page 50069 "BA Phys. Invt. Import Errors"
{
    SourceTable = "Name/Value Buffer";
    PageType = List;
    Caption = 'Inventory Import Errors';
    Editable = false;
    LinksAllowed = false;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec.Name)
                {
                    ApplicationArea = all;
                    Caption = 'Item No.';
                    TableRelation = Item."No.";
                }
                field("Line No."; Rec."BA Dmension Set ID")
                {
                    ApplicationArea = all;
                    Caption = 'Journal Line No.';
                    BlankZero = true;

                    trigger OnDrillDown()
                    var
                        ItemJnlLine: Record "Item Journal Line";
                        RecID: RecordId;
                        PhysicalInvJnl: Page "Phys. Inventory Journal";
                        RevaluationJnl: Page "Revaluation Journal";
                    begin
                        if not Evaluate(RecID, Rec."Value") or not ItemJnlLine.Get(RecID) then
                            exit;
                        ItemJnlLine.FilterGroup(2);
                        ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
                        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                        ItemJnlLine.SetRange("Item No.", ItemJnlLine."Item No.");
                        if ItemJnlLine."Journal Template Name" = 'REVALUATIO' then begin
                            RevaluationJnl.SetTableView(ItemJnlLine);
                            ItemJnlLine.FilterGroup(0);
                            RevaluationJnl.RunModal();
                        end else begin
                            PhysicalInvJnl.SetTableView(ItemJnlLine);
                            ItemJnlLine.FilterGroup(0);
                            PhysicalInvJnl.RunModal();
                        end;
                    end;
                }
                field(Error; Rec."Value Long")
                {
                    ApplicationArea = all;
                    Caption = 'Error Message';
                    Style = Unfavorable;
                }
            }
        }
    }

    procedure PopulateRecords(var ItemJnlLine: Record "Item Journal Line")
    begin
        if ItemJnlLine.FindSet() then
            repeat
                Rec.Init();
                Rec.ID := ItemJnlLine."Line No.";
                Rec."BA Dmension Set ID" := ItemJnlLine."Line No.";
                Rec.Name := ItemJnlLine."Item No.";
                Rec.Value := CopyStr(Format(ItemJnlLine.RecordId()), 1, MaxStrLen(Rec.Value));
                Rec."Value Long" := ItemJnlLine."BA Warning Message";
                Rec.Insert(false);
            until ItemJnlLine.Next() = 0;
    end;
}