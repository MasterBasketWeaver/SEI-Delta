pageextension 80201 "BA Production Journal" extends "Production Journal"
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
    }

    actions
    {
        addlast(Processing)
        {
            action("BA Update to Default Bins")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Update to Default Bins';
                Image = CreateBinContent;

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
                        BinContent.SetRange("Item No.", ItemJournalLine."Item No.");
                        BinContent.SetRange("Location Code", ItemJournalLine."Location Code");
                        if BinContent.FindFirst() then
                            if ItemJournalLine."Bin Code" <> BinContent."Bin Code" then begin
                                ItemJournalLine.Validate("Bin Code", BinContent."Bin Code");
                                ItemJournalLine.Modify(true);
                                UpdateCount += 1;
                            end;
                    until ItemJournalLine.Next() = 0;
                    CurrPage.Update(false);
                    if UpdateCount = 1 then
                        Message(SingleUpdateMsg)
                    else
                        Message(MultiUpdateMsg, UpdateCount);
                end;
            }
        }
        addlast("Pro&d. Order")
        {
            action("BA Item Card")
            {
                ApplicationArea = all;
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = field ("Item No.");
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Item Card';
            }
            action("BA Item Ledger Entries")
            {
                ApplicationArea = all;
                Image = ItemLedger;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Item Ledger Entries';

                trigger OnAction()
                var
                    ItemLedgerEntry: Record "Item Ledger Entry";
                begin
                    ItemLedgerEntry.SetCurrentKey("Item No.");
                    ItemLedgerEntry.SetRange("Item No.", Rec."Item No.");
                    Page.Run(Page::"Item Ledger Entries", ItemLedgerEntry);
                end;
            }
        }
    }


    var
        SingleUpdateMsg: Label 'Updated 1 line with default bin code.';
        MultiUpdateMsg: Label 'Updated %1 lines with default bin code.';
}