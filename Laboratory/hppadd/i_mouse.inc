{}
function TranslateKeys(Keys: word): TMouseKeys;
begin
  Result := [];
  if Keys and MK_CONTROL > 0 then Result := Result + [mkControl];
  if Keys and MK_LBUTTON > 0 then Result := Result + [mkLButton];
  if Keys and MK_MBUTTON > 0 then Result := Result + [mkMButton];
  if Keys and MK_RBUTTON > 0 then Result := Result + [mkRButton];
  if Keys and MK_SHIFT   > 0 then Result := Result + [mkShift];
end;

procedure THistoryGrid.URLClick(Item: Integer; URLText: PWideChar; Button: TMouseKey);
var
  menu:HMENU;
  pt:TPOINT;
begin
//  SendMessageW(FHintWindow,TTM_POP,0,0);
  Windows.SetCursor(GridOptions.CursorDefault);
{
  if Assigned(OnUrlClick) then
    OnUrlClick(Self, Item, URLText, Button);
}
  if Button in [mkLButton, mkMButton] then
    OpenUrl(URLText)
  else if Button = mkRButton then
  begin
    GetCursorPos(pt);
    menu:=CreatePopupMenu;
    AppendMenuW(menu,MF_STRING,100,TranslateW('Open &Link'));
    AppendMenuW(menu,MF_STRING,101,TranslateW('&Copy Link'));
    case integer(TrackPopupMenu(menu,TPM_RETURNCMD+TPM_NONOTIFY,pt.x,pt.y,0,FClient,nil)) of
      100: OpenUrl   (URLText);
      101: CopyToClip(URLText, Handle);
    end;
    DestroyMenu(menu);
  end;
  mFreeMem(URLText);
end;

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
  oldf:HFONT;
  sz:TSize;
  lText:pWideChar;
  idx:integer;
begin
  Result := [];
  SetRectEmpty(FHintRect);
  Item := FindItemAt(X, Y);
  if Item = -1 then
    exit;
  Include(Result, ghtItem);

  FullHeader := not(FGroupLinked and FItems[Item].LinkedToPrev);
  ItemRect := GetItemRect(Item);
  RTL := GetItemRTL(Item);
  Sel := IsSelected(Item);
  Point(P, X, Y);

  if FullHeader and (ShowHeaders) and (ExpandHeaders) and (FItems[Item].HasHeader) then
  begin
    if Reversed xor ReversedHeader then
    begin
      SetRect(SessRect, ItemRect.Left, ItemRect.Top, ItemRect.Right,
        ItemRect.Top + SessHeaderHeight);
      Inc(ItemRect.Top, SessHeaderHeight);
    end
    else
    begin
      SetRect(SessRect, ItemRect.Left, ItemRect.Bottom - SessHeaderHeight - 1,
        ItemRect.Right, ItemRect.Bottom - 1);
      Dec(ItemRect.Bottom, SessHeaderHeight);
    end;
    if PointInRect(P, SessRect) then
    begin
      Include(Result, ghtSession);
      InflateRect(SessRect, -3, -3);

      if RTL then
        SetRect(ButtonRect, SessRect.Left, SessRect.Top, SessRect.Left + 16, SessRect.Bottom)
      else
        SetRect(ButtonRect, SessRect.Right - 16, SessRect.Top, SessRect.Right, SessRect.Bottom);

      if PointInRect(P, ButtonRect) then
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

    if IsIncomingEvent(FItems[Item]) then
      HeaderHeight := CHeaderHeight
    else
      HeaderHeight := PHeaderheight;

    SetRect(HeaderRect, ItemRect.Left, ItemRect.Top, ItemRect.Right, ItemRect.Top + HeaderHeight);
    Inc(ItemRect.Top, HeaderHeight + (Padding - (Padding div 2)));
    if PointInRect(P, HeaderRect) then
    begin
      Include(Result, ghtHeader);
      if (ShowHeaders) and (not ExpandHeaders) and (FItems[Item].HasHeader) then
      begin
        if RTL then
          SetRect(ButtonRect, HeaderRect.Right - 16, HeaderRect.Top, HeaderRect.Right, HeaderRect.Bottom)
        else
          SetRect(ButtonRect, HeaderRect.Left, HeaderRect.Top, HeaderRect.Left + 16, HeaderRect.Bottom);
        if PointInRect(P, ButtonRect) then
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
{
        if mtIncoming in FItems[Item].MessageType then
          FClient.Canvas.Font.Assign(GridOptions.FontIncomingTimestamp)
        else
          FClient.Canvas.Font.Assign(GridOptions.FontOutgoingTimestamp);
        TimestampOffset:=FClient.Canvas.TextExtent(GetDateTimeString(FItems[Item].Time)).cX + Padding;
}
        if IsIncomingEvent(FItems[Item]) then
          idx:=fiInTime
        else
          idx:=fiOutTime;
        oldf:=SelectObject(FClientDC,GridOptions.Font[idx]);
        lText:=GetDateTimeString(FItems[Item].Time);
        GetTextExtentPoint32W(FClientDC, lText, StrLenW(lText), sz);
        mFreeMem(lText);
        TimestampOffset:=sz.cX + Padding;
        SelectObject(FClientDC,oldf);

        if RTL then
          SetRect(ButtonRect,HeaderRect.Left + TimestampOffset, HeaderRect.Top,
            HeaderRect.Left + TimestampOffset + 16, HeaderRect.Bottom)
        else
          SetRect(ButtonRect, HeaderRect.Right - 16 - TimestampOffset, HeaderRect.Top,
            HeaderRect.Right - TimestampOffset, HeaderRect.Bottom);
        if PointInRect(P, ButtonRect) then
        begin
          Include(Result, ghtBookmark);
          Include(Result, ghtButton);
          FHintRect := ButtonRect;
        end;
      end;
    end;
  end;

  if PointInRect(P, ItemRect) then
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

