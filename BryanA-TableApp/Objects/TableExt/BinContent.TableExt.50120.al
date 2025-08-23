tableextension 80120 "BA Bin Content" extends "Bin Content"
{
    fields
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                Rec.CalcFields("BA Item Description", "BA Item Description 2", "BA Item Blocked", "BA Item Hide Visibility");
            end;
        }
        field(80000; "BA Item Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item.Description where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Item Description';
        }
        field(80001; "BA Item Description 2"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item."Description 2" where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Item Description 2';
        }
        field(80002; "BA Item Blocked"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item.Blocked where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Item Blocked';
        }
        field(80003; "BA Item Hide Visibility"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item."BA Hide Visibility" where ("No." = field ("Item No.")));
            Editable = false;
            Caption = 'Item Hide Visibility';
        }
        field(80004; "BA Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Quantity';
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