report 50010 "BA Update Item Bins"
{
    ProcessingOnly = true;
    Caption = 'Update Item Bins';


    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(OldLocationCode; OldLocationCode)
                    {
                        ApplicationArea = all;
                        TableRelation = Location.Code;
                        ShowMandatory = true;
                        Caption = 'Current Location Code';
                    }
                    field(NewLocationCode; NewLocationCode)
                    {
                        ApplicationArea = all;
                        TableRelation = Location.Code;
                        ShowMandatory = true;
                        Caption = 'New Location Code';
                    }
                    field("Posting Date"; PostingDate)
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                    }
                    field("Document No."; DocNo)
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            OldLocationCode := 'DELTA';
            NewLocationCode := 'DELTA';
            PostingDate := WorkDate();
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::Cancel then
                exit;
            if OldLocationCode = '' then
                Error(NoCurrentLocationErr);
            if NewLocationCode = '' then
                Error(NoNewLocationErr);
            if PostingDate = 0D then
                Error(NoPostingDateErr);
            if DocNo = '' then
                Error(NoDocNoErr);
        end;
    }


    procedure SetItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    begin
        TemplateName := ItemJnlLine."Journal Template Name";
        BatchName := ItemJnlLine."Journal Batch Name";
    end;


    trigger OnPostReport()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        NameBuffer: Record "Name/Value Buffer" temporary;
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        BinContent: Record "Bin Content";
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        Window: Dialog;
        DefaultBin: Code[20];
        RecCount: Integer;
        LineNo: Integer;
        i: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Customer List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, NameBuffer) then
            Error(NoSheetErr);
        NameBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, NameBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        ExcelBuffer.SetRange("Column No.", 1);
        if not ExcelBuffer.FindSet() then
            Error(NoDataErr);

        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        if ItemJnlLine.FindLast() then
            LineNo := ItemJnlLine."Line No.";

        Window.Open(WindowTitle);
        RecCount := ExcelBuffer.Count;
        BinContent.SetCurrentKey("Default", "Location Code", "Item No.", "Variant Code", "Bin Code");
        BinContent.SetRange("Location Code", OldLocationCode);
        BinContent.SetFilter("Bin Code", '<>%1', '');
        BinContent.SetAutoCalcFields(Quantity);
        i := 1;
        repeat
            i += 1;
            Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
            if ExcelBuffer.Get(i, 1) and Item.Get(CopyStr(ExcelBuffer."Cell Value as Text", 1, MaxStrLen(Item."No."))) then begin
                BinContent.SetRange(Quantity);
                BinContent.SetRange(Default, true);
                BinContent.SetRange("Item No.", Item."No.");
                if BinContent.FindFirst() then begin
                    DefaultBin := BinContent."Bin Code";
                    BinContent.SetRange(Default, false);
                    BinContent.SetFilter(Quantity, '>%1', 0);
                    if BinContent.FindSet() then
                        repeat
                            LineNo += 10000;
                            ItemJnlLine.Init();
                            ItemJnlLine.Validate("Journal Template Name", TemplateName);
                            ItemJnlLine.Validate("Journal Batch Name", BatchName);
                            ItemJnlLine.Validate("Line No.", LineNo);
                            ItemJnlLine.Validate("Document No.", DocNo);
                            ItemJnlLine.Validate("Posting Date", PostingDate);
                            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::Transfer);
                            ItemJnlLine.Validate("Item No.", Item."No.");
                            ItemJnlLine.Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
                            ItemJnlLine.Validate("Location Code", OldLocationCode);
                            ItemJnlLine.Validate("Bin Code", BinContent."Bin Code");
                            ItemJnlLine.Validate("New Location Code", NewLocationCode);
                            ItemJnlLine.Validate("New Bin Code", DefaultBin);
                            ItemJnlLine.Validate(Quantity, BinContent.Quantity);
                            ItemJnlLine.Insert(true);
                        until BinContent.Next() = 0;
                end;
            end;
        until ExcelBuffer.Next() = 0;

        Window.Close();
    end;


    var
        PostingDate: Date;
        OldLocationCode: Code[10];
        NewLocationCode: Code[10];
        TemplateName: Code[10];
        BatchName: Code[10];
        DocNo: Code[20];

        NoCurrentLocationErr: Label 'Current Location must be specified';
        NoNewLocationErr: Label 'New Location must be specified';
        NoPostingDateErr: Label 'Posting Date must be specified.';
        NoDocNoErr: Label 'Document No. must be specfied.';
        NoSheetErr: Label 'No Sheets in file.';
        NoDataErr: Label 'No data found in file.';
        WindowTitle: Label 'Populating Lines...\#1##';
}