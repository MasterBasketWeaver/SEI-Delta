pageextension 80092 "BA Service Orders" extends "Service Orders"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Amount"; Rec."BA Amount")
            {
                ApplicationArea = all;
            }
            field("BA Amount Including VAT"; Rec."BA Amount Including Tax")
            {
                ApplicationArea = all;
            }
            field("BA Amount Including VAT (LCY)"; Rec."BA Amount Including Tax (LCY)")
            {
                ApplicationArea = all;
                Visible = false;
            }
            field("BA Quote Date"; Rec."BA Quote Date")
            {
                ApplicationArea = all;
            }
            field("BA Order Date"; Rec."Order Date")
            {
                ApplicationArea = all;
            }
            field("BA Shipment Date"; Rec."BA Shipment Date")
            {
                ApplicationArea = all;
            }
            field("BA Promised Delivery Date"; "BA Promised Delivery Date")
            {
                ApplicationArea = all;
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
                    ServiceOrder: Page "Service Order";
                begin
                    ServiceOrder.PrintPackingSlip(Rec);
                end;
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("BA Amount", "BA Amount Including Tax", "BA Amount Including Tax (LCY)");
    end;
}