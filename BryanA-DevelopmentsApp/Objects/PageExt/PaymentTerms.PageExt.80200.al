pageextension 80200 "BA Payment Terms" extends "Payment Terms"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Is Prepaid"; Rec."BA Is Prepaid")
            {
                ApplicationArea = all;
            }
        }
    }
}