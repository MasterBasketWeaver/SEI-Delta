pageextension 80120 "BA Sales Quotes" extends "Sales Quotes"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Sales Source"; Rec."BA Sales Source")
            {
                ApplicationArea = all;
            }
            field("BA Web Lead Date"; Rec."BA Web Lead Date")
            {
                ApplicationArea = all;
            }
            field("BA SEI Int'l Ref. No."; Rec."BA SEI Int'l Ref. No.")
            {
                ApplicationArea = all;
            }
            field("BA Quote Date"; Rec."BA Quote Date")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("BA Delete Sales Quotes")
            {
                ApplicationArea = all;
                Image = DeleteAllBreakpoints;
                Caption = 'Delete Sales Quotes';
                Visible = IsBryan;
                Enabled = IsBryan;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.ImportSalesQuoteListToRemove();
                end;
            }
        }
    }


    trigger OnOpenPage()
    begin
        IsBryan := UserId = 'SEI-IND\BRYANBCDEV';
    end;

    var
        [InDataSet]
        IsBryan: Boolean;
}
