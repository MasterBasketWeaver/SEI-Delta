pageextension 80020 "BA Posted Purch. Rcpt. Subpage" extends "Posted Purchase Rcpt. Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("BA Direct Unit Cost"; Rec."Direct Unit Cost")
            {
                ApplicationArea = all;
            }
            field("BA Line Amount"; "BA Line Amount")
            {
                ApplicationArea = all;
            }
            field("Line Discount %"; Rec."Line Discount %")
            {
                ApplicationArea = all;
            }
            field("BA Line Discount Amount"; Rec."BA Line Discount Amount")
            {
                ApplicationArea = all;
            }
        }
        addlast(Control1)
        {
            field("BA Product ID Code"; Rec."BA Product ID Code")
            {
                ApplicationArea = all;
            }
            field("BA Project Code"; Rec."BA Project Code")
            {
                ApplicationArea = all;
            }
            field("BA Shareholder Code"; "BA Shareholder Code")
            {
                ApplicationArea = all;
            }
            field("BA Capex Code"; Rec."BA Capex Code")
            {
                ApplicationArea = all;
            }
        }
    }

}