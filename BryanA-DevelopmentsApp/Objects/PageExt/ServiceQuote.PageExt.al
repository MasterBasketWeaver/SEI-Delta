pageextension 80051 "BA Service Quote" extends "Service Quote"
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
            }
        }
        addlast(General)
        {
            field("BA Quote Exch. Rate"; "BA Quote Exch. Rate")
            {
                ApplicationArea = all;
            }
        }
        modify("Order Date")
        {
            ApplicationArea = all;
            Editable = false;
            Visible = false;
        }
        addafter("Service Order Type")
        {
            field("BA External Document No."; "ENC External Document No.")
            {
                ApplicationArea = all;
                Caption = 'External Document No.';
            }
            field("BA Document Date"; Rec."Document Date")
            {
                ApplicationArea = all;
            }
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
        addlast("Ship-to")
        {
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
        }
        modify("Document Date")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Salesperson Code")
        {
            ApplicationArea = all;
            Visible = false;
        }
        addafter(Status)
        {
            field("BA Salesperson Code"; Rec."Salesperson Code")
            {
                ApplicationArea = all;
            }
            field("BA Salesperson Verified"; Rec."BA Salesperson Verified")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies if the Salesperson assigned has been confirmed to be correct.';
            }
        }
        modify("Responsibility Center")
        {
            ApplicationArea = all;
            Visible = false;
        }
    }


    actions
    {

        addlast(Processing)
        {
            action("BA Update Exchange Rate")
            {
                Image = AdjustExchangeRates;
                ApplicationArea = all;
                Caption = 'Update Exchange Rate';
                Enabled = CanUpdateRate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.UpdateServicePrice(Rec);
                end;
            }
        }
    }


    var
        [InDataSet]
        CanUpdateRate: Boolean;
        // [InDataSet]
        // ShowLCYBalances: Boolean;

    trigger OnAfterGetRecord()
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        // CustPostingGroup: Record "Customer Posting Group";
    begin
        CanUpdateRate := SalesRecSetup.Get() and SalesRecSetup."BA Use Single Currency Pricing";
        // ShowLCYBalances := CustPostingGroup.Get(Rec."Customer Posting Group") and not CustPostingGroup."BA Show Non-Local Currency";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ExchangeRate: Record "Currency Exchange Rate";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        Subscribers: Codeunit "BA SEI Subscibers";
    begin
        ServiceMgtSetup.Get();
        if not ServiceMgtSetup."BA Use Single Currency Pricing" then
            exit;
        ServiceMgtSetup.TestField("BA Single Price Currency");
        if Subscribers.GetExchangeRate(ExchangeRate, ServiceMgtSetup."BA Single Price Currency") then
            Rec."BA Quote Exch. Rate" := ExchangeRate."Relational Exch. Rate Amount";
    end;
}