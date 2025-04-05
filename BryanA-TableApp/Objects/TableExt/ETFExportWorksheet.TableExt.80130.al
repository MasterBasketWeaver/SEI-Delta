tableextension 80130 "BA Export Workset" extends "EFT Export Workset"
{
    fields
    {
        field(80000; "BA Detail Record Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Detail Record Count';
            Editable = false;
        }
    }
}