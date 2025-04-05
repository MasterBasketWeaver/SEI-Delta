tableextension 80049 "BA Item Jnl. Line" extends "Item Journal Line"
{
    fields
    {
        field(80000; "BA Updated"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Updated';
            Editable = false;
            Description = 'System field used for Physical Inventory import';
        }
        field(80001; "BA Created At"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created At';
            Editable = false;
        }
        field(80002; "BA Warning Message"; Text[256])
        {
            DataClassification = CustomerContent;
            Caption = 'Warning Message';
            Editable = false;
        }
        field(80010; "BA Item Tracking Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup (Item."Item Tracking Code" where ("No." = field ("Item No.")));
            Caption = 'Item Tracking Code';
            Editable = false;
        }

        field(80011; "BA Adjust. Reason Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Adjustment Reason Code';
            TableRelation = "BA Adjustment Reason".Code;
        }
        field(80012; "BA Approved By"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Approved By';
            TableRelation = "User Setup"."User ID";
            Editable = false;
        }
        field(80013; "BA Status"; Enum "BA Approval Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            Editable = false;
        }
        field(80014; "BA Locked For Approval"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Locked For Approval';
            Editable = false;
        }
        field(80015; "BA Approval GUID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Approval GUID';
            Editable = false;
        }
        field(80100; "BA Product ID Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Product ID Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('PRODUCT ID'), Blocked = const (false), "ENC Inactive" = const (false));

            trigger OnValidate()
            begin
                SetNewDimValue('PRODUCT ID', "BA Product ID Code");
            end;
        }
        field(80101; "BA Project Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Project Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('PROJECT'), Blocked = const (false), "ENC Inactive" = const (false));

            trigger OnValidate()
            begin
                SetNewDimValue('PROJECT', "BA Project Code");
            end;
        }
        field(80102; "BA Shareholder Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shareholder Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('SHAREHOLDER'), Blocked = const (false), "ENC Inactive" = const (false));

            trigger OnValidate()
            begin
                SetNewDimValue('SHAREHOLDER', "BA Shareholder Code");
            end;
        }
        field(80103; "BA Capex Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Capex Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('CAPEX'), Blocked = const (false), "ENC Inactive" = const (false));

            trigger OnValidate()
            begin
                SetNewDimValue('CAPEX', "BA CAPEX Code");
            end;
        }
    }

    local procedure SetNewDimValue(DimCode: Code[20]; DimValue: Code[20])
    var
        DimValueRec: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
        TempDimSetEntry.SetRange("Dimension Code", DimCode);
        if DimValue <> '' then begin
            DimValueRec.Get(DimCode, DimValue);
            if TempDimSetEntry.FindFirst() then begin
                TempDimSetEntry."Dimension Value Code" := DimValue;
                TempDimSetEntry."Dimension Value ID" := DimValueRec."Dimension Value ID";
                TempDimSetEntry.Modify(false);
            end else begin
                TempDimSetEntry.Init();
                TempDimSetEntry."Dimension Code" := DimCode;
                TempDimSetEntry."Dimension Value Code" := DimValue;
                TempDimSetEntry."Dimension Value ID" := DimValueRec."Dimension Value ID";
                TempDimSetEntry.Insert(false);
            end;
        end else
            if TempDimSetEntry.FindFirst() then
                TempDimSetEntry.Delete(false);
        Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
}