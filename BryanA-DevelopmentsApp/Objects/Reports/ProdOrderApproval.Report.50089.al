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
            column(OrderLink_UrlText; StrSubstNo('Order %1', "No.")) { }
            column(OrderLink_Url; GetUrl(ClientType::Windows, CompanyName(), ObjectType::Page, Page::"Sales Order", SalesHeader)) { }


            trigger OnAfterGetRecord()
            var
                User: Record User;
                ApprovalRejection: Record "BA Approval Rejection";
            begin
                User.SetRange("User Name", SalesHeader."BA Approval Email User ID");
                if User.FindFirst() then
                    if User."Full Name" <> '' then
                        Username := User."Full Name"
                    else
                        Username := User."User Name";
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


}