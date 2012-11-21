{}

const
  DefaultActionName = 'new action';
const
  inoutfilter:pWideChar = 'XML files'#0'*.xml'#0'All files'#0'*.*'#0#0;
const
  checknames:array [BST_UNCHECKED..BST_CHECKED] of PAnsiChar=(
    ACI_VAR_UNCHECKED,ACI_VAR_CHECKED);
const
  MaxDescrLen = 128;
const
  hlpVariables    = 30;
  hlpAdvVariables = 31;

var
  DontReact:bool;
  OldGroupTableProc,
  OldActTableProc:pointer;
  ChMask:dword;

procedure ResetDialogs;
var
  p:pActModule;
begin
  p:=ModuleLink;
  while p<>nil do
  begin
    SendMessage(p^.DlgHandle,WM_ACT_RESET,0,0);
    p:=p^.Next;
  end;
end;

procedure ClearDialogData;
var
  p:pActModule;
begin
  p:=ModuleLink;
  while p<>nil do
  begin
    if p^.DlgHandle<>0 then ShowWindow(p^.DlgHandle,SW_HIDE);
    p:=p^.Next;
  end;
end;

procedure SHActButtons(Dialog:HWND;mode:integer);
begin
  ShowWindow(GetDlgItem(Dialog,IDC_STAT_ACTION),mode);
  ShowWindow(GetDlgItem(Dialog,IDC_ACTION_TYPE),mode);
end;

procedure SetStart;
begin
  if NewGroupList=nil then
  begin
    NewGroupList:=GroupList;
    NewMaxGroups:=MaxGroups;
  end;
  if NewActionList=nil then
  begin
    NewActionList:=ActionList;
    NewMaxActions:=MaxActions;
  end;
end;

procedure SetChanged(wnd:HWND;atype:integer);
begin
  SendMessage(GetParent(wnd),PSM_CHANGED,0,0);
  if ((atype and etHK )<>0) and (NewGroupList =GroupList ) then NewGroupList :=CloneGroupList;
  if ((atype and etACT)<>0) and (NewActionList=ActionList) then NewActionList:=CloneActionList;
end;

procedure SetSave(Dialog:HWND;curIdx:integer);
var
  i,j:integer;
  li:LV_ITEMW;
  wnd:HWND;
begin
  if NewGroupList<>GroupList then
  begin

    DestroyMacros(GroupList,MaxGroups);
    wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
    j:=SendMessageW(wnd,LVM_GETITEMCOUNT,0,0);
    MaxGroups:=j;
    if j>0 then
    begin
      GetMem  (GroupList ,MaxGroups*SizeOf(tHKRecord));
      FillChar(GroupList^,MaxGroups*SizeOf(tHKRecord),0);
      li.mask    :=LVIF_PARAM;
      li.iSubItem:=0;
      for i:=0 to j-1 do
      begin
        li.iItem:=i;
        SendMessageW(wnd,LVM_GETITEMW,0,lparam(@li)); // GetLParam(wnd,i);
        move(NewGroupList^[li.lParam],GroupList^[i],SizeOf(tHKRecord));
        li.lParam:=i;
        SendMessageW(wnd,LVM_SETITEMW,0,lparam(@li));
      end;
    end
    else
      GroupList:=nil;

    FreeMem(NewGroupList);
    NewGroupList:=GroupList;
    NewMaxGroups:=MaxGroups;
  end;
end;

procedure SetCancel;
begin
  if NewActionList<>nil then
  begin
    if (NewActionList<>ActionList) then
      DestroyActions(NewActionList,NewMaxActions);
    NewActionList:=nil;
  end;
  if NewGroupList<>nil then
  begin
    if (NewGroupList<>GroupList) then
      DestroyMacros(NewGroupList,NewMaxGroups);
    NewGroupList:=nil;
  end;
end;

//-----  -----

procedure FillAction(act:tBaseAction);
var
  p:pActModule;
begin
  if act<>nil then
  begin
    p:=GetLink(act.UID);
    if p<>nil then
    begin
      SendMessage(p^.DlgHandle,WM_ACT_SETVALUE,0,tlparam(p));
      ShowWindow(p^.DlgHandle,SW_SHOW);
    end;
  end
  //???
  else
  begin
    ShowWindow(ModuleLink^.DlgHandle,SW_SHOW);
  end;
end;

// Fill action type combobox
function FillActTypeList(list:hwnd):HWND;
var
  cbei:TCOMBOBOXEXITEMW;
  il:HIMAGELIST;
  i:integer;
  buf:array [0..127] of WideChar;
  p:pActModule;
  rc:TRECT;
begin
  il:=ImageList_Create(16,16,ILC_COLOR32 or ILC_MASK,0,1);
  SendMessage(list,CB_RESETCONTENT,0,0);

  FillChar(cbei,SizeOf(cbei),0);
  cbei.mask:=CBEIF_IMAGE or CBEIF_SELECTEDIMAGE or CBEIF_TEXT or CBEIF_LPARAM; //!!
  p:=ModuleLink;
  i:=0;
  SetRect(rc,134,22,0,0);
  MapDialogRect(GetParent(list),rc);
  while p<>nil do
  begin
//!!    ImageList_AddIcon(il,CallService(MS_SKIN2_GETICON,0,lparam(ActIds[i].icon)));
    cbei.pszText       :=TranslateW(FastAnsiToWideBuf(p^.Name,buf));
    cbei.iItem         :=i;
    cbei.lParam        :=p^.Hash;
    cbei.iImage        :=i;
    cbei.iSelectedImage:=i;
    if SendMessageW(list,CBEM_INSERTITEMW,0,lparam(@cbei))=-1 then
      break;
    p^.DlgHandle:=p^.Dialog(GetParent(list));
    SetWindowPos(p^.DlgHandle,0,rc.left,rc.top,0,0,SWP_NOZORDER or SWP_NOSIZE or SWP_HIDEWINDOW);
    p:=p^.Next;
    inc(i);
  end;
  ImageList_Destroy(SendMessage(list,CBEM_SETIMAGELIST,0,il));

  SendMessage(list,CB_SETCURSEL,0,0);
  result:=GetLink(CB_GetData(list,0))^.DlgHandle;
