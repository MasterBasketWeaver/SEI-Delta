pageextension 80099 "BA Service Item WkSht. Subform" extends "Service Item Worksheet Subform"
{
    layout
    {
        addfirst(Control1)
        {
            field("Line No."; Rec."Line No.")
            {
                ApplicationArea = all;
            }

        }
        addlast(Control1)
        {
            field("BA Booking Date"; Rec."BA Booking Date")
            {
                ApplicationArea = all;
                Editable = CanEditBookingDate;
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        CanEditBookingDate := UserSetup.Get(UserId()) and UserSetup."BA Can Edit Booking Dates";
    end;

    var
        [InDataSet]
        CanEditBookingDate: Boolean;
}