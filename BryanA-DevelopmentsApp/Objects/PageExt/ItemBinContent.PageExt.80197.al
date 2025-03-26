pageextension 80197 "BA Item Bin Contents" extends "Item Bin Contents"
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
        EntryNos: List of [Integer];
        EntryNoFilter: TextBuilder;
        EntryNo: Integer;
    begin
        if not Subscribers.GetMatchingWhseEntriesBySerialNo(EntryNos, Rec."Item No.", Rec."Bin Code", Rec."Location Code",
                Rec."Variant Code", Rec."Unit of Measure Code") or (EntryNos.Count() = 0) then
            exit;
        EntryNo := EntryNos.Get(0);
        EntryNos.RemoveAt(0);
        EntryNoFilter.Append(Format(EntryNo));
        foreach EntryNo in EntryNos do
            EntryNoFilter.Append(StrSubstNo('|%1', EntryNo));
        WarehouseEntry.SetFilter("Entry No.", EntryNoFilter.ToText());
        Page.Run(Page::"Warehouse Entries", WarehouseEntry);
    end;

    var
        Subscribers: Codeunit "BA SEI Subscibers";
}