pageextension 80186 "BA Payment Journal" extends "Payment Journal"
{
    actions
    {
        modify(TransmitPayments)
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        modify(GenerateEFT)
        {
            ApplicationArea = all;
            Visible = true;
            Enabled = true;
            Promoted = true;
            PromotedCategory = Category4;
            PromotedIsBig = true;
            PromotedOnly = true;
        }
    }
}