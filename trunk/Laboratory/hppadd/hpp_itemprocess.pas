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
 hpp_itemprocess (historypp project)

 Version:   1.5
 Created:   05.08.2004
 Author:    Oxygen

 [ Description ]

 Module for people to help get aquanted with ME_HPP_RICHEDIT_ITEMPROCESS
 Has samples for SmileyAdd, TextFormat, Math Module and new procedure
 called SeparateDialogs. It makes message black if previous was hour ago,
 kinda of conversation separation

 [ History ]

 1.5 (05.08.2004)
   First version

 [ Modifications ]
 none

 [ Known Issues ]
 none

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}

unit hpp_itemprocess;

interface

uses
  Windows, m_api;

const
  rtf_ctable_text = 
    '\red0\green0\blue0;'+
    '\red0\green0\blue255;'+
    '\red0\green255\blue0;'+
    '\red255\green0\blue0;'+
    '\red255\green0\blue255;'+
    '\red0\green255\blue255;'+
    '\red255\green255\blue0;'+
    '\red255\green255\blue255;';

//var  rtf_ctable_text: AnsiString;

// HTML export
function DoSupportBBCodesHTML(const S: PAnsiChar): PAnsiChar;

function DoSupportBBCodesRTF (const S: PAnsiChar; StartColor: integer; doColorBBCodes: boolean): PAnsiChar;
// XML/text export / speak
function DoStripBBCodes      (const S: PWideChar): PWideChar;

function DoSupportSmileys      (awParam:WPARAM; alParam: LPARAM): Integer;
//function DoSupportMathModule   (awParam:WPARAM; alParam: LPARAM): Integer;
function DoSupportAvatarHistory(awParam:WPARAM; alParam: LPARAM): Integer;

function AllHistoryRichEditProcess(wParam { hRichEdit } : WPARAM; lParam { PItemRenderDetails } : LPARAM): Int; cdecl;

implementation

uses
  Messages,
{  RichEdit, -- used for CHARRANGE and EM_EXTSETSEL}
  common,
  my_rtf,
  my_GridOptions, // SmileyAddEnable, AvatarHistoryEnabled
  hpp_richedit,
  hpp_global;

const
  EM_EXSETSEL = WM_USER + 55; // from RichEdit

type
  TRTFColorTable = record
    sz : PAnsiChar;
    col: TCOLORREF;
  end;

const
  rtf_ctable: array[0..7] of TRTFColorTable = (
    //                 BBGGRR
    (sz:'black';  col:$000000),
    (sz:'blue';   col:$FF0000),
    (sz:'green';  col:$00FF00),
    (sz:'red';    col:$0000FF),
    (sz:'magenta';col:$FF00FF),
    (sz:'cyan';   col:$FFFF00),
    (sz:'yellow'; col:$00FFFF),
    (sz:'white';  col:$FFFFFF));

type
  TBBCodeClass = (bbStart,bbEnd);
  TBBCodeType = (bbSimple, bbColor, bbSize, bbUrl, bbImage);

  PBBCodeInfo = ^TBBCodeInfo;
  TBBCodeInfo = record
    prefix: PAnsiChar;
    suffix: PAnsiChar;
    bbtype: TBBCodeType;
    rtf   : PAnsiChar;
    html  : PAnsiChar;
  end;

