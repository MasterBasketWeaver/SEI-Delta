table 75020 "BA Shipment Email Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Shipment Email Entry';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Sent DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = if ("Document Type" = const ("Sales Invoice")) "Sales Invoice Header"."No." else
            if ("Document Type" = const ("Service Invoice")) "Service Invoice Header"."No.";
        }
        field(4; "Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Customer."No.";
        }
        field(6; "Sent-to Email"; Text[250])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Package Tracking No."; Text[30])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Package Tracking No. Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Package Tracking No. Last Modified';
        }
        field(10; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Editable = false;
            OptionMembers = "Sales Invoice","Service Invoice";
            OptionCaption = 'Sales Invoice,Service Invoice';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(K2; "Sent DateTime")
        {

        }
        key(K3; "Order No.", "Invoice No.", "Package Tracking No.")
        {

        }
        key(K4; "User ID")
        {

        }
    }
}