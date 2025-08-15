pageextension 80176 "BA Approval User Setup" extends "Approval User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Receive Prod. Approvals"; Rec."BA Receive Prod. Approvals")
            {
                ApplicationArea = all;
            }
        }
        addafter("Approver ID")
        {
            field("BA Purch. Approver ID"; Rec."BA Purch. Approver ID")
            {
                ApplicationArea = all;
            }
        }
        addafter("Approval Administrator")
        {
            field("BA Purch. Approval Admin"; Rec."BA Purch. Approval Admin")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("BA Update Sales Approval User")
            {
                ApplicationArea = all;
                Caption = 'Update All Sales Approver ID''s';
                Image = AdministrationSalesPurchases;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    UpdateApprover(false);
                end;
            }
            action("BA Update Purch. Approval User")
            {
                ApplicationArea = all;
                Caption = 'Update All Purchase Approver ID''s';
                Image = SalesPurchaseTeam;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    UpdateApprover(true);
                end;
            }
        }
    }

    local procedure UpdateApprover(Purchase: Boolean)
    var
        UserSetup: Record "User Setup";
        UserSetupList: Page "User Setup";
        ApprovalUserCode: Code[50];
    begin
        UserSetupList.LookupMode(true);
        if UserSetupList.RunModal() <> Action::LookupOK then
            exit;
        UserSetupList.GetRecord(UserSetup);
        ApprovalUserCode := UserSetup."User ID";
        if ApprovalUserCode = '' then
            exit;
        UserSetup.Reset();
        UserSetup.SetFilter("User ID", '<>%1', ApprovalUserCode);
        if UserSetup.FindSet() then
            repeat
                if Purchase then
                    UserSetup.Validate("BA Purch. Approver ID", ApprovalUserCode)
                else
                    UserSetup.Validate("Approver ID", ApprovalUserCode);
                UserSetup.Modify(true);
            until UserSetup.Next() = 0;
        UserSetup.Get(ApprovalUserCode);
        if Purchase then
            UserSetup.Validate("BA Purch. Approver ID", '')
        else
            UserSetup.Validate("Approver ID", '');
        UserSetup.Modify(true);
    end;
}