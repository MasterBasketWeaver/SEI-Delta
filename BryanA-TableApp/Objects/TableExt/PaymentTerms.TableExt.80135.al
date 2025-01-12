tableextension 80135 "BA Payment Terms" extends "Payment Terms"
{
    fields
    {
        field(80000; "BA Is Prepaid"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Prepaid';
        }
    }
}