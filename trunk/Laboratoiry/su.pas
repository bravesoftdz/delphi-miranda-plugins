function StringReplace(const S, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
var
  SearchStr, Patt, NewStr: string;
  Offset: Integer;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := AnsiUpperCase(S);
    Patt := AnsiUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := AnsiPos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then
    begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

function IsLeadChar(C: WideChar): Boolean;
begin
  Result := (C >= #$D800) and (C <= #$DFFF);
end;

function WrapText(const Line, BreakStr: string; const BreakChars: TSysCharSet;
  MaxCol: Integer): string;
const
  QuoteChars = ['''', '"'];
var
  Col, Pos: Integer;
  LinePos, LineLen: Integer;
  BreakLen, BreakPos: Integer;
  QuoteChar, CurChar: Char;
  ExistingBreak: Boolean;
  L: Integer;
begin
  Col := 1;
  Pos := 1;
  LinePos := 1;
  BreakPos := 0;
  QuoteChar := #0;
  ExistingBreak := False;
  LineLen := Length(Line);
  BreakLen := Length(BreakStr);
  Result := '';
  while Pos <= LineLen do
  begin
    CurChar := Line[Pos];
    if IsLeadChar(CurChar) then
    begin
      L := CharLength(Line, Pos) div SizeOf(Char) - 1;
      Inc(Pos, L);
      Inc(Col, L);
    end
    else
    begin
    if CurChar in QuoteChars then
      if QuoteChar = #0 then
        QuoteChar := CurChar
      else if CurChar = QuoteChar then
        QuoteChar := #0;
    if QuoteChar = #0 then
    begin
      if CurChar = BreakStr[1] then
      begin
        ExistingBreak := StrLComp(PChar(BreakStr), PChar(@Line[Pos]), BreakLen) = 0;
        if ExistingBreak then
        begin
          Inc(Pos, BreakLen-1);
          BreakPos := Pos;
        end;
      end;

      if not ExistingBreak then
        if CurChar in BreakChars then
          BreakPos := Pos;
      end;
    end;

    Inc(Pos);
    Inc(Col);

    if not (QuoteChar in QuoteChars) and (ExistingBreak or
      ((Col > MaxCol) and (BreakPos > LinePos))) then
    begin
      Col := 1;
      Result := Result + Copy(Line, LinePos, BreakPos - LinePos + 1);
      if not (CurChar in QuoteChars) then
      begin
        while Pos <= LineLen do
        begin
          if Line[Pos] in BreakChars then
          begin
            Inc(Pos);
            ExistingBreak := False;
          end
          else
          begin
            if StrLComp(PChar(@Line[Pos]), sLineBreak, Length(sLineBreak)) = 0 then
            begin
              Inc(Pos, Length(sLineBreak));
              ExistingBreak := True;
            end
            else
              Break;
          end;
        end;
      end;
      if (Pos <= LineLen) and not ExistingBreak then
        Result := Result + BreakStr;

      Inc(BreakPos);
      LinePos := BreakPos;
      Pos := LinePos;
      ExistingBreak := False;
    end;
  end;
  Result := Result + Copy(Line, LinePos, MaxInt);
end;

function WrapText(const Line: string; MaxCol: Integer): string;
begin
  Result := WrapText(Line, sLineBreak, [' ', '-', #9], MaxCol); { do not localize }
end;

