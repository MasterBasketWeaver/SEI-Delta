pageextension 80182 "BA Account Schedule" extends "Account Schedule"
{
    layout
    {
        addfirst(Control1)
        {
            field("BA Line No."; Rec."Line No.")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("BA Insert New Line")
            {
                ApplicationArea = all;
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Insert New Line';
                ToolTip = 'Inserts a new line, when teh default functionality fails';
                ShortcutKey = 'Ctrl+N';

                trigger OnAction()
                var
                    AccSchLine: Record "Acc. Schedule Line";
                    LineNo: Integer;
                    NewLineNo: Integer;
                    UpdatedLineNo: Integer;
                    CurrentLineNo: Integer;
                    Remainder: Integer;
                    NewLinesDict: Dictionary of [Integer, Integer];
                    LineNos: List of [Integer];
                begin
                    AccSchLine.SetRange("Schedule Name", Rec."Schedule Name");
                    if not AccSchLine.IsEmpty() then begin
                        AccSchLine.SetFilter("Line No.", '<%1', Rec."Line No.");
                        if AccSchLine.FindLast() then;
                        if (Rec."Line No." - AccSchLine."Line No.") < 2 then
                            NewLineNo := Rec."Line No."
                        else
                            NewLineNo := AccSchLine."Line No." + Round((Rec."Line No." - AccSchLine."Line No.") / 2, 1);

                        if AccSchLine.Get(Rec."Schedule Name", NewLineNo) then begin
                            CurrentLineNo := Rec."Line No.";
                            AccSchLine.SetRange("Line No.");
                            AccSchLine.Ascending(false);
                            if AccSchLine.FindSet() then begin
                                UpdatedLineNo := (AccSchLine.Count() + 1) * 10000;
                                repeat
                                    if AccSchLine."Line No." <> UpdatedLineNo then
                                        NewLinesDict.Add(AccSchLine."Line No.", UpdatedLineNo);
                                    if AccSchLine."Line No." = CurrentLineNo then begin
                                        NewLineNo := UpdatedLineNo - 10000;
                                        UpdatedLineNo -= 20000
                                    end else
                                        UpdatedLineNo -= 10000;
                                until AccSchLine.Next() = 0;

                                while NewLinesDict.Count() > 0 do begin
                                    LineNos := NewLinesDict.Keys();
                                    foreach LineNo in LineNos do begin
                                        UpdatedLineNo := NewLinesDict.Get(LineNo);
                                        if not AccSchLine.Get(Rec."Schedule Name", UpdatedLineNo) then begin
                                            AccSchLine.Get(Rec."Schedule Name", LineNo);
                                            AccSchLine.Rename(Rec."Schedule Name", UpdatedLineNo);
                                            NewLinesDict.Remove(LineNo);
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end else
                        NewLineNo := 10000;

                    AccSchLine.Init();
                    AccSchLine.Validate("Schedule Name", Rec."Schedule Name");
                    AccSchLine.Validate("Line No.", NewLineNo);
                    AccSchLine.Insert(true);
                    CurrPage.Update(true);
                    CurrPage.SetRecord(AccSchLine);
                end;
            }
        }
    }
}