tableextension 80131 "BA ACH RB Footer" extends "ACH RB Footer"
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