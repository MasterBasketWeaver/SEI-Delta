tableextension 80121 "BA Gen. Product Posting Group" extends "Gen. Product Posting Group"
{
    fields
    {
        field(80000; "BA Division Currency"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Division Currency';
            TableRelation = Currency.Code;
        }
    }
}