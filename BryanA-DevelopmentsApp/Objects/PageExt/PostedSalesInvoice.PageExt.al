pageextension 80052 "BA Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        modify("Sell-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addfirst("Sell-to")
        {
            field("BA Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
                Editable = false;
            }
        }
        modify("Bill-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addbefore("Bill-to Name")
        {
            field("BA Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
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
            field("BA Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
                Editable = false;
            }
        }
        addafter("Sell-to County")
        {
            field("BA Sell-to County Fullname"; "BA Sell-to County Fullname")
            {
                ApplicationArea = all;
            }
        }
        addafter("Ship-to County")
        {
            field("BA Ship-to County Fullname"; Rec."BA Ship-to County Fullname")
            {
                ApplicationArea = all;
            }
        }
        addafter("Bill-to County")
        {
            field("BA Bill-to County Fullname"; Rec."BA Bill-to County Fullname")
            {
                ApplicationArea = all;
            }
        }
        addafter("Order No.")
        {
            field("BA Sales Source"; SalesSource)
            {
                ApplicationArea = all;
                Caption = 'Source';
                Editable = Editable;
                TableRelation = "BA Sales Source".Name;

                trigger OnValidate()
                begin
                    Rec."BA Sales Source" := SalesSource;
                end;
            }
            field("BA Web Lead Date"; WebLeadDate)
            {
                ApplicationArea = all;
                Caption = 'Web Lead Date';
                Editable = Editable;

                trigger OnValidate()
                begin
                    Rec."BA Web Lead Date" := WebLeadDate;
                end;
            }
        }
        addafter("External Document No.")
        {
            field("ENC Assigned User ID"; Rec."ENC Assigned User ID")
            {
                ApplicationArea = all;
                Caption = 'Assigned User ID';
            }
            field("User ID"; Rec."User ID")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
        addafter("Posting Date")
        {
            field("BA Actual Posting DateTime"; Rec."BA Actual Posting DateTime")
            {
                ApplicationArea = all;
            }
        }
        addbefore("Work Description")
        {
            field("BA SEI Int'l Ref. No."; Rec."BA SEI Int'l Ref. No.")
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
            field("Order Date"; Rec."Order Date")
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
        addafter("Shipping Agent Code")
        {
            field("Service Level"; Rec."Shipment Method Code")
            {
                ApplicationArea = all;
                Caption = 'Service Level';
                Editable = true;
            }
            field("ENC Freight Term"; Rec."ENC Freight Term")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("ENC Freight Quote No."; Rec."ENC Freight Quote No.")
            {
                ApplicationArea = all;
            }
            field("ENC Freight Account No."; Rec."ENC Freight Account No.")
            {
                ApplicationArea = all;
            }
            field("ENC Shipped By"; Rec."ENC Shipped By")
            {
                ApplicationArea = all;
                Editable = true;
            }
            field("Package Tracking No.2"; Rec."Package Tracking No.")
            {
                ApplicationArea = all;
                Caption = 'Package Tracking No.';
                Editable = true;
            }
            field("BA Package Tracking No. Date"; Rec."BA Package Tracking No. Date")
            {
                ApplicationArea = all;
            }
            field("BA Ship-to Email"; Rec."BA Ship-to Email")
            {
                ApplicationArea = all;
            }
            field("Shipment Date2"; Rec."Shipment Date")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("ENC Promised Delivery Date"; Rec."ENC Promised Delivery Date")
            {
                ApplicationArea = all;
            }
            field("ENC Physical Ship Date"; Rec."ENC Physical Ship Date")
            {
                ApplicationArea = all;
                Caption = 'Physical Ship Date';
                Editable = true;
            }
            field("Reason Code"; Rec."Reason Code")
            {
                ApplicationArea = all;
                Caption = 'Reason Code';
                Editable = true;
            }
            field("ENC Freight Invoice Billed"; Rec."ENC Freight Invoice Billed")
            {
                ApplicationArea = all;
                Caption = 'Freight Invoice Billed';
                Editable = true;
            }
            field("ENC Brokerage Billed"; Rec."ENC Brokerage Billed")
            {
                ApplicationArea = all;
                Caption = 'Brokerage Billed';
                Editable = true;
            }
            field("ENC Consolidated With Order(s)"; Rec."ENC Consolidated With Order(s)")
            {
                ApplicationArea = all;
                Caption = 'Consolidated With Order(s)';
                Editable = true;
            }
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
                PromotedCategory = Category6;
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
        SalesSource := Rec."BA Sales Source";
        WebLeadDate := Rec."BA Web Lead Date";
        Editable := CurrPage.Editable();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) or not UserSetup."BA Force Reason Code Entry" then
            exit;
        if Rec."ENC Physical Ship Date" <= Rec."ENC Promised Delivery Date" then
            exit(true);
        SalesRecSetup.Get();
        if SalesRecSetup."BA Default Reason Code" = '' then
            exit(true);
        if Rec."Reason Code" in ['', SalesRecSetup."BA Default Reason Code"] then
            Error(ReasonCodeErr, Rec.FieldCaption("Reason Code"));
    end;

    var
        SalesSource: Text[30];
        WebLeadDate: Date;
        [InDataSet]
        Editable: Boolean;

        ReasonCodeErr: Label '%1 must be a different value.';
}