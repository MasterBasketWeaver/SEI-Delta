codeunit 75012 "BA Sales Approval Mgt."
{
    Permissions = tabledata "Sales Invoice Header" = M,
    tabledata "Approval Entry" = M;

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
            Customer."Payment Terms Code" = '': //TBD
                begin
                    ApprovalGroup.SetRange("Is Government", false);
                    ApprovalGroup.SetRange("Is Military", false);
                    ApprovalGroup.SetRange("Is Prepaid", false);
                    ApprovalGroup.SetRange("Is Trusted Agent", false);
                    ApprovalGroup.SetRange("Overdue Date Formula", ApprovalGroup."Overdue Date Formula"); // blank date formula
                    ApprovalGroup.FindFirst();
                    Customer.Validate("BA Approval Group", ApprovalGroup.Code);
                end;
            else
                if PaymentTerms."BA Is Prepaid" then begin //A
                    ApprovalGroup.SetRange("Is Prepaid", true);
                    ApprovalGroup.FindFirst();
                    Customer.Validate("BA Approval Group", ApprovalGroup.Code);
                end else begin //B
                    ApprovalGroup.SetRange("Is Government", false);
                    ApprovalGroup.SetRange("Is Military", false);
                    ApprovalGroup.SetRange("Is Prepaid", false);
                    ApprovalGroup.SetRange("Is Trusted Agent", false);
                    ApprovalGroup.SetFilter("Overdue Date Formula", '<>%1', ApprovalGroup."Overdue Date Formula"); // not blank date formula
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
        if Rec."ENC Military" <> Rec."ENC Military"::" " then begin
            Rec.Validate("BA Government (CDN/US)", true);
            Rec.Modify(true);
            Rec.Get(Rec."No.");
        end;
        UpdateCustomerApprovalGroup(Rec);
    end;







    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRec', '', false, false)]
    local procedure WorkflowMgtOnBeforeHandleEventWithxRec(FunctionName: Code[128]; Variant: Variant; var IsHandled: Boolean)
    var
        RecRef: RecordRef;
    begin
        if TryToGetRecord(RecRef, Variant) then
            case RecRef.Number() of
                Database::"Sales Header":
                    HandleSalesApprovalEvents(RecRef, IsHandled, Variant, FunctionName);
                Database::"Purchase Header":
                    HandlePurchaseApprovalEvent(RecRef, FunctionName);
            end;
    end;

    local procedure HandlePurchaseApprovalEvent(var RecRef: RecordRef; FunctionName: Code[128])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if FunctionName <> WorkflowEventHandling.RunWorkflowOnAfterReleasePurchaseDocCode() then
            exit;
        RecRef.SetTable(PurchaseHeader);
        SendPurchaseApprovalEmail(PurchaseHeader);
    end;

    local procedure HandleSalesApprovalEvents(var RecRef: RecordRef; var IsHandled: Boolean; var RecVariant: Variant; FunctionName: Code[128])
    var
        SalesHeader: Record "Sales Header";
        WorkflowStepInstance: Record "Workflow Step Instance";
        WorkflowMgt: Codeunit "Workflow Management";
    begin
        RecRef.SetTable(SalesHeader);
        if SalesHeader."BA Use Default Workflow" then begin
            SalesHeader."BA Use Default Workflow" := false;
            SalesHeader.Modify(false);
            exit;
        end;

        case FunctionName of
            WorkflowEventHandling.RunWorkflowOnSendSalesDocForApprovalCode():
                if WorkflowMgt.FindWorkflowStepInstance(RecVariant, RecVariant, WorkflowStepInstance, FunctionName) then
                    SendSalesApproval(IsHandled, SalesHeader, FunctionName);
            WorkflowEventHandling.RunWorkflowOnAfterReleaseSalesDocCode():
                begin
                    UpdateApprovalFields(SalesHeader);
                    SendProductionnotificationEmails(SalesHeader, true);
                end;
        end
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeHandleEventWithxRecOnKnownWorkflowInstance', '', false, false)]
    local procedure WorkflowMgtOnBeforeHandleEventWithxRecOnKnownWorkflowInstance(FunctionName: Code[128]; var RecordRef: RecordRef)
    var
        ApprovalEntry: Record "Approval Entry";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
    begin
        if (FunctionName <> WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode()) or (RecordRef.Number() <> Database::"Approval Entry") then
            exit;
        RecordRef.SetTable(ApprovalEntry);
        case true of
            SalesHeader.Get(ApprovalEntry."Record ID to Approve"):
                HandleSalesRejectionEvents(SalesHeader);
            PurchHeader.Get(ApprovalEntry."Record ID to Approve"):
                HandlePurchaseRejectionEvents(PurchHeader);
        end;
    end;

    local procedure HandleSalesRejectionEvents(var SalesHeader: Record "Sales Header")
    var
        RejectionCode: Code[20];
    begin
        RejectionCode := GetRejectionReason();
        SalesHeader.Validate("BA Appr. Reject. Reason Code", RejectionCode);
        SalesHeader.Modify(true);
        RecordRestrictMgt.AllowRecordUsage(SalesHeader);
        SendProductionnotificationEmails(SalesHeader, false);
    end;


    local procedure HandlePurchaseRejectionEvents(var PurchaseHeader: Record "Purchase Header")
    var
        RejectionCode: Code[20];
    begin
        RejectionCode := GetRejectionReason();
        PurchaseHeader.Validate("BA Appr. Reject. Reason Code", RejectionCode);
        PurchaseHeader.Modify(true);
        RecordRestrictMgt.AllowRecordUsage(PurchaseHeader);
        SendPurchasenotificationEmails(PurchaseHeader, false);
    end;


    local procedure GetRejectionReason(): Code[20]
    var
        SelectRejectionReason: Page "BA Select Rejection Reason";
        RejectionCode: Code[20];
    begin
        Commit();
        if SelectRejectionReason.RunModal() <> Action::OK then
            error('');
        RejectionCode := SelectRejectionReason.GetReasonCode();
        if RejectionCode = '' then
            error(NoReasonCodeErr);
        exit(RejectionCode);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnBeforeFindMatchingWorkflowStepInstance', '', false, false)]
    local procedure WorkflowMgtOnBeforeFindMatchingWorkflowStepInstance(var RecordRef: RecordRef; var WorkflowStepInstanceLoop: Record "Workflow Step Instance"; FunctionName: Code[128]; StartWorkFlow: Boolean; var IsHandled: Boolean; var Result: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        if RecordRef.Number <> Database::"Sales Header" then
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
        Customer.Get(SalesHeader."Sell-to Customer No.");
        if Customer."Payment Terms Code" = '' then
            error(MissingCredLimitErr, Customer."No.");
        if Customer."BA Approval Group" = '' then
            UpdateCustomerApprovalGroup(Customer);
        if not ApprovalGroup.Get(Customer."BA Approval Group") then
            error(InvalidApprovalGroupErr, Customer."BA Approval Group", Customer."No.");

        SalesHeader.CalcFields(Amount);
        Customer.CalcFields(Balance, "Balance (LCY)");
        case true of
            ApprovalGroup."Is Prepaid":
                SendPrepaidApproval(SalesHeader, SalesHeader."BA Approval Count" = 0);
            ApprovalGroup."Is Government" or ApprovalGroup."Is Military":
                SendGovernmentMilitaryApproval(SalesHeader, Customer);
            else
                if Format(ApprovalGroup."Overdue Date Formula") <> '' then
                    SendApprovalOnOverDue(SalesHeader, Customer, ApprovalGroup)
                else
                    error(InvalidAppGroupErr, Customer."No.", ApprovalGroup.Code);
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
                error(CreditLimitErr, Customer."No.");
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
        ApprovalMgt.OnSendSalesDocForApproval(SalesHeader); //calls notificationEntryDispatcherOnBeforeGetHTMLBodyText() during processing
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"notification Entry Dispatcher", 'OnBeforeGetHTMLBodyText', '', false, false)]
    local procedure notificationEntryDispatcherOnBeforeGetHTMLBodyText(var IsHandled: Boolean; var Result: Boolean; var notificationEntry: Record "notification Entry"; var BodyTextOut: Text)
    var
        ApprovalEntry: Record "Approval Entry";
        SalesHeader: Record "Sales Header";
        UserSetup: Record "User Setup";
        notificationMgt: Codeunit "notification Management";
        EmailBody: Text;
        Subject: Text;
        ReportID: Integer;
    begin
        if not ApprovalEntry.Get(notificationEntry."Triggered By Record") or (notificationEntry."Recipient User ID" = '') then
            exit;
        if not SalesHeader.Get(ApprovalEntry."Record ID to Approve") then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        if (SalesHeader."Assigned User ID" = notificationEntry."Recipient User ID") and (ApprovalEntry.Status = ApprovalEntry.Status::Rejected) then begin
            if not UserSetup.Get(SalesHeader."Assigned User ID") or (UserSetup."E-Mail" = '') then
                exit;
            Subject := StrSubstNo(RejectionEmailSubject, SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name");
            ReportID := Report::"BA Prod. Order Approval";
        end else begin
            UserSetup.SetRange("User ID", notificationEntry."Recipient User ID");
            UserSetup.SetRange("Approval Administrator", true);
            UserSetup.SetFilter("E-Mail", '<>%1', '');
            if not UserSetup.FindFirst() then
                exit;
            Subject := StrSubstNo(ApprovalRequestSubject, SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name");
            ReportID := Report::"BA Sales Order Approval note.";
        end;

        if not TryToSendEmail(SalesHeader, UserSetup."E-Mail", Subject, '', ReportID, EmailBody) then begin
            notificationEntry.SeterrorMessage(GetLasterrorText());
            ClearLasterror();
            notificationEntry.Modify(true);
        end else
            notificationMgt.MovenotificationEntryToSentnotificationEntries(notificationEntry, EmailBody, true, 0);
        IsHandled := true;
        Result := false;
    end;







    procedure HasZeroCreditLimit(var Customer: Record Customer; var CreditLimit: Decimal; var Balance: Decimal): Boolean
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

    local procedure SendProductionnotificationEmails(var SalesHeader: Record "Sales Header"; Approved: Boolean)
    var
        UserSetup: Record "User Setup";
        Addresses: List of [Text];
        AddressText: TextBuilder;
        Address: Text;
        Subject: Text;
        AssignedUserID: Code[50];
    begin
        if not Approved then
            if SalesHeader."Assigned User ID" <> '' then
                UserSetup.SetFilter("User ID", '<>%1', SalesHeader."Assigned User ID");
        UserSetup.SetRange("BA Receive Prod. Approvals", true);
        UserSetup.SetFilter("E-Mail", '<>%1', '');
        if not UserSetup.FindSet() then
            exit;
        if not Approved then
            Subject := StrSubstNo(RejectionEmailSubject, SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name")
        else
            Subject := StrSubstNo(ApprovalEmailSubject, SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name");
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
                    Message(MultifailedToSendErr, AddressText.ToText());
                end;
        end;
    end;

    local procedure SendPurchasenotificationEmails(var PurchaseHeader: Record "Purchase Header"; Approved: Boolean)
    var
        UserSetup: Record "User Setup";
        Addresses: List of [Text];
        AddressText: TextBuilder;
        Address: Text;
        Subject: Text;
        EmailBody: Text;
        AssignedUserID: Code[50];
    begin
        if not Approved then
            if PurchaseHeader."Assigned User ID" <> '' then
                UserSetup.SetFilter("User ID", '<>%1', PurchaseHeader."Assigned User ID");
        UserSetup.SetRange("BA Receive Prod. Approvals", true);
        UserSetup.SetFilter("E-Mail", '<>%1', '');
        if not UserSetup.FindSet() then
            exit;
        if not Approved then
            Subject := StrSubstNo(RejectionEmailSubject, PurchaseHeader."No.", PurchaseHeader."Sell-to Customer No.", PurchaseHeader."Buy-from Vendor Name")
        else
            Subject := StrSubstNo(ApprovalEmailSubject, PurchaseHeader."No.", PurchaseHeader."Sell-to Customer No.", PurchaseHeader."Buy-from Vendor Name");
        repeat
            if not TryToSendEmail(PurchaseHeader, UserSetup."E-Mail", Subject, UserSetup."User ID", Report::"BA Prod. Order Approval", EmailBody) then
                if not Addresses.Contains(UserSetup."E-Mail") then
                    Addresses.Add(UserSetup."E-Mail");
        until UserSetup.Next() = 0;
        PurchaseHeader."BA Approval Email User ID" := '';
        PurchaseHeader.Modify(false);
        case Addresses.Count() of
            0:
                exit;
            1:
                if Addresses.Get(1, Address) then
                    Message(SingleFailedToSendErr, Address);
            else begin
                    foreach Address in Addresses do
                        AddressText.AppendLine(Address);
                    Message(MultifailedToSendErr, AddressText.ToText());
                end;
        end;
    end;


    [TryFunction]
    local procedure TryToSendEmail(var SalesHeader: Record "Sales Header"; EmailAddr: Text; Subject: Text; ReportID: Integer)
    var
        EmailBody: Text;
    begin
        TryToSendEmail(SalesHeader, EmailAddr, Subject, '', ReportID, EmailBody);
    end;

    [TryFunction]
    local procedure TryToSendEmail(var SalesHeader: Record "Sales Header"; EmailAddr: Text; Subject: Text; UserIDCode: Code[50]; ReportID: Integer)
    var
        EmailBody: Text;
    begin
        TryToSendEmail(SalesHeader, EmailAddr, Subject, UserIDCode, ReportID, EmailBody);
    end;


    [TryFunction]
    local procedure TryToSendEmail(var SalesHeader: Record "Sales Header"; EmailAddr: Text; Subject: Text; UserIDCode: Code[50]; ReportID: Integer; var EmailBody: Text)
    var
        SalesHeader2: Record "Sales Header";
        RecVar: Variant;
    begin
        if UserIDCode <> '' then begin
            SalesHeader."BA Approval Email User ID" := UserIDCode;
            SalesHeader.Modify(false);
        end;
        SalesHeader2.SetRange("Document Type", SalesHeader."Document Type");
        SalesHeader2.SetRange("No.", SalesHeader."No.");
        RecVar := SalesHeader2;

        SendEmail(EmailAddr, Subject, ReportID, EmailBody, RecVar);
    end;

    [TryFunction]
    local procedure TryToSendEmail(var PurchaseHeader: Record "Purchase Header"; EmailAddr: Text; Subject: Text; UserIDCode: Code[50]; ReportID: Integer; var EmailBody: Text)
    var
        PurchaseHeader2: Record "Purchase Header";
        RecVar: Variant;
    begin
        if UserIDCode <> '' then begin
            PurchaseHeader."BA Approval Email User ID" := UserIDCode;
            PurchaseHeader.Modify(false);
        end;
        TryToSendEmail(PurchaseHeader, EmailAddr, Subject, ReportID, EmailBody);
    end;


    [TryFunction]
    local procedure TryToSendEmail(var PurchaseHeader: Record "Purchase Header"; EmailAddr: Text; Subject: Text; ReportID: Integer; var EmailBody: Text)
    var
        PurchaseHeader2: Record "Purchase Header";
        RecVar: Variant;
    begin
        PurchaseHeader2.SetRange("No.", PurchaseHeader."No.");
        PurchaseHeader2.SetRange("Document Type", PurchaseHeader."Document Type");
        RecVar := PurchaseHeader2;
        SendEmail(EmailAddr, Subject, ReportID, EmailBody, RecVar);
    end;

    local procedure SendEmail(EmailAddr: Text; Subject: Text; ReportID: Integer; var EmailBody: Text; var RecVar: Variant)
    var
        SMTPMail: Codeunit "SMTP Mail";
        Window: Dialog;
    begin
        Window.Open(SendingMsg);
        EmailBody := GetBodyHTMLText(RecVar, ReportID);
        SMTPMail.CreateMessage('', GetSenderEmail(), EmailAddr, Subject, EmailBody, true);
        SMTPMail.Send;
        Window.Close();
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
        TryToSendEmail(SalesHeader, UserSetup."E-Mail", StrSubstNo(InvRequestSubject, SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name"), UserSetup."User ID", Report::"BA Prod. Order Approval");
        SalesHeader.Get(SalesHeader.RecordId());
        SalesHeader."BA Sent for Invoice Request" := false;
        SalesHeader.Modify(false);
        SalesHeader.Get(SalesHeader.RecordId());
        Message(SentInvoiceMsg, UserSetup."E-Mail");
    end;




    procedure SendShipmentAndInvoice(var SalesInvHeader: Record "Sales Invoice Header")
    var
        SalesInvHeader2: Record "Sales Invoice Header";
        SalesShptHeader: Record "Sales Shipment Header";
        Window: Dialog;
        RecVar: Variant;
        FileNames: Dictionary of [Text, Text];
        Emails: List of [Text];
        EmailsCC: List of [Text];
        SinglePackSlip: Boolean;
    begin
        SalesInvHeader.TestField("Order No.");
        SalesShptHeader.SetRange("Order No.", SalesInvHeader."Order No.");
        if not SalesShptHeader.FindSet() then
            error(NoRelatedPackingSlipsErr, SalesInvHeader."No.", SalesInvHeader."Order No.");
        SinglePackSlip := SalesShptHeader.Count() = 1;
        if SinglePackSlip then
            Window.Open(SendingInvPackingSlipSingleTitle)
        else
            Window.Open(SendingInvPackingSlipMultiTitle);
        PopulateAttachments(SalesInvHeader, SalesInvHeader2, SalesShptHeader, FileNames);
        PopulateEmailAddresses(SalesInvHeader, Emails, EmailsCC);

        RecVar := SalesInvHeader2;
        SendInvoiceShipmentEmail(FileNames, Emails, EmailsCC, GetBodyHTMLText(RecVar, Report::"BA Invoice/Shpt Email Body"), StrSubstNo(InvPackSlipSubject, SalesInvHeader."Order No.", SalesInvHeader."Sell-to Customer No.", SalesInvHeader."Sell-to Customer Name"));
        Window.Close();
        if SinglePackSlip then
            Message(SentSingleInvoiceMsg)
        else
            Message(SentMultiInvoiceMsg);
    end;


    local procedure GetBodyHTMLText(var RecVar: Variant; ReportID: Integer): Text
    var
        BodyFilePath: Text;
        BodyText: Text;
    begin
        BodyFilePath := FileMgt.ServerTempFileName('html');
        if not Report.SaveAsHtml(ReportID, BodyFilePath, RecVar) then
            error(NoEmailBodyErr, GetLasterrorText());
        BodyText := FileMgt.GetFileContent(BodyFilePath);
        exit(BodyText);
    end;


    local procedure PopulateAttachments(var SalesInvHeader: Record "Sales Invoice Header"; var SalesInvHeader2: Record "Sales Invoice Header"; var SalesShptHeader: Record "Sales Shipment Header"; var FileNames: Dictionary of [Text, Text])
    var
        SalesShptHeader2: Record "Sales Shipment Header";
        ReportSelections: Record "Report Selections";
        FileName: Text;
        i: Integer;
    begin
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        ReportSelections.FindFirst();
        FileName := FileMgt.ServerTempFileName('pdf');
        SalesInvHeader2.SetRange("No.", SalesInvHeader."No.");
        Report.SaveAsPdf(ReportSelections."Report ID", FileName, SalesInvHeader2);
        SalesInvHeader.Get(SalesInvHeader."No.");
        FileNames.Add(StrSubstNo(InvoiceFileName, SalesInvHeader."No.", SalesInvHeader."Order No.", SalesInvHeader."Sell-to Customer No."), FileName);

        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Shipment");
        ReportSelections.FindFirst();
        repeat
            FileName := FileMgt.ServerTempFileName('pdf');
            SalesShptHeader2.SetRange("No.", SalesShptHeader."No.");
            Report.SaveAsPdf(ReportSelections."Report ID", FileName, SalesShptHeader2);
            i += 1;
            if i = 1 then
                FileNames.Add(StrSubstNo(SingleShptFilename, SalesInvHeader."No.", SalesInvHeader."Order No.", SalesInvHeader."Sell-to Customer No."), FileName)
            else
                FileNames.Add(StrSubstNo(MultiShptFileName, SalesInvHeader."No.", SalesInvHeader."Order No.", SalesInvHeader."Sell-to Customer No.", i), FileName);
        until SalesShptHeader.Next() = 0;
    end;

    local procedure PopulateEmailAddresses(var SalesInvHeader: Record "Sales Invoice Header"; var Emails: List of [Text]; var EmailsCC: List of [Text])
    var
        UserSetup: Record "User Setup";
        Salesperson: Record "Salesperson/Purchaser";
        ProdOrderApproval: Report "BA Prod. Order Approval";
        Usernames: List of [Text];
    begin
        UserSetup.SetRange("BA Receive Prod. Approvals", true);
        UserSetup.SetFilter("E-Mail", '<>%1', '');
        if not UserSetup.FindSet() then
            error(NoProdStaffAssignedErr);
        repeat
            if not Emails.Contains(UserSetup."E-Mail") then begin
                Emails.Add(UserSetup."E-Mail");
                Usernames.Add(ProdOrderApproval.GetUserFullName(UserSetup."User ID"));
            end;
        until UserSetup.Next() = 0;
        if UserSetup.Get(SalesInvHeader."ENC Assigned User ID") and (UserSetup."E-Mail" <> '') then
            if not EmailsCC.Contains(UserSetup."E-Mail") then
                EmailsCC.Add(UserSetup."E-Mail");
        if (SalesInvHeader."Salesperson Code" <> '') and (Salesperson.Get(SalesInvHeader."Salesperson Code")) then
            if (Salesperson."E-Mail" <> '') and not EmailsCC.Contains(Salesperson."E-Mail") then
                EmailsCC.Add(Salesperson."E-Mail");
        SetEmailUsernames(SalesInvHeader, Usernames);
    end;

    local procedure SetEmailUsernames(var SalesInvHeader: Record "Sales Invoice Header"; var Usernames: List of [Text])
    var
        Username: Text;
        LastUsername: Text;
        FieldLength: Integer;
    begin
        FieldLength := MaxStrLen(SalesInvHeader."BA Invoice/Packing Slip Users");
        case Usernames.Count() of
            1:
                Usernames.Get(1, SalesInvHeader."BA Invoice/Packing Slip Users");
            2:
                begin
                    Usernames.Get(1, SalesInvHeader."BA Invoice/Packing Slip Users");
                    Usernames.Get(2, Username);
                    SalesInvHeader."BA Invoice/Packing Slip Users" := CopyStr(StrSubstNo(DoubleTok, SalesInvHeader."BA Invoice/Packing Slip Users", Username), 1, FieldLength);
                end;
            else begin
                    Usernames.Get(1, SalesInvHeader."BA Invoice/Packing Slip Users");
                    Usernames.Get(Usernames.Count(), LastUsername);
                    Usernames.RemoveAt(Usernames.Count());
                    Usernames.RemoveAt(1);
                    foreach Username in Usernames do
                        SalesInvHeader."BA Invoice/Packing Slip Users" := CopyStr(StrSubstNo(MultiTok, SalesInvHeader."BA Invoice/Packing Slip Users", Username), 1, FieldLength);
                    SalesInvHeader."BA Invoice/Packing Slip Users" := CopyStr(StrSubstNo(LastTok, SalesInvHeader."BA Invoice/Packing Slip Users", LastUsername), 1, FieldLength);
                end;
        end;
        SalesInvHeader.Modify(false);
    end;


    local procedure SendInvoiceShipmentEmail(var FileNames: Dictionary of [Text, Text]; var Emails: List of [Text]; var EmailsCC: List of [Text]; BodyText: Text; Subject: Text)
    var
        SMTPMail: Codeunit "SMTP Mail";
        FilePath: Text;
        FileName: Text;
        Addresses: Text;
        CCAddresses: Text;
    begin
        Addresses := GetEmailsAsText(Emails);
        CCAddresses := GetEmailsAsText(EmailsCC);
        SMTPMail.CreateMessage('', GetSenderEmail(), Addresses, Subject, BodyText, true);
        if CCAddresses <> '' then
            SMTPMail.AddCC(CCAddresses);
        foreach FileName in FileNames.Keys() do begin
            FileNames.Get(FileName, FilePath);
            SMTPMail.AddAttachment(FilePath, FileName);
        end;
        if not SMTPMail.TrySend() then
            error(FailedToSendInvoicePackingSlipErr, SMTPMail.GetLastSendMailerrorText());
    end;

    local procedure GetEmailsAsText(var Emails: List of [Text]): Text
    var
        EmailText: Text;
        Email: Text;
    begin
        Emails.Get(1, EmailText);
        Emails.RemoveAt(1);
        foreach Email in Emails do
            EmailText += ';' + Email;
        exit(EmailText);
    end;

    local procedure GetSenderEmail(): Text;
    var
        MailMgt: Codeunit "Mail Management";
    begin
        if SenderEmail = '' then
            SenderEmail := MailMgt.GetSenderEmailAddress();
        exit(SenderEmail);
    end;








    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCreateApprovalEntrynotification', '', false, false)]
    local procedure ApprovalMgtOnBeforeCreateApprovalEntrynotification(var ApprovalEntry: Record "Approval Entry")
    var
        UserSetup: Record "User Setup";
    begin
        if (ApprovalEntry."Table ID" <> Database::"Purchase Header") or (ApprovalEntry.Status <> ApprovalEntry.Status::Open) then
            exit;
        UserSetup.SetRange("User ID", ApprovalEntry."Approver ID");
        UserSetup.SetRange("Approval Administrator", true);
        if UserSetup.IsEmpty() then
            exit;
        UserSetup.Reset();
        UserSetup.SetRange("BA Purch. Approval Admin", true);
        if not UserSetup.FindFirst() then
            error(NoPurchApprovalAdminErr);
        ApprovalEntry."Approver ID" := UserSetup."User ID";
        ApprovalEntry.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Entry Dispatcher", 'OnBeforeCreateMailAndDispatch', '', false, false)]
    local procedure NotificationEntryDispatcherOnBeforeCreateMailAndDispatch(var NotificationEntry: Record "Notification Entry"; var MailSubject: Text)
    var
        ApprovalEntry: Record "Approval Entry";
        PurchaseHeader: Record "Purchase Header";
    begin
        if not ApprovalEntry.Get(notificationEntry."Triggered By Record") or (notificationEntry."Recipient User ID" = '') then
            exit;
        if PurchaseHeader.Get(ApprovalEntry."Record ID to Approve") then
            case ApprovalEntry.Status of
                ApprovalEntry.Status::Open, ApprovalEntry.Status::Created:
                    MailSubject := StrSubstNo(PurchRequireApprovalSubject, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor Name");
                ApprovalEntry.Status::Approved:
                    MailSubject := StrSubstNo(PurchApprovedSubject, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor Name");
                ApprovalEntry.Status::Rejected:
                    MailSubject := StrSubstNo(PurchRejectedSubject, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor Name");
            end
    end;

    local procedure SendPurchaseApprovalEmail(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        UserSetup: Record "User Setup";
        notificationEntry: Record "notification Entry";
        notificationMgt: Codeunit "notification Management";
        EmailBody: Text;
        Subject: Text;
        URL: Text;
        ReportID: Integer;
        notificationID: Integer;
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit(false);
        if not UserSetup.Get(PurchaseHeader."Assigned User ID") or (UserSetup."E-Mail" = '') then
            exit(false);
        if notificationEntry.FindLast() then
            notificationID := notificationEntry.ID;
        Clear(notificationEntry);
        notificationEntry.ID := notificationID + 1;
        notificationEntry.Type := notificationEntry.Type::Approval;
        notificationEntry."Recipient User ID" := UserSetup."User ID";
        notificationEntry."Triggered By Record" := PurchaseHeader.RecordId();
        notificationEntry."Link TarGet Page" := Page::"Purchase Order";
        notificationEntry."Custom Link" := GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Purchase Order", PurchaseHeader);
        notificationEntry."Sender User ID" := UserId();
        notificationEntry.Insert(true);

        Subject := StrSubstNo(ApprovalEmailSubject, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor Name");
        ReportID := Report::"BA Prod. Order Approval";
        if not TryToSendEmail(PurchaseHeader, UserSetup."E-Mail", Subject, ReportID, EmailBody) then begin
            notificationEntry.SeterrorMessage(GetLasterrorText());
            ClearLasterror();
            notificationEntry.Modify(true);
        end else
            notificationMgt.MovenotificationEntryToSentnotificationEntries(notificationEntry, EmailBody, true, 0);
        exit(true);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCheckUserAsApprovalAdministrator', '', false, false)]
    local procedure ApprovalMgtOnBeforeCheckUserAsApprovalAdministrator(ApprovalEntry: Record "Approval Entry"; var IsHandled: Boolean)
    var
        UserSetup: Record "User Setup";
    begin
        if (ApprovalEntry."Table ID" <> Database::"Purchase Header") then
            exit;
        IsHandled := true;
        UserSetup.Get(UserId());
        UserSetup.TestField("BA Purch. Approval Admin");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeSubstituteUserIdForApprovalEntry', '', false, false)]
    local procedure ApprovalMgtOnBeforeSubstituteUserIdForApprovalEntry(ApprovalEntry: Record "Approval Entry"; var IsHandled: Boolean)
    var
        UserSetup: Record "User Setup";
        ApprovalAdminUserSetup: Record "User Setup";
        Substitute: Code[50];
    begin
        if (ApprovalEntry."Table ID" <> Database::"Purchase Header") then
            exit;
        IsHandled := true;
        if not UserSetup.Get(ApprovalEntry."Approver ID") then
            error(ApproverUserIdnotInSetupErr, ApprovalEntry."Sender ID");

        Substitute := '';
        ApprovalMgt.OnSubstituteUserIdForApprovalEntry(ApprovalEntry, Substitute);
        if Substitute <> '' then begin
            ApprovalEntry."Approver ID" := Substitute;
            ApprovalEntry.Modify(true);
            ApprovalMgt.OnDelegateApprovalRequest(ApprovalEntry);
            exit;
        end;

        if UserSetup.Substitute = '' then
            if UserSetup."BA Purch. Approver ID" = '' then begin
                ApprovalAdminUserSetup.SetRange("Approval Administrator", true);
                if ApprovalAdminUserSetup.FINDFIRST then
                    UserSetup.Get(ApprovalAdminUserSetup."User ID")
                else
                    error(SubstitutenotFoundErr, UserSetup."User ID");
            end else
                UserSetup.Get(UserSetup."BA Purch. Approver ID")
        else
            UserSetup.Get(UserSetup.Substitute);

        ApprovalEntry."Approver ID" := UserSetup."User ID";
        ApprovalEntry.Modify(true);
        ApprovalMgt.OnDelegateApprovalRequest(ApprovalEntry);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeIsSufficientPurchApprover', '', false, false)]
    local procedure ApprovalMgtOnBeforeIsSufficientPurchApprover(UserSetup: Record "User Setup"; var IsHandled: Boolean; var IsSufficient: Boolean)
    begin
        if UserSetup."BA Purch. Approval Admin" or (UserSetup."User ID" = UserSetup."BA Purch. Approver ID") or UserSetup."Unlimited Purchase Approval" then begin
            IsHandled := true;
            IsSufficient := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnCreateApprovalRequestForApproverChainOnBeforeCheckApproverId', '', false, false)]
    local procedure ApprovalMgtOnCreateApprovalRequestForApproverChainOnBeforeCheckApproverId(var UserSetup: Record "User Setup"; ApprovalEntry: Record "Approval Entry")
    begin
        if ApprovalEntry."Table ID" = Database::"Purchase Header" then
            UserSetup."Approver ID" := UserSetup."BA Purch. Approver ID";
    end;


    var
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        Subscribers: Codeunit "BA SEI Subscibers";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        FileMgt: Codeunit "File Management";
        RecordRestrictMgt: Codeunit "Record Restriction Mgt.";
        SenderEmail: Text;



        CreditLimitErr: Label 'Customer %1 has credit terms but no credit limit setup. Please contact the accounting department.';
        MissingCredLimitErr: Label 'Customer %1 must have a Payment Terms assigned before it any related sales documents can be sent for approval.';
        InvalidApprovalGroupErr: Label 'Invalid Approval Group %1 for Customer %2.';
        SingleFailedToSendErr: Label 'Unable to send production order approval email to the following address: %1';
        MultifailedToSendErr: Label 'Unable to send production order approval email to the following addresses:\%1';
        ApprovalEmailSubject: Label '%1 Has Been Approved - %2 - %3';
        RejectionEmailSubject: Label '%1 Has Been Rejected - %2 - %3';
        InvRequestSubject: Label 'Invoice Request: %1 - %2 - %3';
        InvPackSlipSubject: Label '%1 Has Been Invoiced - %2 - %3';
        NoReasonCodeErr: Label 'Rejection reason must be selected.';
        SentInvoiceMsg: Label 'Invoice request sent to %1';
        SentSingleInvoiceMsg: Label 'Sent invoice and related packing slip email.';
        SentMultiInvoiceMsg: Label 'Sent invoice and related packing slips email.';
        SendingInvPackingSlipSingleTitle: Label 'Sending invoice and packing slip...';
        SendingInvPackingSlipMultiTitle: Label 'Sending invoice and packing slips...';
        NoRelatedPackingSlipsErr: Label 'Unable to send invoice email due to no related packing slips found for Invoice %1, Order No. %2.';
        NoEmailBodyErr: Label 'Unable to create email body:%1';
        InvoiceFileName: Label '%1-%2-%3-Sales Invoice.pdf';
        SingleShptFilename: Label '%1-%2-%3-Packing Slip.pdf';
        MultiShptFileName: Label '%1-%2-%3-Packing Slip (%4).pdf';
        FailedToSendInvoicePackingSlipErr: Label 'Unable to send invoice & packing slip email due to the following error:\%1';
        NoProdStaffAssignedErr: Label 'No production control staff have been assigned.';
        DoubleTok: Label '%1 and %2';
        MultiTok: Label '%1, %2';
        LastTok: Label '%1, and %2';
        InvalidAppGroupErr: Label 'Cannot send an approval request for Customer %1 as it has not been assigned a valid approval group: %2.';
        ApprovalRequestSubject: Label 'Order Approval Request %1 - %2 - %3';
        NoPurchApprovalAdminErr: Label 'Purchaser Approval Admin must be configured before Purchase documents can be sent for approval.';
        SubstitutenotFoundErr: Label 'There is no substitute, direct approver, or approval administrator for user ID %1 in the Approval User Setup window.';
        ApproverUserIdnotInSetupErr: Label 'You must set up an approver for user ID %1 in the Approval User Setup window.';
        PurchRequireApprovalSubject: Label 'PO %1 - %2 - Requires Approval';
        PurchApprovedSubject: Label 'PO %1 - %2 - Approved';
        PurchRejectedSubject: Label 'PO %1 - %2 - Rejected';
        SendingMsg: Label 'Sending Email...';


}


