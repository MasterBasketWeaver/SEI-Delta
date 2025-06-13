tableextension 80096 "BA Salesperson/Purchaser" extends "Salesperson/Purchaser"
{
    fields
    {
        field(80000; "BA Sales Staff"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Staff';
        }
        field(80010; "BA Commission Rate 2"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Commission Rate 2';
            TableRelation = "BA Commission Rate".Code;

            trigger OnValidate()
            begin
                Rec.CalcFields("BA Commission % 2");
            end;
        }
        field(80011; "BA Commission Rate 3"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Commission Rate 3';
            TableRelation = "BA Commission Rate".Code;

            trigger OnValidate()
            begin
                Rec.CalcFields("BA Commission % 3");
            end;
        }
        field(80012; "BA Commission Rate 4"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Commission Rate 4';
            TableRelation = "BA Commission Rate".Code;

            trigger OnValidate()
            begin
                Rec.CalcFields("BA Commission % 4");
            end;
        }
        field(80013; "BA Commission Rate 5"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Commission Rate 5';
            TableRelation = "BA Commission Rate".Code;

            trigger OnValidate()
            begin
                Rec.CalcFields("BA Commission % 5");
            end;
        }
        field(80020; "BA Commission % 2"; Decimal)
        {
            Caption = 'Commission % 2';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Commission Rate".Rate where (Code = Field ("BA Commission Rate 2")));
            Editable = false;
        }
        field(80021; "BA Commission % 3"; Decimal)
        {
            Caption = 'Commission % 3';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Commission Rate".Rate where (Code = Field ("BA Commission Rate 3")));
            Editable = false;
        }
        field(80022; "BA Commission % 4"; Decimal)
        {
            Caption = 'Commission % 4';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Commission Rate".Rate where (Code = Field ("BA Commission Rate 4")));
            Editable = false;
        }
        field(80023; "BA Commission % 5"; Decimal)
        {
            Caption = 'Commission % 5';
            FieldClass = FlowField;
            CalcFormula = lookup ("BA Commission Rate".Rate where (Code = Field ("BA Commission Rate 5")));
            Editable = false;
        }
    }
}