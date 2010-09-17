unit tr_frame;

interface

uses windows;

procedure CreateFrame(parent:HWND);
procedure DestroyFrame;

implementation

uses commctrl,Messages,m_api,common,wrapper,mirutils,dbsettings;

{$include resource.inc}

{
  wParam - unicode text to translate
  lParam - loword=From, hiword=To ; in=0 - auto, out=0 - system/langpack
  return - translated unicode string
  notes  - language coding: word value, like 0x6E45 for 'En'
}
const
  MS_TRANSLATE_GOOGLE:PAnsiChar = 'Translate/Google';

const
  query:PAnsiChar = 'http://ajax.googleapis.com/ajax/services/language/translate';
  qstart:PAnsiChar = 'v=1.0&langpair=';
  rest:PWideChar = '"translatedText":"';

type
  tLang = record
    short :Array [0..2] of AnsiChar;
    descr :PAnsiChar;
    locale:integer;
  end;
const
  MaxLangs = 10;
  Languages:array [0..MaxLangs-1] of tLang = (
  (short:'?' ; descr:'Auto'   ; locale:$0409),
  (short:'En'; descr:'English'; locale:$0409),
  (short:'Ru'; descr:'Russian'; locale:$0419),
  (short:'De'; descr:'German' ; locale:$0407),
  (short:'Fr'; descr:'French' ; locale:$040C),
  (short:'Es'; descr:'Spanish'; locale:$040A),
  (short:'It'; descr:'Italian'; locale:$0410),
  (short:'Pl'; descr:'Polish' ; locale:$0415),
  (short:'Fi'; descr:'Finnish'; locale:$040B),
  (short:'Sv'; descr:'Swedish'; locale:$041D));
const
  FrameWnd:HWND = 0;
  FrameId:integer = -1;
  OldEditProc:pointer=nil;
  pattern:pWideChar=nil;
const
  frm_back:pAnsiChar = 'Frame background';
var
  colorhook:THANDLE;
  srv:THANDLE;
  hbr:HBRUSH;
  frm_bkg:TCOLORREF;

const
  AddText = #$0D#$0A#$0D#$0A'Copy to clipboard?';
const
  MainTitle = 'Translate';
const
  optFrom:PAnsiChar = 'From';
  optTo  :PAnsiChar = 'To';
  
function ProcessResult(src:pAnsiChar):pWideChar;
var
  pc,ppc:pWideChar;
  tmp:array [0..4] of WideChar;
