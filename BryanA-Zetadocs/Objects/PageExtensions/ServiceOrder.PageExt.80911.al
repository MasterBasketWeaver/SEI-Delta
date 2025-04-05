pageextension 80911 "BAZD Service Order" extends "Service Order"
{
    PromotedActionCategories = 'New,Process,Report,Warehouse,Print/Send,Release,Posting,Order,Navigate,Zetadocs';
    actions
    {
        modify(ZddSend)
        {
            Promoted = true;
            PromotedCategory = Category10;
            PromotedIsBig = true;
        }
        modify(ZddOutbox)
        {
            Promoted = true;
            PromotedCategory = Category10;
            PromotedIsBig = true;
        }
        modify(ZddRules)
        {
            Promoted = true;
            PromotedCategory = Category10;
            PromotedIsBig = true;
        }
    }
}