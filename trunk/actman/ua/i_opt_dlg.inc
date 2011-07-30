{}
const
  settings:HWND = 0;
const
  NumControls = 15;

  IDsArray:array [0..NumControls-1] of integer =(
    // Menu settings controls
    IDC_UA_SEPARATE ,IDC_UA_POPUPT   ,IDC_UA_POPUPV,
    IDC_UA_VARNAMEST,IDC_UA_VARNAMESV,IDC_UA_VARNAMESH,
    IDC_UA_SHOWVART ,IDC_UA_SHOWVARV ,IDC_UA_SHOWVARH,
    // toolbar settings controls
    IDC_UA_TWOSTATE ,IDC_UA_COMMON,
    IDC_UA_TTNORMALT,IDC_UA_TTNORMALV,IDC_UA_TTPRESSEDT,IDC_UA_TTPRESSEDV
    );

  // Show-hide controls by place type
  SHArray:array [0..NumTypes-1, 0..NumControls-1] of integer = (
    (SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,
     SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW),
    (SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,
     SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW),
    (SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,
     SW_SHOW,SW_SHOW,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE),
    (SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,
     SW_SHOW,SW_SHOW,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE),
    (SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,
     SW_SHOW,SW_SHOW,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE),
    (SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,
     SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE)
    );
  // additional show/hide controls check by Variables installings (1 - need to check)
  SHVarArray:array [0..NumControls-1] of byte = (
    0,0,0,    0,0,1,    1,1,1,
    0,0,0,0,0,0);
  // additional enable/disable controls check (1 - always enable)
  EnDisArray:array [0..NumControls-1] of byte = (
    0,0,0,    0,0,0,    0,0,0,
    1,1,0,0,0,0);

var
  hIC:THANDLE;

procedure CheckPlacesAbility;
var
  i:integer;
begin
  for i:=0 to NumTypes-1 do
  begin
    with NamesArray[i] do
    begin
      enable:=(service=nil) or (PluginLink^.ServiceExists(service)<>0);
    end;
  end;
end;

function CompareItem(lParam1,lParam2:LPARAM;SortType:LPARAM):int; stdcall;
begin
  result:=UActionList[lParam1].wSortIndex-UActionList[lParam2].wSortIndex;
end;

//  Show or hide option items
procedure SetupControls(Dialog:HWND;atype:integer;item:integer=-1);
var
  i: cardinal;
  typ:integer;
  wnd,wnd1:HWND;
  enable:boolean;
