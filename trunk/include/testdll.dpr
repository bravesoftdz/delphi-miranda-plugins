library testdll;

uses
  m_api, Windows;

const
  PluginInfo:TPLUGININFOEX=(
    cbSize     :sizeof(TPLUGININFOEX);
    shortName  :'Plugin Template';
    version    :$00000001;
    description:'The long description of your plugin, to go in the plugin options dialog';
    author     :'J. Random Hacker';
    authorEmail:'noreply@sourceforge.net';
    copyright  :'(c) 2003 J. Random Hacker';
    homepage   :'http://miranda-icq.sourceforge.net/';
    flags      :UNICODE_AWARE;
    replacesDefaultModule:0;
    uuid:'{08B86253-EC6E-4d09-B7A9-64ACDF0627B8}';
  );

var
  PluginInterfaces:array [0..1] of MUUID;

function MirandaPluginInfo(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize:=SizeOf(TPLUGININFO);
end;

function MirandaPluginInfoEx(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize:=SizeOf(TPLUGININFOEX);
end;

function PluginMenuCommand(wParam: WPARAM; lParam: LPARAM):Integer; cdecl;
begin
  Result:=0;
  // this is called by Miranda, thus has to use the cdecl calling convention
  // all services and hooks need this.
  MessageBox(0, 'Just groovy, baby!', 'Plugin-o-rama', MB_OK);
end;

var
  onloadhook:THANDLE;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
begin
  Result:=0;
  PluginLink^.UnhookEvent(onloadhook);

  PluginLink^.CreateServiceFunction('TestPlug/MenuCommand', @PluginMenuCommand);
  FillChar(mi,SizeOf(mi),0);
  mi.cbSize    :=SizeOf(mi);
  mi.position  :=$7FFFFFFF;
  mi.flags     :=0;
  mi.hIcon     :=LoadSkinnedIcon(SKINICON_OTHER_MIRANDA);
  mi.szName.a  :='&Test Plugin...';
  mi.pszService:='TestPlug/MenuCommand';
  PluginLink^.CallService(MS_CLIST_ADDMAINMENUITEM,0,dword(@mi));
end;

function Load(link:PPLUGINLINK):int; cdecl;
begin
  // this line is VERY VERY important, if it's not present, expect crashes.
  PluginLink:=Pointer(link);
  InitMMI;

  onloadhook:=PluginLink^.HookEvent(ME_SYSTEM_MODULESLOADED,@OnModulesLoaded);

  Result:=0;
end;

function Unload:int; cdecl;
begin
  Result:=0;
end;

function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  PluginInterfaces[0]:=MIID_TESTPLUGIN;
  PluginInterfaces[1]:=MIID_LAST;
  result:=@PluginInterfaces;
end;

exports
  Load, Unload,
  MirandaPluginInfo,
  MirandaPluginInterfaces,MirandaPluginInfoEx;

begin
end.
