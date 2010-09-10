{IcoLib code}

function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=0;
  if FrameId<>0 then
  begin
    ShowWindow(FrameWnd,SW_HIDE);
    ShowWindow(FrameWnd,SW_SHOW);
  end;
end;
