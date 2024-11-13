page 50081 "BA Shipment Email Entries"
{
    Caption = 'Shipment Email Entries';
    SourceTable = "BA Shipment Email Entry";
    PageType = List;
    Editable = false;
    ApplicationArea = all;
    UsageCategory = Lists;
    LinksAllowed = false;

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
                field("Sent DateTime"; Rec."Sent DateTime")
                {
                    ApplicationArea = all;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = all;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = all;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = all;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = all;
                }
                field("Sent-to Email"; Rec."Sent-to Email")
                {
                    ApplicationArea = all;
                }
                field("Package Tracking No."; Rec."Package Tracking No.")
                {
                    ApplicationArea = all;
                }
                field("Package Tracking No. Date"; Rec."Package Tracking No. Date")
                {
                    ApplicationArea = all;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = all;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}