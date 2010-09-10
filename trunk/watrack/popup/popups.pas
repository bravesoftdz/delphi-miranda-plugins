{PopUp support}
unit Popups;
{$include compilers.inc}
interface
{$Resource popup.res}
implementation

uses windows,messages,commctrl,
     wat_api,waticons,global,
     wrapper,common,m_api,dbsettings,mirutils;

const
  MenuInfoPos = 500050002;
  PluginName  = 'Winamp Track';
const
  IcoBtnInfo:PAnsiChar='WATrack_Info';
const
  HKN_POPUP:PAnsiChar = 'WAT_Popup';

{$include pop_rc.inc}
{$include pop_vars.inc}
{$include pop_opt.inc}

const
  MainTmpl = 'artist: %s'#13#10'title: "%s"'#13#10'album: "%s"'#13#10+
    'genre: %s'#13#10'comment: %s'#13#10'year: %s'#13#10'track: %u'#13#10+
    'bitrate: %ukbps %s'#13#10'samplerate: %uKHz'#13#10+
    'channels: %u'#13#10'length: %s'#13#10'player: "%s" v.%s';
  AddTmpl = #13#10'file: "%s"'#13#10'size: %u bytes';

procedure ShowMusicInfo(si:pSongInfo);
var
  Tmpl:array [0..255] of WideChar;
  buf:pWideChar;
  lvars:array [0..15] of integer;
  s:array [0..31] of WideChar;
  p:PWideChar;
begin
  mGetMem(buf,16384);
  with si^ do
  begin
    lvars[0]:=dword(artist);
    lvars[1]:=dword(title);
    lvars[2]:=dword(album);
    lvars[3]:=dword(genre);
    lvars[4]:=dword(comment);
    lvars[5]:=dword(year);
    lvars[6]:=track;
    lvars[7]:=kbps;
    if vbr>0 then
      p:='VBR'
    else
      p:='CBR';
    lvars[8]:=dword(p);
    lvars[9]:=khz;
    lvars[10]:=channels;
    lvars[11]:=dword(IntToTime(s,total));
    lvars[12]:=dword(player);
    lvars[13]:=dword(txtver);
  end;
  StrCopyW(Tmpl,MainTmpl);
  if PopUpFile=BST_CHECKED then
  begin
    lvars[14]:=dword(si^.mfile);
    lvars[15]:=si^.fsize;
    StrCatW(Tmpl,AddTmpl);
  end;

  wvsprintfw(buf,TranslateW(Tmpl),@lvars);
  MessageBoxW(0,buf,PluginName,MB_OK);
  mFreeMem(buf);
end;

function DumbPopupDlgProc(Wnd:hwnd;msg:uint;wParam:integer;lParam:longint):integer;stdcall;
var
  si:pSongInfo;
  h:HBITMAP;
begin
  case msg of
    WM_COMMAND,WM_CONTEXTMENU: begin
      if msg=WM_CONTEXTMENU then
        wParam:=Hi(PopUpAction)
      else
        wParam:=Lo(PopUpAction);
      si:=pointer(CallService(MS_WAT_RETURNGLOBAL,0,0));
      case wParam of
        1: ShowMusicInfo(si);
        2: ShowWindow(si^.plwnd,SW_RESTORE);
        3: PluginLink^.CallServiceSync(MS_WAT_PRESSBUTTON,WAT_CTRL_NEXT,0);
      end;
      SendMessage(Wnd,UM_DESTROYPOPUP,0,0);
      result:=1;
    end;
    UM_POPUPACTION: begin
//      if wParam<>0 then
        result:=PluginLink^.CallServiceSync(MS_WAT_PRESSBUTTON,lParam,0);
    end;
    UM_FREEPLUGINDATA: begin
      h:=CallService(MS_POPUP_GETPLUGINDATA,wnd,h);
      if h<>0 then
        DeleteObject(h);
      result:=0;
    end;
  else
    result:=DefWindowProc(Wnd,msg,wParam,lParam);
  end;
end;

function MakeActions:PPOPUPACTION;
type
  anacts = array [0..6] of TPOPUPACTION;
var
  p:^anacts;
  i:integer;
