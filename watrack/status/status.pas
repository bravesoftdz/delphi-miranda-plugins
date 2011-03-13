{Statistic}
unit Status;
{$include compilers.inc}
interface
{$Resource st_opt.res}
implementation

uses
  windows,messages,commctrl,
  common,m_api,mirutils,protocols,dbsettings,swrapper,syswin,
  global,wat_api,hlpdlg,CBEx,myRTF,Tmpl;

const
  HKN_INSERT:PansiChar = 'WAT_Insert';

procedure reghotkey;
var
  hkrec:HOTKEYDESC;
begin
//  if DisablePlugin=dsPermanent then
//    exit;
  with hkrec do
  begin
    cbSize          :=HOTKEYDESC_SIZE_V1;
    pszName         :=HKN_INSERT;
    pszDescription.a:='Global WATrack hotkey';
    pszSection.a    :=PluginName;
    pszService      :=MS_WAT_INSERT;
    DefHotKey       :=((HOTKEYF_ALT or HOTKEYF_CONTROL) shl 8) or VK_F5;
    lParam          :=0;
  end;
  CallService(MS_HOTKEY_REGISTER,0,dword(@hkrec));
end;

{$include i_st_vars.inc}
{$include i_st_rc.inc}
{$include i_opt_status.inc}
{$include i_hotkey.inc}
{$include i_status.inc}
{$include i_opt_3.inc}
{$include i_opt_11.inc}
{$include i_opt_12.inc}

// ------------ base interface functions -------------

function InitProc(aGetStatus:boolean=false):integer;
begin
  if aGetStatus then
  begin
    if GetModStatus=0 then
    begin
      result:=0;
      exit;
    end;
  end
  else
    SetModStatus(1);
  result:=1;

  loadopt;
  CreateProtoList;
  CreateTemplates;
  reghotkey;
  hINS:=PluginLink^.CreateServiceFunction(MS_WAT_INSERT,@InsertProc);
  plStatusHook:=PluginLink^.HookEvent(ME_WAT_NEWSTATUS,@NewPlStatus);

//  if PluginLink^.ServiceExists(MS_LISTENINGTO_GETPARSEDTEXT)<>0 then
//    hLTo:=PluginLink^.CreateServiceFunction(MS_LISTENINGTO_GETPARSEDTEXT,@ListenProc);
end;

procedure DeInitProc(aSetDisable:boolean);
var
  j:integer;
begin
  if aSetDisable then
    SetModStatus(0);

  for j:=1 to GetNumProto do
  begin
    if (SimpleMode<>BST_UNCHECKED) or ((GetProtoSetting(j) and psf_enabled)<>0) then
      CallProtoService(GetProtoName(j),PS_SET_LISTENINGTO,0,0);
  end;
//  PluginLink^.DestroyServiceFunction(hLTo);
  PluginLink^.DestroyServiceFunction(hINS);
  PluginLink^.UnhookEvent(plStatusHook);
  FreeProtoList;
  FreeTemplates;
end;

function AddOptionsPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
const
  count:integer=2;
begin
  if count=0 then
    count:=2;
  case count of
    2: begin
      tmpl:='COMMON';
      proc:=@DlgProcOptions3;
      name:='Status (common)';
    end;
    1: begin
      if SimpleMode=BST_UNCHECKED then
      begin
        tmpl:='TEMPLATE11';
        proc:=@DlgProcOptions11;
      end
      else
      begin
        tmpl:='TEMPLATE12';
        proc:=@DlgProcOptions12;
      end;
      name:='Status (templates)';
    end
  end;

  dec(count);
  result:=count;
end;

var
  mStatus:twModule;

procedure Init;
begin
  mStatus.Next      :=ModuleLink;
  mStatus.Init      :=@InitProc;
  mStatus.DeInit    :=@DeInitProc;
  mStatus.AddOption :=@AddOptionsPage;
  mStatus.ModuleName:='Statuses';
  ModuleLink        :=@mStatus;
end;

begin
  Init;
end.
