tableextension 80140 "BA Tax Jurisdiction" extends "Tax Jurisdiction"
{
    fields
    {
        field(80000; "BA Pass Through (Purchases)"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Pass Through (Purchases)';
        }
    }
}