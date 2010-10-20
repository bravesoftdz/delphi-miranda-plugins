{Frame + background}

const
  WS_EX_LAYERED = $00080000;

function SetLayeredWindowAttributes(Hwnd: THandle; crKey: COLORREF; bAlpha: Byte; dwFlags: DWORD): Boolean; stdcall;
   external user32 name 'SetLayeredWindowAttributes';

const
//  opt_HiddenByMe:PAnsiChar = 'frame/hiddenbyme';
  opt_ShowCtrls :PAnsiChar = 'frame/showcontrols';
  opt_FrmUsePic :PAnsiChar = 'frame/frmusepic';
  opt_FrmUseCvr :PAnsiChar = 'frame/frmusecover';
  opt_FrmBkColor:PAnsiChar = 'frame/frmbkcolor';
  opt_FrmBkPic  :PAnsiChar = 'frame/frmbkpic';
  opt_FrmBkMode :PAnsiChar = 'frame/frmbkmode';
//  opt_FrmHeight :PAnsiChar = 'frame/frmheight';
  opt_FrmAlpha  :PAnsiChar = 'frame/frmalpha';
  opt_HideFrameM:PAnsiChar = 'frame/hideframem';
  opt_HideFrameP:PAnsiChar = 'frame/hideframep';
  opt_FrmTimer  :PAnsiChar = 'frame/frametimer';
  opt_PadLeft   :PAnsiChar = 'frame/paddingleft';
  opt_PadTop    :PAnsiChar = 'frame/paddingtop';
  opt_PadRight  :PAnsiChar = 'frame/paddingright';
  opt_PadBottom :PAnsiChar = 'frame/paddingbottom';

procedure TWATFrame.ResetFrame;
begin
// Slider to zero (max to sero)
  ResetTrackbar(Trackbar);
// Clear text
  ClearText(TextBlock);
// frame back to default
  RefreshPicture(nil);
end;

procedure FrameTimerProc(wnd:HWND;uMsg:cardinal;idEvent:cardinal;dwTime:dword); stdcall;
var
  psi:PSongInfo;
begin
  if FrameCtrl.Trackbar<>nil then
  begin
    if (FrameCtrl.ShowControls and scTrackBar)<>0 then
    begin
      if //(TrackPos>=0) and
         (CallService(MS_WAT_GETMUSICINFO,WAT_INF_CHANGES,dword(@psi))<>
         WAT_PLS_NOTFOUND) then
      begin
        SetTrackBarPosition(FrameCtrl.Trackbar,(psi^.time*1000) div FrameCtrl.UpdInterval)
      end;
    end;
  end;

  if (FrameCtrl.ShowControls and scText)<>0 then
  begin
    UpdateTextBlock(FrameCtrl.TextBlock,false); // fase - check for %percent%/%time%
  end;

  FrameCtrl.Form.Update;
end;

procedure TWATFrame.AdjustFrame;
var
  h:integer;
begin
  h:=Form.Height; // or need to get FRAME height
  if ((ShowControls and scTrackbar)<>0) and (Trackbar<>nil) then
  begin
    dec(h,Trackbar.Height);
//    Trackbar.Top:=h;
  end;
  if ((ShowControls and scButtons )<>0) and (Buttons<>nil) then
  begin
    with Buttons^ do
    begin
      Top:=h-Height-BtnGap;
      dec(h,Height+2*BtnGap);
    end;
  end;
  if TextBlock<>nil then
    with TextBlock^ do
    begin
      Top   :=awkTextPad;
      Height:=h-Top;
    end;
end;

procedure TWATFrame.SaveSettings;
var
  D:pIcoGrpData;
  DT:pTxtBlockData;
begin
  DBWriteByte  (0,PluginShort,opt_HideFrameM,ord(HideNoMusic));
  DBWriteByte  (0,PluginShort,opt_HideFrameP,ord(HideNoPlayer));
  DBWriteByte  (0,PluginShort,opt_FrmUsePic ,ord(UseBkPicture));
  DBWriteByte  (0,PluginShort,opt_FrmUseCvr ,ord(UseCover));
  DBWriteDWord (0,PluginShort,opt_FrmBkColor,BkColor);
  DBWriteWord  (0,PluginShort,opt_FrmBkMode ,BkMode);
  DBWriteDWord (0,PluginShort,opt_ShowCtrls ,ShowControls);
  DBWriteByte  (0,PluginShort,opt_FrmAlpha  ,FrmAlpha);
  DBWriteWord  (0,PluginShort,opt_FrmTimer  ,UpdInterval);
  DBWriteWord  (0,PluginShort,opt_PadLeft   ,padding.left);
  DBWriteWord  (0,PluginShort,opt_PadTop    ,padding.top);
  DBWriteWord  (0,PluginShort,opt_PadRight  ,padding.right);
  DBWriteWord  (0,PluginShort,opt_PadBottom ,padding.bottom);
  DBWriteString(0,PluginShort,opt_FrmBkPic  ,BkDefFile);

  RefreshPicture;

  InvalidateRect(FrameCtrl.Form.GetWindowHandle,nil,true);

  if TextBlock<>nil then
  begin
    TextBlock.Visible:=(ShowControls and scText)<>0;
    DT:=Pointer(TextBlock.CustomObj);
    DT.ChangeBkColor(BkColor);
  end;

  if Trackbar<>nil then
  begin
    Trackbar.Visible:=(ShowControls and scTrackBar)<>0;
    TrackbarSetRange(Trackbar,UpdInterval);
  end;

  if Buttons<>nil then
  begin
    Buttons.Visible:=(ShowControls and scButtons)<>0;
    D:=Pointer(Buttons.CustomObj);
    D.ShowVolume:=(ShowControls and scVolume)<>0; // like Buttons.Childrens[0].Visible
    D.ButtonGap :=(ShowControls and scGap   )<>0;
    SendMessage(Buttons.GetWindowHandle,WM_SIZE,0,0);
  end;

  AdjustFrame;
  FrameCtrl.Form.Update;

  if UpdTimer<>0 then // FrameWnd MUST be present
    KillTimer(0,UpdTimer);
  if UpdInterval>0 then
  begin
    UpdTimer:=SetTimer(0,0,UpdInterval,@FrameTimerProc);
  end
  else
    UpdTimer:=0;

