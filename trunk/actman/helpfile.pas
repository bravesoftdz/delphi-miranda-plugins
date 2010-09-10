{service insertion code}
unit HelpFile;

interface

uses windows,messages;

const
  WM_UPDATEHELP = WM_USER+100;

function  FillParams(service:PAnsiChar;wnd:hwnd;paramname:PAnsiChar):pAnsiChar;
procedure FillServiceList(list:hwnd);
function  InitHelpFile:bool;
function  ServiceHelpDlg(Dialog:HWnd;hMessage,wParam,lParam:DWord):integer; stdcall;
procedure DoInitCommonControls(dwICC:DWORD);
function  GetResultType(service:PAnsiChar):pAnsiChar;

implementation

uses m_api,common,io,kol,mirutils;

{$include i_const.inc}

const
  ServiceHlpFile = 'plugins\services.ini';
const
  BufSize = 2048;
var
  HelpINIFile:PAnsiChar;

procedure DoInitCommonControls(dwICC:DWORD);
begin
  KOL.DoInitCommonControls(dwICC);
end;

function GetResultType(service:PAnsiChar):pAnsiChar;
var
  buf:array [0..2047] of AnsiChar;
  p:pAnsiChar;
begin
  GetPrivateProfileStringA(service,'return','',buf,SizeOf(buf),HelpINIFile);
  p:=@buf;
  while p^ in sWordOnly do inc(p);
  p^:=#0;
  StrDup(result,@buf);
end;

function FillParams(service:PAnsiChar;wnd:hwnd;paramname:PAnsiChar):pAnsiChar;
var
  buf :array [0..2047] of AnsiChar;
  bufw:array [0..2047] of WideChar;
  j:integer;
  p,pp,pc:PAnsiChar;
  tmp:pWideChar;
begin
  GetPrivateProfileStringA(service,paramname,'',buf,SizeOf(buf),HelpINIFile);
  StrDup(result,@buf);
  SendMessage(wnd,CB_RESETCONTENT,0,0);
  if buf[0]<>#0 then
  begin
    p:=@buf;
    GetMem(tmp,BufSize*SizeOf(WideChar));
    repeat
      pc:=StrScan(p,'|');
      if pc<>nil then
        pc^:=#0;

      if (p^ in ['0'..'9']) or ((p^='-') and (p[1] in ['0'..'9'])) then
      begin
        j:=0;
        pp:=p;
        repeat
          bufw[j]:=WideChar(pp^);
          inc(j); inc(pp);
        until (pp^=#0) or (pp^=' ');
        if pp^<>#0 then
        begin
          bufw[j]:=' '; bufw[j+1]:='-'; bufw[j+2]:=' '; inc(j,3);
          FastANSItoWideBuf(pp+1,tmp);
          StrCopyW(bufw+j,TranslateW(tmp));
          SendMessageW(wnd,CB_ADDSTRING,0,dword(@bufw));
        end
        else
          SendMessageA(wnd,CB_ADDSTRING,0,dword(p));
      end
      else
      begin
        FastANSItoWideBuf(p,tmp);
        SendMessageW(wnd,CB_ADDSTRING,0,dword(TranslateW(tmp)));
        if (p=@buf) and (lstrcmpia(p,'structure')=0) then
          break;
      end;
      p:=pc+1;
    until pc=nil;
    FreeMem(tmp);
  end;
  SendMessage(wnd,CB_SETCURSEL,0,0);
end;

procedure FillServiceList(list:hwnd);
var
  buf:array [0..8191] of AnsiChar;
  p:PAnsiChar;
begin
  if HelpINIFile<>nil then
  begin
    SendMessage(list,CB_RESETCONTENT,-1,0);
    buf[0]:=#0;
    GetPrivateProfileSectionNamesA(buf,SizeOf(buf),HelpINIFile); // sections
    p:=@buf;
    while p^<>#0 do
    begin
      SendMessageA(list,CB_ADDSTRING,0,dword(p));
      while p^<>#0 do inc(p); inc(p);
    end;
    SendMessage(list,CB_SETCURSEL,-1,0);
  end;
end;

function ServiceHelpDlg(Dialog:HWnd;hMessage,wParam,lParam:DWord):integer; stdcall;
var
  buf,p:PAnsiChar;
  tmp:PWideChar;
begin
  result:=0;
  case hMessage of
    WM_CLOSE: DestroyWindow(Dialog);
    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);
      result:=1;
    end;
    WM_COMMAND: begin
      if (wParam shr 16)=BN_CLICKED then
      begin
        case loword(wParam) of
          IDOK,IDCANCEL: DestroyWindow(Dialog);
        end;
      end;
    end;
    WM_UPDATEHELP: begin
      if (HelpINIFile<>nil) and (lParam<>0) then
      begin
        GetMem(buf,BufSize);
        GetMem(tmp,BufSize*SizeOf(WideChar));
        SetDlgItemTextA(Dialog,IDC_HLP_SERVICE,PAnsiChar(lParam));
        GetPrivateProfileStringA(PAnsiChar(lParam),'return','Undefined',buf,BufSize,HelpINIFile);
        p:=buf;
        while p^ in sWordOnly do inc(p); if (p<>@buf) and (p^<>#0) then inc(p);
        FastAnsiToWideBuf(p,tmp);
        SetDlgItemTextW(Dialog,IDC_HLP_RETURN,TranslateW(tmp));

        GetPrivateProfileStringA(PAnsiChar(lParam),'descr','Undefined',buf,BufSize,HelpINIFile);
        FastAnsiToWideBuf(buf,tmp);
        SetDlgItemTextW(Dialog,IDC_HLP_EFFECT,TranslateW(tmp));

        GetPrivateProfileStringA(PAnsiChar(lParam),'plugin','',buf,BufSize,HelpINIFile);
        FastAnsiToWideBuf(buf,tmp);
        SetDlgItemTextW(Dialog,IDC_HLP_Plugin,TranslateW(tmp));
        FreeMem(tmp);
        FreeMem(buf);
      end;
    end;
  end;
end;

function InitHelpFile:bool;
begin
  GetMem(HelpINIFile,1024);
  ConvertFileName(PAnsiChar(ServiceHlpFile),HelpINIFile);
//  PluginLink^.CallService(MS_UTILS_PATHTOABSOLUTE,
//    dword(PAnsiChar(ServiceHlpFile)),dword(HelpINIFile));
  if GetFSize(HelpINIFile)=0 then
  begin
    FreeMem(HelpINIFile);
    HelpINIFile:=nil;
  end;
  result:=HelpINIFile<>NIL;
end;

initialization
finalization
  if HelpINIFile<>nil then
    FreeMem(HelpINIFile);
end.
