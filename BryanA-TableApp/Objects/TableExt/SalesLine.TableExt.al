tableextension 80002 "BA Sales Line" extends "Sales Line"
{
    fields
    {
        field(80000; "BA Org. Qty. To Ship"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Original Qty. to Ship';
            Editable = false;
        }
        field(80001; "BA Org. Qty. To Invoice"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Original Qty. to Invoice';
            Editable = false;
        }
        field(80002; "BA Stage"; Option)
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("Sales Header"."ENC Stage" where ("Document Type" = field ("Document Type"), "No." = field ("Document No.")));
            Caption = 'Stage';
            Editable = false;
            OptionMembers = " ","Open","Closed/Lost","Closed/Other","Archive";
        }
        field(80046; "BA Allow Rename"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Rename';
            Editable = false;
            Description = 'System field to override default rename functionality';
        }
        field(80050; "BA Booking Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Booking Date';
        }
        field(80060; "BA Skip Reservation Date Check"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Skip Reservation Date Check';
            Editable = false;
            Description = 'System field to allow Shipment Date to be deleted when there is a linked Assembly Header.';
        }
    }
}