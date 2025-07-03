page 50000 "BA Item Seral No. Labels"
{
    Caption = 'Item Serial No. Labels';
    SourceTable = "BA Item Serial No. Label";
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Administration;
    LinksAllowed = false;
    AutoSplitKey = true;
    SourceTableView = sorting ("Label Order") order(ascending);
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Line)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = all;
                    Visible = false;
                    Editable = false;
                }
                field("Label Order"; "Label Order")
                {
                    ApplicationArea = all;
                    BlankZero = true;
                    ShowMandatory = true;
                }
                field("Label Text"; "Label Text")
                {
                    ApplicationArea = all;
                }
                field(Header; Header)
                {
                    ApplicationArea = all;
                    Caption = 'Divider Line Afterwards';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if ("Label Order" = 0) and BelowxRec then
            SetNextOrderNo();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if BelowxRec then
            SetNextOrderNo();
    end;

    local procedure SetNextOrderNo()
    var
        ItemSerialNoLabel: Record "BA Item Serial No. Label";
    begin
        ItemSerialNoLabel.SetCurrentKey("Label Order");
        ItemSerialNoLabel.SetAscending("Label Order", true);
        if ItemSerialNoLabel.FindLast() then;
        Rec."Label Order" := ItemSerialNoLabel."Label Order" + 100;
    end;
}