begin
  if atype<0 then
  begin
    for i:=0 to NumControls-1 do
    begin
      ShowWindow(GetDlgItem(Dialog,IDsArray[i]),SW_HIDE);
    end;
  end
  else
  begin
    wnd1:=GetDlgItem(Dialog,IDC_UA_PLACELIST);
    if item<0 then
      item:=SendMessage(wnd1,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
    enable:=ListView_GetCheckState(wnd1,item)<>0;

    for i:=0 to NumControls-1 do
    begin
      typ:=SHArray[atype][i];
      if typ=SW_SHOW then
        if (SHVarArray[i]<>0) and (not IsVarsInstalled) then
          typ:=SW_HIDE;
      wnd:=GetDlgItem(Dialog,IDsArray[i]);
      ShowWindow(wnd,typ);
      EnableWindow(wnd,enable or (EnDisArray[i]<>0));
    end;
    // personal settings
    case atype of
      uaMTB, uaTAB: begin
        enable:=false;
        if IsDlgButtonChecked(Dialog,IDC_UA_TWOSTATE)<>BST_UNCHECKED then
          if IsWindowEnabled(GetDlgItem(Dialog,IDC_UA_TTNORMALV)) then
            enable:=true;
        EnableWindow(GetDlgItem(Dialog,IDC_UA_TTPRESSEDV),enable);
      end;
    end;
  end;
end;

// Clear all screen buttons/text fields (reset)
procedure ClearControls(Dialog:HWND);
begin
  CheckDlgButton (Dialog,IDC_UA_TWOSTATE ,BST_UNCHECKED);

  CheckDlgButton (Dialog,IDC_UA_SEPARATE ,BST_UNCHECKED);
  SetDlgItemTextW(Dialog,IDC_UA_POPUPV   ,nil);
  SetDlgItemTextW(Dialog,IDC_UA_VARNAMESV,nil);
  SetDlgItemTextW(Dialog,IDC_UA_SHOWVARV ,nil);
end;

procedure ShowSubAction(Dialog:HWND;aType:integer;item:integer=-1);
begin
  ClearControls(Dialog);
  SetupControls(Dialog,aType,item);

  // get UAction number
  item:=LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),item);

  // common settings
  if (UActionList[item].flags and UAF_2STATE)<>0 then
    CheckDlgButton(Dialog,IDC_UA_TWOSTATE,BST_CHECKED);

  // Show real UA settings
  case aType of
    uaMTB: begin // CList modern toolbar
      with UActionList[item] do
      begin
        SetDlgItemTextA(Dialog,IDC_UA_TTNORMALV ,szMTBTooltip);
        SetDlgItemTextA(Dialog,IDC_UA_TTPRESSEDV,szMTBTooltipPressed);
      end;
    end;

    uaTAB: begin // TabSRMM toolbar
      with UActionList[item] do
      begin
        SetDlgItemTextW(Dialog,IDC_UA_TTNORMALV ,szTabBTooltip);
        SetDlgItemTextW(Dialog,IDC_UA_TTPRESSEDV,szTabBTooltipPressed);
      end;
    end;

    uaMain: begin // Main menu
      with UActionList[item] do
      begin
        if (flags and UAF_MMENUSEP)<>0 then
          CheckDlgButton(Dialog,IDC_UA_SEPARATE,BST_CHECKED);
        with UAMenuItem[main_menu] do
        begin
          SetDlgItemTextW(Dialog,IDC_UA_POPUPV   ,szMenuPopup);
          SetDlgItemTextW(Dialog,IDC_UA_VARNAMESV,szMenuNameVars);
          SetDlgItemTextW(Dialog,IDC_UA_SHOWVARV ,szMenuShowWhenVars);
        end;
      end;
    end;

    uaContact: begin // Contact menu
      with UActionList[item] do
      begin
        if (flags and UAF_CMENUSEP)<>0 then
          CheckDlgButton(Dialog,IDC_UA_SEPARATE,BST_CHECKED);
        with UAMenuItem[contact_menu] do
        begin
          SetDlgItemTextW(Dialog,IDC_UA_POPUPV   ,szMenuPopup);
          SetDlgItemTextW(Dialog,IDC_UA_VARNAMESV,szMenuNameVars);
          SetDlgItemTextW(Dialog,IDC_UA_SHOWVARV ,szMenuShowWhenVars);
        end;
      end;
    end;

    uaTray: begin // Tray menu
      with UActionList[item] do
      begin
        if (flags and UAF_TMENUSEP)<>0 then
          CheckDlgButton(Dialog,IDC_UA_SEPARATE,BST_CHECKED);
        with UAMenuItem[tray_menu] do
        begin
          SetDlgItemTextW(Dialog,IDC_UA_POPUPV   ,szMenuPopup);
          SetDlgItemTextW(Dialog,IDC_UA_VARNAMESV,szMenuNameVars);
          SetDlgItemTextW(Dialog,IDC_UA_SHOWVARV ,szMenuShowWhenVars);
        end;
      end;
    end;

    uaHotkey: begin // Hotkey
      // Settings in Customize/Hotkeys
    end;
  end;
end;

procedure ShowAction(Dialog:HWND;item:integer=-1);
var
  i:integer;
  wnd:HWND;
  li:LV_ITEMW;
  buf:array [0..255] of WideChar;
begin
  wnd:=GetDlgItem(Dialog,IDC_UA_PLACELIST);
  i:=LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),item);
  if i>=0 then
  begin
    with UActionList[i] do
    begin
      // make "places" list
      SendMessage(wnd,LVM_DELETEALLITEMS,0,0);
      for i:=0 to NumTypes-1 do
      begin
        with NamesArray[i] do
        begin
          if enable then // cached ability flag
          begin
            li.mask    :=LVIF_TEXT+LVIF_PARAM;
            li.iSubItem:=0;
            li.iItem   :=i;
            li.lParam  :=i;
            li.pszText :=TranslateW(FastAnsiToWideBuf(name,buf));
            li.iItem   :=SendMessageW(wnd,LVM_INSERTITEMW,0,LPARAM(@li));
            ListView_SetCheckState(wnd,li.iItem,(flags and mask)<>0);
          end;
        end;
      end;
      ListView_SetItemState(wnd,0,
        LVIS_FOCUSED or LVIS_SELECTED,
        LVIS_FOCUSED or LVIS_SELECTED);
      // show first selected "place"
      ShowSubAction(Dialog,LV_GetLParam(wnd));
    end;
  end
  else
  begin
    ClearControls(Dialog);
    SetupControls(Dialog,-1,-1);
  end;
