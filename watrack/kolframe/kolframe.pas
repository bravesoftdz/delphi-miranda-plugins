{CList frame}
unit KOLFrame;

interface

implementation

uses kol, io,windows,commdlg,messages,common,commctrl,
     wat_api,wrapper,global,m_api,hlpdlg,macros,dbsettings,waticons,mirutils;

{$include frm_vars.inc}
{$include frm_opt.inc}
{$include frm_rc.inc}
{$include frm_icons.inc}
{$include frm_icobutton.inc}

// ---------------- basic frame functions ----------------

function NewPlStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
const
  needToChange:boolean=true;
var
  buf:array [0..127] of AnsiChar;
  bufw:array [0..511] of WideChar;
  tmp:integer;
begin
  result:=0;
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

//TOnEvent = procedure( Sender: PObj ) of object;

function CreateFrameWindow(parent:HWND):THANDLE;
begin
  result:=0;
  FrameCtrl:=NewAlienPanel(parent,esNone);
  if FrameCtrl<>nil then
  begin
    result:=FrameCtrl.GetWindowHandle;
    // adding elements here: textblock(?), buttons, trackbar
    with CreateIcoButton(FrameCtrl,'WATrack_VolDn','WATrack_VolDnH','WATrack_VolDnP')^ do // VolDn
    begin
      OnClick:=BtnClick(WAT_CTRL_VOLDN);
    end;
    with CreateIcoButton(FrameCtrl,'WATrack_VolUp','WATrack_VolUpH','WATrack_VolUpP')^ do // VolUp
    begin
      OnClick:=BtnClick(WAT_CTRL_VOLUP);
    end;
    with CreateIcoButton(FrameCtrl,'WATrack_Prev','WATrack_PrevH','WATrack_PrevP')^ do // Prev
    begin
      OnClick:=BtnClick(WAT_CTRL_PREV);
    end;
    with CreateIcoButton(FrameCtrl,'WATrack_Play','WATrack_PlayH','WATrack_PlayP')^ do // Play
    begin
      OnClick:=BtnClick(WAT_CTRL_PLAY);
    end;
    with CreateIcoButton(FrameCtrl,'WATrack_Pause','WATrack_PauseH','WATrack_PauseP')^ do // Pause
    begin
      OnClick:=BtnClick(WAT_CTRL_PAUSE);
    end;
    with CreateIcoButton(FrameCtrl,'WATrack_Stop','WATrack_StopH','WATrack_StopP')^ do // Stop
    begin
      OnClick:=BtnClick(WAT_CTRL_STOP);
    end;
    with CreateIcoButton(FrameCtrl,'WATrack_Next','WATrack_NextH','WATrack_NextP')^ do // Next
    begin
      OnClick:=BtnClick(WAT_CTRL_NEXT);
    end;
  end;
end;

procedure CreateFrame(parent:HWND);
var
  CLFrame:TCLISTFrame;
  rc:TRECT;
  tmp:HWND;
  p:PSongInfo;
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
    FrmBrush:=CreateSolidBrush(FrmBkColor);

    FrameId:=CallService(MS_CLIST_FRAMES_ADDFRAME,dword(@CLFrame),0);
    if FrameId>=0 then
    begin
      plStatusHook:=PluginLink^.HookEvent(ME_WAT_NEWSTATUS,@NewPlStatus);
    end;
  end;
end;

procedure DestroyFrame;
begin
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

  if FrameId>=0 then
  begin
    PluginLink^.UnhookEvent(plStatusHook);
    CallService(MS_CLIST_FRAMES_REMOVEFRAME,FrameId,0);
    FrameCtrl.Free;
    FrameId:=-1;
  end;
  FrameWnd:=0;
end;

// ---------------- base interface procedures ----------------

function InitProc(aGetStatus:boolean=false):integer;
var
  buf:array [0..255] of WideChar;
  size:integer;
  pc:pWideChar;
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

  FrameWnd:=0;
  FrameId :=-1;
  TotalTime:=0;
  isFreeImagePresent:=PluginLink^.ServiceExists(MS_IMG_LOAD)<>0;
  loadframe;

  RegisterButtonIcons;
  sic:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);

  CreateFrame(0);

  FillChar(buf,SizeOf(buf),0);
  StrCopyW(buf,TranslateW('All Bitmaps'));
  StrCatW (buf,' (*.bmp;*.jpg;*.gif;*.png)');
  pc:=StrEndW(buf)+1;
  StrCopyW(pc,'*.BMP;*.RLE;*.JPG;*.JPEG;*.GIF;*.PNG');
  size:=(StrEndW(pc)+2-@buf)*SizeOf(WideChar);
  mGetMem(BMPFilter,size);
  move(buf,BMPFilter^,size);
end;

procedure DeInitProc(aSetDisable:boolean);
begin
  if aSetDisable then
    SetModStatus(0);

  PluginLink^.UnhookEvent(sic);
  mFreeMem(BMPFilter);
  mFreeMem(FrameText);
  DestroyFrame;
end;
{
function AddOptionsPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
const
  count:integer=2;
begin
  if count=0 then
    count:=2;
  if count=2 then
  begin
    tmpl:='FRAME';
    proc:=@DlgProcOptions5;
    name:='Frame (main)';
  end
  else
  begin
    tmpl:='FRAME2';
    proc:=@DlgProcOptions51;
    name:='Frame (text)';
  end;

  dec(count);
  result:=count;
end;
}
var
  Frame:twModule;

procedure Init;
begin
  Frame.Next      :=ModuleLink;
  Frame.Init      :=@InitProc;
  Frame.DeInit    :=@DeInitProc;
  Frame.AddOption :=nil;//@AddOptionsPage;
  Frame.ModuleName:='Frame';
  ModuleLink      :=@Frame;
end;

begin
  Init;
end.
