pageextension 80147 "BA Posted Service Inv. Subpage" extends "Posted Service Invoice Subform"
{
    Editable = true;

    layout
    {
        modify(Type)
        {
            Editable = false;
        }
        modify("No.")
        {
            Editable = false;
        }
        modify("Variant Code")
        {
            Editable = false;
        }
        modify(Description)
        {
            Editable = false;
        }
        modify("Return Reason Code")
        {
            Editable = false;
        }
        modify(Quantity)
        {
            Editable = false;
        }
        modify("Unit of Measure")
        {
            Editable = false;
        }
        modify("Unit of Measure Code")
        {
            Editable = false;
        }
        modify("Unit Cost (LCY)")
        {
            Editable = false;
        }
        modify("Unit Price")
        {
            Editable = false;
        }
        modify("Tax Liable")
        {
            Editable = false;
        }
        modify("Tax Area Code")
        {
            Editable = false;
        }
        modify("Tax Group Code")
        {
            Editable = false;
        }
        modify("Line Discount %")
        {
            Editable = false;
        }
        modify("Line Amount")
        {
            Editable = false;
        }
        modify("Line Discount Amount")
        {
            Editable = false;
        }
        modify("Appl.-to Item Entry")
        {
            Editable = false;
        }
        modify("Service Item No.")
        {
            Editable = false;
        }
        modify("Shortcut Dimension 1 Code")
        {
            Editable = false;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Editable = false;
        }
        modify("ShortcutDimCode[3]")
        {
            Editable = false;
        }
        modify("ShortcutDimCode[4]")
        {
            Editable = false;
        }
        modify("ShortcutDimCode[5]")
        {
            Editable = false;
        }
        modify("ShortcutDimCode[6]")
        {
            Editable = false;
        }
        modify("ShortcutDimCode[7]")
        {
            Editable = false;
        }
        modify("ShortcutDimCode[8]")
        {
            Editable = false;
        }

        addfirst(Control1)
        {
            field("BA Omit from Reports"; Rec."BA Omit from Reports")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BA Omit from POP Report"; OmitFromPOPReport)
            {
                ApplicationArea = all;
                Caption = 'Omit from POP Report';
                Editable = IsEditable;

                trigger OnValidate()
                begin
                    Subscribers.UpdateOmitFromPOPReport(Rec, OmitFromPOPReport);
                end;
            }
        }
        addlast(Control1)
        {
            field("BA Booking Date"; "BA Booking Date")
            {
                ApplicationArea = all;
                Editable = CanEditBookingDate;
            }
            field("BA Order Entry No."; Rec."BA Order Entry No.")
            {
                ApplicationArea = all;
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
                    ServiceInvLine: Record "Service Invoice Line";
                    UpdatedPostedLines: Report "BA Updated Posted Lines";
                begin
                    CurrPage.SetSelectionFilter(ServiceInvLine);
                    UpdatedPostedLines.ServiceInvoiceLines(ServiceInvLine);
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
        OmitFromPOPReport := Rec."BA Omit from POP Report";
        IsEditable := CurrPage.Editable();
        Rec.CalcFields("BA Order Entry No.");
    end;


    var
        Subscribers: Codeunit "BA SEI Subscibers";
        [InDataSet]
        IsEditable: Boolean;
        [InDataSet]
        CanEditBookingDate: Boolean;
        OmitFromPOPReport: Boolean;
}