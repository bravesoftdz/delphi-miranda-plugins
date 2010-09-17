{Frame + background}

function SetLayeredWindowAttributes(Hwnd: THandle; crKey: COLORREF; bAlpha: Byte; dwFlags: DWORD): Boolean; stdcall;
   external user32 name 'SetLayeredWindowAttributes';

type
  PWATFrame = ^TWATFrame;
  TWATFrame = object(TObj)
    BkDC        :HDC;       // "buffer" DC and associated bitmap
    BkBitmap    :HBITMAP;   // original bitmap
    BkFile      :PAnsiChar; // original bitmap filename
    BkDefFile   :PAnsiChar; // default background picture filename
    BkMode      :cardinal;
    BkTimer     :cardinal;  // timer to free original picture buffer
    BkColor     :cardinal;
    padding     :TRect;
    ShowControls:dword;
    UseBkPicture:bool;
    UseCover    :bool;
    HideNoMusic :bool;
    HideNoPlayer:bool;

    // not sure what will keep here
    FrameId     :integer;
    FrmAlpha    :integer;
    UpdInterval :cardinal;
    UpdTimer    :cardinal;  

    Form     :PControl;
    Trackbar :PTrackbar;
    Buttons  :PControl;

    destructor Destroy; virtual;
    procedure Paint(Sender: PControl; DC: HDC);
    procedure FrameResize(Sender: PObj);

    procedure PreparePicture(dc:HDC;rc:TRECT);
    function LoadBkPicture(CoverFName:PAnsiChar;check:boolean=false;
             BackFName:PAnsiChar=nil):integer;
    procedure SaveSettings;
    procedure LoadSettings;
    procedure SetAlpha(value:integer);

  end;

var
  FrameCtrl:PWATFrame;

procedure TWATFrame.SaveSettings;
var
  D:pIcoGrpData;
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

  D:=Pointer(FrameCtrl.Buttons.CustomObj);
  D.ShowVolume:=(ShowControls and scVolume)<>0;
  D.ButtonGap :=(ShowControls and scGap   )<>0;
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
end;

procedure BkTimerProc(wnd:HWND;uMsg:cardinal;idEvent:cardinal;dwTime:dword); stdcall;
begin
  KillTimer(0,FrameCtrl.BkTimer);
  FrameCtrl.BkTimer:=0;
  DeleteObject(FrameCtrl.BkBitmap);
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
        BkBitmap:=LoadBkPicture(BkFile);

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

destructor TWATFrame.Destroy;
var
  tmpBmp:HBITMAP;
begin
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

function CreateFrameWindow(parent:HWND):THANDLE;
begin
  result:=0;

  New(FrameCtrl,Create);
  if FrameCtrl<>nil then
  begin
    FrameCtrl.LoadSettings;

    FrameCtrl.Form:=NewAlienPanel(parent,esNone);
    result:=FrameCtrl.Form.GetWindowHandle;

    FrameCtrl.Buttons :=MakeNewButtonGroup(FrameCtrl.Form,
        (FrameCtrl.ShowControls and scVolume)<>0,
        (FrameCtrl.ShowControls and scGap)<>0);

    FrameCtrl.Trackbar:=MakeNewTrackbar(FrameCtrl.Form);

    if FrameCtrl.UseBkPicture then
    begin
      FrameCtrl.BkBitmap:=FrameCtrl.LoadBkPicture(nil,true,FrameCtrl.BkDefFile);
      if FrameCtrl.BkBitmap=HBITMAP(-1) then
        FrameCtrl.BkBitmap:=0;
    end;

    with FrameCtrl.Form^ do
    begin
      MinWidth :=80;
      MinHeight:=30;
      OnPaint :=FrameCtrl.Paint;
      OnResize:=FrameCtrl.FrameResize;
    end;
  end;
end;

procedure DestroyFrameWindow;
begin
  FrameCtrl.Destroy;
end;
