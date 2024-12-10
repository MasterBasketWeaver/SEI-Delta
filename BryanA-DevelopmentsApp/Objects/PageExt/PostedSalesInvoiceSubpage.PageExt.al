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
                Editable = EditableBookingDate;
                Caption = 'Booking Date';

                trigger OnValidate()
                begin
                    Subscribers.UpdateBookingDate(Rec, BookingDate);
                end;
            }
            field("BA New Business - TDG"; NewBusiness)
            {
                ApplicationArea = all;
                Caption = 'New Business - TDG';
                Editable = IsEditable;

                trigger OnValidate()
                begin
                    Subscribers.UpdateNewBusiness(Rec, NewBusiness);
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

    trigger OnAfterGetRecord()

    begin
        BookingDate := Rec."BA Booking Date";
        NewBusiness := Rec."BA New Business - TDG";
        IsEditable := CurrPage.Editable();
        EditableBookingDate := CanEditBookingDate and IsEditable
    end;

    var
        Subscribers: Codeunit "BA SEI Subscibers";
        [InDataSet]
        IsEditable: Boolean;
        [InDataSet]
        CanEditBookingDate: Boolean;
        EditableBookingDate: Boolean;
        BookingDate: Date;
        NewBusiness: Boolean;

}