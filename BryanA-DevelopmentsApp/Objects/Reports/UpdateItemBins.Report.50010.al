report 50010 "BA Update Item Bins"
{
    ProcessingOnly = true;
    Caption = 'Update Item Bins';
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
                    field(ItemFilter; ItemFilter)
                    {
                        ApplicationArea = all;
                        TableRelation = Item."No." where (Blocked = const (false));
                        ShowMandatory = true;
                        Caption = 'Item Filter';
                    }
                    field(OldLocationCode; OldLocationCode)
                    {
                        ApplicationArea = all;
                        TableRelation = Location.Code;
                        ShowMandatory = true;
                        Caption = 'Current Location Code';

                        trigger OnValidate()
                        begin
                            OldBinCode := '';
                        end;
                    }
                    field(OldBinCode; OldBinCode)
                    {
                        ApplicationArea = all;
                        Caption = 'Current Bin Code';
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(BinLookup(OldLocationCode, NewBinCode, OldBinCode, true));
                        end;
                    }
                    field(NewLocationCode; NewLocationCode)
                    {
                        ApplicationArea = all;
                        TableRelation = Location.Code;
                        ShowMandatory = true;
                        Caption = 'New Location Code';

                        trigger OnValidate()
                        begin
                            NewBinCode := '';
                        end;
                    }
                    field(NewBinCode; NewBinCode)
                    {
                        ApplicationArea = all;
                        Caption = 'New Bin Code';
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(BinLookup(NewLocationCode, OldBinCode, NewBinCode, false));
                        end;
                    }
                    field("Quantity to Handle"; QtyToHandle)
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                        BlankZero = true;
                        DecimalPlaces = 0 : 2;
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

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::Cancel then
                exit;
            if OldLocationCode = '' then
                Error('Current Location must be specified');
            if OldBinCode = '' then
                Error('Current Bin Code must be specified');
            if NewLocationCode = '' then
                Error('New Location must be specified');
            if NewBinCode = '' then
                Error('New Bin Code must be specified');
            if OldBinCode = NewBinCode then
                Error('Current and new bin codes must be different: %1', OldBinCode);
            if QtyToHandle = 0 then
                Error('Quantity to handle must be specified.');
            if PostingDate = 0D then
                Error('Posting Date must be specified.');
            if DocNo = '' then
                Error('Document No. must be specfied.');
        end;
    }

    local procedure BinLookup(LocationCode: Code[10]; OldCode: Code[20]; var NewCode: Code[20]; HideEmpty: Boolean): Boolean
    var
        Item: Record Item;
        Bin: Record Bin;
        BinList: Page "Bin List";
    begin
        if LocationCode = '' then
            exit;
        Bin.FilterGroup(2);
        Bin.SetRange("Location Code", LocationCode);
        if HideEmpty then
            Bin.SetRange(Empty, false);
        if OldCode <> '' then
            Bin.SetFilter(Code, '<>%1', OldCode);
        Bin.FilterGroup(0);
        BinList.LookupMode(true);
        BinList.SetTableView(Bin);
        if BinList.RunModal() <> Action::LookupOK then
            exit;
        BinList.GetRecord(Bin);
        NewCode := Bin.Code;
    end;

    procedure SetItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    var
        ItemJnlLine2: Record "Item Journal Line";
    begin
        ItemJnlLine2.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
        ItemJnlLine2.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
        if ItemJnlLine2.FindLast() then
            LineNo := ItemJnlLine2."Line No.";
        TemplateName := ItemJnlLine."Journal Template Name";
        BatchName := ItemJnlLine."Journal Batch Name";
    end;

    trigger OnPostReport()
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        BinContent: Record "Bin Content";
        Window: Dialog;
        RecCount: Integer;
        i: Integer;
    begin
        Item.SetFilter("No.", ItemFilter);
        Item.SetRange(Blocked, false);
        RecCount := Item.Count;
        Window.Open('Inserting Lines\#1###');
        Item.FindSet();
        BinContent.SetAutoCalcFields(Quantity);
        repeat
            i += 1;
            Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
            if BinContent.Get(OldLocationCode, OldBinCode, Item."No.", '', Item."Base Unit of Measure") then
                if BinContent.Quantity > 0 then begin
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
                    ItemJnlLine.Validate("Bin Code", OldBinCode);
                    ItemJnlLine.Validate("New Location Code", NewLocationCode);
                    ItemJnlLine.Validate("New Bin Code", NewBinCode);
                    if QtyToHandle > BinContent.Quantity then
                        ItemJnlLine.Validate(Quantity, BinContent.Quantity)
                    else
                        ItemJnlLine.Validate(Quantity, QtyToHandle);
                    ItemJnlLine.Insert(true);
                end;
        until Item.Next() = 0;
        Window.Close();
    end;

    var
        PostingDate: Date;
        ItemFilter: Text;
        OldLocationCode: Code[10];
        NewLocationCode: Code[10];
        OldBinCode: Code[20];
        NewBinCode: Code[20];
        TemplateName: Code[10];
        BatchName: Code[10];
        DocNo: Code[20];
        QtyToHandle: Decimal;
        LineNo: Integer;


}