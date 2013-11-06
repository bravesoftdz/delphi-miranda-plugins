{}
function ClientWndProc(Dialog: HWND; hMessage: UInt; wParam: WPARAM; lParam: LPARAM): lresult; stdcall;
var
  dc:HDC;
  ps:tPaintStruct;
  Grid:THistoryGrid;
begin
  result:=0;
  Grid:=THistoryGrid(GetWindowLongPtrW(Dialog,GWLP_USERDATA));

  case hMessage of
    WM_INITDIALOG: begin
    end;

    WM_COMMAND: begin
{
      case wParam shr 16 of
      end;
}
    end;

    WM_PAINT: begin
      dc := BeginPaint(Dialog, ps);
      result:=Grid.Paint(ps.rcPaint);
      BitBlt(dc,
          ps.rcPaint.Left,
          ps.rcPaint.Top,
          ps.rcPaint.Right  - ps.rcPaint.Left,
          ps.rcPaint.Bottom - ps.rcPaint.Top,
          Grid.FClientDC, ps.rcPaint.Left, ps.rcPaint.Top, SRCCOPY);
      EndPaint(Dialog, ps);
    end;

    WM_ERASEBKGND: begin
      result:=1;
    end;

    WM_GETDLGCODE: begin
      Result := DLGC_WANTALLKEYS or DLGC_HASSETSEL;
      if lParam <> 0 then
      begin
        if (pMsg(lParam).message = WM_KEYDOWN) or
           (pMsg(lParam).message = WM_CHAR) or
           (pMsg(lParam).message = WM_SYSCHAR) then
          if wParam = VK_TAB then
            Result := DLGC_WANTARROWS or DLGC_HASSETSEL;
      end;
    end;

    WM_KEYFIRST..WM_KEYLAST:
      result:=Grid.OnKeyMessage(hMessage,wParam,lParam);

    WM_MOUSEFIRST..WM_MOUSELAST:
      Grid.OnMouseMessage(hMessage,wParam,lParam);

    WM_HELP: begin
      result:=1;
    end;

    WM_NOTIFY: begin
      if Grid.OnGridNotify(lParam) then
        result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
    end;

  else
    result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;
