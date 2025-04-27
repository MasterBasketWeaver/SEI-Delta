pageextension 80201 "BA Production Journal" extends "Production Journal"
{
    actions
    {
        addlast("&Line")
        {
            action("BA Update to Default Bins")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Update to Default Bins';

                trigger OnAction()
                var
                    BinContent: Record "Bin Content";
                    ItemJournalLine: Record "Item Journal Line";
                    UpdateCount: Integer;
                begin
                    if '' in [Rec."Journal Template Name", Rec."Journal Batch Name"] then
                        exit;
                    ItemJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    ItemJournalLine.SetFilter("Item No.", '<>%1', '');
                    if not ItemJournalLine.FindSet() then
                        exit;
                    BinContent.SetRange(Default, true);
                    BinContent.SetFilter("Bin Code", '<>%1', '');
                    repeat
                        BinContent.SetRange("Item No.", ItemJournalLine."Bin Code");
                        BinContent.SetRange("Location Code", ItemJournalLine."Location Code");
                        if BinContent.FindFirst() and (ItemJournalLine."Bin Code" <> BinContent."Bin Code") then begin
                            ItemJournalLine.Validate("Bin Code", BinContent."Bin Code");
                            ItemJournalLine.Modify(true);
                            UpdateCount += 1;
                        end;
                    until ItemJournalLine.Next() = 0;
                    CurrPage.Update(false);
                    Message('Updated %1 line(s) with default bin code.');
                end;
            }
        }
    }
}