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
  hpp_global;

function GetContactDisplayName(hContact: THandle; Proto: AnsiString = ''; Contact: boolean = false): WideString;
function GetContactProto(hContact: THandle): AnsiString; overload;
function GetContactProto(hContact: THandle; var SubContact: THandle; var SubProtocol: AnsiString): AnsiString; overload;
function GetContactID(hContact: THandle; Proto: AnsiString = ''; Contact: boolean = false): AnsiString;
function GetContactCodePage(hContact: THandle; const Proto: AnsiString = ''): Cardinal; overload;
function GetContactCodePage(hContact: THandle; const Proto: AnsiString; var UsedDefault: boolean): Cardinal; overload;
function WriteContactCodePage(hContact: THandle; CodePage: Cardinal; Proto: AnsiString = ''): boolean;
function GetContactRTLMode(hContact: THandle; Proto: AnsiString = ''): boolean;
function GetContactRTLModeTRTL(hContact: THandle; Proto: AnsiString = ''): TRTLMode;
function WriteContactRTLMode(hContact: THandle; RTLMode: TRTLMode; Proto: AnsiString = ''): boolean;

implementation

uses hpp_options, m_api, common, dbsettings;

function GetContactProto(hContact: THandle): AnsiString;
begin
  Result := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, hContact, 0));
end;

function GetContactProto(hContact: THandle; var SubContact: THandle; var SubProtocol: AnsiString): AnsiString;
begin
  Result := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, hContact, 0));
  if MetaContactsExists and (Result = MetaContactsProto) then
  begin
    SubContact := CallService(MS_MC_GETMOSTONLINECONTACT, hContact, 0);
    SubProtocol := PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO, SubContact, 0));
  end
  else
  begin
    SubContact := hContact;
    SubProtocol := Result;
  end;
end;

function GetContactDisplayName(hContact: THandle; Proto: AnsiString = ''; Contact: boolean = false): WideString;
var
  ci: TContactInfo;
  RetPWideChar, UW: PWideChar;
begin
  if (hContact = 0) and Contact then
    Result := TranslateW('Server')
  else
  begin
    if Proto = '' then
      Proto := GetContactProto(hContact);
    if Proto = '' then
      Result := TranslateW('''(Unknown Contact)''' { TRANSLATE-IGNORE } )
    else
    begin
      ci.cbSize := SizeOf(ci);
      ci.hContact := hContact;
      ci.szProto := PAnsiChar(Proto);
      ci.dwFlag := CNF_DISPLAY + CNF_UNICODE;
      if CallService(MS_CONTACT_GETCONTACTINFO, 0, LPARAM(@ci)) = 0 then
      begin
        RetPWideChar := ci.retval.szVal.w;
        UW := TranslateW('''(Unknown Contact)''' { TRANSLATE-IGNORE } );
//kol        if AnsiCompareStrNoCase(RetPWideChar, UW) = 0 then)
        if StrCmpW(RetPWideChar,UW)=0 then
//orig        if WideCompareText(RetPWideChar, UW) = 0 then
          Result := AnsiToWideString(GetContactID(hContact, Proto), CP_ACP)
        else
          Result := RetPWideChar;
        mir_free(RetPWideChar);
      end
      else
        Result := WideString(GetContactID(hContact, Proto));
      if Result = '' then
        Result := TranslateAnsiW(Proto { TRANSLATE-IGNORE } );
    end;
  end;
end;

function GetContactID(hContact: THandle; Proto: AnsiString = ''; Contact: boolean = false): AnsiString;
var
  uid: PAnsiChar;
  dbv: TDBVARIANT;
  cgs: TDBCONTACTGETSETTING;
  tmp: WideString;
  buf: array [0..15] of AnsiChar;
