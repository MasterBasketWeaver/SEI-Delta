table 75015 "BA Adjustment Reason"
{
    DataClassification = CustomerContent;
    Caption = 'Adjumst Reasons';

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(k1; Code)
        {
            Clustered = true;
        }
    }
}