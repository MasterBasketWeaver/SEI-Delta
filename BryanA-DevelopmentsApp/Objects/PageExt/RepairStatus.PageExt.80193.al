pageextension 80193 "BA Repair Status" extends "Repair Status"
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