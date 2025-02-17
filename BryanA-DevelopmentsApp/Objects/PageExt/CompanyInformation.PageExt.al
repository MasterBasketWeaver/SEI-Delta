pageextension 80135 "BA Company Information" extends "Company Information"
{
    layout
    {
        modify("System Indicator Text")
        {
            ApplicationArea = all;
            Editable = false;
        }
        addafter("Phone No.2")
        {
            field("BA Ship-To Phone No."; Rec."BA Ship-To Phone No.")
            {
                ApplicationArea = all;
            }
        }
        addafter("E-Mail")
        {
            field("BA Ship-To Email"; Rec."BA Ship-To Email")
            {
                ApplicationArea = all;
            }
            field("BA Accounting AR Email"; Rec."BA Accounting AR Email")
            {
                ApplicationArea = all;
            }
            field("BA Purchasing Email"; Rec."BA Purchasing Email")
            {
                ApplicationArea = all;
            }
        }
    }
}