begin
  mGetMem(p,SizeOf(p^));
  result:=PPOPUPACTION(p);
  FillChar(p^,SizeOf(p^),0);
  for i:=0 to 6 do
  begin
    with p^[i] do
    begin
      cbSize:=SizeOf(TPOPUPACTION);
      lchIcon:=PluginLink^.CallService(MS_SKIN2_GETICON,0,
        dword(CtrlIcoNames[CtrlRemap[i+1]]));
      StrCopy(lpzTitle,'Watrack/');
      StrCat (lpzTitle,CtrlDescr[CtrlRemap[i+1]]);
      flags:=PAF_ENABLED;
      wParam:=1;
      lParam:=CtrlButtons[i];
    end;
  end;
end;

function ThShowPopup(si:pSongInfo):dword; //stdcall;
var
  ppdu:PPOPUPDATAW;
  title,descr:pWideChar;
  flag:dword;
  ppd2:PPOPUPDATA2;
  icon:HICON;
  sec:integer;
  cb,ct:TCOLORREF;
  line:boolean;
  tmp:pAnsiChar;
begin
  result:=0;
  line:=CallService(MS_POPUP_ISSECONDLINESHOWN,0,0)<>0;

  descr:=PWideChar(PluginLink^.CallService(MS_WAT_REPLACETEXT,0,dword(PopText)));
  if line then
    title:=PWideChar(PluginLink^.CallService(MS_WAT_REPLACETEXT,0,dword(PopTitle)))
  else
    title:=nil;

  if (descr<>nil) or (title<>nil) then
  begin
    if si^.Icon<>0 then
      Icon:=si^.Icon
    else
      Icon:=LoadSkinnedIcon(SKINICON_OTHER_MIRANDA);
    if PopUpDelay<0 then
      sec:=-1
    else if PopUpDelay>0 then
      sec:=PopUpPause
    else
      sec:=0;
    case PopUpColor of
      0: begin
        cb:=0;
        ct:=0;
      end;
      1: begin
        cb:=GetSysColor(COLOR_BTNFACE);
        ct:=GetSysColor(COLOR_BTNTEXT);
      end;
      2: begin
        cb:=PopUpBack;
        ct:=PopUpFore;
      end;
    end;

    if IsPopup2Present then
    begin
      mGetMem (ppd2 ,SizeOf(TPOPUPDATA2));
      FillChar(ppd2^,SizeOf(TPOPUPDATA2),0);
      with ppd2^ do
      begin
        cbSize          :=SizeOf(TPOPUPDATA2);
        flags           :=PU2_UNICODE;
        lchIcon         :=Icon;
        colorBack       :=cb;
        colorText       :=ct;
        PluginWindowProc:=@DumbPopupDlgProc;

        if line then
        begin
          pzTitle.w:=title;
          pzText .w:=descr;
        end
        else
          pzTitle.w:=descr;

        if ActionList=nil then
          flag:=0
        else
        begin
          flag       :=APF_NEWDATA;
          actionCount:=7;
          lpActions  :=ActionList;
        end;

        if si.cover<>nil then
        begin
          if isFreeImagePresent then
            hbmAvatar:=CallService(MS_IMG_LOAD,dword(si.cover),IMGL_WCHAR)
          else
            hbmAvatar:=0;
          if hbmAvatar=0 then
          begin
            WideToAnsi(si.cover,tmp);
            hbmAvatar:=CallService(MS_UTILS_LOADBITMAP,0,dword(tmp));
            mFreeMem(tmp);
          end;
        end;
        PluginData:=pointer(hbmAvatar);
      end;
      PluginLink^.CallService(MS_POPUP_ADDPOPUP2,DWORD(ppd2),flag);
      mFreeMem(ppd2);
    end
    else
    begin
      mGetMem (ppdu ,SizeOf(TPOPUPDATAW));
      FillChar(ppdu^,SizeOf(TPOPUPDATAW),0);
      with ppdu^ do
      begin
        if line then
        begin
          if title<>nil then
            StrCopyW(lpwzContactName,title,MAX_CONTACTNAME-1)
          else
            lpwzContactName[0]:=' ';
          if descr<>nil then
            StrCopyW(lpwzText,descr,MAX_SECONDLINE-1)
          else
            lpwzText[0]:=' ';
        end
        else
        begin
          StrCopyW(ppdu^.lpwzContactName,title,MAX_CONTACTNAME-1);
          lpwzText[0]:=' ';
        end;
        
        lchIcon         :=Icon;
        PluginWindowProc:=@DumbPopupDlgProc;
        iSeconds        :=sec;
        colorBack       :=cb;
        colorText       :=ct;

    //    if PluginLink^.ServiceExists(MS_POPUP_REGISTERACTIONS)=0 then
        if ActionList=nil then
          flag:=0
        else
        begin
          flag       :=APF_NEWDATA;
          icbSize    :=SizeOf(TPOPUPDATAW);
          actionCount:=7;
          lpActions  :=ActionList;
        end;
      end;
      PluginLink^.CallService(MS_POPUP_ADDPOPUPW,DWORD(ppdu),flag);
      mFreeMem(ppdu);
    end;
    mFreeMem(title);
    mFreeMem(descr);
  end;
