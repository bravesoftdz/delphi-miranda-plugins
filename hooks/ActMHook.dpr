library ActMHook;

uses
  m_api, Windows, commctrl, messages, wrapper, common, dbsettings, io;

{$r hooks.res}

const
  PluginInfo:TPLUGININFOEX=(
    cbSize     :sizeof(TPLUGININFOEX);
    shortName  :'ActMan Hooks';
    version    :$00000100;
    description:'Simple Miranda event catcher for ActMan plugin';
    author     :'Awkward';
    authorEmail:'panda75@bk.ru';
    copyright  :'';
    homepage   :'http://awkward.miranda.im/';
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

var
  NoDescription:PWideChar;

var
  opthook,
  onloadhook:THANDLE;

{$i i_hook.inc}

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  Result:=0;
  PluginLink^.UnhookEvent(onloadhook);

  opthook:=PluginLink^.HookEvent(ME_OPT_INITIALISE ,@OnOptInitialise);
  Init;
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
  PluginLink^.UnhookEvent(opthook);
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
