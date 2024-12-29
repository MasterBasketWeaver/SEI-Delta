report 50090 "BA Invoice/Shpt Email Body"
{
    Caption = 'Invoice & Shipments Email Body';
    UseRequestPage = false;
    WordLayout = './Objects/ReportLayouts/InvoiceShptEmailBody.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(SalesInvHeader; "Sales Invoice Header")
        {
            column(No; "No.") { }
            column(Username; Username) { }
            column(CompanyName; CompanyName()) { }
            column(ApprovalAction; ApprovalAction) { }
            column(CustomerNo; "Sell-to Customer No.") { }
            column(CustomerName; "Sell-to Customer Name") { }
            column(OrderLink_UrlText; StrSubstNo('Posted Sales Invoice %1', "No.")) { }
            column(OrderLink_Url; GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Posted Sales Invoice", SalesInvHeader)) { }


            trigger OnAfterGetRecord()
            begin
                ApprovalAction := 'has been invoiced. Please see invoice and packing slip(s) attached.';
                Username := 'Username';
            end;
        }
    }


    var
        Username: Text;
        ApprovalAction: Text;

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