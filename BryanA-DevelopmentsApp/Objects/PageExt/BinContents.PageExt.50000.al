pageextension 50120 "BA Bin Contents" extends "Bin Contents"
{
    layout
    {

        addlast(Control37)
        {
            field("BA Item Description"; Rec."BA Item Description")
            {
                ApplicationArea = all;
            }
            field("BA Item Description 2"; Rec."BA Item Description 2")
            {
                ApplicationArea = all;
            }
            field("BA Item Blocked"; Rec."BA Item Blocked")
            {
                ApplicationArea = all;
            }
            field("BA Item Hide Visibility"; Rec."BA Item Hide Visibility")
            {
                ApplicationArea = all;
            }
        }
        modify(CalcQtyUOM)
        {
            ApplicationArea = all;
            Visible = false;
        }
        addafter(CalcQtyUOM)
        {
            field("BA Quantty"; Rec."BA Quantty")
            {
                ApplicationArea = all;
            }
        }
    }
}