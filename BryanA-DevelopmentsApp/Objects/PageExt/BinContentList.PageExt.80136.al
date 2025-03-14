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
                begin
                    if WarehouseEntry.GetFilters() = '' then
                        SetWarehouseEntryFilters();
                    if WarehouseEntry.FindSet() then
                        Page.Run(0, WarehouseEntry);
                end;
            }
        }
    }

    local procedure SetWarehouseEntryFilters()
    begin
        WarehouseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated);
        WarehouseEntry.SetRange("Item No.", Rec."Item No.");
        WarehouseEntry.SetRange("Bin Code", Rec."Bin Code");
        WarehouseEntry.SetRange("Location Code", Rec."Location Code");
        WarehouseEntry.SetRange("Variant Code", Rec."Variant Code");
        WarehouseEntry.SetRange("Unit of Measure Code", Rec."Unit of Measure Code");
        WarehouseEntry.SetFilter("Serial No.", '<>%1', '');
    end;

    trigger OnAfterGetRecord()
    begin
        SetWarehouseEntryFilters();
        if WarehouseEntry.IsEmpty() then
            SerialNoDisplay := 'No'
        else
            SerialNoDisplay := 'Yes';
    end;



    var
        WarehouseEntry: Record "Warehouse Entry";
        SerialNoDisplay: Text;
}