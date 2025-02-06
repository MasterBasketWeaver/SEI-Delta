pageextension 80121 "BA Sales Order List" extends "Sales Order List"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Sales Source"; "BA Sales Source")
            {
                ApplicationArea = all;
            }
            field("BA Web Lead Date"; "BA Web Lead Date")
            {
                ApplicationArea = all;
            }
            field("BA SEI Int'l Ref. No."; Rec."BA SEI Int'l Ref. No.")
            {
                ApplicationArea = all;
            }
            field("Order Date"; Rec."Order Date")
            {
                ApplicationArea = all;
            }
            field("BA Quote Date"; Rec."BA Quote Date")
            {
                ApplicationArea = all;
            }
            field("Promised Delivery Date"; Rec."Promised Delivery Date")
            {
                ApplicationArea = all;
            }
            field("BA Approval Count"; Rec."BA Approval Count")
            {
                ApplicationArea = all;
            }
            field("BA Last Approval Amount"; Rec."BA Last Approval Amount")
            {
                ApplicationArea = all;
            }
            field("BA Appr. Reject. Reason Code"; Rec."BA Appr. Reject. Reason Code")
            {
                ApplicationArea = all;
            }
            field("BA Salesperson Verified"; Rec."BA Salesperson Verified")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the Salesperson assigned has been confirmed to be correct.';
                Visible = false;
            }
        }
    }
}
