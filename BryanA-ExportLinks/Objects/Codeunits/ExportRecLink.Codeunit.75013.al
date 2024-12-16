codeunit 75013 "BA Export Record Link2"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export Analysis View", 'OnBeforeBeforeCreateExcelFile', '', false, false)]
    local procedure ExportRecordLinkToExcel(var ExcelBuffer: Record "Excel Buffer")
    var
        FieldRec: Record Field;
        RecordLink: Record "Record Link";
        ExcelBuffer2: Record "Excel Buffer" temporary;
        RecRef: RecordRef;
        FldRef: FieldRef;
        Window: Dialog;
        BlobValue: Text;
        Flds: List of [Integer];
        RowNo: Integer;
        ColNo: Integer;
        FldNo: Integer;
        RecCount: Integer;
        i: Integer;
    begin
        if UserId <> 'SEI-IND\BRYANBCDEV' then
            exit;

        if not RecordLink.FindSet() then
            exit;
        RecCount := RecordLink.Count();
        FieldRec.SetRange(TableNo, Database::"Record Link");
        FieldRec.FindSet();

        repeat
            Flds.Add(FieldRec."No.");
        until FieldRec.Next() = 0;



        RecRef.Open(Database::"Record Link");
        RowNo := 1;
        foreach FldNo in Flds do begin
            ColNo += 1;
            FldRef := RecRef.Field(FldNo);
            ExcelBuffer2.AddColumn(FldRef.Caption, false, '', true, false, true, '', ExcelBuffer2."Cell Type"::Text);
        end;
        RecRef.Close();
        Window.Open('#1###');
        repeat
            i += 1;
            Window.Update(1, StrSubstNo('%1 of %2', i, RecCount));
            if (RecordLink.URL1 <> '') or (RecordLink.URL2 <> '') or (RecordLink.URL3 <> '') or (RecordLink.URL4 <> '') then begin
                RecRef.GetTable(RecordLink);
                RowNo += 1;
                ColNo := 0;

                foreach FldNo in Flds do begin
                    ColNo += 1;
                    FldRef := RecRef.Field(FldNo);
                    if FldRef.Type = FldRef.Type::Blob then begin
                        if TryToReadBlob(FldRef, BlobValue) then;
                        ExcelBuffer2.EnterCell(ExcelBuffer2, RowNo, ColNo, BlobValue, false, false, false)
                    end else
                        ExcelBuffer2.EnterCell(ExcelBuffer2, RowNo, ColNo, FldRef.Value(), false, false, false);
                end;
                RecRef.Close();
            end;
        until RecordLink.Next() = 0;
        Window.Close();

        WriteNewSheet(ExcelBuffer2, ExcelBuffer);
    end;


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


    var
        TypeHelper: Codeunit "Type Helper";
}