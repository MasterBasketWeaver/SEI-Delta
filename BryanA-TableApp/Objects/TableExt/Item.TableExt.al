tableextension 80012 "BA Item" extends Item
{
    fields
    {
        field(80000; "BA Qty. on Sales Quote"; Decimal)
        {
            Caption = 'Qty. on Open Sales Quote';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum ("Sales Line"."Outstanding Qty. (Base)"
            where ("Document Type" = Const (Quote), Type = Const (Item), "No." = Field ("No."),
                "Shortcut Dimension 1 Code" = Field ("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = Field ("Global Dimension 2 Filter"),
                "Location Code" = Field ("Location Filter"), "Drop Shipment" = Field ("Drop Shipment Filter"), "Variant Code" = Field ("Variant Filter"),
                "Shipment Date" = Field ("Date Filter"), "BA Stage" = const (Open)));
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DecimalPlaces = 0 : 5;
        }
        field(80001; "BA Last USD Purch. Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Last USD Purchase Cost';
        }
        field(80002; "BA Qty. on Closed Sales Quote"; Decimal)
        {
            Caption = 'Qty. on Archived Sales Quote';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum ("Sales Line"."Outstanding Qty. (Base)"
            where ("Document Type" = Const (Quote), Type = Const (Item), "No." = Field ("No."),
                "Shortcut Dimension 1 Code" = Field ("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = Field ("Global Dimension 2 Filter"),
                "Location Code" = Field ("Location Filter"), "Drop Shipment" = Field ("Drop Shipment Filter"), "Variant Code" = Field ("Variant Filter"),
                "Shipment Date" = Field ("Date Filter"), "BA Stage" = Filter (Archive | "Closed/Lost" | "Closed/Other")));
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DecimalPlaces = 0 : 5;
        }
        field(80010; "BA ETL Approved Fabric"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'ETL Approved Fabric';
        }
        field(80020; "BA Default Vendor No."; Code[30])
        {
            Caption = 'Default Vendor No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup ("Item Cross Reference"."Cross-Reference Type No." where ("Item No." = field ("No."),
                "Cross-Reference Type" = const (Vendor), "Cross-Reference No." = field ("BA Default Cross-Ref. No."), "BA Default Cross Refernce No." = const (true)));
        }
        field(80021; "BA Default Cross-Ref. No."; Code[20])
        {
            Caption = 'Default Cross-Ref. No.';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup ("Item Cross Reference"."Cross-Reference No." where ("Item No." = field ("No."),
                "Cross-Reference Type" = const (Vendor), "BA Default Cross Refernce No." = const (true)));
        }
        field(80030; "BA Location Filter"; Code[20])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location.Code where ("BA Inactive" = const (false));
        }
        field(80035; "BC NC Cut Sheet"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'NC Cut Sheet';
        }
        field(80040; "BA Service Item Only"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Service Item Only';
        }
        field(80050; "BA Hide Visibility"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Hide Visibility';

            trigger OnValidate()
            begin
                Rec."BA Visibility Changed By" := UserId();
                Rec."BA Visibility Updated" := CurrentDateTime();
            end;
        }
        field(80051; "BA Visibility Updated"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Visibility Updated';
            Editable = false;
        }
        field(80052; "BA Visibility Changed By"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Visibility Changed By';
            Editable = false;
            TableRelation = User."User Name";
        }
    }

    procedure SetLastCurrencyPurchCost(CurrCode: Code[10]; LastPurchCost: Decimal)
    begin
        case CurrCode of
            'USD':
                Rec.Validate("BA Last USD Purch. Cost", LastPurchCost);
            else
                Error('Invalid purchase currency: %1', CurrCode);
        end;
    end;

    procedure GetLastCurrencyPurchCost(CurrCode: Code[10]): Decimal
    begin
        case CurrCode of
            'USD':
                exit(Rec."BA Last USD Purch. Cost");
            else
                Error('Invalid purchase currency: %1', CurrCode);
        end;
    end;
}