pageextension 80146 "BA P. Sales Cr.Memo Subpage" extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addfirst(Control1)
        {
            field("BA Omit from Reports"; Rec."BA Omit from Reports")
            {
                ApplicationArea = all;
            }
        }
        addbefore(Quantity)
        {
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = all;
            }
        }
        addafter("Unit Cost (LCY)")
        {
            field("BA Labour Cost"; Rec."BA Labour Cost")
            {
                ApplicationArea = all;
                BlankZero = true;
                HideValue = Type <> Type::Item;
            }
            field("BA Material Cost"; Rec."BA Material Cost")
            {
                ApplicationArea = all;
                BlankZero = true;
                HideValue = Type <> Type::Item;
            }
        }
        modify("Unit Cost (LCY)")
        {
            ApplicationArea = all;
            BlankZero = true;
            HideValue = Type <> Type::Item;
        }
    }

    actions
    {
        addlast("&Line")
        {
            action("Omit Selected Lines")
            {
                ApplicationArea = all;
                Image = MakeOrder;

                trigger OnAction()
                var
                    SalesCrMemoLine: Record "Sales Cr.Memo Line";
                    UpdatedPostedLines: Report "BA Updated Posted Lines";
                begin
                    CurrPage.SetSelectionFilter(SalesCrMemoLine);
                    UpdatedPostedLines.SalesCrMemoLines(SalesCrMemoLine);
                end;
            }
        }
    }
}