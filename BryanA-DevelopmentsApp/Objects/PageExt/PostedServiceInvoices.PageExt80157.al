pageextension 80157 "BA Posted Service Invoices" extends "Posted Service Invoices"
{
    layout
    {
        addlast(Control1)
        {
            field("User ID"; Rec."User ID")
            {
                ApplicationArea = all;
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
            field("ENC Physical Ship Date"; "ENC Physical Ship Date")
            {
                ApplicationArea = all;
            }
            field("BA Promised Delivery Date"; "BA Promised Delivery Date")
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
            action("BA Send Shipment Details")
            {
                ApplicationArea = all;
                Image = SendEmailPDFNoAttach;
                Promoted = true;
                PromotedCategory = Process;
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
        }
    }
}