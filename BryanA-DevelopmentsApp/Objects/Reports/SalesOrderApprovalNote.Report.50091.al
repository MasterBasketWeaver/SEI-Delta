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
                Vendor: Record Vendor;
                ApprovalRejection: Record "BA Approval Rejection";
            begin
                if not UsePurchase then
                    exit;

                SourceNo := PurchaseHeader."Buy-from Vendor No.";
                SourceName := PurchaseHeader."Buy-from Vendor Name";
                URLLabel := StrSubstNo(PurchOrderUrlCaption, PurchaseHeader."No.");
                URLText := GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Purchase Order", PurchaseHeader);
                PaymentTermsText := PurchaseHeader."Payment Terms Code";
                ApprovalCount := '';
                LastApprovedAmt := '';

                Username := ProdOrderApproval.GetUserFullName(PurchaseHeader."BA Approval Email User ID");
                RejectReason := StrSubstNo(SentByLbl, ProdOrderApproval.GetUserFullName(UserId()));
                if PurchaseHeader."Currency Code" = '' then begin
                    GLSetup.Get();
                    GLSetup.TestField("LCY Code");
                    CurrencyCode := GLSetup."LCY Code";
                end else
                    CurrencyCode := PurchaseHeader."Currency Code";
                PurchaseHeader.CalcFields("Amount Including VAT");
                AmountText := StrSubstNo(AmountLbl, CurrencyCode, PurchaseHeader."Amount Including VAT");
                Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
                Vendor.CalcFields("Balance (LCY)");
                BalanceText := Format(Vendor."Balance (LCY)");
                CreditLimitText := '';
            end;
        }
        dataitem(SalesHeader; "Sales Header")
        {
            column(No; "No.") { }
            column(Username; Username) { }
            column(CompanyName; CompanyName()) { }
            column(ApprovalAction; ActionLabel) { }
            column(RejectReason; RejectReason) { }
            column(CustomerNo; SourceNo) { }
            column(CustomerName; SourceName) { }
            column(OrderLink_UrlText; URLLabel) { }
            column(OrderLink_Url; URLText) { }
            column(AmountText; AmountText) { }
            column(PaymentTermsCode; PaymentTermsText) { }
            column(ApprovalGroup; ApprovalGroup) { }
            column(Balance; BalanceText) { }
            column(CreditLimit; CreditLimitText) { }
            column(ApprovalCount; ApprovalCount) { }
            column(LastApprovalAmount; LastApprovedAmt) { }


            trigger OnAfterGetRecord()
            var
                Customer: Record Customer;
            begin
                SourceNo := SalesHeader."Sell-to Customer No.";
                SourceName := SalesHeader."Sell-to Customer Name";
                URLLabel := StrSubstNo(SalesOrderUrlCaption, "No.");
                URLText := GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Sales Order", SalesHeader);
                PaymentTermsText := SalesHeader."Payment Terms Code";
                ApprovalCount := Format(SalesHeader."BA Approval Count");
                LastApprovedAmt := Format(SalesHeader."BA Last Approval Amount");

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
                if CreditLimit > 0 then
                    CreditLimitText := Format(CreditLimit)
                else
                    CreditLimitText := '';
                BalanceText := Format(Balance);
            end;
        }
    }


    trigger OnPreReport()
    begin
        UsePurchase := PurchaseHeader.GetFilters() <> '';
    end;


    var
        GLSetup: Record "General Ledger Setup";
        SalesApprovalMgt: Codeunit "BA Sales Approval Mgt.";
        ProdOrderApproval: Report "BA Prod. Order Approval";
        Username: Text;
        RejectReason: Text;
        ApprovalAction: Text;
        AmountText: Text;
        ApprovalGroup: Text;
        SourceNo: Text;
        SourceName: Text;
        URLLabel: Text;
        URLText: Text;
        PaymentTermsText: Text;
        DocNo: Text;
        ApprovalCount: Text;
        LastApprovedAmt: Text;
        CreditLimitText: Text;
        BalanceText: Text;
        CurrencyCode: Code[10];
        CreditLimit: Decimal;
        Balance: Decimal;
        UsePurchase: Boolean;



        SalesOrderUrlCaption: Label 'Sales Order %1';
        PurchOrderUrlCaption: Label 'Purchase Order %1';
        SentByLbl: Label 'Sent by %1';
        AmountLbl: Label 'Amount %1 %2';
        ActionLabel: Label 'requires your approval.';
}