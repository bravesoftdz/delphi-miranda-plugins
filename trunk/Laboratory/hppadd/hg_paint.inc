{}
{
procedure TCanvas.TextRect(Rect: TRect; X, Y: Integer; const Text: string);
var
  Options: Longint;
begin
  Changing;
  RequiredState([csHandleValid, csFontValid, csBrushValid]);
  Options := ETO_CLIPPED or FTextFlags;
  if Brush.Style <> bsClear then
    Options := Options or ETO_OPAQUE;
  if ((FTextFlags and ETO_RTLREADING) <> 0) and
     (CanvasOrientation = coRightToLeft) then Inc(X, TextWidth(Text) + 1);
  Winapi.Windows.ExtTextOut(FHandle, X, Y, Options, Rect, Text,
    Length(Text), nil);
  Changed;
end;
}
// paint session header
procedure THistoryGrid.PaintHeader(Index: Integer; ItemRect: TRect);
var
  TextToDraw: WideString;
  RTL: Boolean;
  RIconOffset, IconOffset, IconTop: Integer;
  IconPosition: integer;
begin
  RTL := GetItemRTL(Index);
{!!
  if not(RTL = ((Canvas.TextFlags and ETO_RTLREADING) > 0)) then
  begin
    if RTL then
      Canvas.TextFlags := Canvas.TextFlags or ETO_RTLREADING
    else
      Canvas.TextFlags := Canvas.TextFlags and not ETO_RTLREADING;
  end;
}
  Dec(ItemRect.Bottom, 1);

  FClient.Canvas.Brush.Color := GridOptions.ColorSessHeader;
  FClient.Canvas.FillRect(ItemRect);

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

    DrawIconEx(FClient.Canvas.Handle, IconPosition, ItemRect.Top + IconTop,
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

    DrawIconEx(FClient.Canvas.Handle, IconPosition, ItemRect.Top + IconTop,
      hppIcons[HPP_ICON_SESS_DIVIDER].Handle, 16, 16, 0, 0, DI_NORMAL);
    Inc(IconOffset, 16 + Padding);
  end;

  // draw session header text
  TextToDraw := Format(TxtSessions, [GetDateTimeString(Items[Index].Time)]);
  FClient.Canvas.Font.Assign(GridOptions.FontSessHeader);
  Inc(ItemRect.Left , IconOffset);
  Dec(ItemRect.Right, RIconOffset);
  // TextRect ->DrawText?
  if RTL then
  begin
    FClient.Canvas.WTextRect(ItemRect, ItemRect.Right - FClient.Canvas.TextExtent(TextToDraw).cX,
       ItemRect.Top, TextToDraw);
  end
  else
    FClient.Canvas.WTextRect(ItemRect, ItemRect.Left, ItemRect.Top, TextToDraw);
end;

procedure THistoryGrid.PaintItem(Index: Integer; ItemRect: TRect);
var
  TimeStamp, HeaderName: WideString;
  OrgRect, ItemClipRect: TRect;
  TopIconOffset, IconOffset, TimeOffset: Integer;
  BackColor: TColor;
  nameFont, timestampFont, textFont: PFont;
  Sel: Boolean;
  RTL: Boolean;
  FullHeader: Boolean;
  RichBMP: PCacheBitmap;
  ic: HICON;
  HeadRect: TRect;
  dtf: Integer;
  er: PEventRecord;
begin
  // leave divider line
  Dec(ItemRect.Bottom);
  OrgRect := ItemRect;

  Sel := IsSelected(Index);
  GridOptions.GetItemOptions(FItems[Index].MessageType, textFont, BackColor);
  if Sel then
    BackColor := GridOptions.ColorSelected;

  IntersectRect(ItemClipRect, ItemRect, FClient.Canvas.ClipRect);
  FClient.Canvas.Brush.Color := BackColor;
  FClient.Canvas.FillRect(ItemClipRect);

  InflateRect(ItemRect, -Padding, -Padding);

  FullHeader := not(FGroupLinked and FItems[Index].LinkedToPrev);
  if FullHeader then
  begin
    HeadRect := ItemRect;
    HeadRect.Top := HeadRect.Top - Padding + (Padding div 2);
    if mtIncoming in FItems[Index].MessageType then
      HeadRect.Bottom := HeadRect.Top + CHeaderHeight
    else
      HeadRect.Bottom := HeadRect.Top + PHeaderheight;
    ItemRect.Top := HeadRect.Bottom + Padding - (Padding div 2);
  end;

  if FullHeader and DoRectsIntersect(HeadRect, FClient.Canvas.ClipRect) then
  begin
    if mtIncoming in FItems[Index].MessageType then
    begin
      nameFont      := GridOptions.FontContact;
      timestampFont := GridOptions.FontIncomingTimestamp;
      HeaderName    := ContactName;
    end
    else
    begin
      nameFont      := GridOptions.FontProfile;
      timestampFont := GridOptions.FontOutgoingTimestamp;
      HeaderName    := ProfileName;
    end;
    if Assigned(FGetNameData) then
      FGetNameData(@Self, Index, HeaderName);
    HeaderName := HeaderName + ':';
    TimeStamp := GetDateTimeString(FItems[Index].Time);

    RTL := GetItemRTL(Index);
{!!
    if not(RTL = ((Canvas.TextFlags and ETO_RTLREADING) > 0)) then
    begin
      if RTL then
        Canvas.TextFlags := Canvas.TextFlags or ETO_RTLREADING
      else
        Canvas.TextFlags := Canvas.TextFlags and not ETO_RTLREADING;
    end;
}
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
      DrawIconEx(FClient.Canvas.Handle, IconOffset, HeadRect.Top + TopIconOffset,
        hppIcons[HPP_ICON_SESS_DIVIDER].Handle, 16, 16, 0, 0, DI_NORMAL);
    end;

    // draw event type icon
    if GridOptions.ShowIcons then
    begin
      er := GetEventRecord(FItems[Index]);
      if er.i = -1 then
        ic := 0
      else if er.iSkin = -1 then
        ic := hppIcons[er.i].Handle
      else
        ic := skinIcons[er.i].Handle;
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
        DrawIconEx(FClient.Canvas.Handle, IconOffset, HeadRect.Top + TopIconOffset,
          ic, 16, 16, 0, 0, DI_NORMAL);
      end;
    end;

    // Draw nick name
    FClient.Canvas.Font.Assign(nameFont);
    if Sel then
      FClient.Canvas.Font.Color := GridOptions.ColorSelectedText;
    dtf := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER;
    if RTL then
      dtf := dtf or DT_RTLREADING or DT_RIGHT
    else
      dtf := dtf or DT_LEFT;
    DrawTextW(FClient.Canvas.Handle, PWideChar(HeaderName), Length(HeaderName), HeadRect, dtf);

    // Draw timestamp
    FClient.Canvas.Font.Assign(timestampFont);
    if Sel then
      FClient.Canvas.Font.Color := GridOptions.ColorSelectedText;
    TimeOffset := FClient.Canvas.TextExtent(TimeStamp).cX;
    dtf := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER;
    if RTL then
      dtf := dtf or DT_RTLREADING or DT_LEFT
    else
      dtf := dtf or DT_RIGHT;
    DrawTextW(FClient.Canvas.Handle, PWideChar(TimeStamp), Length(TimeStamp), HeadRect, dtf);

    // Show bookmark icon
    if ShowBookmarks and (Sel or FItems[Index].Bookmarked) then
    begin
      IconOffset := TimeOffset + Padding;
      if FItems[Index].Bookmarked then
        ic := hppIcons[HPP_ICON_BOOKMARK_ON].Handle
      else
        ic := hppIcons[HPP_ICON_BOOKMARK_OFF].Handle;

      if RTL then
        IconOffset:=HeadRect.Left + IconOffset
      else
        IconOffset:=HeadRect.Right - IconOffset - 16;

      DrawIconEx(FClient.Canvas.Handle, IconOffset, HeadRect.Top + TopIconOffset,
          ic, 16, 16, 0, 0, DI_NORMAL);
    end;
  end;

  // Draw item body (getbitmap from cache)
  if DoRectsIntersect(ItemRect, FClient.Canvas.ClipRect) then
  begin
    ApplyItemToRich(Index);
    RichBMP := FRichCache.GetItemRichBitmap(Index);

    SetRect(ItemClipRect, ItemRect.Left, ItemRect.Top,
      ItemRect.Left + RichBMP.Width, ItemRect.Top + RichBMP.Height);
    IntersectRect(ItemClipRect, ItemClipRect, FClient.Canvas.ClipRect);

    BitBlt(FClient.Canvas.Handle, ItemClipRect.Left, ItemClipRect.Top,
      ItemClipRect.Right - ItemClipRect.Left, ItemClipRect.Bottom - ItemClipRect.Top,
      RichBMP.DC, ItemClipRect.Left - ItemRect.Left,
      ItemClipRect.Top - ItemRect.Top, SRCCOPY);
  end;

  if (not FGridNotFocused {or WindowPrePainting}) and (Index = Selected) then
  begin
    DrawFocusRect(FClient.Canvas.Handle, OrgRect);
  end;
end;

procedure THistoryGrid.Paint;
var
  TextRect, HeaderRect: TRect;
  Ch, cw: Integer;
  idx, cnt: Integer;
  SumHeight: Integer;
begin
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
  ch := FClient.ClientHeight;
  cw := FClient.ClientWidth;

  while (SumHeight < ch) and (idx >= 0) and (idx < cnt) do
  begin
    LoadItem(idx);
    // TextRect = rect of next item
    SetRect(TextRect, 0, SumHeight, cw, SumHeight + FItems[idx].Height);
    if DoRectsIntersect(FClient.Canvas.ClipRect, TextRect) then
    begin
      FClient.Canvas.Brush.Color := GridOptions.ColorDivider;
      FClient.Canvas.FillRect(TextRect);
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

      PaintItem(idx, TextRect);
    end;
    Inc(SumHeight, FItems[idx].Height);
    idx := GetNext(idx);
    if idx = -1 then
      break;
  end;

  if SumHeight < ch then
  begin
    SetRect(TextRect, 0, SumHeight, cw, ch);
    if DoRectsIntersect(FClient.Canvas.ClipRect, TextRect) then
    begin
      FClient.Canvas.Brush.Color := GridOptions.ColorBackground;
      FClient.Canvas.FillRect(TextRect);
    end;
  end;
end;

procedure THistoryGrid.MyPaint(Sender: PControl; DC: HDC);
var
  ClipRect:TRect;
begin
  if LockCount > 0 then
    exit;

  ClipRect := Sender.Canvas.ClipRect;
  try
    Paint;
    BitBlt(DC, ClipRect.Left, ClipRect.Top, ClipRect.Right - ClipRect.Left,
      ClipRect.Bottom - ClipRect.Top, FClient.Canvas.Handle, ClipRect.Left, ClipRect.Top, SRCCOPY);
  finally
  end;
end;

procedure THistoryGrid.EraseBkgnd(Sender: PControl; DC: HDC);
begin
end;

procedure THistoryGrid.DrawMessage(const aText: WideString);
var
  cr, r: TRect;
begin
  FClient.Canvas.Font.Assign(GridOptions.FontMessage);
//  Canvas.Font := GridOptions.FontMessage;
  FClient.Canvas.Brush.Color := GridOptions.ColorBackground;
  r := FClient.ClientRect;
  cr := FClient.ClientRect;
  FClient.Canvas.FillRect(r);

  DrawTextW(FClient.Canvas.Handle, PWideChar(aText), Length(aText), r,
    DT_NOPREFIX or DT_CENTER or DT_CALCRECT);
  OffsetRect(r, ((cr.Right - cr.Left) - (r.Right - r.Left)) div 2,
    ((cr.Bottom - cr.Top) - (r.Bottom - r.Top)) div 2);
  DrawTextW(FClient.Canvas.Handle, PWideChar(aText), Length(aText), r, DT_NOPREFIX or DT_CENTER);
end;

procedure THistoryGrid.DoProgress(lPos, Max: Integer);
var
  dc: HDC;
  newp: Byte;
begin
  if not ShowProgress then
  begin
    IsCanvasClean := False;
    FClient.Invalidate;
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

  Paint;

  dc := GetDC(FClient.Handle);

  try
    BitBlt(dc, ProgressRect.Left, ProgressRect.Top, ProgressRect.Right - ProgressRect.Left,
      ProgressRect.Bottom - ProgressRect.Top, FClient.Canvas.Handle, ProgressRect.Left,
      ProgressRect.Top, SRCCOPY);
  finally
    ReleaseDC(FClient.Handle, dc);
  end;
//!!  Application.ProcessMessages;
end;

procedure THistoryGrid.DrawProgress;
var
  r: TRect;
begin
  r := FClient.ClientRect;
  FClient.Canvas.Font.Assign(GridOptions.FontMessage);
  FClient.Canvas.Brush.Color := GridOptions.ColorBackground;
  FClient.Canvas.Pen.Color := GridOptions.FontMessage.Color;
  if not IsCanvasClean then
  begin
    FClient.Canvas.FillRect(r);
    ProgressRect := r;
    InflateRect(r, -30, -((FClient.ClientHeight - 17) div 2));
    IsCanvasClean := True;
  end
  else
  begin
    InflateRect(r, -30, -((FClient.ClientHeight - 17) div 2));
    ProgressRect := r;
  end;
  FClient.Canvas.FrameRect(r);
  InflateRect(r, -1, -1);
  FClient.Canvas.Rectangle(r.left,r.top,r.right,r.bottom);
  InflateRect(r, -2, -2);
  FClient.Canvas.Brush.Color := GridOptions.FontMessage.Color;
  if ProgressPercent < 100 then
    r.Right := r.Left + Round(((r.Right - r.Left) * ProgressPercent) / 100);
  FClient.Canvas.FillRect(r);
end;
