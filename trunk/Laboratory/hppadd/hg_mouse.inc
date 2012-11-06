{}
var
  // WasDownOnGrid hack was introduced
  // because I had the following problem: when I have
  // history of contact A opened and have search results
  // with messages from A, and if the history is behind the
  // search results window, when I double click A's message
  // I get hisory to the front with sometimes multiple messages
  // selected because it 1) selects right message;
  // 2) brings history window to front; 3) sends wm_mousemove message
  // to grid saying that left button is pressed (???) and because
  // of that shit grid thinks I'm selecting several items. So this
  // var is used to know whether mouse button was down down on grid
  // somewhere else
  WasDownOnGrid: Boolean = False;

function THistoryGrid.GetHitTests(X, Y: Integer): TGridHitTests;
var
  Item: Integer;
  ItemRect: TRect;
  HeaderHeight: Integer;
  HeaderRect, SessRect: TRect;
  ButtonRect: TRect;
  P: TPoint;
  RTL: Boolean;
  Sel: Boolean;
  FullHeader: Boolean;
  TimestampOffset: Integer;
begin
  Result := [];
  FHintRect:=MakeRect(0, 0, 0, 0);
  Item := FindItemAt(X, Y);
  if Item = -1 then
    exit;
  Include(Result, ghtItem);

  FullHeader := not(FGroupLinked and FItems[Item].LinkedToPrev);
  ItemRect := GetItemRect(Item);
  RTL := GetItemRTL(Item);
  Sel := IsSelected(Item);
  P := MakePoint(X, Y);

  if FullHeader and (ShowHeaders) and (ExpandHeaders) and (FItems[Item].HasHeader) then
  begin
    if Reversed xor ReversedHeader then
    begin
      SessRect := MakeRect(ItemRect.Left, ItemRect.Top, ItemRect.Right,
        ItemRect.Top + SessHeaderHeight);
      Inc(ItemRect.Top, SessHeaderHeight);
    end
    else
    begin
      SessRect := MakeRect(ItemRect.Left, ItemRect.Bottom - SessHeaderHeight - 1,
        ItemRect.Right, ItemRect.Bottom - 1);
      Dec(ItemRect.Bottom, SessHeaderHeight);
    end;
    if PtInRect(SessRect, P) then
    begin
      Include(Result, ghtSession);
      InflateRect(SessRect, -3, -3);
      if RTL then
        ButtonRect := MakeRect(SessRect.Left, SessRect.Top, SessRect.Left + 16, SessRect.Bottom)
      else
        ButtonRect := MakeRect(SessRect.Right - 16, SessRect.Top, SessRect.Right, SessRect.Bottom);
      if PtInRect(ButtonRect, P) then
      begin
        Include(Result, ghtSessHideButton);
        Include(Result, ghtButton);
        FHintRect := ButtonRect;
      end;
    end;
  end;

  Dec(ItemRect.Bottom); // divider
  InflateRect(ItemRect, -Padding, -Padding); // paddings

  if FullHeader then
  begin
    Dec(ItemRect.Top, Padding);
    Inc(ItemRect.Top, Padding div 2);

    if mtIncoming in FItems[Item].MessageType then
      HeaderHeight := CHeaderHeight
    else
      HeaderHeight := PHeaderheight;

    HeaderRect := MakeRect(ItemRect.Left, ItemRect.Top, ItemRect.Right,
      ItemRect.Top + HeaderHeight);
    Inc(ItemRect.Top, HeaderHeight + (Padding - (Padding div 2)));
    if PtInRect(HeaderRect, P) then
    begin
      Include(Result, ghtHeader);
      if (ShowHeaders) and (not ExpandHeaders) and (FItems[Item].HasHeader) then
      begin
        if RTL then
          ButtonRect := MakeRect(HeaderRect.Right - 16, HeaderRect.Top, HeaderRect.Right,
            HeaderRect.Bottom)
        else
          ButtonRect := MakeRect(HeaderRect.Left, HeaderRect.Top, HeaderRect.Left + 16,
            HeaderRect.Bottom);
        if PtInRect(ButtonRect, P) then
        begin
          Include(Result, ghtSessShowButton);
          Include(Result, ghtButton);
          FHintRect := ButtonRect;
        end;
      end;

      if ShowBookmarks and (Sel or FItems[Item].Bookmarked) then
      begin
        // TimeStamp := GetTime(FItems[Item].Time);
        // Canvas.Font.Assign(Options.FontTimeStamp);
        if mtIncoming in FItems[Item].MessageType then
          FClient.Canvas.Font.Assign(GridOptions.FontIncomingTimestamp)
        else
          FClient.Canvas.Font.Assign(GridOptions.FontOutgoingTimestamp);
        TimestampOffset:=FClient.Canvas.TextExtent(GetDateTimeString(FItems[Item].Time)).cX + Padding;

        if RTL then
          ButtonRect := MakeRect(HeaderRect.Left + TimestampOffset, HeaderRect.Top,
            HeaderRect.Left + TimestampOffset + 16, HeaderRect.Bottom)
        else
          ButtonRect := MakeRect(HeaderRect.Right - 16 - TimestampOffset, HeaderRect.Top,
            HeaderRect.Right - TimestampOffset, HeaderRect.Bottom);
        if PtInRect(ButtonRect, P) then
        begin
          Include(Result, ghtBookmark);
          Include(Result, ghtButton);
          FHintRect := ButtonRect;
        end;
      end;
    end;
  end;

  if PtInRect(ItemRect, P) then
  begin
    Include(Result, ghtText);
    FHintRect := ItemRect;
    if IsLinkAtPoint(ItemRect, X, Y, Item) then
      Include(Result, ghtLink)
    else
      Include(Result, ghtUnknown);
  end;
