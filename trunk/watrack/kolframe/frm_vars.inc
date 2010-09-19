{Frame variables}
var
  sic,
  PlStatusHook:cardinal;

  HiddenByMe:bool;

  AlignCenter,
  FrameHeight:dword;

//  TotalTime:cardinal;

  hFrmTimer,          // frame refresh
  hTxtTimer:cardinal; // text scroll speed
  vFrmTimer,
  vTxtTimer:cardinal;

  changed:cardinal;
