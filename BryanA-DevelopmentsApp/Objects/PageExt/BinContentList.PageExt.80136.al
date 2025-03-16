pageextension 80136 "BA Bin Content List" extends "Bin Contents List"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Has Available Serial Nos."; SerialNoDisplay)
            {
                Caption = 'Has Available Serial Nos.';
                Editable = false;

                trigger OnDrillDown()
                var
                    WarehouseEntry: Record "Warehouse Entry";
                    TempWarehouseEntry: Record "Warehouse Entry" temporary;
                    EntryNos: List of [Integer];
                    EntryNo: Integer;
                begin
                    if not Calculated.ContainsKey(Rec.CurrentKey()) or not Calculated.Get(Rec.CurrentKey()) then
                        exit;
                    if not EntryNoLists.Get(Rec.CurrentKey(), EntryNos) then
                        exit;
                    foreach EntryNo in EntryNos do begin
                        WarehouseEntry.Get(EntryNo);
                        TempWarehouseEntry := WarehouseEntry;
                        TempWarehouseEntry.Insert(false);
                    end;
                    Page.Run(0, TempWarehouseEntry);
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    var
        WarehouseEntry: Record "Warehouse Entry";
        WarehouseEntry2: Record "Warehouse Entry";
        EntryNos: List of [Integer];
        HasSerialEntries: Boolean;
    begin
        if not Calculated.ContainsKey(Rec.CurrentKey()) then begin
            SetWarehouseEntryFilters(WarehouseEntry);
            if WarehouseEntry.FindSet() then begin
                SetWarehouseEntryFilters(WarehouseEntry2);
                repeat
                    WarehouseEntry2.SetRange("Serial No.", WarehouseEntry."Serial No.");
                    WarehouseEntry2.SetRange(Quantity, -WarehouseEntry.Quantity);
                    if WarehouseEntry2.IsEmpty() then begin
                        EntryNos.Add(WarehouseEntry."Entry No.");
                        HasSerialEntries := true;
                    end;
                until WarehouseEntry.Next() = 0;
                if HasSerialEntries then
                    EntryNoLists.Add(Rec.CurrentKey(), EntryNos);
            end;
            Calculated.Add(Rec.CurrentKey(), HasSerialEntries);
        end else
            HasSerialEntries := Calculated.Get(Rec.CurrentKey());

        if HasSerialEntries then
            SerialNoDisplay := 'Yes'
        else
            SerialNoDisplay := 'No';
    end;


    local procedure SetWarehouseEntryFilters(var WarehouseEntry: Record "Warehouse Entry")
    begin
        WarehouseEntry.SetCurrentKey("Entry No.", "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated);
        WarehouseEntry.SetRange("Item No.", Rec."Item No.");
        WarehouseEntry.SetRange("Bin Code", Rec."Bin Code");
        WarehouseEntry.SetRange("Location Code", Rec."Location Code");
        WarehouseEntry.SetRange("Variant Code", Rec."Variant Code");
        WarehouseEntry.SetRange("Unit of Measure Code", Rec."Unit of Measure Code");
        WarehouseEntry.SetFilter("Serial No.", '<>%1', '');
        WarehouseEntry.SetAscending("Entry No.", false);
    end;


    var
        EntryNoLists: Dictionary of [Text, List of [Integer]];
        Calculated: Dictionary of [Text, Boolean];
        SerialNoDisplay: Text;
}