begin
  UTF8ToWide(src,result);
  ppc:=StrPosW(result,rest);
  if ppc=nil then
    mFreeMem(result)
  else
  begin
    // remove JS code
    StrCopyW(result,ppc+StrLenW(rest));
    ppc:=StrScanW(result,'"');
    if ppc<>nil then ppc^:=#0;

    // replace \u#### to unicode char
    ppc:=result;
    repeat
      ppc:=StrPosW(ppc,'\u');
      if ppc=nil then
        break;
      if (ppc>result) and ((ppc-1)^='\') then 
      begin
        inc(ppc,2);
        continue;
      end;
      pc:=ppc;
      inc(pc,2);
      tmp[0]:=pc^; inc(pc);
      tmp[1]:=pc^; inc(pc);
      tmp[2]:=pc^; inc(pc);
      tmp[3]:=pc^;
      tmp[4]:=#0;
      StrCopyW(ppc,pc);
      ppc^:=WideChar(HexToInt(tmp));
    until false;

    // replace &lt; &gt; &amp; &quot; to symbols: < > & '"
    StrReplaceW(result,'&amp;','&');
    StrReplaceW(result,'&quot;','''');
    StrReplaceW(result,'&lt;','<');
    StrReplaceW(result,'&gt;','>');

    // replace &#**; to char
    ppc:=result;
    tmp[3]:=#0;
    repeat
      ppc:=StrPosW(ppc,'&#');
      if ppc=nil then
        break;
      pc:=ppc;
      inc(pc,2);
      tmp[0]:=pc^; inc(pc);
      tmp[1]:=pc^; inc(pc);
      if pc^=';' then
        tmp[2]:=#0
      else
      begin
        tmp[2]:=pc^; inc(pc);
      end;
      StrCopyW(ppc,pc);
      ppc^:=WideChar(StrToInt(tmp));
    until false;

  end;
end;

function Encode(dst,src:pAnsiChar):PAnsiChar;
begin
  while src^<>#0 do
  begin
    if (src^ in [' ','%','+','&','?',#128..#255]) then
    begin
      dst^:='%'; inc(dst);
      dst^:=HexDigitChr[ord(src^) shr 4]; inc(dst);
      dst^:=HexDigitChr[ord(src^) and $0F];
    end
    else
      dst^:=src^;
    inc(src);
    inc(dst);
  end;
  dst^:=#0;
  result:=dst;
end;

function GetTranslatedText(src:pWideChar;tFrom,tTo:PAnsiChar):pWideChar;
var
  langstr:array [0..15] of AnsiChar;
  buf,pc,pca:PAnsiChar;
  i,j:integer;
  locale:integer;
begin
  result:=nil;

  FillChar(langstr,SizeOf(langstr),#0);
  WideToUTF8(src,pca);

  if (tFrom=nil) or (tFrom^<>'?') and (tFrom^<>#0) then
  begin
    langstr[0]:=tFrom[0];
    langstr[1]:=tFrom[1];
    i:=2;
  end
  else
  begin
    i:=0;
  end;
  langstr[i]:='%'; inc(i);
  langstr[i]:='7'; inc(i);
  langstr[i]:='C'; inc(i);
  if (tTo=nil) or (tTo^=#0) then
  begin
    locale:=CallService(MS_LANGPACK_GETLOCALE,0,0);
    langstr[i]:=#1;
    for j:=1 to MaxLangs-1 do
    begin
      if Languages[j].locale=locale then
      begin
        langstr[i]:=Languages[j].short[0]; inc(i);
        langstr[i]:=Languages[j].short[1]; inc(i);
        break;
      end;
    end;
    if langstr[i]=#1 then // locale not found, english by default
    begin
      langstr[i]:='E'; inc(i);
      langstr[i]:='n'; inc(i);
    end
  end
  else
  begin
    langstr[i]:=tTo[0]; inc(i);
    langstr[i]:=tTo[1]; inc(i);
  end;
  langstr[i]:=#0;

  mGetMem(buf,StrLen(pca)*3+Length(qstart)+HIGH(langstr)+3+1);
  pc:=StrCopyE(StrCopyE(buf,qstart),langstr);
  pc^:='&'; inc(pc);
  pc^:='q'; inc(pc);
  pc^:='='; inc(pc);
  Encode(pc,pca);

  pc:=SendRequest(query,REQUEST_POST,buf);
  mFreeMem(buf);
  if pc<>nil then
  begin
    result:=ProcessResult(pc);
    mFreeMem(pc);
  end;
end;

procedure LoadSettings;
var
  lstr:array [0..3] of AnsiChar;
begin
  lstr[3]:=#0;
  pword(@lstr)^:=DBReadWord(0,MainTitle,optFrom,$6E45); // En
  SetDlgItemTextA(FrameWnd,IDC_FRAME_FROM,lstr);
  pword(@lstr)^:=DBReadWord(0,MainTitle,optTo,$6E45); // En
  SetDlgItemTextA(FrameWnd,IDC_FRAME_TO,lstr);
end;

function ChooseDirection(From:bool):integer;
var
  menu:HMENU;
  id:integer;
  pt:TPOINT;
  pc:PAnsiChar;
  buf:array [0..127] of ansiChar;
begin
  menu:=CreatePopupMenu;
  if menu<>0 then
  begin
    if From then
    begin
      pc:='From';
      id:=0;
    end
    else
    begin
      pc:='To';
      id:=1;
    end;
    AppendMenuA(menu,MF_DISABLED+MF_STRING,0,Translate(pc));
    AppendMenuA(menu,MF_SEPARATOR,0,nil);

    while id<MaxLangs do
    begin
      pc:=StrCopyE(buf,Languages[id].short);
      pc^:=' '; inc(pc);
      pc^:='-'; inc(pc);
      pc^:=' '; inc(pc);
      StrCopy(pc,Translate(Languages[id].descr));
      AppendMenuA(menu,MF_STRING,100+id,buf);
      inc(id);
    end;

    GetCursorPos(pt);
    result:=integer(TrackPopupMenu(menu,TPM_RETURNCMD+TPM_NONOTIFY,pt.x,pt.y,0,FrameWnd,nil))-100;
    DestroyMenu(menu);
  end
  else
    result:=-1;
end;

function NewEditProc(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
begin
  result:=0;
  case hMessage of
    WM_CHAR: if wParam=27 then
    begin
      // clear edit field
      SendMessage(Dialog,WM_SETTEXT,0,0);
      exit;
    end;

    WM_KEYDOWN: begin
      case wParam of
        VK_RETURN: begin
          PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_FRAME_START,0);
          exit;
        end;
      end;
    end;
  end;
  result:=CallWindowProc(OldEditProc,dialog,hMessage,wParam,lParam);
end;

function QSDlgResizer(Dialog:HWND;lParam:LPARAM;urc:PUTILRESIZECONTROL):int; cdecl;
begin
  case urc^.wId of
    IDC_FRAME_FROM  : result:=RD_ANCHORX_LEFT  or RD_ANCHORY_CENTRE;
    IDC_FRAME_SWITCH: result:=RD_ANCHORX_LEFT  or RD_ANCHORY_CENTRE;
    IDC_FRAME_TO    : result:=RD_ANCHORX_LEFT  or RD_ANCHORY_CENTRE;
    IDC_FRAME_EDIT  : result:=RD_ANCHORX_WIDTH or RD_ANCHORY_CENTRE;
    IDC_FRAME_START : result:=RD_ANCHORX_RIGHT or RD_ANCHORY_CENTRE;
  else
    result:=0;
  end;
end;

function TRFrameProc(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
var
  urd:TUTILRESIZEDIALOG;
  rc:TRECT;
  pcw:pAnsiChar;
  txt,sres:PWideChar;
  fromto:bool;
  res:integer;
  tfrom,tto:array [0..7] of AnsiChar;
begin
  result:=0;
  case hMessage of
    WM_DESTROY: begin
      DeleteObject(hbr);
    end;

    WM_INITDIALOG: begin
      OldEditProc:=pointer(SetWindowLongA(GetDlgItem(dialog,IDC_FRAME_EDIT),
         GWL_WNDPROC,integer(@NewEditProc)));

    end;

    WM_SIZE: begin
      FillChar(urd,SizeOf(TUTILRESIZEDIALOG),0);
      urd.cbSize    :=SizeOf(urd);
      urd.hwndDlg   :=Dialog;
      urd.hInstance :=hInstance;
      urd.lpTemplate:=MAKEINTRESOURCEA(IDD_FRAME);
      urd.lParam    :=0;
      urd.pfnResizer:=@QSDlgResizer;
      CallService(MS_UTILS_RESIZEDIALOG,0,dword(@urd));
    end;

    WM_ERASEBKGND: begin
      GetClientRect(Dialog,rc);
      FillRect(wParam,rc,hbr);
      result:=1;
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        BN_CLICKED: begin
          case loword(wParam) of
            IDC_FRAME_SWITCH: begin
              GetWindowTextA(GetDlgItem(Dialog,IDC_FRAME_FROM),tfrom,3);
              if tfrom[0]='?' then
              begin
                tfrom[0]:='E';
                tfrom[1]:='n';
                tfrom[2]:=#0;
              end;
              GetWindowTextA(GetDlgItem(Dialog,IDC_FRAME_TO  ),tto  ,3);
              SetWindowTextA(GetDlgItem(Dialog,IDC_FRAME_FROM),tto);
              SetWindowTextA(GetDlgItem(Dialog,IDC_FRAME_TO  ),tfrom);
              DBWriteWord(0,MainTitle,optFrom,ord(tto  [0])+(ord(tto  [1]) shl 8));
              DBWriteWord(0,MainTitle,optTo  ,ord(tfrom[0])+(ord(tfrom[1]) shl 8));
            end;
            IDC_FRAME_FROM,IDC_FRAME_TO: begin
              Fromto:=loword(wParam)=IDC_FRAME_FROM;
              res:=ChooseDirection(Fromto);
              if res>=0 then
              begin
                with Languages[res] do
                begin
                  SetWindowTextA(lParam,short);
                  if Fromto then
                    pcw:=optFrom
                  else
                    pcw:=optTo;
                  DBWriteWord(0,MainTitle,pcw,ord(short[0])+(ord(short[1]) shl 8));
                end;
              end;
            end;
            IDC_FRAME_START : begin
              txt:=GetDlgText(Dialog,IDC_FRAME_EDIT);
              GetWindowTextA(GetDlgItem(Dialog,IDC_FRAME_FROM),tfrom,3);
              GetWindowTextA(GetDlgItem(Dialog,IDC_FRAME_TO  ),tto  ,3);
              sres:=GetTranslatedText(txt,tfrom,tto);
              mFreeMem(txt);
              if sres=nil then
                messagebox(0,'Oops! something wrong!','ERROR',MB_ICONERROR)
              else
              begin
                mGetMem(txt,(StrLenW(sres)+StrLenW(AddText)+1)*SizeOf(WideChar));
                StrCopyW(StrCopyEW(txt,sres),AddText);
                if MessageBoxW(0,txt,TranslateW(MainTitle),
                   MB_YESNO+MB_ICONINFORMATION)=IDYES then
                begin
                  CopyToClipboard(sres,false);
                end;
                mFreeMem(sres);
                mFreeMem(txt);
              end;

            end;
          end;
        end;
      end;
    end;

  else
    result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;

function SrvGetTranslatedText(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  tfrom,tto:array [0..3] of AnsiChar;
begin
  pword(@tfrom)^:=lParam and $FFFF;
  pword(@tto  )^:=lParam shr 16;
  tfrom[2]:=#0;
  tto  [2]:=#0;
  result:=dword(GetTranslatedText(pWideChar(wParam),tfrom,tto));
end;

function ColorReload(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  cid:TColourID;
begin
  result:=0;
  cid.cbSize:=SizeOf(cid);
  StrCopy(cid.group,MainTitle);
  StrCopy(cid.name ,frm_back);
  frm_bkg:=CallService(MS_COLOUR_GETA,dword(@cid),0);
  DeleteObject(hbr);
  hbr:=CreateSolidBrush(frm_bkg);

  RedrawWindow(FrameWnd,nil,0,RDW_ERASE);
end;

procedure CreateFrame(parent:HWND);
var
  Frame:TCLISTFrame;
  tr:TRECT;
  cid:TColourID;
begin
  if PluginLink^.ServiceExists(MS_CLIST_FRAMES_ADDFRAME)=0 then
    exit;
  if parent=0 then
    parent:=CallService(MS_CLUI_GETHWND,0,0);

  if FrameWnd=0 then
    FrameWnd:=CreateDialog(hInstance,MAKEINTRESOURCE(IDD_FRAME),parent,@TRFrameProc);

  if FrameWnd<>0 then
  begin
    GetWindowRect(FrameWnd,tr);
    FillChar(Frame,SizeOf(Frame),0);
    with Frame do
    begin
      cbSize  :=SizeOf(Frame);
      hWnd    :=FrameWnd;
      hIcon   :=0;
      align   :=alTop;
      height  :=tr.bottom-tr.top+2;
      Flags   :=F_VISIBLE or F_NOBORDER or F_UNICODE;
      name.w  :=MainTitle;
      TBName.w:=MainTitle;
    end;

    FrameId:=CallService(MS_CLIST_FRAMES_ADDFRAME,dword(@Frame),0);
    if FrameId>=0 then
    begin
      LoadSettings;
      CallService(MS_CLIST_FRAMES_UPDATEFRAME,FrameId, FU_FMPOS);

      cid.cbSize:=SizeOf(cid);
      cid.flags :=0;
      StrCopy(cid.group,MainTitle);
      StrCopy(cid.dbSettingsGroup,MainTitle);

      StrCopy(cid.name   ,frm_back);
      StrCopy(cid.setting,'frame_back');
      cid.defcolour:=COLOR_3DFACE;
      cid.order    :=0;
      CallService(MS_COLOUR_REGISTERA,dword(@cid),0);

      colorhook:=PluginLink^.HookEvent(ME_COLOUR_RELOAD,@ColorReload);
      ColorReload(0,0);

      srv:=PluginLink^.CreateServiceFunction(MS_TRANSLATE_GOOGLE,@SrvGetTranslatedText);
    end;
  end;
end;

procedure DestroyFrame;
begin
  if FrameId>=0 then
  begin
    PluginLink^.DestroyServiceFunction(srv);
    CallService(MS_CLIST_FRAMES_REMOVEFRAME,FrameId,0);
    FrameId:=-1;
  end;
  DestroyWindow(FrameWnd);
  FrameWnd:=0;
end;

end.
