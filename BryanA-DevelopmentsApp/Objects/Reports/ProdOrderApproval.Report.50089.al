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
            column(OrderLink_UrlText; StrSubstNo('Sales Order %1', "No.")) { }
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
                    ApprovalAction := 'has been requested for invoicing.';
                    RejectReason := StrSubstNo('Sent by %1', GetUserFullName(UserId()));
                    if SalesHeader."Currency Code" = '' then begin
                        GLSetup.Get();
                        GLSetup.TestField("LCY Code");
                        CurrencyCode := GLSetup."LCY Code";
                    end else
                        CurrencyCode := SalesHeader."Currency Code";
                    SalesHeader.CalcFields("Amount Including VAT");
                    AmountText := StrSubstNo('Amount %1 %2', CurrencyCode, SalesHeader."Amount Including VAT");
                end else
                    if SalesHeader."BA Appr. Reject. Reason Code" <> '' then begin
                        ApprovalAction := 'has been rejected for approval.';
                        ApprovalRejection.Get(SalesHeader."BA Appr. Reject. Reason Code");
                        if ApprovalRejection.Description <> '' then
                            RejectReason := ApprovalRejection.Description
                        else
                            RejectReason := ApprovalRejection.Code;
                    end else
                        ApprovalAction := 'has been approved.';
            end;
        }
    }


    var
        Username: Text;
        RejectReason: Text;
        ApprovalAction: Text;
        AmountText: Text;

    local procedure GetUserFullName(UserIDCode: Code[50]): Text;
    var
        User: Record User;
    begin
        User.SetRange("User Name", UserIDCode);
        if not User.FindFirst() then
            exit(UserIDCode);
        if User."Full Name" <> '' then
            exit(User."Full Name");
        exit(User."User Name");
    end;

}