pageextension 80046 "BA Item List" extends "Item List"
{
    layout
    {
        addlast(Control1)
        {
            field("ENC International HS Code"; Rec."ENC International HS Code")
            {
                ApplicationArea = all;
            }
            field("ENC US HS Code"; Rec."ENC US HS Code")
            {
                ApplicationArea = all;
            }
            field("ENC CUSMA"; Rec."ENC CUSMA")
            {
                ApplicationArea = all;
            }
            field("ENC Producer"; Rec."ENC Producer")
            {
                ApplicationArea = all;
            }
            field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
            {
                ApplicationArea = all;
            }
            field("BA Default Cross-Ref. No."; Rec."BA Default Cross-Ref. No.")
            {
                ApplicationArea = all;
            }
            field("BA Default Vendor No."; Rec."BA Default Vendor No.")
            {
                ApplicationArea = all;
            }
            field("BA Service Item Only"; Rec."BA Service Item Only")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addfirst(Processing)
        {
            action("BA Remove Sales Pricing")
            {
                ApplicationArea = all;
                Image = PriceAdjustment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Remove Sales Pricing';
                Visible = IsBryanUser;
                Enabled = IsBryanUser;

                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.ImportPricingListToRemove();
                end;
            }
            action("BA Update Sales Pricing")
            {
                ApplicationArea = all;
                Image = UpdateUnitCost;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Update Sales Pricing';
                Visible = IsBryanUser;
                Enabled = IsBryanUser;

                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.ImportPricingListToUpdate();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsBryanUser := UserId = 'SEI-IND\BRYANBCDEV';
    end;

    var
        [InDataSet]
        IsBryanUser: Boolean;
}