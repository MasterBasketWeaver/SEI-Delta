codeunit 75013 "BA Record Links Update"
{
    trigger OnRun()
    begin
        ImportUpdatedRecordLinks();
    end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Analysis View", 'OnBeforeBeforeCreateExcelFile', '', false, false)]
    // local procedure ExportRecordLinkToExcel(var ExcelBuffer: Record "Excel Buffer")
    // var
    //     FieldRec: Record Field;
    //     RecordLink: Record "Record Link";
    //     ExcelBuffer2: Record "Excel Buffer" temporary;
    //     RecRef: RecordRef;
    //     FldRef: FieldRef;
    //     Window: Dialog;
    //     BlobValue: Text;
    //     Flds: List of [Integer];
    //     RowNo: Integer;
    //     ColNo: Integer;
    //     FldNo: Integer;
    //     RecCount: Integer;
    //     i: Integer;
    // begin
    //     if UserId <> 'SEI-IND\BRYANBCDEV' then
    //         exit;

    //     if not RecordLink.FindSet() then
    //         exit;
    //     RecCount := RecordLink.Count();
    //     FieldRec.SetRange(TableNo, Database::"Record Link");
    //     FieldRec.FindSet();

    //     repeat
    //         Flds.Add(FieldRec."No.");
    //     until FieldRec.Next() = 0;



    //     RecRef.Open(Database::"Record Link");
    //     RowNo := 1;
    //     foreach FldNo in Flds do begin
    //         ColNo += 1;
    //         FldRef := RecRef.Field(FldNo);
    //         ExcelBuffer2.AddColumn(FldRef.Caption, false, '', true, false, true, '', ExcelBuffer2."Cell Type"::Text);
    //     end;
    //     RecRef.Close();
    //     Window.Open('#1###');
    //     repeat
    //         i += 1;
    //         Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
    //         if (RecordLink.URL1 <> '') or (RecordLink.URL2 <> '') or (RecordLink.URL3 <> '') or (RecordLink.URL4 <> '') then begin
    //             RecRef.GetTable(RecordLink);
    //             RowNo += 1;
    //             ColNo := 0;

    //             foreach FldNo in Flds do begin
    //                 ColNo += 1;
    //                 FldRef := RecRef.Field(FldNo);
    //                 if FldRef.Type = FldRef.Type::Blob then begin
    //                     if TryToReadBlob(FldRef, BlobValue) then;
    //                     ExcelBuffer2.EnterCell(ExcelBuffer2, RowNo, ColNo, BlobValue, false, false, false)
    //                 end else
    //                     ExcelBuffer2.EnterCell(ExcelBuffer2, RowNo, ColNo, FldRef.Value(), false, false, false);
    //             end;
    //             RecRef.Close();
    //         end;
    //     until RecordLink.Next() = 0;
    //     Window.Close();

    //     WriteNewSheet(ExcelBuffer2, ExcelBuffer);
    // end;


    [TryFunction]
    local procedure TryToReadBlob(var FldRef: FieldRef; var BlobValue: Text)
    begin
        BlobValue := '';
        BlobValue := TypeHelper.ReadBlob(FldRef);
    end;


    local procedure WriteNewSheet(var NewBuffer: Record "Excel Buffer"; var OldBuffer: Record "Excel Buffer")
    var
        c: Char;
        c2: Char;
        ColText: Text;
        i: Integer;
        i2: Integer;
        HasValue: array[5] of Boolean;
    begin
        with NewBuffer do begin
            OldBuffer.SelectOrAddSheet('Record Links');
            SetFilter("Cell Value as Text", '<>%1', '');
            SetFilter("Row No.", '>%1', 1);
            for i := 1 to 5 do begin
                SetRange("Column No.", i + 2);
                HasValue[i] := not IsEmpty();
            end;

            Reset();
            SetRange("Row No.", 1);
            if FindSet then
                repeat
                    i := "Column No." - 1;
                    if i <= 25 then begin
                        c := 'A' + i;
                        ColText := Format(c);
                    end else begin
                        c := 'A' + i Mod 26;
                        c2 := 'A' + Round(i / 26, 1);
                        ColText := Format(c2) + Format(c);
                    end;
                    if c = 'B' then
                        OldBuffer.SetColumnWidth(ColText, 30)
                    else
                        if (c >= 'C') and (c <= 'G') then begin
                            i2 += 1;
                            if HasValue[i2] then
                                OldBuffer.SetColumnWidth(ColText, 60)
                            else
                                OldBuffer.SetColumnWidth(ColText, 10);
                        end else
                            OldBuffer.SetColumnWidth(ColText, 10);
                    OldBuffer.WriteCellValue(NewBuffer);
                until Next = 0;
            SetFilter("Row No.", '>%1', 1);
            if FindSet then
                repeat
                    OldBuffer.WriteCellValue(NewBuffer);
                until Next = 0;
        end;

        NewBuffer.Reset();
        OldBuffer.Reset();

        // if not Confirm('%1 -> %2', false, OldBuffer.Count, NewBuffer.Count) then
        //     Error('');
    end;





    procedure ImportUpdatedRecordLinks()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ExcelBuffer2: Record "Excel Buffer" temporary;
        ErrorBuffer: Record "Name/Value Buffer" temporary;
        TempBlob: Record TempBlob;
        RecordLink: Record "Record Link";
        FileMgt: Codeunit "File Management";
        RecRef: RecordRef;
        RecID: RecordId;
        IStream: InStream;
        Window: Dialog;
        FileName: Text;
        RecCount: Integer;
        i: Integer;
        i2: Integer;
        TempInt: Integer;
    begin
        if FileMgt.BLOBImportWithFilter(TempBlob, 'Select Updated Record Links List', '', 'Excel|*.xlsx', 'Excel|*.xlsx') = '' then
            exit;
        TempBlob.Blob.CreateInStream(IStream);
        if not ExcelBuffer.GetSheetsNameListFromStream(IStream, ErrorBuffer) then
            Error('No Sheets in file.');
        ErrorBuffer.FindFirst();
        ExcelBuffer.OpenBookStream(IStream, ErrorBuffer.Value);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SetFilter("Row No.", '>%1', 1);
        ExcelBuffer.SetRange("Column No.", 1, 3);
        ExcelBuffer.SetFilter("Cell Value as Text", '<>%1', '');
        if not ExcelBuffer.FindSet() then
            exit;
        repeat
            ExcelBuffer2 := ExcelBuffer;
            ExcelBuffer2.Insert(false);
        until ExcelBuffer.Next() = 0;

        ExcelBuffer.SetRange("Column No.", 1);
        RecCount := ExcelBuffer.Count();
        ExcelBuffer.FindSet();
        Window.Open('#1####');

        repeat
            i += 1;
            Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
            if Evaluate(TempInt, ExcelBuffer."Cell Value as Text") then
                if RecordLink.Get(TempInt) then begin
                    ExcelBuffer2.Get(ExcelBuffer."Row No.", 2);
                    if Evaluate(RecID, ExcelBuffer2."Cell Value as Text") then
                        if RecRef.Get(RecordLink."Record ID") then begin
                            ExcelBuffer2.Get(ExcelBuffer."Row No.", 3);
                            RecordLink.URL1 := CopyStr(ExcelBuffer2."Cell Value as Text", 1, MaxStrLen(RecordLink.URL1));
                            RecordLink.Modify(false);
                            i2 += 1;
                        end;
                end;
        until ExcelBuffer.Next() = 0;
        Window.Close();

        Message('Updated %1 of %2.', i2, RecCount);
    end;




    var
        TypeHelper: Codeunit "Type Helper";
}