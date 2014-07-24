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

{ -----------------------------------------------------------------------------
  hpp_contacts (historypp project)

  Version:   1.0
  Created:   31.03.2003
  Author:    Oxygen

  [ Description ]

  Some helper routines for contacts

  [ History ]
  1.0 (31.03.2003) - Initial version

  [ Modifications ]

  [ Knows Inssues ]
  None

  Contributors: theMIROn, Art Fedorov
  ----------------------------------------------------------------------------- }

unit hpp_contacts;

interface

uses
  Windows,
  m_api,
  hpp_global;

function GetContactDisplayName(hContact: TMCONTACT; Proto: pAnsiChar = nil; Contact: boolean = false): PWideChar;
function GetContactProto(hContact: TMCONTACT): pAnsiChar; overload;
function GetContactProto(hContact: TMCONTACT; var SubContact: TMCONTACT; var SubProtocol: pAnsiChar): pAnsiChar; overload;
function GetContactID(hContact: TMCONTACT; Proto: pAnsiChar = nil; Contact: boolean = false): PAnsiChar;

function GetContactCodePage  (hContact: TMCONTACT; const Proto: pAnsiChar = nil): Cardinal; overload;
function GetContactCodePage  (hContact: TMCONTACT; const Proto: pAnsiChar; var UsedDefault: boolean): Cardinal; overload;
function WriteContactCodePage(hContact: TMCONTACT; CodePage: Cardinal; Proto: pAnsiChar = nil): boolean;

function GetContactRTLMode    (hContact: TMCONTACT; Proto: pAnsiChar = nil): boolean;
function GetContactRTLModeTRTL(hContact: TMCONTACT; Proto: pAnsiChar = nil): TRTLMode;
function WriteContactRTLMode  (hContact: TMCONTACT; RTLMode: TRTLMode; Proto: pAnsiChar = nil): boolean;

implementation

uses common, dbsettings;

function GetContactProto(hContact: TMCONTACT): pAnsiChar;
begin
  Result := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, hContact, 0));
end;

function GetContactProto(hContact: TMCONTACT; var SubContact: TMCONTACT; var SubProtocol: pAnsiChar): pAnsiChar;
begin
  Result := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, hContact, 0));
  if StrCmp(Result, META_PROTO)=0 then
  begin
    SubContact  := CallService(MS_MC_GETMOSTONLINECONTACT, hContact, 0);
    SubProtocol := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, SubContact, 0));
  end
  else
  begin
    SubContact  := hContact;
    SubProtocol := Result;
  end;
end;

function GetContactDisplayName(hContact: TMCONTACT; Proto: pAnsiChar = nil; Contact: boolean = false): PWideChar;
var
  ci: TContactInfo;