end;

procedure TWATFrame.LoadSettings;
begin
  HideNoMusic :=DBReadByte (0,PluginShort,opt_HideFrameM,0)<>0;
  HideNoPlayer:=DBReadByte (0,PluginShort,opt_HideFrameP,0)<>0;
  UseBkPicture:=DBReadByte (0,PluginShort,opt_FrmUsePic ,0)<>0;
  UseCover    :=DBReadByte (0,PluginShort,opt_FrmUseCvr ,0)<>0;
  BkColor     :=DBReadDWord(0,PluginShort,opt_FrmBkColor,$00E0E0E0);
  BkMode      :=DBReadWord (0,PluginShort,opt_FrmBkMode ,frbkCenter);
  ShowControls:=DBReadDWord(0,PluginShort,opt_ShowCtrls ,scAll);
  FrmAlpha    :=DBReadByte (0,PluginShort,opt_FrmAlpha  ,255);

  UpdInterval:=DBReadWord(0,PluginShort,opt_FrmTimer,200);
  if UpdInterval<100 then
    UpdInterval:=UpdInterval*1000;

  padding.left  :=DBReadWord(0,PluginShort,opt_PadLeft  ,0);
  padding.top   :=DBReadWord(0,PluginShort,opt_PadTop   ,0);
  padding.right :=DBReadWord(0,PluginShort,opt_PadRight ,0);
  padding.bottom:=DBReadWord(0,PluginShort,opt_PadBottom,0);

  BkDefFile:=DBReadString(0,PluginShort,opt_FrmBkPic,nil);
end;

{$include i_bitmap.inc}

procedure TWATFrame.SetAlpha(value:integer);
const
  LWA_COLORKEY = $00000001;
  LWA_ALPHA    = $00000002;
var
  wnd:HWND;
  x:cardinal;
begin
  if IsFrameFloated(FrameId) then
  begin
    wnd:=GetParent(FrameCtrl.Form.GetWindowHandle);
    x:=GetWindowLongW(wnd,GWL_EXSTYLE);
    if value<>255 then
    begin
      if (x and WS_EX_LAYERED)=0 then
        SetWindowLongW(wnd,GWL_EXSTYLE,x or WS_EX_LAYERED);
      SetLayeredWindowAttributes(wnd,0,value,LWA_ALPHA);
    end
    else if (x and WS_EX_LAYERED)<>0 then
      SetWindowLongW(wnd,GWL_EXSTYLE,x and not WS_EX_LAYERED);
  end;
end;

procedure TWATFrame.FrameResize(Sender: PObj);
var
  tmpBmp:HBITMAP;
begin
  if BkDC<>0 then
  begin
    tmpBmp:=GetCurrentObject(BkDC,OBJ_BITMAP);
    DeleteDC(BkDC);
    BkDC:=0;
    DeleteObject(tmpBmp);
  end;
  AdjustFrame;
end;

procedure BkTimerProc(wnd:HWND;uMsg:cardinal;idEvent:cardinal;dwTime:dword); stdcall;
begin
  KillTimer(0,FrameCtrl.BkTimer);
  FrameCtrl.BkTimer:=0;
  DeleteObject(FrameCtrl.BkBitmap);
  FrameCtrl.BkBitmap:=0;
end;

procedure TWATFrame.RefreshPicture(cover:PAnsiChar=nil);
begin
  if BkBitmap<>0 then
    BkTimerProc(0,0,0,0); // remove old picture

  FrameResize(nil); // clear frame bitmap buffer

  if UseBkPicture then
    BkBitmap:=LoadBkPicture(cover,true,BkDefFile);

  if FrameCtrl.BkBitmap=HBITMAP(-1) then // same file
    FrameCtrl.BkBitmap:=0;
end;

procedure TWATFrame.Paint(Sender: PControl; DC: HDC);
var
  rc: TRect;
  br:HBRUSH;