end;

procedure CheckActList(Dialog:HWND;num:integer=-1);
var
  wnd:HWND;
  dir:integer;
  okup,okdown:boolean;
begin
  wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
//    if num<0 then
  begin
    dir:=LV_CheckDirection(wnd);
    okup  :=odd(loword(dir));
    okdown:=(loword(dir) and 2)<>0;
  end;
{
  else
  begin
    okup  :=num>0;
    okdown:=(num+1)<SendMessage(wnd,LVM_GETITEMCOUNT,0,0);
    SendMessage(wnd,LVM_ENSUREVISIBLE,num,0);
  end;
}
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_UP  ),okup);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DOWN),okdown);
  SendMessage(wnd,LVM_ENSUREVISIBLE,hiword(dir)-1,0);
(*
  wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
  if num<0 then
    num:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_UP),num>0);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DOWN),
      (num+1)<SendMessage(wnd,LVM_GETITEMCOUNT,0,0));
  SendMessage(wnd,LVM_ENSUREVISIBLE,num,0);
*)
end;

procedure CheckActionList(Dialog:HWND;next:integer);
var
  i:integer;
  wnd:HWND;
begin
  wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
  i:=SendMessage(wnd,LVM_GETITEMCOUNT,0,0);
  if i>0 then
  begin
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_HELP),true);
    if next=i then
      dec(next);
    ListView_SetItemState(wnd,next,
        LVIS_FOCUSED or LVIS_SELECTED,
        LVIS_FOCUSED or LVIS_SELECTED);
  end
  else
  begin
    SHActButtons(Dialog,SW_HIDE);
    EnableWindow(wnd,false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_HELP  ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_GROUP_TEST   ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DELETE),false);
    next:=0;
  end;
  CheckActList(Dialog,next);
end;

// Fill Chain list
procedure MakeActionList(Dialog:HWND;HK:pHKRecord);
var
  i,idx:integer;
  wnd:HWND;
  li:LV_ITEMW;
  p:pWideChar;
  buf:array [0..127] of WideChar;
begin
  wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
  SendMessage(wnd,LVM_DELETEALLITEMS,0,0);

  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_UP),false);
  if (HK=nil) or (HK^.firstAction=0) then
  begin
    SHActButtons(Dialog,SW_HIDE);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_LIST  ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_GROUP_TEST   ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_HELP  ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DELETE),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DOWN  ),false);
    exit;
  end;
  SHActButtons(Dialog,SW_SHOW);

  li.mask    :=LVIF_TEXT or LVIF_PARAM;
  li.iSubitem:=0;
  i:=HK^.firstAction;
  idx:=0;
  repeat
    p:=NewActionList^[i].ActionDescr;
    if p=nil then
      // get name from ModuleLink
      p:=TranslateW(FastAnsiToWideBuf(GetLink(NewActionList^[i].UID).Name,buf));
    li.pszText:=p;
    li.iItem  :=idx;
    li.lParam :=i;
    SendMessageW(wnd,LVM_INSERTITEMW,0,tlparam(@li));
//!!    ListView_SetCheckState(wnd,idx,(NewActionList^[i].flags1 and ACF_DISABLED)=0);

//!!      i:=NewActionList^[i].next;
    inc(idx);
  until i=0;

  Listview_SetItemState(wnd,0,
      LVIS_FOCUSED or LVIS_SELECTED,
      LVIS_FOCUSED or LVIS_SELECTED);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_LIST  ),true);
  EnableWindow(GetDlgItem(Dialog,IDC_GROUP_TEST   ),true);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_HELP  ),true);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DELETE),true);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DOWN),idx>1);
//--    FillSubList(Dialog);
  FillAction(NewActionList^[HK^.firstAction]);
  CheckActList(Dialog,0);
end;

// change current action name ONLY IN LIST
procedure ChangeActionName(Dialog:HWND; num:integer=-1;str:PWideChar=nil);
var
  li:LV_ITEMW;
  wnd:HWND;
begin
  wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
  if num<0 then
    li.iItem:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED)
  else
    li.iItem:=num;
  if li.iItem>=0 then
  begin
    li.iSubItem:=0;
    // getting SubAction number
    li.mask:=LVIF_PARAM;
    SendMessage(wnd,LVM_GETITEM,0,tlparam(@li));

    // changing to default name
    if str=nil then
      str:=DefaultActionName;

    li.mask   :=LVIF_TEXT;
    li.pszText:=str;
    SendMessageW(wnd,LVM_SETITEMW,0,tlparam(@li));
  end;
end;

procedure SaveAction(Dialog:HWND;listnum,actnum:integer);
var
  wnd:HWND;
  arr: array [0..255] of WideChar;
  li:LV_ITEMW;
  p:pActModule;
