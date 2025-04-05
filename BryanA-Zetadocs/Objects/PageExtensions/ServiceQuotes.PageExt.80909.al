pageextension 80909 "BAZD Service Quotes" extends "Service Quotes"
{
    PromotedActionCategories = 'New,Process,Report,Quote,Request Approval,Print/Send,Navigate,Zetadocs';
    actions
    {
        modify(ZddSend)
        {
            Promoted = true;
            PromotedCategory = Category8;
            PromotedIsBig = true;
        }
        modify(ZddOutbox)
        {
            Promoted = true;
            PromotedCategory = Category8;
            PromotedIsBig = true;
        }
        modify(ZddRules)
        {
            Promoted = true;
            PromotedCategory = Category8;
            PromotedIsBig = true;
        }
    }
}