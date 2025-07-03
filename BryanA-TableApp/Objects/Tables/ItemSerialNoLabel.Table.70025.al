table 50009 "BA Item Serial No. Label"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Label Text"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Label Order"; Integer)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(4; "Header"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K2; "Label Order") { }
    }
}