begin
  if (ChMask and ACTM_ACT)=0 then exit;
  ChMask:=ChMask and not ACTM_ACT;
  wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
  if listnum<0 then
  begin
    listnum:=SendMessageW(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
    if listnum<0 then
      exit;
  end;
  if actnum<0 then
    actnum:=LV_GetLParam(wnd,listnum);
  if NewActionList^[actnum]<>nil then
  begin
    NewActionList^[actnum].Clear;
    Dispose(NewActionList^[actnum]);
  end;

  // Action saving
  p:=GetLink(CB_GetData(GetDlgItem(Dialog,IDC_ACTION_TYPE)));
  NewActionList^[actnum]:=p.Create;
  
  with NewActionList^[actnum]^ do
  begin
//!!    flags1:=0; //ACF_ASSIGNED not needed anymore
//!!    flags2:=0;

    li.iItem     :=listnum;
    li.mask      :=LVIF_TEXT;
    li.iSubItem  :=0;
    li.pszText   :=@arr;
    li.cchTextMax:=SizeOf(arr) div SizeOf(WideChar);
    SendDlgItemMessageW(Dialog,IDC_ACTION_LIST,LVM_GETITEMW,0,tlparam(@li));
    StrDupW(ActionDescr,arr);

    if ListView_GetCheckState(wnd,listnum)=0 then
;//!!      flags1:=flags1 or ACF_DISABLED;

    SendMessage(p.DlgHandle,WM_ACT_SAVE,0,tlparam(NewActionList^[actnum]));
  end;
end;

procedure BuildActionChain(Dialog:HWND;group:integer=-1);
var
  i,j,item:integer;
  wnd:HWND;
  act:pHKAction;
  idx:integer;
begin
  if (ChMask and ACTM_ACTS)=0 then exit;
  ChMask:=ChMask and not ACTM_ACTS;
  SaveAction(Dialog,-1,-1);
  wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
  i:=SendMessageW(wnd,LVM_GETITEMCOUNT,0,0);
  idx:=LV_GetLParam(GetDlgItem(Dialog,IDC_ACTION_GROUP),group);
  if i>0 then
  begin
    j:=LV_GetLParam(wnd,0);
    NewGroupList^[idx].firstAction:=j;
    act:=@NewActionList^[j];
    for item:=1 to i-1 do
    begin
      j:=LV_GetLParam(wnd,item);
      act^.next:=j;
      act:=@NewActionList^[j];
    end;
    act^.next:=0;
  end
  else
  begin
    if idx>=0 then
      NewGroupList^[idx].firstAction:=0;
  end;
end;

// action group table procedure (key hook)
function NewGroupTableProc(Dialog:HWnd;hMessage:uint;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  i:integer;
begin
  result:=0;
  case hMessage of
    WM_KEYDOWN: begin
      if (lParam and (1 shl 30))=0 then
      begin
        case wParam of
          VK_F2: begin
            i:=SendMessage(Dialog,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
            if i>=0 then
              PostMessageW(Dialog,LVM_EDITLABELW,i,0);
            exit;
          end;
          VK_INSERT: begin
            PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_GROUP_NEW,0);
            exit;
          end;
          VK_DELETE: begin
            PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_GROUP_DELETE,0);
            exit;
          end;
          VK_UP: begin
            if (GetKeyState(VK_CONTROL) and $8000)<>0 then
            begin
              PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_GROUP_UP,0);
              exit;
            end;
          end;
          VK_DOWN: begin
            if (GetKeyState(VK_CONTROL) and $8000)<>0 then
            begin
              PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_GROUP_DOWN,0);
              exit;
            end;
          end;
        end;
      end;
    end;
  end;
  result:=CallWindowProc(OldGroupTableProc,Dialog,hMessage,wParam,lParam);
end;

// action (chain) table procedure (key hook)
function NewActTableProc(Dialog:HWnd;hMessage:uint;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  i:integer;
begin
  result:=0;
  case hMessage of
    WM_KEYDOWN: begin
      if (lParam and (1 shl 30))=0 then
      begin
        case wParam of
          VK_F2: begin
            i:=SendMessage(Dialog,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
            if i>=0 then
              PostMessageW(Dialog,LVM_EDITLABELW,i,0);
            exit;
          end;
          VK_UP: begin
            if (GetKeyState(VK_CONTROL) and $8000)<>0 then
            begin
              PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_ACTION_UP,0);
              exit;
            end;
          end;
          VK_DOWN: begin
            if (GetKeyState(VK_CONTROL) and $8000)<>0 then
            begin
              PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_ACTION_DOWN,0);
              exit;
            end;
          end;
          VK_INSERT: begin
            PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_ACTION_NEW,0);
            exit;
          end;
          VK_DELETE: begin
            PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_ACTION_DELETE,0);
            exit;
          end;
        end;
      end;
    end;
  end;
  result:=CallWindowProc(OldActTableProc,Dialog,hMessage,wParam,lParam);
end;

// miranda button icon paint
procedure SetButtonIcons2(Dialog:HWND);
var
  ti:TTOOLINFOW;
  hwndTooltip:HWND;
begin
  hwndTooltip:=CreateWindowW(TOOLTIPS_CLASS,nil,TTS_ALWAYSTIP,
      integer(CW_USEDEFAULT),integer(CW_USEDEFAULT),
      integer(CW_USEDEFAULT),integer(CW_USEDEFAULT),
      Dialog,0,hInstance,nil);

  FillChar(ti,SizeOf(ti),0);
  ti.cbSize  :=sizeof(TOOLINFO);
  ti.uFlags  :=TTF_IDISHWND or TTF_SUBCLASS;
  ti.hwnd    :=Dialog;
  ti.hinst   :=hInstance;

  ti.uId     :=GetDlgItem(Dialog,IDC_ACTION_HELP);
  ti.lpszText:=TranslateW('Help');
  SendMessage(ti.uId,BM_SETIMAGE,IMAGE_ICON,
      CallService(MS_SKIN_LOADICON,SKINICON_OTHER_HELP,0));
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));
  
  ti.uId     :=GetDlgItem(Dialog,IDC_ACTION_NEW);
  ti.lpszText:=TranslateW('New');
  SetButtonIcon(ti.uId,ACI_NEW);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_NEW);
  SetButtonIcon(ti.uId,ACI_NEW);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_ACTION_UP);
  ti.lpszText:=TranslateW('Up');
  SetButtonIcon(ti.uId,ACI_UP);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_UP);
  SetButtonIcon(ti.uId,ACI_UP);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_ACTION_DOWN);
  ti.lpszText:=TranslateW('Down');
  SetButtonIcon(ti.uId,ACI_DOWN);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_DOWN);
  SetButtonIcon(ti.uId,ACI_DOWN);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_ACTION_DELETE);
  ti.lpszText:=TranslateW('Delete');
  SetButtonIcon(ti.uId,ACI_DELETE);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_DELETE);
  SetButtonIcon(ti.uId,ACI_DELETE);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_RELOAD);
  ti.lpszText:=TranslateW('Reload');
  SetButtonIcon(ti.uId,ACI_RELOAD);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_TEST);
  ti.lpszText:=TranslateW('Test');
  SetButtonIcon(ti.uId,ACI_TEST);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_IMPORT);
  ti.lpszText:=TranslateW('Import');
  SetButtonIcon(ti.uId,ACI_IMPORT);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

  ti.uId     :=GetDlgItem(Dialog,IDC_GROUP_EXPORT);
  ti.lpszText:=TranslateW('Export');
  SetButtonIcon(ti.uId,ACI_EXPORT);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,lparam(@ti));

