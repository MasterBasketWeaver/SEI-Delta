page 50079 "BA Currency FX Index"
{
    ApplicationArea = all;
    UsageCategory = Administration;
    SourceTable = "BA Currency FX Index";
    PageType = List;
    LinksAllowed = false;
    Caption = 'Currency FX Index';

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field(Date; Rec.Date)
                {
                    ApplicationArea = all;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                }
                field("Exchange Rate"; "Exchange Rate")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec.Date = 0D then
            Rec.FieldError(Date);
        Rec.TestField("Currency Code");
    end;
}