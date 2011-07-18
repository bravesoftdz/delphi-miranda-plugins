{}

//===== Support =====

function AddIcolibIcon(var ActionItem:tMyActionItem):THANDLE;
var
  sid:TSKINICONDESC;
  buf,buf1:array [0..63] of WideChar;
begin
  if ActionItem.hIcolibIcon=0 then
  begin
    // add icon for action to icolib
    fillChar(sid,SizeOf(sid),0);
    sid.cbSize         :=sizeof(sid);
    sid.szSection    .w:=ICOLIB_ACTSECTION;
    sid.szDefaultFile.w:=szMyPath;
    sid.iDefaultIndex  :=-IDI_ACTION;
    sid.cx             :=16;
    sid.cy             :=16;
    sid.flags          :=SIDF_ALL_UNICODE;
    // icon "on"
    sid.szDescription.w:=ActionItem.szActDescr;
    sid.pszName        :=ActionItem.szNameID;
    ActionItem.hIcolibIcon:=CallService(MS_SKIN2_ADDICON,0,LPARAM(@sid));
    result:=ActionItem.hIcolibIcon;
    // icon "off"
    StrCopyW(StrCopyEW(buf,ActionItem.szActDescr),' (pressed)');
    sid.szDescription.w:=@buf;
    StrCopy(StrCopyE(@buf1,ActionItem.szNameID),'_pressed');
    sid.pszName        :=@buf1;
    ActionItem.hIcolibIconPressed:=CallService(MS_SKIN2_ADDICON,0,LPARAM(@sid));
  end
  else
    result:=ActionItem.hIcolibIcon;
end;

procedure DeleteIcolibIcon(var ActionItem:tMyActionItem);
begin
  //will work only in MIM0.8.0.13+ (Rev7555+) - otherwise it will crash !
//  DWORD dwMirVer = CallService(MS_SYSTEM_GETVERSION, 0, 0);
//  if (dwMirVer >= 0x0008000D)
  CallService(MS_SKIN2_REMOVEICON,0,LPARAM(ActionItem.szNameID));
end;

//===== Really places =====

//----- Hotkeys -----

function AddCoreHotkey(var ActionItem:tMyActionItem):boolean;
var
  hkd:THOTKEYDESC;
begin
  if (ActionItem.flags and UAF_HKREGGED)=0 then
  begin
    FillChar(hkd,SizeOf(hkd),0);
    hkd.cbSize          := HOTKEYDESC_SIZE_V1;//SizeOf(hkd);
    hkd.pszName         := ActionItem.szNameID;
    hkd.pszDescription.w:= ActionItem.szActDescr;
    hkd.pszSection    .w:= 'Actions';
    hkd.pszService      := SERVICE_WITH_LPARAM_NAME;
    hkd.lParam          := ActionItem.dwActID;
    result:=CallService(MS_HOTKEY_REGISTER,0,LPARAM(@hkd))<>0;
    if result then
      ActionItem.flags:=ActionItem.flags or UAF_HKREGGED;
  end
  else
    result:=true; //!!
end;

procedure DeleteCoreHotkey(var ActionItem:tMyActionItem);
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

//----- Common menu functions -----

procedure DeleteMenuItem(var ActionItem:tMyActionItem;mtype:tMenuType;service:pAnsiChar);
begin
  with ActionItem.UAMenuItem[mtype] do
  begin
    if hMenuItem=0 then exit;

    CallService(service,hMenuItem,0);

    hMenuItem:=0;
  end;
end;

function AddRootMenuIcon(szPopupName:pWideChar):THANDLE;
var
  sid:TSKINICONDESC;
begin
  FillChar(sid,SizeOf(sid),0);
  //first - register icon for root popup
  sid.cbSize         := sizeof(sid);
  sid.szSection.w    := ICOLIB_MNUSECTION;
  sid.flags          := SIDF_ALL_UNICODE;
  sid.cx             := 16;
  sid.cy             := 16;
  sid.szDescription.w:= szPopupName;
  sid.szDefaultFile.w:= szMyPath;
  sid.iDefaultIndex  := -IDI_ACTION;
  WideToAnsi(szPopupName,sid.pszName);
  result:=CallService(MS_SKIN2_ADDICON,0,LPARAM(@sid));
  mFreeMem(sid.pszName);
end;

