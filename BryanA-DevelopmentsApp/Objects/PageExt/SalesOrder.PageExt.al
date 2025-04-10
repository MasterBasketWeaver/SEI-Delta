pageextension 80025 "BA Sales Order" extends "Sales Order"
{
    layout
    {
        modify("Location Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                Subscribers: Codeunit "BA SEI Subscibers";
            begin
                Text := Subscribers.LocationListLookup();
                exit(Text <> '');
            end;
        }
        modify("Due Date")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Bill-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addfirst(Control82)
        {
            field("BA Bill-to Country/Region Code"; "Bill-to Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
            }
        }
        modify("Sell-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addfirst("Sell-to")
        {
            field("BA Sell-to Country/Region Code"; "Sell-to Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
            }
        }
        modify("Ship-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addfirst(Control4)
        {
            field("BA Ship-to Country/Region Code"; "Ship-to Country/Region Code")
            {
                ApplicationArea = all;
                Caption = 'Country';
            }
        }
        addafter("Payment Method Code")
        {
            field("Due Date2"; Rec."Due Date")
            {
                ApplicationArea = all;
            }
        }
        addafter("Sell-to County")
        {
            field("BA Sell-to County Fullname"; "BA Sell-to County Fullname")
            {
                ApplicationArea = all;
            }
        }
        modify("Sell-to County")
        {
            trigger OnAfterValidate()
            begin
                Rec.CalcFields("BA Sell-to County Fullname");
            end;
        }
        addafter("Ship-to County")
        {
            field("BA Ship-to County Fullname"; "BA Ship-to County Fullname")
            {
                ApplicationArea = all;
            }
        }
        modify("Ship-to County")
        {
            trigger OnAfterValidate()
            begin
                Rec.CalcFields("BA Ship-to County Fullname");
            end;
        }
        addafter("Bill-to County")
        {
            field("BA Bill-to County Fullname"; "BA Bill-to County Fullname")
            {
                ApplicationArea = all;
            }
        }
        modify("Bill-to County")
        {
            trigger OnAfterValidate()
            begin
                Rec.CalcFields("BA Bill-to County Fullname");
            end;
        }
        addbefore("External Document No.")
        {
            field("BA Sales Source"; "BA Sales Source")
            {
                ApplicationArea = all;
            }
            field("BA Web Lead Date"; "BA Web Lead Date")
            {
                ApplicationArea = all;
            }
        }
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                Rec."BA Modified Posting Date" := true;
                Rec.Modify(true);
            end;
        }
        addbefore("Work Description")
        {
            field("BA SEI Int'l Ref. No."; Rec."BA SEI Int'l Ref. No.")
            {
                ApplicationArea = all;
            }
        }
        modify("Order Date")
        {
            ApplicationArea = all;
            Editable = false;
        }
        addbefore("Order Date")
        {
            field("BA Quote Date"; Rec."BA Quote Date")
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
            }
            field("BA FID No."; Rec."ENC FID No.")
            {
                ApplicationArea = all;
            }
            field("BA EORI No."; Rec."BA EORI No.")
            {
                ApplicationArea = all;
            }
        }
        addbefore("Shipment Method")
        {
            field("BA Ship-to Phone No."; Rec."ENC Ship-to Phone No.")
            {
                ApplicationArea = all;
            }
            field("BA Ship-To Tax Reg. No."; Rec."ENC Ship-To Tax Reg. No.")
            {
                ApplicationArea = all;
            }
            field("BA Ship-To FID No."; Rec."ENC Ship-To FID No.")
            {
                ApplicationArea = all;
            }
            field("BA Ship-to EORI No."; Rec."BA Ship-to EORI No.")
            {
                ApplicationArea = all;
            }
            field("Shipping Advice2"; Rec."Shipping Advice")
            {
                ApplicationArea = all;
                Caption = 'Shipping Advice';
            }
        }
        modify("Promised Delivery Date")
        {
            ApplicationArea = all;
            ShowMandatory = MandatoryDeliveryDate;
        }
        addafter("Ship-to Contact")
        {
            field("BA Ship-to Email"; Rec."BA Ship-to Email")
            {
                ApplicationArea = all;
            }
        }
        addlast(General)
        {
            field("BA Approval Count"; Rec."BA Approval Count")
            {
                ApplicationArea = all;
            }
            field("BA Last Approval Amount"; Rec."BA Last Approval Amount")
            {
                ApplicationArea = all;
            }
        }
        addafter(Status)
        {
            field("BA Appr. Reject. Reason Code"; "BA Appr. Reject. Reason Code")
            {
                ApplicationArea = all;
            }
            field("BA Rejection Reason"; "BA Rejection Reason")
            {
                ApplicationArea = all;
            }
        }
        addafter("Salesperson Code")
        {
            field("BA Salesperson Verified"; Rec."BA Salesperson Verified")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the Salesperson assigned has been confirmed to be correct.';
                Importance = Additional;
            }
        }
        modify("Campaign No.")
        {
            ApplicationArea = all;
            Visible = false;
        }
    }


    actions
    {
        addlast(Processing)
        {
            action("BA Send for Invoicing")
            {
                ApplicationArea = all;
                Image = SendEmailPDFNoAttach;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Send for Invoicing';

                trigger OnAction()
                var
                    SalesApprovalMgt: Codeunit "BA Sales Approval Mgt.";
                begin
                    SalesApprovalMgt.SendOrderForInvoicing(Rec);
                end;
            }
        }
    }


    var
        [InDataSet]
        MandatoryDeliveryDate: Boolean;
        // [InDataSet]
        // ShowApprovalRejection: Boolean;



    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        UpdateExchangeRate();
    end;

    local procedure UpdateExchangeRate()
    var
        ExchangeRate: Record "Currency Exchange Rate";
        SalesRecSetup: Record "Sales & Receivables Setup";
        Subscribers: Codeunit "BA SEI Subscibers";
    begin
        SalesRecSetup.Get();
        if not SalesRecSetup."BA Use Single Currency Pricing" then
            exit;
        SalesRecSetup.TestField("BA Single Price Currency");
        if Subscribers.GetExchangeRate(ExchangeRate, SalesRecSetup."BA Single Price Currency") then
            Rec."BA Quote Exch. Rate" := ExchangeRate."Relational Exch. Rate Amount";
    end;

    trigger OnAfterGetRecord()
    var
        ResetStatus: Boolean;
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
    begin
        MandatoryDeliveryDate := Customer.Get(Rec."Bill-to Customer No.") and not Customer."BA Non-Mandatory Delivery Date";
        if Rec."BA Modified Posting Date" or (Rec."Posting Date" = WorkDate()) or not CurrPage.Editable() or (Rec.Status <> Rec.Status::Open) then
            exit;
        Rec.SetHideValidationDialog(true);
        Rec."BA Skip Sales Line Recreate" := true;
        Rec.Validate("Posting Date", WorkDate());
        UpdateExchangeRate();
        Rec.SetHideValidationDialog(false);
        Rec."BA Skip Sales Line Recreate" := false;
        Rec.Modify(true);
    end;

}