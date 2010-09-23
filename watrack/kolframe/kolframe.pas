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

procedure SetFrameTitle(title:pointer;icon:HICON;addflag:integer=FO_UNICODETEXT);
begin
  CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,
      (FrameCtrl.FrameId shl 16)+FO_TBNAME+addflag,dword(title));
  CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,(FrameCtrl.FrameId shl 16)+FO_ICON,icon);
  CallService(MS_CLIST_FRAMES_UPDATEFRAME,FrameCtrl.FrameId,FU_TBREDRAW);
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
  Cover:pAnsiChar;
begin
  result:=0;
//  FrameWnd:=FrameCtrl.Form.GetWindowHandle;

  case wParam of
    WAT_EVENT_PLAYERSTATUS: begin
      case lParam of
        WAT_PLS_NORMAL  : exit;
        WAT_PLS_NOMUSIC : begin
          if FrameCtrl.HideNoMusic then
            HideFrame(FrameCtrl.FrameId)
          else
            ShowFrame(FrameCtrl.FrameId); // if was hidden with "no player"

          // clear text, slider to 0, picture to default
        end;
        WAT_PLS_NOTFOUND: begin
          if FrameCtrl.HideNoPlayer then
            HideFrame(FrameCtrl.FrameId);

          SetFrameTitle(PluginShort,0,0); // frame update code there
        end;
      end;
//      InvalidateRect(FrameWnd,0,false); //??
    end;

    WAT_EVENT_NEWTRACK: begin
      // cover
      if (PSongInfo(lParam)^.Cover<>nil) and (PSongInfo(lParam)^.Cover^<>#0) then
      begin
        GetShortPathNameW(PSongInfo(lParam)^.Cover,bufw,SizeOf(bufw));
        WideToAnsi(bufw,Cover);
        FrameCtrl.RefreshPicture(Cover);
        mFreeMem(Cover);
      end;

      // trackbar
      tmp:=(PSongInfo(lParam)^.total*1000) div FrameCtrl.UpdInterval;
      with FrameCtrl.Trackbar^ do
      begin
        RangeMax:=tmp;
        LineSize:=tmp div 100;
        PageSize:=tmp div 10;
      end;
//          FrameCtrl.UpdTimer:=SetTimer(0,0,FrameCtrl.UpdInterval,@);

      // text

      ShowFrame(FrameCtrl.FrameId);
    end;

    WAT_EVENT_NEWPLAYER: begin
      SetFrameTitle(PSongInfo(lParam)^.player,PSongInfo(lParam)^.icon);
      // new player must call "no music" at least, so we have chance to show frame
    end;

    WAT_EVENT_PLUGINSTATUS: begin
      case lParam of
        dsEnabled: begin
          ShowFrame(FrameCtrl.FrameId);
          // plus - start frame and text timers
//          FrameCtrl.UpdTimer:=SetTimer(0,0,FrameCtrl.UpdInterval,@);
        end;

        dsPermanent: begin
          HideFrame(FrameCtrl.FrameId);

          // plus - stop frame and text timers
          if FrameCtrl.UpdTimer<>0 then
            KillTimer(0,FrameCtrl.UpdTimer);
        end;
      end;
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
      RefreshAllFrameIcons;
      ShowWindow(Form.GetWindowHandle,SW_HIDE);
      ShowWindow(Form.GetWindowHandle,SW_SHOW);
    end;
  end;
end;

const
  opt_FrmHeight :PAnsiChar = 'frame/frmheight';

function CreateFrame(parent:HWND):boolean;
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
  result:=FrameWnd<>0;
end;

procedure DestroyFrame;
var
  h:integer;
begin
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
  result:=0;
  if aGetStatus then
  begin
    if GetModStatus=0 then
      exit;
  end
  else
    SetModStatus(1);

  result:=ord(CreateFrame(0));
  if result<>0 then
    sic:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);
end;

procedure DeInitProc(aSetDisable:boolean);
begin
  if aSetDisable then
    SetModStatus(0);

  if sic<>0 then PluginLink^.UnhookEvent(sic);
  DestroyFrame;
end;

function AddOptionsPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
const
  count:integer=2;
begin
  if count=0 then
    count:=2;
  if count=2 then
  begin
    tmpl:='FRAME';
    proc:=@FrameViewDlg;
    name:='Frame (main)';
  end
  else
  begin
    tmpl:='FRAME2';
    proc:=@FrameTextDlg;
    name:='Frame (text)';
  end;

  dec(count);
  result:=count;
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
