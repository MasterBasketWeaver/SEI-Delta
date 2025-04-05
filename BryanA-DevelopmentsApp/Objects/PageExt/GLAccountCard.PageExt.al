pageextension 80085 "BA G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addlast(General)
        {
            field("BA Freight Charge"; Rec."BA Freight Charge")
            {
                ApplicationArea = all;
            }
            field("BA Transfer Charge"; Rec."BA Transfer Charge")
            {
                ApplicationArea = all;
            }
            field("BA Require Description Change"; "BA Require Description Change")
            {
                ApplicationArea = all;
            }
        }
    }
}