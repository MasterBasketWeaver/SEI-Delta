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
    }

    actions
    {
        addlast(Processing)
        {
            action("BA Update Approval User")
            {
                ApplicationArea = all;
                Caption = 'Update All Approver IDs';
                Image = UserInterface;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
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
                            UserSetup.Validate("Approver ID", ApprovalUserCode);
                            UserSetup.Modify(true);
                        until UserSetup.Next() = 0;
                end;
            }
        }
    }
}