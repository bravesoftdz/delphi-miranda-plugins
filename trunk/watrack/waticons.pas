unit WATIcons;
interface

uses wat_api;

const // to not load icobuttons module
  AST_NORMAL  = 0;
  AST_HOVERED = 1;
  AST_PRESSED = 2;

// main Enable/Disable icons
const // name in icolib
  IcoBtnEnable :PAnsiChar='WATrack_Enabled';
  IcoBtnDisable:PAnsiChar='WATrack_Disabled';

function RegisterIcons:boolean;

// frame button icons
function RegisterButtonIcons:boolean;
function GetIcon(action:integer;stat:integer=AST_NORMAL):cardinal;
function DoAction(action:integer):integer;
function GetIconDescr(action:integer):pAnsiChar;
{
const
  AST_NORMAL  = 0;
  AST_HOVERED = 1;
  AST_PRESSED = 2;
}
implementation

uses m_api,windows,mirutils;

{$include waticons.inc}

const
  ICOCtrlName = 'watrack_buttons.dll';

const
  IconsLoaded:bool = false;

function DoAction(action:integer):integer;
begin
  result:=CallService(MS_WAT_PRESSBUTTON,action,0);
end;

function RegisterIcons:boolean;
var
  sid:TSKINICONDESC;
  buf:array [0..511] of AnsiChar;
  hIconDLL:THANDLE;
begin
  result:=true;
  sid.pszDefaultFile.a:='icons\'+ICOCtrlName;
//    ConvertFileName(sid.pszDefaultFile.a,buf);
  PluginLink^.CallService(MS_UTILS_PATHTOABSOLUTE,wparam(sid.pszDefaultFile),lparam(@buf));

  hIconDLL:=LoadLibraryA(buf);
  if hIconDLL=0 then // not found
  begin
    sid.pszDefaultFile.a:='plugins\'+ICOCtrlName;
//      ConvertFileName(sid.pszDefaultFile.a,buf);
    PluginLink^.CallService(MS_UTILS_PATHTOABSOLUTE,wparam(sid.pszDefaultFile),lparam(@buf));
    hIconDLL:=LoadLibraryA(buf);
  end;

  if hIconDLL=0 then
    hIconDLL:=hInstance;

  FillChar(sid,SizeOf(TSKINICONDESC),0);
  sid.cbSize:=SizeOf(TSKINICONDESC);
  sid.cx:=16;
  sid.cy:=16;
  sid.szSection.a:='WATrack';

  sid.hDefaultIcon   :=LoadImage(hIconDLL,
      MAKEINTRESOURCE(IDI_PLUGIN_ENABLE),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnEnable;
  sid.szDescription.a:='Plugin Enabled';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hIconDLL,
      MAKEINTRESOURCE(IDI_PLUGIN_DISABLE),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnDisable;
  sid.szDescription.a:='Plugin Disabled';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  if hIconDLL<>hInstance then
    FreeLibrary(hIconDLL);
end;

type
  PAWKIconButton = ^TAWKIconButton;
  TAWKIconButton = record
    descr:PAnsiChar;
    name :PAnsiChar;
    id   :int_ptr;
  end;
const
  CtrlIcoLib:array [WAT_CTRL_FIRST..WAT_CTRL_LAST,AST_NORMAL..AST_PRESSED] of
    TAWKIconButton = (
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
function RegisterButtonIcons:boolean;
var
  sid:TSKINICONDESC;
  buf:array [0..511] of AnsiChar;
  hIconDLL:THANDLE;
  i,j:integer;
begin
  if not IconsLoaded then
  begin
    sid.flags:=0;
    sid.cbSize:=SizeOf(TSKINICONDESC);
    sid.cx:=16;
    sid.cy:=16;

    sid.szSection.a     :='WATrack/Frame Controls';
    sid.pszDefaultFile.a:='icons\'+ICOCtrlName;
//    ConvertFileName(sid.pszDefaultFile.a,buf);
    PluginLink^.CallService(MS_UTILS_PATHTOABSOLUTE,wparam(sid.pszDefaultFile),lparam(@buf));

    hIconDLL:=LoadLibraryA(buf);
    if hIconDLL=0 then // not found
    begin
      sid.pszDefaultFile.a:='plugins\'+ICOCtrlName;
//      ConvertFileName(sid.pszDefaultFile.a,buf);
      PluginLink^.CallService(MS_UTILS_PATHTOABSOLUTE,wparam(sid.pszDefaultFile),lparam(@buf));
      hIconDLL:=LoadLibraryA(buf);
    end;

    if hIconDLL<>0 then
    begin
      i:=WAT_CTRL_FIRST;
      repeat
        j:=AST_NORMAL;
        repeat
          sid.hDefaultIcon   :=LoadImage(hIconDLL,
              MAKEINTRESOURCE(CtrlIcoLib[i][j].id),IMAGE_ICON,16,16,0);
          if sid.hDefaultIcon=0 then continue;

          // increment from 1 by order, so - just decrease number (for iconpack import)
          sid.iDefaultIndex  :=CtrlIcoLib[i][j].id-1;
          sid.pszName        :=CtrlIcoLib[i][j].name;
          sid.szDescription.a:=CtrlIcoLib[i][j].descr;

          PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
          DestroyIcon(sid.hDefaultIcon);
          Inc(j);
        until j>AST_PRESSED;
        Inc(i);
      until i>WAT_CTRL_LAST;
      FreeLibrary(hIconDLL);
      IconsLoaded:=true;
    end;
  end;

  result:=IconsLoaded;
end;

function GetIcon(action:integer;stat:integer):cardinal;
begin
  result:=PluginLink^.CallService(MS_SKIN2_GETICON,0,
      lparam(CtrlIcoLib[action][stat].name));
end;

function GetIconDescr(action:integer):pAnsiChar;
begin
  result:=CtrlIcoLib[action][AST_NORMAL].descr;
end;

end.
