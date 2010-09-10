{}
const
  etHK  = 1; // Groups  changed
  etACT = 2; // Actions changed
const
  ACI_NEW    :PAnsiChar = 'ACI_New';
  ACI_UP     :PAnsiChar = 'ACI_Up';
  ACI_DOWN   :PAnsiChar = 'ACI_Down';
  ACI_DELETE :PAnsiChar = 'ACI_Delete';
  ACI_RELOAD :PAnsiChar = 'ACI_Reload';
  ACI_TEST   :PAnsiChar = 'ACI_Test';
  ACI_IMPORT :PAnsiChar = 'ACI_Import';
  ACI_EXPORT :PAnsiChar = 'ACI_Export';
const
  ACI_CONTACT = 'ACI_Contact';
  ACI_SERVICE = 'ACI_Service';
  ACI_PROGRAM = 'ACI_Program';
  ACI_INSERT  = 'ACI_Insert';
  ACI_ADVANCE = 'ACI_Advanced';
  ACI_CHAIN   = 'ACI_Chain';
  ACI_RW      = 'ACI_Database';
  ACI_MESSAGE = 'ACI_Message';

  ACI_FORMAT  = 'ACI_Format';

  ACI_VAR_UNCHECKED = 'ACI_VarUnChecked';
  ACI_VAR_CHECKED   = 'ACI_VarChecked';

const
  sresInt    = 0;
  sresHex    = 1;
  sresString = 2;
  sresStruct = 3;
type
  tActId = record
    code:dword;
    id  :dword;
    icon:PAnsiChar;
    text:PAnsiChar;
  end;
const
  ActIds:array [0..ACT_MAXTYPE-1] of tActId = (
      (code:ACT_CONTACT; id:IDI_CONTACT; icon:ACI_CONTACT; text:'Open contact window'),
      (code:ACT_SERVICE; id:IDI_SERVICE; icon:ACI_SERVICE; text:'Call service'),
      (code:ACT_PROGRAM; id:IDI_PROGRAM; icon:ACI_PROGRAM; text:'Execute program'),
      (code:ACT_TEXT   ; id:IDI_INSERT ; icon:ACI_INSERT ; text:'Insert text'),
      (code:ACT_ADVANCE; id:IDI_ADVANCE; icon:ACI_ADVANCE; text:'Advanced'),
      (code:ACT_CHAIN  ; id:IDI_CHAIN  ; icon:ACI_CHAIN  ; text:'Link to action'),
      (code:ACT_RW     ; id:IDI_RW     ; icon:ACI_RW     ; text:'Profile'),
      (code:ACT_MESSAGE; id:IDI_MESSAGE; icon:ACI_MESSAGE; text:'MessageBox'));

function SetIcon(btn:HWND;name:PAnsiChar):HICON;
begin
  result:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(name));
  SendMessage(btn,BM_SETIMAGE,IMAGE_ICON,result);
end;

procedure RegisterIcons;
var
  sid:TSKINICONDESC;

  procedure RegisterIcon(id:dword;name:PAnsiChar;descr:PAnsiChar);
  var
    buf:array [0..63] of WideChar;
  begin
    sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(id),IMAGE_ICON,16,16,0);
    sid.pszName        :=name;
    sid.szDescription.w:=FastAnsiToWideBuf(descr,buf);
    PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
    DestroyIcon(sid.hDefaultIcon);
  end;

var
  i:integer;
begin
  FillChar(sid,SizeOf(TSKINICONDESC),0);
  sid.cbSize     :=SizeOf(TSKINICONDESC);
  sid.cx         :=16;
  sid.cy         :=16;
  sid.flags      :=SIDF_UNICODE;
  sid.szSection.w:='Actions';

  RegisterIcon(IDI_NEW    ,ACI_NEW    ,'New');
  RegisterIcon(IDI_DELETE ,ACI_DELETE ,'Delete');
  RegisterIcon(IDI_UP     ,ACI_UP     ,'Up');
  RegisterIcon(IDI_DOWN   ,ACI_DOWN   ,'Down');
  RegisterIcon(IDI_RELOAD ,ACI_RELOAD ,'Reload');
  RegisterIcon(IDI_TEST   ,ACI_TEST   ,'Test');
  RegisterIcon(IDI_IMPORT ,ACI_IMPORT ,'Import');
  RegisterIcon(IDI_EXPORT ,ACI_EXPORT ,'Export');

  RegisterIcon(IDI_FORMAT ,ACI_FORMAT ,'Contact list format');

  for i:=0 to ACT_MAXTYPE-1 do
    with ActIds[i] do
      RegisterIcon(id,icon,text);

  sid.cx:=8;
  sid.cy:=8;
  RegisterIcon(IDI_VAR_CHECKED  ,ACI_VAR_CHECKED  ,'Use Variables');
  RegisterIcon(IDI_VAR_UNCHECKED,ACI_VAR_UNCHECKED,'Don''t use Variables');
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

    DestroyGroups(GroupList,MaxGroups);
    wnd:=GetDlgItem(dialog,IDC_ACTION_GROUP);
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
        SendMessageW(wnd,LVM_GETITEMW,0,dword(@li)); // GetLParam(wnd,i);
        move(NewGroupList^[li.lParam],GroupList^[i],SizeOf(THKRecord));
        li.lParam:=i;
        SendMessageW(wnd,LVM_SETITEMW,0,dword(@li));
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
      DestroyGroups(NewGroupList,NewMaxGroups);
    NewGroupList:=nil;
  end;
end;

procedure InsertString(wnd:HWND;num:dword;str:PAnsiChar);
var
  buf:array [0..127] of WideChar;
begin
  SendMessageW(wnd,CB_SETITEMDATA,
      SendMessageW(wnd,CB_ADDSTRING,0,
          dword(TranslateW(FastAnsiToWideBuf(str,buf)))),
      num);
{
  SendMessageW(wnd,CB_INSERTSTRING,num,
      dword(TranslateW(FastAnsiToWideBuf(str,buf))));
}
end;

{$include i_opt_struct.inc}
{$include i_opt_dlg2.inc}

function OnOptInitialise(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  odp:TOPTIONSDIALOGPAGE;
begin
  result:=0;
  NoDescription  :=TranslateW('No Description');
  FillChar(odp,SizeOf(odp),0);
  odp.cbSize     :=OPTIONPAGE_OLD_SIZE3;  //for 0.5 compatibility
  odp.flags      :=ODPF_BOLDGROUPS or ODPF_EXPERTONLY;
  odp.Position   :=900003000;
  odp.hInstance  :=hInstance;
  odp.szGroup.a  :='Services';
  odp.szTitle.a  :='Actions';
  odp.szTab.a    :='Actions';
  odp.pfnDlgProc :=@DlgProcOpt2;
  odp.pszTemplate:=PAnsiChar(IDD_ACTION);
  PluginLink^.CallService(MS_OPT_ADDPAGE,wParam,dword(@odp));
  DoInitCommonControls(ICC_USEREX_CLASSES);
  StrCopyW(xmlfilename,'c:\export.xml');
end;