const
  bbCodesCount = 8;

  bbCodes: array[0..bbCodesCount-1, bbStart..bbEnd] of TBBCodeInfo = (
    ((prefix:'[b]';      suffix:nil; bbtype:bbSimple; rtf:'{\b ';      html:'<b>'),
     (prefix:'[/b]';     suffix:nil; bbtype:bbSimple; rtf:'}';         html:'</b>')),

    ((prefix:'[i]';      suffix:nil; bbtype:bbSimple; rtf:'{\i ';      html:'<i>'),
     (prefix:'[/i]';     suffix:nil; bbtype:bbSimple; rtf:'}';         html:'</i>')),

    ((prefix:'[u]';      suffix:nil; bbtype:bbSimple; rtf:'{\ul ';     html:'<u>'),
     (prefix:'[/u]';     suffix:nil; bbtype:bbSimple; rtf:'}';         html:'</u>')),

    ((prefix:'[s]';      suffix:nil; bbtype:bbSimple; rtf:'{\strike '; html:'<s>'),
     (prefix:'[/s]';     suffix:nil; bbtype:bbSimple; rtf:'}';         html:'</s>')),

    ((prefix:'[color=';  suffix:']'; bbtype:bbColor;  rtf:'{\cf%u ';   html:'<font style="color:%s">'),
     (prefix:'[/color]'; suffix:nil; bbtype:bbSimple; rtf:'}';         html:'</font>')),

    ((prefix:'[url=';    suffix:']'; bbtype:bbUrl;    rtf:'{\field{\*\fldinst{HYPERLINK ":%s"}}{\fldrslt{\ul\cf%u'; html:'<a href="%s">'),
     (prefix:'[/url]';   suffix:nil; bbtype:bbSimple; rtf:'}}}';      html:'</a>')),

    ((prefix:'[size=';   suffix:']'; bbtype:bbSize;   rtf:'{\fs%u ';   html:'<font style="font-size:%spt">'),
     (prefix:'[/size]';  suffix:nil; bbtype:bbSimple; rtf:'}';         html:'</font>')),

    ((prefix:'[img]';    suffix:nil; bbtype:bbImage;  rtf:'[{\revised\ul\cf%u '; html:'['),
     (prefix:'[/img]';   suffix:nil; bbtype:bbSimple; rtf:'}]';        html:']'))
  );

var
  TextBuffer: THppBuffer;

function GetColorRTF(code: PAnsiChar; colcount: integer): integer;
var
  i: integer;
begin
  Result := 0;
  if colcount >= 0 then
    for i := 0 to High(rtf_ctable) do
      if StrCmp(rtf_ctable[i].sz, code)=0 then
      begin
        Result := colcount + i;
        break;
      end;
end;

function StrReplace(strStart, str, strEnd: PAnsiChar; var strTrail: PAnsiChar): PAnsiChar;
var
  len,delta: integer;
  tmpStartPos,tmpEndPos,tmpTrailPos: Integer;
  tmpStart,tmpEnd,tmpTrail: PAnsiChar;
begin
  if str = nil then
    len := 0
  else
    len := StrLen(str);
  delta := len - (strTrail - strStart);
  tmpStartPos := strStart - TextBuffer.Buffer;
  tmpTrailPos := strTrail - TextBuffer.Buffer;
  tmpEndPos   := strEnd - TextBuffer.Buffer;
  TextBuffer.Reallocate(tmpEndPos + delta + 1);
  tmpStart := PAnsiChar(TextBuffer.Buffer) + tmpStartPos;
  tmpTrail := PAnsiChar(TextBuffer.Buffer) + tmpTrailPos;
  tmpEnd   := PAnsiChar(TextBuffer.Buffer) + tmpEndPos;
  strTrail := tmpTrail + delta;

  StrCopy(strTrail, tmpTrail, tmpEnd - tmpTrail + 1);
  if len > 0 then
    StrCopy(tmpStart, str, len);

  Result := tmpEnd + delta;
end;

function StrAppend(str, strEnd: PAnsiChar): PAnsiChar;
var
  len: integer;
  tmpEndPos: integer;
  tmpEnd: PAnsiChar;
begin
  if str = nil then
  begin
    Result := strEnd;
    exit;
  end;
  len := StrLen(str);
  tmpEndPos := strEnd - TextBuffer.Buffer;
  TextBuffer.Reallocate(tmpEndPos + len + 1);
  tmpEnd := PAnsiChar(TextBuffer.Buffer) + tmpEndPos;
  StrCopy(tmpEnd, str, len + 1);
  Result := tmpEnd + len;
end;

function StrSearch(str,prefix,suffix: PAnsiChar; var strStart,strEnd,strCode: PAnsiChar; var lenCode: integer): Boolean;
begin
  Result := false;
  strStart := StrPos(str, prefix);
  if strStart = nil then
    exit;
  strCode := strStart + StrLen(prefix);
  lenCode := 0;
  if suffix = nil then
  begin
    strEnd := strCode
  end
  else
  begin
    strEnd := StrPos(strCode, suffix);
    if strEnd = nil then
      exit;
    lenCode := strEnd - strCode;
    strEnd := strEnd + StrLen(suffix);
  end;
  Result := true;
end;

