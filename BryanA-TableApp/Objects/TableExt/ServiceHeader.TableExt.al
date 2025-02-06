tableextension 80026 "BA Service Header" extends "Service Header"
{
    fields
    {
        modify("Location Filter")
        {
            TableRelation = Location.Code where ("BA Inactive" = const (false));
        }
        modify(County)
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Country/Region Code"));
        }
        modify("Bill-to County")
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Bill-to Country/Region Code"));
        }
        modify("Ship-to County")
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Ship-to Country/Region Code"));
        }
        field(80020; "BA Quote Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Exchange Rate';
            Editable = false;
        }
        field(80030; "BA Amount"; Decimal)
        {
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("Service Line"."Line Amount" where ("Document Type" = field ("Document Type"), "Document No." = field ("No.")));
        }
        field(80031; "BA Amount Including Tax"; Decimal)
        {
            Caption = 'Amount Including Tax';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("Service Line"."Outstanding Amount" where ("Document Type" = field ("Document Type"), "Document No." = field ("No.")));
        }
        field(80032; "BA Amount Including Tax (LCY)"; Decimal)
        {
            Caption = 'Amount Including Tax (LCY)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum ("Service Line"."Outstanding Amount (LCY)" where ("Document Type" = field ("Document Type"), "Document No." = field ("No.")));
        }
        field(80051; "BA EORI No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EORI No.';
        }
        field(80052; "BA Ship-to EORI No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to EORI No.';
        }
        field(80070; "BA Quote Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Quote Date';
            Editable = false;
        }
        field(80075; "BA Promised Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Promised Delivery Date';
        }
        field(80076; "BA Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Shipment Date';

            trigger OnValidate()
            begin
                Rec.Validate("BA Promised Delivery Date", Rec."BA Shipment Date");
                Rec.Modify(true);
            end;
        }
        field(80085; "BA Salesperson Verified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Salesperson Verified';
        }
    }
}