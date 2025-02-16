tableextension 80080 "BA Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(80010; "BA Omit from Reports"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Omit From Reports';
        }
        field(80050; "BA Booking Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Booking Date';
        }
        field(80065; "BA New Business - TDG"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'New Business - TDG';
        }
        field(80070; "BA Omit from POP Report"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Omit from POP Report';
        }
        field(80071; "BA Order Entry No."; Integer)
        {
            Caption = 'Order Entry No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Order Line"."Entry No." where ("Posted Document Type" = const ("Posted Sales Invoice"), "Posted Document No." = field ("Document No."), "Posted Line No." = field ("Line No.")));
        }
    }
}