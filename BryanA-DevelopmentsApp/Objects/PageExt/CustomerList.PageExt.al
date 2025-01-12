pageextension 80083 "BA Customer List" extends "Customer List"
{
    layout
    {
        addafter("Credit Limit (LCY)")
        {
            field("BA Credit Limit"; Rec."BA Credit Limit")
            {
                ApplicationArea = all;
            }
        }
        addlast(Control1)
        {
            field("BA Last Sales Activity"; Rec."BA Last Sales Activity")
            {
                ApplicationArea = all;
            }
            field("BA SEI Service Center"; Rec."BA SEI Service Center")
            {
                ApplicationArea = all;
            }
            field("BA SEI Int'l Cust. No."; Rec."BA SEI Int'l Cust. No.")
            {
                ApplicationArea = all;
            }
            field("BA Segment Code"; Rec."BA Segment Code")
            {
                ApplicationArea = all;
            }
            field("BA Sub-Segment Code"; Rec."BA Sub-Segment Code")
            {
                ApplicationArea = all;
            }
            field("BA Constrained"; Rec."BA Constrained")
            {
                ApplicationArea = all;
            }
            field("BA Dealer"; Rec."BA Dealer")
            {
                ApplicationArea = all;
            }
            field("BA Non-Mandatory Delivery Date"; Rec."BA Non-Mandatory Delivery Date")
            {
                ApplicationArea = all;
            }
            field("BA Government (CDN/US)"; Rec."BA Government (CDN/US)")
            {
                ApplicationArea = all;
            }
            field("BA Trusted Agent"; Rec."BA Trusted Agent")
            {
                ApplicationArea = all;
            }
            field("BA Approval Group"; Rec."BA Approval Group")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {

        addlast(Processing)
        {
            action("BA Import Customers")
            {
                ApplicationArea = all;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Import Customers';

                trigger OnAction()
                var
                    Subsribers: Codeunit "BA SEI Subscibers";
                begin
                    Subsribers.ImportCustomerList();
                end;
            }
            action("BA Delete Customers")
            {
                ApplicationArea = all;
                Image = DeleteAllBreakpoints;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Delete Customers';
                Enabled = EnableCustDeleteReport;
                Visible = EnableCustDeleteReport;

                trigger OnAction()
                var
                    Customer: Record Customer;
                    DeleteCustomers: Report "BA Delete Customers";
                begin
                    CurrPage.SetSelectionFilter(Customer);
                    DeleteCustomers.SetTableView(Customer);
                    DeleteCustomers.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        DeleteCustomers: Report "BA Delete Customers";
    begin
        EnableCustDeleteReport := DeleteCustomers.IsValidUser();
    end;

    var
        [InDataSet]
        EnableCustDeleteReport: Boolean;
}