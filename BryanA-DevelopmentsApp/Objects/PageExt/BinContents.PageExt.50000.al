pageextension 50120 "BA Bin Contents" extends "Bin Contents"
{
    PromotedActionCategories = 'Navigate';

    layout
    {
        addafter("Item No.")
        {
            field("BA Item Description"; Rec."BA Item Description")
            {
                ApplicationArea = all;
            }
            field("BA Item Description 2"; Rec."BA Item Description 2")
            {
                ApplicationArea = all;
            }
            field("BA Item Blocked"; Rec."BA Item Blocked")
            {
                ApplicationArea = all;
            }
            field("BA Item Hide Visibility"; Rec."BA Item Hide Visibility")
            {
                ApplicationArea = all;
            }
        }
        modify(CalcQtyUOM)
        {
            ApplicationArea = all;
            Visible = false;
        }
        addafter(CalcQtyUOM)
        {
            field("BA Quantity"; Rec."BA Quantity")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addlast(Navigation)
        {
            action("BA Item Reclassification Journal")
            {
                ApplicationArea = all;
                Image = InventoryJournal;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                RunObject = page "Item Reclass. Journal";
                Caption = 'Item Reclassification Journal';
                ToolTip = 'Opens the Item Reclassifcation Journal';
            }
        }
    }
}