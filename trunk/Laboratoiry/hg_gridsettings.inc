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

function OnChange(Grid:PHistoryGrid;wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=0;
Grid.DoOptionsChanged; //!!!!
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
{!!
  if Assigned(FOnState) then
    FOnState(Self, FState);
}
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

  FClient.Invalidate;
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
  FClient.Invalidate;
  FClient.Update;
end;

procedure THistoryGrid.SetReversedHeader(const Value: Boolean);
begin
  if FReversedHeader = Value then
    exit;
  FReversedHeader := Value;

  if not Allocated then
    exit;

  FClient.Invalidate;
  FClient.Update;
end;

procedure THistoryGrid.SetRTLMode(const Value: TRTLMode);
var
  NewBiDiMode: TBiDiMode;
begin
  if FRTLMode <> Value then
  begin
    FRTLMode := Value;
    FRichCache.ResetAllItems;
    FClient.Invalidate;
    FClient.Update;
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

function THistoryGrid.GetProfileName: WideString;
begin
  if Assigned(GridOptions) and GridOptions.ForceProfileName then
    Result := GridOptions.ProfileName
  else
    Result := FProfileName;
end;

procedure THistoryGrid.SetProfileName(const Value: WideString);
begin
  if FProfileName = Value then
    exit;
  FProfileName := Value;
  if Assigned(GridOptions) and GridOptions.ForceProfileName then
    exit;
  FClient.Update;
end;

procedure THistoryGrid.SetContactName(const Value: WideString);
begin
  if FContactName = Value then
    exit;
  FContactName := Value;
  FClient.Update;
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
begin
  // recalc fonts
  for i := 0 to HIGH(FItems) do
  begin
    FItems[i].Height := -1;
  end;
  FRichCache.ResetAllItems;

  with FClient.Canvas^ do
  begin
    Font.Assign(GridOptions.FontProfile);             ph := TextExtent('Wy').cY;
    Font.Assign(GridOptions.FontContact);             Ch := TextExtent('Wy').cY;
    Font.Assign(GridOptions.FontOutgoingTimestamp);  pth := TextExtent('Wy').cY;
    Font.Assign(GridOptions.FontIncomingTimestamp);  cth := TextExtent('Wy').cY;
    Font.Assign(GridOptions.FontSessHeader);          sh := TextExtent('Wy').cY;
  end;
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

  FClient.Invalidate;
  FClient.Update; // cos when you change from GridOptions it updates with lag
end;

procedure THistoryGrid.GridUpdateSize;
var
  w: Integer;
  i: Integer;
begin
{!!
  if State = gsInline then
    CancelInline;
}
  IsCanvasClean := False;

  w := FClient.ClientWidth;

  if (GridWidth <> w) then
  begin
    FRichCache.Width := w - 2 * Padding;
    GridWidth := w;
    for i := 0 to Count - 1 do
      FItems[i].Height := -1;
  end;

  BarAdjusted := False;
  if Allocated then
    AdjustScrollBar;

  FClient.Invalidate;
  FClient.Update;
end;

procedure THistoryGrid.UpdateFilter;
begin
  if not Allocated then
    exit;
//!!  CheckBusy;

  FRichCache.ResetItems(FSelItems);
  SetLength(FSelItems, 0);
  State := gsLoad;
  try

    VertScrollBar.Visible := True;
    VertScrollBar.SBMax := Count + FVertScrollBar.SBPageSize - 1;
//??    VertScrollBar.Range := Count + FVertScrollBar.SBPageSize - 1;
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
  FClient.Invalidate;
  FClient.Update;
end;

