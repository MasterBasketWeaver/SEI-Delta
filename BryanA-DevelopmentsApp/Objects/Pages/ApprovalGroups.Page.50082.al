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
                    ShowMandatory = NeedOverDue;
                }
                field("Is Military"; Rec."Is Military")
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    begin
                        UpdateOverDue();
                    end;
                }
                field("Is Government"; Rec."Is Government")
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    begin
                        UpdateOverDue();
                    end;
                }
                field("Is Trusted Agent"; Rec."Is Trusted Agent")
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    begin
                        UpdateOverDue();
                    end;
                }
                field("Is Prepaid"; Rec."Is Prepaid")
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    begin
                        UpdateOverDue();
                    end;
                }
            }
        }
    }

    var
        [InDataSet]
        NeedOverDue: Boolean;

    trigger OnAfterGetRecord()
    begin
        UpdateOverDue();
    end;

    local procedure UpdateOverDue()
    begin
        NeedOverDue := (Rec."Is Trusted Agent") or (not Rec."Is Government" and not Rec."Is Military" and not Rec."Is Prepaid");
    end;
}