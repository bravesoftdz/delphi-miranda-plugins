{$IMAGEBASE $13100000}
library quicksearch;

{$R qs.res}

uses
//  FastMM4,
  Windows,
  Messages,
  m_api,
  sr_optdialog,
  sr_global,
  sr_window,
  sr_frame,
  mirutils,
  common,
  hotkeys;

var
  opthook:cardinal;
  onloadhook:cardinal;
  onstatus,
  ondelete,
//  onaccount,
  onadd:cardinal;
  servshow:cardinal;

const
  icohook:THANDLE = 0;
// Updater compatibility data
const
  VersionURL        = 'http://addons.miranda-im.org/details.php?action=viewfile&id=3285';
  VersionPrefix     = '<span class="fileNameHeader">QuickSearch Mod ';
  UpdateURL         = 'http://addons.miranda-im.org/feed.php?dlfile=3285';
  BetaVersionURL    = 'http://awkward.miranda.im/index.htm';
  BetaVersionPrefix = '>QuickSearch plugin ';
  BetaUpdateURL     = 'http://awkward.miranda.im/quicksearch.zip';
  BetaChangelogURL  = nil;

var
  PluginInterfaces:array [0..1] of MUUID;

function MirandaPluginInfoEx(mirandaVersion:DWORD):PPLUGININFOEX; cdecl;
begin
  result:=@PluginInfo;
  PluginInfo.cbSize     :=SizeOf(TPLUGININFOEX);
  PluginInfo.shortName  :='Quick Search Mod';
  PluginInfo.version    :=$01040112;
  PluginInfo.description:=
    'This Plugin allow you to quick search for nickname,'+
    'firstname, lastname, email, uin in your contact list.'+
    'And now you may add any setting to display - for example'+
    'users version of miranda,group or city.';
  PluginInfo.author     :='Awkward, based on Bethoven sources';
  PluginInfo.authorEmail:='panda75@bk.ru; awk1975@ya.ru';
  PluginInfo.copyright  :='(c) 2004,2005 Bethoven; 2006-2011 Awkward';
  PluginInfo.homepage   :='http://code.google.com/p/delphi-miranda-plugins/';
  PluginInfo.flags      :=UNICODE_AWARE;
  PluginInfo.replacesDefaultModule:=0;
  PluginInfo.uuid       :=MIID_QUICKSEARCH;
end;

function OnTTBLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  addtotoolbar;
  result:=0;
end;

function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
//  ttb:TTBButtonV2; work only with TTBButton type :(
begin
  result:=0;
  FillChar(mi,SizeOf(mi),0);
  mi.cbSize:=sizeof(mi);
  mi.flags :=CMIM_ICON;

  mi.hIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,tlparam(QS_QS));
  PluginLink^.CallService(MS_CLIST_MODIFYMENUITEM,MainMenuItem,tlparam(@mi));

{// toptoolbar
  if PluginLink^.ServiceExists(MS_TTB_GETBUTTONOPTIONS)<>0 then
  begin
    pluginLink^.CallService(MS_TTB_GETBUTTONOPTIONS,(hTTBButton shl 16)+TTBO_ALLDATA,dword(@ttb));
    ttb.hIconUp:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(QS_QS));
    ttb.hIconDn:=ttb.hIconUp;
    pluginLink^.CallService(MS_TTB_SETBUTTONOPTIONS,(hTTBButton shl 16)+TTBO_ALLDATA,dword(@ttb));
  end;
}
end;

procedure RegisterIcons;
var
  sid:TSKINICONDESC;
begin
  FillChar(sid,SizeOf(TSKINICONDESC),0);
  sid.cbSize     :=SizeOf(TSKINICONDESC);
  sid.cx         :=16;
  sid.cy         :=16;
  sid.szSection.a:=qs_module;

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_QS),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_QS;
  sid.szDescription.a:=qs_name;
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_NEW),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_NEW;
  sid.szDescription.a:='New Column';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_ITEM),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_ITEM;
  sid.szDescription.a:='Save Column';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_UP),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_UP;
  sid.szDescription.a:='Column Up';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_DOWN),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_DOWN;
  sid.szDescription.a:='Column Down';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_DELETE),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_DELETE;
  sid.szDescription.a:='Delete Column';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_DEFAULT),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_DEFAULT;
  sid.szDescription.a:='Default';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_RELOAD),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_RELOAD;
  sid.szDescription.a:='Reload';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_MALE),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_MALE;
  sid.szDescription.a:='Male';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(IDI_FEMALE),IMAGE_ICON,16,16,0);
  sid.pszName        :=QS_FEMALE;
  sid.szDescription.a:='Female';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,lparam(@sid));
  DestroyIcon(sid.hDefaultIcon);

  icohook:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);
