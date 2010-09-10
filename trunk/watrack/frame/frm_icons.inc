{IcoLib code}
function GetIcon(num:integer):HICON;
var
  stat:integer;
begin
  if CtrlsLoaded then
  begin
     if (CtrlPushed and (1 shl num))<>0 then
       stat:=bstPressed
     else if (CtrlHovered and (1 shl num))<>0 then
       stat:=bstHovered
     else
       stat:=bstNormal;

    if num=BTN_SLIDER then
    begin
{
      if stat=bstPressed then
        num:=2//CtrlRemap[num]+2
      else if stat=bstHovered then
        num:=1//CtrlRemap[num]+1
      else
}
        num:=CtrlRemap[num];
    end
    else
      case stat of
        bstNormal: num:=CtrlRemap[num];
        bstPressed: begin
          if (num=WAT_CTRL_VOLDN) or (num=WAT_CTRL_VOLUP) then
            num:=CtrlRemap[num]+5
          else
            num:=CtrlRemap[num]+BtnPushed
        end;
        bstHovered: begin
          if (num=WAT_CTRL_VOLDN) or (num=WAT_CTRL_VOLUP) then
            num:=CtrlRemap[num]+2
          else
            num:=CtrlRemap[num]+BtnHovered;
        end;
      end;
    result:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(CtrlIcoNames[num]))
  end
  else
    result:=PluginLink^.CallService(MS_SKIN2_GETICON,0,
      dword(CtrlIcoNames[CtrlRemap[num]]))
end;

function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=0;
  if FrameId<>0 then
  begin
    ShowWindow(FrameWnd,SW_HIDE);
    ShowWindow(FrameWnd,SW_SHOW);
  end;
end;
