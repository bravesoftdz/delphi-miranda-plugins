{}
function THistoryGrid.GetRichEditRect(Item: Integer; DontClipTop: Boolean): TRect;
var
  res: TRect;
  hh: Integer;
begin
  SetRect(Result, 0, 0, 0, 0);
  if Item = -1 then
    exit;
  Result := GetItemRect(Item);
  Inc(Result.Left, Padding);
  Dec(Result.Right, Padding);
  /// avatars!.!
  // Dec(Result.Right,64+Padding);
  if FGroupLinked and FItems[Item].LinkedToPrev then
    hh := 0
  else if mtIncoming in FItems[Item].MessageType then
    hh := CHeaderHeight
  else
    hh := PHeaderheight;
  Inc(Result.Top, hh + Padding);
  Dec(Result.Bottom, Padding + 1);
  if (Items[Item].HasHeader) and (ShowHeaders) and (ExpandHeaders) then
  begin
    if Reversed xor ReversedHeader then
      Inc(Result.Top, SessHeaderHeight)
    else
      Dec(Result.Bottom, SessHeaderHeight);
  end;
  res := FClient.ClientRect;

  if DontClipTop and (Result.Top < res.Top) then
    res.Top := Result.Top;
  IntersectRect(Result, res, Result);
end;

function THistoryGrid.IsLinkAtPoint(RichEditRect: TRect; X, Y, Item: Integer): Boolean;
var
  P: TPoint;
  cr: CHARRANGE;
  cf: CharFormat2;
  cp: Integer;
  res: DWord;
begin
  Result := False;
  P := MakePoint(X - RichEditRect.Left, Y - RichEditRect.Top);
  ApplyItemToRich(Item);

  cp := SendMessage(FRich.Handle, EM_CHARFROMPOS, 0, lParam(@P));
  if cp = -1 then
    exit; // out of richedit area
  cr.cpMin := cp;
  cr.cpMax := cp + 1;
  SendMessage(FRich.Handle, EM_EXSETSEL, 0, lParam(@cr));

  ZeroMemory(@cf, SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  cf.dwMask := CFM_LINK or CFM_REVISED;
  res := SendMessage(FRich.Handle, EM_GETCHARFORMAT, SCF_SELECTION, lParam(@cf));
  // no link under point
  Result := (((res and CFM_LINK) > 0) and ((cf.dwEffects and CFE_LINK) > 0)) or
            (((res and CFM_REVISED) > 0) and ((cf.dwEffects and CFE_REVISED) > 0));
end;

// Call this function to get the link url at given point in grid
// Call it when you are sure that the point has a link,
// if no link at a point, the result is ''
// To know if there's a link, use GetHitTests and look for ghtLink
function THistoryGrid.GetLinkAtPoint(X, Y: Integer): AnsiString;
var
  cr: CHARRANGE;
  cf: CharFormat2;
  res: DWord;
  RichEditRect: TRect;
  Max, Item: Integer;
begin
  Result := '';
  Item := FindItemAt(X, Y);
  if Item = -1 then
    exit;
  RichEditRect := GetRichEditRect(Item, True);

  if not IsLinkAtPoint(RichEditRect, X, Y, Item) then exit;

  while cr.cpMin > 0 do
  begin
    Dec(cr.cpMin);
    SendMessage(FRich.Handle, EM_EXSETSEL, 0, lParam(@cr));
    cf.cbSize := SizeOf(cf);
    cf.dwMask := CFM_LINK or CFM_REVISED;
    res := SendMessage(FRich.Handle, EM_GETCHARFORMAT, SCF_SELECTION, lParam(@cf));
    if (((res and CFM_LINK) = 0) or ((cf.dwEffects and CFE_LINK) = 0)) and
      (((res and CFM_REVISED) = 0) or ((cf.dwEffects and CFE_REVISED) = 0)) then
    begin
      Inc(cr.cpMin);
      break;
    end;
  end;

  Max := GetTextLength(FRich.Handle);
  while cr.cpMax < Max do
  begin
    Inc(cr.cpMax);
    SendMessage(FRich.Handle, EM_EXSETSEL, 0, lParam(@cr));
    cf.cbSize := SizeOf(cf);
    cf.dwMask := CFM_LINK or CFM_REVISED;
    res := SendMessage(FRich.Handle, EM_GETCHARFORMAT, SCF_SELECTION, lParam(@cf));
    if (((res and CFM_LINK) = 0) or ((cf.dwEffects and CFE_LINK) = 0)) and
      (((res and CFM_REVISED) = 0) or ((cf.dwEffects and CFE_REVISED) = 0)) then
    begin
      Dec(cr.cpMax);
      break;
    end;
  end;

  Result := GetTextRange(FRich.Handle, cr.cpMin, cr.cpMax);

  if (Length(Result) > 10) and (Pos('HYPERLINK', Result) = 1) then
  begin
//!!    cr.cpMin := PosEx('"', Result, 10);
    if cr.cpMin > 0 then
      Inc(cr.cpMin)
    else
      exit;
//!!    cr.cpMax := PosEx('"', Result, cr.cpMin);
    if cr.cpMin = 0 then
      exit;
    Result := Copy(Result, cr.cpMin, cr.cpMax - cr.cpMin);
  end;

end;
