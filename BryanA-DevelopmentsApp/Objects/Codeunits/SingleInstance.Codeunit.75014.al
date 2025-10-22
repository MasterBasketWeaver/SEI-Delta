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


    procedure ClearBuffer(Start: Boolean)
    begin
        NameValueBuffer.Reset();
        NameValueBuffer.DeleteAll(false);
        IsPurchPosting := Start;
    end;

    procedure AddBuffer(var NewBuffer: Record "Name/Value Buffer")
    begin
        NameValueBuffer := NewBuffer;
        NameValueBuffer.Insert(false);
    end;

    procedure UpdateBuffer(var NewBuffer: Record "Name/Value Buffer")
    begin
        if NameValueBuffer.Get(NewBuffer.ID) then begin
            NameValueBuffer := NewBuffer;
            NameValueBuffer.Modify(false)
        end else begin
            NameValueBuffer := NewBuffer;
            NameValueBuffer.Insert(false);
        end;
    end;

    procedure SetBuffer(var NewBuffer: Record "Name/Value Buffer")
    begin
        NameValueBuffer.Reset();
        NameValueBuffer.DeleteAll(false);
        if NewBuffer.FindSet() then
            repeat
                NameValueBuffer := NewBuffer;
                NameValueBuffer.Insert(false);
            until NewBuffer.Next() = 0;
    end;

    procedure GetBuffer(var NewBuffer: Record "Name/Value Buffer"): Boolean
    begin
        NewBuffer.Reset();
        NewBuffer.DeleteAll(false);
        if NameValueBuffer.FindSet() then
            repeat
                NewBuffer := NameValueBuffer;
                NewBuffer.Insert(false);
            until NameValueBuffer.Next() = 0;
        exit(NewBuffer.FindSet());
    end;

    procedure GetIsPurchPosting(): Boolean
    begin
        exit(IsPurchPosting);
    end;




    procedure SetSkipCreditLimitUpdate(NewValue: Boolean)
    begin
        SkipCreditLimitUpdate := NewValue;
    end;

    procedure GetSkipCreditLimitUpdate(): Boolean
    begin
        exit(SkipCreditLimitUpdate);
    end;


    procedure SetSkipLedgerLineSave(NewValue: Boolean)
    begin
        SkipLedgerLineSave := NewValue;
    end;

    procedure GetSkipLedgerLineSave(): Boolean
    begin
        exit(SkipLedgerLineSave);
    end;



    procedure GetSkipBlockedItem(): Boolean
    begin
        exit(SkipBlockedItem);
    end;

    procedure SetSkipBlockedItem(NewValue: Boolean)
    begin
        SkipBlockedItem := NewValue;
    end;


    procedure GetHasDisplayedInventoryWarning(): Boolean
    begin
        exit(HasDisplayedInventoryWarning);
    end;

    procedure SetHasDisplayedInventoryWarning(NewValue: Boolean)
    begin
        HasDisplayedInventoryWarning := NewValue;
    end;


    procedure SetInitialLastDirectCost(NewValue: Decimal)
    begin
        InitialLastDirectCost := NewValue;
    end;

    procedure GetInitialLastDirectCost(): Decimal
    begin
        exit(InitialLastDirectCost);
    end;


    var
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        InitialLastDirectCost: Decimal;
        SkipUSDCreditLimit: Boolean;
        ForceUSDCreditLimit: Boolean;
        SkipSalesPrepaymentApprovalCheck: Boolean;
        IsPurchPosting: Boolean;
        SkipCreditLimitUpdate: Boolean;
        SkipLedgerLineSave: Boolean;
        SkipBlockedItem: Boolean;
        HasDisplayedInventoryWarning: Boolean;
}
