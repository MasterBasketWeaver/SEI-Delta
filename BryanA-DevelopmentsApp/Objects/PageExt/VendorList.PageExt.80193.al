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
            field("BA Address"; Rec.Address)
            {
                ApplicationArea = all;
            }
            field("BA Address 2"; Rec."Address 2")
            {
                ApplicationArea = all;
            }
            field("Payment Method Code"; Rec."Payment Method Code")
            {
                ApplicationArea = all;
            }
            field("Preferred Bank Account Code"; Rec."Preferred Bank Account Code")
            {
                ApplicationArea = all;
            }
        }
    }
}