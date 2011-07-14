{}

//===== Support =====

function AddIcolibIcon(var ActionItem:MyActionItem):THANDLE;
var
  sid:TSKINICONDESC;
begin
	if ActionItem.hIcolibIconOn=0 then
	begin
    // add icon for action to icolib
    fillChar(sid,SizeOf(sid),0);
    sid.cbSize         :=sizeof(sid);
    sid.szSection    .w:=ICOLIB_ACTSECTION;
    sid.szDescription.w:=ActionItem.szActDescr;
    sid.pszName        :=ActionItem.szNameID;
//    sid.szDefaultFile.w:=tszMyPath;
    sid.iDefaultIndex  :=-IDI_ACTION;
    sid.cx             :=16;
    sid.cy             :=16;
    sid.flags          :=SIDF_ALL_UNICODE;
    result:=CallService(MS_SKIN2_ADDICON,0,LPARAM(@sid));
	end
	else
		result:=ActionItem.hIcolibIconOn;
end;

procedure DeleteIcolibIcon(var ActionItem:MyActionItem);
begin
	//will work only in MIM0.8.0.13+ (Rev7555+) - otherwise it will crash !
//	DWORD dwMirVer = CallService(MS_SYSTEM_GETVERSION, 0, 0);
//	if (dwMirVer >= 0x0008000D)
  CallService(MS_SKIN2_REMOVEICON,0,LPARAM(ActionItem.szNameID));
end;

//===== Really places =====

//----- Hotkeys -----

function AddCoreHotkey(var ActionItem:MyActionItem):boolean;
var
  hkd:THOTKEYDESC;
begin
	if (ActionItem.flags and UAF_HKREGGED)=0 then
	begin
	  FillChar(hkd,SizeOf(hkd),0);
		hkd.cbSize          := HOTKEYDESC_SIZE_V1;//SizeOf(hkd);
		hkd.pszName         := ActionItem.szNameID;
		hkd.pszDescription.w:= ActionItem.szActDescr;
		hkd.pszSection    .w:= MODULE;
		hkd.pszService      := SERVICE_WITH_LPARAM_NAME;
		hkd.lParam          := ActionItem.dwActID;
		result:=CallService(MS_HOTKEY_REGISTER,0,LPARAM(@hkd))<>0;
		if result then
      ActionItem.flags:=ActionItem.flags or UAF_HKREGGED;
	end
	else
    result:=true; //!!
end;

procedure DeleteCoreHotkey(var ActionItem:MyActionItem);
begin
	//delete core hotkeys
	//will work only from 0.8.0.15+ (Rev.7786+)
	// and bug with crash when hotkey synonims were used is fixed in 0.8.0.27 (Rev.8831)
	if // bCoreHotkeyPresents and
	   // (ServiceExists(MS_HOTKEY_UNREGISTER)<>0) and
	   ((ActionItem.flags and UAF_HKREGGED)<>0) then
	begin
		CallService(MS_HOTKEY_UNREGISTER,0,LParam(ActionItem.szNameID));
    ActionItem.flags:=ActionItem.flags and not UAF_HKREGGED;
	end;
end;

//-----  -----

