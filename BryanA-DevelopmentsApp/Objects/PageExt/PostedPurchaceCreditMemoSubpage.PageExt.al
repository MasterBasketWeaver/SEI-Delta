pageextension 80097 "BA P. Purch. Cr.Memo Subpage" extends "Posted Purch. Cr. Memo Subform"
{
    layout
    {
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
            field("BA Shareholder Code"; Rec."BA Shareholder Code")
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