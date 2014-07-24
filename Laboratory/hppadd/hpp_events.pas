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
 hpp_events (historypp project)

 Version:   1.5
 Created:   05.08.2004
 Author:    Oxygen

 [ Description ]

 Some refactoring we have here, so now all event reading
 routines are here. By event reading I mean getting usefull
 info out of DB and translating it into human words,
 like reading different types of messages and such.

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}

unit hpp_events;

interface

uses
  Windows,
  m_api,
  hpp_global;

// general routine
procedure ReadEvent          (hDBEvent: THANDLE; var hi: THistoryItem; UseCP: Cardinal = CP_ACP);
procedure GetEventInfo       (hDBEvent: THANDLE; var EventInfo: TDBEventInfo);
function  GetEventTimestamp  (hDBEvent: THANDLE): DWord;
function  GetEventMessageType(hDBEvent: THANDLE): ThppMessageType;
function  GetEventDateTime   (hDBEvent: THANDLE): TDateTime;

function  GetEventName(const Hi: THistoryItem):pAnsiChar;

function IsIncomingEvent(const Hi: THistoryItem):boolean;
function IsOutgoingEvent(const Hi: THistoryItem):boolean;

implementation

uses
  common, datetime;

var
  RecentEvent: THANDLE = 0;
  RecentEventInfo: TDBEventInfo;