procedure THistoryGrid.DoLButtonUp(X, Y: integer);
var
  ht: TGridHitTests;
begin
  ht := GetHitTests(X, Y) * DownHitTests;
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
      FOnBookmarkClick(FindItemAt(X, Y));
    end;
}
  end

  else if (ghtLink in ht) then
  begin
    URLClick(FindItemAt(X, Y), GetLinkAtPoint(X, Y), mkLButton);
  end;
end;

procedure THistoryGrid.OnGridMouseWheel(Shift:SmallInt);
var
  Lines, code: Integer;
  FWheelCurrTick: Cardinal;
begin
  if State = gsInline then
  begin
//!!    with TMessage(Message) do FRichInline.Perform(WM_MOUSEWHEEL, wParam, lParam);
    exit;
  end;

//  if (Cardinal(Message.WheelDelta) = WHEEL_PAGESCROLL) or (Mouse.WheelScrollLines < 0) then
// wheeldelta=wparam
  if (Cardinal(Shift) = WHEEL_PAGESCROLL) then
  begin
    Lines := 1;
    if Shift < 0 then
      code := SB_PAGEDOWN
    else
      code := SB_PAGEUP;
  end
  else
  begin
    Lines := ABS(Shift) div WHEEL_DELTA;
    if Shift < 0 then
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

  FWheelAccumulator := FWheelAccumulator + Shift * Lines;
  while Abs(FWheelAccumulator) >= WHEEL_DELTA do
  begin
    FWheelAccumulator := Abs(FWheelAccumulator) - WHEEL_DELTA;
    PostMessage(FHandle, WM_VSCROLL, code, FScrollBar);
  end;
end;

procedure THistoryGrid.OnMouseMessage(hMessage:UInt; wParam:WPARAM; lParam:LPARAM);
var
  X,Y:integer;
  Item: Integer;
  ht: TGridHitTests;
  Keys:tMouseKeys;
  SelectMove: Boolean;