end;

//----- Direct mouse events processing -----

procedure THistoryGrid.DoLButtonDown(var Mouse:TMouseEventData);
var
  Item:integer;
begin
  WasDownOnGrid := True;
//!!  SearchPattern := '';
  CheckBusy;
  if Count = 0 then
    exit;

  DownHitTests := GetHitTests(Mouse.X, Mouse.Y);

  // we'll hide/show session headers on button up, don't select item
  if (ghtButton in DownHitTests) or (ghtLink in DownHitTests) then
    exit;

  Item := FindItemAt(Mouse.X, Mouse.Y);

  if Item <> -1 then
  begin
    if GetKeyState(VK_CONTROL)<0 then
    begin
      if IsSelected(Item) then
        RemoveSelected(Item)
      else
        AddSelected(Item);
      MakeSelected(Item);
      FClient.Invalidate;
    end
    else if (Selected<>-1) and (GetKeyState(VK_SHIFT)<0) then
    begin
      MakeSelectedTo(Item);
      MakeSelected(Item);
      FClient.Invalidate;
    end
    else
      Selected := Item;
  end;
end;

procedure THistoryGrid.DoLButtonUp(var Mouse:TMouseEventData);
var
  ht: TGridHitTests;
begin
  ht := GetHitTests(Mouse.X, Mouse.Y) * DownHitTests;
  DownHitTests := [];
  WasDownOnGrid := False;

  if ((ghtSessHideButton in ht) or (ghtSessShowButton in ht)) then
  begin
    ExpandHeaders := (ghtSessShowButton in ht);
  end

  else if (ghtBookmark in ht) then
  begin
{!!
    if Assigned(FOnBookmarkClick) then
    begin
      FOnBookmarkClick(Self, FindItemAt(Mouse.X, Mouse.Y));
    end;
}
  end

  else if (ghtLink in ht) then
  begin
//!!    URLClick(FindItemAt(Mouse.X, Mouse.Y), GetLinkAtPoint(Mouse.X, Mouse.Y), mbLeft);
  end;
end;

procedure THistoryGrid.OnGridMouseDown(Sender:PControl; var Mouse:TMouseEventData);
begin
  if FGridNotFocused then
    Windows.SetFocus(FClient.Handle);

  case Mouse.Button of
    mbLeft: begin
      DoLButtonDown(Mouse);
    end;

    mbRight: begin
    end;

    mbMiddle: begin
      WasDownOnGrid := True;
      if Count = 0 then
        exit;
      DownHitTests := GetHitTests(Mouse.X, Mouse.Y);
    end
  end;
end;

procedure THistoryGrid.OnGridMouseUp(Sender:PControl; var Mouse:TMouseEventData);
var
  Item: Integer;
  ht: TGridHitTests;
begin
  case Mouse.Button of
    mbLeft: begin
      DoLButtonUp(Mouse);
    end;

    mbRight: begin
//!!      SearchPattern := '';
      CheckBusy;

      Item := FindItemAt(Mouse.X, Mouse.Y);

      ht := GetHitTests(Mouse.X, Mouse.Y);
      if (ghtLink in ht) then
      begin
