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
                Visible = ShowBookingDate;
            }
        }
    }

    var
        [InDataSet]
        ShowBookingDate: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        ShowBookingDate := Rec."Document Type" = Rec."Document Type"::Order;
    end;
}