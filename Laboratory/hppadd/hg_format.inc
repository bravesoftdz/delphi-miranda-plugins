{}
{ from SysUtils }
function IsLeadChar(C: WideChar): Boolean;
begin
  Result := (C >= #$D800) and (C <= #$DFFF);
end;

function StrCharLength(const Str: PWideChar): Integer;
begin
  if (Str^   >= #$D800) and (Str^   <= #$DBFF) and
     (Str[1] >= #$DC00) and (Str[1] <= #$DFFF) then
    Result := SizeOf(WideChar) * 2
  else
    Result := SizeOf(WideChar);
end;

function CharLength(const S: UnicodeString; Index: Integer): Integer;
begin
  Result := SizeOf(WideChar);
  if IsLeadChar(S[Index]) then
    Result := StrCharLength(PWideChar(S) + Index - 1);
end;

type
  TSysCharSet = set of AnsiChar;

function WrapText(const Line, BreakStr: WideString; const BreakChars: TSysCharSet;
  MaxCol: Integer): WideString;
const
  QuoteChars = ['''', '"'];
   sLineBreak = WideString(#13#10);
var
  Col, Pos: Integer;
  LinePos, LineLen: Integer;
  BreakLen, BreakPos: Integer;
  QuoteChar, CurChar: WideChar;
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
      L := CharLength(Line, Pos) div SizeOf(WideChar) - 1;
      Inc(Pos, L);
      Inc(Col, L);
    end
    else
    begin
    if AnsiChar(CurChar) in QuoteChars then
      if QuoteChar = #0 then
        QuoteChar := CurChar
      else if CurChar = QuoteChar then
        QuoteChar := #0;
    if QuoteChar = #0 then
    begin
      if CurChar = BreakStr[1] then
      begin
        ExistingBreak := StrCmpW(PWideChar(BreakStr), PWideChar(@Line[Pos]), BreakLen) = 0;
        if ExistingBreak then
        begin
          Inc(Pos, BreakLen-1);
          BreakPos := Pos;
        end;
      end;

      if not ExistingBreak then
        if AnsiChar(CurChar) in BreakChars then
          BreakPos := Pos;
      end;
    end;

    Inc(Pos);
    Inc(Col);

    if not (AnsiChar(QuoteChar) in QuoteChars) and (ExistingBreak or
      ((Col > MaxCol) and (BreakPos > LinePos))) then
    begin
      Col := 1;
      Result := Result + Copy(Line, LinePos, BreakPos - LinePos + 1);
      if not (AnsiChar(CurChar) in QuoteChars) then
      begin
        while Pos <= LineLen do
        begin
          if AnsiChar(Line[Pos]) in BreakChars then
          begin
            Inc(Pos);
            ExistingBreak := False;
          end
          else
          begin
            if StrCmpW(PWideChar(@Line[Pos]), sLineBreak, Length(sLineBreak)) = 0 then
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
{
function WrapText(const Line: WideString; MaxCol: Integer): WideString;
begin
  Result := WrapText(Line, sLineBreak, [' ', '-', #9], MaxCol);
end;
}


const
  Substs: array [0 .. 3] of array [0 .. 1] of WideString = (
    ('\n', #13#10),
    ('\t', #9),
    ('\\', '\'),
    ('\%', '%'));

const
  smes            = 0;
  sadj_mes        = 1;
  squot_mes       = 2;
  sselmes         = 3;
  sadj_selmes     = 4;
  squot_selmes    = 5;
  snick           = 6;
  sfrom_nick      = 7;
  sto_nick        = 8;
  sdatetime       = 9;
  ssmart_datetime = 10;
  sdate           = 11;
  stime           = 12;
const
  mtable : array [0..12] of
    record
      name: PWideChar;
    end = (
    (name: '%mes%'),
    (name: '%adj_mes%'),
    (name: '%quot_mes%'),
    (name: '%selmes%'),
    (name: '%adj_selmes%'),
    (name: '%quot_selmes%'),
    (name: '%nick%'),
    (name: '%from_nick%'),
    (name: '%to_nick%'),
    (name: '%datetime%'),
    (name: '%smart_datetime%'),
    (name: '%date%'),
    (name: '%time%')
  );
procedure THistoryGrid.IntFormatItem(Item: Integer; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);
var
  i, j, n, num: Integer;
  tok: TWideStrArray;
  toksp: TIntArray;
  subst: WideString;
  from_nick, to_nick, nick: pWideChar;
  dt: TDateTime;
  Mes, selmes: WideString;
  ws:pWideChar;
begin
  // item MUST be loaded before calling IntFormatItem!

  tok   := Tokens;
  toksp := SpecialTokens;

  Mes := FItems[Item].Text;
  if GridOptions.RawRTFEnabled and IsRTF(pWideChar(Mes)) then
  begin
    ApplyItemToRich(Item);
    Mes := GetRichString(FRich.Handle, False);
  end;

  if State = gsInline then
    selmes := GetRichString(FRichInline.Handle, True)
  else
    selmes := Mes;

  if IsIncomingEvent(FItems[Item]) then
  begin
    from_nick := ContactName;
    to_nick   := ProfileName;
  end
  else
  begin
    from_nick := ProfileName;
    to_nick   := ContactName;
  end;

  if Assigned(FGetNameData) then
    FGetNameData(Item, nick)
  else
    nick := from_nick;

  dt := TimestampToDateTime(FItems[Item].Time);

  for i := 0 to Length(toksp) - 1 do
  begin
    subst := '';
    if tok[toksp[i]][1] = '\' then
    begin
      for n := 0 to Length(Substs) - 1 do
        if tok[toksp[i]] = Substs[n][0] then
        begin
          subst := Substs[n][1];
          break;
        end;
    end
    else
    begin
      // we are doing many if's here, because I don't want to pre-compose all the
      // possible tokens into array. That's because some tokens take some time to
      // be generated, and if they're not used, this time would be wasted.
      ws:=pWideChar(tok[toksp[i]]);

      num:=-1;
      for j:=0 to HIGH(mtable) do
      begin
        if StrCmpW(ws,mtable[j].name)=0 then
        begin
          num:=j;
          break;
        end;
      end;

      case num of
        sMes: begin
          subst := Mes;
        end;

        sadj_mes: begin
          subst := WrapText(Mes, #13#10, [' ', #9, '-'], 72)
        end;

        squot_mes: begin
          subst := StringReplace('» ' + Mes, #13#10, #13#10 + '» ', [rfReplaceAll]);
          subst := WrapText(subst, #13#10 + '» ', [' ', #9, '-'], 70)
        end;

        sselmes: begin
          subst := selmes;
        end;

        sadj_selmes: begin
          subst := WrapText(selmes, #13#10, [' ', #9, '-'], 72);
        end;

        squot_selmes: begin
          subst := StringReplace('» ' + selmes, #13#10, #13#10 + '» ', [rfReplaceAll]);
          subst := WrapText(subst, #13#10 + '» ', [' ', #9, '-'], 70)
        end;

        snick: begin
          subst := nick;
        end;
        sfrom_nick: begin
          subst := from_nick;
        end;
        sto_nick: begin
          subst := to_nick;
        end;

        sdatetime: begin
//!!        subst := DateTime2StrShort(dt)
        end;
        ssmart_datetime: begin
//!!        subst := DateTime2StrShort(dt)
        end;
        sdate: begin
//!!        subst := Date2StrFmt('',dt)
        end;
        stime: begin
//!!        subst := Time2StrFmt('',dt);
        end;
      end;
    end;
    tok[toksp[i]] := subst;
  end;

  if Assigned(FGetNameData) then
    mFreeMem(nick);
end;

function THistoryGrid.FormatItems(ItemList: array of Integer; Format: WideString): WideString;
var
  ifrom, ito, step, i, n: Integer;
  tok2, tok: TWideStrArray;
  toksp, tok_smartdt: TIntArray;
  prevdt, dt: TDateTime;
begin
  // array of items MUST be a sorted list!

  Result := '';

  SetLength(tok_smartdt,0);
  TokenizeString(Format, tok, toksp);

  // detect if we have smart_datetime in the tokens
  // and cache them if we do
  for n := 0 to Length(toksp) - 1 do
    if tok[toksp[n]] = '%smart_datetime%' then
    begin
      SetLength(tok_smartdt, Length(tok_smartdt) + 1);
      tok_smartdt[High(tok_smartdt)] := toksp[n];
    end;
  dt := 0;
  prevdt := 0;

  // start processing all items

  // if Reversed then begin
  // from older to newer, excluding external grid
  if not ReversedHeader then
  begin
    ifrom := High(ItemList);
    ito   := 0;
    step  := -1;
  end
  else
  begin
    ifrom := 0;
    ito   := High(ItemList);
    step  := 1;
  end;
  i := ifrom;
  while (i >= 0) and (i <= High(ItemList)) do
  begin
    LoadItem(ItemList[i], False);
    tok2 := Copy(tok, 0, Length(tok));

    // handle smart dates:
    if Length(tok_smartdt) > 0 then
    begin
      dt := TimestampToDateTime(FItems[ItemList[i]].Time);
      if prevdt <> 0 then
        if Trunc(dt) = Trunc(prevdt) then
          for n := 0 to Length(tok_smartdt) - 1 do
            tok2[tok_smartdt[n]] := '%time%';
    end; // end smart dates

    IntFormatItem(ItemList[i], tok2, toksp);
    for n := 0 to Length(tok2) - 1 do
      Result := Result + tok2[n];

    if i <> ito then // do not put linebr after last item
      Result := Result + #13#10;
    prevdt := dt;
    Inc(i, step);
  end;
end;

function THistoryGrid.FormatSelected(const Format: WideString): WideString;
begin
  if SelCount = 0 then
    Result := ''
  else
    Result := FormatItems(FSelItems, Format);
end;

function THistoryGrid.GetSelectionString: WideString;
begin
  if FSelectionStored then
  begin
    Result := FSelectionString;
    exit;
  end
  else
    Result := '';
  if Count = 0 then
    exit;

  if State = gsInline then
    Result := GetRichString(FRichInline.Handle, True)
  else if Selected <> -1 then
  begin
    FSelectionString := FormatSelected(GridOptions.SelectionFormat);
    FSelectionStored := True;
    Result := FSelectionString;
  end;
end;
