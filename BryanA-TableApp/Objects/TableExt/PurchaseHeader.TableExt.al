tableextension 80007 "BA Purchase Header" extends "Purchase Header"
{
    fields
    {
        modify("Location Filter")
        {
            TableRelation = Location.Code where ("BA Inactive" = const (false));
        }
        field(80000; "BA Requisition Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Requisition Order';
            Editable = false;
            Description = 'System field to specify Requisition Orders';
        }
        field(80001; "BA Fully Rec'd. Req. Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Fully Received Requisition Order';
            Editable = false;
            Description = 'System field to specify when a Requisition Order is to be considered fully recieved/posted';
        }
        field(80005; "BA Omit Orders"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Omit from Outstanding Orders';
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
        modify("Buy-from County")
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Buy-from Country/Region Code"));
        }
        modify("Pay-to County")
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Pay-to Country/Region Code"));
        }
        modify("Ship-to County")
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Ship-to Country/Region Code"));
        }
    }
}