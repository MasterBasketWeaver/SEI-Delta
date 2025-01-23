codeunit 75008 "BA Exp. Mapping Header EFT RB"
{
    TableNo = "Data Exch.";
    Permissions = tabledata "ACH RB Header" = rimd,
    tabledata "Data Exch." = rimd,
    tabledata "Data Exch. Line Def" = rimd;

    trigger OnRun()
    var
        ACHRBHeader: Record "ACH RB Header";
        DataExch: Record "Data Exch.";
        DataExchLineDef: Record "Data Exch. Line Def";
        EFTExportMgt: Codeunit "EFT Export Mgt";
        RecRef: RecordRef;
        LineNo: Integer;
    begin
        LineNo := 1;
        DataExchLineDef.Init();
        DataExchLineDef.SetRange("Data Exch. Def Code", "Data Exch. Def Code");
        DataExchLineDef.SetRange("Line Type", DataExchLineDef."Line Type"::Header);
        if DataExchLineDef.FindFirst() then
            if DataExch.Get(Rec."Entry No.") and ACHRBHeader.GET(Rec."Entry No.") then begin
                RecRef.GetTable(ACHRBHeader);
                EFTExportMgt.InsertDataExchLineForFlatFile(DataExch, LineNo, RecRef);
            end;
    end;
}