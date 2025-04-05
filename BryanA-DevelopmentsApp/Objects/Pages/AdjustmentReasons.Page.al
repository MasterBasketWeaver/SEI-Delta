page 50071 "BA Adjustment Reasons"
{
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Administration;
    SourceTable = "BA Adjustment Reason";
    LinksAllowed = false;
    Caption = 'Adjustment Reasons';

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}