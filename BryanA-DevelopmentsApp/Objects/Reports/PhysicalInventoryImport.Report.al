report 50080 "BA Physical Inventory Import"
{
    Caption = 'Physical Inventory Import';
    ProcessingOnly = true;
    ApplicationArea = all;
    UsageCategory = Tasks;

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(DocNo; DocNo)
                    {
                        ApplicationArea = all;
                        Caption = 'Document No.';
                        ShowMandatory = true;
                    }
                    field("Select Excel File"; FilePath)
                    {
                        ApplicationArea = all;
                        Editable = false;
                        ToolTip = 'Use the Assist Edit function to select an excel file containing the inventory information to be imported.';
                        // ToolTip = 'After inventory is calculated for the journal, use this feature to upload the physical inventory count numbers into the Qty. (Phys. Inventory) column. Format an Excel file with 2 columns (Item No. & Quantity) Set the Document No. to match the Document No. of the journal that will receive the Excel file upload. Select "Upload Excel File" and choose the file required. If any items exist in the Excel file that are not on the journal, they will be added as new lines at the bottom of the journal.';
                        // ToolTip = 'After inventory is calculated for the journal, use this feature to upload the physical inventory count numbers into the Qty. (Phys. Inventory) column.';

                        trigger OnAssistEdit()
                        begin
                            OpenFile(TempBlob, FilePath, ImportDialogTitle);
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            FilePath := '';
        end;
    }


    trigger OnPostReport()
    begin
        if TemplateName = '' then
            Error('Template Name must be specified.');
        if BatchName = '' then
            Error('Batch Name must be specified.');
        if DocNo = '' then
            Error('Document No. must be specified.');
        if FilePath = '' then
            Error('Must select a file to be imported.');
        CalculateMissingItems := true;
        ImportExcelToPhysicalItemJnl();
    end;

    local procedure ImportExcelToPhysicalItemJnl()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ItemJnlLine: Record "Item Journal Line";
        Window: Dialog;
        ItemNo: Code[20];
        QtyList: List of [Decimal];
        Qty: Decimal;
        LineNo: Integer;
        RecCount: Integer;
        i: Integer;
    begin
        if not ImportFile(ExcelBuffer, ImportDialogTitle) then
            exit;
        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        if not ExcelBuffer.FindSet() then
            exit;
        Window.Open('#1####/#2####');
        Window.Update(1, 'Reading Lines');
        ExcelBuffer.SetRange("Column No.", 2);
        RecCount := ExcelBuffer.Count();
        repeat
            i += 1;
            Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
            if not Evaluate(Qty, ExcelBuffer."Cell Value as Text") then
                Qty := -1;
            QtyList.Add(Qty);
        until ExcelBuffer.Next() = 0;
        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        if ItemJnlLine.FindLast() then
            LineNo := ItemJnlLine."Line No.";
        Window.Update(1, 'Importing Lines');
        Window.Update(2, '');
        ItemJnlLine.ModifyAll("BA Updated", false);
        ItemJnlLine.SetRange("BA Updated", false);
        ExcelBuffer.SetRange("Column No.", 1);
        ExcelBuffer.FindSet();
        i := 1;
        repeat
            i += 1;
            Window.Update(2, StrSubstNo('%1 of %2', i, RecCount));
            ItemNo := CopyStr(ExcelBuffer."Cell Value as Text", 1, MaxStrLen(ItemJnlLine."Item No."));
            ItemJnlLine.SetRange("Item No.", ItemNo);
            QtyList.Get(ExcelBuffer."Row No.", Qty);
            if Qty <> -1 then
                if ItemJnlLine.FindFirst() then
                    UpdateItemJnlLine(ItemJnlLine, Qty)
                else
                    if CalculateMissingItems then
                        CreateItemJnlLine(LineNo, ItemNo, Qty);
        until ExcelBuffer.Next() = 0;
        Window.Close();

        ItemJnlLine.SetRange("Item No.", '');
        ItemJnlLine.DeleteAll(true);
    end;




    local procedure CreateItemJnlLine(var LineNo: Integer; ItemNo: Code[20]; Qty: Decimal)
    var
        ItemJnlLine: Record "Item Journal Line";
    begin
        LineNo += 10000;
        ItemJnlLine.Init();
        ItemJnlLine.Validate("Journal Template Name", TemplateName);
        ItemJnlLine.Validate("Journal Batch Name", BatchName);
        ItemJnlLine.Validate("Line No.", LineNo);
        ItemJnlLine.Validate("Document No.", DocNo);
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine.Validate("Item No.", ItemNo);
        ItemJnlLine.Validate("Location Code", LocationCode);
        ItemJnlLine.Validate("Phys. Inventory", true);
        ItemJnlLine.Validate("Qty. (Calculated)", 0);
        ItemJnlLine.Validate("Qty. (Phys. Inventory)", Qty);
        ItemJnlLine."BA Updated" := true;
        ItemJnlLine.Insert(true);
    end;



    local procedure UpdateItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; Qty: Decimal)
    begin
        ItemJnlLine.Validate("Qty. (Phys. Inventory)", Qty);
        ItemJnlLine."BA Updated" := true;
        ItemJnlLine.Modify(true);
    end;

    procedure SetParameters(var ItemJnlLine: Record "Item Journal Line")
    begin
        TemplateName := ItemJnlLine."Journal Template Name";
        BatchName := ItemJnlLine."Journal Batch Name";
        DocNo := ItemJnlLine."Document No.";
        PostingDate := ItemJnlLine."Posting Date";
        LocationCode := ItemJnlLine."Location Code";
    end;



    local procedure OpenFile(var TempBlob: Record TempBlob; var FileName: Text; WindowName: Text): Boolean
    begin
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, WindowName, '', 'Excel|*.xlsx', 'Excel|*.xlsx');
        exit(FileName <> '');
    end;



    local procedure ImportFile(var ExcelBuffer: Record "Excel Buffer"; WindowName: Text): Boolean
    var
        NameBuffer: Record "Name/Value Buffer" temporary;
        IStream: InStream;
        FileName: Text;
    begin
        if not ExcelBuffer.IsTemporary then
            Error(NotTempRecError);
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, NameBuffer) then
            Error(NoSheetsError);
        NameBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, NameBuffer.Value);
        ExcelBuffer.ReadSheet();
        exit(true);
    end;


    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        CalculateMissingItems: Boolean;
        BatchName: Code[20];
        TemplateName: Code[20];
        DocNo: Code[20];
        LocationCode: Code[10];
        PostingDate: Date;
        FilePath: Text;

        NotTempRecError: Label 'Must use a temporary record to import excel data.';
        NoSheetsError: Label 'No sheets found.';
        MissingSheetError: Label 'No sheet found with name %1.', Comment = '%1 = Sheetname';
        ImportDialogTitle: Label 'Physical Inventory Import';



}