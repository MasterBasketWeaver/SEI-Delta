pageextension 80198 "BA Item Bin Contents" extends "Item Bin Contents"
{
    layout
    {
        modify(CalcQtyUOM)
        {
            ApplicationArea = all;

            trigger OnDrillDown()
            begin
                QtyDrillDown();
            end;
        }
        modify("Quantity (Base)")
        {
            ApplicationArea = all;

            trigger OnDrillDown()
            begin
                QtyDrillDown();
            end;
        }
    }

    local procedure QtyDrillDown()
    var
        WarehouseEntry: Record "Warehouse Entry";
        WarehouseEntries: Page "Warehouse Entries";
        EntryNos: List of [Integer];
        EntryNoFilter: TextBuilder;
        EntryNo: Integer;
    begin
        if not Subscribers.GetMatchingWhseEntriesBySerialNo(EntryNos, Rec."Item No.", Rec."Bin Code", Rec."Location Code",
                Rec."Variant Code", Rec."Unit of Measure Code") or (EntryNos.Count() = 0) then
            exit;
        EntryNo := EntryNos.Get(1);
        EntryNos.RemoveAt(1);
        EntryNoFilter.Append(Format(EntryNo));
        foreach EntryNo in EntryNos do
            EntryNoFilter.Append(StrSubstNo('|%1', EntryNo));

        WarehouseEntry.FilterGroup(3);
        WarehouseEntry.SetFilter("Entry No.", EntryNoFilter.ToText());
        WarehouseEntry.SetAscending("Entry No.", false);
        WarehouseEntry.FilterGroup(0);

        WarehouseEntries.SetTableView(WarehouseEntry);
        WarehouseEntries.Run();
    end;

    var
        Subscribers: Codeunit "BA SEI Subscibers";
}