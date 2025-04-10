page 50090 "BA Inactive Items"
{
    Caption = 'Inactive Items';
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = Item;
    SourceTableView = sorting("No.") where("BA Hide Visibility" = const(true));
    PageType = List;
    CardPageId = "Item Card";
    LinksAllowed = false;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Reports,Navigate';

    layout
    {
        area(Content)
        {
            group("Item Count")
            {
                Caption = 'Item Count';
                field("Count"; CountText)
                {
                    ApplicationArea = all;
                    ShowCaption = false;
                }
            }
            repeater(Items)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field("No. 2"; Rec."No. 2")
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = all;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = all;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = all;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = all;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = all;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = all;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = all;
                }
                field("ENC Shortcut Dimension 8 Code"; Rec."ENC Shortcut Dimension 8 Code")
                {
                    ApplicationArea = all;
                }
                field("ENC Product ID Code"; Rec."ENC Product ID Code")
                {
                    ApplicationArea = all;
                }
                field("Costing Method"; Rec."Costing Method")
                {
                    ApplicationArea = all;
                }
                field("Standard Cost"; Rec."Standard Cost")
                {
                    ApplicationArea = all;
                }
                field("ENC Created By"; Rec."ENC Created By")
                {
                    ApplicationArea = all;
                }
                field("ENC Created Date"; Rec."ENC Created Date")
                {
                    ApplicationArea = all;
                }
                field("BA Visibility Updated"; Rec."BA Visibility Updated")
                {
                    ApplicationArea = all;
                }
                field("BA Visibility Changed By"; Rec."BA Visibility Changed By")
                {
                    ApplicationArea = all;
                }
                field("ENC NSN No."; Rec."ENC NSN No.")
                {
                    ApplicationArea = all;
                }
                field("ENC Drawing No."; Rec."ENC Drawing No.")
                {
                    ApplicationArea = all;
                }
                field("ENC Drawing Rev. No."; Rec."ENC Drawing Rev. No.")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Item Ledger Entries")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = ItemLedger;
                RunObject = page "Item Ledger Entries";
                RunPageLink = "Item No." = field("No.");
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields(Inventory);
    end;

    trigger OnAfterGetRecord()
    begin
        CountText := Format(Rec.Count, 0, '<Sign><Integer Thousand>');
    end;


    var
        CountText: Text;
}