page 50010 "BA Purch. Requests to Approve"
{
    ApplicationArea = Suite;
    Caption = 'Purchase Requests to Approve';
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Approval Entry";
    SourceTableView = SORTING ("Approver ID", Status, "Due Date", "Date-Time Sent for Approval") ORDER(Ascending) where ("Table ID" = const (38));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Line)
            {
                field(ToApprove; Rec.RecordCaption)
                {
                    ApplicationArea = Suite;
                    Caption = 'To Approve';
                    ToolTip = 'Specifies the record that you are requested to approve. On the Home tab, in the Process group, choose Record to view the record on a new page where you can also act on the approval request.';
                    Width = 30;
                }
                field(Details; Rec.RecordDetails)
                {
                    ApplicationArea = Suite;
                    Caption = 'Details';
                    ToolTip = 'Specifies details about the approval request, such as what and who the request is about.';
                    Width = 50;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = Suite;
                    HideValue = NOT Comment;
                    ToolTip = 'Specifies whether there are comments relating to the approval of the record. If you want to read the comments, choose the field to open the Approval Comment Sheet window.';
                }
                field("Sender ID"; Rec."Sender ID")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the ID of the user who sent the approval request for the document to be approved.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Suite;
                    StyleExpr = DateStyle;
                    ToolTip = 'Specifies when the record must be approved, by one or more approvers.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the approval status for the entry:';
                    Visible = ShowAllEntries;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the total amount (excl. tax) on the document awaiting approval.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the total amount in $ (excl. tax) on the document awaiting approval.';
                }
                field("BA Remaining Amount"; Rec."BA Remaining Amount")
                {
                    ApplicationArea = all;
                }
                field("BA Remaining Amount (LCY)"; Rec."BA Remaining Amount (LCY)")
                {
                    ApplicationArea = all;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code of the currency of the amounts on the sales or purchase lines.';
                }

                field("BA Customer No."; Rec."BA Customer No.")
                {
                    ApplicationArea = all;
                }
                field("BA Customer Name"; Rec."BA Customer Name")
                {
                    ApplicationArea = all;
                }
                field("BA Last Sales Activity"; Rec."BA Last Sales Activity")
                {
                    ApplicationArea = all;
                }
                field("BA Payment Terms Code"; Rec."BA Payment Terms Code")
                {
                    ApplicationArea = all;
                    Caption = 'Payment Terms Code';
                }
                field("BA Salesperson Code"; Rec."BA Salesperson Code")
                {
                    ApplicationArea = all;
                }
                field("BA Credit Limit"; Rec."BA Credit Limit")
                {
                    ApplicationArea = all;
                }
                field("BA Approval Group"; Rec."BA Approval Group")
                {
                    ApplicationArea = all;
                }
            }
        }
        area(factboxes)
        {
            part(CommentsFactBox; 9104)
            {
                ApplicationArea = Suite;
                Visible = ShowCommentFactbox;
            }
            part(Change; 1527)
            {
                ApplicationArea = Suite;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                UpdatePropagation = SubPart;
                Visible = ShowChangeFactBox;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Show)
            {
                Caption = 'Show';
                Image = View;
                action("Record")
                {
                    ApplicationArea = Suite;
                    Caption = 'Open Record';
                    Enabled = ShowRecCommentsEnabled;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    ToolTip = 'Open the document, journal line, or card that the approval is requested for.';

                    trigger OnAction()
                    begin
                        ShowRecord;
                    end;
                }
                action(Comments)
                {
                    ApplicationArea = Suite;
                    Caption = 'Comments';
                    Enabled = ShowRecCommentsEnabled;
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Process;
                    Scope = Repeater;
                    ToolTip = 'View or add comments for the record.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        RecRef: RecordRef;
                    begin
                        RecRef.GET("Record ID to Approve");
                        CLEAR(ApprovalsMgmt);
                        ApprovalsMgmt.GetApprovalCommentForWorkflowStepInstanceID(RecRef, "Workflow Step Instance ID");
                    end;
                }
            }
        }
        area(processing)
        {
            // action(Test)
            // {
            //     ApplicationArea = All;
            //     Image = TestDatabase;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     Scope = Repeater;

            //     trigger OnAction()
            //     var
            //         SalesHeader: Record "Sales Header";
            //         PurchaseHeader: Record "Purchase Header";
            //     begin
            //         SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
            //         SalesHeader.FindFirst();
            //         SalesHeader.SetRange("No.", SalesHeader."No.");
            //         PurchaseHeader.Get(Rec."Record ID to Approve");
            //         PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type");
            //         PurchaseHeader.SetRange("No.", PurchaseHeader."No.");
            //         Report.Run(Report::"BA Prod. Order Approval", false, false, SalesHeader);
            //         Report.Run(Report::"BA Prod. Order Approval", false, false, PurchaseHeader);
            //     end;
            // }
            action(Approve)
            {
                ApplicationArea = Suite;
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Approve the requested changes.';

                trigger OnAction()
                var
                    ApprovalEntry: Record "Approval Entry";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    CurrPage.SETSELECTIONFILTER(ApprovalEntry);
                    ApprovalsMgmt.ApproveApprovalRequests(ApprovalEntry);
                end;
            }
            action(Reject)
            {
                ApplicationArea = Suite;
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Reject the approval request.';

                trigger OnAction()
                var
                    ApprovalEntry: Record "Approval Entry";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    CurrPage.SETSELECTIONFILTER(ApprovalEntry);
                    ApprovalsMgmt.RejectApprovalRequests(ApprovalEntry);
                end;
            }
            action(Delegate)
            {
                ApplicationArea = Suite;
                Caption = 'Delegate';
                Image = Delegate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                ToolTip = 'Delegate the approval to a substitute approver.';

                trigger OnAction()
                var
                    ApprovalEntry: Record "Approval Entry";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    CurrPage.SETSELECTIONFILTER(ApprovalEntry);
                    ApprovalsMgmt.DelegateApprovalRequests(ApprovalEntry);
                end;
            }
            group(View)
            {
                Caption = 'View';
                action(OpenRequests)
                {
                    ApplicationArea = Suite;
                    Caption = 'Open Requests';
                    Image = Approvals;
                    ToolTip = 'Open the approval requests that remain to be approved or rejected.';

                    trigger OnAction()
                    begin
                        SETRANGE(Status, Status::Open);
                        ShowAllEntries := FALSE;
                    end;
                }
                action(AllRequests)
                {
                    ApplicationArea = Suite;
                    Caption = 'All Requests';
                    Image = AllLines;
                    ToolTip = 'View all approval requests that are assigned to you.';

                    trigger OnAction()
                    begin
                        SETRANGE(Status);
                        ShowAllEntries := TRUE;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RecRef: RecordRef;
    begin
        ShowChangeFactBox := CurrPage.Change.PAGE.SetFilterFromApprovalEntry(Rec);
        ShowCommentFactbox := CurrPage.CommentsFactBox.PAGE.SetFilterFromApprovalEntry(Rec);
        ShowRecCommentsEnabled := RecRef.GET("Record ID to Approve");
    end;

    trigger OnAfterGetRecord()
    begin
        SetDateStyle;
    end;

    trigger OnOpenPage()
    begin
        FILTERGROUP(2);
        SETRANGE("Approver ID", USERID);
        FILTERGROUP(0);
        SETRANGE(Status, Status::Open);
    end;

    var
        DateStyle: Text;
        ShowAllEntries: Boolean;
        ShowChangeFactBox: Boolean;
        ShowRecCommentsEnabled: Boolean;
        ShowCommentFactbox: Boolean;

    local procedure SetDateStyle()
    begin
        DateStyle := '';
        IF IsOverdue THEN
            DateStyle := 'Attention';
    end;
}