end;

procedure ShowPopup(si:pSongInfo);
var
  res:dword;
begin
  CloseHandle(BeginThread(nil,0,@ThShowPopup,si,0,res));
end;

// --------------- Services and Hooks ----------------

function OpenPopUp(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  si:pSongInfo;
begin
  result:=0;
  if DisablePlugin<>dsEnabled then
    exit;
  if PluginLink^.CallService(MS_WAT_GETMUSICINFO,0,dword(@si))=WAT_PLS_NORMAL then
  begin
    if PopupPresent then
      ShowPopUp(si)
    else
      ShowMusicInfo(si);
  end;
end;

procedure regpophotkey;
var
  hkrec:HOTKEYDESC;
begin
  if DisablePlugin=dsPermanent then
    exit;
  with hkrec do
  begin
    cbSize          :=HOTKEYDESC_SIZE_V1;
    pszName         :=HKN_POPUP;
    pszDescription.a:='WATrack popup hotkey';
    pszSection.a    :=PluginName;
    pszService      :=MS_WAT_SHOWMUSICINFO;
    lParam          :=0;
    DefHotKey:=((HOTKEYF_ALT or HOTKEYF_CONTROL) shl 8) or VK_F7 or HKF_MIRANDA_LOCAL;
  end;
  CallService(MS_HOTKEY_REGISTER,0,dword(@hkrec));
end;

{$include pop_dlg.inc}

function NewPlStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
  flag:integer;
begin
  result:=0;
  case wParam of
    WAT_EVENT_NEWTRACK: begin
      if PopupPresent and (PopRequest=BST_UNCHECKED) then
        ShowPopUp(pSongInfo(lParam));
    end;
    WAT_EVENT_PLUGINSTATUS: begin
      DisablePlugin:=lParam;
      case lParam of
        dsEnabled: begin
          flag:=0;
        end;
        dsPermanent: begin
          flag:=CMIF_GRAYED;
        end;
      else // like 1
        exit
      end;
      FillChar(mi,sizeof(mi),0);
      mi.cbSize:=sizeof(mi);
      mi.flags :=CMIM_FLAGS+flag;
      CallService(MS_CLIST_MODIFYMENUITEM,hMenuInfo,dword(@mi));
    end;
  end;
end;

function IconChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  mi:TCListMenuItem;
begin
  result:=0;
  FillChar(mi,SizeOf(mi),0);
  mi.cbSize:=sizeof(mi);
  mi.flags :=CMIM_ICON;
  mi.hIcon :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnInfo));
  CallService(MS_CLIST_MODIFYMENUITEM,hMenuInfo,dword(@mi));
  if ActionList<>nil then
  begin
    mFreeMem(ActionList);
    ActionList:=MakeActions;
    CallService(MS_POPUP_REGISTERACTIONS,dword(ActionList),7);
  end;
end;

