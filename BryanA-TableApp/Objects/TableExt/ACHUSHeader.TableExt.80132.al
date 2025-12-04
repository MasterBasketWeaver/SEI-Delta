tableextension 80132 "BA ACH US Header" extends "ACH US Header"
{
    fields
    {
        field(80000; "BA Payment Amount Text"; Text[12])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Amount Text';
            Editable = false;
        }
    }
}