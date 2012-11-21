{}
const
  etHK  = 1; // Groups  changed
  etACT = 2; // Actions changed
const
  ACI_APPLY  :PAnsiChar = 'ACI_Apply';
  ACI_NEW    :PAnsiChar = 'ACI_New';
  ACI_UP     :PAnsiChar = 'ACI_Up';
  ACI_DOWN   :PAnsiChar = 'ACI_Down';
  ACI_DELETE :PAnsiChar = 'ACI_Delete';
  ACI_RELOAD :PAnsiChar = 'ACI_Reload';
  ACI_TEST   :PAnsiChar = 'ACI_Test';
  ACI_IMPORT :PAnsiChar = 'ACI_Import';
  ACI_EXPORT :PAnsiChar = 'ACI_Export';
const
  ACI_VAR_UNCHECKED = 'ACI_VarUnChecked';
  ACI_VAR_CHECKED   = 'ACI_VarChecked';


procedure RegisterIcon(var sid:TSKINICONDESC;id:uint_ptr;name:PAnsiChar;descr:PAnsiChar);
var
  buf:array [0..63] of WideChar;
begin
  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(id),IMAGE_ICON,16,16,0);
  sid.pszName        :=name;
  sid.szDescription.w:=FastAnsiToWideBuf(descr,buf);
  Skin_AddIcon(@sid);
  DestroyIcon(sid.hDefaultIcon);
end;

procedure RegisterIcons;
var
  sid:TSKINICONDESC;
//  i:integer;
begin
  FillChar(sid,SizeOf(TSKINICONDESC),0);
  sid.cbSize     :=SizeOf(TSKINICONDESC);
  sid.cx         :=16;
  sid.cy         :=16;
  sid.flags      :=SIDF_UNICODE;
  sid.szSection.w:='Actions';

  RegisterIcon(sid,IDI_APPLY  ,ACI_APPLY  ,'Apply');
  RegisterIcon(sid,IDI_NEW    ,ACI_NEW    ,'New');
  RegisterIcon(sid,IDI_DELETE ,ACI_DELETE ,'Delete');
  RegisterIcon(sid,IDI_UP     ,ACI_UP     ,'Up');
  RegisterIcon(sid,IDI_DOWN   ,ACI_DOWN   ,'Down');
  RegisterIcon(sid,IDI_RELOAD ,ACI_RELOAD ,'Reload');
  RegisterIcon(sid,IDI_TEST   ,ACI_TEST   ,'Test');
  RegisterIcon(sid,IDI_IMPORT ,ACI_IMPORT ,'Import');
  RegisterIcon(sid,IDI_EXPORT ,ACI_EXPORT ,'Export');

{!!
  for i:=0 to ACT_MAXTYPE-1 do
    with ActIds[i] do
      RegisterIcon(sid,id,icon,text);
}
{
  sid.cx:=8;
  sid.cy:=8;
  RegisterIcon(sid,IDI_VAR_CHECKED  ,ACI_VAR_CHECKED  ,'Use Variables');
  RegisterIcon(sid,IDI_VAR_UNCHECKED,ACI_VAR_UNCHECKED,'Don''t use Variables');
}
end;

{$include i_opt_dlg2.inc}

function OnOptInitialise(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  odp:TOPTIONSDIALOGPAGE;
  ptr:pActionLink;
  tmpl:pAnsiChar;
  name:pansiChar;
  proc:pointer;
  i:integer;
begin
  result:=0;
  NoDescription  :=TranslateW('No Description');
  StrCopyW(xmlfilename,'c:\export.xml');

  DoInitCommonControls(ICC_USEREX_CLASSES);

  FillChar(odp,SizeOf(odp),0);
  odp.cbSize     :=SizeOf(odp);
  odp.flags      :=ODPF_BOLDGROUPS;
  odp.Position   :=900003000;
  odp.hInstance  :=hInstance;
  odp.szGroup.a  :='Services';
  odp.szTitle.a  :='Actions';
  odp.szTab.a    :='Actions';
  odp.pfnDlgProc :=@DlgProcOpt2;
  odp.pszTemplate:=PAnsiChar(IDD_ACTION);
  Options_AddPage(wParam,@odp);

  ptr:=ActionLink;
  while ptr<>nil do
  begin
    if @ptr^.AddOption<>nil then
    begin
      i:=ptr^.AddOption(tmpl,proc,name);
      odp.pszTemplate:=tmpl;
      odp.pfnDlgProc :=proc;
      odp.szTab.a    :=name;
      Options_AddPage(wParam,@odp);
      if i>0 then continue;
    end;
    ptr:=ptr^.Next;
  end;
end;
