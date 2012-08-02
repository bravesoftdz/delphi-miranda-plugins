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
