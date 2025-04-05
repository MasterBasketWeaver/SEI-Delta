pageextension 80913 "BAZD Posted Service Invoice" extends "Posted Service Invoice"
{
    PromotedActionCategories = 'New,Process,Report,Invoice,Print/Send,Zetadocs';
    actions
    {
        modify(ZddSend)
        {
            Promoted = true;
            PromotedCategory = Category6;
            PromotedIsBig = true;
        }
        modify(ZddOutbox)
        {
            Promoted = true;
            PromotedCategory = Category6;
            PromotedIsBig = true;
        }
        modify(ZddRules)
        {
            Promoted = true;
            PromotedCategory = Category6;
            PromotedIsBig = true;
        }
    }
}