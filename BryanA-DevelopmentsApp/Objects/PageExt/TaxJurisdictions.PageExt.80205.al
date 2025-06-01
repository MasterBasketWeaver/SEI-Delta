pageextension 80205 "BA Tax Jurisdictions" extends "Tax Jurisdictions"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Pass Through (Purchases)"; Rec."BA Pass Through (Purchases)")
            {
                ApplicationArea = all;

                trigger OnValidate()
                begin
                    EnableTaxAccount := not Rec."BA Pass Through (Purchases)";
                end;
            }
        }
        modify("Tax Account (Purchases)")
        {
            Enabled = EnableTaxAccount;
        }
    }

    trigger OnAfterGetRecord()
    begin
        EnableTaxAccount := not Rec."BA Pass Through (Purchases)";
    end;

    var
        [InDataSet]
        EnableTaxAccount: Boolean;
}