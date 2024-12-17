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
        }
    }






}