pageextension 80195 "BA Sales Order Archive" extends "Sales Order Archive"
{
    layout
    {
        addafter("Salesperson Code")
        {
            field("BA Salesperson Verified"; Rec."BA Salesperson Verified")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the Salesperson assigned has been confirmed to be correct.';
            }
        }
    }
}