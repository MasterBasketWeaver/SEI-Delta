tableextension 80080 "BA Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(80010; "BA Omit from Reports"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Omit From Reports';
        }
        field(80050; "BA Booking Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Booking Date';
        }
        field(80065; "BA New Business - TDG"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'New Business - TDG';
        }
    }
}