pageextension 80914 "BAZD Posted Serv. Credit Memos" extends "Posted Service Credit Memos"
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