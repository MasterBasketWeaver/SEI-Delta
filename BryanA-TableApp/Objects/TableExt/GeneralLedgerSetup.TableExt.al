tableextension 80097 "BA General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(80000; "BA Region Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Region Code';
            TableRelation = Dimension.Code where (Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(80001; "BA Country Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Country Code';
            TableRelation = Dimension.Code where (Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(80002; "BA Shareholder Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shareholder Code';
            TableRelation = Dimension.Code where (Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(80003; "BA Capex Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Capex Code';
            TableRelation = Dimension.Code where (Blocked = const (false), "ENC Inactive" = const (false));
        }
    }
}