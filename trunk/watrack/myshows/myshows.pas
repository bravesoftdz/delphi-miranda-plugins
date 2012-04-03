unit myshows;
{$include compilers.inc}
interface
{$Resource myshows.res}
implementation

uses windows, messages, commctrl,
  common,
  m_api,dbsettings,wrapper, mirutils,
  wat_api,global;

const
  DefTimerValue = 10*60*1000; // 10 minutes
const
  opt_ModStatus:PAnsiChar = 'module/myshows';
const
  IcoMyShows:pAnsiChar = 'WATrack_myshows';
var
  md5:TMD5_INTERFACE;
  msh_tries:integer;
  sic:THANDLE;
  slastinf:THANDLE;
  slast:THANDLE;
const
  msh_lang    :integer=0;
  msh_on      :integer=0;
  hMenuMyShows:HMENU = 0;
  msh_login   :pAnsiChar=nil;
  msh_password:pAnsiChar=nil;
  session_id  :pAnsiChar=nil;
  np_url      :pAnsiChar=nil;
  sub_url     :pAnsiChar=nil;

function GetModStatus:integer;
begin
  result:=DBReadByte(0,PluginShort,opt_ModStatus,1);
end;

procedure SetModStatus(stat:integer);
begin
  DBWriteByte(0,PluginShort,opt_modStatus,stat);
end;

{$i i_const.inc}
{$i i_myshows_opt.inc}
{$i i_myshows_api.inc}

function ThScrobble(param:LPARAM):dword; //stdcall;
{
var
  count:integer;
  npisok:bool;
begin
  count:=msh_tries;
  npisok:=false;
  while count>0 do
  begin
    if Scrobble>=0 then break;
    dec(count);
  end;
  if count=0 then ;
}
begin
  Scrobble;
  result:=0;
end;

const
  hTimer:THANDLE=0;

procedure TimerProc(wnd:HWND;uMsg:uint;idEvent:uint_ptr;dwTime:dword); stdcall;
var
  res:{$IFDEF COMPILER_16_UP}Longword{$ELSE}uint_ptr{$ENDIF};
begin
  if hTimer<>0 then
  begin
    KillTimer(0,hTimer);
    hTimer:=0;
  end;

  if (msh_login   <>nil) and (msh_login^   <>#0) and
     (msh_password<>nil) and (msh_password^<>#0) then
    CloseHandle(BeginThread(nil,0,@ThScrobble,nil,0,res));
end;

function NewPlStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  flag:integer;
  mi:TCListMenuItem;
  timervalue:integer;
begin
  result:=0;
  case wParam of
    WAT_EVENT_NEWTRACK: begin
      if hTimer<>0 then
        KillTimer(0,hTimer);
      // need to use half of movie len if presents
      if msh_on=0 then
      begin
        if PluginLink^.ServiceExists(MS_JSON_GETINTERFACE)<>0 then
        begin
          if pSongInfo(lParam).width>0 then // for video only
          begin
            timervalue:=5000;//(pSongInfo(lParam).total div 2)*1000; // to msec
            if timervalue=0 then
              timervalue:=DefTimerValue;
            hTimer:=SetTimer(0,0,timervalue,@TimerProc)
          end;
        end;
      end;
    end;

    WAT_EVENT_PLUGINSTATUS: begin
      case lParam of
        dsEnabled: begin
          msh_on:=msh_on and not 2;
          flag:=0;
        end;
        dsPermanent: begin
          msh_on:=msh_on or 2;
          if hTimer<>0 then
          begin
            KillTimer(0,hTimer);
            hTimer:=0;
          end;
          flag:=CMIF_GRAYED;
        end;
      else // like 1
        exit
      end;
      FillChar(mi,sizeof(mi),0);
      mi.cbSize:=sizeof(mi);
      mi.flags :=CMIM_FLAGS+flag;
      CallService(MS_CLIST_MODIFYMENUITEM,hMenuMyShows,dword(@mi));
    end;
    
    WAT_EVENT_PLAYERSTATUS: begin
      case Integer(loword(lParam)) of
        WAT_PLS_NOMUSIC,WAT_PLS_NOTFOUND: begin
          if hTimer<>0 then
          begin
            KillTimer(0,hTimer);
            hTimer:=0;
          end;
        end;
      end;
    end;
  end;
end;

{$i i_myshows_dlg.inc}

function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
begin
  result:=0;
  FillChar(mi,SizeOf(mi),0);
  mi.cbSize:=sizeof(mi);
  mi.flags :=CMIM_ICON;
  mi.hIcon :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoMyShows));
  CallService(MS_CLIST_MODIFYMENUITEM,hMenuMyShows,dword(@mi));
