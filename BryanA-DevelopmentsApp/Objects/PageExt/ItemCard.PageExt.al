pageextension 80009 "BA Item Card" extends "Item Card"
{
    layout
    {
        modify(Description)
        {
            ApplicationArea = all;
            Caption = 'Description (Max. 40 Char.)';
        }
        modify(GTIN)
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Item Category Code")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Automatic Ext. Texts")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Common Item No.")
        {
            ApplicationArea = all;
            Visible = false;
        }

        addafter("Qty. on Sales Order")
        {
            field("BA Qty. on Sales Quote"; Rec."BA Qty. on Sales Quote")
            {
                ApplicationArea = all;
            }
            field("BA Qty. on Closed Sales Quote"; "BA Qty. on Closed Sales Quote")
            {
                ApplicationArea = all;
            }
        }
        addafter("Last Direct Cost")
        {
            field("BA Last USD Purch. Cost"; "BA Last USD Purch. Cost")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the most recent USD purchase unit cost for the item.';
            }
        }
        addlast(Item)
        {
            group("BA Dimensions")
            {
                Caption = 'Dimensions';
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = all;
                }
                field("ENC Shortcut Dimension 3 Code"; DimValue[3])
                {
                    ApplicationArea = all;
                    Visible = false;
                    TableRelation = "Dimension Value".Code where ("Global Dimension No." = const (3), Blocked = const (false), "ENC Inactive" = const (false));
                    CaptionClass = '1,2,3';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        Rec.Validate("ENC Shortcut Dimension 3 Code", DimValue[3]);
                        Rec."ENC Shortcut Dimension 3 Code" := DimValue[3];
                    end;
                }
                field("ENC Shortcut Dimension 4 Code"; DimValue[4])
                {
                    ApplicationArea = all;
                    Visible = false;
                    TableRelation = "Dimension Value".Code where ("Global Dimension No." = const (4), Blocked = const (false), "ENC Inactive" = const (false));
                    CaptionClass = '1,2,4';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        Rec.Validate("ENC Shortcut Dimension 4 Code", DimValue[4]);
                        Rec."ENC Shortcut Dimension 4 Code" := DimValue[4];
                    end;
                }
                field("ENC Shortcut Dimension 5 Code"; DimValue[5])
                {
                    ApplicationArea = all;
                    Visible = false;
                    TableRelation = "Dimension Value".Code where ("Global Dimension No." = const (5), Blocked = const (false), "ENC Inactive" = const (false));
                    CaptionClass = '1,2,5';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        Rec.Validate("ENC Shortcut Dimension 5 Code", DimValue[5]);
                        Rec."ENC Shortcut Dimension 5 Code" := DimValue[5];
                    end;
                }
                field("ENC Shortcut Dimension 6 Code"; DimValue[6])
                {
                    ApplicationArea = all;
                    Visible = false;
                    TableRelation = "Dimension Value".Code where ("Global Dimension No." = const (6), Blocked = const (false), "ENC Inactive" = const (false));
                    CaptionClass = '1,2,6';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        Rec.Validate("ENC Shortcut Dimension 6 Code", DimValue[6]);
                        Rec."ENC Shortcut Dimension 6 Code" := DimValue[6];
                    end;
                }
                field("ENC Shortcut Dimension 7 Code"; DimValue[7])
                {
                    ApplicationArea = all;
                    Visible = false;
                    TableRelation = "Dimension Value".Code where ("Global Dimension No." = const (7), Blocked = const (false), "ENC Inactive" = const (false));
                    CaptionClass = '1,2,7';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        Rec.Validate("ENC Shortcut Dimension 7 Code", DimValue[7]);
                        Rec."ENC Shortcut Dimension 7 Code" := DimValue[7];
                    end;
                }
                field("ENC Shortcut Dimension 8 Code"; DimValue[8])
                {
                    ApplicationArea = all;
                    TableRelation = "Dimension Value".Code where ("Global Dimension No." = const (8), Blocked = const (false), "ENC Inactive" = const (false));
                    CaptionClass = '1,2,8';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        Rec.Validate("ENC Shortcut Dimension 8 Code", DimValue[8]);
                        Rec."ENC Shortcut Dimension 8 Code" := DimValue[8];
                    end;
                }
                field("ENC Product ID Code"; DimValue[9])
                {
                    ApplicationArea = all;
                    TableRelation = "Dimension Value".Code where ("Dimension Code" = CONST ('PRODUCT ID'), Blocked = const (false), "ENC Inactive" = const (false));
                    Caption = 'Product ID Code';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        Rec.Modify(false);
                        Rec.Get("No.");
                        Rec.Validate("ENC Product ID Code", DimValue[9]);
                        Rec."ENC Product ID Code" := DimValue[9];
                        Rec.Get("No.");
                    end;
                }
            }
        }
        addafter("Base Unit of Measure")
        {
            field("BA Service Item Only"; "BA Service Item Only")
            {
                ApplicationArea = all;
            }
            field("ENC Is Fabric"; "ENC Is Fabric")
            {
                ApplicationArea = all;
            }
            field("BA ETL Approved Fabric"; "BA ETL Approved Fabric")
            {
                ApplicationArea = all;
            }
            field("ENC Fabric Brand Name"; "ENC Fabric Brand Name")
            {
                ApplicationArea = all;
            }
        }
        modify("Vendor Item No.")
        {
            ApplicationArea = all;
            Visible = false;
        }
        modify("Vendor No.")
        {
            ApplicationArea = all;
            Visible = false;
        }
        addafter("Vendor Item No.")
        {
            field("BA Default Cross-Ref. No."; "BA Default Cross-Ref. No.")
            {
                ApplicationArea = all;
                Editable = false;

                trigger OnDrillDown()
                var
                    ItemCrossRef: Record "Item Cross Reference";
                    ItemCrossRefEntries: Page "Item Cross Reference Entries";
                begin
                    ItemCrossRef.FilterGroup(2);
                    ItemCrossRef.SetRange("Item No.", Rec."No.");
                    ItemCrossRefEntries.SetTableView(ItemCrossRef);
                    ItemCrossRefEntries.RunModal();
                    ItemCrossRef.FilterGroup(0);
                    Rec.CalcFields("BA Default Cross-Ref. No.", "BA Default Vendor No.");
                end;
            }
            field("BA Default Vendor No."; "BA Default Vendor No.")
            {
                ApplicationArea = all;
                Editable = false;

                trigger OnDrillDown()
                var
                    Vendor: Record Vendor;
                begin
                    if Rec."BA Default Vendor No." = '' then
                        exit;
                    Vendor.SetRange("No.", Rec."BA Default Vendor No.");
                    Page.RunModal(Page::"Vendor Card", Vendor);
                end;
            }
        }
        modify("Unit Price")
        {
            ApplicationArea = all;
            Editable = false;
        }
        addlast(Control1907509201)
        {
            field("BA Hide Visibility"; Rec."BA Hide Visibility")
            {
                ApplicationArea = all;
            }
            field("BA Visibility Updated"; Rec."BA Visibility Updated")
            {
                ApplicationArea = all;
            }
            field("BA Visibility Changed By"; Rec."BA Visibility Changed By")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("BA Cancel Item")
            {
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Cancel;
                Caption = 'Cancel Item';
                ToolTip = 'Deletes an item that has been accidently created.';

                trigger OnAction()
                var
                    ItemNo: Code[20];
                begin
                    if not Confirm(CancelMsg) then
                        exit;
                    ItemNo := Rec."No.";
                    Cancelled := true;
                    Rec.Delete(true);
                    Subscribers.ReuseItemNo(ItemNo);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CheckToUpdateDimValues(Rec);
        IsEditable := CurrPage.Editable;
    end;



    procedure CheckToUpdateDimValues(var Item: Record Item): Boolean
    begin
        exit(CheckToUpdateDimValues(Item, ''));
    end;

    procedure CheckToUpdateDimValues(var Item: Record Item; NewDimValue: Code[20]): Boolean
    var
        DefaultDim: Record "Default Dimension";
        RecRef: RecordRef;
        RecRef2: RecordRef;
        DimOffset: Integer;
        i: Integer;
        UpdateRec: Boolean;
    begin
        if Item."No." = '' then
            exit(false);

        RecRef.GetTable(Item);
        UpdateDimArray(RecRef);
        GLSetup.Get();
        RecRef2.GetTable(GLSetup);

        DimOffset := GLSetup.FieldNo("Shortcut Dimension 3 Code") - 3;
        if UpdateDimValue(RecRef, RecRef2, GLSetup.FieldNo("Shortcut Dimension 3 Code"), Item.FieldNo("ENC Shortcut Dimension 3 Code"), NewDimValue, DimOffset) then
            UpdateRec := true;
        if UpdateDimValue(RecRef, RecRef2, GLSetup.FieldNo("Shortcut Dimension 4 Code"), Item.FieldNo("ENC Shortcut Dimension 4 Code"), NewDimValue, DimOffset) then
            UpdateRec := true;
        if UpdateDimValue(RecRef, RecRef2, GLSetup.FieldNo("Shortcut Dimension 5 Code"), Item.FieldNo("ENC Shortcut Dimension 5 Code"), NewDimValue, DimOffset) then
            UpdateRec := true;
        if UpdateDimValue(RecRef, RecRef2, GLSetup.FieldNo("Shortcut Dimension 6 Code"), Item.FieldNo("ENC Shortcut Dimension 6 Code"), NewDimValue, DimOffset) then
            UpdateRec := true;
        if UpdateDimValue(RecRef, RecRef2, GLSetup.FieldNo("Shortcut Dimension 7 Code"), Item.FieldNo("ENC Shortcut Dimension 7 Code"), NewDimValue, DimOffset) then
            UpdateRec := true;
        if UpdateDimValue(RecRef, RecRef2, GLSetup.FieldNo("Shortcut Dimension 8 Code"), Item.FieldNo("ENC Shortcut Dimension 8 Code"), NewDimValue, DimOffset) then
            UpdateRec := true;
        if UpdateDimValue(RecRef, RecRef2, GLSetup.FieldNo("ENC Product ID Dim. Code"), Item.FieldNo("ENC Product ID Code"), NewDimValue, DimOffset) then
            UpdateRec := true;

        if UpdateRec then begin
            UpdateDimArray(RecRef);
            RecRef.SetTable(Item);
            CurrPage.Update(true);
            Rec.Get(Item."No.");
            Item.Get(Item."No.");
        end;
        exit(UpdateRec);
    end;

    local procedure UpdateDimArray(var RecRef: RecordRef)
    var
        i: Integer;
    begin
        for i := 3 to 8 do
            DimValue[i] := RecRef.Field(Rec.FieldNo("ENC Shortcut Dimension 3 Code") + i - 3).Value();
        DimValue[9] := RecRef.Field(Rec.FieldNo("ENC Product ID Code")).Value();
    end;

    local procedure UpdateDimValue(var RecRef: RecordRef; var GLRecRef: RecordRef; GLFldNo: Integer; DimFldNo: Integer; NewDimValue: Code[20]; DimOffset: Integer): Boolean
    var
        GLSetup: Record "General Ledger Setup";
        DefaultDim: Record "Default Dimension";
        DimValue: Record "Dimension Value";
        FldRef: FieldRef;
        FldRef2: FieldRef;
        FldRef3: FieldRef;
        FldRef4: FieldRef;
        DimMgt: Codeunit DimensionManagement;
        Result: Boolean;
    begin
        FldRef := GLRecRef.Field(GLFldNo);
        if Format(FldRef.Value()) = '' then
            exit(false);
        FldRef2 := RecRef.Field(Rec.FieldNo("No."));
        FldRef3 := RecRef.Field(DimFldNo);
        if NewDimValue <> '' then
            FldRef4 := RecRef.Field(Rec.FieldNo("ENC Skip Dimension Validation"));

        if DefaultDim.Get(Database::Item, FldRef2.Value(), FldRef.Value()) then begin
            if NewDimValue <> '' then begin
                if DimValue.Get(DefaultDim."Dimension Code", NewDimValue) then begin
                    if Format(FldRef3.Value) <> NewDimValue then begin
                        FldRef4.Value(true);
                        FldRef3.Validate(NewDimValue);
                        FldRef4.Value(false);
                        DimMgt.SaveDefaultDim(Database::Item, FldRef2.Value(), GLFldNo - DimOffset, NewDimValue);
                        Result := true;
                    end;
                end;
            end else
                if DimValue.Get(DefaultDim."Dimension Code", DefaultDim."Dimension Value Code") then
                    if Format(FldRef3.Value) <> DefaultDim."Dimension Value Code" then begin
                        FldRef3.Validate(DefaultDim."Dimension Value Code");
                        Result := true;
                    end;
        end else
            if Format(FldRef3.Value()) <> '' then begin
                FldRef3.Validate('');
                Result := true;
            end;
        exit(Result);
    end;


    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ItemNo: Code[20];
    begin
        if (Rec."No." = '') or (Rec.Description <> '') or Deleted or Cancelled or (Rec."ENC Created Date" <> Today()) then
            exit;
        if not Confirm(StrSubstNo(CancelItemMsg, Rec."No.")) then
            Error('');
        ItemNo := Rec."No.";
        Rec.Delete(true);
        Subscribers.ReuseItemNo(ItemNo);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Deleted := true;
    end;

    var
        Subscribers: Codeunit "BA SEI Subscibers";
        Deleted: Boolean;
        Cancelled: Boolean;

        CancelItemMsg: Label 'Do you want to cancel creating Item No. %1?';
        CancelMsg: Label 'Cancel item?';

    var
        GLSetup: Record "General Ledger Setup";
        DimValue: array[9] of Code[20];
        [InDataSet]
        IsEditable: Boolean;
}