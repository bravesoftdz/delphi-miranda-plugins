{Frame variables}
var
  sic,
  PlStatusHook:cardinal;

  HiddenByMe:bool;

  FrmEffect,
  AlignCenter,
  FrameHeight:dword;

  FrameText:pWideChar;
  FrameLF:TLOGFONT;
  FrmTxtColor:TCOLORREF;
  RollStep,
  RollGap,
  RollTail:integer;
//  TotalTime:cardinal;

  hFrmTimer,          // frame refresh
  hTxtTimer:cardinal; // text scroll speed
  vFrmTimer,
  vTxtTimer:cardinal;

  changed:cardinal;
