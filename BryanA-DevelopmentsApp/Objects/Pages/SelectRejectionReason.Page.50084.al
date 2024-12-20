page 50084 "BA Select Rejection Reason"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = StandardDialog;
    LinksAllowed = false;
    Caption = 'Select Rejection Reason';

    layout
    {
        area(Content)
        {
            field(ReasonCode; ReasonCode)
            {
                ApplicationArea = all;
                ShowMandatory = true;
                TableRelation = "BA Approval Rejection".Code;
                ShowCaption = false;
            }
        }
    }

    procedure GetReasonCode(): Code[20]
    begin
        exit(ReasonCode);
    end;

    var
        ReasonCode: Code[20];
}