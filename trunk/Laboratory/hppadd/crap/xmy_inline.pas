procedure THistoryGrid.AdjustInlineRichedit;
var
  r: TRect;
begin
  if (ItemInline = -1) or (ItemInline > Count) then
    exit;
  r := GetRichEditRect(ItemInline);
  if IsRectEmpty(r) then
    exit;
  // variant 1: move richedit around
  // variant 2: adjust TopItemOffset
  // variant 3: made logic changes in adjust toolbar to respect TopItemOffset
  // FRichInline.Top := r.top;
  Inc(TopItemOffset, r.Top - FRichInline.Top);
end;

procedure THistoryGrid.EditInline(Item: Integer);
var
  r: TRect;
begin
  if State = gsInline then
    CancelInline(False);
  MakeVisible(Item);
  r := GetRichEditRect(Item);
  if IsRectEmpty(r) then
    exit;

  // dunno why, but I have to fix it by 1 pixel
  // or positioning will be not perfectly correct
  // who knows why? i want to know! I already make corrections of margins!
  Inc(r.Right, 1);

  // below is not optimal way to show rich edit
  // (ie me better show it after applying item),
  // but it's done because now when we have OnProcessItem
  // event grid state is gsInline, which is how it should be
  // and you can't set it inline before setting focus
  // because of CheckBusy abort exception
  // themiron 03.10.2006. don't need to, 'cose there's check
  // if inline richedit got the focus

  State := gsInline;
  FItemInline := Item;
  ApplyItemToRich(Item, FRichInline);

  // set bounds after applying to avoid vertical scrollbar
  FRichInline.SetBounds(r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
  FRichInline.SelLength := 0;
  FRichInline.SelStart := 0;

  FRichInline.Show;
  FRichInline.SetFocus;
end;

procedure THistoryGrid.CancelInline(DoSetFocus: Boolean = True);
begin
  if State <> gsInline then
    exit;
  FRichInline.Hide;
  State := gsIdle;
  FRichInline.Clear;
  FRichInline.Top := -MaxInt;
  FRichInline.Height := -1;
  FItemInline := -1;
  if DoSetFocus then
    Windows.SetFocus(Handle);
end;

procedure THistoryGrid.OnInlineOnExit(Sender: TObject);
begin
  CancelInline;
end;

procedure THistoryGrid.OnInlineOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ((Key = VK_ESCAPE) or (Key = VK_RETURN)) then
  begin
    CancelInline;
    Key := 0;
  end
  else if Assigned(FOnInlineKeyDown) then
    FOnInlineKeyDown(Sender, Key, Shift);
end;

procedure THistoryGrid.OnInlineOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not FRichInline.Visible then
  begin
    CancelInline;
    Key := 0;
  end
  else

    if (Key = VK_APPS) or ((Key = VK_F10) and (ssShift in Shift)) then
  begin
    if Assigned(FOnInlinePopup) then
      FOnInlinePopup(Sender);
    Key := 0;
  end
  else

    if Assigned(FOnInlineKeyUp) then
    FOnInlineKeyUp(Sender, Key, Shift);
end;

procedure THistoryGrid.OnInlineOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin;
end;

procedure THistoryGrid.OnInlineOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) and Assigned(FOnInlinePopup) then
    FOnInlinePopup(Sender);
end;

procedure THistoryGrid.OnInlineOnURLClick(Sender: TObject; const URLText: String; Button: TMouseButton);
var
  P: TPoint;
  Item: Integer;
begin
  if Button = mbLeft then
  begin
    P := ScreenToClient(Mouse.CursorPos);
    Item := FindItemAt(P.X, P.Y);
    URLClick(Item, URLText, Button);
  end;
end;