end;

function GetGroupName(id:dword):pWideChar;
var
  i:integer;
begin
  for i:=0 to NewMaxGroups-1 do
  begin
    if ((NewGroupList^[i].flags and ACF_ASSIGNED)<>0) and (id=NewGroupList^[i].id) then
    begin
      result:=NewGroupList^[i].descr;
      exit;
    end;
  end;
//!!  result:=NoChainText;
end;

function AddGroup(Dialog:HWND;HKnum:dword):integer;
var
  li:LV_ITEMW;
  list:HWND;
begin
  with NewGroupList^[HKnum] do
  begin
    if (flags and ACF_ASSIGNED)<>0 then
    begin
      list:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
      li.mask     :=LVIF_PARAM+LVIF_TEXT;
      li.iItem    :=SendMessage(list,LVM_GETNEXTITEM,-1,LVNI_FOCUSED)+1;
      li.iSubItem :=0;
      li.lParam   :=HKnum;
      if descr=nil then
        li.pszText:=NoDescription
      else
        li.pszText:=descr;
      li.iItem    :=SendMessageW(list,LVM_INSERTITEMW,0,lparam(@li));
      if li.iItem>0 then
        dec(li.iItem);
      ListView_SetItemState(list,li.iItem,LVIS_FOCUSED or LVIS_SELECTED,
          LVIS_FOCUSED or LVIS_SELECTED);
      result:=li.iItem;
    end
    else
      result:=-1;
  end;
end;

function MoveGroup(list:HWND;num:integer=-1;incr:integer=0):integer;
var
  i,j:integer;
begin
  if num<0 then
  begin
    result:=-1;
    j:=SendMessage(list,LVM_GETITEMCOUNT,0,0)-1;
    if incr<0 then // up, from beginning
    begin
      for i:=0 to j do
      begin
        if SendMessage(list,LVM_GETITEMSTATE,i,LVIS_SELECTED)<>0 then
        begin
          if i=0 then break;
          LV_MoveItem(list,incr,i);
//          MoveLVItem(list,i,incr);
          if result<0 then result:=i+incr;
        end;
      end;
    end
    else           // down, from the end
    begin
      for i:=j downto 0 do
      begin
        if SendMessage(list,LVM_GETITEMSTATE,i,LVIS_SELECTED)<>0 then
        begin
          if i=j then break;
          LV_MoveItem(list,incr,i);
//          MoveLVItem(list,i,incr);
          if result<0 then result:=i+incr;
        end;
      end;
    end;
  end
  else
  begin
    LV_MoveItem(list,incr,num);
//    MoveLVItem(list,num,incr);
    result:=num;
  end;
end;

// enable/disable navigation chain buttons
procedure CheckGrpList(Dialog:HWND;num:integer=-1);
var
  wnd:HWND;
  dir:integer;
  okup,okdown:boolean;
begin
  wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
//    if num<0 then
  begin
    dir:=LV_CheckDirection(wnd);
    okup  :=odd(loword(dir));
    okdown:=(loword(dir) and 2)<>0;
  end;
{
  else
  begin
    okup  :=num>0;
    okdown:=(num+1)<SendMessage(wnd,LVM_GETITEMCOUNT,0,0);
    SendMessage(wnd,LVM_ENSUREVISIBLE,num,0);
  end;
}
  EnableWindow(GetDlgItem(Dialog,IDC_GROUP_UP  ),okup);
  EnableWindow(GetDlgItem(Dialog,IDC_GROUP_DOWN),okdown);
  SendMessage(wnd,LVM_ENSUREVISIBLE,hiword(dir)-1,0);
(*
  wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
  if num<0 then
    num:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
  EnableWindow(GetDlgItem(Dialog,IDC_GROUP_UP),num>0);
  EnableWindow(GetDlgItem(Dialog,IDC_GROUP_DOWN),
      (num+1)<SendMessage(wnd,LVM_GETITEMCOUNT,0,0));
  SendMessage(wnd,LVM_ENSUREVISIBLE,num,0);
  result:=num;
*)
end;

procedure CheckGroupList(Dialog:HWND;next:integer);
var
  i:integer;
  wnd:HWND;
  li:LV_ITEMW;
begin
  wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
  i:=SendMessage(wnd,LVM_GETITEMCOUNT,0,0);
  if i>0 then
  begin
    if next=i then
      dec(next);
    ListView_SetItemState(wnd,next,LVIS_FOCUSED or LVIS_SELECTED,
      LVIS_FOCUSED or LVIS_SELECTED);
    li.iItem   :=next;
    li.iSubItem:=0;
    li.mask    :=LVIF_PARAM;
    SendMessage(wnd,LVM_GETITEM,0,tlparam(@li));
  end
  else
  begin
    EnableWindow(wnd,false);
    EnableWindow(GetDlgItem(Dialog,IDC_GROUP_DELETE),false);
    CheckActionList(Dialog,0);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_NEW),false);
  end;
  CheckGrpList(Dialog,next);
end;

// Fill action group list and disable chain controls
function FillGroupList(Dialog:hwnd):integer;
var
  CurGroup:pHKRecord;
  i:integer;
  list:HWND;
  lvi:TLVITEMW;
