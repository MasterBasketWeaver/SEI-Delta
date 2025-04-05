pageextension 80001 "BA Purch. Inv. Subpage" extends "Purch. Invoice Subform"
{
    layout
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                if (xRec."No." = Rec."No.") or (Rec."No." <> '') then
                    exit;
                Rec.Validate("BA SEI Order Type", Rec."BA SEI Order Type"::" ");
                Rec.Validate("BA Freight Charge Type", Rec."BA Freight Charge Type"::" ");
            end;
        }
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
        addafter("Qty. Assigned")
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
    begin
        Rec.GetDimensionCodes(GLSetup, SalesPersonCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.OnNewRecord(SalesPersonCode);
        Rec.Validate("BA SEI Order Type", Rec."BA SEI Order Type"::" ");
        Rec.Validate("BA Freight Charge Type", Rec."BA Freight Charge Type"::" ");
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
        SalesPersonCode: Code[20];
}