begin
  if (hContact = 0) and Contact then
    StrDupW(Result, TranslateW('Server'))
  else
  begin
    if Proto = nil then
      Proto := GetContactProto(hContact);
    if Proto = nil then
      StrDupW(Result, TranslateW('''(Unknown Contact)'''))
    else
    begin
      ci.cbSize   := SizeOf(ci);
      ci.hContact := hContact;
      ci.szProto  := Proto;
      ci.dwFlag   := CNF_DISPLAY + CNF_UNICODE;
      if CallService(MS_CONTACT_GETCONTACTINFO, 0, LPARAM(@ci)) = 0 then
      begin
        if StrCmpW(ci.retval.szVal.w, TranslateW('''(Unknown Contact)'''))=0 then
          AnsiToWide(GetContactID(hContact, Proto), Result, CP_ACP)
        else
          StrDupW(Result, ci.retval.szVal.w);
        mir_free(ci.retval.szVal.w);
      end
      else
        AnsiToWide(GetContactID(hContact, Proto), Result);

      if (Result = nil) or (Result^ = #0) then
        AnsiToWide(Translate(Proto), Result, hppCodepage);
    end;
  end;
end;

function GetContactID(hContact: TMCONTACT; Proto: pAnsiChar = nil; Contact: boolean = false): PAnsiChar;
var
  uid: PAnsiChar;
  dbv: TDBVARIANT;
  buf: array [0..15] of AnsiChar;
begin
  Result := nil;
  if not((hContact = 0) and Contact) then
  begin
    if Proto = nil then
      Proto := GetContactProto(hContact);
    uid := PAnsiChar(CallProtoService(Proto, PS_GETCAPS, PFLAG_UNIQUEIDSETTING, 0));
    if (int_ptr(uid) <> CALLSERVICE_NOTFOUND) and (uid <> nil) then
    begin
      // DBGetContactSettingStr comparing to DBGetContactSetting don't translate strings
      // when uType=0 (DBVT_ASIS)
      if DBGetContactSettingStr(hContact, Proto, uid, @dbv, DBVT_ASIS) = 0 then
      begin
        case dbv._type of
          DBVT_BYTE:   StrDup(Result, IntToStr(buf,dbv.bVal));
          DBVT_WORD:   StrDup(Result, IntToStr(buf,dbv.wVal));
          DBVT_DWORD:  StrDup(Result, IntToStr(buf,dbv.dVal));
          DBVT_ASCIIZ: StrDup(Result, dbv.szVal.a);
          DBVT_UTF8:   UTF8ToAnsi(dbv.szVal.a, Result, hppCodepage);
          DBVT_WCHAR:  WideToAnsi(dbv.szVal.w, Result, hppCodepage);
        end;
        // free variant
        DBFreeVariant(@dbv);
      end;
    end;
  end;
end;

function WriteContactCodePage(hContact: TMCONTACT; CodePage: Cardinal; Proto: pAnsiChar = nil): boolean;
begin
  Result := false;
  if Proto = nil then
    Proto := GetContactProto(hContact);
  if Proto = nil then
    exit;
  DBWriteWord(hContact, Proto, 'AnsiCodePage', CodePage);
  Result := True;
end;

function _GetContactCodePage(hContact: TMCONTACT; Proto: pAnsiChar; var UsedDefault: boolean) : Cardinal;
begin
  if Proto = nil then
    Proto := GetContactProto(hContact);
  if Proto = nil then
    Result := hppCodepage
  else
  begin
    Result := DBReadWord(hContact, Proto, 'AnsiCodePage', $FFFF);
    If Result = $FFFF then
      Result := DBReadWord(0, Proto, 'AnsiCodePage', CP_ACP);
    UsedDefault := (Result = CP_ACP);
    if UsedDefault then
      Result := GetACP();
  end;
end;

function GetContactCodePage(hContact: TMCONTACT; const Proto: pAnsiChar = nil): Cardinal;
var
  def: boolean;
begin
  Result := _GetContactCodePage(hContact, Proto, def);
end;

function GetContactCodePage(hContact: TMCONTACT; const Proto: pAnsiChar; var UsedDefault: boolean): Cardinal; overload;
begin
  Result := _GetContactCodePage(hContact, Proto, UsedDefault);
end;

// OXY: 2006-03-30
// Changed default RTL mode from SysLocale.MiddleEast to
// Application.UseRightToLeftScrollBar because it's more correct and
// doesn't bug on MY SYSTEM!
function GetContactRTLMode(hContact: TMCONTACT; Proto: pAnsiChar = nil): boolean;
var
  Temp: Byte;
begin
  if Proto = nil then
    Proto := GetContactProto(hContact);
  if Proto <> nil then
  begin
    Temp := DBReadByte(hContact, Proto, 'RTL', 255);
    if Temp <> 255 then
    begin
      result:=Temp<>0;
      exit;
    end;
  end;
  Result := DBReadByte(0,hppDBName, 'RTL', ORD(GetSystemMetrics(SM_MIDEASTENABLED)<>0))<>0;
//orig  Result := DBReadByte(0,hppDBName, 'RTL', Application.UseRightToLeftScrollBar)<>0;
end;

function WriteContactRTLMode(hContact: TMCONTACT; RTLMode: TRTLMode; Proto: pAnsiChar = nil): boolean;
begin
  Result := false;
  if Proto = nil then
    Proto := GetContactProto(hContact);
  if Proto = nil then
    exit;
  case RTLMode of
    hppRTLDefault: DBDeleteContactSetting(hContact, Proto, 'RTL');
    hppRTLEnable:  DBWriteByte(hContact, Proto, 'RTL', 1);
    hppRTLDisable: DBWriteByte(hContact, Proto, 'RTL', 0);
  end;
  Result := True;
end;

function GetContactRTLModeTRTL(hContact: TMCONTACT; Proto: pAnsiChar = nil): TRTLMode;
begin
  if Proto = nil then
    Proto := GetContactProto(hContact);
  if Proto = nil then
    Result := hppRTLDefault
  else
  begin
    case DBReadByte(hContact, Proto, 'RTL', 255) of
      0: Result := hppRTLDisable;
      1: Result := hppRTLEnable;
    else
      Result := hppRTLDefault;
    end;
  end;
end;

end.
