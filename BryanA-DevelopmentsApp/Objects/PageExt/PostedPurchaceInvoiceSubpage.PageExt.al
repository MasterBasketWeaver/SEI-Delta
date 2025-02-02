pageextension 80096 "BA Posted Purch. Inv. Subpage" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("BA Product ID Code"; Rec."BA Product ID Code")
            {
                ApplicationArea = all;
            }
            field("BA Project Code"; Rec."BA Project Code")
            {
                ApplicationArea = all;
            }
            field("BA Shareholder Code"; "BA Shareholder Code")
            {
                ApplicationArea = all;
            }
            field("BA Capex Code"; Rec."BA Capex Code")
            {
                ApplicationArea = all;
            }
        }
        addbefore("Job No.")
        {
            field("BA SEI Order Type."; Rec."BA SEI Order Type")
            {
                ApplicationArea = all;
            }
            field("BA SEI Order No."; Rec."BA SEI Order No.")
            {
                ApplicationArea = all;
            }
            field("BA SEI Invoice No."; Rec."BA SEI Invoice No.")
            {
                ApplicationArea = all;
            }
            field("BA Freight Charge Type"; Rec."BA Freight Charge Type")
            {
                ApplicationArea = all;
            }
        }
        modify(Type)
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("No.")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify(Description)
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify(Quantity)
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Unit of Measure")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Unit Cost (LCY)")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Unit Price (LCY)")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Direct Unit Cost")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Tax Area Code")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Tax Group Code")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Tax Liable")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Provincial Tax Area Code")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Use Tax")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Line Amount")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Line Discount %")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Line Discount Amount")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Job No.")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Job Task No.")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Shortcut Dimension 1 Code")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Shortcut Dimension 2 Code")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("ShortcutDimCode[3]")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("ShortcutDimCode[4]")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("ShortcutDimCode[5]")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("ShortcutDimCode[6]")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("ShortcutDimCode[7]")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("ShortcutDimCode[8]")
        {
            ApplicationArea = all;
            Editable = false;
        }
        modify("Deferral Code")
        {
            ApplicationArea = all;
            Editable = false;
        }
    }
}