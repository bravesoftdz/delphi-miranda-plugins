library libLangpack;

uses
  Windows, m_api, common,io, KOL, wrapper;

const
  PluginInfo:TPLUGININFOEX=(
    cbSize     :sizeof(TPLUGININFOEX);
    shortName  :'Langpack Plugin Template';
    version    :$00000001;
    description:'Let''s try to upgrade our langpack';
    author     :'Awkward';
    authorEmail:'panda75@bk.u';
    copyright  :'';
    homepage   :'http://awkward.miranda.im/';
    flags      :UNICODE_AWARE;
    replacesDefaultModule:0;
    uuid:'{CF77870C-0866-436E-BCB4-AA015250A1F5}';
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

const
  bModuleInitialized:boolean=false;

{$i langpack.inc}

var
  onloadhook:THANDLE;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  Result:=0;
  PluginLink^.UnhookEvent(onloadhook);
  LoadLangPackModule;
end;

function Load(link:PPLUGINLINK):int; cdecl;
begin
  // this line is VERY VERY important, if it's not present, expect crashes.
  PluginLink:=Pointer(link);
  InitMMI;

  LoadLangPackServices;

  onloadhook:=PluginLink^.HookEvent(ME_SYSTEM_MODULESLOADED,@OnModulesLoaded);

  Result:=0;
end;

function Unload:int; cdecl;
begin
  UnloadLangPackModule();
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