end;

procedure SetChangedFlag(Dialog:HWND);
var
  num,atype:integer;
  mtype:tMenuType;
begin
  num  :=LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),-1);
  atype:=LV_GetLParam(GetDlgItem(Dialog,IDC_UA_PLACELIST ),-1);
  case atype of
    uaContact: mtype:=contact_menu;
    uaTray   : mtype:=tray_menu;
  else
    mtype:=main_menu;
  end;
  UActionList[num].UAMenuItem[mtype].changed:=true;
end;

procedure SaveAction(Dialog:HWND;item:integer=-1;atype:integer=-1);
var
  i,j,num:integer;
  wnd:HWND;
begin
  wnd:=GetDlgItem(Dialog,IDC_UA_PLACELIST);
  num  :=LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),item);
  atype:=LV_GetLParam(GetDlgItem(Dialog,IDC_UA_PLACELIST),atype);

  with UActionList[num] do
  begin
    // main flags
    flags:=flags and not UAF_USING;
    for i:=0 to SendMessage(wnd,LVM_GETITEMCOUNT,0,0)-1 do
    begin
      if ListView_GetCheckState(wnd,i)<>0 then
      begin
        j:=LV_GetLParam(wnd,i);
        flags:=flags or NamesArray[j].mask;
      end;
    end;
    // common section
    if IsDlgButtonChecked(Dialog,IDC_UA_TWOSTATE)<>BST_UNCHECKED then
      flags:=flags or UAF_2STATE
    else
      flags:=flags and not UAF_2STATE;

    // custom data
    case atype of
      uaMTB: begin // CList modern toolbar
        mFreeMem(szMTBTooltip       ); szMTBTooltip       :=GetDlgText(Dialog,IDC_UA_TTNORMALV ,true);
        mFreeMem(szMTBTooltipPressed); szMTBTooltipPressed:=GetDlgText(Dialog,IDC_UA_TTPRESSEDV,true);
      end;

      uaTAB: begin // TabSRMM toolbar
        mFreeMem(szTabBTooltip       ); szTabBTooltip       :=GetDlgText(Dialog,IDC_UA_TTNORMALV);
        mFreeMem(szTabBTooltipPressed); szTabBTooltipPressed:=GetDlgText(Dialog,IDC_UA_TTPRESSEDV);
      end;

      uaMain: begin // Main menu
        if IsDlgButtonchecked(Dialog,IDC_UA_SEPARATE)<>BST_UNCHECKED then
          flags:=flags or UAF_MMENUSEP
        else
          flags:=flags and not UAF_MMENUSEP;

        with UAMenuItem[main_menu] do
        begin
          mFreeMem(szMenuPopup       ); szMenuPopup       :=GetDlgText(Dialog,IDC_UA_POPUPV);
          mFreeMem(szMenuNameVars    ); szMenuNameVars    :=GetDlgText(Dialog,IDC_UA_VARNAMESV);
          mFreeMem(szMenuShowWhenVars); szMenuShowWhenVars:=GetDlgText(Dialog,IDC_UA_SHOWVARV);
        end;
      end;

      uaContact: begin // Contact menu
        if IsDlgButtonchecked(Dialog,IDC_UA_SEPARATE)<>BST_UNCHECKED then
          flags:=flags or UAF_CMENUSEP
        else
          flags:=flags and not UAF_CMENUSEP;

        with UAMenuItem[contact_menu] do
        begin
          mFreeMem(szMenuPopup       ); szMenuPopup       :=GetDlgText(Dialog,IDC_UA_POPUPV);
          mFreeMem(szMenuNameVars    ); szMenuNameVars    :=GetDlgText(Dialog,IDC_UA_VARNAMESV);
          mFreeMem(szMenuShowWhenVars); szMenuShowWhenVars:=GetDlgText(Dialog,IDC_UA_SHOWVARV);
        end;
      end;

      uaTray: begin // Tray menu
        if IsDlgButtonchecked(Dialog,IDC_UA_SEPARATE)<>BST_UNCHECKED then
          flags:=flags or UAF_TMENUSEP
        else
          flags:=flags and not UAF_TMENUSEP;

        with UAMenuItem[tray_menu] do
        begin
          mFreeMem(szMenuPopup       ); szMenuPopup       :=GetDlgText(Dialog,IDC_UA_POPUPV);
          mFreeMem(szMenuNameVars    ); szMenuNameVars    :=GetDlgText(Dialog,IDC_UA_VARNAMESV);
          mFreeMem(szMenuShowWhenVars); szMenuShowWhenVars:=GetDlgText(Dialog,IDC_UA_SHOWVARV);
        end;
      end;

      uaHotkey: begin // Hotkey
        // Settings in Customize/Hotkeys
      end;
    end;
  //just after Action (not place) changes
  if item<0 then
    SaveUA(num);
  end;
