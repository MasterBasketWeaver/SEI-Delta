tableextension 80001 "BA Sales Header" extends "Sales Header"
{
    fields
    {
        modify("Location Filter")
        {
            TableRelation = Location.Code where ("BA Inactive" = const (false));
        }
        field(80000; "BA Copied Doc."; Boolean)
        {
            DataClassification = CustomerContent;
            Description = 'System field use to specify if a document was created via CopyDoc codeunit';
            Caption = 'Copied Document';
            Editable = false;
        }
        field(80011; "BA Sell-to County Fullname"; Text[50])
        {
            Caption = 'Province/State Fullname';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Province/State".Name where ("Print Full Name" = const (true), "Country/Region Code" = field ("Sell-to Country/Region Code"), Symbol = field ("Sell-to County")));
            Editable = false;
        }
        field(80012; "BA Bill-to County Fullname"; Text[50])
        {
            Caption = 'Province/State Fullname';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Province/State".Name where ("Print Full Name" = const (true), "Country/Region Code" = field ("Bill-to Country/Region Code"), Symbol = field ("Bill-to County")));
            Editable = false;
        }
        field(80013; "BA Ship-to County Fullname"; Text[50])
        {
            Caption = 'Province/State Fullname';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Province/State".Name where ("Print Full Name" = const (true), "Country/Region Code" = field ("Ship-to Country/Region Code"), Symbol = field ("Ship-to County")));
            Editable = false;
        }
        modify("Sell-to County")
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Sell-to Country/Region Code"));
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
        field(80025; "BA Sales Source"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Source';
            TableRelation = "BA Sales Source".Name;
        }
        field(80026; "BA Web Lead Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Web Lead Date';
        }
        field(80045; "BA Allow Rename"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Rename';
            Editable = false;
            Description = 'System field to override default rename functionality';
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
        }
        field(80052; "BA Ship-to EORI No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to EORI No.';
        }
        field(80060; "BA SEI Int'l Ref. No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Int''l Ref. No.';
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
        field(80112; "BA Use Default Workflow"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use Default Workflow';
            Editable = false;
        }
        field(80113; "BA Use Custom Workflow Start"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use Custom Workflow Start';
            Editable = false;
        }
        // field(80114; "BA Approval Email"; Text[100])
        // {
        //     DataClassification = CustomerContent;
        //     Caption = 'Approval Email';
        //     Editable = false;
        //     ExtendedDatatype = EMail;
        // }
        field(80115; "BA Appr. Reject. Reason Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Reject Reason Code';
            Editable = false;
            TableRelation = "BA Approval Rejection".Code;

            trigger OnValidate()
            begin
                Rec.CalcFields("BA Rejection Reason");
            end;
        }
        field(80116; "BA Rejection Reason"; Text[100])
        {
            Caption = 'Approval Email User ID';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Approval Rejection".Description where (Code = field ("BA Appr. Reject. Reason Code")));
            Editable = false;
        }
        field(80117; "BA Approval Email User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Email User ID';
            Editable = false;
            TableRelation = User."User Name";
        }
    }
}