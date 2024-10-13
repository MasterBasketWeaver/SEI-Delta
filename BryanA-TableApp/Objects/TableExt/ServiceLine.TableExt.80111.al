tableextension 80111 "BA Service Line" extends "Service Line"
{
    fields
    {
        field(80050; "BA Booking Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Booking Date';
            Editable = false;
        }
    }
}