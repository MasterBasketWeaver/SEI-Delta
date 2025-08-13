report 50091 "BA Approved Notification"
{
    Caption = 'Sales/Purch. Order Approval Notification';
    UseRequestPage = false;
    WordLayout = './Objects/ReportLayouts/ApprovedNotification.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            trigger OnAfterGetRecord()
            var
                ApprovalRejection: Record "BA Approval Rejection";
            begin
                if not UsePurchase then
                    exit;
                PageURL := GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Purchase Order", PurchaseHeader);
                URLCaption := StrSubstNo(PurchUrlLbl, PurchaseHeader."No.");
                Username := GetUserFullName(PurchaseHeader."Assigned User ID");
                DocNo := PurchaseHeader."No.";
                DocType := 'Purchase';
                SourceType := 'Vendor';
                SourceNo := PurchaseHeader."Buy-from Vendor No.";
                SourceName := PurchaseHeader."Buy-from Vendor Name";
                if PurchaseHeader."BA Appr. Reject. Reason Code" <> '' then begin
                    ApprovalAction := RejectedLbl;
                    ApprovalRejection.Get(PurchaseHeader."BA Appr. Reject. Reason Code");
                    if ApprovalRejection.Description <> '' then
                        RejectReason := ApprovalRejection.Description
                    else
                        RejectReason := ApprovalRejection.Code;
                    RejectReason := StrSubstNo('Rejection Reason: %1', RejectReason);
                end else
                    ApprovalAction := ApprovedLbl;
            end;
        }
        dataitem(SalesHeader; "Sales Header")
        {
            column(No; "No.") { }
            column(Username; Username) { }
            column(CompanyName; CompanyName()) { }
            column(ApprovalAction; 'requires your approval.') { }
            column(RejectReason; RejectReason) { }
            column(CustomerNo; "Sell-to Customer No.") { }
            column(CustomerName; "Sell-to Customer Name") { }
            column(OrderLink_UrlText; StrSubstNo(UrlLbl, "No.")) { }
            column(OrderLink_Url; GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Sales Order", SalesHeader)) { }
            column(AmountText; AmountText) { }
            column(PaymentTermsCode; "Payment Terms Code") { }
            column(ApprovalGroup; ApprovalGroup) { }
            column(Balance; Balance) { }
            column(CreditLimit; CreditLimit) { }
            column(ApprovalCount; "BA Approval Count") { }
            column(LastApprovalAmount; "BA Last Approval Amount") { }


            trigger OnAfterGetRecord()
            var
                Customer: Record Customer;
                GLSetup: Record "General Ledger Setup";
                CurrencyCode: Code[10];
            begin
                Username := ProdOrderApproval.GetUserFullName(SalesHeader."BA Approval Email User ID");
                RejectReason := StrSubstNo(SentByLbl, ProdOrderApproval.GetUserFullName(UserId()));
                if SalesHeader."Currency Code" = '' then begin
                    GLSetup.Get();
                    GLSetup.TestField("LCY Code");
                    CurrencyCode := GLSetup."LCY Code";
                end else
                    CurrencyCode := SalesHeader."Currency Code";
                SalesHeader.CalcFields("Amount Including VAT");
                AmountText := StrSubstNo(AmountLbl, CurrencyCode, SalesHeader."Amount Including VAT");
                Customer.Get("Bill-to Customer No.");
                Customer.CalcFields(Balance, "Balance (LCY)");
                ApprovalGroup := Customer."BA Approval Group";
                SalesApprovalMgt.HasZeroCreditLimit(Customer, CreditLimit, Balance);
            end;
        }
    }



    var
        SalesApprovalMgt: Codeunit "BA Sales Approval Mgt.";
        ProdOrderApproval: Report "BA Prod. Order Approval";
        Username: Text;
        RejectReason: Text;
        ApprovalAction: Text;
        AmountText: Text;
        ApprovalGroup: Text;
        CreditLimit: Decimal;
        Balance: Decimal;


        UrlLbl: Label 'Sales Order %1';
        SentByLbl: Label 'Sent by %1';
        AmountLbl: Label 'Amount %1 %2';
}