pageextension 80186 "BA Payment Journal" extends "Payment Journal"
{
    layout
    {
        addafter("Check Printed")
        {
            field("BA Check Transmitted"; Rec."Check Transmitted")
            {
                ApplicationArea = all;
            }
        }
        modify(Description)
        {
            ShowMandatory = EFTpayment;
        }
        modify("Bank Payment Type")
        {
            trigger OnAfterValidate()
            begin
                EFTPayment := Rec."Bank Payment Type" = Rec."Bank Payment Type"::"Electronic Payment";
            end;
        }
        modify("Recipient Bank Account")
        {
            ShowMandatory = EFTpayment;
        }
        modify("Bal. Account Type")
        {
            trigger OnAfterValidate()
            begin
                SetBankLine();
            end;
        }
        modify("Bal. Account No.")
        {
            trigger OnAfterValidate()
            begin
                SetBankLine();
            end;
        }
    }

    actions
    {
        modify(TransmitPayments)
        {
            ApplicationArea = all;
            Visible = false;
            Enabled = false;
        }
        modify(GenerateEFT)
        {
            ApplicationArea = all;
            Visible = true;
            Enabled = IsBankLink;
            Promoted = true;
            PromotedCategory = Category4;
            PromotedIsBig = true;
            PromotedOnly = true;
        }
        moveafter(VoidPayments; GenerateEFT)
    }

    trigger OnAfterGetRecord()
    begin
        EFTPayment := Rec."Bank Payment Type" = Rec."Bank Payment Type"::"Electronic Payment";
        SetBankLine();
    end;

    local procedure SetBankLine()
    begin
        IsBankLink := (Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account") and (Rec."Bal. Account No." <> '');
    end;

    var
        [InDataSet]
        EFTPayment: Boolean;

        [InDataSet]
        IsBankLink: Boolean;
}