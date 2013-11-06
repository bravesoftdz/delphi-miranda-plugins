{}
function THistoryGrid.OnKeyMessage(hMessage:UInt; wParam:WPARAM; lParam:LPARAM):lresult;
var
  r: TRect;
  lAlt,lCtrl,lShift:bool;
  NextItem, Item: Integer;
begin
  result:=0;

  lCtrl  := GetKeyState(VK_CONTROL) < 0;
  lShift := GetKeyState(VK_SHIFT  ) < 0;
  lAlt   := (lParam and (1 shl 29)) <> 0; // GetKeyState(VK_MENU) < 0

  case hMessage of
    //!!  replaces char if needs (idk how to implement it)
    WM_CHAR: begin
      CheckBusy;
      if lAlt or lCtrl or (wParam in [9,13,27]) then
        exit;
{!!
      if Assigned(FOnChar) then
        FOnChar(Self, Ch, ShiftState);
}
    end;

    WM_KEYDOWN: begin
      if Count = 0 then
        exit;
      if lAlt then
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

      if (wParam = VK_HOME) or (lCtrl and (wParam = VK_PRIOR)) then
      begin
//!!        SearchPattern := '';
        NextItem := GetNext(GetIdx(-1));
        if (not(lShift)) or (not MultiSelect) then
        begin
          Selected := NextItem;
        end
        else if NextItem <> -1 then
        begin
          MakeSelectedTo(NextItem);
          Invalidate;
        end;
        AdjustScrollBar;
        result := 1;
      end

      else if (wParam = VK_END) or (lCtrl and (wParam = VK_NEXT)) then
      begin
//!!        SearchPattern := '';
        NextItem := GetPrev(GetIdx(Count));
        if (not(lShift)) or (not MultiSelect) then
        begin
          Selected := NextItem;
        end
        else if NextItem <> -1 then
        begin
          MakeSelectedTo(NextItem);
          Invalidate;
        end;
        AdjustScrollBar;
        result := 1;
      end

      else if wParam = VK_NEXT then
      begin // PAGE DOWN
//!!        SearchPattern := '';
        NextItem := Item;
        r := GetItemRect(NextItem);
        NextItem := FindItemAt(0, r.Top + FClientRect.Bottom);
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
        if (not(lShift)) or (not MultiSelect) then
        begin
          Selected := NextItem;
        end
        else if NextItem <> -1 then
        begin
          MakeSelectedTo(NextItem);
          Invalidate;
        end;
        AdjustScrollBar;
        result := 1;
      end

      else if wParam = VK_PRIOR then
      begin // PAGE UP
//!!        SearchPattern := '';
        NextItem := Item;
        r := GetItemRect(NextItem);
        NextItem := FindItemAt(0, r.Top - FClientRect.Bottom);
        if NextItem <> -1 then
        begin
          if FItems[NextItem].Height < FClientRect.Bottom then
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
        if (not(lShift)) or (not MultiSelect) then
        begin
          Selected := NextItem;
        end
        else if NextItem <> -1 then
        begin
          MakeSelectedTo(NextItem);
          Invalidate;
        end;
        AdjustScrollBar;
        result := 1;
      end

      else if wParam = VK_UP then
      begin
        if lCtrl then
          ScrollGridBy(-VLineScrollSize)
        else
        begin
//!!          SearchPattern := '';
          if GetIdx(Item) > 0 then
            Item := GetPrev(Item);
          if Item = -1 then
            exit;
          if (lShift) and (MultiSelect) then
          begin
            MakeSelectedTo(Item);
            Invalidate;
          end
          else
            Selected := Item;
          AdjustScrollBar;
        end;
        result := 1;
      end

      else if wParam = VK_DOWN then
      begin
        if lCtrl then
          ScrollGridBy(VLineScrollSize)
        else
        begin
//!!          SearchPattern := '';
          if GetIdx(Item) < Count - 1 then
            Item := GetNext(Item);
          if Item = -1 then
            exit;
          if (lShift) and (MultiSelect) then
          begin
            MakeSelectedTo(Item);
            Invalidate;
          end
          else
            Selected := Item;
          AdjustScrollBar;
        end;
        result := 1;
      end;
    end;

    WM_KEYUP,
    WM_SYSKEYUP: begin
      if Count = 0 then
        exit;
      if lAlt  or lCtrl then
        exit;

      if (wParam = VK_APPS) or ((wParam = VK_F10) and lShift) then
      begin
        CheckBusy;
        if Selected = -1 then
        begin
          if Reversed then
            Selected := GetPrev(-1)
          else
            Selected := GetNext(-1);
        end;
{!!
        if Assigned(FOnPopup) then
          OnPopup(Self);
}
        result:=1;
      end;
    end;
  end;
end;
