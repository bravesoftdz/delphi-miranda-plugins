unit WATIcons;
interface

uses wat_api;

{$resource icons\waticons.res}

procedure RegisterButtonIcons;
function GetIcon(action:integer;stat:integer):cardinal;
function GetIconDescr(action:integer):pAnsiChar;

const
  AST_NORMAL  = 0;
  AST_HOVERED = 1;
  AST_PRESSED = 2;

implementation

uses m_api,windows,mirutils;

{$include icons\waticons.inc}

const
  ICOCtrlName = 'watrack_buttons.dll';

const
  CtrlsLoaded  :bool = false; // custom DLL loaded
  ButtonsLoaded:bool = false;

const
  CtrlIcoLib:array [WAT_CTRL_FIRST..WAT_CTRL_LAST,AST_NORMAL..AST_PRESSED] of
    record descr,name:PAnsiChar; id:integer end = (
    ((descr:'Prev'               ;name:'WATrack_Prev'   ; id:IDI_PREV_NORMAL),
     (descr:'Prev Hovered'       ;name:'WATrack_PrevH'  ; id:IDI_PREV_HOVERED),
     (descr:'Prev Pushed'        ;name:'WATrack_PrevP'  ; id:IDI_PREV_PRESSED)),

    ((descr:'Play'               ;name:'WATrack_Play'   ; id:IDI_PLAY_NORMAL),
     (descr:'Play Hovered'       ;name:'WATrack_PlayH'  ; id:IDI_PLAY_HOVERED),
     (descr:'Play Pushed'        ;name:'WATrack_PlayP'  ; id:IDI_PLAY_PRESSED)),
    
    ((descr:'Pause'              ;name:'WATrack_Pause'  ; id:IDI_PAUSE_NORMAL),
     (descr:'Pause Hovered'      ;name:'WATrack_PauseH' ; id:IDI_PAUSE_HOVERED),
     (descr:'Pause Pushed'       ;name:'WATrack_PauseP' ; id:IDI_PAUSE_PRESSED)),

    ((descr:'Stop'               ;name:'WATrack_Stop'   ; id:IDI_STOP_NORMAL),
     (descr:'Stop Hovered'       ;name:'WATrack_StopH'  ; id:IDI_STOP_HOVERED),
     (descr:'Stop Pushed'        ;name:'WATrack_StopP'  ; id:IDI_STOP_PRESSED)),

    ((descr:'Next'               ;name:'WATrack_Next'   ; id:IDI_NEXT_NORMAL),
     (descr:'Next Hovered'       ;name:'WATrack_NextH'  ; id:IDI_NEXT_HOVERED),
     (descr:'Next Pushed'        ;name:'WATrack_NextP'  ; id:IDI_NEXT_PRESSED)),

    ((descr:'Volume Down'        ;name:'WATrack_VolDn'  ; id:IDI_VOLDN_NORMAL),
     (descr:'Volume Down Hovered';name:'WATrack_VolDnH' ; id:IDI_VOLDN_HOVERED),
     (descr:'Volume Down Pushed' ;name:'WATrack_VolDnP' ; id:IDI_VOLDN_PRESSED)),

    ((descr:'Volume Up'          ;name:'WATrack_VolUp'  ; id:IDI_VOLUP_NORMAL),
     (descr:'Volume Up Hovered'  ;name:'WATrack_VolUpH' ; id:IDI_VOLUP_HOVERED),
     (descr:'Volume Up Pushed'   ;name:'WATrack_VolUpP' ; id:IDI_VOLUP_PRESSED)),

    ((descr:'Slider'             ;name:'WATrack_Slider' ; id:IDI_SLIDER_NORMAL),
     (descr:'Slider Hovered'     ;name:'WATrack_SliderH'; id:IDI_SLIDER_HOVERED),
     (descr:'Slider Pushed'      ;name:'WATrack_SliderP'; id:IDI_SLIDER_PRESSED))
    );
{  
type
  CtrlButtons=(
      WAT_CTRL_PREV, WAT_CTRL_PLAY,  WAT_CTRL_PAUSE, WAT_CTRL_STOP,
      WAT_CTRL_NEXT, WAT_CTRL_VOLDN, WAT_CTRL_VOLUP, WAT_CTRL_SLIDER);
}
procedure RegisterButtonIcons;
var
  sid:TSKINICONDESC;
  buf,buf1:array [0..511] of AnsiChar;
  hIconDLL:THANDLE;
  i,j:integer;
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
    for i:=WAT_CTRL_FIRST to WAT_CTRL_LAST do
      for j:=AST_NORMAL to AST_PRESSED do
      begin
        sid.hDefaultIcon   :=LoadImage(hIconDLL,
            MAKEINTRESOURCE(CtrlIcoLib[i][j].id),IMAGE_ICON,16,16,0);
        if sid.hDefaultIcon=0 then continue;

        sid.iDefaultIndex  :=CtrlIcoLib[i][j].id;
        sid.pszName        :=CtrlIcoLib[i][j].name; 
        sid.szDescription.a:=CtrlIcoLib[i][j].descr;

        PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
        DestroyIcon(sid.hDefaultIcon);
      end;
  end
  else
  begin
    GetModuleFileNameA(0,buf,SizeOf(buf));
    PluginLink^.CallService(MS_UTILS_PATHTORELATIVE,dword(@buf),dword(@buf1));
    sid.pszDefaultFile.a:=buf1;
    for i:=WAT_CTRL_FIRST to WAT_CTRL_LAST do
    begin
      with CtrlIcoLib[i,AST_NORMAL] do
      begin
        sid.iDefaultIndex  :=id;
        sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(id),IMAGE_ICON,16,16,0);
        sid.pszName        :=name;
        sid.szDescription.a:=descr;
      end;
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

function GetIcon(action:integer;stat:integer):cardinal;
begin
  result:=PluginLink^.CallService(MS_SKIN2_GETICON,0,
      dword(CtrlIcoLib[action][stat].name));
end;

function GetIconDescr(action:integer):pAnsiChar;
begin
  result:=CtrlIcoLib[action][AST_NORMAL].descr;
end;

end.
