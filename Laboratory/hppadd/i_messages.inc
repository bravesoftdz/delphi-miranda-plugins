{}
function THistoryGrid.OnGridTextMessage(Message:uint; wParam:WPARAM; lParam:LPARAM):LRESULT;
var
  len: integer;
begin
  result:=0;
  case Message of
    EM_GETSEL: begin 
      if wParam<>0 then PDword(wParam)^ := 0;
      if lParam<>0 then PDword(lParam)^ := StrLenW(SelectionString);
    end;
    EM_EXGETSEL: begin
      if lParam <> 0 then
      begin
        PCharRange(lParam)^.cpMin := 0;
        PCharRange(lParam)^.cpMax := StrLenW(SelectionString);
      end;
    end;
    WM_GETTEXT: begin
      len := Min(wParam - 1, StrLenW(SelectionString));
      if len >= 0 then
        StrCopyW(PWideChar(lParam), SelectionString, len);
      result:=len;
    end;
    WM_GETTEXTLENGTH: begin
      result:=StrLenW(SelectionString);
    end;
    WM_SETTEXT,
    EM_SETSEL,
    EM_EXSETSEL: begin
      FSelectionStored := False;
    end;
  end;
end;
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

    //----- Bottomless rich_edit resize message (for RichCache controls) -----
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
