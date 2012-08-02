{}
procedure THistoryGrid.OnGridBeforeScroll(Sender: PControl; OldPos, NewPos: Integer;
      Cmd: Word; var AllowChange: Boolean);
begin
//!!  CheckBusy;

  if Cmd = SB_ENDSCROLL then
    exit;
//beginupdate;
  if Cmd in [SB_LINEUP, SB_LINEDOWN, SB_PAGEDOWN, SB_PAGEUP] then
  begin
    case Cmd of
      SB_LINEDOWN: ScrollGridBy(VLineScrollSize);
      SB_LINEUP  : ScrollGridBy(-VLineScrollSize);
      SB_PAGEDOWN: ScrollGridBy(FClient.ClientHeight);
      SB_PAGEUP  : ScrollGridBy(-FClient.ClientHeight);
    end;
    NeededSBPosition := VertScrollBar.SBPosition; // set through ScrollGridBy
    exit;
  end;
  NeededSBPosition := NewPos;
  FClient.Invalidate;
//endupdate;
//  FClient.Update;
end;

procedure THistoryGrid.OnGridScroll(Sender: PControl; Cmd: Word);
var
  Item1, Item2, SBPos: Integer;
  off, idx, first, ind: Integer;
begin
  // scrolled position to real item number position
  VertScrollBar.SBPosition := NeededSBPosition;
{##}
  if Cmd in [SB_THUMBTRACK, SB_THUMBPOSITION] then
  begin
    idx := GetNext(GetIdx(VertScrollBar.SBPosition));
    if idx = -1 then
    begin
      SetSBPos(MaxSBPos+1);
    end;
  end;
end;

procedure THistoryGrid.SetSBPos(Position: Integer);
var
  SumHeight: Integer;
  idx: Integer;
begin
  TopItemOffset := 0;
  VertScrollBar.SBPosition := Position;
  AdjustScrollBar;
  if GetUp(GetIdx(VertScrollBar.SBPosition)) = -1 then
    VertScrollBar.SBPosition := 0;
  if MaxSBPos = -1 then
    exit;

  if VertScrollBar.SBPosition > MaxSBPos then
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
    until ((SumHeight >= FClient.ClientHeight) or (idx < 0) or (idx >= Length(FItems)));

    if SumHeight > FClient.ClientHeight then
    begin
      TopItemOffset := SumHeight - FClient.ClientHeight;
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
    VertScrollBar.SBMax := 0;
//??    VertScrollBar.Range := 0;
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
    until ((SumHeight > FClient.ClientHeight) or (idx < 0) or (idx >= Length(FItems)));

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
    until ((SumHeight >= FClient.ClientHeight) or (maxidx < 0) or (maxidx >= Length(FItems)));
    BarAdjusted := True;
    VertScrollBar.Visible := (idx <> -1);

    VertScrollBar.SBMax := GetIdx(maxidx) + VertScrollBar.SBPageSize - 1 + 1;
//??    VertScrollBar.Range := GetIdx(maxidx) + VertScrollBar.SBPageSize - 1 + 1;

    MaxSBPos := GetIdx(maxidx);
    // if VertScrollBar.Position > MaxSBPos then
    SetSBPos(VertScrollBar.SBPosition);
//!!    AdjustInlineRichedit;
    exit;
  end;

  if SumHeight = 0 then
  begin
    VertScrollBar.SBMax := 0;
//??    VertScrollBar.Range := 0;
    exit;
  end;

  VertScrollBar.Visible := True;

  VertScrollBar.SBMax := Count + VertScrollBar.SBPageSize - 1;
//??  VertScrollBar.Range := Count + VertScrollBar.SBPageSize - 1;

  MaxSBPos := Count - 1;
  exit;

  if SumHeight < FClient.ClientHeight then
  begin
    idx := GetPrev(GetIdx(Count));
//??    if idx = -1 then Assert(False);
    R1 := GetItemRect(idx);
    idx := FindItemAt(0, R1.Bottom - FClient.ClientHeight);
    if idx = -1 then
    begin
      idx := GetIdx(0);
    end
    else
    begin
      ind := idx;
      R2 := GetItemRect(idx);
      if R1.Bottom - R2.Top > FClient.ClientHeight then
      begin
        idx := GetNext(idx);
        if idx = -1 then
          idx := ind;
      end;
    end;
    BarAdjusted := True;
    VertScrollBar.SBMax := GetIdx(idx) + VertScrollBar.SBPageSize - 1;
//??    VertScrollBar.Range := GetIdx(idx) + VertScrollBar.SBPageSize - 1;

    MaxSBPos := GetIdx(idx) - 1;
    SetSBPos(VertScrollBar.SBMax);
//??    SetSBPos(VertScrollBar.Range);
  end
  else
  begin
    VertScrollBar.SBMax := Count + VertScrollBar.SBPageSize - 1;
//??    VertScrollBar.Range := Count + VertScrollBar.SBPageSize - 1;

    MaxSBPos := Count - 1;
  end;
end;

function SmoothScrollWindow(hwnd: hwnd; XAmount, YAmount: Integer; Rect, ClipRect: PRect): BOOL;
begin
  Result := ScrollWindow(hwnd, XAmount, YAmount, Rect, ClipRect);
  UpdateWindow(hwnd);
end;

procedure THistoryGrid.ScrollGridBy(Offset: Integer; Update: Boolean = True);
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
      if SumHeight > (Offset + FClient.ClientHeight) then // guarantee outside our screen
        break;
      idx := GetDown(idx);
      // we scroll to the last item, let's SetSBPos do the job
      if idx = -1 then
      begin
        SetSBPos(MaxSBPos + 1);
        FClient.Invalidate;
        FClient.Update;
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
        VertScrollBar.SBPosition := GetIdx(idx);
        TopItemOffset := Offset - SumHeight;
        if Update then
          SmoothScrollWindow(FClient.Handle, 0, -Offset, nil, nil);
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
          VertScrollBar.SBPosition := 0
        else
          VertScrollBar.SBPosition := GetIdx(previdx);

        TopItemOffset := Offset - SumHeight;
        if Update then
        begin
          SmoothScrollWindow(FClient.Handle, 0, -Offset, nil, nil);
        end;
        break;
      end;

      if idx = -1 then
      begin
        if previdx = first then
          VertScrollBar.SBPosition := 0
        else
          VertScrollBar.SBPosition := GetIdx(previdx);
        TopItemOffset := 0;
        // to lazy to calculate proper offset
        if Update then
        begin
          FClient.Invalidate;
          FClient.Update;
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
