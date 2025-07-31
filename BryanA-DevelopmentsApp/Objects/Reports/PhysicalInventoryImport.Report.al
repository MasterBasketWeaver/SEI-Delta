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
                    Caption = 'Options';

                    field(DocNo; DocNo)
                    {
                        ApplicationArea = all;
                        Caption = 'Document No.';
                        ShowMandatory = true;
                        Visible = not IsUnitCostImport;
                    }
                    field(LocationCode; LocationCode)
                    {
                        ApplicationArea = all;
                        Caption = 'Location Code';
                        TableRelation = Location.Code;
                        ShowMandatory = true;
                    }
                    field("Select Excel File"; FilePath)
                    {
                        ApplicationArea = all;
                        Editable = false;
                        ToolTip = 'Use the Assist Edit function to select an excel file containing the inventory information to be imported.';
                        ShowMandatory = true;

                        trigger OnAssistEdit()
                        begin
                            OpenFile(TempBlob, FilePath, ImportDialogTitle);
                        end;
                    }
                    field("Show Detailed Instructions"; 'Detailed Instructions')
                    {
                        ApplicationArea = all;
                        ShowCaption = false;
                        Visible = not IsUnitCostImport;

                        trigger OnDrillDown()
                        begin
                            Message(ImportInstructions);
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            FilePath := '';
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::Cancel then
                exit;
            if not IsUnitCostImport then begin
                if TemplateName = '' then
                    Error(NoTemplateNameError);
                if BatchName = '' then
                    Error(NoBatchNameError);
                if DocNo = '' then
                    Error(NoDocumentNoError);
            end;
            if LocationCode = '' then
                Error(NoLocationCodeErr);
            if FilePath = '' then
                Error(NoFilePathError);
        end;

    }


    trigger OnPostReport()
    begin
        ImportExcelToPhysicalItemJnl();
    end;

    local procedure ImportExcelToPhysicalItemJnl()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ItemJnlLine: Record "Item Journal Line";
        Subsrcibers: Codeunit "BA SEI Subscibers";
        Window: Dialog;
        ItemNo: Code[20];
        BinCode: Code[20];
        Qty: Decimal;
        LineNo: Integer;
        RecCount: Integer;
        i: Integer;
        LastRow: Integer;
    begin
        ReadFile(ExcelBuffer, ImportDialogTitle);
        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        if IsUnitCostImport then begin
            ExcelBuffer.SetFilter("Row No.", '>%1', 1);
            if ExcelBuffer.IsEmpty() then
                exit;

            Window.Open('#1####/#2####');
            Window.Update(1, 'Importing Lines');

            ItemJnlLine.SetRange("Location Code", LocationCode);
            ItemJnlLine.SetFilter("Item No.", '<>%1', '');
            if not ItemJnlLine.FindLast() then
                Error('No Item lines found in Journal Batch %1.\There must be at least one line with a non-blank Item No. before Item Revaluations can be imported.', BatchName);
            LineNo := ItemJnlLine."Line No.";
            ItemJnlLine.SetFilter("BA Created At", '<=%1', CurrentDateTime());

            ExcelBuffer.SetRange("Column No.", 1);
            ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
            ExcelBuffer.FindLast();
            LastRow := ExcelBuffer."Row No.";
            RecCount := LastRow - 1;
            for i := 2 to LastRow do begin
                Window.Update(2, StrSubstNo('%1 of %2', i - 1, RecCount));
                ExcelBuffer.Get(i, 2);
                if ExcelBuffer."Cell Value as Text".Trim() <> '' then
                    if Evaluate(Qty, ExcelBuffer."Cell Value as Text") then begin
                        ExcelBuffer.Get(i, 1);
                        ItemNo := CopyStr(ExcelBuffer."Cell Value as Text", 1, MaxStrLen(ItemJnlLine."Item No."));
                        ItemJnlLine.SetRange("Item No.", ItemNo);
                        if ItemJnlLine.FindFirst() then
                            UpdateItemJnlLineUnitCost(ItemJnlLine, Qty)
                        else
                            AddError(ItemNo, 0, StrSubstNo('Item %1 was not found in Journal Batch %2.', ItemNo, BatchName), ErrorBuffer);
                    end else
                        AddError('', 0, StrSubstNo('Could not evaluate "%1" as a decimal.', ExcelBuffer."Cell Value as Text"), ErrorBuffer)
                else
                    AddError('', 0, 'Missing Unit Cost value.', ErrorBuffer);
            end;
            Window.Close();
            ViewErrors(false);
        end else begin
            if Subsrcibers.DoesItemJnlHaveMultipleItemLines(ItemJnlLine) then
                if not Confirm(StrSubstNo(MultiItemLinesMsg, BatchName)) then
                    exit;
            ExcelBuffer.SetFilter("Row No.", '>%1', 1);
            if ExcelBuffer.IsEmpty() then
                exit;
            Window.Open('#1####/#2####');
            Window.Update(1, 'Importing Lines');

            if ItemJnlLine.FindLast() then
                LineNo := ItemJnlLine."Line No.";
            ItemJnlLine.SetFilter("BA Created At", '<=%1', CurrentDateTime());
            ItemJnlLine.SetRange("Location Code", LocationCode);

            ExcelBuffer.SetRange("Column No.", 1);
            ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
            ExcelBuffer.FindLast();
            LastRow := ExcelBuffer."Row No.";
            RecCount := LastRow - 1;
            for i := 2 to LastRow do begin
                Window.Update(2, StrSubstNo('%1 of %2', i - 1, RecCount));
                ExcelBuffer.Get(i, 3);
                if Evaluate(Qty, ExcelBuffer."Cell Value as Text") then begin
                    ExcelBuffer.Get(i, 1);
                    ItemNo := CopyStr(ExcelBuffer."Cell Value as Text", 1, MaxStrLen(ItemJnlLine."Item No."));
                    ExcelBuffer.Get(i, 2);
                    BinCode := CopyStr(ExcelBuffer."Cell Value as Text", 1, MaxStrLen(ItemJnlLine."Bin Code"));
                    ItemJnlLine.SetRange("Item No.", ItemNo);
                    ItemJnlLine.SetRange("Bin Code", BinCode);
                    if ItemJnlLine.FindFirst() then
                        UpdateItemJnlLineQty(ItemJnlLine, Qty)
                    else
                        CreateItemJnlLine(LineNo, ItemNo, Qty, BinCode);
                end;
            end;
            Window.Close();
            ItemJnlLine.SetRange("Item No.", '');
            ItemJnlLine.DeleteAll(true);
            ViewErrors(true);
        end;
    end;



    local procedure ViewErrors(AskConfirm: Boolean)
    begin
        if not ErrorBuffer.FindSet() then
            exit;
        if AskConfirm then
            if not Confirm(ErrorConf, false, ErrorBuffer.Count) then
                exit;
        Page.Run(Page::"BA Phys. Invt. Import Errors", ErrorBuffer);
        if not AskConfirm then
            Message(ViewErrorMsg);
    end;

    local procedure AddError(ItemNo: Code[20]; LineNo: Integer; ErrorMsg: Text; var NameBuffer: Record "Name/Value Buffer")
    var
        ID: Integer;
    begin
        if NameBuffer.FindLast() then
            ID := NameBuffer.ID;
        NameBuffer.Init();
        NameBuffer.ID := ID + 1;
        NameBuffer.Name := ItemNo;
        NameBuffer.Value := Format(LineNo);
        NameBuffer."Value Long" := CopyStr(ErrorMsg, 1, MaxStrLen(NameBuffer."Value Long"));
        NameBuffer.Insert(false);
    end;

    local procedure CreateItemJnlLine(var LineNo: Integer; ItemNo: Code[20]; Qty: Decimal; BinCode: Code[20])
    var
        ItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        Bin: Record Bin;
        HasError: Boolean;
    begin
        if not Item.Get(ItemNo) then begin
            AddError(ItemNo, LineNo, StrSubstNo(NoItemError, ItemNo), ErrorBuffer);
            HasError := true;
        end else
            if Item.Blocked then begin
                AddError(ItemNo, LineNo, StrSubstNo(BlockedItemError, ItemNo), ErrorBuffer);
                HasError := true;
            end else
                if Item."Purchasing Blocked" then begin
                    AddError(ItemNo, LineNo, StrSubstNo(PurchBlockedError, ItemNo), ErrorBuffer);
                    HasError := true;
                end;
        if not Bin.Get(LocationCode, BinCode) then begin
            AddError(ItemNo, LineNo, StrSubstNo(MissingBinErr, BinCode, LocationCode), ErrorBuffer);
            HasError := true;
        end;
        if HasError then
            exit;
        LineNo += 10000;
        ItemJnlLine.Init();
        ItemJnlLine.Validate("Journal Template Name", TemplateName);
        ItemJnlLine.Validate("Journal Batch Name", BatchName);
        ItemJnlLine.Validate("Line No.", LineNo);
        ItemJnlLine.Validate("Document No.", DocNo);
        ItemJnlLine.Validate("Posting Date", PostingDate);
        ItemJnlLine.Validate("Item No.", ItemNo);
        ItemJnlLine.Validate("Location Code", LocationCode);
        ItemJnlLine.Validate("Bin Code", BinCode);
        ItemJnlLine.Validate("Phys. Inventory", true);
        ItemJnlLine.Validate("Qty. (Calculated)", 0);
        ItemJnlLine.Validate("Qty. (Phys. Inventory)", Qty);
        ItemJnlLine.Validate("Bin Code", Bin.Code);
        ItemJnlLine."BA Updated" := true;
        ItemJnlLine.Insert(true);
    end;



    local procedure UpdateItemJnlLineQty(var ItemJnlLine: Record "Item Journal Line"; Qty: Decimal)
    begin
        ItemJnlLine.Validate("Qty. (Phys. Inventory)", Qty);
        ItemJnlLine."BA Updated" := true;
        ItemJnlLine.Modify(true);
    end;

    local procedure UpdateItemJnlLineUnitCost(var ItemJnlLine: Record "Item Journal Line"; UnitCost: Decimal)
    begin
        if ItemJnlLine.Quantity = 0 then begin
            AddError(ItemJnlLine."Item No.", ItemJnlLine."Line No.", 'Quantity must be specified.', ErrorBuffer);
            exit;
        end;
        ItemJnlLine.Validate("Value Entry Type", ItemJnlLine."Value Entry Type"::Revaluation);
        ItemJnlLine.Validate("Unit Cost (Revalued)", UnitCost);
        ItemJnlLine."BA Updated" := true;
        ItemJnlLine.Modify(true);
    end;

    procedure SetParameters(var ItemJnlLine: Record "Item Journal Line"; UnitCostImport: Boolean)
    begin
        TemplateName := ItemJnlLine."Journal Template Name";
        BatchName := ItemJnlLine."Journal Batch Name";
        if ItemJnlLine."Document No." <> '' then
            DocNo := ItemJnlLine."Document No.";
        if ItemJnlLine."Posting Date" <> 0D then
            PostingDate := ItemJnlLine."Posting Date";
        if ItemJnlLine."Location Code" <> '' then
            LocationCode := ItemJnlLine."Location Code";
        IsUnitCostImport := UnitCostImport;
    end;



    local procedure OpenFile(var TempBlob: Record TempBlob; var FileName: Text; WindowName: Text): Boolean
    begin
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, WindowName, '', 'Excel|*.xlsx', 'Excel|*.xlsx');
        exit(FileName <> '');
    end;



    local procedure ReadFile(var ExcelBuffer: Record "Excel Buffer"; WindowName: Text)
    var
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        IStream: InStream;
        FileName: Text;
    begin
        if not ExcelBuffer.IsTemporary() then
            Error(NotTempRecError);
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error(NoSheetsError);
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();
    end;


    var
        TempBlob: Record TempBlob temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        FileMgt: Codeunit "File Management";
        PostingDate: Date;
        FilePath: Text;
        BatchName: Code[20];
        TemplateName: Code[20];
        DocNo: Code[20];
        LocationCode: Code[10];
        [InDataSet]
        IsUnitCostImport: Boolean;


        MultiItemLinesMsg: Label 'Batch %1 has multiple lines for the same item, continue with inventory import?';
        NoTemplateNameError: Label 'Template Name must be specified.';
        NoBatchNameError: Label 'Batch Name must be specified.';
        NoDocumentNoError: Label 'Document No. must be specified.';
        NoFilePathError: Label 'Must select a file to be imported.';
        NotTempRecError: Label 'Must use a temporary record to import excel data.';
        NoSheetsError: Label 'No sheets found.';
        NoItemError: Label 'Item %1 does not exist.';
        BlockedItemError: Label 'Item %1 is blocked.';
        PurchBlockedError: Label 'Item %1 is blocked for purchasing.';
        ViewErrorMsg: Label 'Import failed with the following errors.';
        ErrorConf: Label 'Errors were encountered while processing the import.\Do you want to view them now?';
        ImportDialogTitle: Label 'Physical Inventory Import';
        MissingBinErr: Label 'Bin %1 does not exist for Location %2.';
        ImportInstructions: Label 'After inventory is calculated for the journal, use this feature to upload the physical inventory count numbers into the Qty. (Phys. Inventory) column:\\ - Format an Excel file with 3 columns (Item No., Bin Code & Quantity)\ - Set the Document No. to match the Document No. of the Phys. Inventory Journal\ - Select Excel File\ - The Qty. (Phys. Inventory) column will be updated with the qty. associated with the Item No. & Bin Code\ - If an Item No. or Item No./Bin Code combination in the Excel file doesn’t exist in the journal, they will be added as new lines at the bottom of the journal';
        NoLocationCodeErr: Label 'Location Code must be specified.';
}