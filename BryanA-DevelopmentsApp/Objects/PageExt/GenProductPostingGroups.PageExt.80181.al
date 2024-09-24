pageextension 80181 "BA Gen. Product Posting Groups" extends "Gen. Product Posting Groups"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Division Currency"; Rec."BA Division Currency")
            {
                ApplicationArea = all;
            }
        }
    }
}