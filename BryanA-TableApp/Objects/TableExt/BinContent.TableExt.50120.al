tableextension 80120 "BA Bin Content" extends "Bin Content"
{
    fields
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                Rec.CalcFields("BA Description", "BA Description 2", "BA Blocked", "BA Hide Visibility");
            end;
        }
        field(80000; "BA Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item.Description where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Description';
        }
        field(80001; "BA Description 2"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item."Description 2" where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Description 2';
        }
        field(80002; "BA Blocked"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item.Blocked where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Blocked';
        }
        field(80003; "BA Hide Visibility"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item."BA Hide Visibility" where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Hide Visibility';
        }
        field(80004; "BA Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
    }

    trigger OnModify()
    begin
        Rec.Validate("BA Quantity", Rec.CalcQtyUOM());
    end;

    trigger OnAfterModify()
    begin
        Rec.Validate("BA Quantity", Rec.CalcQtyUOM());
    end;

    trigger OnRename()
    begin
        Rec.Validate("BA Quantity", Rec.CalcQtyUOM());
    end;
}