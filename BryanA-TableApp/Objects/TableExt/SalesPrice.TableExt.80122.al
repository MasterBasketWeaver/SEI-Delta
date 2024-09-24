tableextension 80122 "BA Sales Price" extends "Sales Price"
{
    fields
    {
        field(80000; "BA Pricelist Name"; Text[25])
        {
            DataClassification = CustomerContent;
            Caption = 'Pricelist Name';
        }
        field(80001; "BA Pricelist Year"; Text[4])
        {
            DataClassification = CustomerContent;
            Caption = 'Pricelist Year';
            CharAllowed = '0123456789';
        }
    }
}