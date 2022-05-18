tableextension 80020 "BA Location" extends Location
{
    fields
    {
        field(80000; "BA FID No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'FID No.';
        }
    }
}