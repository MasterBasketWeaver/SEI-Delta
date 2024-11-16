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
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowMgt: Codeunit "Workflow Management";
        RecRef: RecordRef;
    begin
        if not Confirm(FunctionName) then
            Error('');



        if not TryToGetRecord(RecRef, Variant) then
            exit;
        if RecRef.Number <> Database::"Sales Header" then
            exit;
        RecRef.SetTable(SalesHeader);
        if SalesHeader."BA Use Default Workflow" then begin
            SalesHeader."BA Use Default Workflow" := false;
            exit;
        end;

        if FunctionName = WorkflowEventHandling.RunWorkflowOnSendSalesDocForApprovalCode() then
            if WorkflowMgt.FindWorkflowStepInstance(Variant, Variant, WorkflowStepInstance, FunctionName) then
                SendSalespersonApproval(IsHandled, SalesHeader, FunctionName);


        // case true of
        //     (FunctionName = WorkflowEventHandling.RunWorkflowOnSendSalesDocForApprovalCode()) and (RecRef.Number = Database::"Sales Header"):

        //         // (FunctionName = WorkflowEventHandling.RunWorkflowOnSendPurchaseDocForApprovalCode()) and (RecRef.Number = Database::"Purchase Header"):
        //         //     SendPurchaserApproval(IsHandled, RecRef, Variant, FunctionName);
        // end;
    end;

    [TryFunction]
    local procedure TryToGetRecord(var RecRef: RecordRef; Rec: Variant)
    begin
        RecRef.GetTable(Rec);
    end;

    local procedure SendSalespersonApproval(var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; FunctionName: Code[128])
    var
        Customer: Record Customer;
        ApprovalGroup: Record "BA Approval Group";
        FirstApproval: Boolean;
    begin
        Customer.Get(SalesHeader."Bill-to Customer No.");
        if Customer."BA Approval Group" = '' then
            UpdateCustomerApprovalGroup(Customer);
        if not ApprovalGroup.Get(Customer."BA Approval Group") then
            exit;

        FirstApproval := SalesHeader."BA Approval Count" = 0;
        SalesHeader.Validate("BA Approval Count", SalesHeader."BA Approval Count" + 1);
        SalesHeader.Modify(false);

        SalesHeader.CalcFields(Amount);
        Customer.CalcFields(Balance, "Balance (LCY)");
        case true of
            ApprovalGroup."Is Prepaid":
                SendPrepaidApproval(SalesHeader, FirstApproval);
            ApprovalGroup."Is Government" or ApprovalGroup."Is Military":
                SendGovernmentMilitaryApproval(SalesHeader, Customer);
            else
                SendApprovalOnOverDue(SalesHeader, Customer, ApprovalGroup);
        end;

        SalesHeader.Get(SalesHeader.RecordId());
        SalesHeader.Validate("BA Last Approval Amount", SalesHeader.Amount);
        SalesHeader.Modify(false);
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
            ReleaseSalesDocument.PerformManualRelease(SalesHeader);
    end;

    local procedure SendGovernmentMilitaryApproval(var SalesHeader: Record "Sales Header"; var Customer: Record Customer)
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        CreditLimit: Decimal;
    begin
        if HasZeroCreditLimit(Customer, CreditLimit) then
            ReleaseSalesDocument.PerformManualRelease(SalesHeader)
        else
            if (SalesHeader.Amount + Customer.Balance) <= CreditLimit then
                ReleaseSalesDocument.PerformManualRelease(SalesHeader)
            else
                SendApprovalRequest(SalesHeader);
    end;

    local procedure SendApprovalOnOverDue(var SalesHeader: Record "Sales Header"; var Customer: Record Customer; var ApprovalGroup: Record "BA Approval Group")
    var
        CreditLimit: Decimal;
    begin
        if ApprovalGroup."Is Trusted Agent" then
            if HasZeroCreditLimit(Customer, CreditLimit) then
                Error('Customer %1 has credit terms but no credit limit setup. Please contact the accounting department.', Customer."No.");
        if ((SalesHeader.Amount + Customer.Balance) <= CreditLimit) and CustomerHasNoOverDueInvoices(Customer, ApprovalGroup) then
            ReleaseSalesDocument.PerformManualRelease(SalesHeader)
        else
            SendApprovalRequest(SalesHeader);
    end;

    local procedure SendApprovalRequest(var SalesHeader: Record "Sales Header")
    begin
        ApprovalMgt.CheckSalesApprovalPossible(SalesHeader);
        SalesHeader.Validate("BA Use Default Workflow", true);
        SalesHeader.Modify(false);
        ApprovalMgt.OnSendSalesDocForApproval(SalesHeader);
    end;



    local procedure HasZeroCreditLimit(var Customer: Record Customer; var CreditLimit: Decimal): Boolean
    begin
        if UseLocalAmounts(Customer) then
            CreditLimit := Customer."Credit Limit (LCY)"
        else
            CreditLimit := Customer."BA Credit Limit";
        exit(CreditLimit = 0);
    end;


    local procedure CustomerHasNoOverDueInvoices(var Customer: Record Customer; var ApprovalGroup: Record "BA Approval Group"): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentTerms: Record "Payment Terms";
        OverdueDate: Date;
    begin
        Customer.TestField("Payment Terms Code");
        PaymentTerms.Get(Customer."Payment Terms Code");
        PaymentTerms.TestField("Due Date Calculation");

        OverdueDate := CalcDate(ApprovalGroup."Overdue Date Formulate", Today());

        ApprovalGroup.TestField("Overdue Date Formulate");
        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CustLedgerEntry.SetRange("Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetFilter("Due Date", '<%1', OverdueDate);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        exit(CustLedgerEntry.IsEmpty());
    end;

    procedure UseLocalAmounts(var Customer: Record Customer): Boolean
    var
        CustPostingGroup: Record "Customer Posting Group";
    begin
        if Customer."Customer Posting Group" = '' then
            exit(true);
        exit(CustPostingGroup.Get(Customer."Customer Posting Group") and not CustPostingGroup."BA Show Non-Local Currency");
    end;





    var
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        ReleaseSalesDocument: Codeunit "Release Sales Document";


        // procedure CreateSalespersonApprovalRequest(var SalesHeader: Record "Sales Header"; ApproverUserId: Code[50]; WorkflowID: Guid)
        // begin
        //     if SalesHeader.Status = SalesHeader.Status::Released then
        //         Error(SalesOrderAlreadyReleasedErr, SalesHeader."No.");
        //     if SalesHeader.Status = SalesHeader.Status::"Pending Approval" then
        //         Error(SalesOrderAlreadyPendingApprovalErr, SalesHeader."No.");
        //     CreateSalespersonPurchaseApprovalEntry(Database::"Sales Header", Enum::"Approval Document Type"::Order, SalesHeader."No.", SalesHeader.RecordId(), ApproverUserId, WorkflowID);
        //     SalesHeader.Validate(Status, SalesHeader.Status::"Pending Approval");
        //     SalesHeader.Modify(true);
        // end;

        // procedure CreatePurchaserApprovalRequest(var PurchaseHeader: Record "Purchase Header"; ApproverUserId: Code[50]; WorkflowID: Guid)
        // begin
        //     if PurchaseHeader.Status = PurchaseHeader.Status::Released then
        //         Error(PurchaseInvoiceAlreadyReleasedErr, PurchaseHeader."No.");
        //     if PurchaseHeader.Status = PurchaseHeader.Status::"Pending Approval" then
        //         Error(PurchaseInvoiceAlreadyPendingApprovalErr, PurchaseHeader."No.");
        //     CreateSalespersonPurchaseApprovalEntry(Database::"Purchase Header", Enum::"Approval Document Type"::Invoice, PurchaseHeader."No.", PurchaseHeader.RecordId(), ApproverUserId, WorkflowID);
        //     PurchaseHeader.Validate(Status, PurchaseHeader.Status::"Pending Approval");
        //     PurchaseHeader.Modify(true);
        // end;

        // local procedure CreateSalespersonPurchaseApprovalEntry(TableNo: Integer; DocType: Enum "Approval Document Type"; DocNo: Code[20]; RecId: RecordId; ApproverID: Code[50]; WorkflowID: Guid)
        // var
        //     ApprovalEntry: Record "Approval Entry";
        //     CurrentTime: DateTime;
        //     EntryNo: Integer;
        // begin
        //     if ApprovalEntry.FindLast() then
        //         EntryNo := ApprovalEntry."Entry No.";
        //     CurrentTime := CurrentDateTime();
        //     ApprovalEntry.Init();
        //     ApprovalEntry."Entry No." := EntryNo + 1;
        //     ApprovalEntry.Validate("Table ID", TableNo);
        //     ApprovalEntry.Validate("Document Type", DocType);
        //     ApprovalEntry.Validate("Document No.", DocNo);
        //     ApprovalEntry.Validate("Sender ID", UserId());
        //     ApprovalEntry.Validate("Approver ID", ApproverID);
        //     ApprovalEntry.Validate(Status, ApprovalEntry.Status::Open);
        //     ApprovalEntry.Validate("Date-Time Sent for Approval", CurrentTime);
        //     ApprovalEntry.Validate("Last Date-Time Modified", CurrentTime);
        //     ApprovalEntry.Validate("Last Modified By User ID", UserId());
        //     ApprovalEntry.Validate("Record ID to Approve", RecId);
        //     ApprovalEntry.Validate("Workflow Step Instance ID", WorkflowID);
        //     ApprovalEntry.Validate("TA Sales/Purchase Approval", true);
        //     ApprovalEntry.Insert(true);

        //     CreateNotification(ApprovalEntry);
        // end;
}


