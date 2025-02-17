tableextension 80095 "BA Company Info" extends "Company Information"
{
    fields
    {
        field(80000; "BA Populated Dimensions"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Populated Dimensions';
            Description = 'Used by install codeunit to prevent AddNewDimValues() function from running mulitple times.';
            Editable = false;
        }
        field(80010; "BA Ship-To Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-To Email';
            ExtendedDatatype = EMail;
        }
        field(80011; "BA Ship-To Phone No."; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-To Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(80020; "BA Accounting AR Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Accounting AR Email';
            ExtendedDatatype = EMail;
        }
        field(80025; "BA Purchasing Email"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchasing Email';
            ExtendedDatatype = EMail;
        }
        modify("E-Mail")
        {
            Caption = 'Sales Email';
        }
    }
}