begin
  GetClientRect(Sender.Handle,rc);
  if UseBkPicture then
  begin
   if BkDC=0 then
   begin
      if BkBitmap=0 then
      begin
        if (BkFile<>nil) and (BkFile^<>#0) then
          BkBitmap:=CallService(MS_UTILS_LOADBITMAP,0,dword(BkFile));
      end;

      if BkBitmap<>0 then
      begin
        PreparePicture(dc,rc);
        BkTimer:=SetTimer(0,0,10000,@BkTimerProc);
      end;
    end;
    if BkDC<>0 then
    begin
      BitBlt(dc,rc.left,rc.top,rc.right-rc.left,rc.bottom-rc.top,
             BkDC,rc.left,rc.top,SRCCOPY);
      exit;
    end;
  end;

  InflateRect(rc,1,1);
  br:=CreateSolidBrush(BkColor);
  FillRect(dc,rc,br);
  DeleteObject(br);
end;

// JUST LOAD picture, no matter, which transforms
// Backname = from settings, Covername = from data (higher priority)
// -1 - same file, 0 - can't load, other - new bitmap
function TWATFrame.LoadBkPicture(CoverFName:PAnsiChar;check:boolean=false;
             BackFName:PAnsiChar=nil):integer;
var
  tmpstr:PAnsiChar;
begin
  result:=0;

  // check the same file, ie only 'next pic'
  if (CoverFName<>nil) and (CoverFName^<>#0) then
  begin
    if check and (StrCmp(CoverFName,BkFile)=0) then
    begin
      result:=-1;
      Exit;
    end;

    result:=CallService(MS_UTILS_LOADBITMAP,0,dword(CoverFName));
    if result<>0 then
    begin
        mFreeMem(BkFile);
        StrDup(BkFile,CoverFName);
      Exit;
    end;
  end;

  if (BackFName<>nil) and (BackFName^<>#0) then
  begin
    tmpstr:=ParseVarString(BackFName);
    if (tmpstr<>nil) and (tmpstr^<>#0) then
    begin
      if (not check) or (StrCmp(tmpstr,BkFile)<>0) then
      begin
        result:=CallService(MS_UTILS_LOADBITMAP,0,dword(tmpstr));
        if result<>0 then
        begin
          mFreeMem(BkFile);
          StrDup(BkFile,tmpstr);
        end;
      end
      else
        result:=-1;
    end;
    mFreeMem(tmpstr);
  end;
end;

procedure TWATFrame.MouseDown(Sender:PControl;var Mouse:TMouseEventData);
var
  wnd:HWND;
begin
  wnd:=GetParent(Sender.GetWindowHandle);
  SendMessage(wnd,WM_SYSCOMMAND,
     SC_MOVE or HTCAPTION,MAKELPARAM(Mouse.x,Mouse.y));
end;

destructor TWATFrame.Destroy;
var
  tmpBmp:HBITMAP;
begin
  if UpdTimer<>0 then
  begin
    KillTimer(0,UpdTimer);
    UpdTimer:=0;
  end;

  mFreeMem(BkDefFile);
  mFreeMem(BkFile);
  if BkDC<>0 then
  begin
    tmpBmp:=GetCurrentObject(BkDC,OBJ_BITMAP);
    DeleteDC(BkDC);
    BkDC:=0;
    DeleteObject(tmpBmp);
  end;
  if BkBitmap<>0 then
    DeleteObject(BkBitmap);

  inherited;
end;

procedure TWATFrame.RefreshAllFrameIcons;
begin
  if Buttons <>nil then RefreshButtonIcons(Buttons);
  if Trackbar<>nil then RefreshTrackbarIcons(Trackbar);
end;

function CreateFrameWindow(parent:HWND):THANDLE;
begin
  result:=0;

  New(FrameCtrl,Create);
  if FrameCtrl<>nil then
  begin
    with FrameCtrl^ do
    begin
      LoadSettings;

      Form:=NewAlienPanel(parent,esNone);
      result:=Form.GetWindowHandle;

      if RegisterButtonIcons then
      begin

        Buttons :=MakeNewButtonGroup(Form,
            (ShowControls and scVolume)<>0,
            (ShowControls and scGap)<>0);

        Trackbar:=MakeNewTrackbar(Form);
      end
      else
      begin
        Buttons :=nil;
        Trackbar:=nil;
      end;

      TextBlock:=MakeNewTextBlock(Form,BkColor);

      if UseBkPicture then
      begin
        BkBitmap:=LoadBkPicture(nil,true,BkDefFile);
        if BkBitmap=HBITMAP(-1) then
          BkBitmap:=0;
      end;
    end;

    with FrameCtrl.Form^ do
    begin
      MinWidth :=80;
      MinHeight:=30;

      OnPaint    :=FrameCtrl.Paint;
      OnResize   :=FrameCtrl.FrameResize;
      OnMouseDown:=FrameCtrl.MouseDown;
    end;
    FrameCtrl.AdjustFrame;
  end;
end;

procedure DestroyFrameWindow;
begin
  FrameCtrl.Free;
end;
