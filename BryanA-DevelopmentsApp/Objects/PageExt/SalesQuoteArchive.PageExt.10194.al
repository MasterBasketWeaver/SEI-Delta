pageextension 80194 "BA Sales Quote Archive" extends "Sales Quote Archive"
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