end;

procedure FillActionList(wnd:HWND);
var
  i:integer;
  li:LV_ITEMW;
  il:HIMAGELIST;
begin
  wnd:=GetDlgItem(wnd,IDC_UA_ACTIONLIST);
  SendMessage(wnd,LVM_DELETEALLITEMS,0,0);

  il:=ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,0,1);
  for i:=0 to HIGH(UActionList) do
  begin   
    li.mask    :=LVIF_TEXT+LVIF_PARAM+LVIF_IMAGE;
    li.iSubItem:=0;
    li.iItem   :=i;
    li.lParam  :=i;
    li.pszText :=UActionList[i].szActDescr;
    li.iImage:=ImageList_AddIcon(il,
        HICON(CallService(MS_SKIN2_GETICONBYHANDLE,0,LPARAM(UActionList[i].hIcolibIcon))));
    li.iItem   :=SendMessageW(wnd,LVM_INSERTITEMW,0,LPARAM(@li));

    UActionList[i].UAMenuItem[main_menu   ].changed:=false;
    UActionList[i].UAMenuItem[contact_menu].changed:=false;
    UActionList[i].UAMenuItem[tray_menu   ].changed:=false;
  end;
  ImageList_Destroy(SendMessage(wnd,LVM_SETIMAGELIST,LVSIL_SMALL,il));

  SendMessage(wnd,LVM_SORTITEMS,0,LPARAM(@CompareItem));

  ListView_SetItemState(wnd,0,
    LVIS_FOCUSED or LVIS_SELECTED,
    LVIS_FOCUSED or LVIS_SELECTED);
end;

// refresh icons in UA list (at least)
function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  i:integer;
  li:LV_ITEMW;
  il:HIMAGELIST;
  wnd:HWND;
begin
  result:=0;
  wnd:=GetDlgItem(settings,IDC_UA_ACTIONLIST);

  il:=ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,0,1);
  for i:=0 to HIGH(UActionList) do
  begin
    li.mask    :=LVIF_IMAGE;
    li.iSubItem:=0;
    li.iItem   :=i;
    li.iImage:=ImageList_AddIcon(il,
        HICON(CallService(MS_SKIN2_GETICONBYHANDLE,0,TLPARAM(UActionList[i].hIcolibIcon))));
    SendMessage(wnd,LVM_SETITEM,0,TLPARAM(@li));
  end;
  ImageList_Destroy(SendMessage(wnd,LVM_SETIMAGELIST,LVSIL_SMALL,il));
//!!refresh?
end;

function DlgProcOpt(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  wnd:HWND;
  lv:LV_COLUMNW;
  i:integer;
begin
  result:=0;
  case hMessage of
    WM_CLOSE: begin
      settings:=0;
      PluginLink^.UnhookEvent(hIC);
    end;

    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);

      wnd:=GetDlgItem(Dialog,IDC_UA_PLACELIST);
      SendMessage(wnd,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_CHECKBOXES,LVS_EX_CHECKBOXES);
      SendMessage(wnd,LVM_SETUNICODEFORMAT,1,0);
      zeromemory(@lv,sizeof(lv));
      lv.mask:=LVCF_WIDTH;
      lv.cx  :=110;
      SendMessageW(wnd,LVM_INSERTCOLUMNW ,0,tlparam(@lv));
      SendMessageW(wnd,LVM_SETCOLUMNWIDTH,0,LVSCW_AUTOSIZE_USEHEADER);

      wnd:=GetDlgItem(Dialog,IDC_UA_ACTIONLIST);
//      SendMessage(wnd,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_CHECKBOXES,LVS_EX_CHECKBOXES);
      SendMessage(wnd,LVM_SETUNICODEFORMAT,1,0);
      zeromemory(@lv,sizeof(lv));
      lv.mask:=LVCF_WIDTH;
      lv.cx  :=110;
      SendMessageW(wnd,LVM_INSERTCOLUMNW ,0,tlparam(@lv));
      SendMessageW(wnd,LVM_SETCOLUMNWIDTH,0,LVSCW_AUTOSIZE_USEHEADER);
      FillActionList(Dialog);
      ShowAction(Dialog,-1);

