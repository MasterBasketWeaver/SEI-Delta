pageextension 80210 "BA Salespersons/Purchasers" extends "Salespersons/Purchasers"
{
    layout
    {
        addafter("Commission %")
        {
            field("BA Commission % 2"; Rec."BA Commission % 2")
            {
                ApplicationArea = all;
            }
            field("BA Commission % 3"; Rec."BA Commission % 3")
            {
                ApplicationArea = all;
            }
            field("BA Commission % 4"; Rec."BA Commission % 4")
            {
                ApplicationArea = all;
            }
            field("BA Commission % 5"; Rec."BA Commission % 5")
            {
                ApplicationArea = all;
            }
        }
    }
}