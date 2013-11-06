{}
{
function THistoryGrid.OnGridMessage(lParam:LPARAM):boolean;
begin
end;
}
type
  PReqSize = ^TReqSize;
  TReqSize = record
    nmhdr: TNMHdr;
    rc: TRect;
  end;

function THistoryGrid.OnGridNotify(lParam:LPARAM):boolean;
var
  nmh: PFVCNDATA_NMHDR;
  RichItem: PRichItem;
  ClipRect, reRect, smRect: TRect;
begin
  result:=false;

  case integer(PNMHdr(lParam)^.code) of

    //----- Cursor form changing -----
    WM_SETCURSOR: begin
      if State <> gsIdle then
        exit;
      if LoWord(lParam) = word(HTERROR) then
        exit;
{
      NewCursor := crDefault;

GetCursorPos(pt);
ptScreen2Client(pt);

Msg.pt
      P := ScreenToClient(Mouse.CursorPos);
      HintHitTests := GetHitTests(P.X, P.Y);

      if HintHitTests * [ghtButton, ghtLink] <> [] then
        NewCursor := crHandPoint;

      if Windows.GetCursor <> NewCursor then
      begin
        Windows.SetCursor(NewCursor);
        Rslt := 1;
      end
      else
        Rslt := 0;
}
    end;

    //----- Bottomless richedit resize message (for RichCache controls) -----
    EN_REQUESTRESIZE: begin
      FRichCache.ResizeRequest(pReqSize(lParam)^.rc);
    end;

    //----- SmileyAdd smiley animation messages -----
    NM_FIREVIEWCHANGE: begin
{
      if PNMHdr(lParam)^.hwndFrom = FRichInline.Handle then
        exit;
}
      nmh := PFVCNDATA_NMHDR(lParam);
      if (nmh.bEvent = FVCN_PREFIRE) and (nmh.bAction = FVCA_DRAW) then
      begin
        RichItem := FRichCache.GetItemByHandle(nmh.hwndFrom);
        nmh.bAction := FVCA_NONE;
        if Assigned(RichItem) then
        begin
          if RichItem.GridItem = -1 then
            exit;
          if not RichItem.BitmapDrawn then
            exit;
          if (LockCount > 0) {or (RichItem.GridItem = FItemInline)} or
            (not IsVisible(RichItem^.GridItem)) then
          begin
            RichItem.BitmapDrawn := False;
            exit;
          end;
          nmh.bAction := FVCA_SKIPDRAW;
          if (State = gsIdle) or (State = gsInline) then
          begin
            reRect := GetRichEditRect(RichItem.GridItem, True);
            smRect := nmh.rcRect;
            OffsetRect(smRect, reRect.Left, reRect.Top);
            GetClipBox(FClientDC, ClipRect);
            if IntersectRect(smRect, ClipRect) then
            begin
              nmh.bAction       := FVCA_CUSTOMDRAW;
              nmh.HDC           := RichItem.Bitmap.DC;
              nmh.clrBackground := RichItem.Bitmap.Color;
              nmh.fTransparent  := False;
              nmh.lParam        := FRichCache.LockItem(RichItem, smRect);
            end;
          end;
        end;
      end
      else if (nmh.bEvent = FVCN_POSTFIRE) and (nmh.bAction = FVCA_CUSTOMDRAW) then
      begin
        smRect := FRichCache.UnlockItem(nmh.lParam);
        GetClipBox(FClientDC, ClipRect);
        IntersectRect(smRect, smRect, ClipRect);
        if not IsRectEmpty(smRect) then
          InvalidateRect(FClient, @smRect, False);
      end
    end;
  else
    result:=true;
  end;
end;
