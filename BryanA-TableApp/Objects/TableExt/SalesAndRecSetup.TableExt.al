tableextension 80036 "BA Sales & Rec. Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(80000; "BA Use Single Currency Pricing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use Single Currency Pricing';
        }
        field(80001; "BA Single Price Currency"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Single Price Currency';
            TableRelation = Currency.Code;
        }
        field(80002; "BA Default Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Reason Code';
            TableRelation = "Reason Code".Code;
        }
        field(80005; "BA Prepaid Order Limit"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Prepaid Order Increase Limit';
            MinValue = 0;
        }
    }
}