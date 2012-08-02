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
        EN_REQUESTRESIZE: begin
          FRichCache.ResizeRequest(pReqSize(Msg.lParam)^.rc);
        end;

        NM_FIREVIEWCHANGE: begin
result:=true;
OutputDebugString('ONGRID');
{
          if PNMHdr(Msg.lParam)^.hwndFrom = FRichInline.Handle then
            exit;
}
//messagebox(0,'Grid','',0);
          nmh := PFVCNDATA_NMHDR(PNMHdr(Msg.lParam));
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
                  nmh.HDC           := RichItem.Bitmap.Canvas.Handle;
//                  nmh.clrBackground := RichItem.Bitmap.TransparentColor;
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

function THistoryGrid.OnHGridMessage(var Msg:TMsg; var Rslt:Integer):Boolean;
var
  nmh: PFVCNDATA_NMHDR;
  RichItem: PRichItem;
  reRect, smRect: TRect;
begin
  Result := false;
  case Msg.message of
    WM_NOTIFY: begin
      case integer(PNMHdr(Msg.lParam)^.code) of
        NM_FIREVIEWCHANGE: begin
OutputDebugString('HGD|RID');
{
          if PNMHdr(Msg.lParam)^.hwndFrom = FRichInline.Handle then
            exit;
}
          nmh := PFVCNDATA_NMHDR(PNMHdr(Msg.lParam));
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
                  nmh.HDC           := RichItem.Bitmap.Canvas.Handle;
//                  nmh.clrBackground := RichItem.Bitmap.TransparentColor;
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

procedure THistoryGrid.OnGridMouseWheel(Sender:PControl; var Mouse:TMouseEventData);
var
  Lines, code: Integer;
  FWheelCurrTick: Cardinal;
begin
  if State = gsInline then
  begin
//!!    with TMessage(Message) do FRichInline.Perform(WM_MOUSEWHEEL, wParam, lParam);
    exit;
  end;

  if (Cardinal(Mouse.Shift) = WHEEL_PAGESCROLL) then
  begin
    Lines := 1;
    if SmallInt(HiWord(Mouse.Shift)) < 0 then
      code := SB_PAGEDOWN
    else
      code := SB_PAGEUP;
  end
  else
  begin
    Lines := ABS(SmallInt(HiWord(Mouse.Shift)) div WHEEL_DELTA);
    if SmallInt(HiWord(Mouse.Shift)) < 0 then
      code := SB_LINEDOWN
    else
      code := SB_LINEUP;
  end;

  // some kind of acceleraion. mb the right place is in WM_VSCROLL?
  FWheelCurrTick := GetTickCount;
  if FWheelCurrTick - FWheelLastTick < 10 then
  begin
    Lines := Lines shl 1;
  end;
  FWheelLastTick := FWheelCurrTick;

  FWheelAccumulator := FWheelAccumulator + SmallInt(HiWord(Mouse.Shift)) * Lines;
  while Abs(FWheelAccumulator) >= WHEEL_DELTA do
  begin
    FWheelAccumulator := Abs(FWheelAccumulator) - WHEEL_DELTA;
    PostMessage(Sender.Handle, WM_VSCROLL, code, FVertScrollBar.Handle);
  end;
end;

