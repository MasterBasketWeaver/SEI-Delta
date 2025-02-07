pageextension 80119 "BA General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addlast(Control1900309501)
        {
            field("BA Country Code"; Rec."BA Country Code")
            {
                ApplicationArea = all;
            }
            field("BA Region Code"; Rec."BA Region Code")
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