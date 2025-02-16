tableextension 80111 "BA Service Line" extends "Service Line"
{
    fields
    {
        field(80050; "BA Booking Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Booking Date';
        }
        // Reserved for field on Service Invoice Line table
        // field(80070; "Omit from POP Report"; Boolean)
        // {
        //     DataClassification = CustomerContent;
        //     Editable = false;
        // }
        // Reserved for field on Sales Invoice Line table
        // field(80071; "BA Order Entry No."; Integer)
        // {
        //     Caption = 'Order Entry No.';
        //     Editable = false;
        //     FieldClass = FlowField;
        //     CalcFormula = lookup ("BA Order Line"."Entry No." where ("Posted Document Type" = const ("Posted Sales Invoice"), "Posted Document No." = field ("Document No."), "Posted Line No." = field ("Line No.")));
        // }
    }
}