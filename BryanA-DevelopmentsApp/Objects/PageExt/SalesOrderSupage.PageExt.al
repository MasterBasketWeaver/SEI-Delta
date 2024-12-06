pageextension 80078 "BA Sales Order Subpage" extends "Sales Order Subform"
{
    layout
    {
        modify("Shortcut Dimension 1 Code")
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        modify("Shortcut Dimension 2 Code")
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        modify(ShortcutDimCode3)
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        modify(ShortcutDimCode4)
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        modify(ShortcutDimCode5)
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        modify(ShortcutDimCode6)
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        modify(ShortcutDimCode7)
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        modify(ShortcutDimCode8)
        {
            ApplicationArea = all;
            Editable = CanEditDimensions;
        }
        addafter("Total Amount Incl. VAT")
        {
            field("BA Exchange Rate"; ExchageRate)
            {
                ApplicationArea = all;
                Editable = false;
                BlankZero = true;
                ToolTip = 'Specifies the exchange rate used to calculate prices for item sales lines.';
                Caption = 'Exchange Rate';
                DecimalPlaces = 2 : 5;
            }
        }
        modify("Location Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                Subscribers: Codeunit "BA SEI Subscibers";
            begin
                Text := Subscribers.LocationListLookup();
                exit(Text <> '');
            end;
        }
        addafter(Description)
        {
            field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
            {
                ApplicationArea = all;
            }
            field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
            {
                ApplicationArea = all;

                trigger OnValidate()
                begin
                    Rec.UpdateUnitPrice(Rec.FieldNo("Gen. Prod. Posting Group"));
                end;
            }
        }
        addlast(Control1)
        {
            field("BA Booking Date"; Rec."BA Booking Date")
            {
                ApplicationArea = all;
                Editable = CanEditBookingDate;
            }
            field("BA New Business - TDG"; Rec."BA New Business - TDG")
            {
                ApplicationArea = all;
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then begin
            CanEditDimensions := UserSetup."BA Can Edit Dimensions";
            CanEditBookingDate := UserSetup."BA Can Edit Booking Dates";
        end;
    end;

    trigger OnAfterGetRecord()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(Rec."Document Type", rec."Document No.") then
            ExchageRate := SalesHeader."BA Quote Exch. Rate";
    end;

    procedure SetExchangeRate(NewExchangeRate: Decimal)
    begin
        ExchageRate := NewExchangeRate;
    end;

    var
        ExchageRate: Decimal;
        [InDataSet]
        CanEditDimensions: Boolean;
        [InDataSet]
        CanEditBookingDate: Boolean;
}