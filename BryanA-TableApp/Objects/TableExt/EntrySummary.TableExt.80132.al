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
        field(80001; "BA Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            Editable = false;
            TableRelation = Location.Code;
        }
        field(80002; "BA Source Bin Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Bin Code';
            Editable = false;
            TableRelation = Bin.Code where ("Location Code" = field ("BA Location Code"));
        }
    }
}