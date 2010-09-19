{CList frame}
unit KOLFrame;

interface

implementation

uses kol, io,windows,commdlg,messages,common,commctrl, KOLCCtrls,
     wat_api,wrapper,global,m_api,hlpdlg,macros,dbsettings,waticons,mirutils;

{$R frm.res}

{$include frm_data.inc}
{$include frm_vars.inc}

// ---------------- frame functions ----------------

procedure SetFrameTitle(FrameId:integer;title:PAnsiChar;icon:HICON);
begin
  CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,(FrameId shl 16)+FO_TBNAME,dword(title));
  CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,(FrameId shl 16)+FO_ICON,icon);
  CallService(MS_CLIST_FRAMES_UPDATEFRAME,FrameId,FU_TBREDRAW);
end;

// -----------------------

function IsFrameMinimized(FrameId:integer):bool;
begin
  result:=(CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
          (FrameId shl 16)+FO_FLAGS,0) and F_UNCOLLAPSED)=0;
end;

function IsFrameFloated(FrameId:integer):bool;
begin
  result:=CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
          (FrameId shl 16)+FO_FLOATING,0)>0;
end;

function IsFrameHidden(FrameId:integer):bool;
begin
  result:=(CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
          (FrameId shl 16)+FO_FLAGS,0) and F_VISIBLE)=0;
end;

procedure HideFrame(FrameId:integer);
begin
  if not IsFrameHidden(FrameId) then
  begin
    CallService(MS_CLIST_FRAMES_SHFRAME,FrameId,0);
    HiddenByMe:=true;
  end;
end;

function ShowFrame(FrameId:integer):integer;
begin
  result:=0;
  if IsFrameHidden(FrameId) then
    if HiddenByMe then
    begin
      CallService(MS_CLIST_FRAMES_SHFRAME,FrameId,0);
      HiddenByMe:=false;
    end
    else
      result:=1;
end;

{$include frm_rc.inc}
{$include frm_icobutton.inc}
{$include frm_icogroup.inc}
{$include frm_trackbar.inc}
{$include frm_chunk.inc}
{$include frm_text.inc}
{$include frm_frame.inc}

{$include frm_dlg1.inc}
{$include frm_dlg2.inc}

// ---------------- basic frame functions ----------------

function NewPlStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
const
  needToChange:boolean=true;
var
  buf:array [0..127] of AnsiChar;
  bufw:array [0..511] of WideChar;
  tmp:integer;
  FrameWnd:HWND;
begin
  result:=0;
  FrameWnd:=FrameCtrl.Form.GetWindowHandle;

  case wParam of
{
    WAT_EVENT_NEWTEMPLATE: begin
      if lParam=TM_FRAMEINFO then
        SendMessage(FrameWnd,WM_WAREFRESH,frcForce,0);
    end;
}
    WAT_EVENT_PLAYERSTATUS: begin
      case lParam of
        WAT_PLS_NORMAL  : exit;//SetFrameTitle(PSongInfo(lParam));
        WAT_PLS_NOMUSIC : begin
{
          if HideFrameNoMusic<>BST_UNCHECKED then
          begin
            HideFrame;
            tmp:=1;
          end
          else
          begin
            tmp:=ShowFrame;
          end;
          SendMessage(FrameWnd,WM_WAREFRESH,frcClear,tmp);
}
        end;
        WAT_PLS_NOTFOUND: begin
{
          if HideFrameNoPlayer<>BST_UNCHECKED then
            HideFrame;
          SetFrameTitle('',0);
          needToChange:=true;
          CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,(FrameId shl 16)+FO_TBNAME,
                      dword(PluginShort));
          SendMessage(FrameWnd,WM_WAREFRESH,frcClear,1);
          if not IsFrameHidden then
            CallService(MS_CLIST_FRAMES_UPDATEFRAME,FrameId,FU_TBREDRAW);
}
        end;
      end;
