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
            column(Username; "BA Invoice/Packing Slip Users") { }
            column(CompanyName; CompanyName()) { }
            column(ApprovalAction; DescriptionLbl) { }
            column(CustomerNo; "Sell-to Customer No.") { }
            column(CustomerName; "Sell-to Customer Name") { }
            column(OrderLink_UrlText; StrSubstNo(UrlLbl, "No.")) { }
            column(OrderLink_Url; GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Posted Sales Invoice", SalesInvHeader)) { }
        }
    }


    var
        ApprovalAction: Text;

        UrlLbl: Label 'Posted Sales Invoice %1';
        DescriptionLbl: Label 'has been invoiced. Please see invoice and packing slip(s) attached.';
}