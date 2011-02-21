{}

{
 wParam=flags
 lParam=(LPARAM)(const AnsiChar*)szEnglish
}
function TranslateString(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
	result := int(LangPackTranslateString(pAnsiChar(lParam),
            ORD((wParam and LANG_UNICODE)<>0)));
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
			res := pWideChar(LangPackTranslateString(mii.dwTypeData, LANG_UNICODE));
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

procedure TranslateWindow( hwnd:HWND );
var
	title: array [0..2047] of WideChar;
	result:pWideChar;
begin
	GetWindowTextW(hwnd, title, SIZEOF( title ));
	begin
		result := pWideChar(LangPackTranslateString(pAnsiChar(@title), LANG_UNICODE));
//		if result <> title  then
			SetWindowTextW(hwnd, result );
  end;
end;

function TranslateDialogEnumProc(awnd:hwnd;Param:pdword):boolean; stdcall;
var
	lptd:PLANGPACKTRANSLATEDIALOG;
	szClass: array [0..31] of WideChar;
	i,id:int;
begin
  lptd := pointer(Param);
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
		TranslateWindow( awnd )
	else if lstrcmpiw(szClass,'edit')=0 then
	begin
		if ((lptd^.flags and LPTDF_NOIGNOREEDIT)<>0) or
		   ((GetWindowLong(awnd,GWL_STYLE) and ES_READONLY)<>0) then
			TranslateWindow( awnd );
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
begin
  lptd := pointer(lParam);
	if (lptd=nil) or (lptd^.cbSize<>sizeof(TLANGPACKTRANSLATEDIALOG)) then
	begin
	  result := 1;
	  exit;
	end;
	if (lptd^.flags and LPTDF_NOTITLE)=0 then
		TranslateWindow(lptd^.hwndDlg);

	EnumChildWindows(lptd^.hwndDlg,@TranslateDialogEnumProc,lParam);
	result := 0;
end;

function GetDefaultCodePage(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
//  result := LangPackGetDefaultCodePage();
end;

function GetDefaultLocale(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
//  result := LangPackGetDefaultLocale();
end;

function PcharToTchar(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
//  result := int(LangPackPcharToTchar(pAnsiChar(lParam)));
end;

procedure LoadLangPackServices;
begin
	CreateServiceFunction(MS_LANGPACK_TRANSLATESTRING,@TranslateString);
	CreateServiceFunction(MS_LANGPACK_TRANSLATEMENU  ,@TranslateMenu);
	CreateServiceFunction(MS_LANGPACK_TRANSLATEDIALOG,@TranslateDialog);
	CreateServiceFunction(MS_LANGPACK_GETCODEPAGE    ,@GetDefaultCodePage);
	CreateServiceFunction(MS_LANGPACK_GETLOCALE      ,@GetDefaultLocale);
	CreateServiceFunction(MS_LANGPACK_PCHARTOTCHAR   ,@PcharToTchar);
end;