end;

function SrvMyShowsInfo(wParam:WPARAM;lParam:LPARAM):int;cdecl;
//var
//  data:tMyShowsInfo;
begin
{
  case wParam of
    0: result:=GetArtistInfo(data,lParam);
    1: result:=GetAlbumInfo (data,lParam);
    2: result:=GetTrackInfo (data,lParam);
  else
    result:=0;
  end;
}
end;

function SrvMyShows(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
begin
  FillChar(mi,sizeof(mi),0);
  mi.cbSize:=sizeof(mi);
  mi.flags :=CMIM_NAME;
  if odd(msh_on) then
  begin
    mi.szName.a:='Disable scrobbling';
    msh_on:=msh_on and not 1;
  end
  else
  begin
    mi.szName.a:='Enable scrobbling';
    msh_on:=msh_on or 1;
    if hTimer<>0 then
    begin
      KillTimer(0,hTimer);
      hTimer:=0;
    end;
  end;
  CallService(MS_CLIST_MODIFYMENUITEM,hMenuMyShows,dword(@mi));
  result:=ord(not odd(msh_on));
end;

procedure CreateMenus;
var
  mi:TCListMenuItem;
  sid:TSKINICONDESC;
begin
  FillChar(sid,SizeOf(TSKINICONDESC),0);
  sid.cbSize:=SizeOf(TSKINICONDESC);
  sid.cx:=16;
  sid.cy:=16;
  sid.szSection.a:='WATrack';

  sid.hDefaultIcon   :=LoadImage(hInstance,'IDI_MYSHOWS',IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoMyShows;
  sid.szDescription.a:='MyShows';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);
  
  FillChar(mi, sizeof(mi), 0);
  mi.cbSize       :=sizeof(mi);
  mi.szPopupName.a:=PluginShort;

  mi.hIcon        :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoMyShows));
  mi.szName.a     :='Disable scrobbling';
  mi.pszService   :=MS_WAT_MYSHOWS;
  mi.popupPosition:=500050000;
  hMenuMyShows:=PluginLink^.CallService(MS_CLIST_ADDMAINMENUITEM,0,dword(@mi));
end;

// ------------ base interface functions -------------

function AddOptionsPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
begin
  tmpl:='MYSHOWS';
  proc:=@DlgProcOptions;
  name:='MyShows';
  result:=0;
end;

var
  plStatusHook:THANDLE;

function InitProc(aGetStatus:boolean=false):integer;
begin
  slastinf:=PluginLink^.CreateServiceFunction(MS_WAT_MYSHOWSINFO,@SrvMyShowsInfo);
  if aGetStatus then
  begin
    if GetModStatus=0 then
    begin
      result:=0;
      exit;
    end;
  end
  else
  begin
    SetModStatus(1);
    msh_on:=msh_on and not 4;
  end;
  result:=1;

  LoadOpt;

  if md5.cbSize=0 then
  begin
    md5.cbSize:=SizeOf(TMD5_INTERFACE);
    if (CallService(MS_SYSTEM_GET_MD5I,0,dword(@md5))<>0) then
    begin
    end;
  end;

  slast:=PluginLink^.CreateServiceFunction(MS_WAT_MYSHOWS,@SrvMyShows);
  if hMenuMyShows=0 then
    CreateMenus;
  sic:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);
  if (msh_on and 4)=0 then
    plStatusHook:=PluginLink^.HookEvent(ME_WAT_NEWSTATUS,@NewPlStatus);
end;

procedure DeInitProc(aSetDisable:boolean);
begin
  if aSetDisable then
    SetModStatus(0)
  else
    PluginLink^.DestroyServiceFunction(slastinf);

  PluginLink^.DestroyServiceFunction(slast);
  PluginLink^.UnhookEvent(plStatusHook);
  PluginLink^.UnhookEvent(sic);

  if hTimer<>0 then
  begin
    KillTimer(0,hTimer);
    hTimer:=0;
  end;

  FreeOpt;

  mFreeMem(session_id);
  mFreeMem(np_url);
  mFreeMem(sub_url);

  msh_on:=msh_on or 4;
end;

var
  mmyshows:twModule;

procedure Init;
begin
  mmyshows.Next      :=ModuleLink;
  mmyshows.Init      :=@InitProc;
  mmyshows.DeInit    :=@DeInitProc;
  mmyshows.AddOption :=@AddOptionsPage;
  mmyshows.ModuleName:='MyShows.ru';
  ModuleLink     :=@mmyshows;

  md5.cbSize:=0;
end;

begin
  Init;
end.
