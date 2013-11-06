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
  hpp_global,hpp_icons;

type
  PEventRecord = ^TEventRecord;
  TEventRecord = record
    Name : pAnsiChar;
    idx  : Integer;
  end;

const
  EventRecords: array[TBuiltinMessageType] of TEventRecord = (
    (Name:'Unknown';               idx:9999),
    (Name:'Message';               idx:-HPP_SKIN_EVENT_MESSAGE),
    (Name:'Link';                  idx:-HPP_SKIN_EVENT_URL),
    (Name:'File transfer';         idx:-HPP_SKIN_EVENT_FILE),
    (Name:'System message';        idx:ord(HPP_ICON_EVENT_SYSTEM)),
    (Name:'Contacts';              idx:ord(HPP_ICON_EVENT_CONTACTS)),
    (Name:'SMS message';           idx:ord(HPP_ICON_EVENT_SMS)),
    (Name:'Webpager message';      idx:ord(HPP_ICON_EVENT_WEBPAGER)),
    (Name:'EMail Express message'; idx:ord(HPP_ICON_EVENT_EEXPRESS)),
    (Name:'Status changes';        idx:ord(HPP_ICON_EVENT_STATUS)),
    (Name:'SMTP Simple Email';     idx:ord(HPP_ICON_EVENT_SMTPSIMPLE)),
    (Name:'Other events (unknown)';idx:-HPP_SKIN_OTHER_MIRANDA),
    (Name:'Nick changes';          idx:ord(HPP_ICON_EVENT_NICK)),
    (Name:'Avatar changes';        idx:ord(HPP_ICON_EVENT_AVATAR)),
    (Name:'WATrack notify';        idx:ord(HPP_ICON_EVENT_WATRACK)),
    (Name:'Status message changes';idx:ord(HPP_ICON_EVENT_STATUSMES)),
    (Name:'Voice call';            idx:ord(HPP_ICON_EVENT_VOICECALL)),
    (Name:'Custom';                idx:9999)
  );

const
  EVENTTYPE_AVATARCHANGE        = 9003;   // from pescuma

// general routine
procedure ReadEvent          (hDBEvent: THANDLE; var hi: THistoryItem; UseCP: Cardinal = CP_ACP);
procedure GetEventInfo       (hDBEvent: THANDLE; var EventInfo: TDBEventInfo);
function  GetEventTimestamp  (hDBEvent: THANDLE): DWord;
function  GetEventMessageType(hDBEvent: THANDLE): ThppMessageType;
function  GetEventDateTime   (hDBEvent: THANDLE): TDateTime;

function  GetEventName(const Hi: THistoryItem):pAnsiChar;
function  GetEventIcon(const Hi: THistoryItem):HICON;

function IsIncomingEvent(const Hi: THistoryItem):boolean;
function IsOutgoingEvent(const Hi: THistoryItem):boolean;

implementation

uses
  common,
  hpp_contacts;

var
  RecentEvent: THandle = 0;
  RecentEventInfo: TDBEventInfo;

var
  EventBuffer: THppBuffer;
  TextBuffer : THppBuffer;

{$include m_music.inc}
const
  EVENTTYPE_STATUSCHANGE        = 25368;  // from srmm's
  EVENTTYPE_SMTPSIMPLE          = 2350;   // from SMTP Simple
  EVENTTYPE_NICKNAMECHANGE      = 9001;   // from pescuma
  EVENTTYPE_STATUSMESSAGECHANGE = 9002;   // from pescuma
  EVENTTYPE_CONTACTLEFTCHANNEL  = 9004;   // from pescuma
  EVENTTYPE_VOICE_CALL          = 8739;   // from pescuma

const // registered Jabber db event types (not public)
  JABBER_DB_EVENT_TYPE_CHATSTATES = 2000;
//  JS_DB_GETEVENTTEXT_CHATSTATES   = '/GetEventText2000';
  JABBER_DB_EVENT_CHATSTATES_GONE = 1;

