codeunit 75014 "BA Single Instance"
{
    SingleInstance = true;

    procedure GetSkipUSDCreditLimit(): Boolean
    begin
        exit(SkipUSDCreditLimit);
    end;

    procedure SetSkipUSDCreditLimit(Update: Boolean)
    begin
        SkipUSDCreditLimit := Update;
    end;

    procedure GetForceUSDCreditLimit(): Boolean
    begin
        exit(ForceUSDCreditLimit);
    end;

    procedure SetForceUSDCreditLimit(Update: Boolean)
    begin
        ForceUSDCreditLimit := Update;
    end;

    var
        SkipUSDCreditLimit: Boolean;
        ForceUSDCreditLimit: Boolean;
}