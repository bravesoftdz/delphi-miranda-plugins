{Frame + background}

type
  PWATFrame = ^TWATFrame;
  TWATFrame = object(TObj)
    BkDC     :HDC;       // "buffer" DC and associated bitmap
    BkBitmap :HBITMAP;   // original bitmap
    BkFile   :PAnsiChar; // original bitmap filename
    BkDefFile:PAnsiChar; // default background picture filename
    BkMode   :cardinal;

    Form     :PControl;
    Trackbar :PTrackbar;
    Buttons  :PControl;

    destructor Destroy; virtual;
    procedure Paint(Sender: PControl; DC: HDC);

    procedure PreparePicture(dc:HDC;rc:TRECT);
    function  LoadBkPicture(BackFName:PAnsiChar;CoverFName:PAnsiChar=nil):integer;
    procedure SaveSettings;
    procedure LoadSettings;
  end;

var
  FrameCtrl:PWATFrame;

procedure TWATFrame.SaveSettings;
begin
end;

procedure TWATFrame.LoadSettings;
begin
  FrmUsePic   :=DBReadByte (0,PluginShort,opt_FrmUsePic ,BST_UNCHECKED);
  FrmUseCover :=DBReadByte (0,PluginShort,opt_FrmUseCvr ,BST_UNCHECKED);
//??  FrmBkColor  :=DBReadDWord(0,PluginShort,opt_FrmBkColor,$00E0E0E0);
  BkMode   :=DBReadWord (0,PluginShort,opt_FrmBkMode ,0);
//(onrequirement)  FrmAlpha    :=DBReadByte (0,PluginShort,opt_FrmAlpha  ,255);

  BkDefFile   :=DBReadString(0,PluginShort,opt_FrmBkPic,nil);
{
  padding.left  :=DBReadWord(0,PluginShort,opt_PadLeft  ,0);
  padding.top   :=DBReadWord(0,PluginShort,opt_PadTop   ,0);
  padding.right :=DBReadWord(0,PluginShort,opt_PadRight ,0);
  padding.bottom:=DBReadWord(0,PluginShort,opt_PadBottom,0);

}
end;

{$include i_bitmap.inc}

procedure TWATFrame.Paint(Sender: PControl; DC: HDC);
var
  rc: TRect;
  br:HBRUSH;
begin
  GetClientRect(Sender.Handle,rc); // expand to 1 more?
  if (BkDC=0) and (BkBitmap<>0) then
    PreparePicture(dc,rc);

  if BkDC<>0 then
  begin
    BitBlt(dc,rc.left,rc.top,rc.right-rc.left,rc.bottom-rc.top,
           BkDC,rc.left,rc.top,SRCCOPY);
  end
  else
  begin
    br:=CreateSolidBrush(FrmBkColor);
    FillRect(dc,rc,br);
    DeleteObject(br);
  end;
{
  Sender.Canvas.Brush.BrushBitmap := BkBmp;
  Sender.Canvas.FillRect(CR);
}
end;

// JUST LOAD picture, no matter, which transforms
// Backname = from settings, Covername = from data (higher priority)
// -1 - same file, 0 - can't load, other - new bitmap
function TWATFrame.LoadBkPicture(BackFName:PAnsiChar;CoverFName:PAnsiChar=nil):integer;
var
  tmpstr:PAnsiChar;
begin
  result:=-1; // "Same file" code

  // check the same file, ie only 'next pic'
  if (CoverFName<>nil) and (CoverFName^<>#0) then
  begin
    if StrCmp(CoverFName,BkFile)=0 then Exit;

    result:=CallService(MS_UTILS_LOADBITMAP,0,dword(CoverFName));
    if result<>0 then
    begin
        mFreeMem(BkFile);
        StrDup(BkFile,CoverFName);
      Exit;
    end;
  end;

  tmpstr:=ParseVarString(BackFName);
  if (tmpstr<>nil) and (tmpstr^<>#0) then
  begin
    if StrCmp(tmpstr,BkFile)=0 then exit;
 
    result:=CallService(MS_UTILS_LOADBITMAP,0,dword(tmpstr));
    if result<>0 then
    begin
      mFreeMem(BkFile);
      StrDup(BkFile,tmpstr);
    end;
  end;
  mFreeMem(tmpstr);
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
    DeleteObject(tmpBmp);
  end;
  if BkBitmap<>0 then
    DeleteObject(BkBitmap);

  inherited;
end;

function CreateFrameWindow(parent:HWND):THANDLE;
var
  panel:PControl;
begin
  result:=0;

  New(FrameCtrl,Create);
  if FrameCtrl<>nil then
  begin
    FrameCtrl.BkDC:=0;
    FrameCtrl.BkFile:=nil;

    FrameCtrl.Form:=NewAlienPanel(parent,esNone);
    result:=FrameCtrl.Form.GetWindowHandle;

    FrameCtrl.Buttons :=MakeNewButtonGroup(FrameCtrl.Form);
    FrameCtrl.Trackbar:=MakeNewTrackbar   (FrameCtrl.Form);
//    FrameCtrl.BkBitmap:=LoadBitmap(0,PAnsiChar(OBM_CLOSE));
    FrameCtrl.BkBitmap:=FrameCtrl.LoadBkPicture('%miranda_path%\Skins\Avatar\panda.gif');
    if FrameCtrl.BkBitmap=HBITMAP(-1) then
      FrameCtrl.BkBitmap:=0;

    with FrameCtrl.Form^ do
    begin
      MinWidth :=80;
      MinHeight:=30;
      OnPaint:=FrameCtrl.Paint;
    end;
  end;
end;

procedure DestroyFrameWindow;
begin
  FrameCtrl.Destroy;
end;
