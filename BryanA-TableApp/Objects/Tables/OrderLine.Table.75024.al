table 75024 "BA Order Line"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Document Type"; Enum "BA Order Document Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            Editable = false;
            TableRelation = if ("Document Type" = const ("Sales Order")) "Sales Header"."No." where ("Document Type" = const (Order))
            else
            if ("Document Type" = const ("Service Order")) "Service Header"."No." where ("Document Type" = const (Order));
        }
        field(4; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Posted Document Type"; Enum "BA Posted Document Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Posted Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = if ("Posted Document Type" = const ("Posted Sales Invoice")) "Sales Invoice Header"."No."
            else
            if ("Posted Document Type" = const ("Posted Service Invoice")) "Service Invoice Header"."No.";
        }
        field(7; "Posted Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Type"; Enum "BA Order Line Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Gen. Prod. Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Gen. Product Posting Group";
        }
        field(13; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Description 2"; Text[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Unit of Measure".Code;
        }
        field(17; "New Business - TDG"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Booking Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Unit Cost (LCY)"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(23; "Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(24; "Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "Net Price Avg. (CAD)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(26; "Net Price Avg. (USD)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(27; "Profit On Price (CAD)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(28; "Profit On Price (USD)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(29; "Total $ On Price (CAD)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(30; "Total $ On Price (USD)"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(31; "Prior Year Sold"; Integer)
        {
            DataClassification = CustomerContent;
            MinValue = 1900;
        }
        field(32; "Inflation Factor"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(33; "Delta %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50; "Deleted"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "Cancelled"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(52; "Omit from POP Report"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K2; "Document Type", "Document No.", "Line No.", "Posted Document Type", "Posted Document No.", "Posted Line No.") { }
        key(K3; "Document Type", "Document No.", "Line No.") { }
        key(K4; "Posted Document Type", "Posted Document No.", "Posted Line No.") { }
    }
}
