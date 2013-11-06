{}
procedure THistoryGrid.SetSBHidden(value:boolean);
begin
  if FSBHidden<>value then
  begin
    FSBHidden:=value;
    ShowScrollBar(FScrollBar, SB_CTL, not value);
    GridUpdate([guSize]);
  end;
end;

procedure THistoryGrid.SetSBMax(value:integer);
var
  SI: TScrollInfo;
begin
  if value<>FSBMax then
  begin
    FSBMax:=value;
    SI.cbSize:=SizeOf(SI);
    SI.fMask :=SIF_RANGE + SIF_PAGE;
    SI.nPage :=SBPageSize;
    SI.nMin  :=0;
    SI.nMax  :=value;
    SetScrollInfo(FScrollBar, SB_CTL, SI, true);
  end;
end;

procedure THistoryGrid.SetSBPosition(value:integer);
var
  SI: TScrollInfo;
begin
  if value<>FSBPosition then
  begin
    FSBPosition := value;
//    SetScrollPos(FScrollBar, SB_CTL, value, true);
    // Check position range??
    SI.cbSize:=SizeOf(SI);
    SI.fMask :=SIF_POS;
    SI.nPos  :=value;
    SetScrollInfo(FScrollBar, SB_CTL, SI, true);
  end;
end;

procedure THistoryGrid.OnGridScroll(wParam:WPARAM);
var
  idx,ScrollCode: Integer;
begin
  CheckBusy;

  ScrollCode := Loword(wParam);

  if ScrollCode = SB_ENDSCROLL then
    exit;
  
  BeginUpdate;

  if ScrollCode in [SB_LINEUP, SB_LINEDOWN, SB_PAGEDOWN, SB_PAGEUP] then
  begin
    case ScrollCode of
      SB_LINEDOWN: ScrollGridBy( VLineScrollSize);
      SB_LINEUP:   ScrollGridBy(-VLineScrollSize);
      SB_PAGEDOWN: ScrollGridBy( FClientRect.Bottom);
      SB_PAGEUP:   ScrollGridBy(-FClientRect.Bottom);
    end;
  end
  else
  begin
    if ScrollCode in [SB_THUMBTRACK, SB_THUMBPOSITION] then
    begin
      idx := GetNext(GetIdx(Hiword(wParam)));
      if idx = -1 then
      begin
        SetSBPos(MaxSBPos+1);
      end
      else
        SetSBPos(idx);
    end;

    AdjustScrollBar;
    InvalidateRect(FHandle, @FClientRect, False);
  end;

  EndUpdate;
  Update;
end;

//----- main work -----

procedure THistoryGrid.SetSBPos(Position: Integer);
var
  SumHeight: Integer;
  idx: Integer;
begin
  TopItemOffset := 0;
  SBPosition := Position;
  AdjustScrollBar;
  if GetUp(GetIdx(SBPosition)) = -1 then
    SBPosition := 0;
  if MaxSBPos = -1 then
    exit;

  if SBPosition > MaxSBPos then
  begin
    SumHeight := 0;
    idx := GetIdx(HIGH(FItems));
    repeat
      LoadItem(idx, True);
      if IsMatched(idx) then
        Inc(SumHeight, FItems[idx].Height);
      idx := GetUp(idx);
      if idx = -1 then
        break;
    until ((SumHeight >= FClientRect.Bottom) or (idx < 0) or (idx >= Length(FItems)));

    if SumHeight > FClientRect.Bottom then
    begin
      TopItemOffset := SumHeight - FClientRect.Bottom;
    end;
  end;
end;

procedure THistoryGrid.AdjustScrollBar;
var
  maxidx, SumHeight, ind, idx: Integer;
  R1, R2: TRect;
begin
  if BarAdjusted then
    exit;

  MaxSBPos := -1;
  if Count = 0 then
  begin
    SBMax := 0;
    exit;
  end;

  SumHeight := 0;
  idx := GetFirstVisible;

  if idx >= 0 then
    repeat
      LoadItem(idx);
      if IsMatched(idx) then
        Inc(SumHeight, FItems[idx].Height);
      idx := GetDown(idx);
    until ((SumHeight > FClientRect.Bottom) or (idx < 0) or (idx >= Length(FItems)));

  maxidx := idx;
  // see if the idx is the last
  if maxidx <> -1 then
    if GetDown(maxidx) = -1 then
      maxidx := -1;

  // if we are at the end, look up to find first visible
  if (maxidx = -1) and (SumHeight > 0) then
  begin
    SumHeight := 0;
    maxidx := GetIdx(Length(FItems));
    // idx := 0;
    repeat
      idx := GetUp(maxidx);
      if idx = -1 then
        break;
      maxidx := idx;
      LoadItem(maxidx, True);
      if IsMatched(maxidx) then
        Inc(SumHeight, FItems[maxidx].Height);
    until ((SumHeight >= FClientRect.Bottom) or (maxidx < 0) or (maxidx >= Length(FItems)));
    BarAdjusted := True;
    SBHidden := (idx = -1);

    SBMax := GetIdx(maxidx) + SBPageSize - 1 + 1;

    MaxSBPos := GetIdx(maxidx);
    // if VertScrollBar.Position > MaxSBPos then
    SetSBPos(SBPosition);