const // ICQ db events (didn't found anywhere)
  //auth
  //db event added to NULL contact
  //blob format is:
  //ASCIIZ    text
  //DWORD     uin
  //HANDLE    hContact
  ICQEVENTTYPE_AUTH_GRANTED   = 2004;    //database event type
  ICQEVENTTYPE_AUTH_DENIED    = 2005;    //database event type
  ICQEVENTTYPE_SELF_REMOVE    = 2007;    //database event type
  ICQEVENTTYPE_FUTURE_AUTH    = 2008;    //database event type
  ICQEVENTTYPE_CLIENT_CHANGE  = 2009;    //database event type
  ICQEVENTTYPE_CHECK_STATUS   = 2010;    //database event type
  ICQEVENTTYPE_IGNORECHECK_STATUS = 2011;//database event type
  //broadcast from server
  //ASCIIZ    text
  //ASCIIZ    from name
  //ASCIIZ    from e-mail
  ICQEVENTTYPE_BROADCAST      = 2006;    //database event type

const
  // 1970-01-01T00:00:00 in TDateTime
  UnixTimeStart = 25569;
  SecondsPerDay = 60*60*24;

(*
//----- Support functions -----

{2 times}
function Utf8ToWideChar(Dest: PWideChar; MaxDestChars: Integer; Source: PAnsiChar; SourceBytes: Integer; CodePage: Cardinal = CP_ACP): Integer;
const
  MB_ERR_INVALID_CHARS = 8;
var
  Src,SrcEnd: PAnsiChar;
  Dst,DstEnd: PWideChar;
begin
  if (Source = nil) or (SourceBytes <= 0) then
  begin
    Result := 0;
  end
  else if (Dest = nil) or (MaxDestChars <= 0) then
  begin
    Result := -1;
  end
  else
  begin
    Src := Source;
    SrcEnd := Source + SourceBytes;
    Dst := Dest;
    DstEnd := Dst + MaxDestChars;
    while (PAnsiChar(Src) < PAnsiChar(SrcEnd)) and (Dst < DstEnd) do
    begin
      if (Byte(Src[0]) and $80) = 0 then
      begin
        Dst[0] := WideChar(Src[0]);
        Inc(Src);
      end
      else if (Byte(Src[0]) and $E0) = $E0 then
      begin
        if Src + 2 >= SrcEnd then
          break;
        if (Src[1] = #0) or ((Byte(Src[1]) and $C0) <> $80) then
          break;
        if (Src[2] = #0) or ((Byte(Src[2]) and $C0) <> $80) then
          break;
        Dst[0] := WideChar(((Byte(Src[0]) and $0F) shl 12) + ((Byte(Src[1]) and $3F) shl 6) +
          ((Byte(Src[2]) and $3F)));
        Inc(Src, 3);
      end
      else if (Byte(Src[0]) and $E0) = $C0 then
      begin
        if Src + 1 >= SrcEnd then
          break;
        if (Src[1] = #0) or ((Byte(Src[1]) and $C0) <> $80) then
          break;
        Dst[0] := WideChar(((Byte(Src[0]) and $1F) shl 6) + ((Byte(Src[1]) and $3F)));
        Inc(Src, 2);
      end
      else
      begin
        if MultiByteToWideChar(CodePage, MB_ERR_INVALID_CHARS, Src, 1, Dst, 1) = 0 then
          Dst[0] := '?';
        Inc(Src);
      end;
      Inc(Dst);
    end;
    Dst[0] := #0;
    Inc(Dst);
    Result := Dst - Dest;
  end;
end;


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

//----- Event to text translation -----

procedure GetEventTextForMessage(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  msgA: PAnsiChar;
  msgW: PWideChar;
  msglen,lenW: integer;
  i: integer;
begin
  msgA := PAnsiChar(EventInfo.pBlob);
  msgW := nil;
  msglen := StrLen(PAnsiChar(EventInfo.pBlob)) + 1;
  if msglen > integer(EventInfo.cbBlob) then
    msglen := EventInfo.cbBlob;
  if Boolean(EventInfo.flags and DBEF_UTF) then
  begin
    SetLength(Hi.Text, msglen);
    lenW := Utf8ToWideChar(PWideChar(Hi.Text), msglen, msgA, msglen - 1, Hi.CodePage);
    if lenW > 0 then
      SetLength(Hi.Text, lenW - 1)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
  end
  else
  begin
    lenW := 0;
    if integer(EventInfo.cbBlob) >= msglen * SizeOf(WideChar) then
    begin
      msgW := PWideChar(msgA + msglen);
      for i := 0 to ((integer(EventInfo.cbBlob) - msglen) div SizeOf(WideChar)) - 1 do
        if msgW[i] = #0 then
        begin
          lenW := i;
          break;
        end;
    end;
    if (lenW > 0) and (lenW < msglen) then
      SetString(Hi.Text, msgW, lenW)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
  end;
end;

procedure GetEventTextForUrl(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos:LongWord;
  Url,Desc: AnsiString;
  cp: Cardinal;
begin
  BytePos:=0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Url,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Desc,BytePos);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  hi.Text := Format(TranslateW('URL: %s'),[AnsiToWideString(url+#13#10+desc,cp)]);
  hi.Extended := Url;
end;

procedure GetEventTextForFile(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  FileName,Desc: AnsiString;
  cp: Cardinal;
begin
  //blob is: sequenceid(DWORD),filename(ASCIIZ),description(ASCIIZ)
  BytePos := 4;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, FileName, BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Desc, BytePos);
  if Boolean(EventInfo.flags and DBEF_SENT) then
    Hi.Text := 'Outgoing file transfer: %s'
  else
    Hi.Text := 'Incoming file transfer: %s';
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  Hi.Text := Format(TranslateUnicodeString(Hi.Text), [AnsiToWideString(FileName + #13#10 + Desc, cp)]);
  Hi.Extended := FileName;
end;

procedure GetEventTextForAuthRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  uin:integer;
  hContact: THandle;
  Nick,Name,Email,Reason: AnsiString;
  NickW,ReasonW,ReasonUTF,ReasonACP: WideString;
begin
  // blob is: uin(DWORD), hContact(THANDLE), nick(ASCIIZ), first(ASCIIZ), last(ASCIIZ), email(ASCIIZ)
  uin := PDWord(EventInfo.pBlob)^;
  hContact := PInt_ptr(uint_ptr(Pointer(EventInfo.pBlob)) + SizeOf(dword))^;
  BytePos := SizeOf(dword) + SizeOf(THandle);
  // read nick
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Nick, BytePos);
  if Nick = '' then
    NickW := GetContactDisplayName(hContact, '', true)
  else
    NickW := AnsiToWideString(Nick, CP_ACP);
  // read first name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := Name + ' ';
  // read last name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := AnsiString(Trim(WideString(Name)));
  if Name <> '' then
    Name := Name + ', ';
  // read Email
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Email, BytePos);
  if Email <> '' then
    Email := Email + ', ';
  // read reason
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Reason, BytePos);

  ReasonUTF := AnsiToWideString(Reason, CP_UTF8);
  ReasonACP := AnsiToWideString(Reason, hppCodepage);
  if (Length(ReasonUTF) > 0) and (Length(ReasonUTF) < Length(ReasonACP)) then
    ReasonW := ReasonUTF
  else
    ReasonW := ReasonACP;
  Hi.Text := Format(TranslateW('Authorisation request by %s (%s%d): %s'),
    [NickW, AnsiToWideString(Name + Email, hppCodepage), uin, ReasonW]);
end;

procedure GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  uin: integer;
  hContact:THandle;
  Nick,Name,Email: AnsiString;
  NickW: String;
begin
  // blob is: uin(DWORD), hContact(THANDLE), nick(ASCIIZ), first(ASCIIZ), last(ASCIIZ), email(ASCIIZ)
  uin := PDWord(EventInfo.pBlob)^;
  hContact := PInt_ptr(uint_ptr(Pointer(EventInfo.pBlob)) + SizeOf(dword))^;
  BytePos := SizeOf(dword) + SizeOf(THandle);
  // read nick
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Nick, BytePos);
  if Nick = '' then
    NickW := GetContactDisplayName(hContact, '', true)
  else
    NickW := AnsiToWideString(Nick, CP_ACP);
  // read first name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := Name + ' ';
  // read last name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := AnsiString(Trim(WideString(Name)));
  if Name <> '' then
    Name := Name + ', ';
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Email, BytePos);
  if Email <> '' then
    Email := Email + ', ';
  Hi.Text := Format(TranslateW('You were added by %s (%s%d)'),
    [NickW, AnsiToWideString(Name + Email, hppCodepage), uin]);
end;

procedure GetEventTextForSms(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  cp: Cardinal;
begin
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  Hi.Text := AnsiToWideString(PAnsiChar(EventInfo.pBlob), cp);
end;

procedure GetEventTextForContacts(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Contacts: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  Contacts := '';
  While BytePos < Cardinal(EventInfo.cbBlob) do
  begin
    Contacts := Contacts + #13#10;
    ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Contacts, BytePos);
    Contacts := Contacts + ' (ICQ: ';
    ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Contacts, BytePos);
    Contacts := Contacts + ')';
  end;
  if Boolean(EventInfo.flags and DBEF_SENT) then
    Hi.Text := 'Outgoing contacts: %s'
  else
    Hi.Text := 'Incoming contacts: %s';
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  hi.Text := Format(TranslateUnicodeString(hi.Text),[AnsiToWideString(Contacts,cp)]);
end;

procedure GetEventTextForWebPager(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  hi.Text := Format(TranslateW('Webpager message from %s (%s): %s'),
                           [AnsiToWideString(Name,cp),
                           AnsiToWideString(Email,cp),
                           AnsiToWideString(#13#10+Body,cp)]);
end;

procedure GetEventTextForEmailExpress(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  Hi.Text := Format(TranslateW('Email express from %s (%s): %s'),
    [AnsiToWideString(Name, cp), AnsiToWideString(Email, cp),
    AnsiToWideString(#13#10 + Body, cp)]);
end;

procedure GetEventTextForStatusChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  tmp: THistoryItem;
begin
  tmp.Codepage := hppCodepage;
  GetEventTextForMessage(EventInfo,tmp);
  hi.Text := Format(TranslateW('Status change: %s'),[tmp.Text]);
end;

procedure GetEventTextForAvatarChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  msgA: PAnsiChar;
  msgW: PWideChar;
  msglen,lenW: Cardinal;
  i: integer;
begin
  msgA := PAnsiChar(EventInfo.pBlob);
  msgW := nil;
  msglen := lstrlenA(PAnsiChar(EventInfo.pBlob)) + 1;
  if msglen > Cardinal(EventInfo.cbBlob) then
    msglen := EventInfo.cbBlob;
  if Boolean(EventInfo.flags and DBEF_UTF) then
  begin
    SetLength(Hi.Text, msglen);
    lenW := Utf8ToWideChar(PWideChar(Hi.Text), msglen, msgA, msglen - 1, Hi.CodePage);
    if Integer(lenW) > 0 then
      SetLength(Hi.Text, lenW - 1)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
  end
  else
  begin
    lenW := 0;
    if Cardinal(EventInfo.cbBlob) >= msglen * SizeOf(WideChar) then
    begin
      msgW := PWideChar(msgA + msglen);
      for i := 0 to ((Cardinal(EventInfo.cbBlob) - msglen) div SizeOf(WideChar)) - 1 do
        if msgW[i] = #0 then
        begin
          lenW := i;
          break;
        end;
    end;
    if (lenW > 0) and (lenW < msglen) then
      SetString(Hi.Text, msgW, lenW)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
    msglen := msglen + (lenW + 1) * SizeOf(WideChar);
  end;
  if msglen < Cardinal(EventInfo.cbBlob) then
  begin
    msgA := msgA + msglen;
    if lstrlenA(msgA) > 0 then
      Hi.Extended := msgA;
  end;
end;

function GetEventTextForICQSystem(EventInfo: TDBEventInfo; const Template: WideString): WideString;
var
  BytePos: LongWord;
  Body: AnsiString;
  uin: Integer;
  Name: WideString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Body, BytePos);
  if Cardinal(EventInfo.cbBlob) < (BytePos + 4) then
    uin := 0
  else
    uin := PDWord(PAnsiChar(EventInfo.pBlob) + BytePos)^;
  if Cardinal(EventInfo.cbBlob) < (BytePos + 8) then
    Name := TranslateW('''(Unknown Contact)''' { TRANSLATE-IGNORE } )
  else
    Name := GetContactDisplayName(PDWord(PAnsiChar(EventInfo.pBlob) + BytePos + 4)^, '', true);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  Result := Format(Template, [Name, uin, AnsiToWideString(#13#10 + Body, cp)]);
end;

procedure GetEventTextForICQAuthGranted(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Authorization request granted by %s (%d): %s'));
end;

procedure GetEventTextForICQAuthDenied(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Authorization request denied by %s (%d): %s'));
end;

procedure GetEventTextForICQSelfRemove(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('User %s (%d) removed himself from your contact list: %s'));
end;

procedure GetEventTextForICQFutureAuth(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Authorization future request by %s (%d): %s'));
end;

procedure GetEventTextForICQClientChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('User %s (%d) changed icq client: %s'));
end;

procedure GetEventTextForICQCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Status request by %s (%d):%s'));
end;

procedure GetEventTextForICQIgnoreCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Ignored status request by %s (%d):%s'));
end;

procedure GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateW('Broadcast message from %s (%s): %s');
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  hi.Text := Format(hi.Text,[AnsiToWideString(Name,cp),
                             AnsiToWideString(Email,cp),
                             AnsiToWideString(#13#10+Body,cp)]);
end;

procedure GetEventTextForJabberChatStates(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  if EventInfo.cbBlob = 0 then exit;
  case PByte(EventInfo.pBlob)^ of
    JABBER_DB_EVENT_CHATSTATES_GONE:
      hi.Text := TranslateW('closed chat session');
  end;
end;

procedure GetEventTextWATrackRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := TranslateW('WATrack: information request');
end;

procedure GetEventTextWATrackAnswer(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Artist,Title,Album,Template: WideString;
begin
  BytePos := 0;
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Artist  ,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Title   ,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Album   ,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Template,BytePos);
  if (Artist <> '') or (Title <> '') or (Album <> '') then
  begin
    if Template <> '' then
      Template := Template + #13#10;
    Template := Template + Format//WideFormat
      (TranslateW('Artist: %s'#13#10'Title: %s'#13#10'Album: %s'),
      [Artist, Title, Album]);
  end;
  hi.Text := Format(TranslateW('WATrack: %s'),[Template]);
end;

procedure GetEventTextWATrackError(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := TranslateW('WATrack: request denied');
end;

procedure GetEventTextForOther(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  cp: Cardinal;
begin
  TextBuffer.Allocate(EventInfo.cbBlob+1);
  StrCopy(TextBuffer.Buffer,PAnsiChar(EventInfo.pBlob),EventInfo.cbBlob);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  hi.Text := AnsiToWideString(PAnsiChar(TextBuffer.Buffer),cp);
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
  EventTable: array[0..28] of TEventTableItem = (
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
    (EventType: EVENTTYPE_SMTPSIMPLE;            MessageType: mtSMTPSimple;    {TextFunction: GetEventTextForMessage}),
    (EventType: ICQEVENTTYPE_SMS;                MessageType: mtSMS;           {TextFunction: GetEventTextForSMS}),
    (EventType: ICQEVENTTYPE_WEBPAGER;           MessageType: mtWebPager;      {TextFunction: GetEventTextForWebPager}),
    (EventType: ICQEVENTTYPE_EMAILEXPRESS;       MessageType: mtEmailExpress;  {TextFunction: GetEventTextForEmailExpress}),
    (EventType: EVENTTYPE_NICKNAMECHANGE;        MessageType: mtNickChange;    {TextFunction: GetEventTextForMessage}),
    (EventType: EVENTTYPE_STATUSMESSAGECHANGE;   MessageType: mtStatusMessage; {TextFunction: GetEventTextForMessage}),
    (EventType: EVENTTYPE_AVATARCHANGE;          MessageType: mtAvatarChange;  {TextFunction: GetEventTextForAvatarChange}),
    (EventType: ICQEVENTTYPE_AUTH_GRANTED;       MessageType: mtSystem;        {TextFunction: GetEventTextForICQAuthGranted}),
    (EventType: ICQEVENTTYPE_AUTH_DENIED;        MessageType: mtSystem;        {TextFunction: GetEventTextForICQAuthDenied}),
    (EventType: ICQEVENTTYPE_SELF_REMOVE;        MessageType: mtSystem;        {TextFunction: GetEventTextForICQSelfRemove}),
    (EventType: ICQEVENTTYPE_FUTURE_AUTH;        MessageType: mtSystem;        {TextFunction: GetEventTextForICQFutureAuth}),
    (EventType: ICQEVENTTYPE_CLIENT_CHANGE;      MessageType: mtSystem;        {TextFunction: GetEventTextForICQClientChange}),
    (EventType: ICQEVENTTYPE_CHECK_STATUS;       MessageType: mtSystem;        {TextFunction: GetEventTextForICQCheckStatus}),
    (EventType: ICQEVENTTYPE_IGNORECHECK_STATUS; MessageType: mtSystem;        {TextFunction: GetEventTextForICQIgnoreCheckStatus}),
    (EventType: ICQEVENTTYPE_BROADCAST;          MessageType: mtSystem;        {TextFunction: GetEventTextForICQBroadcast}),
    (EventType: JABBER_DB_EVENT_TYPE_CHATSTATES; MessageType: mtStatus;        {TextFunction: GetEventTextForJabberChatStates}),
    (EventType: EVENTTYPE_CONTACTLEFTCHANNEL;    MessageType: mtStatus;        {TextFunction: GetEventTextForMessage}),
    (EventType: EVENTTYPE_WAT_REQUEST;           MessageType: mtWATrack;       {TextFunction: GetEventTextWATrackRequest}),
    (EventType: EVENTTYPE_WAT_ANSWER;            MessageType: mtWATrack;       {TextFunction: GetEventTextWATrackAnswer}),
    (EventType: EVENTTYPE_WAT_ERROR;             MessageType: mtWATrack;       {TextFunction: GetEventTextWATrackError}),
    (EventType: EVENTTYPE_VOICE_CALL;            MessageType: mtVoiceCall;     {TextFunction: GetEventTextForMessage})
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
    EventBuffer.Allocate(BlobSize+2); // cheat, for possible crash avoid
    EventInfo.pBlob := EventBuffer.Buffer;
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

function GetEventCoreText(EventInfo: TDBEventInfo; var Hi: THistoryItem): Boolean;
var
  dbegt: TDBEVENTGETTEXT;
  msg: pWideChar;
begin
  dbegt.dbei     := @EventInfo;
  dbegt.datatype := DBVT_WCHAR;
  dbegt.codepage := hi.Codepage;

  msg := pWideChar(CallService(MS_DB_EVENT_GETTEXT,0,LPARAM(@dbegt)));
  Result := Assigned(msg);

  if Result then
  begin
    StrDupW(hi.Text,msg,StrLenW(msg));
    mir_free(msg);
  end;
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
  i,len,lenW: Integer;
  pPos: PWideChar;
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
      IsWideCharAlphaNumeric((pPos + Length(UrlPrefix[i]))^);
    if Result then
      exit;
  end;

  // search in url protos like "http:/"

  if StrPosW(Text,':/') = nil then exit;

  lenW := (len+1)*SizeOf(WideChar);

  TextBuffer.Lock;
  TextBuffer.Allocate(lenW);

  Move(Text^,TextBuffer.Buffer^,lenW);

  CharLowerBuffW(PWideChar(TextBuffer.Buffer),len);
  for i := 0 to High(UrlProto) do
  begin
    pPos := StrPosW(PWideChar(TextBuffer.Buffer), UrlProto[i].proto);
    if not Assigned(pPos) then
      continue;
    Result := ((uint_ptr(pPos) = uint_ptr(TextBuffer.Buffer)) or
      not IsWideCharAlphaNumeric((pPos - 1)^));
    if Result then
      break;
  end;
  TextBuffer.Unlock;
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
procedure ReadEvent(hDBEvent: THandle; var hi: THistoryItem; UseCP: Cardinal = CP_ACP);
var
  EventInfo: TDBEventInfo;
  EventIndex: integer;
  Handled: Boolean;
begin
  ZeroMemory(@hi,SizeOf(hi));
  hi.Height := -1;
  EventBuffer.Lock;
  GetEventInfo(hDBEvent, EventInfo);

  hi.Module      := EventInfo.szModule;
  hi.proto       := nil;
  hi.Time        := EventInfo.Timestamp;
  hi.EventType   := EventInfo.EventType;
  hi.IsRead      := Boolean(EventInfo.flags and DBEF_READ);
  hi.MessageType := GetMessageType(EventInfo, EventIndex);
  hi.CodePage    := UseCP;
  // enable autoRTL feature
  if Boolean(EventInfo.flags and DBEF_RTL) then
    hi.RTLMode := hppRTLEnable;

  Handled := GetEventCoreText(EventInfo, hi);
{!!
  if not Handled then
    EventTable[EventIndex].TextFunction(EventInfo, hi);
}
  hi.Text := AdjustLineBreaks(hi.Text);
  hi.Text := rtrimw(hi.Text);

  if hi.MessageType.code=mtMessage then
    if TextHasUrls(hi.Text) then
    begin
      hi.MessageType.code:=mtUrl;
    end;

  EventBuffer.Unlock;
end;

procedure CheckRecent(hDBEvent: THandle);
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

function GetEventMessageType(hDBEvent: THandle): THppMessageType;
var
  EventIndex: Integer;
begin
  CheckRecent(hDBEvent);
  Result := GetMessageType(RecentEventInfo,EventIndex);
end;

function GetEventTimestamp(hDBEvent: THandle): DWord;
begin
  CheckRecent(hDBEvent);
  Result := RecentEventInfo.timestamp;
end;

function GetEventDateTime(hDBEvent: THandle): TDateTime;
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
  for mt := Low(EventRecords) to High(EventRecords) do
  begin
    if MesType.code = mt then
    begin
      Result := EventRecords[mt].Name;
      exit;
    end;
  end;

  etd := Pointer(CallService(MS_DB_EVENT_GETTYPE, WPARAM(Hi.Module), LPARAM(Hi.EventType)));
  if etd = nil then
  begin
    Result := EventRecords[mtOther].Name;
  end
  else
    Result := etd.descr;
end;

function GetEventIcon(const Hi: THistoryItem):HICON;
var
  idx:integer;
  MesType: THppMessageType;
  mt: TbuiltinMessageType;
begin
  idx:=-HPP_SKIN_OTHER_MIRANDA;

  MesType := Hi.MessageType;

  for mt := Low(EventRecords) to High(EventRecords) do
  begin
    if MesType.code = mt then
    begin
      idx := EventRecords[mt].idx;
      break;
    end;
  end;

  if idx = 9999 then
  begin
    result:=0;
    exit;
  end
  else if idx < 0 then
    result := skinIcons[-idx-1000].Handle
  else
    result := hppIcons[tHppIconName(idx)].Handle;

  if result = 0 then
    result := hppIcons[HPP_ICON_CONTACTHISTORY].Handle;
end;

function IsIncomingEvent(const Hi: THistoryItem):boolean;
begin
  result:=(Hi.MessageType.direction and mtIncoming)<>0; 
end;

function IsOutgoingEvent(const Hi: THistoryItem):boolean;
begin
  result:=(Hi.MessageType.direction and mtOutgoing)<>0; 
end;

initialization
  EventBuffer := THppBuffer.Create;
  TextBuffer  := THppBuffer.Create;

finalization
  EventBuffer.Destroy;
  TextBuffer.Destroy;

end.
