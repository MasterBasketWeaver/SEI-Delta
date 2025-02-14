page 50090 "BA Inactive Items"
{
    Caption = 'Inactive Items';
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = Item;
    SourceTableView = sorting ("No.") where ("BA Hide Visibility" = const (true));
    PageType = List;
    CardPageId = "Item Card";
    LinksAllowed = false;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Items)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
                field("BA Visibility Updated"; "BA Visibility Updated")
                {
                    ApplicationArea = all;
                }
                field("BA Visibility Changed By"; "BA Visibility Changed By")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}