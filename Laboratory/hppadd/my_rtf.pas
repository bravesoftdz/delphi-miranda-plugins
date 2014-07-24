unit my_rtf;

interface

uses
  richedit,
  windows;

//function InitRichEditLibrary: Integer;

//used for Export only
function GetRichRTFW(RichEditHandle: THANDLE; var RTFStream: PWideChar;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
function GetRichRTFA(RichEditHandle: THANDLE; var RTFStream: PAnsiChar;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;

function GetRichString(RichEditHandle: THANDLE; SelectionOnly: Boolean = false): PWideChar;

function SetRichRTFW(RichEditHandle: THANDLE; const RTFStream: PWideChar;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
function SetRichRTFA(RichEditHandle: THANDLE; const RTFStream: PAnsiChar;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;

function FormatString2RTFW(Source: PWideChar; Suffix: PAnsiChar = nil): PAnsiChar;
function FormatString2RTFA(Source: PAnsiChar; Suffix: PAnsiChar = nil): PAnsiChar;

procedure ReplaceCharFormatRange(RichEditHandle: THANDLE;
     const fromCF, toCF: CHARFORMAT2; idx, len: Integer);
procedure ReplaceCharFormat(RichEditHandle: THANDLE; const fromCF, toCF: CHARFORMAT2);

function GetTextLength(RichEditHandle:THANDLE): Integer;

function GetTextRange(RichEditHandle:THANDLE; cpMin,cpMax: Integer): PWideChar;

implementation

uses
  common,
  hpp_global; // AnsiToWideString, WideToAnsiString

type
  PTextStream = ^TTextStream;
  TTextStream = record
    Size: Integer;
    case Boolean of
      false: (Data:  PAnsiChar);
      true:  (DataW: PWideChar);
  end;
{
var
  FRichEditModule:  THANDLE = 0;
  FRichEditVersion: Integer = 0;

function GetModuleVersionFile(hModule: THANDLE): Integer;
var
  dwVersion: Cardinal;
begin
  Result := -1;
  if hModule = 0 then exit;
  try
    dwVersion := GetFileVersion(GetModuleName(hModule));
    if dwVersion <> Cardinal(-1) then
      Result := LoWord(dwVersion);
  except
  end;
end;

function InitRichEditLibrary: Integer;
const
  RICHED20_DLL = 'RICHED20.DLL';
  MSFTEDIT_DLL = 'MSFTEDIT.DLL';
var
  hModule : THANDLE;
  hVersion: Integer;

  emError : DWord;
begin
  if FRichEditModule = 0 then
  begin
    FRichEditVersion := -1;
    emError := SetErrorMode(SEM_NOOPENFILEERRORBOX);
    try
      FRichEditModule := LoadLibrary(RICHED20_DLL);
      if FRichEditModule <= HINSTANCE_ERROR then
        FRichEditModule := 0;
      if FRichEditModule <> 0 then
        FRichEditVersion := GetModuleVersionFile(FRichEditModule);

      repeat
        if FRichEditVersion > 40 then
          break;
        hModule := LoadLibrary(MSFTEDIT_DLL);
        if hModule <= HINSTANCE_ERROR then
          hModule := 0;
        if hModule <> 0 then
        begin
          hVersion := GetModuleVersionFile(hModule);
          if hVersion > FRichEditVersion then
          begin
            if FRichEditModule <> 0 then
              FreeLibrary(FRichEditModule);
            FRichEditModule := hModule;
            FRichEditVersion := hVersion;
            break;
          end;
          FreeLibrary(hModule);
        end;
      until True;

      if (FRichEditModule <> 0) and (FRichEditVersion = 0) then
        FRichEditVersion := 20;
    finally
      SetErrorMode(emError);
    end;
  end;
  Result := FRichEditVersion;
end;
}
function RichEditStreamLoad(dwCookie: DWORD_PTR; pbBuff: PByte; cb: Longint; var pcb: Longint): dword; stdcall;
var
  pBuff: PAnsiChar;
begin
  with PTextStream(dwCookie)^ do
  begin
    pBuff := Data;
    pcb := Size;
    if pcb > cb then
      pcb := cb;
    Move(pBuff^, pbBuff^, pcb);
    Inc(Data, pcb);
    Dec(Size, pcb);
  end;
  Result := 0;
end;

function RichEditStreamSave(dwCookie: DWORD_PTR; pbBuff: PByte; cb: Longint; var pcb: Longint): dword; stdcall;
var
  prevSize: Integer;
begin
  with PTextStream(dwCookie)^ do
  begin
    prevSize := Size;
    Inc(Size,cb);
    ReallocMem(Data,Size);
    Move(pbBuff^,(Data+prevSize)^,cb);
    pcb := cb;
  end;
  Result := 0;
end;

function _GetRichRTF(RichEditHandle: THANDLE; TextStream: PTextStream;
                    SelectionOnly, PlainText, NoObjects, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  Format: Longint;
begin
  format := 0;
  if SelectionOnly then
    Format := Format or SFF_SELECTION;
  if PlainText then
  begin
    if NoObjects then
      Format := Format or SF_TEXT
    else
      Format := Format or SF_TEXTIZED;
    if Unicode then
      Format := Format or SF_UNICODE;
  end
  else
  begin
    if NoObjects then
      Format := Format or SF_RTFNOOBJS
    else
      Format := Format or SF_RTF;
    if PlainRTF then
      Format := Format or SFF_PLAINRTF;
    // if Unicode then   format := format or SF_USECODEPAGE or (CP_UTF16 shl 16);
  end;
  TextStream^.Size := 0;
  TextStream^.Data := nil;
  es.dwCookie := DWORD_PTR(TextStream);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamSave;
  SendMessage(RichEditHandle, EM_STREAMOUT, format, LPARAM(@es));
  Result := es.dwError;
end;

function GetRichRTFW(RichEditHandle: THANDLE; var RTFStream: PWideChar;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Result := _GetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, NoObjects, PlainRTF, PlainText);
  if Assigned(Stream.DataW) then
  begin
    if PlainText then
      StrDupW(RTFStream, Stream.DataW, Stream.Size div SizeOf(WideChar))
    else
      AnsiToWide(Stream.Data, RTFStream, CP_ACP);
    FreeMem(Stream.Data, Stream.Size);
  end
  else
    RTFStream := nil;
end;

function GetRichRTFA(RichEditHandle: THANDLE; var RTFStream: PAnsiChar;
                    SelectionOnly, PlainText, NoObjects, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Result := _GetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, NoObjects, PlainRTF, False);
  if Assigned(Stream.Data) then
  begin
    StrDup(RTFStream, Stream.Data, Stream.Size - 1);
    FreeMem(Stream.Data, Stream.Size);
  end
  else
    RTFStream := nil;
end;

function GetRichString(RichEditHandle: THANDLE; SelectionOnly: Boolean = false): PWideChar;
begin
  GetRichRTFW(RichEditHandle,Result,SelectionOnly,True,True,False);
end;


function _SetRichRTF(RichEditHandle: THANDLE; TextStream: PTextStream;
                    SelectionOnly, PlainText, PlainRTF, Unicode: Boolean): Integer;
var
  es: TEditStream;
  Format: Longint;
begin
  Format := 0;
  if SelectionOnly then
    Format := Format or SFF_SELECTION;
  if PlainText then
  begin
    Format := Format or SF_TEXT;
    if Unicode then
      Format := Format or SF_UNICODE;
  end
  else
  begin
    Format := Format or SF_RTF;
    if PlainRTF then
      Format := Format or SFF_PLAINRTF;
    // if Unicode then  format := format or SF_USECODEPAGE or (CP_UTF16 shl 16);
  end;
  es.dwCookie := LPARAM(TextStream);
  es.dwError := 0;
  es.pfnCallback := @RichEditStreamLoad;
  SendMessage(RichEditHandle, EM_STREAMIN, format, LPARAM(@es));
  Result := es.dwError;
end;

function SetRichRTFW(RichEditHandle: THANDLE; const RTFStream: PWideChar;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
  Buffer: PAnsiChar;
begin
  if PlainText then
  begin
    Stream.DataW := RTFStream;
    Stream.Size  := StrLenW(RTFStream) * SizeOf(WideChar);
    Buffer := nil;
  end
  else
  begin
    WideToAnsi(RTFStream, Buffer, CP_ACP);
    Stream.Data := Buffer;
    Stream.Size := StrLen(Buffer);
  end;
  Result := _SetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, PlainRTF, PlainText);
  mFreeMem(Buffer);
end;

function SetRichRTFA(RichEditHandle: THANDLE; const RTFStream: PAnsiChar;
                    SelectionOnly, PlainText, PlainRTF: Boolean): Integer;
var
  Stream: TTextStream;
begin
  Stream.Data := RTFStream;
  Stream.Size := StrLen(RTFStream);
  Result := _SetRichRTF(RichEditHandle, @Stream,
                        SelectionOnly, PlainText, PlainRTF, False);
end;

function FormatString2RTFW(Source: PWideChar; Suffix: PAnsiChar = nil): PAnsiChar;
var
  Text: PWideChar;
  res: PAnsiChar;
  buf: array [0..15] of AnsiChar;
  len: integer;
begin
  // calculate len
  len:=Length('{\uc1 ');
  Text := PWideChar(Source);
  while Text[0] <> #0 do
  begin
    if (Text[0] = #13) and (Text[1] = #10) then
    begin
      inc(len,Length('\par '));
      Inc(Text);
    end
    else
      case Text[0] of
        #10: inc(len,Length('\par '));
        #09: inc(len,Length('\tab '));
        '\', '{', '}':
          inc(len,2);
      else
        if Word(Text[0]) < 128 then
          inc(len)
        else
          inc(len,3+IntStrLen(Word(Text[0]),10));
      end;
    Inc(Text);
  end;
  inc(len,StrLen(Suffix)+2);

  // replace
  Text := PWideChar(Source);
  GetMem(Result,len);
  res:=StrCopyE(Result,'{\uc1 ');
  while Text[0] <> #0 do
  begin
    if (Text[0] = #13) and (Text[1] = #10) then
    begin
      res:=StrCopyE(res,'\par ');
      Inc(Text);
    end
    else
      case Text[0] of
        #10: res:=StrCopyE(res,'\par ');
        #09: res:=StrCopyE(res,'\tab ');
        '\', '{', '}': begin
          res^:='\'; inc(res);
          res^:=AnsiChar(Text[0]); inc(res);
        end;
      else
        if Word(Text[0]) < 128 then
        begin
          res^:=AnsiChar(Word(Text[0])); inc(res);
        end
        else
        begin
          res:=StrCopyE(
            StrCopyE(res,'\u'),
            IntToStr(buf,Word(Text[0])));
          res^:='?'; inc(res);
        end;
      end;
    Inc(Text);
  end;

  res:=StrCopyE(res, Suffix);
  res^:='}'; inc(res); res^:=#0;
end;

function FormatString2RTFA(Source: PAnsiChar; Suffix: PAnsiChar = nil): PAnsiChar;
var
  Text,res: PAnsiChar;
  len: integer;
begin
  // calculate len
  len:=1;
  Text := PAnsiChar(Source);
  while Text[0] <> #0 do
  begin
    if (Text[0] = #13) and (Text[1] = #10) then
    begin
      inc(len,Length('\line '));
      Inc(Text);
    end
    else
      case Text[0] of
        #10: inc(len,Length('\line '));
        #09: inc(len,Length('\tab '));
        '\', '{', '}':
          inc(len,2);
      else
        inc(len);
      end;
    Inc(Text);
  end;
  inc(len,StrLen(Suffix)+2);

  // replace
  Text := PAnsiChar(Source);
  GetMem(Result,len);
  res:=Result;
  res^ := '{'; inc(res);
  while Text[0] <> #0 do
  begin
    if (Text[0] = #13) and (Text[1] = #10) then
    begin
      res:=StrCopyE(res,'\line ');
      Inc(Text);
    end
    else
      case Text[0] of
        #10: res:=StrCopyE(res,'\line ');
        #09: res:=StrCopyE(res,'\tab ');
        '\', '{', '}': begin
          res^:='\'; inc(res);
          res^:=Text[0]; inc(res);
        end;
      else
        res^:=Text[0]; inc(res);
      end;
    Inc(Text);
  end;

  res:=StrCopyE(res, Suffix);
  res^:='}'; inc(res); res^:=#0;
end;

function GetTextLength(RichEditHandle: THANDLE): Integer;
var
  gtxl: GETTEXTLENGTHEX;
begin
  gtxl.flags    := GTL_DEFAULT or GTL_PRECISE;
  gtxl.codepage := 1200; // Unicode
  gtxl.flags    := gtxl.flags or GTL_NUMCHARS;
  Result := SendMessage(RichEditHandle, EM_GETTEXTLENGTHEX, WPARAM(@gtxl), 0);
end;

procedure ReplaceCharFormatRange(RichEditHandle: THANDLE;
     const fromCF, toCF: CHARFORMAT2; idx, len: Integer);
var
  cr: CHARRANGE;
  cf: CHARFORMAT2;
  loglen: Integer;
  res: DWord;
begin
  if len = 0 then
    exit;
  cr.cpMin := idx;
  cr.cpMax := idx + len;
  SendMessage(RichEditHandle, EM_EXSETSEL, 0, LPARAM(@cr));
  ZeroMemory(@cf, SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  cf.dwMask := fromCF.dwMask;
  res := SendMessage(RichEditHandle, EM_GETCHARFORMAT, SCF_SELECTION, LPARAM(@cf));
  if (res and fromCF.dwMask) = 0 then
  begin
    if len = 2 then
    begin
      // wtf, msdn tells that cf will get the format of the first AnsiChar,
      // and then we have to select it, if format match or second, if not
      // instead we got format of the last AnsiChar... weired
      if (cf.dwEffects and fromCF.dwEffects) = fromCF.dwEffects then
        Inc(cr.cpMin)
      else
        Dec(cr.cpMax);
      SendMessage(RichEditHandle, EM_EXSETSEL, 0, LPARAM(@cr));
      SendMessage(RichEditHandle, EM_SETCHARFORMAT, SCF_SELECTION, LPARAM(@toCF));
    end
    else
    begin
      loglen := len div 2;
      ReplaceCharFormatRange(RichEditHandle, fromCF, toCF, idx, loglen);
      ReplaceCharFormatRange(RichEditHandle, fromCF, toCF, idx + loglen, len - loglen);
    end;
  end
  else if (cf.dwEffects and fromCF.dwEffects) = fromCF.dwEffects then
    SendMessage(RichEditHandle, EM_SETCHARFORMAT, SCF_SELECTION, LPARAM(@toCF));
end;

procedure ReplaceCharFormat(RichEditHandle: THANDLE; const fromCF, toCF: CHARFORMAT2);
begin
  ReplaceCharFormatRange(RichEditHandle,fromCF,toCF,0,GetTextLength(RichEditHandle));
end;


function GetTextRange(RichEditHandle: THANDLE; cpMin,cpMax: Integer): PWideChar;
var
  tr: TextRangeW;
begin
  tr.chrg.cpMin := cpMin;
  tr.chrg.cpMax := cpMax;
  GetMem(Result,(cpMax-cpMin+1)*SizeOf(WideChar));
  tr.lpstrText := Result;

  SendMessageW(RichEditHandle,EM_GETTEXTRANGE,0,LPARAM(@tr));
end;

initialization
finalization
//  if FRichEditModule <> 0 then FreeLibrary(FRichEditModule);
end.
