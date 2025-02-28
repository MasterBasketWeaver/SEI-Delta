page 50083 "BA Approval Rejections"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "BA Approval Rejection";
    PageType = List;
    LinksAllowed = false;
    Caption = 'Approval Rejections';

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}