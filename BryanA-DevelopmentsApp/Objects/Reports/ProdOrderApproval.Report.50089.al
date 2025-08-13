report 50089 "BA Prod. Order Approval"
{
    Caption = 'Prod. Order Approval';
    UseRequestPage = false;
    WordLayout = './Objects/ReportLayouts/ProdOrderApproval.docx';
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
            column(No; DocNo) { }
            column(DocType; DocType) { }
            column(Username; Username) { }
            column(CompanyName; CompanyName()) { }
            column(ApprovalAction; ApprovalAction) { }
            column(RejectReason; RejectReason) { }
            column(SourceType; SourceType) { }
            column(CustomerNo; SourceNo) { }
            column(CustomerName; SourceName) { }
            column(OrderLink_UrlText; URLCaption) { }
            column(OrderLink_Url; PageURL) { }
            column(AmountText; AmountText) { }


            trigger OnAfterGetRecord()
            var
                ApprovalRejection: Record "BA Approval Rejection";
                GLSetup: Record "General Ledger Setup";
                CurrencyCode: Code[10];
            begin
                if UsePurchase then
                    exit;
                PageURL := GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Sales Order", SalesHeader);
                URLCaption := StrSubstNo(SalesUrlLbl, SalesHeader."No.");
                Username := GetUserFullName(SalesHeader."BA Approval Email User ID");
                DocNo := SalesHeader."No.";
                DocType := 'Sales';
                SourceType := 'Customer';
                SourceNo := SalesHeader."Sell-to Customer No.";
                SourceName := SalesHeader."Sell-to Customer Name";
                if SalesHeader."BA Sent for Invoice Request" then begin
                    ApprovalAction := RequestForInvoicingLbl;
                    RejectReason := StrSubstNo(SentByLbl, GetUserFullName(UserId()));
                    if SalesHeader."Currency Code" = '' then begin
                        GLSetup.Get();
                        GLSetup.TestField("LCY Code");
                        CurrencyCode := GLSetup."LCY Code";
                    end else
                        CurrencyCode := SalesHeader."Currency Code";
                    SalesHeader.CalcFields("Amount Including VAT");
                    AmountText := StrSubstNo(AmountLbl, CurrencyCode, SalesHeader."Amount Including VAT");
                end else
                    if SalesHeader."BA Appr. Reject. Reason Code" <> '' then begin
                        ApprovalAction := RejectedLbl;
                        ApprovalRejection.Get(SalesHeader."BA Appr. Reject. Reason Code");
                        if ApprovalRejection.Description <> '' then
                            RejectReason := ApprovalRejection.Description
                        else
                            RejectReason := ApprovalRejection.Code;
                        RejectReason := StrSubstNo('Rejection Reason: %1', RejectReason);
                    end else
                        ApprovalAction := ApprovedLbl;
            end;
        }
    }


    trigger OnPreReport()
    begin
        UsePurchase := PurchaseHeader.GetFilters() <> '';
    end;

    procedure GetUserFullName(UserIDCode: Code[50]): Text;
    var
        User: Record User;
    begin
        User.SetRange("User Name", UserIDCode);
        if User.FindFirst() then
            if User."Full Name" <> '' then
                exit(User."Full Name")
            else
                if User."User Name" <> '' then
                    exit(User."User Name");
        exit(UserIDCode);
    end;


    var
        Username: Text;
        RejectReason: Text;
        ApprovalAction: Text;
        AmountText: Text;
        PageURL: Text;
        URLCaption: Text;
        DocNo: Text;
        DocType: Text;
        SourceNo: Text;
        SourceName: Text;
        SourceType: Text;
        UsePurchase: Boolean;


        SalesUrlLbl: Label 'Sales Order %1';
        PurchUrlLbl: Label 'Purchase Order %1';
        RequestForInvoicingLbl: Label 'has been requested for invoicing.';
        RejectedLbl: Label 'has been rejected for approval.';
        ApprovedLbl: Label 'has been approved.';
        SentByLbl: Label 'Sent by %1';
        AmountLbl: Label 'Amount %1 %2';
}