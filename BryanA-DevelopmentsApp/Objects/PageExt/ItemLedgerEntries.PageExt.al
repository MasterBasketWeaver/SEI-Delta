pageextension 80088 "BA Item Ledger Entries" extends "Item Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Year-end Adjst."; Rec."BA Year-end Adjst.")
            {
                ApplicationArea = all;
            }
            field("BA Adjust. Reason Code"; Rec."BA Adjust. Reason Code")
            {
                ApplicationArea = all;
            }
            field("BA Approved By"; Rec."BA Approved By")
            {
                ApplicationArea = all;
            }
        }
    }
}