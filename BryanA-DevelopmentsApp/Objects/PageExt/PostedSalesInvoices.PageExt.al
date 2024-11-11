pageextension 80123 "BA Posted Sales Invoices" extends "Posted Sales Invoices"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Sales Source"; Rec."BA Sales Source")
            {
                ApplicationArea = all;
            }
            field("BA Web Lead Date"; Rec."BA Web Lead Date")
            {
                ApplicationArea = all;
            }
            field("User ID"; Rec."User ID")
            {
                ApplicationArea = all;
            }
            field("BA SEI Int'l Ref. No."; Rec."BA SEI Int'l Ref. No.")
            {
                ApplicationArea = all;
            }
            field("BA Order Date"; Rec."Order Date")
            {
                ApplicationArea = all;
            }
            field("BA Quote Date"; Rec."BA Quote Date")
            {
                ApplicationArea = all;
            }
            field("ENC Promised Delivery Date"; Rec."ENC Promised Delivery Date")
            {
                ApplicationArea = all;
            }
        }
        addafter("Posting Date")
        {
            field("BA Actual Posting DateTime"; Rec."BA Actual Posting DateTime")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action("BA Import Booking Dates")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = UpdateUnitCost;
                Caption = 'Update Booking Dates';
                Visible = IsdebugUser;
                Enabled = IsdebugUser;

                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.ImportBookingDates(true);
                end;
            }
            action("BA Send Shipment Details")
            {
                ApplicationArea = all;
                Image = SendEmailPDFNoAttach;
                Promoted = true;
                PromotedCategory = Category7;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Send Shipment Details';

                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.SendShipmentTrackingInfoEmail(Rec);
                end;
            }
            action("BA Update Freight Carrier")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CalculateShipment;
                Caption = 'Update Freight Carrier';
                Visible = IsdebugUser;
                Enabled = IsdebugUser;


                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.ImportFreightInvoicesToFixUpdate();
                end;
            }
        }
    }

    var
        [InDataSet]
        IsdebugUser: Boolean;

    trigger OnOpenPage()
    var
        Subscribers: Codeunit "BA SEI Subscibers";
    begin
        IsdebugUser := Subscribers.IsDebugUser();
    end;

}