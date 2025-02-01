pageextension 80144 "BA Purch. Cr.Memo Subform" extends "Purch. Cr. Memo Subform"
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
        addafter(ShortcutDimCode8)
        {
            field("BA Product ID Code"; Rec."BA Product ID Code")
            {
                ApplicationArea = all;
                Editable = "No." <> '';
                Visible = false;
            }
            field("BA Project Code"; Rec."BA Project Code")
            {
                ApplicationArea = all;
                Editable = "No." <> '';
                Visible = false;
            }
            field("BA Shareholder Code"; Rec."BA Shareholder Code")
            {
                ApplicationArea = all;
                Editable = "No." <> '';
                Visible = false;
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