begin
  if hMessage = WM_MOUSEWHEEL then
  begin
    OnGridMouseWheel(SmallInt(Hiword(wParam)));
  end
  else
  begin
    X:=SmallInt(LoWord(lParam));
    Y:=SmallInt(HiWord(lParam));
    Keys:=TranslateKeys(LoWord(wParam));

    case hMessage of
{
      //----- Mouse wheel -----

      WM_MOUSEWHEEL: begin
      end;
}
      //----- Mouse move -----

      WM_MOUSEMOVE: begin
        if not FGridNotFocused {??Focused} then
        begin
          CheckBusy;
          if Count = 0 then
            exit;

          // do we need to process control here?
          SelectMove := ((mkLButton in Keys) and not((mkControl in Keys) or (mkShift in Keys))) and
            (MultiSelect) and (WasDownOnGrid);

          SelectMove := SelectMove and not((ghtButton in DownHitTests) or (ghtLink in DownHitTests));

          if SelectMove then
          begin
            if SelCount = 0 then
              exit;
            Item := FindItemAt(X, Y);
            if Item = -1 then
              exit;
            // do not do excessive relisting of items
            if (not((FSelItems[0] = Item) or (FSelItems[High(FSelItems)] = Item))) or
               (FSelected <> Item) then
            begin
              MakeSelectedTo(Item);
            end;
          end;
        end;
      end;

      //--- Button down ---

      WM_MBUTTONDOWN: begin
        if FGridNotFocused then
          Windows.SetFocus(FClient);

        WasDownOnGrid := True;
        if Count = 0 then
          exit;
        DownHitTests := GetHitTests(X, Y);
      end;

      WM_RBUTTONDOWN: begin
      end;

      WM_LBUTTONDOWN: begin
        if FGridNotFocused then
          Windows.SetFocus(FClient);
        WasDownOnGrid := True;
      //!!  SearchPattern := '';
        CheckBusy;
        if Count = 0 then
          exit;

        DownHitTests := GetHitTests(X, Y);

        // we'll hide/show session headers on button up, don't select item
        if (ghtButton in DownHitTests) or (ghtLink in DownHitTests) then
          exit;

        Item := FindItemAt(X, Y);

        if Item <> -1 then
        begin
          if GetKeyState(VK_CONTROL)<0 then
          begin
            if IsSelected(Item) then
              RemoveSelected(Item)
            else
              AddSelected(Item);
            MakeSelected(Item);
          end
          else if (Selected<>-1) and (GetKeyState(VK_SHIFT)<0) then
          begin
            MakeSelectedTo(Item);
          end
          else
            Selected := Item;
        end;
      end;

      //--- Button up ---

      WM_MBUTTONUP: begin
        ht := GetHitTests(X, Y) * DownHitTests;
        DownHitTests := [];
        WasDownOnGrid := False;
        if (ghtLink in ht) then
        begin
          URLClick(FindItemAt(X, Y), GetLinkAtPoint(X, Y), mkMButton);
        end;
      end;

      WM_RBUTTONUP: begin
  //!!      SearchPattern := '';
        CheckBusy;

        Item := FindItemAt(X, Y);

        ht := GetHitTests(X, Y);
        if (ghtLink in ht) then
        begin
          URLClick(Item, GetLinkAtPoint(X, Y), mkRButton);
          exit;
        end;

        if Selected <> Item then
        begin
          if IsSelected(Item) then
          begin
            FSelected := Item;
            MakeVisible(Item);
            Invalidate;
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
OnSpeakMessage;
      end;

      WM_LBUTTONUP: begin
        DoLButtonUp(X,Y);
      end;

      //--- Double click ---

      WM_MBUTTONDBLCLK: begin
      end;
      WM_RBUTTONDBLCLK: begin
      end;
      WM_LBUTTONDBLCLK: begin
  //!!      SearchPattern := '';
        CheckBusy;
        ht := GetHitTests(X, Y);
        if (ghtSessShowButton in ht) or
           (ghtSessHideButton in ht) or
           (ghtBookmark       in ht) then
          exit;

        if ghtLink in ht then
        begin
          DownHitTests := ht;
          DoLButtonUp(X,Y);
        end
        else
        begin
          Item := FindItemAt(X, Y);
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
    end;
  end;
end;

function THistoryGrid.OnSetCursor(wParam:WPARAM; lParam:LPARAM):lresult;
var
  P:TPOINT;
  NewCursor:HCURSOR;
  oldHitTest:TGridHitTests;
  oldHintRect:TRect;
begin
  result:=0;

  if State <> gsIdle then
    exit;
  if LoWord(lParam) = word(HTERROR) then
    exit;

  GetCursorPos(P);
  ScreenToClient(wParam,P);
  oldHitTest := HintHitTests;
  oldHintRect:= FHintRect;
  HintHitTests := GetHitTests(P.X, P.Y);

  // Cursor changing (if needs)
  if HintHitTests * [ghtButton, ghtLink] <> [] then
    NewCursor := GridOptions.CursorHand
  else
    NewCursor := GridOptions.CursorDefault;

  if Windows.GetCursor <> NewCursor then
  begin
    Windows.SetCursor(NewCursor);
    result := 1;
  end;

  // Hint (hover) check
  if (not PointInRect(P,oldHintRect)) or // outside old region
     (oldHitTest<>HintHitTests) then     // point to another type
  begin
    KillTimer(FClient, TIMERID_HOVER);           // old timer gone
    SetTimer (FClient, TIMERID_HOVER, 450, nil); // new pause
  end;

end;
