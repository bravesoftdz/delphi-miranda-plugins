{$IMAGEBASE $13500000}
library Translate;

{$R frm.res}

uses
  m_api, Windows, tr_frame;

const
  PluginInfo:TPLUGININFOEX=(
    cbSize     :sizeof(TPLUGININFOEX);
    shortName  :'Google Translate frame';
    version    :$00000001;
    description:'this plugin creating frame with google translate text ability';
    author     :'Awkward';
    authorEmail:'panda75@bk.ru';
    copyright  :'(c) 2010 Awkward';
    homepage   :'http://awkward.miranda.im/';
    flags      :UNICODE_AWARE;
    replacesDefaultModule:0;
    uuid:'{0C0954EA-43D7-4452-99AC-F084D4456716}';
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
  onloadhook:THANDLE;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  Result:=0;
  PluginLink^.UnhookEvent(onloadhook);
  CreateFrame(0);
end;

function Load(link:PPLUGINLINK):int; cdecl;
begin
  PluginLink:=Pointer(link);
  InitMMI;

  onloadhook:=PluginLink^.HookEvent(ME_SYSTEM_MODULESLOADED,@OnModulesLoaded);

  Result:=0;
end;

function Unload:int; cdecl;
begin
  Result:=0;
  DestroyFrame;
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
