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
            DecimalPlaces = 2 : 5;
        }
        field(21; "Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2 : 5;
        }
        field(22; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2 : 5;
        }
        field(23; "Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 2 : 5;
        }
        field(24; "Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "Net Price Avg. (CAD)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(26; "Net Price Avg. (USD)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(27; "Profit On Price (CAD)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(28; "Profit On Price (USD)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(29; "Total $ On Price (CAD)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(30; "Total $ On Price (USD)"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
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
        field(34; "Line Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(35; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Dimension Set Entry";
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
        field(52; "Posting Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Order Header"."Posting Date"
                where ("Document Type" = field ("Document Type"), "Document No." = field ("Document No."),
                "Posted Document Type" = field ("Posted Document Type"), "Posted Document No." = field ("Posted Document No.")));
            Editable = false;
        }
        field(53; "Order Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Order Header"."Order Date"
                where ("Document Type" = field ("Document Type"), "Document No." = field ("Document No."),
                "Posted Document Type" = field ("Posted Document Type"), "Posted Document No." = field ("Posted Document No.")));
            Editable = false;
        }
        field(54; "Sell-to Customer No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Order Header"."Sell-to Customer No."
                where ("Document Type" = field ("Document Type"), "Document No." = field ("Document No."),
                "Posted Document Type" = field ("Posted Document Type"), "Posted Document No." = field ("Posted Document No.")));
            TableRelation = Customer."No.";
        }
        field(55; "Sell-to Customer Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Order Header"."Sell-to Customer Name"
                where ("Document Type" = field ("Document Type"), "Document No." = field ("Document No."),
                "Posted Document Type" = field ("Posted Document Type"), "Posted Document No." = field ("Posted Document No.")));
            Editable = false;
        }
        field(56; "Currency Code"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Order Header"."Currency Code"
                where ("Document Type" = field ("Document Type"), "Document No." = field ("Document No."),
                "Posted Document Type" = field ("Posted Document Type"), "Posted Document No." = field ("Posted Document No.")));
            Editable = false;
            TableRelation = Currency.Code;
        }
        field(57; "Currency Factor"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Order Header"."Currency Factor"
                where ("Document Type" = field ("Document Type"), "Document No." = field ("Document No."),
                "Posted Document Type" = field ("Posted Document Type"), "Posted Document No." = field ("Posted Document No.")));
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
