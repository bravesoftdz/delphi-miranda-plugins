{popup variables}
const
  ActionList:PPOPUPACTION=nil;
var
  PopTitle,
  PopText:pWideChar;
  PopRequest,
  PopUpFile:dword;
  PopUpColor:dword;
  PopUpFore,
  PopUpBack:cardinal;
  PopUpPause:cardinal;
  PopUpDelay:integer;
  PopUpAction:cardinal;

  DisablePlugin:integer;
  IsPopup2Present:boolean;
  isFreeImagePresent:boolean;
var
  hMenuInfo   :THANDLE;
  ssmi,sic,
  plStatusHook:THANDLE;
  PopupPresent:Bool;
  opthook:THANDLE;
  ttbInfo:THANDLE;