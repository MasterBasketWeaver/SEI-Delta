tableextension 80105 "BA Sales Header Archive" extends "Sales Header Archive"
{
    fields
    {
        field(75001; "ENC Ship-to Phone No."; Code[30])
        {
            Caption = 'Ship-to Phone No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75002; "ENC Sell-to Phone No."; Code[30])
        {
            Caption = 'Sell-to Phone No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75003; "ENC Pick List Exist"; Boolean)
        {
            Caption = 'Pick List Exist';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75011; "ENC Freight Term"; Code[20])
        {
            Caption = 'Freight Term';
            TableRelation = "ENC Freight Term";
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75012; "ENC Freight Quote No."; Code[20])
        {
            Caption = 'Freight Quote No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75013; "ENC Freight Account No."; Code[20])
        {
            Caption = 'Freight Account No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75014; "ENC Physical Ship Date"; Date)
        {
            Caption = 'Physical Ship Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75015; "ENC Freight Invoice Billed"; Decimal)
        {
            Caption = 'Freight Invoice Billed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75020; "ENC Tax Registration No."; Code[30])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75021; "ENC Ship-To Tax Reg. No."; Code[20])
        {
            Caption = 'Ship-To Tax Registration No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75030; "ENC Probabilty %"; Integer)
        {
            Caption = 'Probabilty %';
            MinValue = 0;
            MaxValue = 100;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75035; "ENC Stage"; Option)
        {
            Caption = 'Stage';
            OptionMembers = " ","Open","Closed/Lost","Closed/Other","Archive";
            OptionCaption = ' ,Open,Closed/Lost,Closed/Other,Archive';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75036; "ENC Timeline"; Option)
        {
            Caption = 'Timeline';
            OptionMembers = " ","1 - 2 Weeks","2 - 3 Weeks","3 - 4 Weeks","5 - 6 Weeks","8+ Weeks","Not This Fiscal Year";
            OptionCaption = ' ,1 - 2 Weeks,2 - 3 Weeks,3 - 4 Weeks,5 - 6 Weeks,8+ Weeks,Not This Fiscal Year';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75037; "ENC Lead Time"; Code[20])
        {
            Caption = 'Lead Time';
            TableRelation = "ENC Lead Time".Code;
            ValidateTableRelation = true;
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75040; "ENC FID No."; Code[20])
        {
            Caption = 'FID No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75041; "ENC Ship-To FID No."; Code[20])
        {
            Caption = 'Ship-To FID No.';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(75045; "ENC BBD Sell-To No."; Code[30])
        {
            Caption = 'BBD Sell-To No.';
            TableRelation = "ENC BBD Sell-To"."No." where (Company = const (BBD));
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75046; "ENC BBD Sell-To PO No."; Text[30])
        {
            Caption = 'BBD Sell-To PO No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75047; "ENC BBD Sell-To Name"; Text[100])
        {
            Caption = 'BBD Sell-To Name';
            TableRelation = "ENC BBD Sell-To"."No." where (Company = const (BBD));
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75048; "ENC BBD Contact"; Code[30])
        {
            Caption = 'BBD Contact';
            TableRelation = "ENC BBD Contact"."No." where (Company = const (BBD));
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(75050; "ENC AWS Sell-To No."; Code[30])
        {
            Caption = 'AWS Sell-To No.';
            TableRelation = "ENC BBD Sell-To"."No." where (Company = const (AWS));
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(75051; "ENC AWS Sell-To PO No."; Text[30])
        {
            Caption = 'AWS Sell-To PO No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75052; "ENC AWS Sell-To Name"; Text[100])
        {
            Caption = 'AWS Sell-To Name';
            TableRelation = "ENC BBD Sell-To"."No." where (Company = const (AWS));
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75053; "ENC AWS Contact"; Code[30])
        {
            Caption = 'AWS Contact';
            TableRelation = "ENC BBD Contact"."No." where (Company = const (AWS));
            DataClassification = CustomerContent;
            Editable = false;
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
            Caption = 'Rejection Reason';
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
        field(80118; "BA Sent for Invoice Request"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sent for Invoice Request';
        }
        
        field(80125; "BA Salesperson Verified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Salesperson Verified';
            Editable = false;
        }
    }
}