page 50056 "BA Commission Rates"
{
    SourceTable = "BA Commission Rate";
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Lists;
    Caption = 'Commission Rates';

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
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = all;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = all;
                }
                field("Gen. Prod. Posting Group Code"; Rec."Gen. Prod. Posting Group Code")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SingleInstance: Codeunit "BA Single Instance";
    begin
        if not SingleInstance.CanViewCommissionData() then
            Error(NoAccessErr);
    end;

    var
        NoAccessErr: Label 'You do not have access to view Commission data.';
}