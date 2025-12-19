pageextension 80210 "BA Gener" extends "Generate EFT Files"
{
    layout
    {
        addlast(Content)
        {
            field("Test Payment"; TestPayment)
            {
                ApplicationArea = all;

                trigger OnValidate()
                begin
                    SingleInstance.SetEFTTestTransaction(TestPayment);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        TestPayment := SingleInstance.GetEFTTestTransaction();
    end;

    var
        SingleInstance: Codeunit "BA Single Instance";
        TestPayment: Boolean;

}