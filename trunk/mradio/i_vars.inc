{used variables}
const
  RecBufSize = 16384;

{$include m_radio.inc}

const
  optActiveCodec:PAnsiChar = 'ActiveCodec';
  optLastStn    :PAnsiChar = 'LastStation';
  optConnect    :PAnsiChar = 'AutoConnect';
  optOffline    :PAnsiChar = 'asOffline';
  optEQ_OFF     :PAnsiChar = 'eqoff';
  optStatusMsg  :PAnsiChar = 'StatusMsg';
  optCurElement :PAnsiChar = 'LastPlayed';
  optPlay1st    :PAnsiChar = 'PlayFromFirst'; 
  optActiveURL  :PAnsiChar = 'ActiveURL';
  optContRec    :PAnsiChar = 'ContRec';
  optLoop       :PAnsiChar = 'Loop';
  optShuffle    :PAnsiChar = 'Shuffle';
  optRecPath    :PAnsiChar = 'RecordPath';
  optStatus     :PAnsiChar = 'Status';
  optVolume     :PAnsiChar = 'Volume';
  optBuffer     :PAnsiChar = 'Buffer';
  optPreBuf     :PAnsiChar = 'PreBuf';
  optTimeout    :PAnsiChar = 'Timeout';
  optVersion    :PAnsiChar = 'version';
  optStatusTmpl :PAnsiChar = 'StatusTmpl';
  optNumTries   :PAnsiChar = 'NumTries';
  // mRadio compatibility
  optStationURL :PAnsiChar = 'StationURL';
  optMyHandle   :PAnsiChar = 'MyHandle';
  optGenre      :PAnsiChar = 'Genre';
  optBitrate    :PAnsiChar = 'Bitrate';
  // UserInfo compatibility
  optFirstName  :PAnsiChar = 'FirstName';
  optNick       :PAnsiChar = 'Nick';
  optLastName   :PAnsiChar = 'LastName';
  optAge        :PAnsiChar = 'Age';
  // 3D sound support
  optEAXType    :PAnsiChar = 'EAXtype';

  optGroup      :PAnsiChar = 'Group';
  optBASSPath   :PAnsiChar = 'BASSpath';
  optTitle      :PAnsiChar = 'Title';
  optArtist     :PAnsiChar = 'Artist';

var
  hhRadioStatus,
  // service handles
  hsPlayStop,
  hsRecord,
  hsSettings,
  hsSetVol,
  hsGetVol,
  hsCommand,
  hsExport,
  hsImport,
  hsEqOnOff,

  hNetLib,
  hDblClick,
  hHookShutdown,
  hCMenuItemRec,
  hCMenuItemPlay,
  contexthook,
  opthook,
  onsetting,
  ondelete,
  onloadhook:THANDLE;
var
  plist:tPlaylist;
//  plFile:pWideChar; // playlist file name (for delete after using?)
//  plLocal:boolean;  // true - no need to delete playlist
var
  RemoteSong:bool;
  PlayStatus:dword;
  gVolume:integer;
  NumTries:cardinal;
  doLoop:dword;
  PlayFirst:dword;
  doShuffle:dword;
  doContRec:dword;
  asOffline:dword;
  AuConnect:dword;
  isEQ_OFF:dword;
  PluginStatus:integer;
  storagep,storage:PAnsiChar;
  recpath:pWideChar;
  ttbRecord,ttbSettings:integer;
  tbUsed:bool;
  sBuffer,
  sTimeout,
  sPreBuf:dword;
const
  hVolCtrl   :HWND=0;
  hVolFrmCtrl:HWND=0;
const
  Inited:boolean=false;
const
  StatusTmpl:pWideChar = nil;
  Proxy:pAnsiChar = nil;
type
  tEQRec = record
    fx    :HFX;
    wnd   :HWND;
    param :BASS_DX8_PARAMEQ;
    text  :PAnsiChar;
  end;
