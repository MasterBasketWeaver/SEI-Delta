pageextension 80915 "BAZD Posted Serv. Credit Memo" extends "Posted Service Credit Memo"
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