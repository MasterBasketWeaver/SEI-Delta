pageextension 80188 "BA Warehouse Entries" extends "Warehouse Entries"
{
    trigger OnOpenPage()
    begin
        Rec.SetView('sorting ("Entry No.") order(descending)');
    end;
}