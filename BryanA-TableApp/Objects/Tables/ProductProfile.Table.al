table 75014 "BA Product Profile"
{
    DataClassification = CustomerContent;
    Caption = 'Product Profile';

    fields
    {
        field(1; "Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }

        field(10; "Item Category Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(11; "Item Tracking Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Item Tracking Code".Code;
        }
        field(12; "Gen. Prod. Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group".Code;
        }
        field(13; "Core Product Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "ENC Core Product";
        }
        field(14; "Core Prod. Sub. Cat. Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Core Prod. Sub. Category Code';
            TableRelation = "ENC Core Product Sub. Category";
        }
        field(15; "Manufacturing Dept."; Text[35])
        {
            DataClassification = CustomerContent;
            TableRelation = "ENC Department Code".Name where (Type = const (Manufacturing));
            ValidateTableRelation = true;
        }
        field(16; "Core Prod. Model Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "ENC Core Product Model";
            ValidateTableRelation = true;
        }
        field(17; "Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Inventory","Service","Non-Inventory";
            OptionCaption = 'Inventory,Service,Non-Inventory';
        }
        field(18; "Base Unit of Measure"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
            ValidateTableRelation = true;
        }
        field(19; "Inventory Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Inventory Posting Group".Code;
            ValidateTableRelation = true;
        }
        field(20; "Costing Method"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "FIFO","LIFO","Specific","Average","Standard";
            OptionCaption = 'FIFO,LIFO,Specific,Average,Standard';
        }
        field(21; "Price/Profit Calculation"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Profit=Price-Cost","Price=Cost+Profit","No Relationship";
            OptionCaption = 'Profit=Price-Cost,Price=Cost+Profit,No Relationship';
        }
        field(22; "Replenishment System"; Option)
        {
            DataClassification = CustomerContent;
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            OptionMembers = "Purchase","Prod. Order"," ","Assembly";
            OptionCaption = 'Purchase,Prod. Order, ,Assembly';
        }
        field(23; "Manufacturing Policy"; Option)
        {
            DataClassification = CustomerContent;
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            OptionCaption = 'Make-to-Stock,Make-to-Order';
            OptionMembers = "Make-to-Stock","Make-to-Order";
        }
        field(24; "Assembly Policy"; Option)
        {
            DataClassification = CustomerContent;
            AccessByPermission = TableData "BOM Component" = R;
            OptionCaption = 'Assemble-to-Stock,Assemble-to-Order';
            OptionMembers = "Assemble-to-Stock","Assemble-to-Order";
        }

        field(25; "Reordering Policy"; Option)
        {
            DataClassification = CustomerContent;
            AccessByPermission = TableData "Req. Wksh. Template" = R;
            OptionCaption = ' ,Fixed Reorder Qty.,Maximum Qty.,Order,Lot-for-Lot';
            OptionMembers = " ","Fixed Reorder Qty.","Maximum Qty.","Order","Lot-for-Lot";
        }
        field(26; "Reserve"; Option)
        {
            DataClassification = CustomerContent;
            AccessByPermission = TableData "Purch. Rcpt. Header" = R;
            InitValue = Optional;
            OptionMembers = "Never","Optional","Always";
            OptionCaption = 'Never,Optional,Always';
        }

        field(27; "US HS Code"; Code[13])
        {
            DataClassification = CustomerContent;
            TableRelation = "ENC US HS Code"."Formatted Code";
            ValidateTableRelation = true;
        }
        field(28; "International HS Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "ENC International HS Code"."Formatted Code";
            ValidateTableRelation = true;
        }
        field(29; "CUSMA"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Eligible","Non-Eligible";
            OptionCaption = ' ,Eligible,Non-Eligible';
        }
        field(30; "Producer"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Producer","Non-Producer";
            OptionCaption = ' ,Producer,Non-Producer';
        }
        field(31; "Preference Criterion"; Code[1])
        {
            DataClassification = CustomerContent;
        }
        field(32; "Net Cost"; Code[4])
        {
            DataClassification = CustomerContent;
        }
        field(33; "Country/Region of Origin Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
        }


        field(50; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (1), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(51; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (2), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(52; "Shortcut Dimension 3 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (3), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(53; "Shortcut Dimension 4 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,4';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (4), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(54; "Shortcut Dimension 5 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,5';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (5), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(55; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (6), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(56; "Shortcut Dimension 7 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,7';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (7), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(57; "Shortcut Dimension 8 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,8';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No." = CONST (8), Blocked = const (false), "ENC Inactive" = const (false));
        }
        field(58; "Product ID Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Product ID Code';
            TableRelation = "Dimension Value".Code WHERE ("Dimension Code" = CONST ('PRODUCT ID'), Blocked = const (false), "ENC Inactive" = const (false));
        }

        field(200; "Created By"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "User Setup"."User ID";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(201; "Creation Date"; DateTime)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(k1; "Profile Code")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId();
        "Creation Date" := CurrentDateTime();
    end;
}