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
            field("BA Appr. Reject. Reason Code"; "BA Appr. Reject. Reason Code")
            {
                ApplicationArea = all;
                Visible = ShowApprovalRejection;
            }
            field("BA Rejection Reason"; "BA Rejection Reason")
            {
                ApplicationArea = all;
                Visible = ShowApprovalRejection;
            }
        }

    }




    var
        [InDataSet]
        MandatoryDeliveryDate: Boolean;
        [InDataSet]
        ShowApprovalRejection: Boolean;

    trigger OnAfterGetRecord()
    var
        Customer: Record Customer;
    begin
        MandatoryDeliveryDate := Customer.Get(Rec."Bill-to Customer No.") and not Customer."BA Non-Mandatory Delivery Date";
        ShowApprovalRejection := Rec."BA Appr. Reject. Reason Code" <> '';
    end;


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ExchangeRate: Record "Currency Exchange Rate";
        SalesRecSetup: Record "Sales & Receivables Setup";
        Subscribers: Codeunit "BA SEI Subscibers";
    begin
        SalesRecSetup.Get();
        if not SalesRecSetup."BA Use Single Currency Pricing" then
            exit;
        SalesRecSetup.TestField("BA Single Price Currency");
        if Subscribers.GetExchangeRate(ExchangeRate, SalesRecSetup."BA Single Price Currency") then begin
            Rec."BA Quote Exch. Rate" := ExchangeRate."Relational Exch. Rate Amount";
            CurrPage.SalesLines.Page.SetExchangeRate(Rec."BA Quote Exch. Rate");
        end
    end;

}