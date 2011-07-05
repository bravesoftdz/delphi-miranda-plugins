{}
var
  OldTableProc:pointer;

const
  ACI_NEW    :PAnsiChar = 'ACI_New';
  ACI_DELETE :PAnsiChar = 'ACI_Delete';

procedure CheckTaskList(wnd:HWND);
var
  i:integer;
  li:LV_ITEMW;
  arr:array [0..127] of WideChar;
begin
  ClearTasks;

  li.mask      :=LVIF_TEXT or LVIF_PARAM;
  li.pszText   :=@arr;
  li.cchTextMax:=SizeOf(arr) div SizeOf(WideChar);

  MaxTasks:=SendMessage(wnd,LVM_GETITEMCOUNT,0,0);
  
  GetMem  (TaskList ,MaxTasks*SizeOf(tTaskRec));
  FillChar(TaskList^,MaxTasks*SizeOf(tTaskRec),0);
  for i:=0 to MaxTasks-1 do
  begin
    with TaskList[i] do
    begin
{
      flags:=ACF_ASSIGNED;
      li.iItem   :=i;
      li.iSubItem:=0;
      SendMessageW(wnd,LVM_GETITEMW,0,LPARAM(@li));
      StrDupW(descr,arr);
      action:=li.lParam;
      li.iSubItem:=1;
      SendMessageA(wnd,LVM_GETITEMA,0,LPARAM(@li));
      StrDup(name,pAnsiChar(@arr));

      if ListView_GetCheckState(wnd,i)=0 then // disabled
        flags:=flags or ACF_DISABLED;
}
    end;
  end;
end;

procedure FillTaskList(wnd:HWND);
var
  i:integer;
  li:LV_ITEMW;
begin
  SendMessage(wnd,LVM_DELETEALLITEMS,0,0);
  for i:=0 to MaxTasks-1 do
  begin
    with TaskList[i] do
    begin
{
      if (flags and ACF_ASSIGNED)<>0 then
      begin
        li.mask    :=LVIF_TEXT+LVIF_PARAM;
        li.iSubItem:=0;
        li.iItem   :=i;
        li.lParam  :=action;
        li.pszText :=descr;
        li.iItem   :=SendMessageW(wnd,LVM_INSERTITEMW,0,LPARAM(@li));
        li.mask    :=LVIF_TEXT;
        li.iSubItem:=1;
        li.pszText :=pWideChar(name);
        SendMessageA(wnd,LVM_SETITEMA,0,LPARAM(@li));
        ListView_SetCheckState(wnd,li.iItem,(flags and ACF_DISABLED)=0);
      end;
}
    end;
  end;
  ListView_SetItemState(wnd,0,
    LVIS_FOCUSED or LVIS_SELECTED,
    LVIS_FOCUSED or LVIS_SELECTED);
end;

procedure ShowTaskData(Dialog:HWND; item:integer=-1);
var
  li:LV_ITEM;
  arr:array [0..127] of WideChar;
  wnd:HWND;
begin
{
  wnd:=GetDlgItem(Dialog,IDC_TASK_NAME);
  if item<0 then
    li.iItem:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED)
  else
    li.iItem:=item;

  li.mask      :=LVIF_TEXT+LVIF_PARAM;
  li.iSubItem  :=1;
  li.pszText   :=@arr;
  li.cchTextMax:=SizeOf(arr) div SizeOf(WideChar);
  arr[0]:=#0;
  SendMessageW(wnd,LVM_GETITEMW,0,LPARAM(@li));
  if arr[0]<>#0 then
    SetDlgItemTextW(Dialog,IDC_EVENTLIST,arr);
  CB_SelectData(GetDlgItem(Dialog,IDC_TASK_ACTION),li.lParam);
}
end;

procedure SaveTaskData(Dialog:HWND; item:integer=-1);
var
  wnd:HWND;
  li:LV_ITEM;
begin
  wnd:=GetDlgItem(Dialog,IDC_TASK_NAME);
{
  if item<0 then
    li.iItem:=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED)
  else
    li.iItem:=item;
  li.mask      :=LVIF_PARAM;
  li.lParam    :=CB_GetData(GetDlgItem(Dialog,IDC_ACTIONLIST));
  li.iSubItem  :=0;
  SendMessageW(wnd,LVM_SETITEMW,0,LPARAM(@li));
  li.mask      :=LVIF_TEXT;
  li.iSubItem  :=1;
  li.pszText   :=GetDlgText(Dialog,IDC_EVENTLIST);
  SendMessageW(wnd,LVM_SETITEMW,0,LPARAM(@li));
  mFreeMem(li.pszText);
}
end;

function NewTask(Dialog:HWND;item:integer=-1):integer;
var
  wnd:HWND;
  li:LV_ITEMW;
begin
  wnd:=GetDlgItem(Dialog,IDC_TASK_NAME);
  li.mask    :=LVIF_TEXT;
  if item<0 then
    li.iItem :=SendMessage(wnd,LVM_GETNEXTITEM,-1,LVNI_FOCUSED)+1
  else
    li.iItem :=item;
  li.iSubItem:=0;
  li.pszText :=TranslateW('Task sample');
  result:=SendMessageW(wnd,LVM_INSERTITEMW,0,LPARAM(@li));
