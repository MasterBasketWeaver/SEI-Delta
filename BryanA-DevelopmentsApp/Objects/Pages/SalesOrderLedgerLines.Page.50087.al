page 50087 "BA Sales Order Ledger Lines"
{
    SourceTable = "BA Order Line";
    PageType = ListPart;
    LinksAllowed = false;
    Caption = 'Sales Order Ledger Lines';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = all;
                }
                field("Line No."; Rec."Line No.")
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
                field("Posted Line No."; Rec."Posted Line No.")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = all;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = all;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = all;
                }
                field("New Business - TDG"; Rec."New Business - TDG")
                {
                    ApplicationArea = all;
                }
                field("Booking Date"; Rec."Booking Date")
                {
                    ApplicationArea = all;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = all;
                    TableRelation = "Gen. Product Posting Group";
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = all;
                }
                field("Net Price Avg. (CAD)"; Rec."Net Price Avg. (CAD)")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Net Price Avg. (USD)"; Rec."Net Price Avg. (USD)")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Profit On Price (CAD)"; Rec."Profit On Price (CAD)")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Profit On Price (USD)"; Rec."Profit On Price (USD)")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Total $ On Price (CAD)"; Rec."Total $ On Price (CAD)")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Total $ On Price (USD)"; Rec."Total $ On Price (USD)")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    DecimalPlaces = 0 : 5;
                }
                field("Prior Year Sold"; Rec."Prior Year Sold")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                }
                field("Inflation Factor"; Rec."Inflation Factor")
                {
                    ApplicationArea = all;
                }
                field("Delta %"; Rec."Delta %")
                {
                    ApplicationArea = all;
                }
                field("Deleted"; Rec."Deleted")
                {
                    ApplicationArea = all;
                }
                field("Cancelled"; Rec."Cancelled")
                {
                    ApplicationArea = all;
                }
                field("Omit from POP Report"; Rec."Omit from POP Report")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) or not UserSetup."BA Can Edit Ledger Pages" then
            Error(EditPermErr);
    end;

    var
        EditPermErr: Label 'You do not have permission to edit ledger lines.';
}