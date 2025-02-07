tableextension 80011 "BA Purch. Inv. Line" extends "Purch. Inv. Line"
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