//!!        URLClick(Item, GetLinkAtPoint(Mouse.X, Mouse.Y), mbRight);
        exit;
      end;

      if Selected <> Item then
      begin
        if IsSelected(Item) then
        begin
          FSelected := Item;
          MakeVisible(Item);
          FClient.Invalidate;
        end
        else
        begin
          Selected := Item;
        end;
      end;
{!!
      if Assigned(FOnPopup) then
        OnPopup(Self);
}
    end;

    mbMiddle: begin
      ht := GetHitTests(Mouse.X, Mouse.Y) * DownHitTests;
      DownHitTests := [];
      WasDownOnGrid := False;
      if (ghtLink in ht) then
      begin
//!!        URLClick(FindItemAt(Mouse.X, Mouse.Y), GetLinkAtPoint(Mouse.X, Mouse.Y), mbMiddle);
      end;
    end
  end;
end;

procedure THistoryGrid.OnGridMouseDblClick(Sender:PControl; var Mouse:TMouseEventData);
var
  Item: Integer;
  ht: TGridHitTests;
begin
  case Mouse.Button of
    mbLeft: begin
//!!      SearchPattern := '';
      CheckBusy;
      ht := GetHitTests(Mouse.X, Mouse.Y);
      if (ghtSessShowButton in ht) or
         (ghtSessHideButton in ht) or
         (ghtBookmark in ht) then
        exit;

      if ghtLink in ht then
      begin
        DownHitTests := ht;
        DoLButtonUp(Mouse);
      end
      else
      begin
        Item := FindItemAt(Mouse.X, Mouse.Y);
        if Item <> Selected then
        begin
          Selected := Item;
        end
        else
        begin
{!!
          if Assigned(OnDblClick) then
            OnDblClick(@Self);
}
        end;
      end;
    end;

    mbRight: begin
    end;

    mbMiddle: begin
    end
  end;
end;

procedure THistoryGrid.OnGridMouseMove(Sender:PControl; var Mouse:TMouseEventData);
var
  Item: Integer;
  SelectMove: Boolean;
begin
  if not FGridNotFocused {??Focused} then
  begin
    CheckBusy;
    if Count = 0 then
      exit;

    // do we need to process control here?
    SelectMove := ((Mouse.Button=mbLeft) and
      not((GetKeyState(VK_CONTROL)<0) or (GetKeyState(VK_SHIFT)<0))) and
//      not((mmkControl in Keys) or (mmkShift in Keys))) and
      (MultiSelect) and (WasDownOnGrid);
    SelectMove := SelectMove and not((ghtButton in DownHitTests) or (ghtLink in DownHitTests));

    if SelectMove then
    begin
      if SelCount = 0 then
        exit;
      Item := FindItemAt(Mouse.X, Mouse.Y);
      if Item = -1 then
        exit;
      // do not do excessive relisting of items
      if (not((FSelItems[0] = Item) or (FSelItems[High(FSelItems)] = Item))) or
         (FSelected <> Item) then
      begin
        MakeSelectedTo(Item);
        MakeSelected(Item);
        FClient.Invalidate;
      end;
    end;
  end;
end;

procedure THistoryGrid.OnGridMouseWheel(Sender:PControl; var Mouse:TMouseEventData);
var
  Lines, code: Integer;
  FWheelCurrTick: Cardinal;
begin
  if State = gsInline then
  begin
//!!    with TMessage(Message) do FRichInline.Perform(WM_MOUSEWHEEL, wParam, lParam);
    exit;
  end;

  if (Cardinal(Mouse.Shift) = WHEEL_PAGESCROLL) then
  begin
    Lines := 1;
    if SmallInt(HiWord(Mouse.Shift)) < 0 then
      code := SB_PAGEDOWN
    else
      code := SB_PAGEUP;
  end
  else
  begin
    Lines := ABS(SmallInt(HiWord(Mouse.Shift)) div WHEEL_DELTA);
    if SmallInt(HiWord(Mouse.Shift)) < 0 then
      code := SB_LINEDOWN
    else
      code := SB_LINEUP;
  end;

  // some kind of acceleraion. mb the right place is in WM_VSCROLL?
  FWheelCurrTick := GetTickCount;
  if FWheelCurrTick - FWheelLastTick < 10 then
  begin
    Lines := Lines shl 1;
  end;
  FWheelLastTick := FWheelCurrTick;

  FWheelAccumulator := FWheelAccumulator + SmallInt(HiWord(Mouse.Shift)) * Lines;
  while Abs(FWheelAccumulator) >= WHEEL_DELTA do
  begin
    FWheelAccumulator := Abs(FWheelAccumulator) - WHEEL_DELTA;
    PostMessage(Sender.Handle, WM_VSCROLL, code, FVertScrollBar.Handle);
  end;
end;
