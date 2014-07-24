{}
procedure THistoryGrid.BeginUpdate;
begin
  Inc(LockCount);
end;

procedure THistoryGrid.EndUpdate;
begin
  if LockCount > 0 then
    Dec(LockCount);
  if LockCount > 0 then
    exit;
  try
    if guSize    in GridUpdates then GridUpdateSize;
    if guOptions in GridUpdates then DoOptionsChanged;
    if guFilter  in GridUpdates then UpdateFilter;
  finally
    GridUpdates := [];
  end;
end;

procedure THistoryGrid.GridUpdate(Updates: TGridUpdates);
begin
  BeginUpdate;
  GridUpdates := GridUpdates + Updates;
  EndUpdate;
end;

function OnChange(Grid:THistoryGrid;wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=0;
Grid.DoOptionsChanged; //!!
  if (wParam and HGOPT_OPTIONS) <> 0 then
  begin
  end;
  if (wParam and HGOPT_TEMPLATES) <> 0 then
  begin
  end;
  if (wParam and HGOPT_FONTSERVICE) <> 0 then
  begin
  end;
end;

procedure THistoryGrid.SetState(const Value: TGridState);
begin
  FState := Value;

  if Assigned(FOnState) then
    FOnState(FState);
end;

procedure THistoryGrid.SetGroupLinked(const Value: Boolean);
var
  i: Integer;
begin
  if FGroupLinked = Value then
    exit;
  FGroupLinked := Value;

  for i := 0 to HIGH(FItems) do
  begin
    if FItems[i].LinkedToPrev then
    begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;

  BarAdjusted := False;
  AdjustScrollBar;

  Invalidate;
end;

procedure THistoryGrid.SetShowHeaders(const Value: Boolean);
var
  i: Integer;
begin
  if FShowHeaders = Value then
    exit;
  FShowHeaders := Value;

  for i := 0 to HIGH(FItems) do
  begin
    if FItems[i].HasHeader then
    begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;

  BarAdjusted := False;
  AdjustScrollBar;

  Invalidate;
end;

procedure THistoryGrid.SetExpandHeaders(const Value: Boolean);
var
  i: Integer;
begin
  if FExpandHeaders = Value then
    exit;
  FExpandHeaders := Value;

  for i := 0 to HIGH(FItems) do
  begin
    if FItems[i].HasHeader then
    begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;

  BarAdjusted := False;
  AdjustScrollBar;

  Invalidate;
end;

procedure THistoryGrid.SetReversed(const Value: Boolean);
var
  vis_idx: Integer;
begin
  if FReversed = Value then
    exit;

  if not Allocated then
  begin
    FReversed := Value;
    exit;
  end;

  if Selected = -1 then
  begin
    vis_idx := GetFirstVisible;
  end
  else
  begin
    vis_idx := Selected;
  end;
  FReversed := Value;

  // VertScrollBar.Position := getIdx(0);
  BarAdjusted := False;
  SetSBPos(GetIdx(0));
  AdjustScrollBar;

  MakeVisible(vis_idx);

  Invalidate;
  Update;
end;

procedure THistoryGrid.SetReversedHeader(const Value: Boolean);
begin
  if FReversedHeader = Value then
    exit;
  FReversedHeader := Value;

  if not Allocated then
    exit;

  Invalidate;
  Update;
end;

procedure THistoryGrid.SetRTLMode(const Value: TRTLMode);
var
  NewBiDiMode: TBiDiMode;
begin
  if FRTLMode <> Value then
  begin
    FRTLMode := Value;
    FRichCache.ResetAllItems;

    Invalidate;
    Update;
  end;
  if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and GridOptions.RTLEnabled) then
    NewBiDiMode := bdRightToLeft
  else
    NewBiDiMode := bdLeftToRight;
  if NewBiDiMode <> BiDiMode then
  begin
    BiDiMode := NewBiDiMode;
{!!
    if Assigned(FOnRTLChange) then
      OnRTLChange(Self, NewBiDiMode);
}
  end;
end;

function THistoryGrid.GetProfileName: pWideChar;
begin
  if Assigned(GridOptions) and GridOptions.ForceProfileName then
    Result := GridOptions.ProfileName
  else
    Result := FProfileName;
end;

procedure THistoryGrid.SetProfileName(Value: pWideChar);
begin
  if StrCmpW(Value,FProfileName)=0 then
    exit;
  mFreeMem(FProfileName);
  StrDupW(FProfileName,Value); //!!!!

  if Assigned(GridOptions) and GridOptions.ForceProfileName then
    exit;
  Update;
end;

procedure THistoryGrid.SetContactName(Value: pWideChar);
begin
  if StrCmpW(Value,FContactName)=0 then
    exit;
  mFreeMem(FContactName);
  StrDupW(FContactName,Value); //!!!!

  Update;
end;

