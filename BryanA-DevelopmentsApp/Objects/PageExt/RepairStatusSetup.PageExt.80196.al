pageextension 80196 "BA Repair Status Setup" extends "Repair Status Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Salesperson Verification"; Rec."BA Salesperson Verification")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if Salesperson Verification must be true for the related Service Order before it can be posted.';
            }
        }
    }
}