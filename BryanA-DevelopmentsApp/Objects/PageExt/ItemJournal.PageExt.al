pageextension 80151 "BA Item Journal" extends "Item Journal"
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
        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Item No." = '' then
                    ClearDimensions();
            end;
        }

        addlast(Control1)
        {
            field("BA Product ID Code"; Rec."BA Product ID Code")
            {
                ApplicationArea = all;
                Visible = false;
            }
            field("BA Project Code"; Rec."BA Project Code")
            {
                ApplicationArea = all;
                Visible = false;
            }
            field("BA Shareholder Code"; Rec."BA Shareholder Code")
            {
                ApplicationArea = all;
                Visible = false;
            }
            field("BA Capex Code"; Rec."BA Capex Code")
            {
                ApplicationArea = all;
                Visible = ShowCapexDim;
            }
        }
    }

    trigger OnOpenPage()
    begin
        GLSetup.Get();
        ShowProductIDDim := GLSetup."ENC Product ID Dim. Code" <> '';
        ShowShareholderDim := GLSetup."BA Shareholder Code" <> '';
        ShowCapexDim := GLSetup."BA Capex Code" <> '';
    end;

    trigger OnAfterGetRecord()
    begin
        GetDimensionCodes();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearDimensions();
    end;

    local procedure GetDimensionCodes()
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        if Rec."Item No." = '' then begin
            ClearDimensions();
            exit;
        end;
        DimMgt.GetDimensionSet(TempDimSetEntry, Rec."Dimension Set ID");
        Rec."BA Product ID Code" := GetDimensionCode(TempDimSetEntry, GLSetup."ENC Product ID Dim. Code");
        Rec."BA Project Code" := GetDimensionCode(TempDimSetEntry, 'PROJECT');
        Rec."BA Shareholder Code" := GetDimensionCode(TempDimSetEntry, GLSetup."BA Shareholder Code");
        Rec."BA Capex Code" := GetDimensionCode(TempDimSetEntry, GLSetup."BA Capex Code");
    end;

    local procedure ClearDimensions()
    begin
        Rec."BA Product ID Code" := '';
        Rec."BA Project Code" := '';
        Rec."BA Shareholder Code" := '';
        Rec."BA Capex Code" := '';
    end;


    local procedure GetDimensionCode(var TempDimSetEntry: Record "Dimension Set Entry"; DimCode: Code[20]): Code[20]
    begin
        if DimCode = '' then
            exit('');
        TempDimSetEntry.SetRange("Dimension Code", DimCode);
        if TempDimSetEntry.FindFirst() then
            exit(TempDimSetEntry."Dimension Value Code");
        exit('');
    end;

    var
        GLSetup: Record "General Ledger Setup";
        DimMgt: Codeunit DimensionManagement;
        ShowProductIDDim: Boolean;
        ShowShareholderDim: Boolean;
        ShowCapexDim: Boolean;
}