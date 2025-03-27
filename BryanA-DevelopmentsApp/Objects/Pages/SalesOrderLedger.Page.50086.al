page 50086 "BA Sales Order Ledger"
{
    SourceTable = "BA Order Header";
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    Caption = 'Sales Order Ledger';

    layout
    {
        area(Content)
        {
            group(General)
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
            part(Lines; "BA Order Ledger Lines")
            {
                SubPageLink = "Document Type" = field ("Document Type"), "Document No." = field ("Document No.");
                Caption = 'Sales Order Ledger Lines';
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