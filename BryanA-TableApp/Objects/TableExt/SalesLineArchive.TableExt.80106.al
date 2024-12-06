tableextension 80106 "BA Sales Line Archive" extends "Sales Line Archive"
{
    fields
    {
        field(75002; "ENC No. 2"; Code[20])
        {
            Caption = 'No. 2';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75005; "ENC Item Assembly BOM"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Assembly BOM';
            Editable = false;
        }
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
        field(80065; "BA New Business - TDG"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'New Business - TDG';
            Editable = false;
        }
    }
}