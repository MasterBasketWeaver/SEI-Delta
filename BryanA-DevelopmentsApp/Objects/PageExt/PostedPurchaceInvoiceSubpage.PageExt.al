pageextension 80096 "BA Posted Purch. Inv. Subpage" extends "Posted Purch. Invoice Subform"
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