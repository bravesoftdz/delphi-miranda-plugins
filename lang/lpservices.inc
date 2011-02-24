{
  LPHandle which used in services can be defined as [global] variable somethere in headers.
  to set it's value we just need to call MS_LANGPACK_GETPLUGINHANDLE service
}

const
  MS_LANGPACK_GETPLUGINHANDLE:PAnsiChar='LangPack/GetPluginHandle';
{
 wParam=flags
 lParam=(LPARAM)(const AnsiChar*)szEnglish
}
function TranslateString(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
	result := int(LangPackTranslateString(pAnsiChar(lParam),wParam));
end;

{
 wParam=(WPARAM)(HMENU)hMenu
 lParam=0
}
function TranslateMenu(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  Menu:HMENU;
  i:int;
	mii: MENUITEMINFO;
	str:array [0..255] of WideChar;
	res:pWideChar;
begin
  Menu := wParam;
	mii.cbSize := SizeOf(MenuItemInfo);//MENUITEMINFO_V4_SIZE;
	for i := GetMenuItemCount( Menu )-1 downto 0 do
	begin
		mii.fMask := MIIM_TYPE or MIIM_SUBMENU;
		mii.dwTypeData := @str;
		mii.cch := HIGH(str);
		GetMenuItemInfo(Menu, i, TRUE, mii);

		if (mii.cch<>0) and (mii.dwTypeData<>nil) then
		begin
			res := pWideChar(LangPackTranslateString(mii.dwTypeData, lParam or LANG_UNICODE));
//			if res <> mii.dwTypeData then
			begin
				mii.dwTypeData := pAnsiChar(res);
				mii.fMask := MIIM_TYPE;
				SetMenuItemInfo( Menu, i, TRUE, mii);
      end;
    end;

		if mii.hSubMenu <> 0 then
		  TranslateMenu(mii.hSubMenu, lParam);
	end;
	result := 0;
end;

procedure TranslateWindow( hwnd:HWND; lParam:LPARAM );
var
	title: array [0..2047] of WideChar;
	result:pWideChar;
begin
	GetWindowTextW(hwnd, title, SIZEOF( title ));
	begin
		result := pWideChar(LangPackTranslateString(pAnsiChar(@title), lParam or LANG_UNICODE));
//		if result <> title  then
			SetWindowTextW(hwnd, result );
  end;
end;

type
  pEnumDlgStruct = ^tEnumDlgStruct;
  tEnumDlgStruct = record
    LPHandle,
    lParam:LPARAM;
  end;
function TranslateDialogEnumProc(awnd:hwnd;Param:pdword):boolean; stdcall;
var
	lptd:PLANGPACKTRANSLATEDIALOG;
	szClass: array [0..31] of WideChar;
	i,id:int;
begin
  lptd := pointer(pEnumDlgStruct(Param).lParam);
	id := GetDlgCtrlID( awnd );

	if lptd^.ignoreControls <> nil then
	begin
	  i:=0;
	  while lptd^.ignoreControls[i]<>0 do
	  begin
	    if (lptd^.ignoreControls[i]=id) then
	    begin
	      result := true;
	      exit;
	    end;
	    inc(i);
	  end;
	end;

	GetClassName(awnd,@szClass,SIZEOF(szClass));

	if (lstrcmpiw(szClass,'static')=0) or
	   (lstrcmpiw(szClass,'hyperlink')=0) or
	   (lstrcmpiw(szClass,'button')=0) or
	   (lstrcmpiw(szClass,'MButtonClass')=0) or
	   (lstrcmpiw(szClass,'MHeaderbarCtrl')=0) then
		TranslateWindow( awnd, pEnumDlgStruct(Param).LPHandle )
	else if lstrcmpiw(szClass,'edit')=0 then
	begin
		if ((lptd^.flags and LPTDF_NOIGNOREEDIT)<>0) or
		   ((GetWindowLong(awnd,GWL_STYLE) and ES_READONLY)<>0) then
			TranslateWindow( awnd, pEnumDlgStruct(Param).LPHandle );
	end;
	result := TRUE;
end;

{
 wParam=0
 lParam=(LPARAM)(LANGPACKTRANSLATEDIALOG*)&lptd
}
function TranslateDialog(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
	lptd:PLANGPACKTRANSLATEDIALOG;
	tmp:tEnumDlgStruct;
begin
  lptd := pointer(lParam);
	if (lptd=nil) or (lptd^.cbSize<>sizeof(TLANGPACKTRANSLATEDIALOG)) then
	begin
	  result := 1;
	  exit;
	end;
	if (lptd^.flags and LPTDF_NOTITLE)=0 then
		TranslateWindow(lptd^.hwndDlg, wParam);

	tmp.lParam  :=lParam;
	tmp.LPHandle:=wParam;
	EnumChildWindows(lptd^.hwndDlg,@TranslateDialogEnumProc,dword(@tmp));
	result := 0;
end;

// Next 3 services didn't realized yet - too lazy
function GetDefaultCodePage(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
//  result := LangPackGetDefaultCodePage();
end;

function GetDefaultLocale(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
//  result := LangPackGetDefaultLocale();
end;

function PCharToTChar(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
//  result := int(LangPackPCharToTChar(pAnsiChar(lParam)));
end;

procedure LoadLangPackServices;
begin
	CreateServiceFunction(MS_LANGPACK_TRANSLATESTRING,@TranslateString);
	CreateServiceFunction(MS_LANGPACK_TRANSLATEMENU  ,@TranslateMenu);
	CreateServiceFunction(MS_LANGPACK_TRANSLATEDIALOG,@TranslateDialog);
	CreateServiceFunction(MS_LANGPACK_GETCODEPAGE    ,@GetDefaultCodePage);
	CreateServiceFunction(MS_LANGPACK_GETLOCALE      ,@GetDefaultLocale);
	CreateServiceFunction(MS_LANGPACK_PCHARTOTCHAR   ,@PcharToTchar);

	CreateServiceFunction(MS_LANGPACK_GETPLUGINHANDLE,@GetLangPackHandle);
	{ Example: in OnModulesLoad call it}
end;
(* Examples of Translating services wrapper

function TranslateW(sz: PWideChar): PWideChar;
begin
  Result := PWideChar(PluginLink^.CallService(MS_LANGPACK_TRANSLATESTRING,
    LPHandle shl 16 + LANG_UNICODE, lParam(sz)));
end;

function Translate(sz: PAnsiChar): PAnsiChar;
begin
  Result := PAnsiChar(PluginLink^.CallService(MS_LANGPACK_TRANSLATESTRING,
    LPHandle shl 16 + 0, lParam(sz)));
end;

function TranslateDialogDefault(hwndDlg: THandle): int;
var
  lptd: TLANGPACKTRANSLATEDIALOG;
begin
  lptd.cbSize         := sizeof(lptd);
  lptd.flags          := 0;
  lptd.hwndDlg        := hwndDlg;
  lptd.ignoreControls := nil;
  Result := PluginLink^.CallService(MS_LANGPACK_TRANSLATEDIALOG, LPHandle shl 16, lParam(@lptd));
end;
*)
