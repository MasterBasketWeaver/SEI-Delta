pageextension 80187 "BA Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        modify("Input Qualifier")
        {
            Visible = false;
        }
        modify("Transit No.2")
        {
            Editable = EFTUS;
            ShowMandatory = UseEFT;
        }
        modify("Client No.")
        {
            Editable = UseEFT;
            Enabled = UseEFT;
            ShowMandatory = UseEFT;
        }
        modify("Client Name")
        {
            Editable = UseEFT;
            Enabled = UseEFT;
        }
        modify("Payment Export Format")
        {
            ShowMandatory = UseEFT;
        }
        modify("SWIFT Code")
        {
            Visible = false;
        }
        modify(IBAN)
        {
            Visible = false;
        }
        modify("Positive Pay Export Code")
        {
            Visible = false;
        }
        modify("Bank Statement Import Format")
        {
            Visible = false;
        }
        modify("EFT Export Code")
        {
            Visible = false;
        }

        modify("Export Format")
        {
            trigger OnAfterValidate()
            begin
                UpdateEFTDisplay();
            end;
        }
        modify("E-Pay Export File Path")
        {
            ApplicationArea = all;
            Visible = true;
            ShowMandatory = UseEFT;

            trigger OnAfterValidate()
            begin
                CheckFilePathHasSuffix();

            end;

            trigger OnAssistEdit()
            var

                FilePath: Text;
            begin
                if FileMgt.SelectDefaultFolderDialog('Select Export Folder', FilePath, Rec."E-Pay Export File Path") then begin
                    if (StrLen(FilePath) - 1) > MaxStrLen(Rec."E-Pay Export File Path") then
                        Error('Filepath exceeds max character length of %1', MaxStrLen(Rec."E-Pay Export File Path"));
                    Rec.Validate("E-Pay Export File Path", FilePath);
                    CheckFilePathHasSuffix();
                end;
            end;
        }
        modify("Last E-Pay File Creation No.")
        {
            ApplicationArea = all;
            Visible = false;
            BlankZero = true;
        }
        modify("Last E-Pay Export File Name")
        {
            ShowMandatory = UseEFT;

            trigger OnAfterValidate()
            begin
                if Rec."Last E-Pay Export File Name" <> '' then
                    Rec.Validate("Last Remittance Advice No.", Subscribers.GetNumeralsOnly(Rec."Last E-Pay Export File Name"));
            end;
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateEFTDisplay();
    end;

    local procedure CheckFilePathHasSuffix()
    begin
        if Rec."E-Pay Export File Path" = '' then
            exit;

        if not FileMgt.ClientDirectoryExists(Rec."E-Pay Export File Path") or not FileMgt.ServerDirectoryExists(Rec."E-Pay Export File Path") then
            if not Confirm('No folder found at %1, continue?', false, Rec."E-Pay Export File Path".Replace('\', '\')) then
                Error('');

        if not Rec."E-Pay Export File Path".EndsWith('\') then
            Rec."E-Pay Export File Path" += '\';
    end;

    local procedure UpdateEFTDisplay()
    begin
        EFTCA := Rec."Export Format" = Rec."Export Format"::CA;
        EFTUS := Rec."Export Format" = Rec."Export Format"::US;
        UseEFT := EFTCA or EFTUS;
    end;

    var
        Subscribers: Codeunit "BA SEI Subscibers";
        FileMgt: Codeunit "File Management";
        [InDataSet]
        UseEFT: Boolean;
        [InDataSet]
        EFTCA: Boolean;
        [InDataSet]
        EFTUS: Boolean;
}