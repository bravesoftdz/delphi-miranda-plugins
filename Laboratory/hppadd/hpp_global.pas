(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
    History+ parts (C) 2001 Christian Kastner

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

{-----------------------------------------------------------------------------
 hpp_global.pas (historypp project)

 Version:   1.5
 Created:   30.01.2006
 Author:    Oxygen

 [ Description ]

 After some refactoring, caused by dp_events, had to bring
 THistoryItem record into independant unit, so we don't have
 silly dependances of HisotoryGrid on dp_events (HistoryGrid
 doesn't depend on Miranda!) or dp_events on HistoryGrid (such
 a hog!)


 [ History ]

 1.5 (30.01.2006)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Contributors: theMIROn
-----------------------------------------------------------------------------}

unit hpp_global;

interface

uses
  Windows,Messages,
  m_api;

type
  TMouseKey = (mkControl, mkLButton, mkMButton, mkRButton, mkShift);
  TMouseKeys = set of TMouseKey;

const // direction
  mtIncoming = 1;
  mtOutgoing = 2;

type
  // note: add new message types to the end, or it will mess users' saved filters
  //       don't worry about customization filters dialog, as mtOther will always
  //       be show as the last entry
  TBuiltinMessageType = (
    mtUnknown,
    mtMessage, mtUrl, mtFile, mtSystem,
    mtContacts, mtSMS, mtWebPager, mtEmailExpress, mtStatus, mtSMTPSimple,
    mtOther,
    mtNickChange,mtAvatarChange,mtWATrack,mtStatusMessage,mtVoiceCall,mtCustom);

  THppMessageType = record
    event    : word;                // event code in database
    direction: byte;                // 0, incoming, outgoing, both
    code     : TBuiltinMessageType; // number (code) of predefined event
  end;

  PMessageTypes = ^TMessageTypes;
  TMessageTypes = set of TBuiltinMessageType;

const
  EventNames: array[TBuiltinMessageType] of PAnsiChar = (
    'Unknown',
    'Message',
    'Link',
    'File transfer',
    'System message',
    'Contacts',
    'SMS message',
    'Webpager message',
    'EMail Express message',
    'Status changes',
    'SMTP Simple Email',
    'Other events (unknown)',
    'Nick changes',
    'Avatar changes',
    'WATrack notify',
    'Status message changes',
    'Voice call',
    'Custom'
  );

type
  TRTLMode = (hppRTLDefault,hppRTLEnable,hppRTLDisable);

{  TDBEVENTINFO = record
    cbSize   : int;  // size of the structure
*    szModule : PAnsiChar; // module that 'owns' this event and controls the data format
*    timestamp: dword; // timestamp in UNIX time
x    flags    : dword; // the DBEF_* flags above
*    eventType: word;  // event type, such as message, can be module defined
    cbBlob   : dword; // size in bytes of pBlob^
    pBlob    : PByte; // pointer to buffer containing the module defined event data
  end;
}
  PHistoryItem = ^THistoryItem;
  THistoryItem = record
    Module      : pAnsiChar;
    Proto       : pAnsiChar;
    Text        : pWideChar;
    Extended    : pAnsiChar;
    CodePage    : Cardinal;
    Time        : DWord;
    Height      : Integer;
    MessageType : ThppMessageType;
    RTLMode     : TRTLMode;
    HasHeader   : Boolean;    // header for sessions
    LinkedToPrev: Boolean;    // for future use to group messages from one contact together
    Bookmarked  : Boolean;
    IsRead      : Boolean;
  end;

type
  TWideStrArray = array of PWideChar;
  TIntArray     = array of Integer;
type
  TSendMethod = (smSend,smPost);

const
  HM_BASE = WM_APP + 10214; // (+$27E6) base for all history++ messages

  HM_HIST_BASE = HM_BASE + 100; // base for contact's history specific messages
  HM_SRCH_BASE = HM_BASE + 200; // base for global search specific messages
  HM_SESS_BASE = HM_BASE + 300; // base for session thread specific messages
  HM_STRD_BASE = HM_BASE + 400; // base for search thread specific messages
  HM_NOTF_BASE = HM_BASE + 500; // base for plugin-wide notification messages
  HM_MIEV_BASE = HM_BASE + 600; // base for miranda event messages

  // HistoryGrid messages:
  HM_HG_OPTIONS     = HM_BASE + 1; // HistoryGrid options changed. wParam - HGOPT_* flags
  HM_HG_CACHEUPDATE = HM_BASE + 2; // Need to update RichItem cache element. lParam - RichItem?

  // notification messages:
  HM_NOTF_ICONSCHANGED    = HM_NOTF_BASE + 1; // Skin icons has changed
  HM_NOTF_ICONS2CHANGED   = HM_NOTF_BASE + 2; // IcoLib icons has changed
  HM_NOTF_FILTERSCHANGED  = HM_NOTF_BASE + 3; // Filters has changed
  HM_NOTF_TOOLBARCHANGED  = HM_NOTF_BASE + 4; // Toolbar has changed
  HM_NOTF_BOOKMARKCHANGED = HM_NOTF_BASE + 5; // Bookmarks has changed
  HM_NOTF_ACCCHANGED      = HM_NOTF_BASE + 6; // Accessability prefs changed (menu toggle)
  HM_NOTF_NICKCHANGED     = HM_NOTF_BASE + 7; // Nick changed

  // miranda events
  HM_MIEV_EVENTADDED      = HM_MIEV_BASE + 1; // ME_DB_EVENT_ADDED
  HM_MIEV_EVENTDELETED    = HM_MIEV_BASE + 2; // ME_DB_EVENT_DELETED
  HM_MIEV_PRESHUTDOWN     = HM_MIEV_BASE + 3; // ME_SYSTEM_PRESHUTDOWN
  HM_MIEV_CONTACTDELETED  = HM_MIEV_BASE + 4; // ME_DB_CONTACT_DELETED
  HM_MIEV_METADEFCHANGED  = HM_MIEV_BASE + 5; // ME_MC_DEFAULTTCHANGED

//----- Options changing events -----
const
  ME_HPP_OPTIONSCHANGED = 'History++/OptionsChanged';
const
  // History Grid options flags
  HGOPT_TEMPLATES   = $0001; // templates, datetime format
  HGOPT_FONTSERVICE = $0002; // fonts, colors
  HGOPT_ITEMS       = $0004; // close to HGOPT_FONTSERVICE
  HGOPT_OPTIONS     = $0008; // inline,RTL, externals,bbcodes
  HGOPT_ALL         = $00FF;

//----- Plugin info -----
const
  hppName       = 'History++';
  hppShortName  = 'History++ (2in1)';
  hppShortNameV = hppShortName{$IFDEF ALPHA}+' [alpha '+{$I 'alpha.inc'}+']'{$ENDIF};
  hppDBName     = 'HistoryPlusPlus';
  hppVerMajor   = {MAJOR_VER}1{/MAJOR_VER};
  hppVerMinor   = {MINOR_VER}5{/MINOR_VER};
  hppVerRelease = {SUB_VER}1{/SUB_VER};
  hppVerBuild   = {BUILD}5{/BUILD};
  hppVerAlpha   = {$IFDEF ALPHA}True{$ELSE}False{$ENDIF};
  hppVersion    = hppVerMajor shl 24 + hppVerMinor shl 16 + hppVerRelease shl 8 + hppVerBuild;

  MIID_HISTORYPP:TGUID = '{B92282AC-686B-4541-A12D-6E9971A253B7}';

  hppDescription = 'Easy, fast and feature complete history viewer.';
  hppAuthor      = 'theMIROn, Art Fedorov';
  hppAuthorEmail = 'themiron@mail.ru, artemf@mail.ru';
  hppCopyright   = '© 2006-2009 theMIROn, 2003-2006 Art Fedorov. History+ parts © 2001 Christian Kastner';

  hppHomePageURL  = 'http://themiron.miranda.im/';
  hppChangelogURL = 'http://themiron.miranda.im/changelog';

const
  hppLoadBlock      = 4096;
  hppFirstLoadBlock = 200;

{
type
  TCodePage = record
    cp: Cardinal;
    lid: LCID;
    name: WideString;
  end;
}
const
  cpTable: array[0..14] of record
      cp: Cardinal;
      lid: LCID;
      name: pWideChar;
    end = (
    (cp:  874; lid: $041E; name: 'Thai'),
    (cp:  932; lid: $0411; name: 'Japanese'),
    (cp:  936; lid: $0804; name: 'Simplified Chinese'),
    (cp:  949; lid: $0412; name: 'Korean'),
    (cp:  950; lid: $0404; name: 'Traditional Chinese'),
    (cp: 1250; lid: $0405; name: 'Central European'),
    (cp: 1251; lid: $0419; name: 'Cyrillic'),
    (cp: 1252; lid: $0409; name: 'Latin I'),
    (cp: 1253; lid: $0408; name: 'Greek'),
    (cp: 1254; lid: $041F; name: 'Turkish'),
    (cp: 1255; lid: $040D; name: 'Hebrew'),
    (cp: 1256; lid: $0801; name: 'Arabic'),
    (cp: 1257; lid: $0425; name: 'Baltic'),
    (cp: 1258; lid: $042A; name: 'Vietnamese'),
    (cp: 1361; lid: $0412; name: 'Korean (Johab)'));

var
  hppCodepage: Cardinal;
  hppRichEditVersion: Integer;

var // Was in options before
  ShowHistoryCount: Boolean;

function MessageTypesToDWord(mt: TMessageTypes): DWord; //??

procedure CopyToClip(const WideStr: PWideChar; Handle: Hwnd; CodePage: Cardinal = CP_ACP; Clear: Boolean = True);

procedure OpenUrl(const URLText: pWideChar);

function PassMessage(Handle: THANDLE; Message: DWord; wParam: WPARAM; lParam: LPARAM; Method: TSendMethod = smSend): Boolean;

//----- added from TNT ------
function IsRTF(const Value: pWideChar): Boolean;

function IsWideCharUpper       (WC: WideChar): Boolean;
function IsWideCharLower       (WC: WideChar): Boolean;
function IsWideCharDigit       (WC: WideChar): Boolean;
function IsWideCharSpace       (WC: WideChar): Boolean;
function IsWideCharPunct       (WC: WideChar): Boolean;
function IsWideCharCntrl       (WC: WideChar): Boolean;
function IsWideCharBlank       (WC: WideChar): Boolean;
function IsWideCharXDigit      (WC: WideChar): Boolean;
function IsWideCharAlpha       (WC: WideChar): Boolean;
function IsWideCharAlphaNumeric(WC: WideChar): Boolean;


type
  THppBuffer = class
  private
    FBuffer: Pointer;
    FSize: Integer;
    FCallCount: Integer;
    FLock: TRTLCriticalSection;
  protected
    procedure Shrink;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;

    function Reallocate(NewSize: Integer): Integer;
    function Allocate  (NewSize: Integer): Integer;

    procedure Lock;
    procedure Unlock;

    property Buffer: Pointer read FBuffer;
    property Size: Integer read FSize;
  end;


implementation

uses common;


function MessageTypesToDWord(mt: TMessageTypes): DWord;
begin
  Result := 0;
  Move(mt,Result,SizeOf(mt));
end;

procedure OpenUrl(const URLText: pWideChar);
begin
  CallService(MS_UTILS_OPENURL,OUF_UNICODE,LPARAM(URLText));
end;

function GetLCIDfromCodepage(Codepage: Cardinal): LCID;
var
  i: integer;
begin
  if Codepage = CP_ACP then
    Codepage := GetACP;
  for i := 0 to High(cpTable) do
    if cpTable[i].cp = Codepage then
    begin
      Result := cpTable[i].lid;
      exit;
    end;
{
  for i := 0 to Languages.Count - 1 do
    if Cardinal(LCIDToCodePage(Languages.LocaleID[i])) = Codepage then
    begin
      Result := Languages.LocaleID[i];
      exit;
    end;
}
  Result := $0405;
end;

procedure CopyToClip(const WideStr: PWideChar; Handle: HWND; CodePage: Cardinal = CP_ACP; Clear: Boolean = True);
var
  WData, AData, LData: THANDLE;
  LDataPtr: ^Cardinal;
  WDataPtr: PWideChar;
  ADataPtr: PAnsiChar;
  AnsiStr: PAnsiChar;
  ASize,WSize: Integer;
begin
  WSize := (StrLenW(WideStr)+1)*SizeOf(WideChar);
  if WSize = SizeOf(WideChar) then exit;
  WideToAnsi(WideStr,AnsiStr,CodePage);
  ASize := StrLen(AnsiStr)+1;
  OpenClipboard(Handle);
  try
    if Clear then EmptyClipboard;
    WData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, WSize);
    AData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, ASize);
    LData := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, SizeOf(Cardinal));
    try
      WDataPtr := GlobalLock(WData);
      ADataPtr := GlobalLock(AData);
      LDataPtr := GlobalLock(LData);
      try
        Move(WideStr^,WDataPtr^,WSize);
        Move(AnsiStr^,ADataPtr^,ASize);
        LDataPtr^ := GetLCIDfromCodepage(CodePage);
        SetClipboardData(CF_UNICODETEXT, WData);
        SetClipboardData(CF_TEXT       , AData);
        SetClipboardData(CF_LOCALE     , LData);
      finally
        GlobalUnlock(WData);
        GlobalUnlock(AData);
        GlobalUnlock(LData);
      end;
    except
      GlobalFree(WData);
      GlobalFree(AData);
      GlobalFree(LData);
    raise;
    end;
  finally
    CloseClipBoard;
    mFreeMem(AnsiStr);
  end;
