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
            Enabled = true;
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
    end;

    var
        [InDataSet]
        EFTPayment: Boolean;
}