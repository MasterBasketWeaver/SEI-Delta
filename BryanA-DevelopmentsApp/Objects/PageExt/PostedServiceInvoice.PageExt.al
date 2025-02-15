pageextension 80055 "BA Posted Service Invoice" extends "Posted Service Invoice"
{
    layout
    {
        modify("Bill-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addbefore("Bill-to Name")
        {
            field("BA Bill-to Country/Region Code"; "Bill-to Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
                Editable = false;
            }
        }
        modify("Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addfirst("Sell-to")
        {
            field("BA Country/Region Code"; "Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
                Editable = false;
            }
        }
        modify("Ship-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addbefore("Ship-to Name")
        {
            field("BA Ship-to Country/Region Code"; "Ship-to Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
                Editable = false;
            }
        }
        addlast(General)
        {
            field("User ID"; Rec."User ID")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
        addBefore(ServInvLines)
        {
            part(ServLines; "BA Service Item Lines")
            {
                ApplicationArea = all;
                Caption = 'Service Item Lines';
                SubPageLink = "No." = field ("BA Shipment No.");
            }
        }
        addbefore("Order No.")
        {
            field("ENC S. Quote No."; Rec."ENC S. Quote No.")
            {
                ApplicationArea = all;
            }
        }
        addafter("Posting Date")
        {
            field("BA Actual Posting DateTime"; "BA Actual Posting DateTime")
            {
                ApplicationArea = all;
            }
        }
        addafter("Document Date")
        {
            field("BA Quote Date"; Rec."BA Quote Date")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BA Order Date"; Rec."Order Date")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
        addafter("Tax Area Code")
        {
            field("BA Tax Registration No."; Rec."ENC Tax Registration No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BA FID No."; Rec."ENC FID No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BA EORI No."; Rec."BA EORI No.")
            {
                ApplicationArea = all;
            }
        }
        addlast("Ship-to")
        {
            field("BA Ship-To Tax Reg. No."; Rec."ENC Ship-To Tax Reg. No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BA Ship-To FID No."; Rec."ENC Ship-To FID No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BA Ship-to EORI No."; Rec."BA Ship-to EORI No.")
            {
                ApplicationArea = all;
            }
        }
        addafter("Location Code")
        {
            field("ENC Shipping Agent Code"; "ENC Shipping Agent Code")
            {
                ApplicationArea = all;
                Editable = true;
                Caption = 'Freight Carrier';
            }
            field("ENC Shipment Method Code"; "ENC Shipment Method Code")
            {
                ApplicationArea = all;
                Editable = true;
                Caption = 'Service Level';
            }
            field("ENC Freight Term"; "ENC Freight Term")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("ENC Shipped By"; "ENC Shipped By")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("ENC Freight Account No."; "ENC Freight Account No.")
            {
                ApplicationArea = all;
            }
            field("ENC Package Tracking No."; "ENC Package Tracking No.")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("BA Package Tracking No. Date"; Rec."BA Package Tracking No. Date")
            {
                ApplicationArea = all;
            }
            field("Ship-to E-Mail"; Rec."Ship-to E-Mail")
            {
                ApplicationArea = all;
            }
            field("BA Promised Delivery Date"; "BA Promised Delivery Date")
            {
                ApplicationArea = all;
            }
            field("ENC Physical Ship Date"; "ENC Physical Ship Date")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("Reason Code";
            "Reason Code")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("ENC Freight Invoice Billed"; "ENC Freight Invoice Billed")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("ENC Brokerage Billed"; "ENC Brokerage Billed")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("ENC Consolidated With Order(s)"; "ENC Consolidated With Order(s)")
            {
                ApplicationArea = all;
                Editable = true;
            }
        }
        modify("Responsibility Center")
        {
            ApplicationArea = all;
            Visible = false;
        }
        addafter("Salesperson Code")
        {
            field("BA Salesperson Verified"; Rec."BA Salesperson Verified")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the Salesperson assigned has been confirmed to be correct.';
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
                PromotedCategory = Category5;
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

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("BA Shipment No.");
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) or not UserSetup."BA Force Reason Code Entry" then
            exit;
        if Rec."ENC Physical Ship Date" <= Rec."BA Promised Delivery Date" then
            exit(true);
        SalesRecSetup.Get();
        if SalesRecSetup."BA Default Reason Code" = '' then
            exit(true);
        if Rec."Reason Code" in ['', SalesRecSetup."BA Default Reason Code"] then
            Error(ReasonCodeErr, Rec.FieldCaption("Reason Code"));
    end;


    var
        ReasonCodeErr: Label '%1 must be a different value.';
}