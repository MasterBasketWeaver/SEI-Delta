tableextension 80000 "BA Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(80000; "BA Salesperson Filter Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Salesperson Filter Code';
            Editable = false;
        }
        field(80001; "BA Requisition Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Requisition Order';
            Editable = false;
            Description = 'System field to specify Requisition Orders';
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
                SetNewDimValue('CAPEX', "BA Shareholder Code");
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
        if DimValue = '' then begin
            if TempDimSetEntry.FindFirst() then
                TempDimSetEntry.Delete(false);
        end else begin
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
        end;
        Rec."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;

    procedure GetDimensionCodes(var GLSetup: Record "General Ledger Setup"; var SalesPersonCode: Code[20])
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
        Rec."BA Project Code" := GetDimensionCode(TempDimSetEntry, 'PROJECT');
        Rec."BA Product ID Code" := GetDimensionCode(TempDimSetEntry, GLSetup."ENC Product ID Dim. Code");
        Rec."BA Shareholder Code" := GetDimensionCode(TempDimSetEntry, GLSetup."BA Shareholder Code");
        Rec."BA Capex Code" := GetDimensionCode(TempDimSetEntry, GLSetup."BA Capex Code");

        Rec."BA Salesperson Filter Code" := GLSetup."ENC Salesperson Dim. Code";
        SalesPersonCode := GetDimensionCode(TempDimSetEntry, GLSetup."ENC Salesperson Dim. Code");
    end;

    local procedure GetDimensionCode(var TempDimSetEntry: Record "Dimension Set Entry"; DimCode: Code[20]): Code[20]
    begin
        TempDimSetEntry.SetRange("Dimension Code", DimCode);
        if TempDimSetEntry.FindFirst() then
            exit(TempDimSetEntry."Dimension Value Code");
        exit('');
    end;

    procedure OnNewRecord(var SalesPersonCode: Code[20])
    begin
        SalesPersonCode := '';
        Rec."BA Product ID Code" := '';
        Rec."BA Project Code" := '';
        Rec."BA Shareholder Code" := '';
        Rec."BA Capex Code" := '';
    end;


    var
        DimMgt: Codeunit DimensionManagement;
}