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
    }

    actions
    {
        addafter("Item &Tracking Lines")
        {
            action("BA Update Item Bin Quantities")
            {
                ApplicationArea = all;
                Promoted = true;
                Image = CreateBinContent;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Update Item Bin Quantities';

                trigger OnAction()
                var
                    UpdateItemBins: Report "BA Update Item Bins";
                begin
                    UpdateItemBins.SetItemJnlLine(Rec);
                    UpdateItemBins.RunModal();
                end;
            }
        }
    }
}