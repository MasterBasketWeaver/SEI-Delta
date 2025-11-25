pageextension 80187 "BA Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        modify("E-Pay Export File Path")
        {
            ApplicationArea = all;
            Visible = true;
        }
        modify("Last E-Pay File Creation No.")
        {
            ApplicationArea = all;
            Visible = false;
            BlankZero = true;
        }
    }
}