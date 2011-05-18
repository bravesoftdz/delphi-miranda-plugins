{Visual part}
function OnContactMenu(hContact:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
begin
  FillChar(mi,SizeOf(mi),0);
  mi.cbSize:=sizeof(mi);
  if StrCmp(PAnsiChar(CallService(MS_PROTO_GETCONTACTBASEPROTO,hContact,0)),
     PluginName)<>0 then
  begin
    mi.flags:=CMIM_FLAGS or CMIF_HIDDEN;
    PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,hCMenuItemPlay,tlparam(@mi));
  end
  else
  begin
    // play/Stop
    mi.flags:=CMIM_FLAGS or CMIM_ICON or CMIM_NAME;
    if THANDLE(hContact)<>ActiveContact then
    begin
      mi.szName.a:='Start broadcasting';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,tlparam(IcoBtnOn));
    end
    else
    begin
      mi.szName.a:='Stop broadcasting';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,tlparam(IcoBtnOff));
    end;
    PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,hCMenuItemPlay,tlparam(@mi));

    // record
    mi.flags:=CMIM_FLAGS or CMIM_ICON or CMIM_NAME;
    if CallService(MS_RADIO_RECORD,0,1)<>0 then
    begin
      mi.szName.a:='Stop record';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,tlparam(IcoBtnRecDn));
    end
    else
    begin
      mi.szName.a:='Start record';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,tlparam(IcoBtnRecUp));
    end;
  end;
  PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,hCMenuItemRec,tlparam(@mi));
  result:=0;
end;

procedure CreateMenu;
var
  mi:TCListMenuItem;
begin
  FillChar(mi, sizeof(mi), 0);
  mi.cbSize    :=sizeof(mi);
//  mi.popupPosition:=MenuUserInfoPos;
  mi.pszService:=MS_RADIO_RECORD;
  mi.szName.a  :='Start/Stop Record';
  hCMenuItemRec:=PluginLink^.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,lparam(@mi));

//!!  mi.flags        :=CMIF_NOTOFFLINE or CMIF_NOTOFFLIST;
  mi.hIcon      :=PluginLink^.CallService(MS_SKIN2_GETICON,0,lparam(IcoBtnOn));
  mi.pszService :=MS_RADIO_PLAYSTOP;
  mi.szName.a   :='Start/Stop broadcasting';
  hCMenuItemPlay:=PluginLink^.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,lparam(@mi));
end;

procedure RegisterIcons;
var
  sid:TSKINICONDESC;
begin
  FillChar(sid,SizeOf(TSKINICONDESC),0);
  sid.cbSize:=SizeOf(TSKINICONDESC);
  sid.cx:=16;
  sid.cy:=16;
  sid.szSection.a:='Protocols/mRadio';
  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(BTN_RECUP),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnRecUp;
  sid.szDescription.a:='Start record';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(BTN_RECDN),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnRecDn;
  sid.szDescription.a:='Stop record';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_MAIN),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnSettings;
  sid.szDescription.a:='Settings';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_ON),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnOn;
  sid.szDescription.a:='Broadcast ON';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_OFF),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnOff;
  sid.szDescription.a:='Broadcast OFF';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_ADD),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnAdd;
  sid.szDescription.a:='Add EQ preset';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_DEL),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnDel;
  sid.szDescription.a:='Delete EQ preset';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);
end;
