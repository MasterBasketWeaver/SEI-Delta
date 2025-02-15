tableextension 80136 "BA Repair Status" extends "Repair Status"
{
    fields
    {
        field(80000; "BA Salesperson Verification"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Salesperson Verification';
        }
    }
}