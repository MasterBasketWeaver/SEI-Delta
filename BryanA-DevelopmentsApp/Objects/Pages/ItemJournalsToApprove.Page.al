page 50070 "BA Item Jnls. to Approve"
{
    Caption = 'Item Journals to Approve';
    SourceTable = "Approval Entry";
    ApplicationArea = all;
    UsageCategory = Lists;
    PageType = List;
    SourceTableView = order(ascending) where ("Table ID" = const (233));
    Editable = false;
    LinksAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = all;
                }
                field("BA Journal Batch Name"; Rec."BA Journal Batch Name")
                {
                    ApplicationArea = all;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        OpenJournalPage();
                    end;
                }
                field("Sender ID"; Rec."Sender ID")
                {
                    ApplicationArea = all;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                }
                field("Date-Time Sent for Approval"; Rec."Date-Time Sent for Approval")
                {
                    ApplicationArea = all;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Approve)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Approve;

                trigger OnAction()
                var
                    ApprovalEntry: Record "Approval Entry";
                begin
                    CurrPage.SetSelectionFilter(ApprovalEntry);
                    ApprovalMgt.ApproveApprovalRequests(ApprovalEntry);
                end;
            }
            action(Reject)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Reject;

                trigger OnAction()
                var
                    ApprovalEntry: Record "Approval Entry";
                begin
                    CurrPage.SetSelectionFilter(ApprovalEntry);
                    ApprovalMgt.RejectApprovalRequests(ApprovalEntry);
                end;
            }
        }
        area(Navigation)
        {
            action(Comments)
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Comment;

                trigger OnAction()
                var
                    RecRef: RecordRef;
                begin
                    RecRef.Get(Rec."Record ID to Approve");
                    Clear(ApprovalMgt);
                    ApprovalMgt.GetApprovalCommentForWorkflowStepInstanceID(RecRef, Rec."Workflow Step Instance ID");
                end;
            }
            action("Open Record")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = OpenJournal;

                trigger OnAction()
                begin
                    OpenJournalPage();
                end;
            }
        }
    }

    var
        ApprovalMgt: Codeunit "Approvals Mgmt.";

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange(Status, Status::Open);
        Rec.SetRange("Approver ID", UserId);
        Rec.FilterGroup(0);
    end;

    local procedure OpenJournalPage()
    var
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlMgt: Codeunit ItemJnlManagement;
    begin
        ItemJnlBatch.Get('ITEM', "BA Journal Batch Name");
        ItemJnlMgt.TemplateSelectionFromBatch(ItemJnlBatch);
    end;
}