pageextension 80199 "BA Item Tracking Summary" extends "Item Tracking Summary"
{
    layout
    {
        addfirst(Control1)
        {
            field("BA Item Ledger Entry No."; Rec."BA Item Ledger Entry No.")
            {
                ApplicationArea = all;
            }
            field("BA Location Code"; Rec."BA Location Code")
            {
                ApplicationArea = all;
            }
            field("BA Source Bin Code"; Rec."BA Source Bin Code")
            {
                ApplicationArea = all;
            }
        }
    }
}