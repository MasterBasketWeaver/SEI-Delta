tableextension 80133 "BA ACH US Header" extends "ACH US Header"
{
    fields
    {
        field(80000; "BA Payment Amount Text"; Text[12])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Amount Text';
            Editable = false;
        }
        field(80001; "BA Due Date"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Due Date';
            Editable = false;
        }
        field(80002; "BA Work Date"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Work Date';
            Editable = false;
        }
    }
}