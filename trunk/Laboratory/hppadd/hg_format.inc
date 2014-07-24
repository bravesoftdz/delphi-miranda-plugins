{}
type
  TSysCharSet = set of AnsiChar;

function WrapText(const Line, BreakStr: PWideChar; const BreakChars: TSysCharSet;
  MaxCol: Integer): PWideChar;
const
  QuoteChars = ['''', '"'];
  sLineBreak = #13#10;
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
  LinePos  := 1;
  BreakPos := 0;
  QuoteChar := #0;
  ExistingBreak := False;
  LineLen  := StrLenW(Line);
  BreakLen := StrLenW(BreakStr);
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

    if not (AnsiChar(QuoteChar) in QuoteChars) and
      (ExistingBreak or ((Col > MaxCol) and (BreakPos > LinePos))) then
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
            if StrCmpW(PWideChar(@Line[Pos]), sLineBreak, 2{Length(sLineBreak)}) = 0 then
            begin
              Inc(Pos, 2{Length(sLineBreak)});
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
  Substs: array [0 .. 3] of array [0 .. 1] of PWideChar = (
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
  mtable : array [0..12] of PWideChar = (
    '%mes%',
    '%adj_mes%',
    '%quot_mes%',
    '%selmes%',
    '%adj_selmes%',
    '%quot_selmes%',
    '%nick%',
    '%from_nick%',
    '%to_nick%',
    '%datetime%',
    '%smart_datetime%',
    '%date%',
    '%time%'
  );
procedure THistoryGrid.IntFormatItem(Item: Integer; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);
var
  tok: TWideStrArray;
  toksp: TIntArray;
  FRich: PHPPRichEdit;
  from_nick, to_nick, nick: pWideChar;
  ws:pWideChar;
  Mes, selmes: PWideChar;
  subst: PWideChar;
  i, j, n, num: Integer;
  ts: DWord;
begin
  // item MUST be loaded before calling IntFormatItem!

  tok   := Tokens;
  toksp := SpecialTokens;

  Mes := FItems[Item].Text;
  if GridOptions.RawRTFEnabled and IsRTF(pWideChar(Mes)) then
  begin
    FRich := GetRichFromCache(Item);
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

  ts := FItems[Item].Time;

  for i := 0 to HIGH(toksp) do
  begin
    subst := nil;
    if tok[toksp[i]][0] = '\' then
    begin
      for n := 0 to HIGH(Substs) do
        if StrCmpW(tok[toksp[i]], Substs[n][0])=0 then
        begin
          StrDupW(subst, Substs[n][1]);
          break;
        end;
    end
    else
    begin
      ws:=pWideChar(tok[toksp[i]]);
      num:=-1;
      for j:=0 to HIGH(mtable) do
      begin
        if StrCmpW(ws,mtable[j])=0 then
        begin
          num:=j;
          break;
        end;
      end;

      case num of
        sMes: begin
          StrDupW(subst, Mes);
        end;

        sadj_mes: begin
          subst := WrapText(Mes, #13#10, [' ', #9, '-'], 72)
        end;

        squot_mes: begin
          subst := StringReplace('» ' + Mes, #13#10, #13#10 + '» ', [rfReplaceAll]);
          subst := WrapText(subst, #13#10 + '» ', [' ', #9, '-'], 70)
        end;

        sselmes: begin
          StrDupW(subst, selmes);
        end;

        sadj_selmes: begin
          subst := WrapText(selmes, #13#10, [' ', #9, '-'], 72);
        end;

        squot_selmes: begin
          subst := StringReplace('» ' + selmes, #13#10, #13#10 + '» ', [rfReplaceAll]);
          subst := WrapText(subst, #13#10 + '» ', [' ', #9, '-'], 70)
        end;

        // nicknames
        snick: begin
          StrDupW(subst, nick);
        end;
        sfrom_nick: begin
          StrDupW(subst, from_nick);
        end;
        sto_nick: begin
          StrDupW(subst, to_nick);
        end;

        // date / time
        sdatetime: begin
          subst := DateTimeToStr(ts);
        end;
        ssmart_datetime: begin
          subst := DateTimeToStr(ts);
        end;
        sdate: begin
          subst := DateToStr(ts);
        end;
        stime: begin
          subst := TimeToStr(ts);
        end;
      end;
    end;
    tok[toksp[i]] := subst;
  end;

  if State = gsInline then // selmes <> Mes
    mFreeMem(selmes);

  if Mes <> FItems[Item].Text then
    mFreeMem(Mes);

  if Assigned(FGetNameData) then
    mFreeMem(nick);
end;

function THistoryGrid.FormatItems(ItemList: array of Integer; Format: PWideChar): PWideChar;
var
  tok2, tok: TWideStrArray;
  toksp, tok_smartdt: TIntArray;
  prevdt, dt: TDateTime;
  ifrom, ito, step, i, n, len: Integer;
begin
  // array of items MUST be a sorted list!

  Result := nil;

  SetLength(tok_smartdt,0);
  TokenizeString(Format, tok, toksp);

  // detect if we have smart_datetime in the tokens
  // and cache them if we do
  for n := 0 to Length(toksp) - 1 do
    if StrCmpW(tok[toksp[n]], '%smart_datetime%')=0 then
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
    tok2 := Copy(tok, 0, Length(tok)); //!!

    // handle smart dates:
    if Length(tok_smartdt) > 0 then
    begin
      dt := TimestampToDateTime(FItems[ItemList[i]].Time);
      if prevdt <> 0 then
        if Trunc(dt) = Trunc(prevdt) then
          for n := 0 to HIGH(tok_smartdt) do
          begin
            tok2[tok_smartdt[n]] := '%time%'; //!!
          end;
    end; // end smart dates

    IntFormatItem(ItemList[i], tok2, toksp);

    // calc current item text length
    len:=1;
    for n := 0 to HIGH(tok2) do
      inc(len, StrLenW(tok2[n]));

    if i <> ito then // do not put linebr after last item
      inc(len,2);

    //!! create item text or reallocate and fill main buffer?
    mGetMem(pc, (StrLenW(Result) + len) * SizeOf(WideChar));
    StrCopyW(pc, Result);
    mFreeMem(Result);
    Result:=pc; pc:=StrEnd(pc);

    for n := 0 to HIGH(tok2) do
      pc := StrCopyEW(pc, tok2[n]);

    if i <> ito then // do not put linebr after last item
    begin
      pc^:=#13; inc(pc);
      pc^:=#10; inc(pc);
      pc^:=#0;
    end;

    prevdt := dt;
    Inc(i, step);
  end;

  for i = 0 to HIGH(tok) do
  begin
    mFreeMem(tok[i]);
//!!!!    mFreeMem(tok2[i]);
  end;

  tok        :=nil;
  tok2       :=nil;
  toksp      :=nil;
  tok_smartdt:=nil;
end;

function THistoryGrid.FormatSelected(const Format: PWideChar): PWideChar;
begin
  if SelCount = 0 then
    Result := nil
  else
    Result := FormatItems(FSelItems, Format);
end;

function THistoryGrid.FormatItem(Item: Integer; Format: PWideChar): PWideChar;
var
  tok: TWideStrArray;
  toksp: TIntArray;
  pc:PWideChar;
  i: Integer;
begin
  TokenizeString(Format, tok, toksp);
  LoadItem(Item, False);
  IntFormatItem(Item, tok, toksp);
  len := 0;
  for i := 0 to HIGH(tok) do
    inc(len, StrLenW(tok[i]));
  if len>0 then
  begin
    mGetMem(pc, (len + 1) * SizeOf(WideChar));
    Result := pc;
    for i := 0 to HIGH(tok) do
      pc := StrCopyEW(pc, tok[i]);

    for i = 0 to HIGH(tok) do
    begin
      mFreeMem(tok[i]);
    end;

    tok  :=nil;
    toksp:=nil;
  end
  else
    Result := nil;
end;
