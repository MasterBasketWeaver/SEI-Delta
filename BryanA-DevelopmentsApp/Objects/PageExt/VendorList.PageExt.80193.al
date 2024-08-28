pageextension 80192 "BA Vendor List" extends "Vendor List"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Vendor Performance Rank"; Rec."ENC Vendor Performance Rank")
            {
                ApplicationArea = all;
            }
        }
    }
}