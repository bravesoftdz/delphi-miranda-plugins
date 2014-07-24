{}
// paint session header
procedure THistoryGrid.PaintHeader(Index: Integer; var ItemRect: TRect);
var
  TextToDraw,timestr: pWideChar;
  oldf:HFONT;
  br:HBRUSH;
  sz:TSize;
  flags:uint;
  RTL: Boolean;
  RIconOffset, IconOffset, IconTop: Integer;
  IconPosition: integer;
  left,txtlen:integer;
begin
  RTL := GetItemRTL(Index);

//  if not(RTL = ((Canvas.TextFlags and ETO_RTLREADING) > 0)) then
//  begin
    if RTL then
      flags := ETO_RTLREADING
    else
      flags := 0;
//  end;

  Dec(ItemRect.Bottom, 1);

  br:=CreateSolidBrush(GridOptions.ColorBack[fiSession]);
  FillRect(FClientDC,ItemRect,br);
  DeleteObject(br);
  SetBkColor(FClientDC,GridOptions.ColorBack[fiSession]);

  InflateRect(ItemRect, -3, -3);

  IconOffset := 0;
  RIconOffset := 0;
  IconTop := ((ItemRect.Bottom - ItemRect.Top - 16) div 2);

  // Draw closing cross
  // checked in Paint function
//  if (ShowHeaders) and (FItems[Index].HasHeader) and (ExpandHeaders) then
  begin
    if RTL then
      IconPosition:=ItemRect.Left
    else
      IconPosition:=ItemRect.Right - 16;

    DrawIconEx(FClientDC, IconPosition, ItemRect.Top + IconTop,
      hppIcons[HPP_ICON_SESS_HIDE].Handle, 16, 16, 0, 0, DI_NORMAL);
    Inc(RIconOffset, 16 + Padding);
  end;

  // draw session clock
  if hppIcons[HPP_ICON_SESS_DIVIDER].Handle <> 0 then
  begin
    if RTL then
      IconPosition:=ItemRect.Right - 16 - IconOffset
    else
      IconPosition:=ItemRect.Left + IconOffset;

    DrawIconEx(FClientDC, IconPosition, ItemRect.Top + IconTop,
      hppIcons[HPP_ICON_SESS_DIVIDER].Handle, 16, 16, 0, 0, DI_NORMAL);
    Inc(IconOffset, 16 + Padding);
  end;

  // draw session header text
  timestr:=GetDateTimeString(Items[Index].Time);
  TextToDraw := FormatStrW(TxtSessions, [timestr]);
  mFreeMem(timestr);

  SetTextColor(FClientDC,GridOptions.ColorText[fiSession]);
  oldf:=SelectObject(FClientDC,GridOptions.Font[fiSession]);

  Inc(ItemRect.Left , IconOffset);
  Dec(ItemRect.Right, RIconOffset);
  // TextRect ->DrawText?
  txtlen:=StrLenW(TextToDraw);
  if RTL then
  begin
    GetTextExtentPoint32W(FClientDC, TextToDraw, txtlen, sz);
    left:=ItemRect.Right - sz.cX;
  end
  else
    left:=ItemRect.Left;

  ExtTextOutW(FClientDC, left, ItemRect.Top, ETO_CLIPPED {or ETO_OPAQUE} or flags,
                      @ItemRect, TextToDraw, txtlen, nil);
  SelectObject(FClientDC,oldf);
  mFreeMem(TextToDraw);
end;

procedure THistoryGrid.PaintItem(Index: Integer; var ItemRect: TRect; const ClipRect: TRect);
var
  namebuf: array [0..127] of WideChar;
  TimeStamp: pWideChar;
  HeaderName,pc,pcfree: pWideChar;
  OrgRect, ItemClipRect: TRect;
  RichBMP: PCacheBitmap;
  ic: HICON;
  HeadRect: TRect;
  br:HBRUSH;
  sz:TSize;
  ici:tHPPIconName;
  BackColor: TCOLORREF;
  TopIconOffset, IconOffset, TimeOffset: Integer;
  Sel: Boolean;
  RTL: Boolean;
  FullHeader: Boolean;
  dtf,tslen: Integer;
  nameidx, timeidx, idx:integer;
