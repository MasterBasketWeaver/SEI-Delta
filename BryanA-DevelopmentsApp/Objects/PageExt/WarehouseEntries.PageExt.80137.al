pageextension 80188 "BA Warehouse Entries" extends "Warehouse Entries"
{
    trigger OnOpenPage()
    begin
        if Rec.GetFilter("Item No.") <> '' then
            Rec.SetView(StrSubstNo('sorting ("Entry No.") order(descending) where("Item No." = Filter(%1))', Rec.GetFilter("Item No.")))
        else
            Rec.SetView('sorting ("Entry No.") order(descending)');
    end;
}