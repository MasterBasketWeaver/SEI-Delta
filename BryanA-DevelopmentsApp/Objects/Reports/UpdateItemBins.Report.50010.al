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
                    // field(ItemFilter; ItemFilter)
                    // {
                    //     ApplicationArea = all;
                    //     TableRelation = Item."No." where (Blocked = const (false));
                    //     ShowMandatory = true;
                    //     Caption = 'Item Filter';
                    // }
                    field(OldLocationCode; OldLocationCode)
                    {
                        ApplicationArea = all;
                        TableRelation = Location.Code;
                        ShowMandatory = true;
                        Caption = 'Current Location Code';
                    }
                    // field(OldBinCode; OldBinCode)
                    // {
                    //     ApplicationArea = all;
                    //     Caption = 'Current Bin Code';
                    //     ShowMandatory = true;

                    //     trigger OnLookup(var Text: Text): Boolean
                    //     begin
                    //         exit(BinLookup(OldLocationCode, NewBinCode, OldBinCode, true));
                    //     end;
                    // }
                    field(NewLocationCode; NewLocationCode)
                    {
                        ApplicationArea = all;
                        TableRelation = Location.Code;
                        ShowMandatory = true;
                        Caption = 'New Location Code';
                    }
                    // field(NewBinCode; NewBinCode)
                    // {
                    //     ApplicationArea = all;
                    //     Caption = 'New Bin Code';
                    //     ShowMandatory = true;

                    //     trigger OnLookup(var Text: Text): Boolean
                    //     begin
                    //         exit(BinLookup(NewLocationCode, OldBinCode, NewBinCode, false));
                    //     end;
                    // }
                    // field("Quantity to Handle"; QtyToHandle)
                    // {
                    //     ApplicationArea = all;
                    //     ShowMandatory = true;
                    //     BlankZero = true;
                    //     DecimalPlaces = 0 : 2;
                    // }
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
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::Cancel then
                exit;
            if OldLocationCode = '' then
                Error('Current Location must be specified');
            // if OldBinCode = '' then
            //     Error('Current Bin Code must be specified');
            if NewLocationCode = '' then
                Error('New Location must be specified');
            // if NewBinCode = '' then
            //     Error('New Bin Code must be specified');
            // if OldBinCode = NewBinCode then
            //     Error('Current and new bin codes must be different: %1', OldBinCode);
            // if QtyToHandle = 0 then
            //     Error('Quantity to handle must be specified.');
            if PostingDate = 0D then
                Error('Posting Date must be specified.');
            if DocNo = '' then
                Error('Document No. must be specfied.');
        end;
    }

    // local procedure BinLookup(LocationCode: Code[10]; OldCode: Code[20]; var NewCode: Code[20]; HideEmpty: Boolean): Boolean
    // var
    //     Item: Record Item;
    //     Bin: Record Bin;
    //     BinList: Page "Bin List";
    // begin
    //     if LocationCode = '' then
    //         exit;
    //     Bin.FilterGroup(2);
    //     Bin.SetRange("Location Code", LocationCode);
    //     if HideEmpty then
    //         Bin.SetRange(Empty, false);
    //     if OldCode <> '' then
    //         Bin.SetFilter(Code, '<>%1', OldCode);
    //     Bin.FilterGroup(0);
    //     BinList.LookupMode(true);
    //     BinList.SetTableView(Bin);
    //     if BinList.RunModal() <> Action::LookupOK then
    //         exit;
    //     BinList.GetRecord(Bin);
    //     NewCode := Bin.Code;
    // end;

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
            Error('No Sheets in file.');
        NameBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, NameBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        ExcelBuffer.SetRange("Column No.", 1);
        if not ExcelBuffer.FindSet() then
            Error('No data found in file.');

        ItemJnlLine.SetRange("Journal Template Name", TemplateName);
        ItemJnlLine.SetRange("Journal Batch Name", BatchName);
        if ItemJnlLine.FindLast() then
            LineNo := ItemJnlLine."Line No.";

        Window.Open('Populating Lines...\#1##');
        RecCount := ExcelBuffer.Count;
        BinContent.SetCurrentKey("Default", "Location Code", "Item No.", "Variant Code", "Bin Code");
        BinContent.SetRange("Location Code", OldLocationCode);
        BinContent.SetFilter("Bin Code", '<>%1', '');
        BinContent.SetFilter(Quantity, '>%1', 0);
        BinContent.SetAutoCalcFields(Quantity);
        repeat
            i += 1;
            Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
            if ExcelBuffer.Get(i, 1) and Item.Get(CopyStr(ExcelBuffer."Cell Value as Text", 1, MaxStrLen(Item."No."))) then begin
                BinContent.SetRange(Default, true);
                BinContent.SetRange("Item No.", Item."No.");
                if BinContent.FindFirst() then begin
                    DefaultBin := BinContent."Bin Code";
                    BinContent.SetRange(Default, false);
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
        ItemFilter: Text;
        OldLocationCode: Code[10];
        NewLocationCode: Code[10];
        TemplateName: Code[10];
        BatchName: Code[10];
        DocNo: Code[20];


}