begin
  // leave divider line
  Dec(ItemRect.Bottom);
  OrgRect := ItemRect;

  Sel := IsSelected(Index);
  if Sel then
    idx := fiSelected
  else
    idx := GridOptions.GetItemIndex(FItems[Index].MessageType);
  BackColor := GridOptions.ColorBack[idx];

  IntersectRect(ItemClipRect, ItemRect, ClipRect);

  br:=CreateSolidBrush(BackColor);
  FillRect(FClientDC,ItemClipRect,br);
  DeleteObject(br);
  SetBkColor(FClientDC,BackColor);

  InflateRect(ItemRect, -Padding, -Padding);

  FullHeader := not(FGroupLinked and FItems[Index].LinkedToPrev);
  if FullHeader then
  begin
    HeadRect := ItemRect;
    HeadRect.Top := HeadRect.Top - Padding + (Padding div 2);
    if IsIncomingEvent(FItems[Index]) then
      HeadRect.Bottom := HeadRect.Top + CHeaderHeight
    else
      HeadRect.Bottom := HeadRect.Top + PHeaderheight;
    ItemRect.Top := HeadRect.Bottom + Padding - (Padding div 2);
  end;

  if FullHeader and IntersectRect(HeadRect, ClipRect) then
  begin
    if IsIncomingEvent(FItems[Index]) then
    begin
      nameidx    := fiContact;
      timeidx    := fiInTime;
      pc := ContactName;
    end
    else
    begin
      nameidx    := fiProfile;
      timeidx    := fiOutTime;
      pc := ProfileName;
    end;

    if Assigned(FGetNameData) then
      FGetNameData(Index, pc);
    pcfree:=pc;

    pc:=StrCopyEW(namebuf,pc);
    pc^ := ':'; (pc+1)^ := #0;

    if Assigned(FGetNameData) then
      mFreeMem(pcfree);

    HeaderName := @namebuf;
    TimeStamp := GetDateTimeString(FItems[Index].Time);

    RTL := GetItemRTL(Index);

    TopIconOffset := ((HeadRect.Bottom - HeadRect.Top) - 16) div 2;
    // header not expanded, draw session sign (clock)
    if (FItems[Index].HasHeader) and (ShowHeaders) and (not ExpandHeaders) then
    begin
      if RTL then
      begin
        IconOffset:=HeadRect.Right - 16;
        Dec(HeadRect.Right, 16 + Padding);
      end
      else
      begin
        IconOffset:=HeadRect.Left;
        Inc(HeadRect.Left, 16 + Padding);
      end;

      DrawIconEx(FClientDC, IconOffset, HeadRect.Top + TopIconOffset,
        hppIcons[HPP_ICON_SESS_DIVIDER].Handle, 16, 16, 0, 0, DI_NORMAL);
    end;

    // draw event type icon
    if GridOptions.ShowIcons then
    begin
      ic := GetEventIcon(FItems[Index]);
      if ic <> 0 then
      begin
        // canvas. draw here can sometimes draw 32x32 icon (sic!)
        if RTL then
        begin
          IconOffset:=HeadRect.Right - 16;
          Dec(HeadRect.Right, 16 + Padding);
        end
        else
        begin
          IconOffset:=HeadRect.Left;
          Inc(HeadRect.Left, 16 + Padding);
        end;

        DrawIconEx(FClientDC, IconOffset, HeadRect.Top + TopIconOffset,
          ic, 16, 16, 0, 0, DI_NORMAL);
      end;
    end;

    // Draw nick name
    if Sel then
      idx:=fiSelected
    else
      idx:=nameidx;

    SetTextColor(FClientDC,GridOptions.ColorText[idx]);
    SelectObject(FClientDC,GridOptions.Font[nameidx]);

    if RTL then
      dtf := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER or DT_RTLREADING or DT_RIGHT
    else
      dtf := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER or DT_LEFT;
    DrawTextW(FClientDC, HeaderName, StrLenW(HeaderName), HeadRect, dtf);

    // Draw timestamp
    if Sel then
      idx:=fiSelected
    else
      idx:=timeidx;
    SetTextColor(FClientDC,GridOptions.ColorText[idx]);
    SelectObject(FClientDC,GridOptions.Font[timeidx]);
    tslen:=StrLenW(TimeStamp);
    GetTextExtentPoint32W(FClientDC, TimeStamp, tslen, sz);
    TimeOffset := sz.cX;

    dtf := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER;
    if RTL then
      dtf := dtf or DT_RTLREADING or DT_LEFT
    else
      dtf := dtf or DT_RIGHT;
    DrawTextW(FClientDC, TimeStamp, tslen, HeadRect, dtf);
    mFreeMem(Timestamp);

    // Show bookmark icon
    if ShowBookmarks and (Sel or FItems[Index].Bookmarked) then
    begin
      IconOffset := TimeOffset + Padding;
      if FItems[Index].Bookmarked then
        ici := HPP_ICON_BOOKMARK_ON
      else
        ici := HPP_ICON_BOOKMARK_OFF;
      ic := hppIcons[ici].Handle;

      if RTL then
        IconOffset:=HeadRect.Left + IconOffset
      else
        IconOffset:=HeadRect.Right - IconOffset - 16;
      DrawIconEx(FClientDC, IconOffset, HeadRect.Top + TopIconOffset,
          ic, 16, 16, 0, 0, DI_NORMAL);
    end;
  end;

  // Draw item body (getbitmap from cache)
  if IntersectRect(ItemRect, ClipRect) then
  begin
