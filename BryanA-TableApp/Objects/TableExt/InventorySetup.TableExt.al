tableextension 80100 "BA Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        field(80000; "BA Approval Required"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Required';
        }
        field(80001; "BA Approval Limit"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Limit';
            MinValue = 0;
        }
        field(80002; "BA Approval Admin1"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Admin1';
            TableRelation = "User Setup"."User ID";
        }
        field(80003; "BA Approval Admin2"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Admin2';
            TableRelation = "User Setup"."User ID";
        }
        field(80004; "BA Approval Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Code';
            TableRelation = "Approval Code".Code;
        }
        field(80010; "BA Default Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Location Code';
            TableRelation = Location.Code;
        }
    }
}