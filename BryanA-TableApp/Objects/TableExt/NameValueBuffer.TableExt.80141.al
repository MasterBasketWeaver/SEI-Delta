tableextension 80141 "BA Name/Value Buffer" extends "Name/Value Buffer"
{
    fields
    {
        field(80000; "BA Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            Editable = false;
        }
        field(80001; "BA Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            Editable = false;
        }
        field(80002; "BA Dmension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dmension Set ID';
            Editable = false;
        }
    }
}