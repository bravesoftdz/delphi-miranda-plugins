{}

procedure THistoryGrid.SetHideSelection(const Value: Boolean);
begin
  if FHideSelection = Value then
    exit;
  FHideSelection := Value;
  if FGridNotFocused and (SelCount > 0) then
  begin
    FRichCache.ResetItems(FSelItems);
    FClient.Invalidate;
  end;
end;

function THistoryGrid.IsSelected(Item: Integer): Boolean;
begin
  Result := False;

  if FHideSelection and FGridNotFocused then
    exit;

  if Item = -1 then
    exit;
  Result := IntSortedArray_Find(TIntArray(FSelItems), Item) <> -1;
end;

function THistoryGrid.GetSelCount: Integer;
begin
  Result := Length(FSelItems);
end;

procedure THistoryGrid.MakeSelected(Value: Integer);
var
  OldSelected: Integer;
begin
  OldSelected := FSelected;
  FSelected := Value;

  if Value <> -1 then
    MakeVisible(FSelected);

  if Assigned(FOnSelect) then
  begin
    if IsVisible(FSelected) then
      FOnSelect(@Self, FSelected, OldSelected)
    else
      FOnSelect(@Self, -1, OldSelected);
  end;

  FSelectionStored := False;
end;

procedure THistoryGrid.SetSelected(const Value: Integer);
begin
  FRichCache.ResetItem(Value);
  FRichCache.ResetItems(FSelItems);
  if Value <> -1 then
  begin
    SetLength(FSelItems, 1);
    FSelItems[0] := Value;
  end
  else
    SetLength(FSelItems, 0);
  MakeSelected(Value);
  FClient.Invalidate;
  FClient.Update;
end;

procedure THistoryGrid.AddSelected(Item: Integer);
begin
  if IsSelected(Item) then
    exit;
  if IsUnknown(Item) then
    LoadItem(Item, False);
  if not IsMatched(Item) then
    exit;
  IntSortedArray_Add(TIntArray(FSelItems), Item);
  FRichCache.ResetItem(Item);
end;

procedure THistoryGrid.RemoveSelected(Item: Integer);
begin
  IntSortedArray_Remove(TIntArray(FSelItems), Item);
  FRichCache.ResetItem(Item);
end;

function THistoryGrid.GetSelItems(Index: Integer): Integer;
begin
  Result := FSelItems[Index];
end;

procedure THistoryGrid.SetSelItems(Index: Integer; Item: Integer);
begin
  AddSelected(Item);
end;

procedure THistoryGrid.MakeRangeSelected(FromItem, ToItem: Integer);
var
  i: Integer;
  StartItem, EndItem: Integer;
  len: Integer;
  Changed: TIntArray;
begin
  // detect start and end
  if FromItem <= ToItem then
  begin
    StartItem := FromItem;
    EndItem := ToItem;
  end
  else
  begin
    StartItem := ToItem;
    EndItem := FromItem;
  end;

  // fill selected items list
  len := 0;
  for i := StartItem to EndItem do
  begin
    if IsUnknown(i) then
      LoadItem(i, False);
    if not IsMatched(i) then
      continue;
    Inc(len);
    SetLength(TempSelItems, len);
    TempSelItems[len - 1] := i;
  end;

  // determine and update changed items
  Changed := IntSortedArray_NonIntersect(TIntArray(FSelItems), TIntArray(TempSelItems));
  FRichCache.ResetItems(Changed);

  // set selection
  FSelItems := TempSelItems;
end;

procedure THistoryGrid.SelectRange(FromItem, ToItem: Integer);
begin
  if (FromItem = -1) or (ToItem = -1) then
    exit;
  MakeRangeSelected(FromItem, ToItem);
  if SelCount = 0 then
    MakeSelected(-1)
  else
    MakeSelected(FSelItems[0]);
  FClient.Invalidate;
end;

procedure THistoryGrid.SelectAll;
begin
  if Count = 0 then
    exit;
  MakeRangeSelected(0, Count - 1);
  if SelCount = 0 then
    MakeSelected(-1)
  else
    MakeSelected(FSelected);
  FClient.Invalidate;
end;

procedure THistoryGrid.MakeSelectedTo(Item: Integer);
var
  first: Integer;
begin
  if (FSelected = -1) or (Item = -1) then
    exit;
  if FSelItems[0] = FSelected then
    first := FSelItems[High(FSelItems)]
  else if FSelItems[High(FSelItems)] = FSelected then
    first := FSelItems[0]
  else
    first := FSelected;
  MakeRangeSelected(first, Item);
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