(*
function ProcessPopup(var ActionItem:tMyActionItem;mtype:tMenuType;var clmi:TCListMenuItem):int;
var
  i:integer;
  ActMItem,UAMenuItem:pUAMenuItem;
  ActItem:pMyActionItem;
begin
  clmi.flags:=CMIF_UNICODE or CMIF_ICONFROMICOLIB;
   // register Menu items
   UAMenuItem:=@ActionItem.UAMenuItem[mtype];
   // if need to create Popup
  if (UAMenuItem.szMenuPopup<>nil) and (UAMenuItem.szMenuPopup^<>#0) then
  begin
     // first search if we have already created root popup with same name
    for i:=0 to HIGH(UActionList) do
    begin
      // try to find root popup with same name (if we already created one)
      ActItem:=@UActionList[i];
      ActMItem:=@ActItem.UAMenuItem[mtype];
      if (ActMItem.szMenuPopup.w^<>nil) and
        ( (StrCmpW(ActMItem.szMenuPopup.w,UAMenuItem.szMenuPopup.w)=0) and
          (ActItem<>@ActionItem) ) then
      begin
        clmi.szPopupName.w:=ActMItem.hMenuRoot;
        //mi.position = -1999901010;
        UAMenuItem.hMenuRoot:=ActMItem.hMenuRoot;
        break;
      end;
     end;

    // haven't found - then make one!
     if clmi.szPopupName.w=nil then
     begin
       clmi.icolibItem:=AddRootMenuIcon(ActionItem.tszTMenuPopup);
       //then register root popup itself
       clmi.ptszName     :=UActionItem.szMenuPopup;
       clmi.flags        :=clmi.flags or CMIF_ROOTPOPUP;
       clmi.szPopupName.w:=pWideChar(HGENMENU_ROOT);

       ActionItem.hTMenuRoot:=CallService(MS_CLIST_ADDTRAYMENUITEM,0,LPARAM(@clmi));

       clmi.szPopupName.w:=PWideChar(ActionItem.hMenuRoot);
       clmi.flags        :=clmi.flags and not CMIF_ROOTPOPUP;
       //mi.position = -1999901010;
     end;
    clmi.flags:=clmi.flags or CMIF_CHILDPOPUP;
   end
   // need to remove Popup (if presents)
   else
   begin
   end;
end;
*)

function PreBuildMenu(var ActionItem:tMyActionItem;mtype:tMenuType;hContact:THANDLE=0):int;
var
  i:integer;
  mi:TCListMenuItem;
  p:pWideChar;
begin
  result:=0;

  FillChar(mi,SizeOf(mi),0);
  mi.cbSize:=SizeOf(mi);

  for i:=0 to HIGH(UActionList) do
  begin
    mi.flags:=CMIM_FLAGS or CMIF_HIDDEN;
    p:=nil;
    with UActionList[i] do
    begin
      with UAMenuItem[mtype] do
      begin
        if hMenuItem<>0 then // it means, we process that item here
        begin
          // Show / hide
          if isVarsInstalled then
          begin
            if (szMenuShowWhenVars<>nil) and (szMenuShowWhenVars^<>#0) then
            begin
              p:=ParseVarString(szMenuShowWhenVars,hContact);
              if p<>nil then
              begin
                if StrCmpW(p,'1')=0 then
                  mi.flags:=CMIM_FLAGS;
                mFreeMem(p);
              end;
            end;
          end;

          // new name
          mi.flags:=mi.flags or CMIM_NAME or CMIF_UNICODE;
          if (szMenuNameVars<>nil) and (szMenuNameVars^<>#0) then
            mi.szName.w:=ParseVarString(szMenuNameVars,hContact);

          if mi.szName.w=nil then
            StrDupW(mi.szName.w,szActDescr);

          //!!!! icon
          mi.flags:=mi.flags or CMIM_ICON;
          if pressed then
            mi.hIcon:=hIcolibIconPressed
          else
            mi.hIcon:=hIcolibIcon;
        end;
        CallService(MS_CLIST_MODIFYMENUITEM,hMenuItem,LPARAM(@mi));
      end;
      mFreeMem(mi.szName.w);
    end;

  end;
end;

//----- Main Menu -----

procedure AddMainMenuItem(var ActionItem:tMyActionItem);
begin
  if ActionItem.UAMenuItem[main_menu].hMenuItem<>0 then exit;
end;

procedure DeleteMainMenuItem(var ActionItem:tMyActionItem);
begin
  DeleteMenuItem(ActionItem,main_menu,MS_CLIST_REMOVEMAINMENUITEM);
end;

function PreBuildMainMenu(wParam:WPARAM;lParam:LPARAM):int;
begin
  result:=0;
end;

//----- Contact Menu -----

procedure AddContactMenuItem(var ActionItem:tMyActionItem);
begin
  if ActionItem.UAMenuItem[contact_menu].hMenuItem<>0 then exit;
end;

procedure DeleteContactMenuItem(var ActionItem:tMyActionItem);
begin
  DeleteMenuItem(ActionItem,contact_menu,MS_CLIST_REMOVECONTACTMENUITEM);
end;

function PreBuildContactMenu(wParam:WPARAM;lParam:LPARAM):int;
begin
  result:=0;
end;

//----- Tray Menu -----
(*
   clmi.pszService = ActionItem->szNameID;
   if (!ActionItem->hMenuService)
     ActionItem->hMenuService = (HANDLE)CreateServiceFunctionParam(clmi.pszService, ServiceCallWithFParam, ActionItem->dwActID);

   clmi.ptszName = ActionItem->tszActDescr;
   clmi.icolibItem = ActionItem->hIcolibIcon;

   //if (!_tcscmp(ActionItem->tszCMenuName, _T("-----"))) {
     //mi.position += 100000;
   return (HANDLE)CallService(MS_CLIST_ADDTRAYMENUITEM,0,(LPARAM)&clmi);
}
*)

procedure AddTrayMenuItem(var ActionItem:tMyActionItem);
var
  mi:TCListMenuItem;
  mname:pWideChar;
begin
  if ACtionItem.UAMenuItem[tray_menu].hMenuItem<>0 then exit;

//  if PluginLink^.ServiceExists(MS_CLIST_ADDTRAYMENUITEM)<>0 then
    begin
      FillChar(mi,SizeOf(mi),0);
      mi.cbSize    :=sizeof(mi);
      mi.flags     :=CMIF_UNICODE;//+CMIF_ICONFROMICOLIB
      mi.hIcon     :=ActionItem.hIcolibIcon;
//      mi.pszService:=//MS_RADIO_TRAYMENU;
{
      if (ActionItem.szTMenuNameVars<>nil) and (ActionItem.szMenuNameVars^<>#0) then
        mname:=ParseVarString(ActionItem.szMenuNameVars)
      else
        mname:=ActionItem.szActDescr;
      mi.szName.w:=mname;
}
{
      if (ActionItem.szTMenuPopup<>nil) and (ActionItem.szTMenuPopup^<>#0) then
        mpopup:=ParseVarString(ActionItem.szTMenuPopup)
      else
        mpopup:=nil;
      mi.szPopupName.w:=mpopup;
}
//      ActionItem.hMenuItem:=PluginLink^.CallService(MS_CLIST_ADDTRAYMENUITEM,0,lparam(@mi));

      if mname<>ActionItem.szActDescr then
        mFreeMem(mname);
//      if mpopup<>nil                   then mFreeMem(mpopup);
    end;
end;

procedure DeleteTrayMenuItem(var ActionItem:tMyActionItem);
begin
  DeleteMenuItem(ActionItem,tray_menu,MS_CLIST_REMOVETRAYMENUITEM);
end;

function PreBuildTrayMenu(wParam:WPARAM;lParam:LPARAM):int;
begin
  result:=0;
end;

//----- Modern Toolbar -----

procedure AddMTBButton(var ActionItem:tMyActionItem);
begin
end;

procedure DeleteMTBButton(var ActionItem:tMyActionItem);
begin
  if ActionItem.hMTBButton<>0 then
  begin
    CallService(MS_TB_REMOVEBUTTON,ActionItem.hMTBButton,0);
    ActionItem.hMTBButton:=0;
  end;
end;

function OnMTBLoaded(wParam:WPARAM;lParam:LPARAM):int;
begin
  result:=0;
end;

//----- TabSRMM Toolbar -----
procedure AddTabBBButton(var ActionItem:tMyActionItem);
begin
end;

procedure DeleteTabBBButton(var ActionItem:tMyActionItem);
begin
end;

function OnTabBBLoaded(wParam:WPARAM;lParam:LPARAM):int;
begin
  result:=0;
end;

function OnTabButtonPressed(wParam:WPARAM;lParam:LPARAM):int;
begin
  result:=0;
end;
