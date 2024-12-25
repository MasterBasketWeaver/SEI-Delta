codeunit 75012 "BA Sales Approval Mgt."
{
    procedure UpdateCustomerApprovalGroup(var Customer: Record Customer)
    begin
        UpdateCustomerApprovalGroup(Customer, true);
    end;

    procedure UpdateCustomerApprovalGroup(var Customer: Record Customer; ReloadRecord: Boolean)
    var
        ApprovalGroup: Record "BA Approval Group";
        PaymentTerms: Record "Payment Terms";
    begin
        if PaymentTerms.Get(Customer."Payment Terms Code") then;
        case true of
            Customer."BA Trusted Agent": //D
                begin
                    ApprovalGroup.SetRange("Is Trusted Agent", true);
                    ApprovalGroup.FindFirst();
                    Customer.Validate("BA Approval Group", ApprovalGroup.Code);
                end;
            Customer."BA Government (CDN/US)" or (Customer."ENC Military" <> Customer."ENC Military"::" "): //C
                begin
                    ApprovalGroup.SetRange("Is Military", true);
                    if not ApprovalGroup.FindFirst() then begin
                        ApprovalGroup.SetRange("Is Military");
                        ApprovalGroup.SetRange("Is Government", true);
                        ApprovalGroup.FindFirst();
                    end;
                    Customer.Validate("BA Approval Group", ApprovalGroup.Code);
                end;
            PaymentTerms."BA Is Prepaid": //A
                begin
                    ApprovalGroup.SetRange("Is Prepaid", true);
                    ApprovalGroup.FindFirst();
                    Customer.Validate("BA Approval Group", ApprovalGroup.Code);
                end;
            else begin //B
                    ApprovalGroup.SetRange("Is Government", false);
                    ApprovalGroup.SetRange("Is Military", false);
                    ApprovalGroup.SetRange("Is Prepaid", false);
                    ApprovalGroup.SetRange("Is Trusted Agent", false);
                    ApprovalGroup.FindFirst();
                    Customer.Validate("BA Approval Group", ApprovalGroup.Code);
                end;
        end;
        Customer.Modify(true);
        if ReloadRecord then
            Customer.Get(Customer."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Payment Terms Code', false, false)]
    local procedure CustomerOnAfterValidatePaymentTermsCode(var Rec: Record Customer)
    begin
        UpdateCustomerApprovalGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'BA Government (CDN/US)', false, false)]
    local procedure CustomerOnAfterValidateGovernment(var Rec: Record Customer)
    begin
        UpdateCustomerApprovalGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'BA Trusted Agent', false, false)]
    local procedure CustomerOnAfterValidateTrustedAgent(var Rec: Record Customer)
    begin
        UpdateCustomerApprovalGroup(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'ENC Military', false, false)]
    local procedure CustomerOnAfterValidateMilitary(var Rec: Record Customer)
    begin
        UpdateCustomerApprovalGroup(Rec);
    end;







    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', false, false)]
    local procedure WorkflowMgtOnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; var IsHandled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        WorkflowStepInstance: Record "Workflow Step Instance";

        WorkflowMgt: Codeunit "Workflow Management";
        RecRef: RecordRef;
    begin
        if not TryToGetRecord(RecRef, Variant) then
            exit;
        if RecRef.Number <> Database::"Sales Header" then
            exit;
        RecRef.SetTable(SalesHeader);

        // if not Confirm('%1, %2', false, FunctionName, SalesHeader."BA Use Default Workflow") then
        //     Error('');

        if SalesHeader."BA Use Default Workflow" then begin
            SalesHeader."BA Use Default Workflow" := false;
            SalesHeader.Modify(false);
            exit;
        end;

        case FunctionName of
            WorkflowEventHandling.RunWorkflowOnSendSalesDocForApprovalCode():
                if WorkflowMgt.FindWorkflowStepInstance(Variant, Variant, WorkflowStepInstance, FunctionName) then
                    SendSalesApproval(IsHandled, SalesHeader, FunctionName);
            WorkflowEventHandling.RunWorkflowOnAfterReleaseSalesDocCode():
                begin
                    UpdateApprovalFields(SalesHeader);
                    SendProductionNotificationEmails(SalesHeader, true);
                end;
        end
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRecOnKnownWorkflowInstance', '', false, false)]
    local procedure WorkflowMgtOnBeforeHandleEventWithxRecOnKnownWorkflowInstance(FunctionName: Code[128]; var RecordRef: RecordRef)
    var
        ApprovalEntry: Record "Approval Entry";
        SalesHeader: Record "Sales Header";
        SelectRejectionReason: Page "BA Select Rejection Reason";
        FldRef: FieldRef;
        RejectionCode: Code[20];
    begin
        if (FunctionName <> WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode()) or (RecordRef.Number() <> Database::"Approval Entry") then
            exit;
        RecordRef.SetTable(ApprovalEntry);
        if not SalesHeader.Get(ApprovalEntry."Record ID to Approve") then
            exit;
        Commit();
        if SelectRejectionReason.RunModal() <> Action::OK then
            Error('');
        RejectionCode := SelectRejectionReason.GetReasonCode();
        if RejectionCode = '' then
            Error(NoReasonCodeErr);
        SalesHeader.Validate("BA Appr. Reject. Reason Code", RejectionCode);
        SalesHeader.Modify(true);
        SendProductionNotificationEmails(SalesHeader, false);
    end;





    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeFindMatchingWorkflowStepInstance', '', false, false)]
    local procedure WorkflowMgtOnBeforeFindMatchingWorkflowStepInstance(var RecordRef: RecordRef; var WorkflowStepInstanceLoop: Record "Workflow Step Instance"; FunctionName: Code[128]; StartWorkFlow: Boolean; var IsHandled: Boolean; var Result: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        IF RecordRef.Number <> Database::"Sales Header" then
            exit;
        RecordRef.SetTable(SalesHeader);
        if SalesHeader."BA Use Custom Workflow Start" then begin
            IsHandled := true;
            Result := false;
        end;
    end;


    local procedure UpdateApprovalFields(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."BA Use Custom Workflow Start" then
            exit;
        SalesHeader.CalcFields(Amount);
        SalesHeader.Validate("BA Last Approval Amount", SalesHeader.Amount);
        SalesHeader.Validate("BA Approval Count", SalesHeader."BA Approval Count" + 1);
        SalesHeader.Validate("BA Appr. Reject. Reason Code", '');
        SalesHeader.Modify(true);
    end;

    [TryFunction]
    local procedure TryToGetRecord(var RecRef: RecordRef; Rec: Variant)
    begin
        RecRef.GetTable(Rec);
    end;

    local procedure SendSalesApproval(var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; FunctionName: Code[128])
    var
        Customer: Record Customer;
        ApprovalGroup: Record "BA Approval Group";
    begin
        Customer.Get(SalesHeader."Bill-to Customer No.");
        if Customer."Payment Terms Code" = '' then
            Error(MissingCredLimitErr, Customer."No.");
        if Customer."BA Approval Group" = '' then
            UpdateCustomerApprovalGroup(Customer);
        if not ApprovalGroup.Get(Customer."BA Approval Group") then
            Error(InvalidApprovalGroupErr, Customer."BA Approval Group", Customer."No.");

        SalesHeader.CalcFields(Amount);
        Customer.CalcFields(Balance, "Balance (LCY)");
        case true of
            ApprovalGroup."Is Prepaid":
                SendPrepaidApproval(SalesHeader, SalesHeader."BA Approval Count" = 0);
            ApprovalGroup."Is Government" or ApprovalGroup."Is Military":
                SendGovernmentMilitaryApproval(SalesHeader, Customer);
            else
                SendApprovalOnOverDue(SalesHeader, Customer, ApprovalGroup);
        end;
        IsHandled := true;
    end;

    local procedure SendPrepaidApproval(var SalesHeader: Record "Sales Header"; FirstApproval: Boolean)
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        SalesRecSetup.Get('');
        SalesRecSetup.TestField("BA Prepaid Order Limit");
        if FirstApproval or (SalesHeader.Amount > (SalesHeader."BA Last Approval Amount" + SalesRecSetup."BA Prepaid Order Limit")) then
            SendApprovalRequest(SalesHeader)
        else
            ReleaseSalesDoc(SalesHeader);
    end;

    local procedure SendGovernmentMilitaryApproval(var SalesHeader: Record "Sales Header"; var Customer: Record Customer)
    var
        ApprovalGroup: Record "BA Approval Group";
    begin
        SendApprovalOnCreditLimitExceeded(SalesHeader, Customer, ApprovalGroup, true);
    end;

    local procedure SendApprovalOnOverDue(var SalesHeader: Record "Sales Header"; var Customer: Record Customer; var ApprovalGroup: Record "BA Approval Group")
    begin
        SendApprovalOnCreditLimitExceeded(SalesHeader, Customer, ApprovalGroup, false);
    end;


    local procedure SendApprovalOnCreditLimitExceeded(var SalesHeader: Record "Sales Header"; var Customer: Record Customer; var ApprovalGroup: Record "BA Approval Group"; ByPassLimit: Boolean)
    var
        Balance: Decimal;
        CreditLimit: Decimal;
    begin
        HasZeroCreditLimit(Customer, CreditLimit, Balance);
        if HasZeroCreditLimit(Customer, CreditLimit, Balance) then begin
            if not ByPassLimit then
                Error(CreditLimitErr, Customer."No.");
            ReleaseSalesDoc(SalesHeader);
            exit;
        end;
        if ((SalesHeader.Amount + Balance) < CreditLimit) and (ByPassLimit or CustomerHasNoOverDueInvoices(Customer, ApprovalGroup)) then
            ReleaseSalesDoc(SalesHeader)
        else
            SendApprovalRequest(SalesHeader);
    end;

    local procedure ReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Validate("BA Use Custom Workflow Start", true);
        SalesHeader.Validate("BA Appr. Reject. Reason Code", '');
        SalesHeader.Modify(true);
        ReleaseSalesDocument.PerformManualRelease(SalesHeader);
        SalesHeader.Get(SalesHeader.RecordId());
        SalesHeader.Validate("BA Use Custom Workflow Start", false);
        SalesHeader.Modify(true);
    end;

    local procedure SendApprovalRequest(var SalesHeader: Record "Sales Header")
    begin
        ApprovalMgt.CheckSalesApprovalPossible(SalesHeader);
        SalesHeader.Validate("BA Use Default Workflow", true);
        SalesHeader.Validate("BA Appr. Reject. Reason Code", '');
        SalesHeader.Modify(false);
        ApprovalMgt.OnSendSalesDocForApproval(SalesHeader);
    end;



    local procedure HasZeroCreditLimit(var Customer: Record Customer; var CreditLimit: Decimal; var Balance: Decimal): Boolean
    begin
        if Subscribers.UseLCYCreditLimit(Customer) then begin
            CreditLimit := Customer."Credit Limit (LCY)";
            Balance := Customer."Balance (LCY)";
        end else begin
            CreditLimit := Customer."BA Credit Limit";
            Balance := Customer.Balance;
        end;
        exit(CreditLimit = 0);
    end;


    local procedure CustomerHasNoOverDueInvoices(var Customer: Record Customer; var ApprovalGroup: Record "BA Approval Group"): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OverdueDate: Date;
        DueDateFormulaText: Text;
    begin
        DueDateFormulaText := Format(ApprovalGroup."Overdue Date Formula");
        if DueDateFormulaText = '' then
            exit(false);

        if not DueDateFormulaText.Contains('-') then
            Evaluate(ApprovalGroup."Overdue Date Formula", StrSubstNo('-%1', ApprovalGroup."Overdue Date Formula"));
        OverdueDate := CalcDate(ApprovalGroup."Overdue Date Formula", Today());

        ApprovalGroup.TestField("Overdue Date Formula");
        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetFilter("Due Date", '<%1', OverdueDate);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        exit(CustLedgerEntry.IsEmpty());
    end;






    procedure GetProdApprovalReportUsage(): Integer
    begin
        exit(80001);
    end;

    local procedure SendProductionNotificationEmails(var SalesHeader: Record "Sales Header"; Approved: Boolean)
    var
        UserSetup: Record "User Setup";
        Addresses: List of [Text];
        AddressText: TextBuilder;
        Address: Text;
        Subject: Text;
        AssignedUserID: Code[50];
    begin
        UserSetup.SetRange("BA Receive Prod. Approvals", true);
        UserSetup.SetFilter("E-Mail", '<>%1', '');
        if not Approved then begin
            Subject := StrSubstNo(RejectionEmailSubject, SalesHeader."No.", SalesHeader."Bill-to Customer No.", SalesHeader."Bill-to Name");
            if (SalesHeader."Assigned User ID" <> '') and UserSetup.Get(SalesHeader."Assigned User ID") then begin
                if UserSetup."E-Mail" <> '' then
                    if not TryToSendEmail(SalesHeader, UserSetup."E-Mail", Subject, UserSetup."User ID", Report::"BA Prod. Order Approval") then
                        if not Addresses.Contains(UserSetup."E-Mail") then
                            Addresses.Add(UserSetup."E-Mail");
                UserSetup.SetFilter("User ID", '<>%1', SalesHeader."Assigned User ID");
                SalesHeader."BA Approval Email User ID" := '';
                SalesHeader.Modify(false);
            end;
        end else
            Subject := StrSubstNo(ApprovalEmailSubject, SalesHeader."No.", SalesHeader."Bill-to Customer No.", SalesHeader."Bill-to Name");
        if not UserSetup.FindSet() then
            exit;
        repeat
            if not TryToSendEmail(SalesHeader, UserSetup."E-Mail", Subject, UserSetup."User ID", Report::"BA Prod. Order Approval") then
                if not Addresses.Contains(UserSetup."E-Mail") then
                    Addresses.Add(UserSetup."E-Mail");
        until UserSetup.Next() = 0;
        SalesHeader."BA Approval Email User ID" := '';
        SalesHeader.Modify(false);
        case Addresses.Count() of
            0:
                exit;
            1:
                if Addresses.Get(1, Address) then
                    Message(SingleFailedToSendErr, Address);
            else begin
                    foreach Address in Addresses do
                        AddressText.AppendLine(Address);
                    Message(MultiFailedToSendErr, AddressText.ToText());
                end;
        end;
    end;


    [TryFunction]

    local procedure TryToSendEmail(var SalesHeader: Record "Sales Header"; EmailAddr: Text; Subject: Text; UserIDCode: Code[50]; ReportID: Integer)
    var
        SalesHeader2: Record "Sales Header";
        SMTPSetup: Record "SMTP Mail Setup";
        SMTPMail: Codeunit "SMTP Mail";
        MailMgt: Codeunit "Mail Management";
        FileMgt: Codeunit "File Management";
        BodyFilePath: Text;
        BodyText: Text;
    begin
        SMTPSetup.GetSetup;
        BodyFilePath := FileMgt.ServerTempFileName('html');
        SalesHeader."BA Approval Email User ID" := UserIDCode;
        SalesHeader.Modify(false);
        SalesHeader2.SetRange("Document Type", SalesHeader."Document Type");
        SalesHeader2.SetRange("No.", SalesHeader."No.");
        Report.SaveAsHtml(ReportID, BodyFilePath, SalesHeader2);
        if BodyFilePath <> '' then
            BodyText := FileMgt.GetFileContent(BodyFilePath);
        SMTPMail.CreateMessage('', MailMgt.GetSenderEmailAddress, EmailAddr, Subject, BodyText, true);
        SMTPMail.Send;
    end;




    procedure SendOrderForInvoicing(var SalesHeader: Record "Sales Header")
    var
        UserSetup: Record "User Setup";
    begin
        SalesHeader.TestField(Status, SalesHeader.Status::Released);
        SalesHeader."BA Sent for Invoice Request" := true;
        UserSetup.Get(UserId());
        UserSetup.TestField("Approver ID");
        UserSetup.Get(UserSetup."Approver ID");
        UserSetup.TestField("E-Mail");
        TryToSendEmail(SalesHeader, UserSetup."E-Mail", StrSubstNo(InvRequestSubject, SalesHeader."No.", SalesHeader."Bill-to Customer No.", SalesHeader."Bill-to Name"), UserSetup."User ID", Report::"BA Prod. Order Approval");
        SalesHeader.Get(SalesHeader.RecordId());
        SalesHeader."BA Sent for Invoice Request" := false;
        SalesHeader.Modify(false);
        SalesHeader.Get(SalesHeader.RecordId());
        Message('Sent invoice request to %1', UserSetup."E-Mail");
    end;



    var
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        Subscribers: Codeunit "BA SEI Subscibers";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";


        CreditLimitErr: Label 'Customer %1 has credit terms but no credit limit setup. Please contact the accounting department.';
        MissingCredLimitErr: Label 'Customer %1 must have a Payment Terms assigned before it any related sales documents can be sent for approval.';
        InvalidApprovalGroupErr: Label 'Invalid Approval Group %1 for Customer %2.';
        SingleFailedToSendErr: Label 'Unable to send production order approval email to the following address: %1';
        MultiFailedToSendErr: Label 'Unable to send production order approval email to the following addresses:\%1';
        ApprovalEmailSubject: Label '%1 Has Been Approved - %2 - %3';
        RejectionEmailSubject: Label '%1 Has Been Rejected - %2 - %3';
        InvRequestSubject: Label 'Invoice Request: %1 - %2 - %3';
        NoReasonCodeErr: Label 'Rejection reason must be selected.';
}


