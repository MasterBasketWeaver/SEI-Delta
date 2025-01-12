tableextension 80061 "BA Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(80005; "BA Package Tracking No. Date"; DateTime)
        {
            Caption = 'Package Tracking No. Last Modified';
            Editable = false;
        }
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
        field(80030; "BA Order No. DrillDown"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order No.';
            Description = 'Used for Lookup DropDown';
            Editable = false;
        }
        field(80031; "BA Ext. Doc. No. DrillDown"; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
            Description = 'Used for Lookup DropDown';
            Editable = false;
        }
        field(80032; "BA Freight Carrier Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Carrier Name';
            Editable = false;
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
        }
        field(80100; "BA Actual Posting DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Actual Posting DateTime';
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
        field(80112; "BA Invoice/Packing Slip Users"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Invoice/Packing Slip Usernames';
            Editable = false;
        }
    }


    keys
    {
        key(K1; "BA Ext. Doc. No. DrillDown") { }
        key("BA Actual Posting"; "BA Actual Posting DateTime") { }
    }

    fieldgroups
    {
        addlast(DropDown; "BA Order No. DrillDown", "No.", "BA Ext. Doc. No. DrillDown", "BA Posting Date DrillDown", "BA Bill-to Name DrillDown", "BA Ship-to Name DrillDown", "BA Freight Carrier Name", "BA Freight Term Name", "Package Tracking No.", "ENC Physical Ship Date") { }

    }

    trigger OnInsert()
    begin
        Rec."BA Actual Posting DateTime" := CurrentDateTime();
    end;
}