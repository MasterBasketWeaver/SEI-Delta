page 75025 "BA Item Cost Entries"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "BA Direct Cost Entry";
    Caption = 'Item Cost Entries';
    PageType = List;
    Editable = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; "Entry No.") { }
                field("Item No."; "Item No.") { }
                field("Updated At"; "Updated At") { }
                field("Updated By"; "Updated By") { }
                field("Direct Cost"; "Direct Cost") { }
            }
        }
    }
}