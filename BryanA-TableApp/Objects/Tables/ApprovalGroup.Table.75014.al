table 75014 "BA Approval Group"
{
    DataClassification = CustomerContent;
    Caption = 'Approval Group';

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Overdue Date Formula"; DateFormula)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Is Military"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Is Government"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Is Trusted Agent"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Is Prepaid"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}