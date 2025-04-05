tableextension 80010 "BA Purch. Rcpt. Line" extends "Purch. Rcpt. Line"
{
    fields
    {
        field(80001; "BA Requisition Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Requisition Order';
            Editable = false;
            Description = 'System field to specify Requisition Orders';
        }
        field(80005; "BA Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Amount Excl. Tax';
            Editable = false;
        }
        field(80006; "BA Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Discount Amount';
            Editable = false;
        }
        field(80050; "BA SEI Order Type"; Enum "BA SEI Order Type")
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Order Type';
        }
        field(80051; "BA SEI Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Order No.';
            TableRelation = if ("BA SEI Order Type" = filter ("Delta SO")) "Sales Invoice Header"."Order No." where ("Bill-to Customer No." = filter ('<>SEILAB'))
            else
            if ("BA SEI Order Type" = filter ("Int. SO")) "Sales Invoice Header"."External Document No." where ("Bill-to Customer No." = const ('SEILAB'))
            else
            if ("BA SEI Order Type" = filter ("Delta SVO")) "Service Invoice Header"."Order No." where ("Bill-to Customer No." = filter ('<>SEILAB'))
            else
            if ("BA SEI Order Type" = filter ("Int. SVO")) "Service Invoice Header"."ENC External Document No." where ("Bill-to Customer No." = const ('SEILAB'))
            else
            if ("BA SEI Order Type" = const (Transfer)) "Transfer Shipment Header"."Transfer Order No.";
        }
        field(80052; "BA Freight Charge Type"; Enum "BA Freight Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Charge Type';
        }
        field(80053; "BA SEI Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Invoice No.';
            Editable = false;
        }
        field(80100; "BA Product ID Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Product ID Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('PRODUCT ID'), Blocked = const (false), "ENC Inactive" = const (false));
            Editable = false;
        }
        field(80101; "BA Project Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Project Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('PROJECT'), Blocked = const (false), "ENC Inactive" = const (false));
            Editable = false;
        }
        field(80102; "BA Shareholder Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shareholder Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('SHAREHOLDER'), Blocked = const (false), "ENC Inactive" = const (false));
            Editable = false;
        }
        field(80103; "BA Capex Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Capex Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('CAPEX'), Blocked = const (false), "ENC Inactive" = const (false));
            Editable = false;
        }
    }
}