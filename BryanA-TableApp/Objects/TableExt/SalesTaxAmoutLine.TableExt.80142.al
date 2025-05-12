tableextension 80142 "BA Sales Tax Amount Line" extends "Sales Tax Amount Line"
{
    fields
    {
        field(80000; "BA Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
            Caption = 'Account No.';
            Editable = false;
        }
        field(80001; "BA Orignal Tax %"; Decimal)
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
            Caption = 'Account No.';
            Editable = false;
        }
    }
}