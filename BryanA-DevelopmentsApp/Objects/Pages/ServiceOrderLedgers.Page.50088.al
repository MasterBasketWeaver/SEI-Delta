page 50088 "BA Service Order Ledgers"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "BA Order Header";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTableView = sorting ("Document Type", "Document No.", "Posted Document Type", "Posted Document No.") where ("Document Type" = const ("Service Order"));
    CardPageId = "BA Service Order Ledger";
    Caption = 'Service Order Ledgers';

    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = all;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = all;
                }
                field("Posted Document Type"; Rec."Posted Document Type")
                {
                    ApplicationArea = all;
                }
                field("Posted Document No."; Rec."Posted Document No.")
                {
                    ApplicationArea = all;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = all;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = all;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = all;

                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = all;

                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = all;

                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = all;
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = all;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = all;
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = all;
                }
                field("Quote No."; Rec."Quote No.")
                {
                    ApplicationArea = all;
                }
                field("Deleted"; Rec."Deleted")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Dimensions")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Dimensions;

                trigger OnAction()
                var
                    DimMgt: Codeunit DimensionManagement;
                begin
                    DimMgt.ShowDimensionSet(Rec."Dimension Set ID", STRSUBSTNO('%1 %2', Rec."Document Type", Rec."Document No."));
                end;
            }
        }
    }
}