procedure THistoryGrid.SetFilter(const Value: TMessageTypes);
begin
  if (Filter = Value) or (Value = []) or (Value = [mtUnknown]) then
    exit;
  FFilter := Value;
  GridUpdate([guFilter]);
{!!
  if Assigned(FOnFilterChange) then
    FOnFilterChange(Self);
}
end;

procedure THistoryGrid.DoOptionsChanged;
var
  i: Integer;
  Ch, ph, pth, cth, sh: Integer;
  sz:TSize;
  oldf:HFONT;
begin
  // recalc fonts
  for i := 0 to HIGH(FItems) do
  begin
    FItems[i].Height := -1;
  end;
  FRichCache.ResetAllItems;

  oldf:=
  SelectObject(FClientDC,GridOptions.Font[fiProfile]); GetTextExtentPoint32(FClientDC,'Wy',2,sz); ph :=sz.cY;
  SelectObject(FClientDC,GridOptions.Font[fiContact]); GetTextExtentPoint32(FClientDC,'Wy',2,sz); Ch :=sz.cY;
  SelectObject(FClientDC,GridOptions.Font[fiOutTime]); GetTextExtentPoint32(FClientDC,'Wy',2,sz); pth:=sz.cY;
  SelectObject(FClientDC,GridOptions.Font[fiInTime] ); GetTextExtentPoint32(FClientDC,'Wy',2,sz); cth:=sz.cY;
  SelectObject(FClientDC,GridOptions.Font[fiSession]); GetTextExtentPoint32(FClientDC,'Wy',2,sz); sh :=sz.cY;
  SelectObject(FClientDC,oldf);
  
  // find heighest and don't forget about icons
  PHeaderheight := Max(ph, pth);
  CHeaderHeight := Max(Ch, cth);
  SessHeaderHeight := sh + 1 + 3 * 2;
  if GridOptions.ShowIcons then
  begin
    CHeaderHeight := Max(CHeaderHeight, 16);
    PHeaderheight := Max(PHeaderheight, 16);
  end;

  Inc(CHeaderHeight, Padding);
  Inc(PHeaderheight, Padding);

  SetRTLMode(RTLMode);
{!!
  if Assigned(Self.FOnOptionsChange) then
    FOnOptionsChange(Self);
}
  BarAdjusted := False;
  AdjustScrollBar;

  Invalidate;
  Update;
end;

procedure THistoryGrid.GridUpdateSize;
var
  rc,rc1: TRect;
  dc:HDC;
  hbmp:HBITMAP;
  i,x,w: Integer;
begin
{!!
  if State = gsInline then
    CancelInline;
}
  IsCanvasClean := False;
{}
  GetClientRect(FHandle,rc);

  // Resize ScrollBar
  if not FSBHidden then
  begin
    GetWindowRect(FScrollBar,rc1);
    w:=rc1.Right-rc1.Left;
    x:=rc.Right-w;
    MoveWindow(FScrollBar, x, rc.Top, w, rc.Bottom, false);
  end
  else
    x:=rc.Right;

  // Resize memory bitmap
  if (rc.Bottom<>FClientRect.Bottom) or
     (x<>FClientRect.Right) then
  begin
    dc:=GetDC(0);
    hBmp:=CreateCompatibleBitmap(dc,x,rc.Bottom);
    ReleaseDC(0,dc);
    SelectObject(FClientDC,hBmp);
    if FClientBuf<>0 then
      DeleteObject(FClientBuf);
    FClientBuf:=hBmp;
  end;

  // Resize Client area
  if x<>FClientRect.Right then
  begin
    FClientRect.Right := x;

    FRichCache.Width := FClientRect.Right - 2 * Padding;
    for i := 0 to Count - 1 do
      FItems[i].Height := -1;
  end;
  FClientRect.Bottom:=rc.Bottom;
  MoveWindow(FClient,
      FClientRect.Left,
      FClientRect.Top,
      FClientRect.Right,
      FClientRect.Bottom,
      false);
{}

  BarAdjusted := False;
  if Allocated then
    AdjustScrollBar;

  Invalidate;
  Update;
end;

procedure THistoryGrid.UpdateFilter;
begin
  if not Allocated then
    exit;
  CheckBusy;

  FRichCache.ResetItems(FSelItems);
  SetLength(FSelItems, 0);
  State := gsLoad;
  try

    SBHidden:=false;
    SBMax := Count + SBPageSize - 1;
    BarAdjusted := False;

    if (FSelected = -1) or (not IsMatched(FSelected)) then
    begin
      ShowProgress := True;
      try
        if FSelected <> -1 then
        begin
          FSelected := GetDown(FSelected);
          if FSelected = -1 then
            FSelected := GetUp(FSelected);
        end
        else
        begin
          if Reversed then
            // we have multiple selection sets
            FSelected := GetPrev(-1)
          else
            // we have multiple selection sets
            FSelected := GetNext(-1);
        end;
      finally
        ShowProgress := False;
      end;
    end;
    AdjustScrollBar;
  finally
    State := gsIdle;
    Selected := FSelected;
  end;
  Invalidate;
  Update;
end;
