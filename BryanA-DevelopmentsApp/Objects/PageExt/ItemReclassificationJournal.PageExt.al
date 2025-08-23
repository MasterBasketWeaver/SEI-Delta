pageextension 80165 "BA Item Reclass. Jnl." extends "Item Reclass. Journal"
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
        modify("New Location Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                Subscribers: Codeunit "BA SEI Subscibers";
            begin
                Text := Subscribers.LocationListLookup();
                exit(Text <> '');
            end;
        }
        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                Rec.CalcFields("BA Item Tracking Code");
            end;
        }
        addafter("Item No.")
        {
            field("BA Item Tracking Code"; "BA Item Tracking Code")
            {
                ApplicationArea = all;
            }
        }
        modify("Bin Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                WMSMgt: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                BinCode := WMSMgt.BinContentLookUp(Rec."Location Code", Rec."Item No.", Rec."Variant Code", '', "Bin Code");
                if BinCode <> '' then
                    Rec.Validate("Bin Code", BinCode);
            end;
        }
        modify("New Bin Code")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                WMSMgt: Codeunit "WMS Management";
                BinCode: Code[20];
            begin
                BinCode := WMSMgt.BinContentLookUp(Rec."Location Code", Rec."Item No.", Rec."Variant Code", '', "Bin Code");
                if BinCode <> '' then
                    Rec.Validate("New Bin Code", BinCode);
            end;
        }
    }

    actions
    {
        addafter("Item &Tracking Lines")
        {
            action("BA Update Default Bin Quantities")
            {
                ApplicationArea = all;
                Promoted = true;
                Image = CreateBinContent;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Update Default Bin Quantities';

                trigger OnAction()
                var
                    UpdateItemBins: Report "BA Update Default Bin Qtys";
                begin
                    UpdateItemBins.SetItemJnlLine(Rec);
                    UpdateItemBins.RunModal();
                end;
            }
        }
    }
}