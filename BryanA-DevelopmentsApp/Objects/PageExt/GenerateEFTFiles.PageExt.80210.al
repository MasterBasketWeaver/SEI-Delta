pageextension 80210 "BA Gener" extends "Generate EFT Files"
{
    layout
    {
        addafter(PaymentDescription)
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

    actions
    {
        modify(GenerateEFTFile)
        {
            trigger OnAfterAction()
            var
                TempEFTExportWorkset: Record "EFT Export Workset" temporary;
            begin
                CurrPage.GenerateEFTFileLines.Page.GetColumns(TempEFTExportWorkset);
                if TempEFTExportWorkset.IsEmpty() then
                    CurrPage.Close();
            end;
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