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
        field(80050; "BA SEI Order Type"; Enum "BA SEI Order Type")
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Order Type';
        }
        field(80051; "BA SEI Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Order No.';

            TableRelation = if ("BA SEI Order Type" = filter ("Delta SO")) "Sales Invoice Header"."Order No." where ("Bill-to Customer No." = filter ('<>SEILAB'))
            else
            if ("BA SEI Order Type" = filter ("Int. SO")) "Sales Invoice Header"."External Document No." where ("Bill-to Customer No." = const ('SEILAB'))
            else
            if ("BA SEI Order Type" = filter ("Delta SVO")) "Service Invoice Header"."Order No." where ("Bill-to Customer No." = filter ('<>SEILAB'))
            else
            if ("BA SEI Order Type" = filter ("Int. SVO")) "Service Invoice Header"."ENC External Document No." where ("Bill-to Customer No." = const ('SEILAB'))
            else
            if ("BA SEI Order Type" = const (Transfer)) "Transfer Shipment Header"."Transfer Order No.";

            ValidateTableRelation = false;
        }
        field(80052; "BA Freight Charge Type"; Enum "BA Freight Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Charge Type';
        }
        field(80053; "BA SEI Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Invoice No.';
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
                SetNewDimValue('CAPEX', "BA Capex Code");
            end;
        }
    }


    local procedure SetNewDimValue(DimCode: Code[20]; DimValue: Code[20])
    var
        DimValueRec: Record "Dimension Value";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
        if DimValue = '' then begin
            if TempDimSetEntry.Get(Rec."Dimension Set ID", DimCode) then
                TempDimSetEntry.Delete(false);
        end else begin
            DimValueRec.Get(DimCode, DimValue);
            if TempDimSetEntry.Get(Rec."Dimension Set ID", DimCode) then begin
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