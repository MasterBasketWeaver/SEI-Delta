tableextension 80093 "BA Service Inv. Header" extends "Service Invoice Header"
{
    fields
    {
        field(80000; "BA Shipment No."; Code[20])
        {
            Caption = 'Shipment No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("Service Shipment Header"."No." where ("Order No." = field ("Order No.")));
        }
        field(80005; "BA Package Tracking No. Date"; DateTime)
        {
            Caption = 'Package Tracking No. Last Modified';
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
            Editable = false;
        }
        field(80076; "BA Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Shipment Date';
            Editable = false;
        }
        field(80085; "BA Salesperson Verified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Salesperson Verified';
            Editable = false;
        }
        field(80100; "BA Actual Posting DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Actual Posting DateTime';
            Editable = false;
        }
    }

    keys
    {
        key("BA Actual Posting"; "BA Actual Posting DateTime") { }
    }

    trigger OnInsert()
    begin
        Rec."BA Actual Posting DateTime" := CurrentDateTime();
    end;
}