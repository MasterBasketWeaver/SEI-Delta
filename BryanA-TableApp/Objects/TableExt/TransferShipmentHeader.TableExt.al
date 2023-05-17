tableextension 80023 "BA Transfer Shpt. Header" extends "Transfer Shipment Header"
{
    fields
    {
        field(80000; "BA Transfer-To FID No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'FID No.';
            Editable = false;
        }
        field(80001; "BA Transfer-To Phone No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Phone No.';
            Editable = false;
        }
        field(80030; "BA Trans. Order No. DrillDown"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer Order No.';
            Description = 'Used for Lookup DropDown';
            Editable = false;
        }
        field(80032; "BA Freight Carrier Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Carrier Name';
            Editable = false;
        }
        field(80033; "BA Freight Term Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Term Name';
            Editable = false;
        }
        field(80034; "BA Posting Date DrillDown"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
            Description = 'Used for Lookup DropDown';
            Editable = false;
        }
    }

    fieldgroups
    {
        addlast(DropDown; "BA Trans. Order No. DrillDown", "BA Posting Date DrillDown", "Transfer-to Name", "BA Freight Carrier Name", "BA Freight Term Name", "ENC Package Tracking No.", "ENC Physical Ship Date") { }
    }
}