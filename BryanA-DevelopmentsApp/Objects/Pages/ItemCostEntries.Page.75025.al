page 75025 "BA Item Cost Entries"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "BA Item Cost Entry";
    Caption = 'Item Cost Entries';
    PageType = List;
    Editable = false;
    LinksAllowed = false;
    SourceTableView = sorting ("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Item No."; Rec."Item No.") { }
                field("Updated At"; Rec."Updated At") { }
                field("Updated By"; Rec."Updated By") { }
                field("Labour Cost"; Rec."Labour Cost") { }
                field("Material Cost"; Rec."Material Cost") { }
                field("Total Standard Cost"; Rec."Total Standard Cost") { }
            }
        }
    }
}