function OnOptInitialise(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  odp:TOPTIONSDIALOGPAGE;
begin
  FillChar(odp,SizeOf(odp),0);
  odp.cbSize     :=OPTIONPAGE_OLD_SIZE2; //for 0.5 compatibility
  odp.flags      :=ODPF_BOLDGROUPS;
  odp.Position   :=900003000;
  odp.hInstance  :=hInstance;
  odp.szTitle.a  :=PluginName;

  odp.szGroup.a  :='PopUps';
  odp.pszTemplate:=DLGPOPUP;
  odp.pfnDlgProc :=@DlgPopUpOpt;
  PluginLink^.CallService(MS_OPT_ADDPAGE,wParam,dword(@odp));
  result:=0;
end;

// ------------ base interface functions -------------

function InitProc(aGetStatus:boolean=false):integer;
var
  mi:TCListMenuItem;
  ttb:TTBButtonV2;
  sid:TSKINICONDESC;
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

  ssmi:=PluginLink^.CreateServiceFunction(MS_WAT_SHOWMUSICINFO,@OpenPopup);

  FillChar(sid,SizeOf(TSKINICONDESC),0);
  sid.cbSize:=SizeOf(TSKINICONDESC);
  sid.cx:=16;
  sid.cy:=16;
  sid.szSection.a:='WATrack';
  sid.hDefaultIcon   :=LoadImage(hInstance,MAKEINTRESOURCE(BTN_INFO),IMAGE_ICON,16,16,0);
  sid.pszName        :=IcoBtnInfo;
  sid.szDescription.a:='Music Info';
  PluginLink^.CallService(MS_SKIN2_ADDICON,0,dword(@sid));
  DestroyIcon(sid.hDefaultIcon);
  sic:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);

  FillChar(mi,SizeOf(mi),0);
  mi.cbSize       :=SizeOf(mi);
  mi.szPopupName.a:=PluginShort;
  mi.hIcon        :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnInfo));
  mi.szName.a     :='Music Info';
  mi.pszService   :=MS_WAT_SHOWMUSICINFO;
  mi.popupPosition:=MenuInfoPos;
  hMenuInfo       :=PluginLink^.CallService(MS_CLIST_ADDMAINMENUITEM,0,dword(@mi));

  if PluginLink^.ServiceExists(MS_POPUP_ADDPOPUPW)<>0 then
  begin
    IsFreeImagePresent:=PluginLink^.ServiceExists(MS_IMG_LOAD       )<>0;
    IsPopup2Present   :=PluginLink^.ServiceExists(MS_POPUP_ADDPOPUP2)<>0;
    PopupPresent:=true;
    RegisterButtonIcons;
    opthook:=PluginLink^.HookEvent(ME_OPT_INITIALISE,@OnOptInitialise);
    loadpopup;
    regpophotkey;

    if PluginLink^.ServiceExists(MS_POPUP_REGISTERACTIONS)<>0 then
    begin
      ActionList:=MakeActions;
      CallService(MS_POPUP_REGISTERACTIONS,dword(ActionList),7);
    end
    else
      ActionList:=nil;
  end
  else
  begin
    PopupPresent:=false;
  end;

  plStatusHook:=PluginLink^.HookEvent(ME_WAT_NEWSTATUS,@NewPlStatus);

  // get info button
  FillChar(ttb,SizeOf(ttb),0);
  ttb.cbSize :=SizeOf(ttb);
  ttb.dwFlags:=TTBBF_VISIBLE{ or TTBBF_SHOWTOOLTIP};
  ttb.hIconUp       :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(IcoBtnInfo));
  ttb.hIconDn       :=ttb.hIconUp;
  ttb.pszServiceUp  :=MS_WAT_SHOWMUSICINFO;
  ttb.pszServiceDown:=MS_WAT_SHOWMUSICINFO;
  ttb.name          :='Music Info';
  ttbInfo:=CallService(MS_TTB_ADDBUTTON,integer(@ttb),0);
end;

procedure DeInitProc(aSetDisable:boolean);
begin
  if aSetDisable then
    SetModStatus(0);

  PluginLink^.UnhookEvent(plStatusHook);
  PluginLink^.DestroyServiceFunction(ssmi);
  PluginLink^.UnhookEvent(sic);
  mFreeMem(PopTitle);
  mFreeMem(PopText);
  if PopupPresent then
  begin
    PluginLink^.UnhookEvent(opthook);
    mFreeMem(ActionList);
  end;
end;

var
  Popup:twModule;

procedure Init;
begin
  Popup.Next      :=ModuleLink;
  Popup.Init      :=@InitProc;
  Popup.DeInit    :=@DeInitProc;
  Popup.AddOption :=nil;
  Popup.ModuleName:='PopUps';
  ModuleLink      :=@Popup;
end;

begin
  Init;
end.