//      DrawFrame(DF_ALL);
//      InvalidateRect(FrameWnd,0,false); //??
    end;
    WAT_EVENT_NEWTRACK: begin
{
      mFreeMem(Cover);
      if (PSongInfo(lParam)^.Cover<>nil) and (PSongInfo(lParam)^.Cover^<>#0) then
      begin
        GetShortPathNameW(PSongInfo(lParam)^.Cover,bufw,SizeOf(bufw));
        WideToAnsi(bufw,Cover);
      end;

      TotalTime:=PSongInfo(lParam)^.total;
      SendMessage(FrameWnd,WM_WAREFRESH,frcInit,0);
      if needToChange then // only if not player replacing without pause
      begin
        FastWideToAnsiBuf(PSongInfo(lParam)^.player,buf);
        SetFrameTitle(buf,PSongInfo(lParam)^.icon);
        needToChange:=false;
      end;
      ShowFrame;
}
    end;
    WAT_EVENT_NEWPLAYER: begin
      needToChange:=true;
    end;
    WAT_EVENT_PLUGINSTATUS: begin
{
      case lParam of
        dsEnabled: ShowFrame;
        dsPermanent: HideFrame;
      end;
}
    end;
  end;
end;

function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=0;
  with FrameCtrl^ do
  begin
    if FrameId<>0 then
    begin
      ShowWindow(Form.GetWindowHandle,SW_HIDE);
      ShowWindow(Form.GetWindowHandle,SW_SHOW);
    end;
  end;
end;

const
  opt_FrmHeight :PAnsiChar = 'frame/frmheight';

procedure CreateFrame(parent:HWND);
var
  CLFrame:TCLISTFrame;
  rc:TRECT;
  FrameWnd:HWND;
begin
  if PluginLink^.ServiceExists(MS_CLIST_FRAMES_ADDFRAME)=0 then
    exit;

  if parent=0 then
    parent:=CallService(MS_CLUI_GETHWND,0,0);

  FrameWnd:=CreateFrameWindow(parent);

  if FrameWnd<>0 then
  begin
    FillChar(CLFrame,SizeOf(CLFrame),0);
    with CLFrame do
    begin
      cbSize  :=SizeOf(CLFrame);
      hWnd    :=FrameWnd;
      hIcon   :=0;
      align   :=alTop;
      GetClientRect(FrameWnd,rc);
      height  :=DBReadWord(0,PluginShort,opt_FrmHeight,rc.bottom-rc.top);
      Flags   :=0;//{F_VISIBLE or} F_SHOWTB;
      name.a  :=PluginShort;
      TBName.a:=PluginShort;
    end;
    FrameHeight:=CLFrame.height;

    FrameCtrl.FrameId:=CallService(MS_CLIST_FRAMES_ADDFRAME,dword(@CLFrame),0);
    if FrameCtrl.FrameId>=0 then
    begin
      plStatusHook:=PluginLink^.HookEvent(ME_WAT_NEWSTATUS,@NewPlStatus);
    end;
  end;
end;

procedure DestroyFrame;
var
  h:integer;
begin
{
  if hFrmTimer<>0 then
  begin
    KillTimer(FrameWnd,hFrmTimer);
    hFrmTimer:=0;
  end;
  if hTxtTimer<>0 then
  begin
    KillTimer(FrameWnd,hTxtTimer);
    hTxtTimer:=0;
  end;
}
  if FrameCtrl.FrameId>=0 then
  begin
    PluginLink^.UnhookEvent(plStatusHook);

    h:=CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
        FO_HEIGHT+(FrameCtrl.FrameId shl 16),0);
    if h>0 then
    DBWriteWord(0,PluginShort,opt_FrmHeight,h);

    CallService(MS_CLIST_FRAMES_REMOVEFRAME,FrameCtrl.FrameId,0);
    DestroyFrameWindow;
    FrameCtrl.FrameId:=-1;
  end;
end;

const
  opt_ModStatus:PAnsiChar = 'module/frame';

function GetModStatus:integer;
begin
  result:=DBReadByte(0,PluginShort,opt_ModStatus,1);
end;

procedure SetModStatus(stat:integer);
begin
  DBWriteByte(0,PluginShort,opt_modStatus,stat);
end;

// ---------------- base interface procedures ----------------

function InitProc(aGetStatus:boolean=false):integer;
begin
  if aGetStatus then
  begin
    if GetModStatus=0 then
    begin
      result:=0;
      exit;
    end;
  end
  else
    SetModStatus(1);
  result:=1;

  RegisterButtonIcons;
  sic:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);

  CreateFrame(0);
end;

procedure DeInitProc(aSetDisable:boolean);
begin
  if aSetDisable then
    SetModStatus(0);

  PluginLink^.UnhookEvent(sic);
  DestroyFrame;
end;

function AddOptionsPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
const
  count:integer=2;
begin
{
  if count=0 then
    count:=2;
  if count=2 then
  begin
}
    tmpl:='FRAME';
    proc:=@FrameViewDlg;
    name:='Frame (main)';
{
  end
  else
  begin
    tmpl:='FRAME2';
    proc:=@FrameTextDlg;
    name:='Frame (text)';
  end;

  dec(count);
  result:=count;
}
  result:=0;
end;

var
  Frame:twModule;

procedure Init;
begin
  Frame.Next      :=ModuleLink;
  Frame.Init      :=@InitProc;
  Frame.DeInit    :=@DeInitProc;
  Frame.AddOption :=@AddOptionsPage;
  Frame.ModuleName:='Frame';
  ModuleLink      :=@Frame;
end;

begin
  Init;
end.
