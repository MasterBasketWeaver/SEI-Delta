pageextension 80912 "BAZD Posted Service Invoices" extends "Posted Service Invoices"
{
    PromotedActionCategories = 'New,Process,Report,Zetadocs';
    actions
    {
        modify(ZddSend)
        {
            Promoted = true;
            PromotedCategory = Category4;
            PromotedIsBig = true;
        }
        modify(ZddOutbox)
        {
            Promoted = true;
            PromotedCategory = Category4;
            PromotedIsBig = true;
        }
        modify(ZddRules)
        {
            Promoted = true;
            PromotedCategory = Category4;
            PromotedIsBig = true;
        }
    }
}