tableextension 80030 "BA Customer" extends Customer
{
    fields
    {
        field(80000; "BA Int. Customer"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales BBD Fields Mandatory';
        }
        field(80001; "BA Serv. Int. Customer"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Service BBD Fields Mandatory';
        }
        field(80010; "BA Region"; Text[30])
        {
            Caption = 'Region';
            FieldClass = FlowField;
            CalcFormula = lookup ("Country/Region"."BA Region" where (Code = field ("Country/Region Code")));
            Editable = false;
        }
        field(80011; "BA County Fullname"; Text[50])
        {
            Caption = 'Province/State Fullname';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Province/State".Name where ("Print Full Name" = const (true), "Country/Region Code" = field ("Country/Region Code"), Symbol = field (County)));
            Editable = false;
        }
        modify(County)
        {
            TableRelation = "BA Province/State".Symbol where ("Country/Region Code" = field ("Country/Region Code"));
        }
        modify("Country/Region Code")
        {
            trigger OnAfterValidate()
            begin
                if "Country/Region Code" = '' then
                    "BA Region" := ''
                else
                    Rec.CalcFields("BA Region");
            end;
        }

        field(80020; "BA Outstanding Serv. Orders"; Decimal)
        {
            Caption = 'Outstanding Serv. Orders';
            FieldClass = FlowField;
            CalcFormula = Sum ("Service Line"."Outstanding Amount" WHERE ("Document Type" = CONST (Order), "Bill-to Customer No." = FIELD ("No."),
            "Shortcut Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
            "Currency Code" = FIELD ("Currency Filter")));
            Editable = false;
        }
        field(80021; "BA Serv Shipped Not Invoiced"; Decimal)
        {
            Caption = 'Serv Shipped Not Invoiced';
            FieldClass = FlowField;
            CalcFormula = Sum ("Service Line"."Shipped Not Invoiced" WHERE ("Document Type" = CONST (Order), "Bill-to Customer No." = FIELD ("No."),
            "Shortcut Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
            "Currency Code" = FIELD ("Currency Filter")));
            Editable = false;
        }
        field(80022; "BA Outstanding Serv.Invoices"; Decimal)
        {
            Caption = 'Outstanding Serv.Invoices';
            FieldClass = FlowField;
            CalcFormula = Sum ("Service Line"."Outstanding Amount" WHERE ("Document Type" = CONST (Invoice), "Bill-to Customer No." = FIELD ("No."),
                "Shortcut Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"), "Shortcut Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                "Currency Code" = FIELD ("Currency Filter")));
            Editable = false;
        }
        field(80025; "BA Credit Limit"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Limit';
        }
        field(80026; "BA Credit Limit Last Updated"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Limit Last Updated';
            Editable = false;
        }
        field(80027; "BA Credit Limit Updated By"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Credit Limit Updated By';
            Editable = false;
            TableRelation = "User Setup"."User ID";
            ValidateTableRelation = false;
        }
        field(80030; "BA Last Sales Activity"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sales Activity';
            Editable = false;
        }
        field(80040; "BA SEI Service Center"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Service Center';
        }
        field(80050; "BA SEI Int'l Cust. No."; Code[12])
        {
            DataClassification = CustomerContent;
            Caption = 'SEI Int''l Cust. No.';
        }
        field(80051; "BA EORI No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EORI No.';
        }
        field(80060; "BA Segment Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Segment Code';
            TableRelation = "BA Segment".Code;
        }
        field(80061; "BA Sub-Segment Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sub-Segment Code';
            TableRelation = "BA Sub-Segment".Code;
        }
        field(80062; "BA Constrained"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Constrained';
        }
        field(80070; "BA Dealer"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Dealer';
        }
        field(80075; "BA Non-Mandatory Delivery Date"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Non-Mandatory Promised Delivery Date';
        }
        field(80080; "BA Block Reason"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Block Reason';
            TableRelation = "BA Block Reason";
        }
        field(80085; "BA Non-Mandatory Customer"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Non-Mandatory Customer Classification';
        }
        field(80086; "BA New Record"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'New Record';
            Editable = false;
            InitValue = true;
        }
        field(80090; "BA Ship-to Email"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Email';
            ExtendedDatatype = EMail;
        }
        field(80100; "BA Approval Group"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Approval Group';
            TableRelation = "BA Approval Group".Code;
            Editable = false;
        }
        field(80101; "BA Government (CDN/US)"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Government (CDN/US)';
        }
        field(80102; "BA Trusted Agent"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Trusted Agent';
        }
    }
}