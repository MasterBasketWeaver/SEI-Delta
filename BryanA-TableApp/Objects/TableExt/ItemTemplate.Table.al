tableextension 80079 "BA Item Template" extends "Item Template"
{
    fields
    {
        field(80030; "BA Product Profile Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Product Profile Code';
            TableRelation = "BA Product Profile"."Profile Code";
        }

        field(80000; "BA US HS Code"; Code[13])
        {
            DataClassification = CustomerContent;
            Caption = 'US HS Code';
            TableRelation = "ENC US HS Code"."Formatted Code";
            ValidateTableRelation = true;
        }
        field(80001; "BA International HS Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'International HS Code';
            TableRelation = "ENC International HS Code"."Formatted Code";
            ValidateTableRelation = true;
        }
        field(80002; "BA CUSMA"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'CUSMA';
            OptionMembers = " ","Eligible","Non-Eligible";
            OptionCaption = ' ,Eligible,Non-Eligible';
        }
        field(80003; "BA Producer"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Producer';
            OptionMembers = " ","Producer","Non-Producer";
            OptionCaption = ' ,Producer,Non-Producer';
        }
        field(80004; "BA Preference Criterion"; Code[1])
        {
            DataClassification = CustomerContent;
            Caption = 'Preference Criterion';
        }
        field(80005; "BA Net Cost"; Code[4])
        {
            DataClassification = CustomerContent;
            Caption = 'Net Cost';
        }
        field(80006; "BA Country of Origin Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
        }
        field(80007; "BA Core Product Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Core Product Code';
            TableRelation = "ENC Core Product";
        }
        field(80008; "BA Core Prod. Sub. Cat. Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Core Prod. Sub. Category Code';
            TableRelation = "ENC Core Product Sub. Category";
        }
        field(80009; "BA Core Prod. Model Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Core Prod. Model Code';
            TableRelation = "ENC Core Product Model";
        }
        field(80010; "BA Item Tracking Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Tracking Code';
            TableRelation = "Item Tracking Code".Code;
        }
    }
}