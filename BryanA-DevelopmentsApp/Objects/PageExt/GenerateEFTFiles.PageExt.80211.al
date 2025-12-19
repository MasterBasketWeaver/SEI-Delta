pageextension 80211 "BA Generate EFT Files" extends "Generate EFT Files"
{
    layout
    {
        addafter(PaymentDescription)
        {
            field("Test Transaction"; TestTransaction)
            {
                ApplicationArea = all;

                trigger OnValidate()
                begin
                    SingleInstance.SetEFTTestTransaction(TestTransaction);
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
        TestTransaction := SingleInstance.GetEFTTestTransaction();
    end;

    var
        SingleInstance: Codeunit "BA Single Instance";
        TestTransaction: Boolean;

}