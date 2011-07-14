{}
const
  settings:HWND = 0;
var
  onactchanged:THANDLE;

type
  tNameRec = record
    name   :PAnsiChar;
    service:PAnsiChar;
    mask   :dword;
    enable :boolean;
  end;

const
  NumControls = 9;
  NumTypes    = 6;
const
  NamesArray: array [0..NumTypes-1] of tNameRec = (
    (name:'CList Modern toolbar'; service:'ToolBar/AddButton'           ; mask:UAF_REGMTBB),
    (name:'TabSRMM toolbar'     ; service:'TabSRMM/ButtonsBar/AddButton'; mask:UAF_REGTABB),
    (name:'Main menu'           ; service:nil                           ; mask:UAF_REGMMENU),
    (name:'Contact menu'        ; service:nil                           ; mask:UAF_REGCMENU),
    (name:'Tray menu'           ; service:'CList/AddTrayMenuItem'       ; mask:UAF_REGTMENU),
    (name:'Core Hotkey'         ; service:nil{MS_HOTKEY_REGISTER}       ; mask:UAF_REGHOTKEY));

  IDsArray:array [0..NumControls-1] of integer =(
    IDC_UA_SEPARATE ,IDC_UA_POPUPT   ,IDC_UA_POPUPV,
    IDC_UA_VARNAMEST,IDC_UA_VARNAMESV,IDC_UA_VARNAMESH,
    IDC_UA_SHOWVART ,IDC_UA_SHOWVARV ,IDC_UA_SHOWVARH);

  // Show-hide controls by place type
  SHArray:array [0..NumTypes-1, 0..NumControls-1] of integer = (
    (SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE),
    (SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE),
    (SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW),
    (SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW),
    (SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW,SW_SHOW),
    (SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE,SW_HIDE)
    );
  // additional show/hide controls check by Variables installings (1 - need to check)
  SHVarArray:array [0..NumControls-1] of byte = (
    0,0,0,    0,0,1,    1,1,1);

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
    for i:=0 to NumControls-1 do
    begin
      typ:=SHArray[atype][i];
      if typ=SW_SHOW then
        if (SHVarArray[i]<>0) and (not IsVarsInstalled) then
          typ:=SW_HIDE;
      wnd:=GetDlgItem(Dialog,IDsArray[i]);
      ShowWindow(wnd,typ);

      if item<0 then
        item:=SendMessage(wnd1,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
      EnableWindow(wnd, ListView_GetCheckState(wnd1,item)<>0);
{
      EnableWindow(wnd,
        (UActionList[LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),item)].flags
           and NamesArray[atype].mask)<>0);
}
    end;
  end;
end;

// Clear all screen buttons/text fields (reset)
procedure ClearControls(Dialog:HWND);
begin
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
  // Show real UA settings
  case aType of
    0: begin // CList modern toolbar
      // no settings or tooltip name?
    end;
    1: begin // TabSRMM toolbar
      // no settings or tooltip name?
    end;
    2: begin // Main menu
      with UActionList[item] do
      begin
        if (flags and UAF_MMENUSEP)<>0 then
          CheckDlgButton(Dialog,IDC_UA_SEPARATE,BST_CHECKED);
        SetDlgItemTextW(Dialog,IDC_UA_POPUPV   ,szMMenuPopup);
        SetDlgItemTextW(Dialog,IDC_UA_VARNAMESV,szMMenuNameVars);
        SetDlgItemTextW(Dialog,IDC_UA_SHOWVARV ,szMMenuShowWhenVars);
      end;
    end;
    3: begin // Contact menu
      with UActionList[item] do
      begin
        if (flags and UAF_CMENUSEP)<>0 then
          CheckDlgButton(Dialog,IDC_UA_SEPARATE,BST_CHECKED);
        SetDlgItemTextW(Dialog,IDC_UA_POPUPV   ,szCMenuPopup);
        SetDlgItemTextW(Dialog,IDC_UA_VARNAMESV,szCMenuNameVars);
        SetDlgItemTextW(Dialog,IDC_UA_SHOWVARV ,szCMenuShowWhenVars);
      end;
    end;
    4: begin // Tray menu
      with UActionList[item] do
      begin
        if (flags and UAF_TMENUSEP)<>0 then
          CheckDlgButton(Dialog,IDC_UA_SEPARATE,BST_CHECKED);
        SetDlgItemTextW(Dialog,IDC_UA_POPUPV   ,szTMenuPopup);
        SetDlgItemTextW(Dialog,IDC_UA_VARNAMESV,szTMenuNameVars);
        SetDlgItemTextW(Dialog,IDC_UA_SHOWVARV ,szTMenuShowWhenVars);
      end;
    end;
    5: begin // Hotkey
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
end;

procedure SaveAction(Dialog:HWND;item:integer=-1;atype:integer=-1);
var
  i,j:integer;
  wnd:HWND;
