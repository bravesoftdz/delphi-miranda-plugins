{}
procedure THistoryGrid.CheckBusy;
begin
  if State = gsInline then
//!!    CancelInline;
{
  if State <> gsIdle then
    raise EAbort.Create('Grid is busy');
}
end;

function THistoryGrid.GetGMessage(idx:integer):pWideChar;
begin
  result:=FMessages[idx];
end;

procedure THistoryGrid.SetGMessage(idx:integer;value:pWideChar);
begin
  if StrCmpW(value,FMessages[idx])<>0 then
  begin
    mFreeMem(FMessages[idx]);
    StrDupW (FMessages[idx],value);
  end;
end;

procedure THistoryGrid.Update;
begin
  UpdateWindow(FHandle);
end;

procedure THistoryGrid.Invalidate;
begin
  InvalidateRect(FHandle, nil, true);
end;

//-----  -----

procedure THistoryGrid.OnSpeakMessage(item:integer=-1);
var
  mesW: PWideChar;
  hContact: TMCONTACT;
begin
  if ServiceExists(MS_SPEAK_MESSAGE)=0 then
    exit;
  // if Items[Grid.Selected].Custom then exit;
{}
  if item = -1 then
  begin
    if Selected = -1 then
      exit;
    item:=Selected;
  end;
{}
  hContact := 0;
//  hContact := Items[item].hContact;
  mesW     := Items[item].Text;
//  if GridOptions.BBCodesEnabled then
    mesW := DoStripBBCodes(mesW);

  CallService(MS_SPEAK_MESSAGE, hContact, LPARAM(mesW));

  mFreeMem(mesW);
end;
