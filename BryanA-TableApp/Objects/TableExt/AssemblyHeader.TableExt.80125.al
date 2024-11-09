tableextension 80125 "BA Assembly Header" extends "Assembly Header"
{
    fields
    {
        field(80000; "BA Modified Date Fields"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Modified Date Fields';
            Editable = false;
        }
        field(80001; "BA Temp Due Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Temp Due Date';
            Editable = false;
        }
        field(80002; "BA Temp Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Temp Starting Date';
            Editable = false;
        }
        field(80003; "BA Temp Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Temp Ending Date';
            Editable = false;
        }
    }
}