begin
  wnd:=GetDlgItem(Dialog,IDC_UA_PLACELIST);
  i:=LV_GetLParam(GetDlgItem(Dialog,IDC_UA_ACTIONLIST),item);
  with UActionList[i] do
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
    // custom data
    case atype of
      0: begin // CList modern toolbar
        // no settings or tooltip name?
      end;
      1: begin // TabSRMM toolbar
        // no settings or tooltip name?
      end;
      2: begin // Main menu
        if IsDlgButtonchecked(Dialog,IDC_UA_SEPARATE)<>BST_UNCHECKED then
          flags:=flags or UAF_MMENUSEP
        else
          flags:=flags and not UAF_MMENUSEP;

        mFreeMem(szMMenuPopup       ); szMMenuPopup       :=GetDlgText(Dialog,IDC_UA_POPUPV);
        mFreeMem(szMMenuNameVars    ); szMMenuNameVars    :=GetDlgText(Dialog,IDC_UA_VARNAMESV);
        mFreeMem(szMMenuShowWhenVars); szMMenuShowWhenVars:=GetDlgText(Dialog,IDC_UA_SHOWVARV);
      end;
      3: begin // Contact menu
        if IsDlgButtonchecked(Dialog,IDC_UA_SEPARATE)<>BST_UNCHECKED then
          flags:=flags or UAF_CMENUSEP
        else
          flags:=flags and not UAF_CMENUSEP;

        mFreeMem(szCMenuPopup       ); szCMenuPopup       :=GetDlgText(Dialog,IDC_UA_POPUPV);
        mFreeMem(szCMenuNameVars    ); szCMenuNameVars    :=GetDlgText(Dialog,IDC_UA_VARNAMESV);
        mFreeMem(szCMenuShowWhenVars); szCMenuShowWhenVars:=GetDlgText(Dialog,IDC_UA_SHOWVARV);
      end;
      4: begin // Tray menu
        if IsDlgButtonchecked(Dialog,IDC_UA_SEPARATE)<>BST_UNCHECKED then
          flags:=flags or UAF_TMENUSEP
        else
          flags:=flags and not UAF_TMENUSEP;

        mFreeMem(szTMenuPopup       ); szTMenuPopup       :=GetDlgText(Dialog,IDC_UA_POPUPV);
        mFreeMem(szTMenuNameVars    ); szTMenuNameVars    :=GetDlgText(Dialog,IDC_UA_VARNAMESV);
        mFreeMem(szTMenuShowWhenVars); szTMenuShowWhenVars:=GetDlgText(Dialog,IDC_UA_SHOWVARV);
      end;
      5: begin // Hotkey
        // Settings in Customize/Hotkeys
      end;
    end;
  end;
end;

procedure FillActionList(wnd:HWND);
var
  i:integer;
  li:LV_ITEMW;
begin
  SendMessage(wnd,LVM_DELETEALLITEMS,0,0);

  for i:=0 to HIGH(UActionList) do
  begin
    li.mask    :=LVIF_TEXT+LVIF_PARAM+LVIF_IMAGE;
    li.iSubItem:=0;
    li.iItem   :=i;
    li.lParam  :=i;
    li.pszText :=UActionList[i].szActDescr;
    li.iItem   :=SendMessageW(wnd,LVM_INSERTITEMW,0,LPARAM(@li));
  end;

  SendMessage(wnd,LVM_SORTITEMS,0,LPARAM(@CompareItem));

  ListView_SetItemState(wnd,0,
    LVIS_FOCUSED or LVIS_SELECTED,
    LVIS_FOCUSED or LVIS_SELECTED);
end;

function ActListChange(wParam:WPARAM;lParam:LPARAM):integer; cdecl;
begin
  result:=0;
  if settings<>0 then
    FillActionList(GetDlgItem(settings,IDC_UA_ACTIONLIST));
end;

function DlgProcOpt(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  wnd:HWND;
  lv:LV_COLUMNW;
  li:LV_ITEMW;
  i:integer;
begin
  result:=0;
  case hMessage of
    WM_CLOSE: begin
      PluginLink^.UnhookEvent(onactchanged);
      settings:=0;
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
      FillActionList(wnd);

//      if isVarsInstalled then
      begin
        SendDlgItemMessage(Dialog,IDC_UA_VARNAMESH,BM_SETIMAGE,IMAGE_ICON,
          CallService(MS_VARS_GETSKINITEM,0,VSI_HELPICON));
        SendDlgItemMessage(Dialog,IDC_UA_SHOWVARH,BM_SETIMAGE,IMAGE_ICON,
          CallService(MS_VARS_GETSKINITEM,0,VSI_HELPICON));
//        SendDlgItemMessage(Dialog,IDC_UA_VARNAMESH,BUTTONSETASFLATBTN,0,0);
//        SendDlgItemMessage(Dialog,IDC_UA_SHOWVARH ,BUTTONSETASFLATBTN,0,0);
      end;
      
      onactchanged:=PluginLink^.HookEvent(ME_ACT_CHANGED,@ActListChange);
      settings:=Dialog;
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        EN_CHANGE: begin
          SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
        end;

        BN_CLICKED: begin
          case loword(wParam) of
            IDC_UA_VARNAMESH: ShowVarHelp(Dialog,IDC_UA_VARNAMESV);
            IDC_UA_SHOWVARH : ShowVarHelp(Dialog,IDC_UA_SHOWVARV);
          end;
        end;
      end;
    end;

    WM_NOTIFY: begin
      case integer(PNMHdr(lParam)^.code) of
        PSN_APPLY: begin
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
                SaveAction(Dialog,-1,
                  LV_GetLParam(GetDlgItem(Dialog,IDC_UA_PLACELIST),PNMLISTVIEW(lParam)^.iItem));
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
              if PNMLISTVIEW(lParam)^.iItem=
                 SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED) then // current item
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
