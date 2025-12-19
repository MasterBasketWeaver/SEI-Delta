pageextension 80210 "BA Gener" extends "Generate EFT Files"
{
    layout
    {
        addlast(Content)
        {
            field("Test Payment"; TestPayment)
            {
                ApplicationArea = all;
            }
        }
    }

    trigger OnOpenPage()
    begin
        TestPayment := false;
    end;

    var
        TestPayment: Boolean;

}