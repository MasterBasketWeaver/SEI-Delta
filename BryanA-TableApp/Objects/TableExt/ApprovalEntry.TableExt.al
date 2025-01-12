tableextension 80101 "BA Approval Entry" extends "Approval Entry"
{
    fields
    {
        field(80000; "BA Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Batch Name';
            TableRelation = "Item Journal Batch".Name where ("Journal Template Name" = const ('ITEM'));
        }

        field(80005; "BA Last Sales Activity"; Date)
        {
            Caption = 'Last Sales Activity';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup (Customer."BA Last Sales Activity" where ("No." = Field ("BA Customer No.")));
        }
        field(80006; "BA Salesperson Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Salesperson Code';
            Editable = false;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(80010; "BA Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer No.';
            Editable = false;
            TableRelation = Customer."No.";
            ValidateTableRelation = false;
        }
        field(80011; "BA Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Name';
            Editable = false;
        }
        field(80012; "BA Payment Terms Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Terms Code';
            Editable = false;
        }
        field(80013; "BA Credit Limit"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Limit';
            Editable = false;
        }
        field(80020; "BA Remaining Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Remaining Amount';
            Editable = false;
        }
        field(80021; "BA Remaining Amount (LCY)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Remaining Amount ($)';
            Editable = false;
        }
        field(80025; "BA Approval Group"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Group';
            TableRelation = "BA Approval Group".Code;
            Editable = false;
        }
    }
}