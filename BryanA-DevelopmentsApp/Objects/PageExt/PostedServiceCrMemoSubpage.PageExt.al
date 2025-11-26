pageextension 80148 "BA P. Service Cr.Memo Subpage" extends "Posted Serv. Cr. Memo Subform"
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
                    ServiceCrMemoLine: Record "Service Cr.Memo Line";
                    UpdatedPostedLines: Report "BA Updated Posted Lines";
                begin
                    CurrPage.SetSelectionFilter(ServiceCrMemoLine);
                    UpdatedPostedLines.ServiceCrMemoLines(ServiceCrMemoLine);
                end;
            }
        }
    }
}