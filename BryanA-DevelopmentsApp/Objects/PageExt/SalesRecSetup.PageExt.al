pageextension 80075 "BA Sales & Rec. Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(General)
        {
            field("BA Default Reason Code"; Rec."BA Default Reason Code")
            {
                ApplicationArea = all;
            }
            field("BA Prepaid Order Limit"; Rec."BA Prepaid Order Limit")
            {
                ApplicationArea = all;
            }
            field("BA Restrict Order Creation"; Rec."BA Restrict Order Creation")
            {
                ApplicationArea = all;
            }
            field("BA Restrict Order Start Time"; Rec."BA Restrict Order Start Time")
            {
                ApplicationArea = all;
                Enabled = "BA Restrict Order Creation";
            }
            field("BA Restrict Order End Time"; Rec."BA Restrict Order End Time")
            {
                ApplicationArea = all;
                Enabled = "BA Restrict Order Creation";
            }
            // group("Custom Pricing")
            // {
            //     field("BA Use Single Currency Pricing"; "BA Use Single Currency Pricing")
            //     {
            //         ApplicationArea = all;
            //         ToolTip = 'Specifies if Items should use a single price for all currencies.';

            //         trigger OnValidate()
            //         begin
            //             UseCurrencyPricing := Rec."BA Use Single Currency Pricing";
            //         end;
            //     }
            //     field("BA Single Price Currency"; "BA Single Price Currency")
            //     {
            //         ApplicationArea = all;
            //         ToolTip = 'Specifies the currency to be used for all item pricing.';
            //         ShowMandatory = UseCurrencyPricing;
            //         Editable = UseCurrencyPricing;
            //     }
            // }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Get() then
            UseCurrencyPricing := Rec."BA Use Single Currency Pricing";
    end;

    var
        [InDataSet]
        UseCurrencyPricing: Boolean;
}