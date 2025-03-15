report 50089 "BA Prod. Order Approval"
{
    Caption = 'Prod. Order Approval';
    UseRequestPage = false;
    WordLayout = './Objects/ReportLayouts/ProdOrderApproval.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            column(No; "No.") { }
            column(Username; Username) { }
            column(CompanyName; CompanyName()) { }
            column(ApprovalAction; ApprovalAction) { }
            column(RejectReason; RejectReason) { }
            column(CustomerNo; "Sell-to Customer No.") { }
            column(CustomerName; "Sell-to Customer Name") { }
            column(OrderLink_UrlText; StrSubstNo(UrlLbl, "No.")) { }
            column(OrderLink_Url; GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Sales Order", SalesHeader)) { }
            column(AmountText; AmountText) { }


            trigger OnAfterGetRecord()
            var
                ApprovalRejection: Record "BA Approval Rejection";
                GLSetup: Record "General Ledger Setup";
                CurrencyCode: Code[10];
            begin
                Username := GetUserFullName(SalesHeader."BA Approval Email User ID");
                if "BA Sent for Invoice Request" then begin
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


        UrlLbl: Label 'Sales Order %1';
        RequestForInvoicingLbl: Label 'has been requested for invoicing.';
        RejectedLbl: Label 'has been rejected for approval.';
        ApprovedLbl: Label 'has been approved.';
        SentByLbl: Label 'Sent by %1';
        AmountLbl: Label 'Amount %1 %2';
}