{main hotkey code}
function InsertProc(wParam:WPARAM;lParam:LPARAM):int; cdecl;
var
  CurWin:HWND;
  s:pWideChar;
  p:PAnsiChar;
  IsUnicode:boolean;
  i:integer;
  j:integer;
  tt:tTemplateType;
begin
  result:=0;
  if DisablePlugin=dsPermanent then
    exit;
//  i:=CallService(MS_WAT_GETMUSICINFO,0,0);
  if UseMessages=BST_CHECKED then
  begin
    Curwin:=GetFocus;
    if CurWin<>0 then
    begin
//      j:=WndToContact(WaitFocusedWndChild(GetForegroundwindow){GetFocus});
      j:=WndToContact(CurWin);
      p:=GetContactProtoAcc(j);
//      p:=PAnsiChar(PluginLink^.CallService(MS_PROTO_GETCONTACTBASEPROTO,j,0));
      if DBReadByte(j,p,'ChatRoom',0)=1 then
      begin
        isUnicode:=false;
        tt:=tmpl_chat;
      end
      else
      begin
        isUnicode:=true;
        tt:=tmpl_pm;
      end;
      if SimpleMode<>BST_UNCHECKED then
        i:=0
      else
        i:=FindProto(p);
      s:=GetMacros(tt,i,LastStatus);
      if (s<>nil) and (uint_ptr(s)<>uint_ptr(-2)) then
      begin
        if StrScanW(s,'{')<>nil then
          SendRTF(CurWin,s,isUnicode,UserCP)
        else
        begin
          if IsUnicode then
            SendMessageW(CurWin,EM_REPLACESEL,0,tlparam(s))
          else
          begin
            SendMessageA(CurWin,EM_REPLACESEL,0,tlparam(WideToANSI(s,p,UserCP)));
            mFreeMem(p);
          end;
        end;
        mFreeMem(s);
      end;
      result:=1;
    end;
  end;
end;
