tableextension 80083 "BA Service Cr.Memo Line" extends "Service Cr.Memo Line"
{
    fields
    {
        field(80010; "BA Omit from Reports"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Omit From Reports';
        }
        field(80080; "BA Labour Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Labour Cost';
            Editable = false;
        }
        field(80081; "BA Material Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Material Cost';
            Editable = false;
        }
    }
}