//!!    AdjustInlineRichedit;
    exit;
  end;

  if SumHeight = 0 then
  begin
    SBMax := 0;
    exit;
  end;

  SBHidden := False;

  SBMax := Count + SBPageSize - 1;

  MaxSBPos := Count - 1;
  exit;

  if SumHeight < FClientRect.Bottom then
  begin
    idx := GetPrev(GetIdx(Count));
//??    if idx = -1 then Assert(False);
    R1 := GetItemRect(idx);
    idx := FindItemAt(0, R1.Bottom - FClientRect.Bottom);
    if idx = -1 then
    begin
      idx := GetIdx(0);
    end
    else
    begin
      ind := idx;
      R2 := GetItemRect(idx);
      if R1.Bottom - R2.Top > FClientRect.Bottom then
      begin
        idx := GetNext(idx);
        if idx = -1 then
          idx := ind;
      end;
    end;
    BarAdjusted := True;
    SBMax := GetIdx(idx) + SBPageSize - 1;

    MaxSBPos := GetIdx(idx) - 1;
    SetSBPos(SBMax);
  end
  else
  begin
    SBMax := Count + SBPageSize - 1;

    MaxSBPos := Count - 1;
  end;
end;

function SmoothScrollWindow(hwnd: hwnd; XAmount, YAmount: Integer; Rect, ClipRect: PRect): BOOL;
begin
  Result := ScrollWindow(hwnd, XAmount, YAmount, Rect, ClipRect);
  UpdateWindow(hwnd);
end;

procedure THistoryGrid.ScrollGridBy(Offset: Integer; DoUpdate: Boolean = True);
var
  previdx, idx, first: Integer;
  SumHeight: Integer;
begin
  first := GetFirstVisible;
  if first = -1 then
    exit;
  SumHeight := -TopItemOffset;
  idx := first;
  // Scroll Grid to bottom -> Scroll window Up
  if Offset >0 then
  begin
    // part 1 - check for grid "bottom"
    repeat
      LoadItem(idx, True);
      Inc(SumHeight, FItems[idx].Height);
      if SumHeight > (Offset + FClientRect.Bottom) then // guarantee outside our screen
        break;
      idx := GetDown(idx);
      // we scroll to the last item, let's SetSBPos do the job
      if idx = -1 then
      begin
        SetSBPos(MaxSBPos + 1);

        Invalidate;
        Update;
        exit;
      end;
    until false;

    // part 2 - screen scroll
    SumHeight := -TopItemOffset;
    idx := first;
    while (idx >= 0) and (idx < Count) do
    begin
      LoadItem(idx, True);
      if (SumHeight + FItems[idx].Height) > Offset then
      begin
        SBPosition := GetIdx(idx);
        TopItemOffset := Offset - SumHeight;
        if DoUpdate then
          SmoothScrollWindow(FClient, 0, -Offset, nil, nil);
        exit;
      end;
      Inc(SumHeight, FItems[idx].Height);
      idx := GetDown(idx);
    end;
  end
  else // if Offset < 0 // scrolling grid to top
  begin
    while (idx <> -1) and (idx >= 0) and (idx < Count) do
    begin
      previdx := idx;
      idx := GetUp(idx);
      if SumHeight <= Offset then
      begin
        if idx = -1 then
          SBPosition := 0
        else
          SBPosition := GetIdx(previdx);

        TopItemOffset := Offset - SumHeight;
        if DoUpdate then
        begin
          SmoothScrollWindow(FClient, 0, -Offset, nil, nil);
        end;
        break;
      end;

      if idx = -1 then
      begin
        if previdx = first then
          SBPosition := 0
        else
          SBPosition := GetIdx(previdx);

        TopItemOffset := 0;
        // to lazy to calculate proper offset
        if DoUpdate then
        begin
          Invalidate;
          Update;
        end;
        break;
      end;

      LoadItem(idx, True);
      Dec(SumHeight, FItems[idx].Height);
    end;
  end;
end;

procedure THistoryGrid.ScrollToBottom;
begin
  if not BarAdjusted then
    AdjustScrollBar;
  SetSBPos(Count);
end;
