table 50003 "BA Commission Rate"
{
    DataClassification = CustomerContent;
    Caption = 'Commission Rate';

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; Rate; Decimal)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
        }
        field(4; "Salesperson Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(5; "Gen. Prod. Posting Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group".Code;
            Caption = 'Gen. Product Posting Group Code';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; Code, Rate, "Salesperson Code", "Gen. Prod. Posting Group Code", Description) { }
        fieldgroup(DropDown; Code, Rate, "Salesperson Code", "Gen. Prod. Posting Group Code", Description) { }
    }
}