pageextension 80087 "BA Phys. Inventory Jnl." extends "Phys. Inventory Journal"
{
    layout
    {
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
        modify("Bin Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                WMSMgt: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                BinCode := WMSMgt.BinContentLookUp(Rec."Location Code", Rec."No.", Rec."Variant Code", '', "Bin Code");
                if BinCode <> '' then
                    Rec.Validate("Bin Code", BinCode);
            end;
        }
        addfirst(Control1)
        {
            field("Line No."; Rec."Line No.")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field("BA Warning Message"; Rec."BA Warning Message")
            {
                ApplicationArea = all;
                Style = Unfavorable;
                Editable = false;
            }
        }
        addafter(Description)
        {
            field("BA Updated"; Rec."BA Updated")
            {
                ApplicationArea = all;
                Caption = 'Year-End Inventory Adjustment';
                Editable = true;
            }
            field("BA Cycle Count"; Rec."BA Cycle Count")
            {
                ApplicationArea = all;
            }
        }
        addlast(Control1)
        {
            field("BA Unit Cost (Revalued)"; Rec."Unit Cost (Revalued)")
            {
                ApplicationArea = all;
            }
            field("Inventory Value (Revalued)"; Rec."Inventory Value (Revalued)")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("BA Update Posting Date")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = ChangeDates;
                Caption = 'Update Posting Date';

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                    DateLookup: Page "BA Date Lookup";
                    Window: Dialog;
                    NewDate: Date;
                    RecCount: Integer;
                    i: Integer;
                begin
                    ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    if not ItemJnlLine.FindSet() then
                        exit;
                    if (DateLookup.RunModal() <> Action::Yes) then
                        exit;
                    NewDate := DateLookup.GetDate();
                    RecCount := ItemJnlLine.Count();
                    Window.Open(DateDialog);
                    repeat
                        i += 1;
                        Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
                        ItemJnlLine.Validate("Posting Date", NewDate);
                        ItemJnlLine.Modify(true);
                    until ItemJnlLine.Next() = 0;
                    Window.Close();
                    CurrPage.Update(false);
                end;
            }
            action("BA Import Item Inventory")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = PhysicalInventory;
                Caption = 'Import Item Inventory';

                trigger OnAction()
                var
                    ImportInventory: Report "BA Physical Inventory Import";
                begin
                    ImportInventory.SetParameters(Rec, false);
                    ImportInventory.RunModal();
                end;
            }
            action("BA View Import Errors")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = PhysicalInventoryLedger;
                Caption = 'View Inv. Import Msg/Errors';

                trigger OnAction()
                var
                    NameBuffer: Record "Name/Value Buffer" temporary;
                    ItemJnlLine: Record "Item Journal Line";
                    ErrorPage: Page "BA Phys. Invt. Import Errors";
                begin
                    ItemJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    ItemJnlLine.SetFilter("BA Warning Message", '<>%1', '');
                    ErrorPage.PopulateRecords(ItemJnlLine);
                    ErrorPage.RunModal();
                end;
            }
        }
        addafter(CalculateInventory)
        {
            action("BA Reset Blocked Items")
            {
                ApplicationArea = all;
                Promoted = true;
                Image = Restore;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Reset Blocked Items';
                ToolTip = 'Re-blocks any items that were unblocked during the Calculate Inventory action.';

                trigger OnAction()
                var
                    BlockedItem: Record "BA Blocked Item";
                    Subscribers: Codeunit "BA SEI Subscibers";
                    Window: Dialog;
                    RecCount: Integer;
                begin
                    RecCount := BlockedItem.Count();
                    if RecCount <> 0 then begin
                        Window.Open('Reseting blocked items...');
                        Subscribers.ResetBlockedItems();
                        Window.Close();
                        Message('Reset %1 blocked items.', RecCount);
                    end else
                        Message('No blocked Items to reset');
                end;
            }
        }
    }

    var
        DateDialog: Label 'Updating\#1##';
}