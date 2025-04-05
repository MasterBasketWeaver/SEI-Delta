pageextension 80910 "BAZD Service Orders" extends "Service Orders"
{
    PromotedActionCategories = 'New,Process,Report,Warehouse,Posting,Print/Send,Order,Navigate,Zetadocs';
    actions
    {
        modify(ZddSend)
        {
            Promoted = true;
            PromotedCategory = Category9;
            PromotedIsBig = true;
        }
        modify(ZddOutbox)
        {
            Promoted = true;
            PromotedCategory = Category9;
            PromotedIsBig = true;
        }
        modify(ZddRules)
        {
            Promoted = true;
            PromotedCategory = Category9;
            PromotedIsBig = true;
        }
    }
}