tableextension 80090 "BA General Journal" extends "Gen. Journal Line"
{
    fields
    {
        field(80000; "BA Product ID Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Product ID Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('PRODUCT ID'), Blocked = const (false), "ENC Inactive" = const (false));

            trigger OnValidate()
            begin
                SetNewDimValue('PRODUCT ID', "BA Product ID Code");
            end;
        }
        field(80001; "BA Project Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Project Code';
            TableRelation = "Dimension Value".Code where ("Dimension Code" = const ('PROJECT'), Blocked = const (false), "ENC Inactive" = const (false));

            trigger OnValidate()
            begin
                SetNewDimValue('PROJECT', "BA Project Code");
            end;
        }
    }

    local procedure SetNewDimValue(DimCode: Code[20]; DimValue: Code[20])
    var
        DimValueRec: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
        DimValueRec.Get(DimCode, DimValue);
        TempDimSetEntry.SetRange("Dimension Code", DimCode);
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
        Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
}