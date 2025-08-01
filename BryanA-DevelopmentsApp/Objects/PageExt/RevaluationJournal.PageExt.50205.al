pageextension 50205 "BA Revaluation Journal" extends "Revaluation Journal"
{
    actions
    {
        addlast(Processing)
        {
            action("BA Import Item Revaluations")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CreateInventoryPickup;
                Caption = 'Import Item Revaluations';

                trigger OnAction()
                var
                    ImportInventory: Report "BA Physical Inventory Import";
                begin
                    ImportInventory.SetParameters(Rec, true);
                    ImportInventory.RunModal();
                end;
            }
        }
    }
}