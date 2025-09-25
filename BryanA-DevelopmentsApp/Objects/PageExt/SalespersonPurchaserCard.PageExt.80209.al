pageextension 80209 "BA Salesperson/Purchaser Card" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter("Commission %")
        {
            field("BA Commission Rate 2"; "BA Commission Rate 2")
            {
                ApplicationArea = all;
            }
            field("BA Commission % 2"; Rec."BA Commission % 2")
            {
                ApplicationArea = all;
            }
            field("BA Commission Rate 3"; "BA Commission Rate 3")
            {
                ApplicationArea = all;
            }
            field("BA Commission % 3"; Rec."BA Commission % 3")
            {
                ApplicationArea = all;
            }
            field("BA Commission Rate 4"; "BA Commission Rate 4")
            {
                ApplicationArea = all;
            }
            field("BA Commission % 4"; Rec."BA Commission % 4")
            {
                ApplicationArea = all;
            }
            field("BA Commission Rate 5"; "BA Commission Rate 5")
            {
                ApplicationArea = all;
            }
            field("BA Commission % 5"; Rec."BA Commission % 5")
            {
                ApplicationArea = all;
            }
        }
    }

    trigger OnOpenPage()
    var
        SingleInstance: Codeunit "BA Single Instance";
    begin
        if not SingleInstance.CanViewCommissionData() then
            Error(NoAccessErr);
    end;

    var
        NoAccessErr: Label 'You do not have access to view this page as it contains Commission data.';
}