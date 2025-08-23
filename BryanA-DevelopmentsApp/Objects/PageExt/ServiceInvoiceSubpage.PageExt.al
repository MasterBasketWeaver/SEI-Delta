pageextension 80142 "BA Service Invoice Subpage" extends "Service Invoice Subform"
{
    layout
    {
        modify("Location Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                Subscribers: Codeunit "BA SEI Subscibers";
            begin
                Text := Subscribers.LocationListLookup();
                exit(Text <> '');
            end;
        }
        modify("Bin Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                WMSMgt: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                BinCode := WMSMgt.BinContentLookUp(Rec."Location Code", Rec."No.", Rec."Variant Code", '', "Bin Code");
                if BinCode <> '' then
                    Rec.Validate("Bin Code", BinCode);
            end;
        }
    }
}