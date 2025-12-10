pageextension 80193 "BA Data Exch. Def. Card" extends "Data Exch Def Card"
{
    layout
    {
        addafter(Type)
        {
            field("BA Require Desciption"; Rec."BA Require Desciption")
            {
                ApplicationArea = all;
            }
        }
    }
}