end;

function OnOptInitialise(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  odp:TOPTIONSDIALOGPAGE;
begin
  ZeroMemory(@odp,sizeof(odp));
  odp.cbSize     :=OPTIONPAGE_OLD_SIZE3;  //for 0.6+ compatibility
  odp.Position   :=900003000;
  odp.hInstance  :=hInstance;
  odp.pszTemplate:=PAnsiChar(IDD_DIALOG1);
  odp.szTitle.a  :=qs_name;
  odp.szGroup.a  :='Contact List';
  odp.pfnDlgProc :=@sr_optdialog.DlgProcOptions;
  odp.flags      :=ODPF_BOLDGROUPS;
  PluginLink^.CallService(MS_OPT_ADDPAGE,wParam,tlparam(@odp));
  Result:=0;
end;

function OpenSearchWindow(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
begin
  result:=0;
  if not opened then
    OpenSrWindow(pointer(wParam),lParam)
  else
    BringToFront;
end;

function OnModulesLoaded(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  upd:TUpdate;
  buf:array [0..63] of AnsiChar;
begin
  PluginLink^.UnhookEvent(onloadhook);

  if DetectHKManager<>HKMT_CORE then
    InitHotKeys;

  PluginLink^.CallService('DBEditorpp/RegisterSingleModule',twparam(qs_module),0);

  if PluginLink^.ServiceExists(MS_UPDATE_REGISTER)<>0 then
  begin
    with upd do
    begin
      cbSize              :=SizeOf(upd);
      szComponentName     :=PluginInfo.ShortName;
      szVersionURL        :=VersionURL;
      pbVersionPrefix     :=VersionPrefix;
      cpbVersionPrefix    :=length(VersionPrefix);
      szUpdateURL         :=UpdateURL;
      szBetaVersionURL    :=BetaVersionURL;
      pbBetaVersionPrefix :=BetaVersionPrefix;
      cpbBetaVersionPrefix:=length(pbBetaVersionPrefix);
      szBetaUpdateURL     :=BetaUpdateURL;
      pbVersion           :=CreateVersionStringPlugin(@pluginInfo,buf);
      cpbVersion          :=StrLen(pbVersion);
      szBetaChangelogURL  :=BetaChangelogURL;
    end;
    PluginLink^.CallService(MS_UPDATE_REGISTER,0,tlparam(@upd));
  end;

  RegisterIcons;
  RegisterColors;

  servshow:=PluginLink^.CreateServiceFunction(QS_SHOWSERVICE,@OpenSearchWindow);
  AddRemoveMenuItemToMainMenu;

  reghotkeys;

  onadd    :=PluginLink^.HookEvent(ME_DB_CONTACT_ADDED        ,@OnContactAdded);
  ondelete :=PluginLink^.HookEvent(ME_DB_CONTACT_DELETED      ,@OnContactDeleted);
  onstatus :=PluginLink^.HookEvent(ME_CLIST_CONTACTICONCHANGED,@OnStatusChanged);
//  onaccount:=PluginLink^.HookEvent(ME_PROTO_ACCLISTCHANGED    ,@OnAccountChanged);
  PluginLink.HookEvent(ME_TTB_MODULELOADED,@OnTTBLoaded);

  createframe(0);
  Result:=0;
end;

function Load(link:PPLUGINLINK):Integer;cdecl;
begin
  Result:=0;
  PluginLink:=pointer(link);
  InitMMI;
  Langpack_register;
  opthook   :=PluginLink^.HookEvent(ME_OPT_INITIALISE      ,@OnOptInitialise);
  onloadhook:=PluginLink^.HookEvent(ME_SYSTEM_MODULESLOADED,@OnModulesLoaded);
  loadopt_db(true);
end;

function Unload:Integer;cdecl;
begin
  result:=0;
  DestroyFrame;

  PluginLink^.DestroyServiceFunction(servshow);
  PluginLink^.UnhookEvent(opthook);
  PluginLink^.UnhookEvent(onadd);
  PluginLink^.UnhookEvent(ondelete);
  PluginLink^.UnhookEvent(onstatus);
//  PluginLink^.UnhookEvent(onaccount);
  if icohook<>0 then
    PluginLink^.UnhookEvent(icohook);

//  unreghotkeys;
  if DetectHKManager<>HKMT_CORE then
    FreeHotKeys;

  CloseSrWindow;

  clear_columns;
end;

function MirandaPluginInterfaces:PMUUID; cdecl;
begin
  PluginInterfaces[0]:=PluginInfo.uuid;
  PluginInterfaces[1]:=MIID_LAST;
  result:=@PluginInterfaces;
end;

exports
  Load, Unload,
  MirandaPluginInterfaces,MirandaPluginInfoEx;

begin
end.