//??    GetRichFromCache(Index);
    RichBMP := FRichCache.GetItemRichBitmap(Index);

    SetRect(ItemClipRect, ItemRect.Left, ItemRect.Top,
      ItemRect.Left + RichBMP.Width, ItemRect.Top + RichBMP.Height);

    IntersectRect(ItemClipRect, ItemClipRect, ClipRect);

    BitBlt(FClientDC, ItemClipRect.Left, ItemClipRect.Top,
      ItemClipRect.Right - ItemClipRect.Left, ItemClipRect.Bottom - ItemClipRect.Top,
      RichBMP.DC, ItemClipRect.Left - ItemRect.Left,
      ItemClipRect.Top - ItemRect.Top, SRCCOPY);
  end;

  if (not FGridNotFocused {or WindowPrePainting}) and (Index = Selected) then
  begin
    DrawFocusRect(FClientDC, OrgRect);
  end;
end;

function THistoryGrid.Paint(const ClipRect:TRect):lresult;
var
  TextRect, HeaderRect: TRect;
  Ch, cw: Integer;
  idx, cnt: Integer;
  SumHeight: Integer;
  br:HBRUSH;
begin

  if LockCount > 0 then
  begin
    result:=1;
    exit;
  end;

  result:=0;


  if not Allocated then
  begin
    DrawMessage(TxtStartup);
    exit;
  end
  else if ShowProgress then
  begin
    DrawProgress;
    exit;
  end;

  cnt := Count;
  if cnt = 0 then
  begin
    DrawMessage(TxtNoItems);
    exit;
  end;

  idx := GetFirstVisible;

  if idx = -1 then
  begin
    DrawMessage(TxtNoSuch);
    exit;
  end;

  SumHeight := -TopItemOffset;

  ch := FClientRect.Bottom;
  cw := FClientRect.Right;

  br:=CreateSolidBrush(GridOptions.ColorBack[fiDivider]);

  while (SumHeight < ch) and (idx >= 0) and (idx < cnt) do
  begin
    LoadItem(idx);
    // TextRect = rect of next item
    SetRect(TextRect, 0, SumHeight, cw, SumHeight + FItems[idx].Height);
    if IntersectRect(ClipRect, TextRect) then
    begin
      FillRect(FClientDC,TextRect,br);
      // need to paint expanded session header
      if (FItems[idx].HasHeader) and (ShowHeaders) and (ExpandHeaders) then
      begin

        if Reversed xor ReversedHeader then
        begin
          SetRect(HeaderRect, 0, TextRect.Top, cw, TextRect.Top + SessHeaderHeight);
          Inc(TextRect.Top, SessHeaderHeight);
        end
        else
        begin
          SetRect(HeaderRect, 0, TextRect.Bottom - SessHeaderHeight, cw, TextRect.Bottom);
          Dec(TextRect.Bottom, SessHeaderHeight);
        end;
        PaintHeader(idx, HeaderRect);
      end;

      PaintItem(idx, TextRect, ClipRect);
    end;
    Inc(SumHeight, FItems[idx].Height);
    idx := GetNext(idx);
    if idx = -1 then
      break;
  end;
  DeleteObject(br);

  if SumHeight < ch then
  begin
    SetRect(TextRect, 0, SumHeight, cw, ch);
    if IntersectRect(ClipRect, TextRect) then
    begin
      br:=CreateSolidBrush(GridOptions.ColorBack[fiGrid]);
      FillRect(FClientDC,TextRect,br);
      DeleteObject(br);
    end;
  end;

