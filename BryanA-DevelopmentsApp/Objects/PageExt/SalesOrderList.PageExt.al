pageextension 80121 "BA Sales Order List" extends "Sales Order List"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Sales Source"; "BA Sales Source")
            {
                ApplicationArea = all;
            }
            field("BA Web Lead Date"; "BA Web Lead Date")
            {
                ApplicationArea = all;
            }
            field("BA SEI Int'l Ref. No."; Rec."BA SEI Int'l Ref. No.")
            {
                ApplicationArea = all;
            }
            field("Order Date"; Rec."Order Date")
            {
                ApplicationArea = all;
            }
            field("BA Quote Date"; Rec."BA Quote Date")
            {
                ApplicationArea = all;
            }
            field("Promised Delivery Date"; Rec."Promised Delivery Date")
            {
                ApplicationArea = all;
            }
            field("BA Approval Count"; Rec."BA Approval Count")
            {
                ApplicationArea = all;
            }
            field("BA Last Approval Amount"; Rec."BA Last Approval Amount")
            {
                ApplicationArea = all;
            }
            field("BA Appr. Reject. Reason Code"; Rec."BA Appr. Reject. Reason Code")
            {
                ApplicationArea = all;
            }
            field("BA Salesperson Verified"; Rec."BA Salesperson Verified")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the Salesperson assigned has been confirmed to be correct.';
                Visible = false;
            }
        }
    }

    actions
    {
        addlast(Reporting)
        {
            action("BA Create Packing Slip")
            {
                ApplicationArea = all;
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Create Packing Slip';

                trigger OnAction()
                var
                    SalesOrder: Page "Sales Order";
                begin
                    SalesOrder.PrintPackingSlip(Rec);
                end;
            }
        }
        addlast(Navigation)
        {
            action("BA Item Reclassification Journal")
            {
                ApplicationArea = all;
                Image = BinJournal;
                Caption = 'Item Reclassification Journal';
                RunObject = page "Item Reclass. Journal";
            }
        }
        addlast(Processing)
        {
            action("BA Add G/L Offset Amounts")
            {
                ApplicationArea = all;
                Image = AssessFinanceCharges;
                Caption = 'Add G/L Offset Amounts';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = IsDevUser;
                Enabled = IsDevUser;

                trigger OnAction()
                begin
                    Subscribers.AddGLOffsetAmounts(Rec);
                end;
            }
        }
    }


    var
        Subscribers: Codeunit "BA SEI Subscibers";
        [InDataSet]
        IsDevUser: Boolean;


    trigger OnOpenPage()
    begin
        IsDevUser := Subscribers.IsDebugUser();
    end;

}
