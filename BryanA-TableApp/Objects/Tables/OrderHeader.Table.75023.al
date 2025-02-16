table 75023 "BA Order Header"
{
    fields
    {
        field(1; "Document Type"; Enum "BA Order Document Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
            Editable = false;
            TableRelation = if ("Document Type" = const ("Sales Order")) "Sales Header"."No." where ("Document Type" = const (Order))
            else
            if ("Document Type" = const ("Service Order")) "Service Header"."No." where ("Document Type" = const (Order));
        }
        field(3; "Posted Document Type"; Enum "BA Posted Document Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Posted Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = if ("Posted Document Type" = const ("Posted Sales Invoice")) "Sales Invoice Header"."No."
            else
            if ("Posted Document Type" = const ("Posted Service Invoice")) "Service Invoice Header"."No.";
        }
        field(10; "Order Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series".Code;
        }
        field(14; "Salesperson Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(15; "Sell-to Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Customer."No.";
        }
        field(16; "Sell-to Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Customer Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Customer Posting Group".Code;
        }
        field(18; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Currency.Code;
        }
        field(19; "Currency Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Quote No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = if ("Document Type" = const ("Sales Order")) "Sales Header"."No." where ("Document Type" = const (Quote))
            else
            if ("Document Type" = const ("Service Order")) "Service Header"."No." where ("Document Type" = const (Quote));
        }
        field(21; "Dimension Set ID"; Integer)
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
    }

    keys
    {
        key(PK; "Document Type", "Document No.", "Posted Document Type", "Posted Document No.")
        {
            Clustered = true;
        }
    }
}
