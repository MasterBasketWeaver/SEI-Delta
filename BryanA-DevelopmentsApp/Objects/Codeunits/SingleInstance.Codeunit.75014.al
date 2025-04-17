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

    procedure GetSkipSalesPrepaymentApprovalCheck(): Boolean
    begin
        exit(SkipSalesPrepaymentApprovalCheck);
    end;

    procedure SetSkipSalesPrepaymentApprovalCheck(Update: Boolean)
    begin
        SkipSalesPrepaymentApprovalCheck := Update;
    end;

    var
        SkipUSDCreditLimit: Boolean;
        ForceUSDCreditLimit: Boolean;
        SkipSalesPrepaymentApprovalCheck: Boolean;
}