(* commented out fo future use
function ParseLinksInRTF(S: AnsiString): AnsiString;
const
  urlStopChars = [' ','{','}','\','[',']'];
  url41fmt = '{\field{\*\fldinst{HYPERLINK "%s"}}{\fldrslt{{\v #}\ul\cf1 %0:s}}}';
var
  bufPos,bufEnd: PAnsiChar;
  urlStart,urlEnd: PAnsiChar;
  newCode: PAnsiChar;
  fmt_buffer: array[0..MAX_FMTBUF] of AnsiChar;
  code: AnsiString;
begin
  ShrinkTextBuffer;
  AllocateTextBuffer(Length(S)+1);
  bufEnd := StrECopy(buffer,PAnsiChar(S));
  bufPos := StrPos(buffer,'://');
  while Assigned(bufPos) do begin
    urlStart := bufPos;
    urlEnd := bufPos+3;
    while urlStart > buffer do begin
      Dec(urlStart);
      if urlStart[0] in urlStopChars then begin
        Inc(urlStart);
        break;
      end;
    end;
    while urlEnd < bufEnd do begin
      Inc(UrlEnd);
      if urlEnd[0] in urlStopChars then break;
    end;
    if (urlStart<bufPos) and (urlEnd>bufPos+3) then begin
      SetString(code,urlStart,urlEnd-urlStart);
      newCode := StrLFmt(fmt_buffer,MAX_FMTBUF,url41fmt,[code]);
      bufEnd := StrReplace(urlStart,newCode,bufEnd,urlEnd);
      bufPos := urlEnd;
    end;
    bufPos := StrPos(bufPos,'://');
  end;
  SetString(Result,buffer,bufEnd-buffer);
end;
*)

function DoSupportBBCodesRTF(const S: PAnsiChar; StartColor: integer; doColorBBCodes: boolean): PAnsiChar;
var
  fmt_buffer: array[0..127] of AnsiChar;
  code: PAnsiChar;
  bufPos,bufEnd: PAnsiChar;
  strStart,strTrail: PAnsiChar;
  strCode,newCode: PAnsiChar;
  BBSCode,BBECode: PBBCodeInfo;
  i,n,lenCode: Integer;
  sfound,efound: Boolean;
begin
  TextBuffer.Lock;
  TextBuffer.Allocate(StrLen(S)+1);
  bufEnd := StrCopyE(TextBuffer.Buffer,S);

  for i := 0 to High(bbCodes) do
  begin
    bufPos := TextBuffer.Buffer;
    BBSCode := @bbCodes[i, bbStart];
    BBECode := @bbCodes[i, bbEnd];
    repeat
      newCode := nil;
      sfound := StrSearch(TextBuffer.Buffer,
          BBSCode.prefix,
          BBSCode.suffix,
          strStart, strTrail, strCode, lenCode);

      if sfound then
      begin
        case BBSCode.bbtype of
          bbSimple:
            newCode := BBSCode.rtf;

          bbColor: begin
            if doColorBBCodes then
            begin
              StrCopy(fmt_buffer, strCode, lenCode);
              n := GetColorRTF(fmt_buffer, StartColor);
              newCode := FormatSimple(BBSCode.rtf, [n]);
            end;
          end;

          bbSize: begin
            StrCopy(fmt_buffer, strCode, lenCode);
            n:=StrToInt(fmt_buffer);
            newCode := FormatSimple(BBSCode.rtf, [n shl 1]);
          end;

          bbUrl: begin
            StrDup(code, strCode, lenCode);
            if doColorBBCodes then
              n := 2
            else // link color
              n := 0;
            newCode := FormatSimple(BBSCode.rtf, [code, n]);
            mFreeMem(code);
          end;

          bbImage: begin
            if doColorBBCodes then
              n := 2
            else // link color
              n := 0;
            newCode := FormatSimple(BBSCode.rtf, [n]);
          end;
        end;

        bufEnd := StrReplace(strStart, newCode, bufEnd, strTrail);
        bufPos := strTrail;

        if BBSCode.bbtype<>bbSimple then
          mFreeMem(newCode);
      end;

      repeat
        efound := StrSearch(bufPos,
            BBECode.prefix,
            BBECode.suffix,
            strStart, strTrail, strCode, lenCode);
        if sfound and (newCode <> nil) then
          strCode := BBECode.rtf
        else
          strCode := nil;
        if efound then
        begin
          bufEnd := StrReplace(strStart, strCode, bufEnd, strTrail);
          bufPos := strTrail;
        end
        else
          bufEnd := StrAppend(strCode, bufEnd);
      until sfound or not efound;

    until not sfound;
  end;

  StrDup(Result, PAnsiChar(TextBuffer.Buffer), bufEnd - TextBuffer.Buffer);
  TextBuffer.Unlock;
end;

function DoSupportBBCodesHTML(const S: PAnsiChar): PAnsiChar;
var
  bufPos,bufEnd: PAnsiChar;
  code: PAnsiChar;
  strStart,strTrail,strCode: PAnsiChar;
  BBSCode,BBECode: PBBCodeInfo;
  i,lenCode: Integer;
  sfound,efound: Boolean;

begin
  TextBuffer.Lock;
  TextBuffer.Allocate(StrLen(S) + 1);
  bufEnd := StrCopyE(TextBuffer.Buffer, S);

  for i := 0 to High(bbCodes) do
  begin
    bufPos := TextBuffer.Buffer;
    BBSCode := @bbCodes[i, bbStart];
    BBECode := @bbCodes[i, bbEnd];
    repeat
      sfound := StrSearch(TextBuffer.Buffer,
          BBSCode.prefix,
          BBSCode.suffix,
          strStart, strTrail, strCode, lenCode);

      if sfound then
      begin
        if BBSCode.bbtype = bbSimple then
          strCode := BBSCode.html
        else
        begin
          StrDup(code, strCode, lenCode);
          strCode := FormatStr(BBSCode.html, [code]);
          mFreeMem(code);
        end;
        bufEnd := StrReplace(strStart, strCode, bufEnd, strTrail);
        bufPos := strTrail;

        if BBSCode.bbtype <> bbSimple then
          mFreeMem(strCode);
      end;

      repeat
        efound := StrSearch(bufPos,
            BBECode.prefix,
            BBECode.suffix,
            strStart, strTrail, strCode, lenCode);
        if sfound then
          strCode := BBECode.html
        else
          strCode := nil;
        if efound then
        begin
          bufEnd := StrReplace(strStart, strCode, bufEnd, strTrail);
          bufPos := strTrail;
        end
        else
          bufEnd := StrAppend(strCode, bufEnd);
      until sfound or not efound;
    until not sfound;
  end;

  StrDup(Result,PAnsiChar(TextBuffer.Buffer),bufEnd-TextBuffer.Buffer);
  TextBuffer.Unlock;
end;

function DoStripBBCodes(const S: PWideChar): PWideChar;
var
  BBCode:PBBCodeInfo;
  spos,epos:PWideChar;
  WideStream: PWideChar;
  wprefix,wsuffix:array [0..127] of WideChar;
  i,slen,elen: integer;
  bbClass: TBBCodeClass;
begin
  StrDupW(WideStream, S);
  for i := 0 to High(bbCodes) do
    for bbClass := bbStart to bbEnd do
    begin
      BBCode:=@bbCodes[i, bbClass];

      FastAnsiToWideBuf(BBCode.prefix, wprefix);
      slen := StrLenW(wprefix);

      if BBCode.bbtype = bbSimple then
      begin
        repeat
          spos := StrPosW(WideStream, wprefix);
          if spos = nil then break;
          StrCopyW(spos, spos + slen);
        until false;
      end
      else
      begin
        elen := StrLen(BBCode.suffix);
        if elen>0 then
          FastAnsiToWideBuf(BBCode.suffix, wsuffix);
        repeat
          spos := StrPosW(WideStream, wprefix); // start of BBCode
          if spos = nil then
            break;
          epos := spos + slen; // start of BBCode parameters
          if elen <> 0 then
          begin
            epos := StrPosW(epos, wsuffix); // position of end of BBCode
            if epos = nil then // tag not closed
              break;
            inc(epos, elen); // end of BBcode
          end;
          StrCopyW(spos, epos);
        until false;
      end;
    end;
  Result := WideStream;
end;

function DoSupportSmileys(awParam{hRichEdit}:WPARAM; alParam{PItemRenderDetails}: LPARAM): Integer;
const
  mesSent: Array[False..True] of Integer = (0,SAFLRE_OUTGOING);
var
  sare: TSMADD_RICHEDIT3;
  ird: PItemRenderDetails;
begin
  ird := Pointer(alParam);
  sare.cbSize              := SizeOf(sare);
  sare.hwndRichEditControl := awParam;
  sare.rangeToReplace      := nil;
  sare.ProtocolName        := ird^.pProto;
  //sare.flags := SAFLRE_INSERTEMF + mesSent[ird^.IsEventSent];
  sare.flags               := mesSent[ird^.IsEventSent] or SAFLRE_FIREVIEW;
  sare.disableRedraw       := True;
  sare.hContact            := ird^.hContact;
  CallService(MS_SMILEYADD_REPLACESMILEYS,0,LPARAM(@sare));
  Result := 0;
end;

(*
function DoSupportMathModule(awParam{hRichEdit}:WPARAM; alParam{PItemRenderDetails}: LPARAM): Integer;
var
  mrei: TMathRicheditInfo;
begin
  mrei.hwndRichEditControl := awParam;
  mrei.sel := nil;
  mrei.disableredraw := integer(false);
  Result := CallService(MATH_RTF_REPLACE_FORMULAE,0,LPARAM(@mrei));
end;
*)
(*
function DoSupportAvatars(wParam:WPARAM; lParam: LPARAM): Integer;
const
  crlf: AnsiString = '{\line }';
var
  ird: PItemRenderDetails;
  ave: PAvatarCacheEntry;
  msglen: integer;
begin
  ird := Pointer(lParam);
  ave := Pointer(CallService(MS_AV_GETAVATARBITMAP,ird.hContact,0));
  if (ave <> nil) and (ave.hbmPic <> 0) then begin
    msglen := SendMessage(wParam,WM_GETTEXTLENGTH,0,0);
    SendMessage(wParam,EM_SETSEL,msglen,msglen);
    SetRichRTF(wParam,crlf,True,False,True);
    InsertBitmapToRichEdit(wParam,ave.hbmPic);
  end;
  Result := 0;
end;
*)

function DoSupportAvatarHistory(awParam:WPARAM; alParam: LPARAM): int;
var
  ird: PItemRenderDetails;
  pc,Link: PAnsiChar;
  hBmp: hBitmap;
  cr: CHARRANGE;
  hppProfileDir:array [0..MAX_PATH-1] of AnsiChar;
begin
  Result := 0;
  ird := Pointer(alParam);

  if ird.wEventType <> EVENTTYPE_AVATAR_CHANGE then
    exit;

  if (ird.pExtended = nil) or (StrLen(ird.pExtended) < 4) then
    exit;

  if ((ird.pExtended[0] = '\') and (ird.pExtended[1] = '\')) or
     ((ird.pExtended[0] in ['A' .. 'Z', 'a' .. 'z']) and (ird.pExtended[1] = ':') and
      (ird.pExtended[2] = '\')) then
    Link := ird.pExtended
  else
  begin
    // Get profile dir
    CallService(MS_DB_GETPROFILEPATH, MAX_PATH, LPARAM(@hppProfileDir));
    mGetMem(Link,StrLen(hppProfileDir)+StrLen(ird.pExtended)+2);
    pc:=StrCopyE(Link,hppProfileDir); pc^ := '\'; inc(pc);
    StrCopy(pc,ird.pExtended);
  end;

  hBmp := CallService(MS_UTILS_LOADBITMAP, 0, LPARAM(Link));
  if Link<>ird.pExtended then mFreeMem(Link);
  if hBmp <> 0 then
  begin
    cr.cpMin := SendMessage(awParam, WM_GETTEXTLENGTH, 0, 0);
    cr.cpMax := cr.cpMin;
    SendMessage(awParam, EM_EXSETSEL, 0, LPARAM(@cr));
    SetRichRTFA(awParam, '{\rtf1{\line }}', true, false, true);
    RichEdit_InsertBitmap(awParam, hBmp, Cardinal(-1));
  end;
end;

// our own processing of RichEdit for all history windows
function AllHistoryRichEditProcess(wParam { hRichEdit } : WPARAM; lParam { PItemRenderDetails } : LPARAM): Int; cdecl;
begin
  Result := 0;
  if GridOptions.SmileysEnabled        then Result := Result or DoSupportSmileys(wParam, lParam);
  if GridOptions.AvatarsHistoryEnabled then Result := Result or DoSupportAvatarHistory(wParam, lParam);
end;

initialization
  TextBuffer := THppBuffer.Create;

finalization
  TextBuffer.Destroy;

end.
