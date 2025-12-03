pageextension 80187 "BA Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        modify("E-Pay Export File Path")
        {
            ApplicationArea = all;
            Visible = true;
        }
        modify("Last E-Pay File Creation No.")
        {
            ApplicationArea = all;
            Visible = false;
            BlankZero = true;
        }
        modify("Last E-Pay Export File Name")
        {
            trigger OnAfterValidate()
            var
                RemitNo: Code[20];
                c: Char;
                i: Integer;
            begin
                if Rec."Last E-Pay Export File Name" <> '' then begin
                    for i := 1 to StrLen(Rec."Last E-Pay Export File Name") do begin
                        c := Rec."Last E-Pay Export File Name"[i];
                        if (c >= '0') and (c <= '9') then
                            RemitNo += c;
                    end;
                    Rec.Validate("Last Remittance Advice No.", RemitNo);
                end;
            end;
        }
    }
}