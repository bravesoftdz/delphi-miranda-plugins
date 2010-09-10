unit WATIcons;
interface

uses wat_api;

{$resource icons\waticons.res}
{$include icons\waticons.inc}

procedure RegisterButtonIcons;

const
  ICOCtrlName = 'watrack_buttons.dll';

var
  CtrlsLoaded:boolean;

const
  // numbers
  NumIcons    = 8;
  NumButtons  = NumIcons-1;
  NumCtrls    = 5;
  NumIconsExt = NumButtons*3+1;
  BtnHovered  = NumCtrls;
  BtnPushed   = BtnHovered+NumCtrls;

  bstNormal  = 0;
  bstHovered = 1;
  bstPressed = 2;

const
  CtrlButtons:array [0..6] of byte=(
    WAT_CTRL_PREV, WAT_CTRL_PLAY, WAT_CTRL_PAUSE, WAT_CTRL_STOP,
    WAT_CTRL_NEXT, WAT_CTRL_VOLDN,WAT_CTRL_VOLUP);
  CtrlRemap:array [1..NumIcons] of integer = (1,2,3,4,5,16,17,20);
  // Description
  CtrlDescr:array [1..NumIconsExt] of PAnsiChar=(
    'Prev'        ,'Play'        ,'Pause'        ,'Stop'        ,'Next',
    'Prev Hovered','Play Hovered','Pause Hovered','Stop Hovered','Next Hovered',
    'Prev Pushed' ,'Play Pushed' ,'Pause Pushed' ,'Stop Pushed' ,'Next Pushed',
    'Volume Down'        ,'Volume Up',
    'Volume Down Hovered','Volume Up Hovered','Slider',
    'Volume Down Pushed' ,'Volume Up Pushed');
  // IcoLib names
  CtrlIcoNames:array [1..NumIconsExt] of PAnsiChar=(
    'WATrack_Prev' ,'WATrack_Play' ,'WATrack_Pause' ,'WATrack_Stop' ,'WATrack_Next',
    'WATrack_PrevH','WATrack_PlayH','WATrack_PauseH','WATrack_StopH','WATrack_NextH',
    'WATrack_PrevP','WATrack_PlayP','WATrack_PauseP','WATrack_StopP','WATrack_NextP',
    'WATrack_VolDn' ,'WATrack_VolUp',
    'WATrack_VolDnH','WATrack_VolUpH','WATrack_Slider',
    'WATrack_VolDnP','WATrack_VolUpP');

implementation

uses m_api,windows,mirutils;

const
  ButtonsLoaded:bool = false;

procedure RegisterButtonIcons;
var
  sid:TSKINICONDESC;
  buf,buf1:array [0..511] of AnsiChar;
  hIconDLL:THANDLE;
  i:integer;
begin
  if ButtonsLoaded then exit;
  sid.flags:=0;
  sid.cbSize:=SizeOf(TSKINICONDESC);
  sid.cx:=16;
  sid.cy:=16;

  CtrlsLoaded:=false;
  sid.szSection.a     :='WATrack/Frame Controls';
  sid.pszDefaultFile.a:='icons\'+ICOCtrlName;
  ConvertFileName(sid.pszDefaultFile.a,buf);
//  PluginLink^.CallService(MS_UTILS_PATHTOABSOLUTE,dword(sid.pszDefaultFile),dword(@buf));

  hIconDLL:=LoadLibraryA(buf);
  if hIconDLL=0 then // not found
  begin
    sid.pszDefaultFile.a:='plugins\'+ICOCtrlName;
    ConvertFileName(sid.pszDefaultFile.a,buf);
//    PluginLink^.CallService(MS_UTILS_PATHTOABSOLUTE,dword(sid.pszDefaultFile),dword(@buf));
    hIconDLL:=LoadLibraryA(buf);
  end;

  if hIconDLL<>0 then
  begin
    for i:=1 to NumIconsExt do
    begin
      sid.iDefaultIndex  :=i;
      sid.hDefaultIcon   :=LoadImage(hIconDLL,MAKEINTRESOURCE(i),IMAGE_ICON,16,16,0);
      sid.pszName        :=CtrlIcoNames[i];
      sid.szDescription.a:=CtrlDescr[i];
      PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
      DestroyIcon(sid.hDefaultIcon);
    end;
  end
  else
  begin
    GetModuleFileNameA(0,buf,SizeOf(buf));
    PluginLink^.CallService(MS_UTILS_PATHTORELATIVE,dword(@buf),dword(@buf1));
    sid.pszDefaultFile.a:=buf1;
    for i:=1 to NumIcons do
    begin
      sid.iDefaultIndex  :=i;
      sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(i),IMAGE_ICON,16,16,0);
      sid.pszName        :=CtrlIcoNames[CtrlRemap[i]];
      sid.szDescription.a:=CtrlDescr[CtrlRemap[i]];
      PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
      DestroyIcon(sid.hDefaultIcon);
    end;

  end;
  if hIconDLL<>0 then
  begin
    CtrlsLoaded:=true;
    FreeLibrary(hIconDLL);
  end;
  ButtonsLoaded:=true;
end;

end.
