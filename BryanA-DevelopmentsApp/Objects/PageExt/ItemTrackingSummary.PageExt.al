pageextension 80199 "BA Item Tracking Summary" extends "Item Tracking Summary"
{
    layout
    {
        addfirst(Control1)
        {
            field("BA Source Bin Code"; SourceBinCode)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Source Bin Code';
                TableRelation = Bin.Code;
            }
            field("BA Item Ledger Entry No."; Rec."BA Item Ledger Entry No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        WarehouseEntry: Record "Warehouse Entry";
    begin
        if Rec."Table ID" <> Database::"Item Ledger Entry" then
            exit;
        if not ItemLedgerEntry.Get(Rec."BA Item Ledger Entry No.") then
            exit;

        WarehouseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated);
        WarehouseEntry.SetRange("Item No.", ItemLedgerEntry."Item No.");
        WarehouseEntry.SetRange("Location Code", ItemLedgerEntry."Location Code");
        WarehouseEntry.SetRange("Variant Code", ItemLedgerEntry."Variant Code");
        WarehouseEntry.SetRange("Unit of Measure Code", ItemLedgerEntry."Unit of Measure Code");
        WarehouseEntry.SetRange("Lot No.", ItemLedgerEntry."Lot No.");
        WarehouseEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
        WarehouseEntry.SetRange("Registering Date", ItemLedgerEntry."Posting Date");
        IF WarehouseEntry.FindFirst() THEN
            SourceBinCode := WarehouseEntry."Bin Code"
        ELSE
            SourceBinCode := '';
    end;

    var
        SourceBinCode: Code[20];
}