end;

function PassMessage(Handle: THANDLE; Message: DWord; wParam: WPARAM; lParam: LPARAM; Method: TSendMethod = smSend): Boolean;
var
  Tries: integer;
begin
  Result := True;
  case Method of
    smSend: SendMessage(Handle,Message,wParam,lParam);
    smPost: begin
      Tries := 5;
      while (Tries > 0) and not PostMessage(Handle,Message,wParam,lParam) do
      begin
        Dec(Tries);
        Sleep(5);
      end;
      Result := (Tries > 0);
    end;
  end;
end;

function IsRTF(const Value: pWideChar): Boolean;
const
  RTF_BEGIN_1  = '{\RTF';
  RTF_BEGIN_2  = '{URTF';
begin
  Result := (StrPosW(Value,RTF_BEGIN_1) = Value)
         or (StrPosW(Value,RTF_BEGIN_2) = Value);
end;

function _WideCharType(WC: WideChar; dwInfoType: Cardinal): Word;
begin
  GetStringTypeExW(GetThreadLocale, dwInfoType, PWideChar(@WC), 1, Result)
end;

function IsWideCharUpper(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_UPPER) <> 0;
end;

function IsWideCharLower(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_LOWER) <> 0;
end;

function IsWideCharDigit(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_DIGIT) <> 0;
end;

