page 50093 "BA Enter Rate Details"
{
    Caption = 'Enter Rate Details';
    PageType = StandardDialog;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            field(CurrencyCode; CurrencyCode)
            {
                ApplicationArea = all;
                ShowMandatory = true;
                TableRelation = Currency.Code where (Code = filter ('<>CDN'));
            }
            field("Fiscal Month"; Month)
            {
                ApplicationArea = all;
                ShowMandatory = true;

                trigger OnValidate()
                var
                    AccountingPeriod: Record "Accounting Period";
                    DateRec: Record Date;
                begin
                    DateRec.SetRange("Period Start", DMY2Date(1, Month + 1, 2025));
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Month);
                    DateRec.FindFirst();
                    MonthName := DateRec."Period Name";
                    AccountingPeriod.SetRange(Name, MonthName);
                    AccountingPeriod.SetRange(Closed, false);
                    AccountingPeriod.SetAscending("Starting Date", true);
                    if AccountingPeriod.FindLast() then begin
                        StartDate := AccountingPeriod."Starting Date";
                        AccountingPeriod.Reset();
                        AccountingPeriod.SetFilter("Starting Date", '>%1', AccountingPeriod."Starting Date");
                        if AccountingPeriod.FindFirst() then
                            EndDate := AccountingPeriod."Starting Date" - 1;
                    end;
                end;
            }
            field("Start Date"; StartDate)
            {
                ApplicationArea = all;
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    SetValuesFromStartDate()
                end;
            }
            field("End Date"; EndDate)
            {
                ApplicationArea = all;
                ShowMandatory = true;
            }
            field("Relational Exch. Rate Amount"; Rate)
            {
                ApplicationArea = all;
                ShowMandatory = true;
                BlankZero = true;
            }
            field("Relational Adjmt. Exch. Rate Amount"; AdjstRate)
            {
                ApplicationArea = all;
                ShowMandatory = true;
                BlankZero = true;
            }
        }
    }

    var
        StartDate: Date;
        EndDate: Date;
        MonthName: Text;
        Month: Option "January","February","March","April","May","June","July","August","September","October","November","December";
        CurrencyCode: Code[10];
        Rate: Decimal;
        AdjstRate: Decimal;
        TypeHelper: Codeunit "Type Helper";


    procedure SetValues(NewStartDate: Date; NewCurrencyCode: Code[10])
    begin
        StartDate := NewStartDate;
        CurrencyCode := NewCurrencyCode;
        SetValuesFromStartDate()
    end;

    procedure GetValues(var NewStartDate: Date; var NewEndDate: Date; var NewMonthName: Text; var NewCurrencyCode: Code[10]; var NewRate: Decimal; var NewAdjstRate: Decimal)
    begin
        NewStartDate := StartDate;
        NewEndDate := EndDate;
        NewMonthName := MonthName;
        NewCurrencyCode := CurrencyCode;
        NewRate := Rate;
        NewAdjstRate := AdjstRate;
    end;

    local procedure SetValuesFromStartDate()
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        if AccountingPeriod.Get(StartDate) then
            MonthName := AccountingPeriod.Name
        else begin
            AccountingPeriod.SetFilter("Starting Date", '<%1', StartDate);
            AccountingPeriod.SetRange(Closed, false);
            if AccountingPeriod.FindLast() then
                MonthName := AccountingPeriod.Name;
        end;

        if MonthName <> '' then
            Month := TypeHelper.GetOptionNo(MonthName, 'January,February,March,April,May,June,July,August,September,October,November,December');

        AccountingPeriod.Reset();
        AccountingPeriod.SetFilter("Starting Date", '>%1', StartDate);
        if AccountingPeriod.FindFirst() then
            EndDate := AccountingPeriod."Starting Date" - 1;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::LookupCancel then
            exit;
        if CurrencyCode = '' then
            Error(MissingValueErr, 'Currency Code');
        if Rate = 0 then
            Error(MissingValueErr, 'Relational Exch. Rate Amount');
        if AdjstRate = 0 then
            Error(MissingValueErr, 'Relational Adjmt. Exch. Rate Amount');
        if StartDate = 0D then
            Error(MissingValueErr, 'Start Date');
        if EndDate = 0D then
            Error(MissingValueErr, 'End Date');
        if StartDate > EndDate then
            Error(EndDateTooSoonErr, EndDate, StartDate);
    end;

    var
        MissingValueErr: Label '%1 must be specified.';
        EndDateTooSoonErr: Label 'End Date %1 must be after Start Date %2.';
}