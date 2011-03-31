{$IMAGEBASE $13500000}
//{$IFDEF WIN64}{$A8}{$ENDIF}
library Translate;

{$R frm.res}

uses
  Windows, m_api, tr_frame;

var
  PluginInterfaces:array [0..1] of MUUID;

function MirandaPluginInfoEx(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize     :=SizeOf(TPLUGININFOEX);
  PluginInfo.shortName  :='Google Translate frame';
  PluginInfo.version    :=$00000001;
  PluginInfo.description:='this plugin creating frame with google translate text ability';
  PluginInfo.author     :='Awkward';
  PluginInfo.authorEmail:='panda75@bk.ru; awk1975@ya.ru';
  PluginInfo.copyright  :='(c) 2010-2011 Awkward';
  PluginInfo.homepage   :='http://code.google.com/p/delphi-miranda-plugins/';
  PluginInfo.flags      :=UNICODE_AWARE;
  PluginInfo.replacesDefaultModule:=0;
  PluginInfo.uuid:=MIID_TRANSLATE;
end;

var
  onloadhook:THANDLE;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  Result:=0;
  PluginLink^.UnhookEvent(onloadhook);
  Langpack_register;
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
  MirandaPluginInterfaces,MirandaPluginInfoEx;

end.
