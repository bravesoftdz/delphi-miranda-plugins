{Frame variables}
const
  Cover    :PAnsiChar=nil;
  lastbkpic:PAnsiChar=nil;
var
  FrameText:pWideChar;
  BMPFilter:PWideChar;
  FrameWnd:hwnd;
  FrameId:integer;
  sic,
  PlStatusHook:cardinal;

  isFreeImagePresent:bool;
  HiddenByMe:bool;
  HideFrameNoMusic,
  HideFrameNoPlayer:cardinal;
  padding:TRect;
  FrmBkPic:PAnsiChar;
  ShowControls:set of byte;
  FrmUsePic,
  FrmUseCover,
  StyledTrack,
  ButtonGap,
  FrmEffect,
  AlignCenter,
  FrameHeight:dword;
  FrameLF:TLOGFONT;
  FrmBkColor,
  FrmTxtColor:TCOLORREF;
  hBkPic:HBITMAP;
  FrmBkMode:dword;
  FrmAlpha:cardinal;
  FrmBrush:HBRUSH;
  RollStep,
  RollGap,
  RollTail:integer;
  TotalTime:cardinal;
  FrmBkBuf:HDC;
  FrmBkBmp:HBITMAP;

  hFrmTimer,          // frame refresh
  hTxtTimer:cardinal; // text scroll speed
  vFrmTimer,
  vTxtTimer:cardinal;

  changed:cardinal;
