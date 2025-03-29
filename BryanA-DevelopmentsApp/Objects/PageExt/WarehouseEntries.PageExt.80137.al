pageextension 80188 "BA Warehouse Entries" extends "Warehouse Entries"
{

    actions
    {
        addlast(Processing)
        {
            action("BA Import Serial Nos.")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = SerialNoProperties;

                trigger OnAction()
                var
                    Subscribers: Codeunit "BA SEI Subscibers";
                begin
                    Subscribers.ImportWhseEntrySerialNos();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetView('sorting ("Entry No.") order(descending)');
    end;


}