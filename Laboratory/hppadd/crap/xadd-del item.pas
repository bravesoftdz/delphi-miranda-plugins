procedure THistoryGrid.AddItem;
var
  i: Integer;
begin
  SetLength(FItems, Count + 1);

  FRichCache.WorkOutItemAdded(0);

  Move(FItems[0], FItems[1], (Length(FItems) - 1) * SizeOf(FItems[0]));
  FillChar(FItems[0], SizeOf(FItems[0]), 0);

  FItems[0].MessageType := [mtUnknown];
  FItems[0].Height := -1;
  FItems[0].Text := '';
  // change selected here
  if Selected <> -1 then
    Inc(FSelected);
  // change inline edited item
  if ItemInline <> -1 then
    Inc(FItemInline);
  for i := 0 to SelCount - 1 do
    Inc(FSelItems[i]);
  BarAdjusted := False;
  AdjustScrollBar;

  Invalidate;
end;

procedure THistoryGrid.DeleteItem(Item: Integer);
var
  i: Integer;
  SelIdx: Integer;
begin
  // find item pos in selected array if it is there
  // and fix other positions becouse we have
  // to decrease some after we delete the item
  // from main array
  SelIdx := -1;
  FRichCache.WorkOutItemDeleted(Item);
  for i := 0 to SelCount - 1 do
  begin
    if FSelItems[i] = Item then
      SelIdx := i
    else if FSelItems[i] > Item then
      Dec(FSelItems[i]);
  end;

  if Item <> High(FItems) then
  begin
    Finalize(FItems[Item]);
    Move(FItems[Item + 1], FItems[Item], (High(FItems) - Item) * SizeOf(FItems[0]));
    FillChar(FItems[High(FItems)], SizeOf(FItems[0]), 0);
  end;
  SetLength(FItems, High(FItems));

  // if it was in selected array delete there also
  if SelIdx <> -1 then
  begin
    if SelIdx <> High(FSelItems) then
      Move(FSelItems[SelIdx + 1], FSelItems[SelIdx], (High(FSelItems) - SelIdx) *
        SizeOf(FSelItems[0]));
    SetLength(FSelItems, High(FSelItems));
  end;

  // move/delete inline edited item
  if ItemInline = Item then
    FItemInline := -1
  else if ItemInline > Item then
    Dec(FItemInline);

  // tell others they should clear up that item too
  if Assigned(FItemDelete) then
    FItemDelete(Self, Item);
end;

//--------------------------------

procedure THistoryGrid.Delete(Item: Integer);
var
  NextItem, Temp, PrevSelCount: Integer;
begin
  if Item = -1 then
    exit;
  State := gsDelete;
  NextItem := 0; // to avoid compiler warning
  try
    PrevSelCount := SelCount;
    if Selected = Item then
    begin
      // NextItem := -1;
      if Reversed then
        NextItem := GetNext(Item)
      else
        NextItem := GetPrev(Item);
    end;
    DeleteItem(Item);
    if Selected = Item then
    begin
      FSelected := -1;
      if Reversed then
        Temp := GetPrev(NextItem)
      else
        Temp := GetNext(NextItem);
      if Temp <> -1 then
        NextItem := Temp;
      if PrevSelCount = 1 then
        // rebuild FSelItems
        Selected := NextItem
      else if PrevSelCount > 1 then
      begin
        // don't rebuild, just change focus
        FSelected := NextItem;
        // check if we're out of SelItems
        if FSelected > Math.Max(FSelItems[High(FSelItems)], FSelItems[Low(FSelItems)]) then
          FSelected := Math.Max(FSelItems[High(FSelItems)], FSelItems[Low(FSelItems)]);
        if FSelected < Math.Min(FSelItems[High(FSelItems)], FSelItems[Low(FSelItems)]) then
          FSelected := Math.Min(FSelItems[High(FSelItems)], FSelItems[Low(FSelItems)]);
      end;
    end
    else
    begin
      if SelCount > 0 then
      begin
        if Item <= FSelected then
          Dec(FSelected);
      end;
    end;
    BarAdjusted := False;
    AdjustScrollBar;
    Invalidate;
  finally
    State := gsIdle;
  end;
end;

procedure THistoryGrid.DeleteAll;
var
  cur, Max: Integer;
begin
  State := gsDelete;
  try
    BarAdjusted := False;

    FRichCache.ResetAllItems;
    SetLength(FSelItems, 0);
    FSelected := -1;

    Max := Length(FItems) - 1;
    // cur := 0;

    ShowProgress := True;

    for cur := 0 to Max do
    begin
      if Assigned(FItemDelete) then
        FItemDelete(Self, -1);
      DoProgress(cur, Max);
      if cur = 0 then
        Invalidate;
    end;
    SetLength(FItems, 0);

    AdjustScrollBar;
    ShowProgress := False;
    DoProgress(0, 0);
    Invalidate;
    Update;
  finally
    State := gsIdle;
  end;
end;

const
  MIN_ITEMS_TO_SHOW_PROGRESS = 10;

procedure THistoryGrid.DeleteSelected;
var
  NextItem: Integer;
  Temp: Integer;
  s, { e, } Max, cur: Integer;
begin
  if SelCount = 0 then
    exit;

  State := gsDelete;
  try

    Max := Length(FSelItems) - 1;
    cur := 0;

    s := Math.Min(FSelItems[0], FSelItems[High(FSelItems)]);

    if Reversed then
      NextItem := GetNext(s)
    else
      NextItem := GetPrev(s);

    ShowProgress := (Length(FSelItems) >= MIN_ITEMS_TO_SHOW_PROGRESS);
    while Length(FSelItems) <> 0 do
    begin
      DeleteItem(FSelItems[0]);
      if ShowProgress then
        DoProgress(cur, Max);
      if (ShowProgress) and (cur = 0) then
        Invalidate;
      Inc(cur);
    end;

    BarAdjusted := False;
    AdjustScrollBar;

    if NextItem < 0 then
      NextItem := -1;
    FSelected := -1;
    if Reversed then
      Temp := GetPrev(NextItem)
    else
      Temp := GetNext(NextItem);
    if Temp = -1 then
      Selected := NextItem
    else
      Selected := Temp;

    if ShowProgress then
    begin
      ShowProgress := False;
      DoProgress(0, 0);
    end
    else
      Invalidate;
    Update;
  finally
    State := gsIdle;
  end;
end;

