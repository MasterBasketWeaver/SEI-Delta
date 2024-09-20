pageextension 80189 "BA Sales Prices" extends "Sales Prices"
{
    layout
    {
        modify("Currency Code")
        {
            Visible = true;
            ApplicationArea = all;
        }
        addlast(Control1)
        {
            field("BA Pricelist Name"; Rec."BA Pricelist Name")
            {
                ApplicationArea = all;
            }
            field("BA Pricelist Year"; "BA Pricelist Year")
            {
                ApplicationArea = all;
            }
        }
    }
}