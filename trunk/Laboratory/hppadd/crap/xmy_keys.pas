procedure THistoryGrid.WMChar(var Message: TWMChar);
var
  Key: WideChar;
begin
  Key := WideChar(Message.CharCode);
  DoChar(Key, KeyDataToShiftState(Message.KeyData));
  Message.CharCode := Word(Key);
  inherited;
end;

const
  // #9 -- TAB
  // #13 -- ENTER
  // #27 -- ESC
  ForbiddenChars: array [0 .. 2] of WideChar = (#9, #13, #27);

procedure THistoryGrid.DoChar(var Ch: WideChar; ShiftState: TShiftState);
var
  ForbiddenChar: Boolean;
  i: Integer;
begin
  CheckBusy;
  ForbiddenChar := ((ssAlt in ShiftState) or (ssCtrl in ShiftState));
  i := 0;
  While (not ForbiddenChar) and (i <= High(ForbiddenChars)) do
  begin
    ForbiddenChar := (Ch = ForbiddenChars[i]);
    Inc(i);
  end;
  if ForbiddenChar then
    exit;
  if Assigned(FOnChar) then
    FOnChar(Self, Ch, ShiftState);
end;


procedure THistoryGrid.WMKeyDown(var Message: TWMKeyDown);
begin
  DoKeyDown(Message.CharCode, KeyDataToShiftState(Message.KeyData));
  inherited;
end;

procedure THistoryGrid.WMKeyUp(var Message: TWMKeyUp);
begin
  DoKeyUp(Message.CharCode, KeyDataToShiftState(Message.KeyData));
  inherited;
end;

procedure THistoryGrid.WMSysKeyUp(var Message: TWMSysKeyUp);
begin
  DoKeyUp(Message.CharCode, KeyDataToShiftState(Message.KeyData));
  inherited;
end;

procedure THistoryGrid.DoKeyDown(var Key: Word; ShiftState: TShiftState);
var
  NextItem, Item: Integer;
  r: TRect;
begin
  if Count = 0 then
    exit;
  if ssAlt in ShiftState then
    exit;
  CheckBusy;

  Item := Selected;
  if Item = -1 then
  begin
    if Reversed then
      Item := GetPrev(-1)
    else
      Item := GetNext(-1);
  end;

  if (Key = VK_HOME) or ((ssCtrl in ShiftState) and (Key = VK_PRIOR)) then
  begin
    SearchPattern := '';
    NextItem := GetNext(GetIdx(-1));
    if (not(ssShift in ShiftState)) or (not MultiSelect) then
    begin
      Selected := NextItem;
    end
    else if NextItem <> -1 then
    begin
      MakeSelectedTo(NextItem);
      MakeSelected(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end
  else if (Key = VK_END) or ((ssCtrl in ShiftState) and (Key = VK_NEXT)) then
  begin
    SearchPattern := '';
    NextItem := GetPrev(GetIdx(Count));
    if (not(ssShift in ShiftState)) or (not MultiSelect) then
    begin
      Selected := NextItem;
    end
    else if NextItem <> -1 then
    begin
      MakeSelectedTo(NextItem);
      MakeSelected(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end
  else if Key = VK_NEXT then
  begin // PAGE DOWN
    SearchPattern := '';
    NextItem := Item;
    r := GetItemRect(NextItem);
    NextItem := FindItemAt(0, r.Top + ClientHeight);
    if NextItem = Item then
    begin
      NextItem := GetNext(NextItem);
      if NextItem = -1 then
        NextItem := Item;
    end
    else if NextItem = -1 then
    begin
      NextItem := GetPrev(GetIdx(Count));
      if NextItem = -1 then
        NextItem := Item;
    end;
    if (not(ssShift in ShiftState)) or (not MultiSelect) then
    begin
      Selected := NextItem;
    end
    else if NextItem <> -1 then
    begin
      MakeSelectedTo(NextItem);
      MakeSelected(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end
  else if Key = VK_PRIOR then
  begin // PAGE UP
    SearchPattern := '';
    NextItem := Item;
    r := GetItemRect(NextItem);
    NextItem := FindItemAt(0, r.Top - ClientHeight);
    if NextItem <> -1 then
    begin
      if FItems[NextItem].Height < ClientHeight then
        NextItem := GetNext(NextItem);
    end
    else
      NextItem := GetNext(NextItem);
    if NextItem = -1 then
    begin
      if IsMatched(GetIdx(0)) then
        NextItem := GetIdx(0)
      else
        NextItem := GetNext(GetIdx(0));
    end;
    if (not(ssShift in ShiftState)) or (not MultiSelect) then
    begin
      Selected := NextItem;
    end
    else if NextItem <> -1 then
    begin
      MakeSelectedTo(NextItem);
      MakeSelected(NextItem);
      Invalidate;
    end;
    AdjustScrollBar;
    Key := 0;
  end
  else if Key = VK_UP then
  begin
    if ssCtrl in ShiftState then
      ScrollGridBy(-VLineScrollSize)
    else
    begin
      SearchPattern := '';
      if GetIdx(Item) > 0 then
        Item := GetPrev(Item);
      if Item = -1 then
        exit;
      if (ssShift in ShiftState) and (MultiSelect) then
      begin
        MakeSelectedTo(Item);
        MakeSelected(Item);
        Invalidate;
      end
      else
        Selected := Item;
      AdjustScrollBar;
    end;
    Key := 0;
  end
  else if Key = VK_DOWN then
  begin
    if ssCtrl in ShiftState then
      ScrollGridBy(VLineScrollSize)
    else
    begin
      SearchPattern := '';
      if GetIdx(Item) < Count - 1 then
        Item := GetNext(Item);
      if Item = -1 then
        exit;
      if (ssShift in ShiftState) and (MultiSelect) then
      begin
        MakeSelectedTo(Item);
        MakeSelected(Item);
        Invalidate;
      end
      else
        Selected := Item;
      AdjustScrollBar;
    end;
    Key := 0;
  end;

end;

procedure THistoryGrid.DoKeyUp(var Key: Word; ShiftState: TShiftState);
begin
  if Count = 0 then
    exit;
  if (ssAlt in ShiftState) or (ssCtrl in ShiftState) then
    exit;
  if (Key = VK_APPS) or ((Key = VK_F10) and (ssShift in ShiftState)) then
  begin
    CheckBusy;
    if Selected = -1 then
    begin
      if Reversed then
        Selected := GetPrev(-1)
      else
        Selected := GetNext(-1);
    end;
    if Assigned(FOnPopup) then
      OnPopup(Self);
    Key := 0;
  end;
end;

procedure THistoryGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
type
  PWMMsgKey = ^TWMMsgKey;

  TWMMsgKey = packed record
    hwnd: hwnd;
    msg: Cardinal;
    CharCode: Word;
    Unused: Word;
    KeyData: Longint;
    Result: Longint;
  end;

begin
  inherited;
  Message.Result := DLGC_WANTALLKEYS;
  if (TMessage(Message).lParam <> 0) then
  begin
    with PWMMsgKey(TMessage(Message).lParam)^ do
    begin
      if (msg = WM_KEYDOWN) or (msg = WM_CHAR) or (msg = WM_SYSCHAR) then
        case CharCode of
          VK_TAB:
            Message.Result := DLGC_WANTARROWS;
        end;
    end;
  end;
  Message.Result := Message.Result or DLGC_HASSETSEL;
end;