end;

function DeleteTask(Dialog:HWND):integer;
var
  wnd:HWND;
  i:integer;
begin
  result:=0;
  wnd:=GetDlgItem(Dialog,IDC_TASK_NAME);
  for i:=ListView_GetItemCount(wnd)-1 downto 0 do
  begin
    if ListView_GetItemState(wnd,i,LVIS_SELECTED)<>0 then
      SendMessage(wnd,LVM_DELETEITEM,i,0);
  end;
  Listview_SetItemState(wnd,0,LVIS_FOCUSED or LVIS_SELECTED,
                              LVIS_FOCUSED or LVIS_SELECTED);
end;

function NewHKTableProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
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
            PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_TASK_NEW,0);
            exit;
          end;
          VK_DELETE: begin
            PostMessage(GetParent(Dialog),WM_COMMAND,(BN_CLICKED shl 16)+IDC_TASK_DELETE,0);
            exit;
          end;
        end;
      end;
    end;
  end;
  result:=CallWindowProc(OldTableProc,Dialog,hMessage,wParam,lParam);
end;

procedure FillActionList(wnd:HWND);
var
  ptr,ptr1:pChain;
  i,cnt:integer;
begin
  cnt:=CallService(MS_ACT_GETLIST,0,LPARAM(@ptr));
  SendMessage(wnd,CB_RESETCONTENT,0,0);
  if cnt>0 then
  begin
    ptr1:=ptr;
    inc(pbyte(ptr),4);
    for i:=0 to cnt-1 do
    begin
      CB_AddStrDataW(wnd,ptr^.descr,ptr^.id);
      inc(ptr);
    end;

    CallService(MS_ACT_FREELIST,0,LPARAM(ptr1));
    SendMessage(wnd,CB_SETCURSEL,0,0);
  end;
end;

function SetIcon(btn:HWND;name:PAnsiChar):HICON;
begin
  result:=PluginLink^.CallService(MS_SKIN2_GETICON,0,LPARAM(name));
  SendMessage(btn,BM_SETIMAGE,IMAGE_ICON,result);
end;

procedure SetIcons(Dialog:HWND);
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
  ti.hwnd    :=dialog;
  ti.hinst   :=hInstance;
{
  ti.uId     :=GetDlgItem(Dialog,IDC_EVENT_HELP);
  ti.lpszText:=TranslateW('Help');
  SendMessage(ti.uId,BM_SETIMAGE,IMAGE_ICON,
      CallService(MS_SKIN_LOADICON,SKINICON_OTHER_HELP,0));
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,LPARAM(@ti));
}  
  ti.uId     :=GetDlgItem(Dialog,IDC_TASK_NEW);
  ti.lpszText:=TranslateW('New');
  SetIcon(ti.uId,ACI_NEW);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,LPARAM(@ti));
  ti.uId     :=GetDlgItem(Dialog,IDC_TASK_DELETE);
  ti.lpszText:=TranslateW('Delete');
  SetIcon(ti.uId,ACI_DELETE);
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,LPARAM(@ti));
end;

function DlgProcOpt(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  wnd:HWND;
  lv:LV_COLUMNW;
begin
  result:=0;
  case hMessage of
    WM_INITDIALOG: begin
      wnd:=GetDlgItem(Dialog,IDC_TASK_NAME);
      SendMessage(wnd,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_CHECKBOXES,LVS_EX_CHECKBOXES);
      SendMessage(wnd,LVM_SETUNICODEFORMAT,1,0);
      zeromemory(@lv,sizeof(lv));
      lv.mask:=LVCF_WIDTH;
      lv.cx  :=110;
      SendMessageW(wnd,LVM_INSERTCOLUMNW ,0,tlparam(@lv));
      SendMessageW(wnd,LVM_SETCOLUMNWIDTH,0,LVSCW_AUTOSIZE_USEHEADER);

      OldTableProc:=pointer(SetWindowLongPtrW(wnd,GWL_WNDPROC,LONG_PTR(@NewHKTableProc)));
      TranslateDialogDefault(Dialog);

      SetIcons(Dialog);

      FillActionList(GetDlgItem(Dialog,IDC_TASK_ACTION));
      FillTaskList(wnd);
      ShowTaskData(Dialog);
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        EN_CHANGE: begin
        end;

        BN_CLICKED: begin
          case loword(wParam) of
            IDC_TASK_NEW   : NewTask(Dialog);
            IDC_TASK_DELETE: DeleteTask(Dialog);
          end;
        end;
      end;
    end;

    WM_NOTIFY: begin
      case integer(PNMHdr(lParam)^.code) of
        PSN_APPLY: begin
          SaveTaskData(Dialog);
          CheckTaskList(GetDlgItem(Dialog,IDC_TASK_NAME));
          SaveTasks;
        end;

        NM_DBLCLK: begin
        end;

        LVN_ITEMCHANGED: begin
        end;

        LVN_ENDLABELEDITW: begin
        end;
      end;
    end;
  end;
end;

function ActListChange(wParam:WPARAM;lParam:LPARAM):integer; cdecl;
begin
  result:=0;
  if settings<>0 then
    FillActionList(GetDlgItem(settings,IDC_TASK_ACTION));
end;