begin
  SendDlgItemMessage(Dialog,IDC_ACTION_LIST,LVM_DELETEALLITEMS,0,0);
  CheckActionList(Dialog,-1);
  list:=GetDlgItem(Dialog,IDC_ACTION_GROUP);

  SendMessage(list,LVM_DELETEALLITEMS,0,0);
  CurGroup:=@NewGroupList^;
  result:=-1;
  lvi.mask:=LVIF_TEXT+LVIF_PARAM;
  lvi.iSubItem:=0;
  for i:=0 to NewMaxGroups-1 do
  begin
    if (CurGroup^.flags and ACF_ASSIGNED)<>0 then
    begin
      lvi.iItem :=i;
      lvi.lParam:=i;
      if CurGroup^.descr=nil then
        lvi.pszText:=NoDescription
      else
        lvi.pszText:=CurGroup^.descr;
      SendMessageW(list,LVM_INSERTITEMW,0,tlparam(@lvi));
      inc(result);
    end;
    inc(CurGroup);
  end;

  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_GROUP ),result>=0);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_LIST  ),result>=0);
  EnableWindow(GetDlgItem(Dialog,IDC_ACTION_NEW   ),result>=0);
  EnableWindow(GetDlgItem(Dialog,IDC_GROUP_DELETE ),result>=0);
  if result<0 then
  begin
    EnableWindow(GetDlgItem(Dialog,IDC_GROUP_TEST   ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_HELP  ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DELETE),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_UP    ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DOWN  ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_STAT_GROUPS  ),false);
    EnableWindow(GetDlgItem(Dialog,IDC_ACTION_TYPE  ),false);
  end
  else
    result:=0;
  SendMessage(list,CB_SETCURSEL,0,0);
  SendMessage(list,LVM_SETCOLUMNWIDTH,0,LVSCW_AUTOSIZE_USEHEADER);

  ListView_SetItemState(list,0,
    LVIS_FOCUSED or LVIS_SELECTED,
    LVIS_FOCUSED or LVIS_SELECTED);
end;

procedure ShowHelp(Dialog:HWND;code:integer);
var
  vhi:TVARHELPINFO;
begin
  case code of
    hlpVariables: begin
      FillChar(vhi,SizeOf(vhi),0);
      with vhi do
      begin
        cbSize:=SizeOf(vhi);
        flags:=VHF_NOINPUTDLG;
      end;
      CallService(MS_VARS_SHOWHELPEX,Dialog,tlparam(@vhi));
    end;
    hlpAdvVariables: begin
      FillChar(vhi,SizeOf(vhi),0);
      with vhi do
      begin
        cbSize       :=SizeOf(vhi);
        flags        :=VHF_FULLDLG or VHF_SETLASTSUBJECT;
        hwndCtrl     :=GetDlgItem(Dialog,IDC_ADV_VARS);
        szSubjectDesc:='test your variables';
      end;
      CallService(MS_VARS_SHOWHELPEX,Dialog,tlparam(@vhi));
    end;
  end;
end;

