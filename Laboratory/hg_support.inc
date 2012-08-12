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
