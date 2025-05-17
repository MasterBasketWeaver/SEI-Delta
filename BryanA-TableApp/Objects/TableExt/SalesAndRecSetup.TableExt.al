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
        field(80010; "BA Restrict Order Creation"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Order Creation Time';
        }
        field(80011; "BA Restrict Order Start Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Order Start Time';
        }
        field(80012; "BA Restrict Order End Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Order End Time';
        }
        field(80013; "BA Restrict Monday"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Monday';
        }
        field(80014; "BA Restrict Tuesday"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Tuesday';
        }
        field(80015; "BA Restrict Wednesday"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Wednesday';
        }
        field(80016; "BA Restrict Thursday"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Thursday';
        }
        field(80017; "BA Restrict Friday"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Friday';
        }
        field(80018; "BA Restrict Saturday"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Saturday';
        }
        field(80019; "BA Restrict Sunday"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Restrict Sunday';
        }
        field(80020; "BA Ledger Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Ledger Start Date';
        }
    }
}