function DlgProcOpt2(Dialog:HWnd;hMessage:uint;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
const
  LastActionDialog:HWND = 0;

var
  wnd:HWND;
  i,j:int_ptr;
  lvflag:integer;
  li:LV_ITEMW;
  lv:LV_COLUMNW;
  ico:HICON;
begin
  result:=0;
  case hMessage of
    WM_DESTROY: begin
      ApiCard.Free;
      SetCancel;
    end;

    WM_INITDIALOG: begin
      ApiCard:=CreateServiceCard(Dialog);
      SetStart;
      DontReact :=true;
      TranslateDialogDefault(Dialog);
      SetButtonIcons2(Dialog);
      wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
      SendMessage(wnd,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_CHECKBOXES,LVS_EX_CHECKBOXES);
      SendMessage(wnd,LVM_SETUNICODEFORMAT,1,0);
      zeromemory(@lv,sizeof(lv));
      lv.mask:=LVCF_WIDTH;
      lv.cx  :=110;
      SendMessageW(wnd,LVM_INSERTCOLUMNW ,0,tlparam(@lv));
      SendMessageW(wnd,LVM_SETCOLUMNWIDTH,0,LVSCW_AUTOSIZE_USEHEADER);

      // action type combobox
      LastActionDialog:=FillActTypeList(GetDlgItem(Dialog,IDC_ACTION_TYPE));

      if isVarsInstalled then
      begin
        ico:=CallService(MS_VARS_GETSKINITEM,0,VSI_HELPICON);
        SendDlgItemMessage(Dialog,IDC_HLP_FVARS,BM_SETIMAGE,IMAGE_ICON,ico);
        SendDlgItemMessage(Dialog,IDC_HLP_VARS ,BM_SETIMAGE,IMAGE_ICON,ico);
        SendDlgItemMessage(Dialog,IDC_ADV_HVARS,BM_SETIMAGE,IMAGE_ICON,ico);
      end;

      if ServiceExists(MS_SYSTEM_GET_XI)=0 then
      begin
        EnableWindow(GetDlgItem(Dialog,IDC_GROUP_EXPORT),false);
        EnableWindow(GetDlgItem(Dialog,IDC_GROUP_IMPORT),false);
      end;
      
      OldActTableProc  :=pointer(SetWindowLongPtrW(wnd,GWL_WNDPROC,long_ptr(@NewActTableProc)));
      OldGroupTableProc:=pointer(SetWindowLongPtrW(GetDlgItem(Dialog,IDC_ACTION_GROUP),
            GWL_WNDPROC,long_ptr(@NewGroupTableProc)));

      // fill group list
      wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
      SendMessage(wnd,LVM_SETUNICODEFORMAT,1,0);
      lv.mask:=LVCF_WIDTH;
      lv.cx  :=110;
      SendMessageW(wnd,LVM_INSERTCOLUMNW,0,tlparam(@lv));
      FillGroupList(Dialog);

      // fill current group
//!!      MakeActionList(Dialog,@NewGroupList^);
      ChMask:=0;
      CheckGrpList(Dialog,-1);
      DontReact:=false;
    end;

    WM_COMMAND: begin
      if DontReact then exit;
      case wParam shr 16 of
{
        EN_CHANGE: begin
// check for group renaming
          if loword(wParam)<>IDC_EDIT_FORMAT then
          begin
            ChMask:=ChMask or ACTM_ACT or ACTM_ACTS;
            SetChanged(Dialog,etACT);
          end;
        end;
}
        CBN_SELCHANGE:  begin
          ChMask:=ChMask or ACTM_ACT or ACTM_ACTS;
          SetChanged(Dialog,etACT);
          case loword(wParam) of
            IDC_ACTION_TYPE: begin
              ShowWindow(LastActionDialog,SW_HIDE);
              LastActionDialog:=GetLink(CB_GetData(lParam))^.DlgHandle;
              ShowWindow(LastActionDialog,SW_SHOW);
            end;
          end;
        end;

        BN_CLICKED: begin
          case loword(wParam) of
            IDC_GROUP_RELOAD, // don't affect to saved (DB) datas
            IDC_HLP_FVARS,
            IDC_HLP_VARS,
            IDC_ADV_HVARS,
            IDC_ACTION_HELP,
            IDC_GROUP_EXPORT,
            IDC_GROUP_TEST: ;

            IDC_GROUP_UP,
            IDC_GROUP_DOWN,
            IDC_GROUP_NEW : SetChanged(Dialog,etHK);

            IDC_GROUP_DELETE, // action deleting with subactions
            IDC_GROUP_IMPORT,
            IDC_ACTION_NEW,
            IDC_ACTION_DELETE,
            IDC_ACTION_UP,
            IDC_ACTION_DOWN: begin
              ChMask:=ChMask or ACTM_ACT or ACTM_ACTS;
              SetChanged(Dialog,etHK+etACT);
            end;
          else
            ChMask:=ChMask or ACTM_ACT or ACTM_ACTS;
            SetChanged(Dialog,etACT);
          end;

          case loword(wParam) of
            IDC_HLP_FVARS,
            IDC_HLP_VARS : ShowHelp(Dialog,hlpVariables);
            IDC_ADV_HVARS: ShowHelp(Dialog,hlpAdvVariables);

            IDC_GROUP_EXPORT: begin
              if ShowDlgW(xmlfilename,xmlfilename,inoutfilter,false) then
              begin
                wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
                for i:=0 to ListView_GetItemCount(wnd)-1 do
                begin
                  if ListView_GetItemState(wnd,i,LVIS_SELECTED)<>0 then
                  begin
                    with GroupList[LV_GetLParam(wnd,i)] do
                      if (flags and ACF_ASSIGNED)<>0 then // must be always true
                        flags:=flags or ACF_EXPORT;
                  end
                  else
                    with GroupList[i] do
                      if (flags and (ACF_EXPORT or ACF_ASSIGNED))=
                                    (ACF_EXPORT or ACF_ASSIGNED) then
                        flags:=flags and not ACF_EXPORT;
                end;
                i:=ACIO_EXPORT or ACIO_SELECTED;
                if GetFSize(xmlfilename)>0 then
                  if MessageBoxW(Dialog,TranslateW('Append data to file'),
                     PluginName,MB_YESNO+MB_ICONWARNING)=IDYES then
                    i:=i or ACIO_APPEND;
//!!                CallService(MS_ACT_INOUT,i,TLPARAM(@xmlfilename));
//                Export({GetLParam(GetDlgItem(Dialog,IDC_ACTION_GROUP)),}xmlfilename,i);
                for i:=0 to MaxGroups-1 do
                  with GroupList[i] do
                    if (flags and (ACF_EXPORT or ACF_ASSIGNED))=
                                  (ACF_EXPORT or ACF_ASSIGNED) then
                      flags:=flags and not ACF_EXPORT;
              end;
            end;

            IDC_GROUP_IMPORT: begin
              if ShowDlgW(xmlfilename,xmlfilename,inoutfilter) then
              begin
//                if Import(xmlfilename) then
                if CallService(MS_ACT_INOUT,0,TLPARAM(@xmlfilename))<>0 then
                begin
                  ChMask:=ChMask or ACTM_NEW;
                  SendMessage(Dialog,WM_COMMAND,IDC_GROUP_RELOAD+(BN_CLICKED shl 16),
                    GetDlgItem(Dialog,IDC_GROUP_RELOAD));
//(in reload)       FillChainList(Dialog);
                end;
              end;
            end;

            IDC_GROUP_TEST: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
              li.mask    :=LVIF_PARAM;
              li.iSubItem:=0;
              li.iItem   :=0;
              SendMessageW(wnd,LVM_GETITEMW,0,tlparam(@li));
              j:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);

              ActionStarterWait(li.lParam);
              // doubling from  "reload" button
              wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
              i:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
              NewGroupList :=GroupList;
              NewMaxGroups :=MaxGroups;
              NewActionList:=ActionList;
              NewMaxActions:=MaxActions;
              FillGroupList(Dialog);

              Listview_SetItemState(wnd,0,0,LVIS_FOCUSED or LVIS_SELECTED);
              Listview_SetItemState(wnd,i,
                   LVIS_FOCUSED or LVIS_SELECTED,
                   LVIS_FOCUSED or LVIS_SELECTED);
              SendMessage(wnd,LVM_ENSUREVISIBLE,i,0);

              wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
              Listview_SetItemState(wnd,0,0,LVIS_FOCUSED or LVIS_SELECTED);
              Listview_SetItemState(wnd,j,
                   LVIS_FOCUSED or LVIS_SELECTED,
                   LVIS_FOCUSED or LVIS_SELECTED);
              SendMessage(wnd,LVM_ENSUREVISIBLE,j,0);

            end;
            IDC_GROUP_NEW: begin
              i:=AddGroup(Dialog,NewMacro(NewGroupList,NewMaxGroups));
              if i>=0 then
              begin
                ChMask:=ChMask or ACTM_NEW or ACTM_SORT;
                EnableWindow(GetDlgItem(Dialog,IDC_ACTION_GROUP),true);
                EnableWindow(GetDlgItem(Dialog,IDC_GROUP_DELETE),true);
                EnableWindow(GetDlgItem(Dialog,IDC_ACTION_NEW  ),true);
                CheckGrpList(Dialog,i);
              end;
            end;
            IDC_GROUP_DELETE: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
              for i:=ListView_GetItemCount(wnd)-1 downto 0 do
              begin
                if ListView_GetItemState(wnd,i,LVIS_SELECTED)<>0 then
                begin
                  ChMask:=ChMask or ACTM_DELETE or ACTM_SORT;

                  with NewGroupList^[LV_GetLParam(wnd,i)] do
                  begin
                    flags:=0;
                    mFreeMem(descr);
                    FreeActions(NewActionList,firstAction);
                  end;

                  SendMessage(wnd,LVM_DELETEITEM,i,0);
                end;
              end;
              SendDlgItemMessage(Dialog,IDC_ACTION_LIST,LVM_DELETEALLITEMS,0,0);
              Listview_SetItemState(wnd,0,LVIS_FOCUSED or LVIS_SELECTED,
                                          LVIS_FOCUSED or LVIS_SELECTED);
              CheckGroupList(Dialog,-1);
{
              i:=SendMessageW(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED); //??
              if i>=0 then
              begin
                ChMask:=ChMask or ACTM_DELETE;
                j:=GetLParam(wnd,i);

                with NewGroupList^[j] do
                begin
                  flags:=0;
                  mFreeMem(descr);
                  FreeActions(NewActionList,firstAction);
                end;
                SendDlgItemMessage(Dialog,IDC_ACTION_LIST,LVM_DELETEALLITEMS,0,0);

//??                i:=ListView_GetNextItem(wnd,-1,LVNI_FOCUSED);
                SendMessage(wnd,LVM_DELETEITEM,i,0);
                FillChainList(Dialog);
                CheckGroupList(Dialog,i);
              end;
}
            end;
            IDC_GROUP_RELOAD: begin
              ChMask:=ChMask or ACTM_RELOAD;
              SetCancel;
              NewGroupList :=GroupList;
              NewMaxGroups :=MaxGroups;
              NewActionList:=ActionList;
              NewMaxActions:=MaxActions;
            end;

            IDC_ACTION_HELP: begin
              SendMessage(
                GetLink(CB_GetData(GetDlgItem(Dialog,IDC_ACTION_TYPE)))^.DlgHandle,
                WM_HELP,0,0);
            end;

            IDC_ACTION_NEW: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
              li.mask    :=LVIF_PARAM;
              i          :=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
              li.iItem   :=i+1;
              li.iSubItem:=0;
              li.lParam  :=NewAction(NewActionList,NewMaxActions);
              SendMessageW(wnd,LVM_INSERTITEMW,0,tlparam(@li));
              ListView_SetCheckState(wnd,li.iItem,true);
              if li.iItem=0 then
              begin
                ListView_SetItemState(wnd,0,LVIS_FOCUSED or LVIS_SELECTED,
                  LVIS_FOCUSED or LVIS_SELECTED);
                SHActButtons(Dialog,SW_SHOW);
              end;
              ChangeActionName(Dialog,li.iItem);
              EnableWindow(GetDlgItem(Dialog,IDC_ACTION_LIST  ),true);
              EnableWindow(GetDlgItem(Dialog,IDC_ACTION_HELP  ),true);
              EnableWindow(GetDlgItem(Dialog,IDC_GROUP_TEST   ),true);
              EnableWindow(GetDlgItem(Dialog,IDC_ACTION_DELETE),true);
              EnableWindow(GetDlgItem(Dialog,IDC_ACTION_TYPE  ),true);
              CheckActList(Dialog,i);

              wnd:=GetDlgItem(Dialog,IDC_ADV_VAL2);
              i:=SendMessage(wnd,CB_GETCURSEL,0,0);
              SendMessage(wnd,CB_SETCURSEL,i,0);
            end;
            IDC_ACTION_DELETE: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
              for i:=ListView_GetItemCount(wnd)-1 downto 0 do
              begin
                if ListView_GetItemState(wnd,i,LVIS_SELECTED)<>0 then
                begin
                  FreeAction(@NewActionList^[LV_GetLParam(wnd,i)]);
                  SendMessage(wnd,LVM_DELETEITEM,i,0);
                end;
              end;
              Listview_SetItemState(wnd,0,LVIS_FOCUSED or LVIS_SELECTED,
                                          LVIS_FOCUSED or LVIS_SELECTED);
              CheckActionList(Dialog,0);
{              
              wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
              li.iItem:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED); //??
              if li.iItem>=0 then
              begin
                li.mask    :=LVIF_PARAM;
                li.iSubItem:=0;
                SendMessageW(wnd,LVM_GETITEM,0,dword(@li));
                FreeAction(@NewActionList^[li.lParam]);

                SendMessage(wnd,LVM_DELETEITEM,li.iItem,0);
                CheckActionList(Dialog,li.iItem);
              end;
}
            end;

            IDC_GROUP_UP: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
              begin
                CheckGrpList(Dialog,MoveGroup(wnd,-1,-1));
                ChMask:=ChMask or ACTM_SORT;
              end;
            end;
            IDC_GROUP_DOWN: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_GROUP);
              begin
                CheckGrpList(Dialog,MoveGroup(wnd,-1,1));
                ChMask:=ChMask or ACTM_SORT;
              end;
            end;

            IDC_ACTION_UP: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
                CheckActList(Dialog,MoveGroup(wnd,-1,-1));
            end;
            IDC_ACTION_DOWN: begin
              wnd:=GetDlgItem(Dialog,IDC_ACTION_LIST);
                CheckActList(Dialog,MoveGroup(wnd,-1,1));
            end;

          end;
        end;
      end;
    end;

    WM_HELP: begin
      SendMessage(
        GetLink(CB_GetData(GetDlgItem(Dialog,IDC_ACTION_TYPE)))^.DlgHandle,
        WM_HELP,0,0);
    end;

    WM_NOTIFY: begin
      case integer(PNMHdr(lParam)^.code) of
        PSN_APPLY: begin
          BuildActionChain(Dialog);
          SetSave(Dialog,LV_GetLParam(GetDlgItem(Dialog,IDC_ACTION_GROUP)));

          if ActionList<>NewActionList then
          begin
            DestroyActions(ActionList,MaxActions);
            ActionList:=NewActionList;
            MaxActions:=NewMaxActions;
          end;

          SaveGroups;

          if ChMask<>0 then //??
          begin
            NotifyEventHooks(hHookChanged,ChMask,0);
            ChMask:=0;
          end;

        end;

        NM_DBLCLK: begin
          if PNMListView(lParam)^.iItem>=0 then
            PostMessageW(PNMHdr(lParam)^.hWndFrom,LVM_EDITLABELW,
                        PNMListView(lParam)^.iItem,0);
        end;

        LVN_ITEMCHANGED: begin
          if DontReact then exit; // bug when group moved avoid

          if wParam=IDC_ACTION_GROUP then
          begin
            if PNMLISTVIEW(lParam)^.uChanged=LVIF_STATE then
            begin
              lvflag:=(PNMLISTVIEW(lParam)^.uOldState and LVNI_FOCUSED)-
                      (PNMLISTVIEW(lParam)^.uNewState and LVNI_FOCUSED);

              if lvflag>0 then // old focus
                BuildActionChain(Dialog,PNMLISTVIEW(lParam)^.iItem)
              else if lvflag<0 then // new focus
              begin
                DontReact:=true;

                ClearDialogData;
                MakeActionList(Dialog,@NewGroupList^[PNMLISTVIEW(lParam)^.lParam]);
                CheckGrpList(Dialog,PNMLISTVIEW(lParam)^.iItem);

                DontReact:=false;
              end
              else
              begin
                lvflag:=(PNMLISTVIEW(lParam)^.uOldState and LVNI_SELECTED)-
                        (PNMLISTVIEW(lParam)^.uNewState and LVNI_SELECTED);
                if lvflag<>0 then
                  CheckGrpList(Dialog,PNMLISTVIEW(lParam)^.iItem);
              end;
            end;
          end
          else if wParam=IDC_ACTION_LIST then
          begin
            lvflag:=(PNMLISTVIEW(lParam)^.uOldState and LVNI_FOCUSED)-
                    (PNMLISTVIEW(lParam)^.uNewState and LVNI_FOCUSED);
            if lvflag>0 then // old focus
              SaveAction(Dialog,
                         PNMLISTVIEW(lParam)^.iItem,
                         PNMLISTVIEW(lParam)^.lParam)
            else if lvflag<0 then // new focus
            begin
              DontReact:=true;

              ResetDialogs;
              j:=PNMLISTVIEW(lParam)^.lParam;
              FillAction(NewActionList^[j]);
              CheckActList(Dialog,PNMLISTVIEW(lParam)^.iItem);

              DontReact:=false;
            end
            else
            begin // checkboxes
              lvflag:=(PNMLISTVIEW(lParam)^.uOldState and LVNI_SELECTED)-
                      (PNMLISTVIEW(lParam)^.uNewState and LVNI_SELECTED);
              if lvflag<>0 then
                CheckGrpList(Dialog,PNMLISTVIEW(lParam)^.iItem);

              if (PNMLISTVIEW(lParam)^.uOldState or PNMLISTVIEW(lParam)^.uNewState)=$3000 then
              begin
                if PNMLISTVIEW(lParam)^.uOldState=$1000 then
                  i:=0
                else
                  i:=ACF_DISABLED;
                j:=PNMLISTVIEW(lParam)^.lParam;
                if NewActionList^[j]<>nil then
