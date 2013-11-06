{}
function THistoryGrid.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function THistoryGrid.GetBottomItem: Integer;
begin
  if Reversed then
    Result := GetUp(-1)
  else
    Result := GetUp(Count);
end;

function THistoryGrid.GetTopItem: Integer;
begin
  if Reversed then
    Result := GetDown(Count)
  else
    Result := GetDown(-1);
end;

(* Index to Position *)
function THistoryGrid.GetIdx(Index: Integer): Integer;
begin
  if Reversed then
    Result := Count - 1 - Index
  else
    Result := Index;
end;

function THistoryGrid.IsUnknown(Index: Integer): Boolean;
begin
  Result := (FItems[Index].MessageType.code=mtUnknown);
end;

function THistoryGrid.IsMatched(Index: Integer): Boolean;
var
  mts: THppMessageType;
begin
  mts := FItems[Index].MessageType;
  //!! need in/out filter check too
  Result := mts.code in FFilter;

  if Assigned(FOnItemFilter) then
    FOnItemFilter(Index, Result);
end;

function THistoryGrid.GetItemRect(Item: Integer): TRect;
var
  tmp, idx, SumHeight: Integer;
  succ: Boolean;
begin
  SetRectEmpty(Result);
  SumHeight := -TopItemOffset;
  if Item = -1 then
    exit;
  if not IsMatched(Item) then
    exit;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then
  begin
    idx := GetFirstVisible;
    tmp := GetUp(idx);
    if tmp <> -1 then
      idx := tmp;
    { .TODO: fix here, don't go up, go down from 0 }
    if Reversed then
      succ := (idx <= Item)
    else
      succ := (idx >= Item);
    while succ do
    begin
      LoadItem(idx);
      Inc(SumHeight, FItems[idx].Height);
      idx := GetPrev(idx);
      if idx = -1 then
        break;
      if Reversed then
        succ := (idx <= Item)
      else
        succ := (idx >= Item);
    end;
    {
      for i := VertScrollBar.Position-1 downto Item do begin
      LoadItem(i);
      Inc(SumHeight,FItems[i].Height);
      end;
    }
    SetRect(Result, 0, -SumHeight, FClientRect.Right, -SumHeight + FItems[Item].Height);
    exit;
  end;

  idx := GetFirstVisible; // GetIdx(VertScrollBar.Position);

  while GetIdx(idx) < GetIdx(Item) do
  begin
    LoadItem(idx);
    Inc(SumHeight, FItems[idx].Height);
    idx := GetNext(idx);
    if idx = -1 then
      break;
  end;

  SetRect(Result, 0, SumHeight, FClientRect.Right, SumHeight + FItems[Item].Height);
end;

//----- navigation -----
function THistoryGrid.GetDown(Item: Integer): Integer;
begin
  Result := GetNext(Item, False);
end;

function THistoryGrid.GetUp(Item: Integer): Integer;
begin
  Result := GetPrev(Item, False);
end;

function THistoryGrid.GetNext(Item: Integer; Force: Boolean = False): Integer;
var
  Max: Integer;
  WasLoaded: Boolean;
begin
  Result := -1;

  if not Force then
    if Reversed then
    begin
      Result := GetPrev(Item, True);
      exit;
    end;
  Inc(Item);
  Max := Count - 1;
  WasLoaded := False;

  if Item < 0 then
    Item := 0;

  while (Item >= 0) and (Item < Count) do
  begin
    if ShowProgress then
      WasLoaded := not IsUnknown(Item);

    LoadItem(Item, False);

    if (State = gsLoad) and ShowProgress and (not WasLoaded) then
      DoProgress(Item, Max);

    if IsMatched(Item) then
    begin
      Result := Item;
      break;
    end;
    Inc(Item);
  end;

  if (State = gsLoad) and ShowProgress then
  begin
    ShowProgress := False;
    DoProgress(0, 0);
  end;
end;

function THistoryGrid.GetPrev(Item: Integer; Force: Boolean = False): Integer;
begin
  Result := -1;
  if not Force then
    if Reversed then
    begin
      Result := GetNext(Item, True);
      exit;
    end;
  Dec(Item);

  if Item >= Count then
    Item := Count - 1;

  while (Item < Count) and (Item >= 0) do
  begin
    LoadItem(Item, False);
    if IsMatched(Item) then
    begin
      Result := Item;
      break;
    end;
    Dec(Item);
  end;
end;

function THistoryGrid.GetFirstVisible: Integer;
var
  Pos: Integer;
begin
  Pos := SBPosition;
  if MaxSBPos > -1 then
    Pos := Min(MaxSBPos, SBPosition);

  Result := GetDown(GetIdx(Pos - 1));
  if Result = -1 then
    Result := GetUp(GetIdx(Pos + 1));
end;
(*
  Return is item is visible on client area
  EVEN IF IT IS *PARTIALLY* VISIBLE
*)
function THistoryGrid.IsVisible(Item: Integer; Partially: Boolean = True): Boolean;
var
  idx, SumHeight: Integer;
begin
  Result := False;
  if Item = -1 then
    exit;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then
    exit;
  if not IsMatched(Item) then
    exit;
  SumHeight := -TopItemOffset;
  idx := GetFirstVisible;
  LoadItem(idx, True);
  while (SumHeight < FClientRect.Bottom) and (Item <> -1) and (Item < Count) do
  begin
    if Item = idx then
    begin
      if Partially then
        Result := True
      else
        Result := (SumHeight + FItems[idx].Height <= FClientRect.Bottom);
      break;
    end;
    Inc(SumHeight, FItems[idx].Height);
    idx := GetNext(idx);
    if idx = -1 then
      break;
    LoadItem(idx, True);
  end;
end;

procedure THistoryGrid.MakeVisible(Item: Integer);
var
  first: Integer;
  SumHeight: Integer;
  BottomAlign: Boolean;
begin
  BottomAlign := ShowBottomAligned and Reversed;
  ShowBottomAligned := False;
  if Item = -1 then
    exit;
  // load it to make positioning correct
  LoadItem(Item, True);
  if not IsMatched(Item) then
    exit;
  first := GetFirstVisible;
  if Item = first then
  begin
   if FItems[Item].Height > FClientRect.Bottom then
    begin
      if BottomAlign or (TopItemOffset > FItems[Item].Height - FClientRect.Bottom) then
      begin
        TopItemOffset := FItems[Item].Height - FClientRect.Bottom;
      end;
      ScrollGridBy(0, False);
    end
    else
      ScrollGridBy(-TopItemOffset, False);
  end
  else if GetIdx(Item) < GetIdx(first) then
    SetSBPos(GetIdx(Item))
  else
  begin
    // if IsVisible(Item) then exit;
    if IsVisible(Item, False) then
      exit;
    SumHeight := 0;
    first := Item;
    while (Item >= 0) and (Item < Count) do
    begin
      LoadItem(Item, True);
      if (SumHeight + FItems[Item].Height) >= FClientRect.Bottom then
        break;
      Inc(SumHeight, FItems[Item].Height);
      Item := GetUp(Item);
    end;

    if GetIdx(Item) >= MaxSBPos then
    begin
      SetSBPos(GetIdx(Item) + 1);
      // strange, but if last message is bigger then client,
      // it always scrolls to down, but grid thinks, that it's
      // aligned to top (when entering inline mode, for ex.)
      if Item = first then
        TopItemOffset := 0;
    end
    else
    begin
      SetSBPos(GetIdx(Item));
      if Item <> first then
        TopItemOffset := (SumHeight + FItems[Item].Height) - FClientRect.Bottom;
    end;

  end;
end;

function THistoryGrid.CalcItemHeight(Item: Integer): Integer;
var
  hh, h: Integer;
begin
  Result := -1;
  if IsUnknown(Item) then
    exit;

  ApplyItemToRich(Item);
  // rude hack, but what the fuck??? First item with rtl chars is 1 line heighted always
  // probably fixed, see RichCache.ApplyItemToRich
  if FRichHeight <= 0 then
    exit
  else
    h := FRichHeight;

  if FGroupLinked and FItems[Item].LinkedToPrev then
    hh := 0
  else if IsIncomingEvent(FItems[Item]) then
    hh := CHeaderHeight
  else
    hh := PHeaderheight;

  { If you change this, be sure to check out DoMouseMove,
    DoLButtonDown, DoRButtonDown where I compute offset for
    clicking & moving over invisible off-screen rich edit
    control }
  // compute height =
  // 1 pix -- border
  // 2*padding
  // text height
  // + HEADER_HEIGHT header
  Result := 1 + 2 * Padding + h + hh;
  if (FItems[Item].HasHeader) and (ShowHeaders) and (ExpandHeaders) then
    Inc(Result, SessHeaderHeight);
end;

procedure THistoryGrid.LoadItem(Item: Integer; LoadHeight: Boolean = True; Reload: Boolean = False);
begin
  if Reload or IsUnknown(Item) then
    if Assigned(FGetItemData) then
      OnItemData(Item, FItems[Item]);

  if LoadHeight then
    if FItems[Item].Height = -1 then
      FItems[Item].Height := CalcItemHeight(Item);
end;

function THistoryGrid.GetItems(Index: Integer): THistoryItem;
begin
  if (Index < 0) or (Index > High(FItems)) then
    exit;

  if IsUnknown(Index) then
    LoadItem(Index, False);

  Result := FItems[Index];
end;

function THistoryGrid.GetItemRTL(Item: Integer): Boolean;
begin
  if FItems[Item].RTLMode = hppRTLDefault then
  begin
    if RTLMode = hppRTLDefault then
      Result := GridOptions.RTLEnabled
    else
      Result := (RTLMode = hppRTLEnable);
  end
  else
    Result := (FItems[Item].RTLMode = hppRTLEnable)
end;

function MakeColorLines(Color:TCOLORREF):AnsiString;
var
  b1,b2,b3:array [0..3] of AnsiChar;
begin
  result:=AnsiString('\red'  )+IntToStr(b1, Color and $FF)+
          AnsiString('\green')+IntToStr(b2,(Color shr   8) and $FF)+
          AnsiString('\blue' )+IntToStr(b3,(Color shr  16) and $FF)+';'
end;

function MakeFontSettingStr(pFont:pLogFontW;LogY:integer):AnsiString;
var
  buf: array [0..31] of AnsiChar;
begin
  StrCopy(buf,'\f0\b0\i0\ul0\strike0\fs');
  buf[5 ]:=AnsiChar(ORD('0')+integer(pFont.lfWeight>=700));
  buf[8 ]:=AnsiChar(ORD('0')+pFont.lfItalic);
  buf[12]:=AnsiChar(ORD('0')+pFont.lfUnderline);
  buf[20]:=AnsiChar(ORD('0')+pFont.lfStrikeOut);
  IntToStr(PAnsiChar(@buf[24]),(-(pFont.lfHeight * 72) div LogY) shl 1);
  result:=buf;
end;

function MakeFontTableElement(pFont:pLogFontW):AnsiString;
var
  buf:array [0..LF_FACESIZE+3+31] of AnsiChar;
  p:pAnsiChar;
begin
  p:=StrCopyE(buf,'{\f0\fnil\fcharset');
  IntToStr(p,pFont.lfCharSet); p:=StrEnd(p);
  p^:=' '; inc(p);
  FastWideToAnsiBuf(pFont.lfFaceName,p);
  p:=StrEnd(p);
  p^:='}'; inc(p); p^:=#0;
  result:=buf;
end;

procedure THistoryGrid.ApplyItemToRich(Item: Integer; aRichEdit: PHPPRichEdit = nil; ForceInline: Boolean = False);
var
  reItemInline: Boolean;
  reItemSelected: Boolean;
  reItemUseFormat: Boolean;
  reItemUseLinkColor: Boolean;
  textColor, BackColor: TCOLORREF;
  RichItem: PRichItem;
  RTF, lText: AnsiString;
  cf, cf2: CharFormat2;
  numItem:integer;
  pFont:PLogFontW;
begin
  // get from cache
  if aRichEdit = nil then
  begin
    RichItem := FRichCache.RequestItem(Item);
    FRich := RichItem^.Rich;
    FRichHeight := RichItem^.Height;
    exit;
  end;

  reItemInline := ForceInline or (aRichEdit = FRichInline);
  reItemSelected := (not reItemInline) and IsSelected(Item);
  reItemUseFormat := not(reItemInline) or GridOptions.TextFormatting;
//  reItemUseFormat := not(reItemInline and (not GridOptions.TextFormatting));

  reItemUseLinkColor := not(GridOptions.ColorBack[fiLink] = CustomGraph.clBlue);

  if not reItemInline then
    FRich := aRichEdit;

  //!!
  numItem:=GridOptions.GetItemIndex(FItems[Item].MessageType);
  pFont:=@GridOptions.ItemOptions[numItem].textFont;
  if reItemSelected then
  begin
    textColor := GridOptions.ColorText[fiSelected];
    BackColor := GridOptions.ColorBack[fiSelected];
  end
  else
  begin
    textColor := GridOptions.ItemOptions[numItem].textColor;
    BackColor := GridOptions.ItemOptions[numItem].textBkColor;
  end;

  SendMessage(aRichEdit.Handle, WM_SETTEXT,0,0);
//  aRichEdit.Clear;

  SetRichRTL(GetItemRTL(Item), aRichEdit);
  // for use with WM_COPY
//??  aRichEdit.Codepage := FItems[Item].Codepage;

  if reItemUseFormat and GridOptions.RawRTFEnabled and IsRTF(FItems[Item].Text) then
  begin
    // stored text seems to be RTF
    RTF := WideToAnsiString(FItems[Item].Text, FItems[Item].Codepage) + #0
  end
  else
  begin
    RTF := '{\rtf1\ansi\deff0{\fonttbl ';
    // RTF := Format('{\rtf1\ansi\ansicpg%u\deff0\deflang%u{\fonttbl ',[FItems[Item].Codepage,GetLCIDfromCodepage(CodePage)]);
//    RTF := RTF + AnsiString(Format('{\f0\fnil\fcharset%u %s}', [textFont.FontCharSet, textFont.FontName]));
    RTF := RTF + MakeFontTableElement(pFont);
    RTF := RTF + '}{\colortbl';
    RTF := RTF + MakeColorLines(textColor);
    RTF := RTF + MakeColorLines(BackColor);
    // add color table for BBCodes
    if GridOptions.BBCodesEnabled then
    begin
      // link color ro [url][/url], [img][/img]
      RTF := RTF + MakeColorLines(GridOptions.ColorText[fiLink]);
      if reItemUseFormat then
        RTF := RTF + rtf_ctable_text;
    end;
    RTF := RTF + '}\li30\ri30\fi0\cf0';

    if GetItemRTL(Item) then
      RTF := RTF + '\rtlpar\ltrch\rtlch '
    else
      RTF := RTF + '\ltrpar\rtlch\ltrch ';

    RTF := RTF + MakeFontSettingStr(pFont,LogY);
// RE_FmtFontSize
    lText := FormatString2RTFW(FItems[Item].Text);
    { if FGroupLinked and FItems[Item].LinkedToPrev then
      Text := FormatString2RTF(GetTime(FItems[Item].Time)+': '+FItems[Item].Text) else
      Text := FormatString2RTF(FItems[Item].Text); }
    if GridOptions.BBCodesEnabled and reItemUseFormat then
      lText := DoSupportBBCodesRTF(lText, 3, not reItemSelected);
    RTF := RTF + lText + '\par }';
  end;

//  aRichEdit.RE_Text[reRTF,false]:=RTF;
  SetRichRTFA(aRichEdit.Handle, RTF, False, False, True);
  SendMessage(aRichEdit.Handle, EM_SETBKGNDCOLOR, 0, BackColor);

  if reItemUseFormat and Assigned(FOnProcessRichText) then
  begin
    try
      FOnProcessRichText(aRichEdit.Handle, Item);
    except
    end;

    if reItemUseLinkColor or reItemSelected or reItemInline then
    begin
      ZeroMemory(@cf, SizeOf(cf));
      cf.cbSize := SizeOf(cf);
      ZeroMemory(@cf2, SizeOf(cf2));
      cf2.cbSize := SizeOf(cf2);
      // do not allow change backcolor of selection
      if reItemSelected then
      begin
        // change CFE_LINK to CFE_REVISED
        cf.dwMask    := CFM_LINK;
        cf.dwEffects := CFE_LINK;
        cf2.dwMask    := CFM_LINK or CFM_REVISED;
        cf2.dwEffects := CFE_REVISED;
        ReplaceCharFormat(RichEdit.Handle, cf, cf2);
        cf.dwMask      := CFM_COLOR;
        cf.crTextColor := textColor;
        SendMessage(aRichEdit.Handle, EM_SETBKGNDCOLOR, 0, BackColor);
        SendMessage(aRichEdit.Handle, EM_SETCHARFORMAT, SCF_ALL, lParam(@cf));
      end
      else if reItemInline then
      begin
        // change CFE_REVISED to CFE_LINK
        cf.dwMask    := CFM_REVISED;
        cf.dwEffects := CFE_REVISED;
        cf2.dwMask    := CFM_LINK or CFM_REVISED;
        cf2.dwEffects := CFM_LINK;
        ReplaceCharFormat(RichEdit.Handle, cf, cf2);
      end
      else
      begin
        // change CFE_REVISED to CFE_LINK and its color
        cf.dwMask    := CFM_LINK;
        cf.dwEffects := CFE_LINK;
        cf2.dwMask      := CFM_LINK or CFM_REVISED or CFM_COLOR;
        cf2.dwEffects   := CFE_REVISED;
        cf2.crTextColor := GridOptions.ColorText[fiLink]; //?? check
        ReplaceCharFormat(RichEdit.Handle, cf, cf2);
      end;
    end;

  end;

end;

procedure THistoryGrid.ApplyItemToRichCache(Item: Integer; aRichEdit: PHPPRichEdit);
begin
  ApplyItemToRich(Item,aRichEdit);
end;

function THistoryGrid.FindItemAt(X, Y: Integer; out ItemRect: TRect): Integer;
var
  SumHeight: Integer;
  idx: Integer;
begin
  Result := -1;
  SetRectEmpty(ItemRect);
  if Count = 0 then
    exit;

  SumHeight := TopItemOffset;
  if Y < 0 then
  begin
    idx := GetFirstVisible;
    while idx >= 0 do
    begin
      if Y > -SumHeight then
      begin
        Result := idx;
        break;
      end;
      idx := GetPrev(idx);
      if idx = -1 then
        break;
      LoadItem(idx, True);
      Inc(SumHeight, FItems[idx].Height);
    end;
    exit;
  end;

  idx := GetFirstVisible;

  SumHeight := -TopItemOffset;
  while (idx >= 0) and (idx < Length(FItems)) do
  begin
    LoadItem(idx, True);
    if Y < SumHeight + FItems[idx].Height then
    begin
      Result := idx;
      break;
    end;
    Inc(SumHeight, FItems[idx].Height);
    idx := GetDown(idx);
    if idx = -1 then
      break;
  end;

  if Result = -1 then
    exit;
  SetRect(ItemRect, 0, SumHeight, FClientRect.Right, SumHeight + FItems[Result].Height);
end;

function THistoryGrid.FindItemAt(P: TPoint; out ItemRect: TRect): Integer;
begin
  Result := FindItemAt(P.X, P.Y, ItemRect);
end;

function THistoryGrid.FindItemAt(P: TPoint): Integer;
var
  r: TRect;
begin
  Result := FindItemAt(P.X, P.Y, r);
end;

function THistoryGrid.FindItemAt(X, Y: Integer): Integer;
var
  r: TRect;
begin
  Result := FindItemAt(X, Y, r);
end;

