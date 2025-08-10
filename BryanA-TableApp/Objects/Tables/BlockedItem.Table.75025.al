table 75025 "BA Blocked Item"
{
    fields
    {
        field(1; "Item No."; Code[20])
        {
            NotBlank = true;
            TableRelation = Item."No.";
            Editable = false;
        }
        field(2; "Blocked At"; DateTime)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
        }
    }
}