{}
procedure THistoryGrid.OnGridResize(Sender:PObj);
begin
  BeginUpdate;
  GridUpdate([guSize]);
  EndUpdate;
end;

type
  PReqSize = ^TReqSize;
  TReqSize = record
    nmhdr: TNMHdr;
    rc: TRect;
  end;

function THistoryGrid.OnGridMessage(var Msg:TMsg; var Rslt:Integer):Boolean;
var
  nmh: PFVCNDATA_NMHDR;
  RichItem: PRichItem;
  reRect, smRect: TRect;
begin
  Result := false;
  case Msg.message of
    WM_NOTIFY: begin
      case integer(PNMHdr(Msg.lParam)^.code) of

        //----- Cursor form changing -----
        WM_SETCURSOR: begin
          if State <> gsIdle then
            exit;
          if LoWord(Msg.lParam) = word(HTERROR) then
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
          FRichCache.ResizeRequest(pReqSize(Msg.lParam)^.rc);
        end;

        //----- SmileyAdd smiley animation messages -----
        NM_FIREVIEWCHANGE: begin
{
          if PNMHdr(Msg.lParam)^.hwndFrom = FRichInline.Handle then
            exit;
}
          nmh := PFVCNDATA_NMHDR(Msg.lParam);
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
                if DoRectsIntersect(smRect, FClient.Canvas.ClipRect) then
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
            IntersectRect(smRect, smRect, FClient.Canvas.ClipRect);
            if not IsRectEmpty(smRect) then
              InvalidateRect(FClient.Handle, @smRect, False);
          end
{
          else if (nmh.bEvent = FVCN_GETINFO) and (nmh.bAction = FVCA_NONE) then
          begin
            RichItem := FRichCache.GetItemByHandle(nmh.hwndFrom);
            if not Assigned(RichItem) then
              exit;
            if (RichItem.GridItem = -1) or (RichItem.GridItem = FItemInline) then
              exit;
            if not RichItem.BitmapDrawn then
              exit;
            // if (State = gsIdle) or (State = gsInline) then
            nmh.bAction       := FVCA_INFO;
            nmh.rcRect        := GetRichEditRect(RichItem.GridItem, True);
//            nmh.clrBackground := RichItem.Bitmap.TransparentColor;
            nmh.fTransparent  := False;
          end;
}
        end;
  
      end;
    end;
  end;
end;
