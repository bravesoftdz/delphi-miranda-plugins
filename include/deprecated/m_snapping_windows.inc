{$IFNDEF SNAPPING_WINDOWS}
{$DEFINE SNAPPING_WINDOWS}

type
  PSnapWindowProc = ^TSnapWindowProc;
  TSnapWindowProc = record
    hWnd           : HWND;
    m_szMoveOffset : TSIZE;
    wParam         : WPARAM;
    lParam         : LPARAM;
    Reserved1      : int;
    Reserved2      : int;
    Reserved3      : int;
  end;

const
  MS_SNAPWINDOWPROC:PAnsiChar = 'Utils/SnapWindowProc';

{
function CallSnappingWindowProc(hwnd:HWND; nMessage:uint;
    wParam:WPARAM;lParam:LPARAM):LRESULT; stdcall;
const
  SnapInfo:TSnapWindowProc=();
begin
  result:=0;
  if (nMessage=WM_MOVING) or (nMessage=WM_NCLBUTTONDOWN) or
     (nMessage=WM_SYSCOMMAND) or (nMessage=WM_SIZING) then
  begin
    SnapInfo.hWnd   := hwnd;
    SnapInfo.wParam := wParam;
    SnapInfo.lParam := lParam;
    CallService(MS_SNAPWINDOWPROC,WPARAM(@SnapInfo),nMessage);
    if nMessage=WM_SIZING then result:=1;
  end;
end;
}

{$ENDIF}
