pageextension 80005 "BA Sales Quote" extends "Sales Quote"
{
    layout
    {
        modify("Due Date")
        {
            ApplicationArea = all;
            Visible = false;
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
                // Editable = billtoop
            }
        }
        modify("Ship-to Country/Region Code")
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        addfirst(Control72)
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
        addafter("Requested Delivery Date")
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
        modify("Order Date")
        {
            ApplicationArea = all;
            Editable = false;
            Visible = false;
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
        addafter("Ship-to Contact")
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
        }
        addafter("Ship-to Contact")
        {
            field("BA Ship-to Email"; Rec."BA Ship-to Email")
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
            Visible = false;
            ApplicationArea = all;
        }
    }

    actions
    {
        addlast(Navigation)
        {
            action("BA Assemble-to-Order Lines")
            {
                Image = AssemblyBOM;
                Caption = 'Assemble-to-Order Lines';
                ApplicationArea = all;

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                begin
                    CurrPage.SalesLines.Page.GetRecord(SalesLine);
                    SalesLine.ShowAsmToOrderLines();
                end;
            }
        }
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
                    Subscribers.UpdateSalesPrice(Rec);
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
        CustPostingGroup: Record "Customer Posting Group";
    begin
        CanUpdateRate := SalesRecSetup.Get() and SalesRecSetup."BA Use Single Currency Pricing";
        // ShowLCYBalances := CustPostingGroup.Get(Rec."Customer Posting Group") and not CustPostingGroup."BA Show Non-Local Currency";
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