//      if isVarsInstalled then
      begin
        SendDlgItemMessage(Dialog,IDC_UA_VARNAMESH,BM_SETIMAGE,IMAGE_ICON,
          CallService(MS_VARS_GETSKINITEM,0,VSI_HELPICON));
        SendDlgItemMessage(Dialog,IDC_UA_SHOWVARH,BM_SETIMAGE,IMAGE_ICON,
          CallService(MS_VARS_GETSKINITEM,0,VSI_HELPICON));
//        SendDlgItemMessage(Dialog,IDC_UA_VARNAMESH,BUTTONSETASFLATBTN,0,0);
//        SendDlgItemMessage(Dialog,IDC_UA_SHOWVARH ,BUTTONSETASFLATBTN,0,0);
      end;
      
      settings:=Dialog;
      hIC:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        EN_CHANGE: begin
          SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
          if loword(wParam)=IDC_UA_POPUPV then
            SetChangedFlag(Dialog);
        end;

        BN_CLICKED: begin
          case loword(wParam) of
            IDC_UA_TWOSTATE: begin
              SetupControls(Dialog,
                  LV_GetLParam(GetDlgItem(Dialog,IDC_UA_PLACELIST)),-1);
{
              EnableWindow(GetDlgItem(Dialog,IDC_UA_TTPRESSEDV),
                IsDlgButtonChecked(Dialog,IDC_UA_TWOSTATE)<>BST_UNCHECKED);
}
              if IsDlgButtonChecked(Dialog,IDC_UA_TWOSTATE)=BST_UNCHECKED then
                DeleteIcolibIconP(
                    UActionList[LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),-1)])
              else
                AddIcolibIconP(
                    UActionList[LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),-1)]);

              SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
            end;

            IDC_UA_VARNAMESH: ShowVarHelp(Dialog,IDC_UA_VARNAMESV);
            IDC_UA_SHOWVARH : ShowVarHelp(Dialog,IDC_UA_SHOWVARV);

            IDC_UA_SEPARATE: begin
              SetChangedFlag(Dialog);
              SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
            end;
          end;
        end;
      end;
    end;

    WM_NOTIFY: begin
      case integer(PNMHdr(lParam)^.code) of
        PSN_APPLY: begin
          SaveAction(Dialog);
          SaveUAs;
          for i:=0 to HIGH(UActionList) do
          begin
            SetAllActionUsers(UActionList[i]);
          end;
        end;

        LVN_ITEMCHANGED: begin
          if PNMLISTVIEW(lParam)^.uChanged=LVIF_STATE then
          begin
            i:=(PNMLISTVIEW(lParam)^.uOldState and LVNI_FOCUSED)-
               (PNMLISTVIEW(lParam)^.uNewState and LVNI_FOCUSED);

            if i>0 then // old focus
            begin
              if wParam=IDC_UA_ACTIONLIST then
                SaveAction(Dialog,PNMLISTVIEW(lParam)^.iItem)
              else //if wParam=IDC_UA_PLACELIST then
                SaveAction(Dialog,-1,PNMLISTVIEW(lParam)^.iItem);
            end
            else if i<0 then // new focus
            begin
              if wParam=IDC_UA_ACTIONLIST then
                ShowAction(Dialog,PNMLISTVIEW(lParam)^.iItem)
              else//if wParam=IDC_UA_PLACELIST then
                ShowSubAction(Dialog,
                  LV_GetLParam(GetDlgItem(Dialog,IDC_UA_PLACELIST),
                               PNMLISTVIEW(lParam)^.iItem));
            end
            else if (settings<>0) and
               ((PNMLISTVIEW(lParam)^.uOldState or PNMLISTVIEW(lParam)^.uNewState)=$3000) then
            begin
              // which type
              wnd:=GetDlgItem(Dialog,IDC_UA_PLACELIST);
              if PNMLISTVIEW(lParam)^.iItem<>
                 SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED) then
                ListView_SetItemState(wnd,PNMLISTVIEW(lParam)^.iItem,
                    LVIS_FOCUSED or LVIS_SELECTED,
                    LVIS_FOCUSED or LVIS_SELECTED)
              else
                SetupControls(Dialog,LV_GetLParam(wnd,PNMLISTVIEW(lParam)^.iItem),
                     PNMLISTVIEW(lParam)^.iItem);

              SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
            end;
          end;
        end;
      end;
    end;
  end;
end;
