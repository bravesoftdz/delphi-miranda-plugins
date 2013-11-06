{}
function GridWndProc(Dialog: HWND; hMessage: UInt; wParam: WPARAM; lParam: LPARAM): lresult; stdcall;
var
  Grid:THistoryGrid;
begin
  result:=0;
  Grid:=THistoryGrid(GetWindowLongPtrW(Dialog,GWLP_USERDATA));

  case hMessage of
    WM_INITDIALOG: begin
    end;

    WM_SIZE: begin
      Grid.GridUpdate([guSize]);
    end;

    WM_COMMAND: begin
{
      case wParam shr 16 of
      end;
}
    end;
{
    WM_MOUSEFIRST..WM_MOUSELAST:
      Grid.OnMouseMessage(hMessage,wParam,lParam);
}
    // not called :(
    WM_MOUSEWHEEL:
      Grid.OnGridMouseWheel(SmallInt(Hiword(wParam)));

    WM_VSCROLL: begin
      if lParam<>0 then
        Grid.OnGridScroll(wParam);
    end;

    WM_HELP: begin
      result:=1;
    end;

  else
    result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;
