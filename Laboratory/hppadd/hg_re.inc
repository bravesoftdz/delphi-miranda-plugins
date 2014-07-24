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
  Inc(Result.Left , Padding);
  Dec(Result.Right, Padding);
  /// avatars!.!
  // Dec(Result.Right,64+Padding);
  if FGroupLinked and FItems[Item].LinkedToPrev then
    hh := 0
  else if IsIncomingEvent(FItems[Item]) then
    hh := CHeaderHeight
  else
    hh := PHeaderheight;
  Inc(Result.Top   , hh + Padding);
  Dec(Result.Bottom, Padding + 1);
  if (Items[Item].HasHeader) and (ShowHeaders) and (ExpandHeaders) then
  begin
    if Reversed xor ReversedHeader then
      Inc(Result.Top   , SessHeaderHeight)
    else
      Dec(Result.Bottom, SessHeaderHeight);
  end;
  res := FClientRect;

  if DontClipTop and (Result.Top < res.Top) then
    res.Top := Result.Top;
  IntersectRect(Result, res, Result);
end;

function THistoryGrid.IsLinkAtPoint(RichEditRect: TRect; X, Y, Item: Integer): Boolean;
var
  FRich: PHPPRichEdit;
  P: TPoint;
  cr: CHARRANGE;
  cf: CharFormat2;
  cp: Integer;
  res: DWord;
begin
  Result := False;
  Point(P, X - RichEditRect.Left, Y - RichEditRect.Top);
  FRich := GetRichFromCache(Item);

  cp := SendMessage(FRich.Handle, EM_CHARFROMPOS, 0, lParam(@P));
  if cp = -1 then
    exit; // out of rich_edit area
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
function THistoryGrid.GetLinkAtPoint(X, Y: Integer): PWideChar;
var
  FRich: PHPPRichEdit;
  pc,pc1:pWideChar;
  cr: CHARRANGE;
  cf: CharFormat2;
  RichEditRect: TRect;
  P: TPoint;
  cp, Max, Item: Integer;
  res: DWord;
begin
  Result := nil;
  Item := FindItemAt(X, Y);
  if Item = -1 then
    exit;
  RichEditRect := GetRichEditRect(Item, True);

  if not IsLinkAtPoint(RichEditRect, X, Y, Item) then exit;

  FRich := GetRichFromCache(Item);
{}
  Point(P, X - RichEditRect.Left, Y - RichEditRect.Top);
  cp := SendMessage(FRich.Handle, EM_CHARFROMPOS, 0, lParam(@P));
  cr.cpMin := cp;
  cr.cpMax := cp + 1;
{}
{!old
  cp := FRich.Perform(EM_CHARFROMPOS, 0, lParam(@P));
  if cp = -1 then
    exit; // out of rich_edit area
  cr.cpMin := cp;
  cr.cpMax := cp + 1;
  FRich.Perform(EM_EXSETSEL, 0, lParam(@cr));

  ZeroMemory(@cf, SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  cf.dwMask := CFM_LINK or CFM_REVISED;
  res := FRich.Perform(EM_GETCHARFORMAT, SCF_SELECTION, lParam(@cf));
  // no link under point
  if (((res and CFM_LINK) = 0) or ((cf.dwEffects and CFE_LINK) = 0)) and
    (((res and CFM_REVISED) = 0) or ((cf.dwEffects and CFE_REVISED) = 0)) then
    exit;
}
  while cr.cpMin > 0 do
  begin
    Dec(cr.cpMin);
    SendMessage(FRich.Handle, EM_EXSETSEL, 0, lParam(@cr));
    cf.cbSize := SizeOf(cf);
    cf.dwMask := CFM_LINK or CFM_REVISED;
    res := SendMessage(FRich.Handle, EM_GETCHARFORMAT, SCF_SELECTION, lParam(@cf));
    if (((res and CFM_LINK   ) = 0) or ((cf.dwEffects and CFE_LINK   ) = 0)) and
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
    if (((res and CFM_LINK   ) = 0) or ((cf.dwEffects and CFE_LINK   ) = 0)) and
       (((res and CFM_REVISED) = 0) or ((cf.dwEffects and CFE_REVISED) = 0)) then
    begin
      Dec(cr.cpMax);
      break;
    end;
  end;

  Result := GetTextRange(FRich.Handle, cr.cpMin, cr.cpMax);

  if (StrLenW(Result) > 10) and (StrPosW(Result, 'HYPERLINK') = Result) then
  begin
    pc:=StrPosW(Result+10,'"');
    if pc<>nil then
    begin
      inc(pc);
      pc1:=StrPosW(pc,'"');
      if pc1<>nil then
        StrCopyW(Result,pc,pc1-pc);
    end;
  end;
end;
