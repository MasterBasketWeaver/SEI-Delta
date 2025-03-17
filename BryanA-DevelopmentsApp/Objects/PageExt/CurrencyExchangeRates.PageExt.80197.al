pageextension 80197 "BA Currency Exchange Rates" extends "Currency Exchange Rates"
{
    actions
    {
        addlast(Processing)
        {
            action("BA Enter Rate By Date Range")
            {
                ApplicationArea = all;
                Caption = 'Enter Rate By Date Range';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CalculateCalendar;
                Enabled = Enabled;

                trigger OnAction()
                var
                    CurrExchRate: Record "Currency Exchange Rate";
                    EnterRateByDateRange: Page "BA Enter Rate Details";
                    StartDate: Date;
                    EndDate: Date;
                    MonthName: Text;
                    CurrencyCode: Code[10];
                    Rate: Decimal;
                    AdjstRate: Decimal;
                    DateRange: Integer;
                    i: Integer;
                begin
                    EnterRateByDateRange.SetValues(Today(), Rec."Currency Code");
                    EnterRateByDateRange.LookupMode(true);
                    if EnterRateByDateRange.RunModal() <> Action::LookupOK then
                        exit;
                    EnterRateByDateRange.GetValues(StartDate, EndDate, MonthName, CurrencyCode, Rate, AdjstRate);
                    SingleInstance.SetSkipUSDCreditLimit(true);
                    while StartDate <= EndDate do begin
                        if not CurrExchRate.Get(CurrencyCode, StartDate) then begin
                            CurrExchRate.Init();
                            CurrExchRate.Validate("Starting Date", StartDate);
                            CurrExchRate.Validate("Currency Code", CurrencyCode);
                            CurrExchRate.Validate("Fix Exchange Rate Amount", CurrExchRate."Fix Exchange Rate Amount"::Currency);
                            CurrExchRate.Insert(true);
                        end;
                        CurrExchRate.Validate("Exchange Rate Amount", 1.0);
                        CurrExchRate.Validate("Relational Exch. Rate Amount", Rate);
                        CurrExchRate.Validate("Adjustment Exch. Rate Amount", 1.0);
                        CurrExchRate.Validate("Relational Adjmt Exch Rate Amt", AdjstRate);
                        CurrExchRate.Modify(true);
                        StartDate += 1;
                        i += 1;
                    end;
                    SingleInstance.SetSkipUSDCreditLimit(false);
                    Message(CompletedMsg, i, CurrencyCode, Rate, MonthName);
                    if CurrencyCode <> 'USD' then
                        exit;
                    SingleInstance.SetForceUSDCreditLimit(true);
                    CurrExchRate.Get(CurrencyCode, EndDate);
                    CurrExchRate.Validate("Relational Exch. Rate Amount");
                    SingleInstance.SetForceUSDCreditLimit(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Enabled := (Rec."Currency Code" <> LCYCode) and (Rec."Currency Code" <> '');
    end;

    trigger OnOpenPage()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        LCYCode := GLSetup."LCY Code";
    end;

    var
        SingleInstance: Codeunit "BA Single Instance";
        LCYCode: Code[10];
        [InDataSet]
        Enabled: Boolean;

        CompletedMsg: Label 'Inserted %1 new %2 exchange rates at %3 for the fiscal month of %4.';
}