begin
  Result := '';
  if not((hContact = 0) and Contact) then
  begin
    if Proto = '' then
      Proto := GetContactProto(hContact);
    uid := PAnsiChar(CallProtoService(PAnsiChar(Proto), PS_GETCAPS, PFLAG_UNIQUEIDSETTING, 0));
    if (Cardinal(uid) <> CALLSERVICE_NOTFOUND) and (uid <> nil) then
    begin
      cgs.szModule := PAnsiChar(Proto);
      cgs.szSetting := uid;
      cgs.pValue := @dbv;
      if CallService(MS_DB_CONTACT_GETSETTING, hContact, LPARAM(@cgs)) = 0 then
      begin
        case dbv._type of
          DBVT_BYTE: begin
            IntToStr(buf,dbv.bVal);
            Result := AnsiString(@buf);
          end;
          DBVT_WORD: begin
            IntToStr(buf,dbv.wVal);
            Result := AnsiString(@buf);
          end;
          DBVT_DWORD: begin
            IntToStr(buf,dbv.dVal);
            Result := AnsiString(@buf);
          end;
          DBVT_ASCIIZ:
            Result := AnsiString(dbv.szVal.a);
          DBVT_UTF8:
            begin
              tmp := AnsiToWideString(dbv.szVal.a, CP_UTF8);
              Result := WideToAnsiString(tmp, hppCodepage);
            end;
          DBVT_WCHAR:
            Result := WideToAnsiString(dbv.szVal.w, hppCodepage);
        end;
        // free variant
        DBFreeVariant(@dbv);
      end;
    end;
  end;
end;

function WriteContactCodePage(hContact: THandle; CodePage: Cardinal; Proto: AnsiString = ''): boolean;
begin
  Result := false;
  if Proto = '' then
    Proto := GetContactProto(hContact);
  if Proto = '' then
    exit;
  DBWriteWord(hContact, PAnsiChar(Proto), 'AnsiCodePage', CodePage);
  Result := True;
end;

function _GetContactCodePage(hContact: THandle; Proto: AnsiString; var UsedDefault: boolean) : Cardinal;
begin
  if Proto = '' then
    Proto := GetContactProto(hContact);
  if Proto = '' then
    Result := hppCodepage
  else
  begin
    Result := DBReadWord(hContact, PAnsiChar(Proto), 'AnsiCodePage', $FFFF);
    If Result = $FFFF then
      Result := DBReadWord(0, PAnsiChar(Proto), 'AnsiCodePage', CP_ACP);
    UsedDefault := (Result = CP_ACP);
    if UsedDefault then
      Result := GetACP();
  end;
end;

function GetContactCodePage(hContact: THandle; const Proto: AnsiString = ''): Cardinal;
var
  def: boolean;
begin
  Result := _GetContactCodePage(hContact, Proto, def);
end;

function GetContactCodePage(hContact: THandle; const Proto: AnsiString; var UsedDefault: boolean): Cardinal; overload;
begin
  Result := _GetContactCodePage(hContact, Proto, UsedDefault);
end;

// OXY: 2006-03-30
// Changed default RTL mode from SysLocale.MiddleEast to
// Application.UseRightToLeftScrollBar because it's more correct and
// doesn't bug on MY SYSTEM!
function GetContactRTLMode(hContact: THandle; Proto: AnsiString = ''): boolean;
var
  Temp: Byte;
begin
  if Proto = '' then
    Proto := GetContactProto(hContact);
  if Proto <> '' then
  begin
    Temp := DBReadByte(hContact, PAnsiChar(Proto), 'RTL', 255);
    if Temp <> 255 then
    begin
      result:=Temp<>0;
      exit;
    end;
  end;
  Result := DBReadByte(0,hppDBName, 'RTL', ORD(GetSystemMetrics(SM_MIDEASTENABLED)<>0))<>0;
//orig  Result := DBReadByte(0,hppDBName, 'RTL', Application.UseRightToLeftScrollBar)<>0;
end;

function WriteContactRTLMode(hContact: THandle; RTLMode: TRTLMode; Proto: AnsiString = ''): boolean;
begin
  Result := false;
  if Proto = '' then
    Proto := GetContactProto(hContact);
  if Proto = '' then
    exit;
  case RTLMode of
    hppRTLDefault: DBDeleteContactSetting(hContact, PAnsiChar(Proto), 'RTL');
    hppRTLEnable:  DBWriteByte(hContact, PAnsiChar(Proto), 'RTL', Byte(True));
    hppRTLDisable: DBWriteByte(hContact, PAnsiChar(Proto), 'RTL', Byte(false));
  end;
  Result := True;
end;

function GetContactRTLModeTRTL(hContact: THandle; Proto: AnsiString = ''): TRTLMode;
begin
  if Proto = '' then
    Proto := GetContactProto(hContact);
  if Proto = '' then
    Result := hppRTLDefault
  else
  begin
    case DBReadByte(hContact, PAnsiChar(Proto), 'RTL', 255) of
      0: Result := hppRTLDisable;
      1: Result := hppRTLEnable;
    else
      Result := hppRTLDefault;
    end;
  end;
end;

end.