end;

procedure THistoryGrid.DrawMessage(aText: pWideChar);
var
  cr, r: TRect;
  oldf:HFONT;
  br:HBRUSH;
  len:integer;
begin
  r  := FClientRect;
  cr := FClientRect;

  br:=CreateSolidBrush(GridOptions.ColorBack[fiGrid]);
  FillRect(FClientDC,r,br);
  DeleteObject(br);

  SetTextColor(FClientDC,GridOptions.ColorText[fiGrid]);
  oldf:=SelectObject(FClientDC,GridOptions.Font[fiGrid]);
  len:=StrLenW(aText);
  DrawTextW(FClientDC, aText, len, r,
    DT_NOPREFIX or DT_CENTER or DT_CALCRECT);

  OffsetRect(r, ((cr.Right - cr.Left) - (r.Right - r.Left)) div 2,
    ((cr.Bottom - cr.Top) - (r.Bottom - r.Top)) div 2);

  DrawTextW(FClientDC, aText, len, r, DT_NOPREFIX or DT_CENTER);
  SelectObject(FClientDC,oldf);
end;

procedure THistoryGrid.DrawProgress;
var
  r: TRect;
  br:HBRUSH;
  pen:HPEN;
  old:HGDIOBJ;
begin
  r := FClientRect;
  br:=CreateSolidBrush(GridOptions.ColorBack[fiGrid]);
  if not IsCanvasClean then
  begin
    FillRect(FClientDC,r,br);
    ProgressRect := r;
    InflateRect(r, -30, -((FClientRect.Bottom - 17) div 2));
    IsCanvasClean := True;
  end
  else
  begin
    InflateRect(r, -30, -((FClientRect.Bottom - 17) div 2));
    ProgressRect := r;
  end;
  FrameRect(FClientDC,r,br);

  InflateRect(r, -1, -1);

  pen:=CreatePen(PS_SOLID,1,GridOptions.ColorText[fiGrid]);
  old:=SelectObject(FClientDC,pen);
  SelectObject(FClientDC,br);

  Rectangle(FClientDC,r.left,r.top,r.right,r.bottom);
  
  SelectObject(FClientDC,old);

  DeleteObject(pen);
  DeleteObject(br);

  InflateRect(r, -2, -2);
  if ProgressPercent < 100 then
    r.Right := r.Left + Round(((r.Right - r.Left) * ProgressPercent) / 100);

  br:=CreateSolidBrush(GridOptions.ColorBack[fiGrid]);
  FillRect(FClientDC,r,br);
  DeleteObject(br);
end;

procedure THistoryGrid.DoProgress(lPos, Max: Integer);
var
  dc: HDC;
  newp: integer;
begin
  if not ShowProgress then
  begin
    IsCanvasClean := False;
    Invalidate;
    ProgressPercent := 255;
    exit;
  end;

  if Max = 0 then
    exit;
  newp := (lPos * 100 div Max);
  if newp = ProgressPercent then
    exit;
  ProgressPercent := newp;
  if lPos = 0 then
    exit;

  DrawProgress;

  dc := GetDC(FClient);

  try
    BitBlt(dc, ProgressRect.Left, ProgressRect.Top,
           ProgressRect.Right - ProgressRect.Left, ProgressRect.Bottom - ProgressRect.Top,
           FClientDC, ProgressRect.Left, ProgressRect.Top, SRCCOPY);
  finally
    ReleaseDC(FClient, dc);
  end;

end;
