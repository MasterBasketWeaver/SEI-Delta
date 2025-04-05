tableextension 80060 "BA Sales Shpt. Header" extends "Sales Shipment Header"
{
    fields
    {
        field(80011; "BA Sell-to County Fullname"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Province/State Fullname';
            Editable = false;
        }
        field(80012; "BA Bill-to County Fullname"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Province/State Fullname';
            Editable = false;
        }
        field(80013; "BA Ship-to County Fullname"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Province/State Fullname';
            Editable = false;
        }
        field(80020; "BA Has Non-G/L Lines"; Boolean)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist ("Sales Shipment Line" where ("Document No." = field ("No."), Type = filter ('<>G/L Account')));
        }
        field(80021; "BA Has Only Empty Lines"; Boolean)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = - exist ("Sales Shipment Line" where ("Document No." = field ("No."), Type = filter ('<>G/L Account'), Quantity = filter ('<>0')));
        }
        field(80025; "BA Sales Source"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Source';
            TableRelation = "BA Sales Source".Name;
            Editable = false;
        }
        field(80026; "BA Web Lead Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Web Lead Date';
            Editable = false;
        }
        field(80046; "BA SEI Barbados Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Barbados Order';
            Editable = false;
        }
        field(80051; "BA EORI No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EORI No.';
            Editable = false;
        }
        field(80052; "BA Ship-to EORI No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to EORI No.';
            Editable = false;
        }
        field(80060; "BA SEI Int'l Ref. No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Int''l Ref. No.';
            Editable = false;
        }
        field(80070; "BA Quote Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Quote Date';
            Editable = false;
        }
        field(80090; "BA Ship-to Email"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Email';
            ExtendedDatatype = EMail;
            Editable = false;
        }
        field(80110; "BA Approval Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Count';
            Editable = false;
        }
        field(80111; "BA Last Approval Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Approval Amount';
            Editable = false;
        }
        field(80125; "BA Salesperson Verified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Salesperson Verified';
            Editable = false;
        }
    }
}