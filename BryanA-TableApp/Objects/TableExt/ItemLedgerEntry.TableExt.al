tableextension 80069 "BA Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
        field(80000; "BA Year-end Adjst."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Year-end Inventory Adjustment';
            Editable = false;
        }
        field(80011; "BA Adjust. Reason Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Adjustment Reason Code';
            Editable = false;
            TableRelation = "BA Adjustment Reason".Code;
        }
        field(80012; "BA Approved By"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Approved By';
            TableRelation = "User Setup"."User ID";
            Editable = false;
        }
    }
}