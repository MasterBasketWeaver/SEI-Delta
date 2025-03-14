tableextension 80132 "BA Entry Summary" extends "Entry Summary"
{
    fields
    {
        field(80000; "BA Item Ledger Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Ledger Entry No.';
            Editable = false;
            TableRelation = "Item Ledger Entry"."Entry No.";
        }
    }
}