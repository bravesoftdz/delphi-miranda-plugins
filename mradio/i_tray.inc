{}
{$IFDEF KOL_MCK}
function MakeStationsMenu:HMENU;
var
  hContact:Cardinal;
  sl:PWStrListEx;
  p:pWideChar;
  i:integer;
  flag:integer;
begin
  result:=CreatePopupMenu;
  if result<>0 then
  begin
    sl:=NewWStrListEx;
    hContact:=CallService(MS_DB_CONTACT_FINDFIRST,0,0);
    while hContact<>0 do
    begin
       if StrCmp(PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO,hContact,0)),cPluginName)=0 then
       begin
         p:=DBReadUnicode(hContact,strCList,'MyHandle',nil);
         if p<>nil then
         begin
           sl.AddObject(p,hContact);
           mFreeMem(p);
         end;
       end;
      hContact:=CallService(MS_DB_CONTACT_FINDNEXT,hContact,0);
    end;

    sl.Sort(false);
    for i:=0 to sl.Count-1 do
    begin
      if (i=0) or ((i mod 20)<>0) then
        flag:=MF_STRING
      else
        flag:=MF_STRING or MF_MENUBARBREAK;
      AppendMenuW(result,flag,sl.Objects[i],pWideChar(sl.Items[i]));
    end;
    sl.Clear;
    sl.Free;
  end;
end;
{$ELSE}
function MakeStationsMenu:HMENU;
var
  hContact:Cardinal;
  p:pWideChar;
  i:integer;
  flag:integer;
begin
  result:=CreatePopupMenu;
  if result<>0 then
  begin
    i:=0;
    hContact:=CallService(MS_DB_CONTACT_FINDFIRST,0,0);
    while hContact<>0 do
    begin
       if StrCmp(PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO,hContact,0)),cPluginName)=0 then
       begin
         p:=DBReadUnicode(hContact,strCList,'MyHandle',nil);
         if p<>nil then
         begin
           if (i=0) or ((i mod 20)<>0) then
             flag:=MF_STRING
           else
             flag:=MF_STRING or MF_MENUBARBREAK;
           AppendMenuW(result,flag,hContact,p);
           mFreeMem(p);
         end;
       end;
      hContact:=CallService(MS_DB_CONTACT_FINDNEXT,hContact,0);
      inc(i);
    end;
  end;
end;
{$ENDIF}

function CreateTrayMenu(wParam:WPARAM;lParam:LPARAM):int; cdecl;
const
  startid = 100;
var
  menu:HMENU;
  flag,id:integer;
  pt:TPOINT;
  playstr:pWideChar;
begin
  id:=0;
  menu:=CreatePopupMenu;
  if menu<>0 then
  begin
    if gVolume<0 then
      flag:=MF_STRING+MF_CHECKED
    else
      flag:=MF_STRING+MF_UNCHECKED;

    if CallService(MS_RADIO_COMMAND,MRC_STATUS,RD_STATUS_GET)<>RD_STATUS_PAUSED then
      playstr:='Pause'
    else
      playstr:='Play';

    AppendMenuW(menu,flag     ,startid+1,TranslateW('Mute'));
    AppendMenuW(menu,MF_STRING,startid+2,TranslateW(playstr));
    AppendMenuW(menu,MF_STRING,startid+3,TranslateW('Stop'));
    AppendMenuW(menu,MF_SEPARATOR,0,nil);
    AppendMenuW(menu,MF_POPUP,MakeStationsMenu,TranslateW('Play Station'));
    GetCursorPos(pt);
    id:=integer(TrackPopupMenu(menu,TPM_RETURNCMD+TPM_NONOTIFY,pt.x,pt.y,0,hiddenwindow,nil));
    case id of
      0: ; // nothing
      startid+1: begin // mute
        Service_RadioMute(0,0);
      end;
      startid+2: begin // play/pause
        CallService(MS_RADIO_COMMAND,MRC_PAUSE,0);
      end;
      startid+3: begin // stop
        CallService(MS_RADIO_COMMAND,MRC_STOP,0);
      end;
    else // choose station
      Service_RadioPlayStop(id,0);
    end;
    DestroyMenu(menu);
  end;
  result:=id;
end;

procedure CreateMIMTrayMenu;
var
  mi:TCListMenuItem;
begin
  if ServiceExists(MS_CLIST_ADDTRAYMENUITEM)<>0 then
//    if hiddenwindow<>0 then
    begin
      FillChar(mi, sizeof(mi), 0);
      mi.cbSize    :=sizeof(mi);
      mi.pszService:=MS_RADIO_TRAYMENU;
      mi.szName.a  :=cPluginName;
      mi.hIcon     :=CallService(MS_SKIN2_GETICON,0,lparam(IcoBtnSettings));
      Menu_AddTrayMenuItem(@mi);
    end;
end;