var
  eq:array [0..9] of tEQRec = (
    (param:(fCenter:80   ;fBandwidth:18);text:'80'),
    (param:(fCenter:170  ;fBandwidth:18);text:'170'),
    (param:(fCenter:310  ;fBandwidth:18);text:'310'),
    (param:(fCenter:600  ;fBandwidth:18);text:'600'),
    (param:(fCenter:1000 ;fBandwidth:18);text:'1k'),
    (param:(fCenter:3000 ;fBandwidth:18);text:'3k'),
    (param:(fCenter:6000 ;fBandwidth:18);text:'6k'),
    (param:(fCenter:12000;fBandwidth:18);text:'12k'),
    (param:(fCenter:14000;fBandwidth:18);text:'14k'),
    (param:(fCenter:16000;fBandwidth:18);text:'16k'));
const
  IcoBtnSettings:PAnsiChar = 'Radio_Setting';
  IcoBtnOn      :PAnsiChar = 'Radio_On';
  IcoBtnOff     :PAnsiChar = 'Radio_Off';
  IcoBtnRecUp   :PAnsiChar = 'Radio_RecUp';
  IcoBtnRecDn   :PAnsiChar = 'Radio_RecDn';
  IcoBtnAdd     :PAnsiChar = 'Radio_Add';
  IcoBtnDel     :PAnsiChar = 'Radio_Del';
const
  hRecButton   :HWND    = 0;
  hRecord      :THANDLE = 0;
  chan         :HSTREAM = 0;
  ActiveContact:THANDLE = 0;
  ActiveURLW   :PWideChar = nil;
  CurDescrW    :PWideChar = nil;

type
  TEAXItem = record
    name:PWideChar;
    code:dword;
  end;
const
  EAXItems:array [0..EAX_ENVIRONMENT_COUNT] of TEAXItem=(
    (name:'Off'             ; code:0),
    (name:'Generic'         ; code:EAX_ENVIRONMENT_GENERIC),
    (name:'Padded Cell'     ; code:EAX_ENVIRONMENT_PADDEDCELL),
    (name:'Room'            ; code:EAX_ENVIRONMENT_ROOM),
    (name:'Bathroom'        ; code:EAX_ENVIRONMENT_BATHROOM),
    (name:'Living Room'     ; code:EAX_ENVIRONMENT_LIVINGROOM),
    (name:'Stone Room'      ; code:EAX_ENVIRONMENT_STONEROOM),
    (name:'Auditorium'      ; code:EAX_ENVIRONMENT_AUDITORIUM),
    (name:'Concert Hall'    ; code:EAX_ENVIRONMENT_CONCERTHALL),
    (name:'Cave'            ; code:EAX_ENVIRONMENT_CAVE),
    (name:'Arena'           ; code:EAX_ENVIRONMENT_ARENA),
    (name:'Hangar'          ; code:EAX_ENVIRONMENT_HANGAR),
    (name:'Carpeted Hallway'; code:EAX_ENVIRONMENT_CARPETEDHALLWAY),
    (name:'Hallway'         ; code:EAX_ENVIRONMENT_HALLWAY),
    (name:'Stone Corridor'  ; code:EAX_ENVIRONMENT_STONECORRIDOR),
    (name:'Alley'           ; code:EAX_ENVIRONMENT_ALLEY),
    (name:'Forrest'         ; code:EAX_ENVIRONMENT_FOREST),
    (name:'City'            ; code:EAX_ENVIRONMENT_CITY),
    (name:'Mountains'       ; code:EAX_ENVIRONMENT_MOUNTAINS),
    (name:'Quarry'          ; code:EAX_ENVIRONMENT_QUARRY),
    (name:'Plain'           ; code:EAX_ENVIRONMENT_PLAIN),
    (name:'Parking Lot'     ; code:EAX_ENVIRONMENT_PARKINGLOT),
    (name:'Sewer Pipe'      ; code:EAX_ENVIRONMENT_SEWERPIPE),
    (name:'Under Water'     ; code:EAX_ENVIRONMENT_UNDERWATER),
    (name:'Drugged'         ; code:EAX_ENVIRONMENT_DRUGGED),
    (name:'Dizzy'           ; code:EAX_ENVIRONMENT_DIZZY),
    (name:'Psychotic'       ; code:EAX_ENVIRONMENT_PSYCHOTIC));

type
  tPreset = record
    name  :PWideChar;
    preset:array [0..9] of shortint;
  end;
var
  Presets: array of tPreset;