//!!                  NewActionList^[j].flags1:=(NewActionList^[j].flags1 and not ACF_DISABLED) or dword(i);
                ChMask:=ChMask or ACTM_ACT or ACTM_ACTS;
                SetChanged(Dialog,etACT);
              end;
            end;
          end;
        end;

        LVN_ENDLABELEDITW: begin
          if DontReact then exit;

          if wParam=IDC_ACTION_GROUP then
          begin
            with PLVDISPINFOW(lParam)^ do
            begin
              if item.pszText<>nil then
              begin
                ChMask:=ChMask or ACTM_RENAME;
                SetChanged(Dialog,etHK);
                item.mask:=LVIF_TEXT;
                if pWideChar(item.pszText)^=#0 then
                  pWideChar(item.pszText):=NoDescription;
                SendMessageW(hdr.hWndFrom,LVM_SETITEMW,0,tlparam(@item));

                with NewGroupList^[item.lParam] do
                begin
                  mFreeMem(descr);
                  StrDupW(descr,item.pszText);
                end;

                result:=1;
              end;
            end;
          end
          else if wParam=IDC_ACTION_LIST then
          begin
            with PLVDISPINFOW(lParam)^ do
            begin
              if item.pszText<>nil then
              begin
                ChMask:=ChMask or ACTM_ACT or ACTM_ACTS;
                SetChanged(Dialog,etACT);
                ChangeActionName(Dialog,item.iItem,pWideChar(item.pszText));
                result:=1;
              end;
//??
            end;
          end;
        end;

      end;
    end;
  else
//  {result:=}DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
//  {result:=}DefWindowProc(Dialog,hMessage,wParam,lParam);
end;
