tableextension 80133 "BA ACH US Detail" extends "ACH US Detail"
{
    fields
    {
        field(80000; "BA Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            Editable = false;
        }
        field(80001; "BA Receiver Name"; Text[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Receiver Name';
            Editable = false;
        }
    }
}