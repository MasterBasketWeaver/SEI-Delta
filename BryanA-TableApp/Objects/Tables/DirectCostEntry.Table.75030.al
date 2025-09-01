table 75030 "BA Direct Cost Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Direct Cost Entry';

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
        field(5; "Direct Cost"; Decimal)
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