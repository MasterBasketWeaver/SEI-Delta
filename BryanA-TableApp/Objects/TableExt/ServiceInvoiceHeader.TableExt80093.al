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
        field(80030; "BA Order No. DrillDown"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order No.';
            Description = 'Used for Lookup DropDown';
            Editable = false;
        }
        field(80032; "BA Freight Carrier Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Carrier Name';
            // Editable = false;
        }
        field(80033; "BA Freight Term Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Term Name';
            Editable = false;
        }
        field(80034; "BA Posting Date DrillDown"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
            Description = 'Used for Lookup DropDown';
            Editable = false;
        }
        field(80035; "BA Ship-to Name DrillDown"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Name';
            Description = 'Used for Lookup DropDown';
            Editable = false;
        }
        field(80036; "BA Bill-to Name DrillDown"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bill-to Name';
            Description = 'Used for Lookup DropDown';
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
        key(K1; "BA Order No. DrillDown") { }
        key("BA Actual Posting"; "BA Actual Posting DateTime") { }
    }

    fieldgroups
    {
        addlast(DropDown; "BA Order No. DrillDown", "No.", "ENC External Document No.", "BA Posting Date DrillDown", "BA Bill-to Name DrillDown", "BA Ship-to Name DrillDown", "BA Freight Carrier Name", "BA Freight Term Name", "ENC Package Tracking No.", "ENC Physical Ship Date") { }

    }

    trigger OnInsert()
    begin
        Rec."BA Actual Posting DateTime" := CurrentDateTime();
    end;
}