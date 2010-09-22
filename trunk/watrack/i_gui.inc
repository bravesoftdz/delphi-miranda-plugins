{some visual stuff}

function OnTTBLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  ttb:TTBButtonV2;
begin
  PluginLink^.UnhookEvent(onloadhook);

  FillChar(ttb,SizeOf(ttb),0);
  ttb.cbSize :=SizeOf(ttb);
  ttb.dwFlags:=TTBBF_VISIBLE or TTBBF_SHOWTOOLTIP;

  // plugin status button
  if DisablePlugin<>dsPermanent then
    ttb.dwFlags:=ttb.dwFlags or TTBBF_PUSHED;

  ttb.hIconDn       :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnEnable));
  ttb.hIconUp       :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnDisable));
  ttb.wParamUp      :=1;
//  ttb.wParamDown    :=0;
  ttb.pszServiceUp  :=MS_WAT_PLUGINSTATUS;
  ttb.pszServiceDown:=MS_WAT_PLUGINSTATUS;
  ttb.name          :='WATrack status';
//  ttb.tooltipDn:='Disable Plugin';
//  ttb.tooltipUp:='Enable Plugin';
  ttbState:=CallService(MS_TTB_ADDBUTTON,integer(@ttb),0);
  CallService(MS_TTB_SETBUTTONOPTIONS,(ttbState shl 16)+TTBO_TIPNAME,
      dword(Translate('Disable Plugin')));
  result:=0;
end;

procedure CreateMenus;
var
  mi:TCListMenuItem;
begin
  FillChar(mi, sizeof(mi), 0);
  mi.cbSize       :=sizeof(mi);
  mi.szPopupName.a:=PluginShort;

  mi.hIcon        :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnEnable));
  mi.szName.a     :='Disable Plugin';
  mi.pszService   :=MS_WAT_PLUGINSTATUS;
  mi.popupPosition:=MenuDisablePos;
  hMenuDisable:=PluginLink^.CallService(MS_CLIST_ADDMAINMENUITEM,0,dword(@mi));
end;

procedure ChangeMenuIcons(f1:cardinal);
var
  mi:tClistMenuItem;
  p:PAnsiChar;
begin
  FillChar(mi,sizeof(mi),0);
  mi.cbSize:=sizeof(mi);
  mi.flags :=CMIM_NAME+CMIM_FLAGS+CMIM_ICON+f1;
  if f1<>0 then
  begin
    mi.hIcon   :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnDisable));
    mi.szName.a:='Enable Plugin';
  end
  else
  begin
    mi.hIcon   :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnEnable));
    mi.szName.a:='Disable Plugin';
  end;
  CallService(MS_CLIST_MODIFYMENUITEM,hMenuDisable,dword(@mi));

  if PluginLink^.ServiceExists(MS_TTB_SETBUTTONSTATE)<>0 then
  begin
    if f1<>0 then
    begin
      p:='Enable Plugin';
      CallService(MS_TTB_SETBUTTONSTATE,ttbState,TTBST_RELEASED)
    end
    else
    begin
      p:='Disable Plugin';
      CallService(MS_TTB_SETBUTTONSTATE,ttbState,TTBST_PUSHED);
    end;
    CallService(MS_TTB_SETBUTTONOPTIONS,(ttbState shl 16)+TTBO_TIPNAME,
        dword(Translate(p)));
  end;
end;

function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
//  ttb:TTBButtonV2; work only with TTBButton type :(
begin
  result:=0;
  FillChar(mi,SizeOf(mi),0);
  mi.cbSize:=sizeof(mi);
  mi.flags :=CMIM_ICON;

  mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnEnable));
  PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,hMenuDisable,dword(@mi));

{// toptoolbar
  if PluginLink^.ServiceExists(MS_TTB_GETBUTTONOPTIONS)<>0 then
  begin
    PluginLink^.CallService(MS_TTB_GETBUTTONOPTIONS,(ttbInfo shl 16)+TTBO_ALLDATA,dword(@ttb));
    ttb.hIconUp:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnInfo));
    ttb.hIconDn:=ttb.hIconUp;
    PluginLink^.CallService(MS_TTB_SETBUTTONOPTIONS,(ttbInfo shl 16)+TTBO_ALLDATA,dword(@ttb));

    PluginLink^.CallService(MS_TTB_GETBUTTONOPTIONS,(ttbState shl 16)+TTBO_ALLDATA,dword(@ttb));
    ttb.hIconDn:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnEnable));
    ttb.hIconUp:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnDisable));
    PluginLink^.CallService(MS_TTB_SETBUTTONOPTIONS,(ttbState shl 16)+TTBO_ALLDATA,dword(@ttb));
  end;
}
end;
