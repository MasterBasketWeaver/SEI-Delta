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
                    if not Calculated.ContainsKey(Rec.RecordId()) or not Calculated.Get(Rec.RecordId()) then
                        exit;
                    if not EntryNoLists.Get(Rec.RecordId(), EntryNos) then
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
        if not Calculated.ContainsKey(Rec.RecordId()) then begin
            Rec.CalcFields(Quantity);
            if Rec.Quantity <> 0 then
                HasSerialEntries := Subscribers.GetMatchingWhseEntriesBySerialNo(EntryNos, Rec."Item No.", Rec."Bin Code", Rec."Location Code",
                    Rec."Variant Code", Rec."Unit of Measure Code");
            Calculated.Add(Rec.RecordId(), HasSerialEntries);
        end else
            HasSerialEntries := Calculated.Get(Rec.RecordId());

        if HasSerialEntries then
            SerialNoDisplay := 'Yes'
        else
            SerialNoDisplay := 'No';
    end;



    var
        Subscribers: Codeunit "BA SEI Subscibers";
        EntryNoLists: Dictionary of [RecordId, List of [Integer]];
        Calculated: Dictionary of [RecordId, Boolean];
        SerialNoDisplay: Text;
}