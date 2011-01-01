{Visual part}
function OnTTBLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  ttb:TTBButtonV2;
begin
  PluginLink^.UnhookEvent(onloadhook);
  tbUsed:=true;

  FillChar(ttb,SizeOf(ttb),0);
  ttb.cbSize :=SizeOf(ttb);
  ttb.dwFlags:=TTBBF_VISIBLE or TTBBF_SHOWTOOLTIP;
  ttb.hIconDn       :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnRecDn));
  ttb.hIconUp       :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnRecUp));
  ttb.pszServiceUp  :=MS_RADIO_RECORD;
  ttb.pszServiceDown:=MS_RADIO_RECORD;
  ttb.name          :='mRadio record';
  ttbRecord:=CallService(MS_TTB_ADDBUTTON,integer(@ttb),0);
  CallService(MS_TTB_SETBUTTONOPTIONS,(ttbRecord shl 16)+TTBO_TIPNAME,
      dword(Translate('Start record')));

  ttb.hIconDn       :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnSettings));
  ttb.hIconUp       :=ttb.hIconDn;
  ttb.pszServiceUp  :=MS_RADIO_SETTINGS;
  ttb.pszServiceDown:=MS_RADIO_SETTINGS;
  ttb.name          :='mRadio settings';
  ttbSettings:=CallService(MS_TTB_ADDBUTTON,integer(@ttb),0);
  CallService(MS_TTB_SETBUTTONOPTIONS,(ttbSettings shl 16)+TTBO_TIPNAME,
      dword(Translate('mRadio settings')));
  result:=0;
end;

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
    PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,hCMenuItemPlay,dword(@mi));
  end
  else
  begin
    // play/Stop
    mi.flags:=CMIM_FLAGS or CMIM_ICON or CMIM_NAME;
    if THANDLE(hContact)<>ActiveContact then
    begin
      mi.szName.a:='Start broadcasting';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnOn));
    end
    else
    begin
      mi.szName.a:='Stop broadcasting';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnOff));
    end;
    PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,hCMenuItemPlay,dword(@mi));

    // record
    mi.flags:=CMIM_FLAGS or CMIM_ICON or CMIM_NAME;
    if CallService(MS_RADIO_RECORD,1,0)<>0 then
    begin
      mi.szName.a:='Stop record';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnRecDn));
    end
    else
    begin
      mi.szName.a:='Start record';
      mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnRecUp));
    end;
  end;
  PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,hCMenuItemRec,dword(@mi));
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
  hCMenuItemRec:=pluginLink^.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,dword(@mi));

//!!  mi.flags        :=CMIF_NOTOFFLINE or CMIF_NOTOFFLIST;
  mi.hIcon      :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnOn));
  mi.pszService :=MS_RADIO_PLAYSTOP;
  mi.szName.a   :='Start/Stop broadcasting';
  hCMenuItemPlay:=PluginLink^.CallService(MS_CLIST_ADDCONTACTMENUITEM,0,dword(@mi));

end;

{
function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  ttb:TTBButtonV2;// work only with TTBButton type :(
begin
  result:=0;
  if PluginLink^.ServiceExists(MS_TTB_GETBUTTONOPTIONS)<>0 then
  begin
    PluginLink^.CallService(MS_TTB_GETBUTTONOPTIONS,(ttbRecord shl 16)+TTBO_ALLDATA,dword(@ttb));
    ttb.hIconUp:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnRecUp));
    ttb.hIconUp:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnRecDn));
    PluginLink^.CallService(MS_TTB_SETBUTTONOPTIONS,(ttbRecord shl 16)+TTBO_ALLDATA,dword(@ttb));
  end;
end;
}
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
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(BTN_RECDN),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnRecDn;
  sid.szDescription.a:='Stop record';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_MAIN),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnSettings;
  sid.szDescription.a:='Settings';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_ON),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnOn;
  sid.szDescription.a:='Broadcast ON';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_OFF),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnOff;
  sid.szDescription.a:='Broadcast OFF';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_ADD),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnAdd;
  sid.szDescription.a:='Add EQ preset';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_DEL),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnDel;
  sid.szDescription.a:='Delete EQ preset';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);
//  PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);
end;