//const
{ CORE

  EVENTTYPE_MESSAGE     = 0;
  EVENTTYPE_URL         = 1;
  EVENTTYPE_CONTACTS    = 2;     // v0.1.2.2+
  EVENTTYPE_ADDED       = 1000;  // v0.1.1.0+: these used to be module-
  EVENTTYPE_AUTHREQUEST = 1001;  // specific codes, hence the module-
  EVENTTYPE_FILE        = 1002;  // specific limit has been raised to 2000
}
{ ICQ

  ICQEVENTTYPE_SMS           = 2001;
  ICQEVENTTYPE_EMAILEXPRESS  = 2002;
  ICQEVENTTYPE_WEBPAGER      = 2003;
  ICQEVENTTYPE_MISSEDMESSAGE = 2004;
}
{ WATRACK

  EVENTTYPE_WAT_REQUEST = 9601;
  EVENTTYPE_WAT_ANSWER  = 9602;
  EVENTTYPE_WAT_ERROR   = 9603;
  EVENTTYPE_WAT_MESSAGE = 9604;
}
{ NEWXSTATUSNOTIFY

  EVENTTYPE_STATUSCHANGE = 25368;  // from NewXStatusNotify
}
{ AVATARHISTORY

  EVENTTYPE_AVATAR_CHANGE = 9003;   // from pescuma's Avatar History
}
(*
//----- Support functions -----

{24 times}
procedure ReadStringTillZeroA(Text: PAnsiChar; Size: LongWord; var Result: AnsiString; var Pos: LongWord);
begin
  while (Pos < Size) and ((Text+Pos)^ <> #0) do
  begin
    Result := Result + (Text+Pos)^;
    Inc(Pos);
  end;
  Inc(Pos);
end;

{4 times in one place}
//?? need to check text+pos
procedure ReadStringTillZeroW(Text: PWideChar; Size: LongWord; var Result: WideString; var Pos: LongWord);
begin
  while (Pos < Size) and ((Text+Pos)^ <> #0) do
  begin
    Result := Result + (Text+Pos)^;
    Inc(Pos,SizeOf(WideChar));
  end;
  Inc(Pos,SizeOf(WideChar));
end;
*)

type
  TTextFunction = procedure(EventInfo: TDBEventInfo; var Hi: THistoryItem);

  TEventTableItem = record
    EventType   : Word;
    MessageType : TBuiltinMessageType;
//!!    TextFunction: TTextFunction;
  end;

var
  EventTable: array[0..14] of TEventTableItem = (
    // must be the first item in array for unknown events
    (EventType: MaxWord;                         MessageType: mtOther;         {TextFunction: GetEventTextForOther}),
    // events definitions
    (EventType: EVENTTYPE_MESSAGE;               MessageType: mtMessage;       {TextFunction: GetEventTextForMessage}),
    (EventType: EVENTTYPE_FILE;                  MessageType: mtFile;          {TextFunction: GetEventTextForFile}),
    (EventType: EVENTTYPE_URL;                   MessageType: mtUrl;           {TextFunction: GetEventTextForUrl}),
    (EventType: EVENTTYPE_AUTHREQUEST;           MessageType: mtSystem;        {TextFunction: GetEventTextForAuthRequest}),
    (EventType: EVENTTYPE_ADDED;                 MessageType: mtSystem;        {TextFunction: GetEventTextForYouWereAdded}),
    (EventType: EVENTTYPE_CONTACTS;              MessageType: mtContacts;      {TextFunction: GetEventTextForContacts}),
    
    (EventType: EVENTTYPE_STATUSCHANGE;          MessageType: mtStatus;        {TextFunction: GetEventTextForStatusChange}),
    (EventType: EVENTTYPE_AVATAR_CHANGE;         MessageType: mtAvatarChange;  {TextFunction: GetEventTextForAvatarChange}),

    (EventType: ICQEVENTTYPE_SMS;                MessageType: mtSMS;           {TextFunction: GetEventTextForSMS}),
    (EventType: ICQEVENTTYPE_WEBPAGER;           MessageType: mtWebPager;      {TextFunction: GetEventTextForWebPager}),
    (EventType: ICQEVENTTYPE_EMAILEXPRESS;       MessageType: mtEmailExpress;  {TextFunction: GetEventTextForEmailExpress}),

    (EventType: EVENTTYPE_WAT_REQUEST;           MessageType: mtWATrack;       {TextFunction: GetEventTextWATrackRequest}),
    (EventType: EVENTTYPE_WAT_ANSWER;            MessageType: mtWATrack;       {TextFunction: GetEventTextWATrackAnswer}),
    (EventType: EVENTTYPE_WAT_ERROR;             MessageType: mtWATrack;       {TextFunction: GetEventTextWATrackError})
  );

function GetMessageType(EventInfo: TDBEventInfo; var EventIndex: Integer): THppMessageType;
var
  i: Integer;
begin
  EventIndex := 0;

  for i := 1 to High(EventTable) do
    if EventTable[i].EventType = EventInfo.EventType then
    begin
      EventIndex := i;
      break;
    end;
  Result.event:=EventInfo.EventType;
  Result.code :=EventTable[EventIndex].MessageType;

  if (EventInfo.flags and DBEF_SENT) = 0 then
    Result.direction:=mtIncoming
  else
    Result.direction:=mtOutgoing;
end;

procedure GetEventInfo(hDBEvent: THANDLE; var EventInfo: TDBEventInfo);
var
  BlobSize: integer;
begin
  ZeroMemory(@EventInfo, SizeOf(EventInfo));
  EventInfo.cbSize := SizeOf(EventInfo);
  BlobSize := db_event_getBlobSize(hDBEvent);
  if BlobSize > 0 then
  begin
    mGetMem(EventInfo.pBlob,BlobSize+2); // cheat, for possible crash avoid
  end
  else
    BlobSize := 0;
  EventInfo.cbBlob := BlobSize;
  if db_event_get(hDBEvent, @EventInfo) = 0 then
  begin
    EventInfo.cbBlob := BlobSize;
    pAnsiChar(EventInfo.pBlob)[BlobSize  ]:=#0;
    pAnsiChar(EventInfo.pBlob)[BlobSize+1]:=#0;
  end
  else
    EventInfo.cbBlob := 0;
end;

function GetEventCoreText(EventInfo: TDBEventInfo; CP: integer): PWideChar;
var
  dbegt: TDBEVENTGETTEXT;
  msg: pWideChar;
begin
  dbegt.dbei     := @EventInfo;
  dbegt.datatype := DBVT_WCHAR;
  dbegt.codepage := CP;

  msg := pWideChar(CallService(MS_DB_EVENT_GETTEXT,0,LPARAM(@dbegt)));
  StrDupW(result,msg);
  mir_free(msg);
end;

const
  UrlPrefix: array[0..1] of pWideChar = (
    'www.',
    'ftp.');

const
  UrlProto: array[0..12] of record
      Proto: PWideChar;
      Idn  : Boolean;
    end = (
    (Proto: 'http:/';     Idn: True;),
    (Proto: 'ftp:/';      Idn: True;),
    (Proto: 'file:/';     Idn: False;),
    (Proto: 'mailto:/';   Idn: False;),
    (Proto: 'https:/';    Idn: True;),
    (Proto: 'gopher:/';   Idn: False;),
    (Proto: 'nntp:/';     Idn: False;),
    (Proto: 'prospero:/'; Idn: False;),
    (Proto: 'telnet:/';   Idn: False;),
    (Proto: 'news:/';     Idn: False;),
    (Proto: 'wais:/';     Idn: False;),
    (Proto: 'outlook:/';  Idn: False;),
    (Proto: 'callto:/';   Idn: False;));

function TextHasUrls(Text: pWideChar): Boolean;
var
  i,len: Integer;
  buf,pPos: PWideChar;
begin
  Result := False;
  len := StrLenW(Text);
  if len=0 then exit;

  // search in URL Prefixes like "www"
  // make Case-insensitive??

  for i := 0 to High(UrlPrefix) do
  begin
    pPos := StrPosW(Text, UrlPrefix[i]);
    if not Assigned(pPos) then
      continue;
    Result := ((uint_ptr(pPos) = uint_ptr(Text)) or not IsWideCharAlphaNumeric((pPos - 1)^)) and
      IsWideCharAlphaNumeric((pPos + StrLenW(UrlPrefix[i]))^);
    if Result then
      exit;
  end;

  // search in url protos like "http:/"

  if StrPosW(Text,':/') = nil then exit;

  StrDupW(buf,Text);

  CharLowerBuffW(buf,len);
  for i := 0 to High(UrlProto) do
  begin
    pPos := StrPosW(buf, UrlProto[i].proto);
    if not Assigned(pPos) then
      continue;
    Result := ((uint_ptr(pPos) = uint_ptr(buf)) or
      not IsWideCharAlphaNumeric((pPos - 1)^));
    if Result then
      break;
  end;
  mFreeMem(buf);
end;

function AdjustLineBreaks(S:pWideChar):pWideChar;
var
  Source, Dest: PWideChar;
  Extra, len: Integer;
begin
  Result := nil;
  len := StrLenW(S);
  if len=0 then
    exit;

  Source := S;
  Extra := 0;
  while Source^ <> #0 do
  begin
    case Source^ of
      #10:
        Inc(Extra);
      #13:
        if Source[1] = #10 then
          Inc(Source)
        else
          Inc(Extra);
    end;
    Inc(Source);
  end;

  if Extra = 0 then
  begin
    Result := S;
  end
  else
  begin
    Source := S;
    mGetMem(Result, len + Extra + 1);
    Dest := Result;
    while Source^ <> #0 do
    begin
      case Source^ of
        #10: begin
          Dest^ := #13;
          Inc(Dest);
          Dest^ := #10;
        end;
        #13: begin
          Dest^ := #13;
          Inc(Dest);
          Dest^ := #10;
          if Source[1] = #10 then
            Inc(Source);
        end;
      else
        Dest^ := Source^;
      end;
      Inc(Dest);
      Inc(Source);
    end;
    Dest^ := #0;
    mFreeMem(S); //!!
  end;
end;

// reads event from hDbEvent handle
// reads all THistoryItem fields
// *EXCEPT* Proto field. Fill it manually, plz
procedure ReadEvent(hDBEvent: THANDLE; var hi: THistoryItem; UseCP: Cardinal = CP_ACP);
var
  EventInfo: TDBEventInfo;
  EventIndex: integer;
  Handled: Boolean;
begin
  ZeroMemory(@hi,SizeOf(hi));
  hi.Height := -1;
  GetEventInfo(hDBEvent, EventInfo);

  hi.Module      := EventInfo.szModule;                     {*}
  hi.proto       := nil;
  hi.Time        := EventInfo.Timestamp;                    {*}
  hi.IsRead      := Boolean(EventInfo.flags and DBEF_READ); {*}
  hi.MessageType := GetMessageType(EventInfo, EventIndex);  {!}
  hi.CodePage    := UseCP;                                  {?}
  // enable autoRTL feature
  if Boolean(EventInfo.flags and DBEF_RTL) then
    hi.RTLMode := hppRTLEnable;                             {*}

  hi.Text := GetEventCoreText(EventInfo, UseCP);
{!!
  if hi.Text = nil then
    EventTable[EventIndex].TextFunction(EventInfo, hi);
}
  hi.Text := AdjustLineBreaks(hi.Text);
  hi.Text := rtrimw(hi.Text);

  if hi.MessageType.code=mtMessage then
    if TextHasUrls(hi.Text) then
    begin
      hi.MessageType.code:=mtUrl;
    end;

  mFreeMem(EventInfo.pBlob);
end;

procedure CheckRecent(hDBEvent: THANDLE);
begin
  if RecentEvent <> hDBEvent then
  begin
    ZeroMemory(@RecentEventInfo, SizeOf(RecentEventInfo));
    RecentEventInfo.cbSize := SizeOf(RecentEventInfo);
    RecentEventInfo.cbBlob := 0;
    db_event_get(hDBEvent, @RecentEventInfo);
    RecentEvent := hDBEvent;
  end;
end;

function GetEventMessageType(hDBEvent: THANDLE): THppMessageType;
var
  EventIndex: Integer;
begin
  CheckRecent(hDBEvent);
  Result := GetMessageType(RecentEventInfo,EventIndex);
end;

function GetEventTimestamp(hDBEvent: THANDLE): DWord;
begin
  CheckRecent(hDBEvent);
  Result := RecentEventInfo.timestamp;
end;

function GetEventDateTime(hDBEvent: THANDLE): TDateTime;
begin
  Result := TimestampToDateTime(GetEventTimestamp(hDBEvent));
end;

function GetEventName(const Hi: THistoryItem):pAnsiChar;
var
  MesType: THppMessageType;
  mt: TBuiltinMessageType;
  etd: PDBEVENTTYPEDESCR;
begin
  MesType := Hi.MessageType;
  for mt := Low(EventNames) to High(EventNames) do
  begin
    if MesType.code = mt then
    begin
      Result := EventNames[mt];
      exit;
    end;
  end;

  etd := Pointer(CallService(MS_DB_EVENT_GETTYPE, WPARAM(Hi.Module), LPARAM(Hi.MessageType.event)));
  if etd = nil then
  begin
    Result := EventNames[mtOther];
  end
  else
    Result := etd.descr;
end;

function IsIncomingEvent(const Hi: THistoryItem):boolean;
begin
  result:=(Hi.MessageType.direction and mtIncoming)<>0; 
end;

function IsOutgoingEvent(const Hi: THistoryItem):boolean;
begin
  result:=(Hi.MessageType.direction and mtOutgoing)<>0; 
end;

end.
