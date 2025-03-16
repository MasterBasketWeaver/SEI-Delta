tableextension 80024 "BA User Setup" extends "User Setup"
{
    fields
    {
        field(80000; "BA Job Title"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Job Title';
        }
        field(80001; "BA Allow Changing Counties"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Changing Provinces/States';
        }
        field(80002; "BA Allow Changing Regions"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Changing Regions';
        }
        field(80003; "BA Allow Changing Countries"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Changing Countries';
        }
        field(80004; "BA Receive Job Queue Notes."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Receive Job Queue Notifications';
        }
        field(80005; "BA Can Edit Dimensions"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Edit Dimensions on SQ/SO';
        }
        field(80010; "BA Force Reason Code Entry"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Force Reason Code Entry';
        }
        field(80020; "BA Can Edit Sales Prices"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Edit Sales Prices';
        }
        field(80030; "BA Can Edit Booking Dates"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Edit Booking Dates';
        }
        field(80040; "BA Email SP On Tracking Emails"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Email SP On Tracking Emails';
        }
        field(80060; "BA Receive Prod. Approvals"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Receive Production Approvals';
        }
        field(80065; "BA Allow Changing Pay. Terms"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Changing Payment Terms';
        }
        field(80070; "BA Allow Deleting Orders"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allows Sales/Service Order Deletion';
        }
        field(80099; "BA Service Order Open"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Service Order Open';
            Editable = false;
        }
        field(80100; "BA Open Service Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Open Service Order No.';
            Editable = false;
            TableRelation = "Service Header"."No." where ("Document Type" = const (Order));
        }
        field(80130; "BA Can Create Orders Anytime"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Create Orders Anytime';
        }
        field(80135; "BA Can Deactivate Items"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Deactivate Items';
        }
    }
}