function IsWideCharSpace(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_SPACE) <> 0;
end;

function IsWideCharPunct(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_PUNCT) <> 0;
end;

function IsWideCharCntrl(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_CNTRL) <> 0;
end;

function IsWideCharBlank(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_BLANK) <> 0;
end;

function IsWideCharXDigit(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_XDIGIT) <> 0;
end;

function IsWideCharAlpha(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and C1_ALPHA) <> 0;
end;

function IsWideCharAlphaNumeric(WC: WideChar): Boolean;
begin
  Result := (_WideCharType(WC, CT_CTYPE1) and (C1_ALPHA + C1_DIGIT)) <> 0;
end;

{ THppBuffer }

const
  SHRINK_ON_CALL = 50;
  SHRINK_TO_LEN  = 512;

constructor THppBuffer.Create;
begin
  inherited;
  FBuffer := nil;
  FSize := 0;
  FCallCount := SHRINK_ON_CALL+1;
  InitializeCriticalSection(FLock);
  Shrink;
end;

destructor THppBuffer.Destroy;
begin
  Clear;
  DeleteCriticalSection(FLock);
  inherited;
end;

function THppBuffer.Reallocate(NewSize: Integer): Integer;
begin
  if NewSize > FSize then
  begin
    FSize := ((NewSize shr 4) + 1) shl 4;
    ReallocMem(FBuffer, FSize);
  end;
  Result := FSize;
end;

function THppBuffer.Allocate(NewSize: Integer): Integer;
begin
  Shrink;
  Result := Reallocate(NewSize);
end;

procedure THppBuffer.Shrink;
begin
  // shrink buffer on every SHRINK_ON_CALL event,
  // so it's not growing to infinity
  if (FSize > SHRINK_TO_LEN) and (FCallCount >= SHRINK_ON_CALL) then
  begin
    FSize := SHRINK_TO_LEN;
    ReallocMem(FBuffer, FSize);
    FCallCount := 0;
  end
  else
    Inc(FCallCount);
end;

procedure THppBuffer.Clear;
begin
  FreeMem(FBuffer,FSize);
  FBuffer := nil;
  FSize := 0;
  FCallCount := 0;
end;

procedure THppBuffer.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure THppBuffer.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

end.
