pageextension 80145 "BA Posted Sales Inv. Subpage" extends "Posted Sales Invoice Subform"
{
    Editable = true;

    layout
    {
        addfirst(Control1)
        {
            field("BA Omit from Reports"; Rec."BA Omit from Reports")
            {
                ApplicationArea = all;
            }
        }
        addbefore(Quantity)
        {
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = all;
            }
        }
        addlast(Control1)
        {
            field("BA Booking Date"; BookingDate)
            {
                ApplicationArea = all;
                Editable = CanEditBookingDate;
                Caption = 'Booking Date';

                trigger OnValidate()
                begin
                    Subscribers.UpdateBookingDate(Rec, BookingDate);
                end;
            }
        }
    }

    actions
    {
        addlast("&Line")
        {
            action("Omit Selected Lines")
            {
                ApplicationArea = all;
                Image = MakeOrder;

                trigger OnAction()
                var
                    SalesInvLine: Record "Sales Invoice Line";
                    UpdatedPostedLines: Report "BA Updated Posted Lines";
                begin
                    CurrPage.SetSelectionFilter(SalesInvLine);
                    UpdatedPostedLines.SalesInvoiceLines(SalesInvLine);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        CanEditBookingDate := UserSetup.Get(UserId()) and UserSetup."BA Can Edit Booking Dates";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        BookingDate := Rec."BA Booking Date";
    end;

    var
        Subscribers: Codeunit "BA SEI Subscibers";
        [InDataSet]
        CanEditBookingDate: Boolean;
        BookingDate: Date;

}