page 50080 "BA Temp Sales Price"
{
    SourceTable = "Sales Price";
    PageType = List;
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'Temp Sales Price';

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field("Item No."; "Item No.")
                {
                    ApplicationArea = all;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = all;
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = all;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = all;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = all;
                }
                field("Minimum Quantity"; "Minimum Quantity")
                {
                    ApplicationArea = all;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = all;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = all;
                }
                field("BA Pricelist Name"; "BA Pricelist Name")
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
}