pageextension 80050 "BA Service Order" extends "Service Order"
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
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                Rec."BA Modified Posting Date" := true;
                Rec.Modify(true);
            end;
        }
    }



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

    trigger OnAfterGetRecord()
    var
        SalesLine: Record "Sales Line";
        CurrExchRate: Record "Currency Exchange Rate";
        OldCurrFactor: Decimal;
    begin
        GetUserSetup();
        if not UserSetup."BA Service Order Open" or (UserSetup."BA Open Service Order No." <> Rec."No.") then begin
            UserSetup."BA Service Order Open" := true;
            UserSetup."BA Open Service Order No." := Rec."No.";
            UserSetup.Modify(false);
        end;

        if Rec."BA Modified Posting Date" or (Rec."Posting Date" = WorkDate()) or not CurrPage.Editable() or (Rec.Status <> Rec.Status::"In Process") then
            exit;
        OldCurrFactor := Rec."Currency Factor";
        Rec.SetHideValidationDialog(true);
        Rec."BA Skip Sales Line Recreate" := true;
        if (Rec."Currency Code" <> '') and (Rec."Currency Factor" = 0) then
            if Rec."BA Quote Exch. Rate" <> 0 then
                Rec."Currency Factor" := 1 / Rec."BA Quote Exch. Rate"
            else
                Rec."Currency Factor" := CurrExchRate.GetCurrentCurrencyFactor(Rec."Currency Code");
        Rec.Validate("Posting Date", WorkDate());
        if (Rec."Currency Code" <> '') and (Rec."Currency Factor" = 0) then
            Rec.Validate("Currency Factor", CurrExchRate.GetCurrentCurrencyFactor(Rec."Currency Code"));
        Rec.SetHideValidationDialog(false);
        Rec."BA Skip Sales Line Recreate" := false;
        Rec.Modify(true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        GetUserSetup();
        if UserSetup."BA Service Order Open" then begin
            UserSetup."BA Service Order Open" := false;
            UserSetup."BA Open Service Order No." := '';
            UserSetup.Modify(false);
        end;
    end;

    local procedure GetUserSetup()
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup.Validate("User ID", UserId());
            UserSetup.Insert(false);
        end;
    end;

    var
        UserSetup: Record "User Setup";
}