pageextension 80019 "BA Purch. Ret. Order Subpage" extends "Purchase Return Order Subform"
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
        modify("Direct Unit Cost")
        {
            ApplicationArea = all;
            Visible = not "BA Requisition Order";
        }
        modify("Line Discount Amount")
        {
            ApplicationArea = all;
            Visible = not "BA Requisition Order";
        }

        modify("Line Discount %")
        {
            ApplicationArea = all;
            Visible = not "BA Requisition Order";
        }
        addafter(Quantity)
        {
            field("Direct Unit Cost2"; Rec."Direct Unit Cost")
            {
                ApplicationArea = all;
                Visible = "BA Requisition Order";
            }
            field("Line Discount %2"; Rec."Line Discount %")
            {
                ApplicationArea = all;
                Visible = "BA Requisition Order";
            }

            field("Line Discount Amount2"; Rec."Line Discount Amount")
            {
                ApplicationArea = all;
                Visible = "BA Requisition Order";
            }
        }
        addafter(ShortcutDimCode4)
        {
            field("BA Sales Person Code"; SalesPersonCode)
            {
                ApplicationArea = all;
                TableRelation = "Dimension Value".Code where ("Dimension Code" = field ("BA Salesperson Filter Code"), "ENC Inactive" = const (false));
                Caption = 'Sales Person Code';

                trigger OnValidate()
                begin
                    ValidateShortcutDimCode(5, SalesPersonCode);
                end;
            }
        }
        addlast(Control1)
        {
            field("BA Product ID Code"; Rec."BA Product ID Code")
            {
                ApplicationArea = all;
                Editable = "No." <> '';
            }
            field("BA Project Code"; Rec."BA Project Code")
            {
                ApplicationArea = all;
                Editable = "No." <> '';
            }
            field("BA Shareholder Code"; Rec."BA Shareholder Code")
            {
                ApplicationArea = all;
                Editable = "No." <> '';
            }
            field("BA Capex Code"; Rec."BA Capex Code")
            {
                ApplicationArea = all;
                Editable = "No." <> '';
            }
        }
    }

    actions
    {
        modify(Dimensions)
        {
            trigger OnAfterAction()
            begin
                Rec.GetDimensionCodes(GLSetup, SalesPersonCode);
            end;
        }
    }

    trigger OnAfterGetRecord()
    var
        TempDimSet: Record "Dimension Set Entry" temporary;
    begin
        SalesPersonCode := '';
        DimMgt.GetDimensionSet(TempDimSet, Rec."Dimension Set ID");
        TempDimSet.SetRange("Dimension Code", GLSetup."ENC Salesperson Dim. Code");
        if TempDimSet.FindFirst then
            SalesPersonCode := TempDimSet."Dimension Value Code";
        Rec."BA Salesperson Filter Code" := GLSetup."ENC Salesperson Dim. Code";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SalesPersonCode := '';
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."BA Salesperson Filter Code" := GLSetup."ENC Salesperson Dim. Code";
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec."BA Salesperson Filter Code" := GLSetup."ENC Salesperson Dim. Code";
    end;

    trigger OnOpenPage()
    begin
        GLSetup.Get;
        GLSetup.TestField("ENC Salesperson Dim. Code");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit DimensionManagement;
        SalesPersonCode: Code[20];
}