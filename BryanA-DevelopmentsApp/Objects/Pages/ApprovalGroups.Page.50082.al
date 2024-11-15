page 50082 "BA Approval Groups"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "BA Approval Group";
    PageType = List;
    LinksAllowed = false;
    Caption = 'Approval Groups';

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
                field("Overdue Date Formulate"; Rec."Overdue Date Formulate")
                {
                    ApplicationArea = all;
                }
                field("Is Military"; Rec."Is Military")
                {
                    ApplicationArea = all;
                }
                field("Is Government"; Rec."Is Government")
                {
                    ApplicationArea = all;
                }
                field("Is Trusted Agent"; Rec."Is Trusted Agent")
                {
                    ApplicationArea = all;
                }
                field("Is Prepaid"; Rec."Is Prepaid")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}