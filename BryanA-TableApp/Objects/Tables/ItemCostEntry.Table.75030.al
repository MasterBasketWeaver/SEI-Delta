table 75030 "BA Item Cost Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Item Cost Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Item No."; Code[20])
        {
            Editable = false;
            TableRelation = Item."No.";
        }
        field(3; "Updated By"; Code[50])
        {
            TableRelation = User."User Name";
            Editable = false;
        }
        field(4; "Updated At"; DateTime)
        {
            Editable = false;
        }
        field(5; "Total Standard Cost"; Decimal)
        {
            Editable = false;
        }
        field(6; "Labour Cost"; Decimal)
        {
            Editable = false;
        }
        field(7; "Material Cost"; Decimal)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K2; "Item No.") { }
        key(K3; "Updated At", "Updated By") { }
    }
}