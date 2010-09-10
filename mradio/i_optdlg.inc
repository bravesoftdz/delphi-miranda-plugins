{Options dialog}
const
  OldEQPreset:integer=-1;
const
  optOldPreset:pAnsiChar='oldpreset';
  optPresets  :pAnsiChar='numpreset';
  optPreset   :PAnsiChar='preset_';
  optPreDescr :PAnsiChar='predescr_';

const
  PresetMax = 17;

procedure InitPresets;
type
  tP = array [0..9] of AnsiChar;
begin
  StrDupW(Presets[00].name,'Acoustic' ); tP(Presets[00].preset):=#$01#$02#$00#$00#$00#$00#$00#$01#$01#$03;
  StrDupW(Presets[01].name,'Blues'    ); tP(Presets[01].preset):=#$01#$02#$01#$00#$00#$00#$00#$00#$00#$FE;
  StrDupW(Presets[02].name,'Classical'); tP(Presets[02].preset):=#$01#$04#$01#$00#$00#$00#$00#$00#$01#$01;
  StrDupW(Presets[03].name,'Country'  ); tP(Presets[03].preset):=#$00#$00#$01#$01#$00#$00#$01#$01#$01#$01;
  StrDupW(Presets[04].name,'Dance'    ); tP(Presets[04].preset):=#$04#$03#$02#$01#$FF#$FF#$02#$04#$05#$05;
  StrDupW(Presets[05].name,'Folk'     ); tP(Presets[05].preset):=#$FF#$00#$00#$01#$01#$00#$01#$01#$01#$00;
  StrDupW(Presets[06].name,'Grunge'   ); tP(Presets[06].preset):=#$01#$00#$FF#$00#$00#$02#$01#$FF#$FE#$FD;
  StrDupW(Presets[07].name,'Jazz'     ); tP(Presets[07].preset):=#$00#$01#$02#$03#$03#$01#$01#$03#$04#$05;
  StrDupW(Presets[08].name,'Metall'   ); tP(Presets[08].preset):=#$FE#$00#$00#$00#$00#$03#$02#$04#$06#$05;
  StrDupW(Presets[09].name,'New Age'  ); tP(Presets[09].preset):=#$03#$03#$00#$00#$00#$00#$00#$00#$02#$02;
  StrDupW(Presets[10].name,'Opera'    ); tP(Presets[10].preset):=#$00#$01#$02#$04#$01#$02#$00#$00#$00#$00;
  StrDupW(Presets[11].name,'Rap'      ); tP(Presets[11].preset):=#$00#$04#$04#$00#$00#$00#$01#$04#$05#$07;
  StrDupW(Presets[12].name,'Reggae'   ); tP(Presets[12].preset):=#$03#$00#$FD#$00#$05#$00#$02#$03#$04#$05;
  StrDupW(Presets[13].name,'Rock'     ); tP(Presets[13].preset):=#$00#$02#$04#$00#$00#$00#$02#$04#$05#$06;
  StrDupW(Presets[14].name,'Speech'   ); tP(Presets[14].preset):=#$FE#$02#$00#$00#$00#$00#$FF#$FE#$FD#$FC;
  StrDupW(Presets[15].name,'Swing'    ); tP(Presets[15].preset):=#$FF#$00#$00#$02#$02#$00#$02#$02#$03#$03;
  StrDupW(Presets[16].name,'Techno'   ); tP(Presets[16].preset):=#$05#$08#$FF#$FE#$FD#$FF#$04#$06#$06#$06;
end;

procedure LoadPresets;
var
  num,preset,descr:array [0..63] of AnsiChar;
  i:integer;
  p,pd:pAnsiChar;
begin
  p :=StrCopyE(preset,optPreset);
  pd:=StrCopyE(descr ,optPreDescr);

  i:=DBReadByte(0,PluginName,optPresets);
  if i=0 then
  begin
    SetLength(Presets,PresetMax);
    InitPresets;
  end
  else
  begin
    OldEQPreset:=integer(DBReadByte(0,PluginName,optOldPreset,byte(-1)));
    SetLength(Presets,i);
    for i:=0 to HIGH(Presets) do
    begin
      StrCopy(p ,IntToStr(num,i));      DBReadStruct (0,PluginName,preset,@Presets[i].preset,10);
      StrCopy(pd,num); Presets[i].name:=DBReadUnicode(0,PluginName,descr);
    end;
  end;
end;

procedure SavePresets;
var
  num,preset,descr:array [0..63] of AnsiChar;
  i,j:integer;
  p,pd:pAnsiChar;
begin
  p :=StrCopyE(preset,optPreset);
  pd:=StrCopyE(descr ,optPreDescr);
  j:=DBReadByte(0,PluginName,optPresets);
  for i:=0 to HIGH(Presets) do
  begin
    StrCopy(p ,IntToStr(num,i)); DBWriteStruct (0,PluginName,preset,@Presets[i].preset,10);
    StrCopy(pd,num);             DBWriteUnicode(0,PluginName,descr ,Presets[i].name);
  end;
  while j>Length(Presets) do
  begin
    dec(j);
    StrCopy(p ,IntToStr(num,j)); DBDeleteSetting(0,PluginName,preset);
    StrCopy(pd,num);             DBDeleteSetting(0,PluginName,descr);
  end;
  DBWriteByte(0,PluginName,optOldPreset,OldEQPreset);
  DBWriteByte(0,PluginName,optPresets  ,Length(Presets));
end;

procedure FreePresets;
var
  i:integer;
begin
  for i:=0 to HIGH(Presets) do
    mFreeMem(Presets[i].name);
end;

function ImportOneStation(group,ini,section:PAnsiChar):int;
var
  grbuf,buf:array [0..511] of AnsiChar;
  status:integer;
  p:pWideChar;
begin
  result:=0;
  GetPrivateProfileStringA(section,'URL','',buf,SizeOf(buf),ini);
  if buf[0]<>#0 then
  begin
    result:=CallService(MS_DB_CONTACT_ADD,0,0);
    if result<>0 then
    begin
      CallService(MS_PROTO_ADDTOCONTACT,result,dword(PluginName));
      DBWriteString(result,PluginName,optStationURL,buf);
      DBWriteString(result,PluginName,optFirstName ,buf);
      GetPrivateProfileStringA(section,'Bitrate','0',buf,SizeOf(buf),ini);
      DBWriteString(result,PluginName,optBitrate,buf);
      DBWriteWord  (result,PluginName,optAge    ,StrToInt(buf));
      GetPrivateProfileStringA(section,'Name',section,buf,SizeOf(buf),ini);
      DBWriteString(result,strCList  ,optMyHandle,buf);
      DBWriteString(result,PluginName,optNick    ,buf);
      GetPrivateProfileStringA(section,'Genre','unknown',buf,SizeOf(buf),ini);
      DBWriteString(result,PluginName,optGenre   ,buf);
      DBWriteString(result,PluginName,optLastName,buf);
      if (PluginStatus=ID_STATUS_OFFLINE){ or (asOffline<>BST_UNCHECKED)} then
        status:=ID_STATUS_OFFLINE
      else
       status:=ID_STATUS_INVISIBLE;
      SetStatus(result,status);

      if group=nil then
      begin
        GetPrivateProfileStringA(section,'Group','',grbuf,SizeOf(grbuf),ini);
        group:=@grbuf;
      end;
      AnsiToWide(group,p,MirandaCP);
      CreateGroupW(p,result);
      mFreeMem(p);
    end;
  end;
end;

function ImportAll(wParam:WPARAM;lParam:LPARAM):int; cdecl;
var
  dst:array [0..MAX_PATH-1] of AnsiChar;
  pc,buf:pAnsiChar;
begin
  result:=0;
  if lParam<>0 then
    StrCopy(dst,PAnsiChar(lParam));
  if (lParam<>0) or ShowDlg(dst,'radio.ini',nil,true) then
  begin
    mGetMem(buf,32768);
    GetPrivateProfileSectionNamesA(buf,32768,dst);
    pc:=buf;
    while pc^<>#0 do
    begin
      if ImportOneStation(pAnsiChar(wParam),dst,pc)<>0 then inc(result);
      while pc^<>#0 do inc(pc);
      inc(pc);
    end;
    mFreeMem(buf);
  end;
end;

procedure ExportRadioContact(num:integer;fname:PAnsiChar;hContact:THANDLE);
var
  pc:pAnsiChar;
  section:array [0..15] of AnsiChar;
begin
  IntToStr(section,num);
  pc:=DBReadString(hContact,strCList,optMyHandle);
  WritePrivateProfileStringA(section,'Name',pc,fname);
  mFreeMem(pc);
          
  pc:=DBReadString(hContact,PluginName,optStationURL);
  WritePrivateProfileStringA(section,'URL',pc,fname);
  mFreeMem(pc);

  pc:=DBReadString(hContact,PluginName,optGenre);
  if pc<>nil then
  begin
    WritePrivateProfileStringA(section,'Genre',pc,fname);
    mFreeMem(pc);
  end;

  pc:=DBReadString(hContact,PluginName,optBitrate);
  if pc<>nil then
  begin
    WritePrivateProfileStringA(section,'Bitrate',pc,fname);
    mFreeMem(pc);
  end;

  pc:=DBReadString(hContact,strCList,optGroup);
  if pc<>nil then
  begin
    WritePrivateProfileStringA(section,'Group',pc,fname);
    mFreeMem(pc);
  end;
end;

function ExportAll(wParam:WPARAM;lParam:LPARAM):int; cdecl;
var
  dst:array [0..MAX_PATH-1] of AnsiChar;
  hContact:THANDLE;
begin
  result:=0;
  if lParam<>0 then
    StrCopy(dst,PAnsiChar(lParam));
  if (lParam<>0) or ShowDlg(dst,'radio.ini',nil,false) then
  begin
    if (wParam<>0) and (CallService(MS_DB_CONTACT_IS,wParam,0)<>0) then
    begin
      result:=1;
      ExportRadioContact(result,dst,wParam)
    end
    else
    begin
      hContact:=CallService(MS_DB_CONTACT_FINDFIRST,0,0);
      while hContact<>0 do
      begin
        if StrCmp(PAnsiChar(PluginLink^.CallService(MS_PROTO_GETCONTACTBASEPROTO,hContact,0)),
               PluginName)=0 then
        begin
          inc(result);
          ExportRadioContact(result,dst,hContact);
        end;
        hContact:=CallService(MS_DB_CONTACT_FINDNEXT,hContact,0);
      end;
    end;
  end;
end;

function MakeFilter(dst,descr,full,filter:PWideChar;show:bool=true):pWideChar;
var
  p:PWideChar;
begin
  if full<>nil then
  begin
    p:=StrEndW(full);
    p^:=';';
    StrCopyW(p+1,filter);
  end;

  dst:=StrCopyEW(dst,TranslateW(descr));
  if show then
  begin
    dst^    :=' ';
    (dst+1)^:='(';
    dst:=StrCopyEW(dst+2,filter);
    dst^:=')';
    inc(dst);
    dst^:=#0;
  end;
  inc(dst);
  result:=StrCopyEW(dst,filter)+1;
end;

function ConstructFilter:pointer;
var
  pc:pWideChar;
  ph:PDWord;
  Info:PBASS_PLUGININFO;
  i:integer;
  full:array [0..511] of WideChar;
  tmpbuf1,tmpbuf2:array [0..127] of WideChar;
begin
  mGetMem(pc,4096);
//  FillChar(pc^,4096,0);
  result:=pc;
  full[0]:=#0;
  pc:=MakeFilter(pc,'All files'     ,nil ,'*.*',false);
  pc:=MakeFilter(pc,'Playlist files',full,'*.pls;*.m3u;*.m3u8;*.asx');
  pc:=MakeFilter(pc,'BASS built-in' ,full,'*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif');

  ph:=pointer(BASS_PluginGetInfo(0));
  if ph<>nil then
  begin
    while ph^<>0 do
    begin
      Info:=BASS_PluginGetInfo(ph^);
      for i:=0 to Info^.formatc-1 do
//!! need to translate ansi -> wide
        with Info^.Formats[i] do
        begin
          pc:=MakeFilter(pc,FastAnsiToWideBuf(name,tmpbuf1),full,FastAnsiToWideBuf(exts,tmpbuf2));
        end;
      inc(ph);
    end;
  end;
  pc:=MakeFilter(pc,'All supported formats',nil,full,false);
  pc^:=#0;
end;

procedure SetButtonIcons(Dialog:HWND);
var
  ti:TTOOLINFOW;
  hwndTooltip:HWND;
begin
  hwndTooltip:=CreateWindowW(TOOLTIPS_CLASS,nil,TTS_ALWAYSTIP,
      integer(CW_USEDEFAULT),integer(CW_USEDEFAULT),
      integer(CW_USEDEFAULT),integer(CW_USEDEFAULT),
      Dialog,0,hInstance,nil);

  FillChar(ti,SizeOf(ti),0);
  ti.cbSize  :=sizeof(TOOLINFO);
  ti.uFlags  :=TTF_IDISHWND or TTF_SUBCLASS;
  ti.hwnd    :=dialog;
  ti.hinst   :=hInstance;

  ti.uId     :=GetDlgItem(Dialog,IDC_EQ_ADD);
  ti.lpszText:=TranslateW('Add');

  SendMessage(ti.uId,BM_SETIMAGE,IMAGE_ICON,
      CallService(MS_SKIN2_GETICON,0,dword(IcoBtnAdd)));
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,integer(@ti));
  
  ti.uId     :=GetDlgItem(Dialog,IDC_EQ_DEL);
  ti.lpszText:=TranslateW('Delete');
  SendMessage(ti.uId,BM_SETIMAGE,IMAGE_ICON,
      CallService(MS_SKIN2_GETICON,0,dword(IcoBtnDel)));
  SendMessageW(hwndTooltip,TTM_ADDTOOLW,0,integer(@ti));
end;

function DlgProcOpt(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
const
  DlgInit:integer=1;
var
  buf:array [0..MAX_PATH-1] of WideChar;
  psr:TPROTOSEARCHRESULT;
  dst:pWideChar;
  i:dword;
//  info:BASS_CHANNELINFO;
  vhi:TVARHELPINFO;
  wnd:HWND;
begin
  result:=0;
  case hMessage of
    WM_DESTROY: begin
//!!      hRecButton:=0;
      DBWriteByte(0,PluginName,optLoop   ,doLoop);
      DBWriteByte(0,PluginName,optShuffle,doShuffle);
      DBWriteByte(0,PluginName,optContRec,doContRec);
      DBWriteByte(0,PluginName,optPlay1st,PlayFirst);
      DBWriteByte(0,PluginName,optOffline,asOffline);
      DBWriteByte(0,PluginName,optConnect,AuConnect);

      DBWriteUnicode(0,PluginName,optStatusTmpl,StatusTmpl);
    end;

    WM_INITDIALOG: begin
      DlgInit:=1;
      TranslateDialogDefault(Dialog);

      wnd:=GetDlgItem(Dialog,IDC_HLP_VARS);
      if isVarsInstalled then
      begin
        SendMessage(wnd,BM_SETIMAGE,IMAGE_ICON,
            CallService(MS_VARS_GETSKINITEM,0,VSI_HELPICON));
      end
      else
        ShowWindow(wnd,SW_HIDE);

//!!      hRecButton:=GetDlgItem(Dialog,IDC_BN_RECORD);
      if recpath<>nil then
        SetDlgItemTextW(Dialog,IDC_ED_RECPATH,recpath);

{!!
      if CallService(MS_RADIO_RECORD,1,0)<>0 then
        SendMessage(hRecButton,BM_SETCHECK,BST_CHECKED,0);
}
      CheckDlgButton(Dialog,IDC_LOOP     ,doLoop);
      CheckDlgButton(Dialog,IDC_SHUFFLE  ,doShuffle);
      CheckDlgButton(Dialog,IDC_CONTREC  ,doContRec);
      CheckDlgButton(Dialog,IDC_PLAYFIRST,PlayFirst);
      CheckDlgButton(Dialog,IDC_OFFLINE  ,asOffline);
      CheckDlgButton(Dialog,IDC_CONNECT  ,AuConnect);

      SetDlgItemTextW(Dialog,IDC_STATUS,StatusTmpl);
      
      DlgInit:=0;
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        EN_CHANGE: begin
          if DlgInit=0 then
            case loword(wparam) of
              IDC_STATION,IDC_STATIONURL,IDC_GENRE,IDC_BITRATE: ;
            else
              SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
            end;
        end;

        BN_CLICKED: begin
          case loword(wParam) of

            IDC_EXPORT: begin
              ExportAll(0,0);
            end;

            IDC_HLP_VARS: begin
              FillChar(vhi,SizeOf(vhi),0);
              with vhi do
              begin
                cbSize       :=SizeOf(vhi);
                flags        :=VHF_FULLDLG or VHF_SETLASTSUBJECT;
                hwndCtrl     :=GetDlgItem(Dialog,IDC_STATUS);
                szSubjectDesc:='test your variables';
              end;
              PluginLink^.CallService(MS_VARS_SHOWHELPEX,Dialog,dword(@vhi));
            end;

            IDC_BN_URLPATH: begin
   
              dst:=ConstructFilter;
              if ShowDlgW(@buf,nil,dst) then
                SetDlgItemTextW(Dialog,IDC_STATIONURL,@buf);
              mFreeMem(dst);
            end;

            IDC_BN_RECPATH: begin
              dst:=nil;
              if SelectDirectory(nil,dst,Dialog,true) then
              begin
                PluginLink^.CallService(MS_UTILS_PATHTORELATIVEW,dword(dst),dword(@buf));
                SetDlgItemTextW(Dialog,IDC_ED_RECPATH,pWideChar(@buf));
                mFreeMem(dst);
              end;
            end;

{!!
            IDC_BN_RECORD: begin
              if IsDlgButtonChecked(Dialog,IDC_BN_RECORD)<>BST_UNCHECKED then
                i:=1
              else
                i:=2;
              CallService(MS_RADIO_COMMAND,MRC_RECORD,i);
            end;
}
            IDC_LOOP,IDC_SHUFFLE,IDC_CONTREC,IDC_OFFLINE,IDC_CONNECT:
              SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);

            IDC_ADD_LIST,IDC_ADD_INI: begin
              if GetWindowTextLength(GetDlgItem(Dialog,IDC_STATIONURL))>0 then
              begin
                FillChar(psr,SizeOf(psr),0);
                GetDlgItemTextA(Dialog,IDC_STATIONURL,PAnsiChar(@buf),SizeOf(buf));
                with psr do
                begin
                  StrDup(firstname.a,PAnsiChar(@buf));
                  PAnsiChar(@buf)^:=#0;

                  GetDlgItemTextA(Dialog,IDC_STATION,PAnsiChar(@buf),SizeOf(buf));
                  if PAnsiChar(@buf)^<>#0 then
                    StrDup(nick.a,@buf)
                  else
                    StrDup(nick.a,firstname.a);
                  PAnsiChar(@buf)^:=#0;

                  GetDlgItemTextA(Dialog,IDC_GENRE,PAnsiChar(@buf),SizeOf(buf));
                  StrDup(lastname.a,@buf);
                  PAnsiChar(@buf)^:=#0;

                  GetDlgItemTextA(Dialog,IDC_BITRATE,PAnsiChar(@buf),SizeOf(buf));
                  StrDup(email.a,@buf);

                  if loword(wParam)=IDC_ADD_LIST then
                  begin
                    i:=Service_AddToList(0,dword(@psr));

                    GetDlgItemTextW(Dialog,IDC_STATION,@buf,SizeOf(buf));
                    DBWriteUnicode(i,strCList,optMyHandle,@buf);

                    GetDlgItemTextW(Dialog,IDC_STATIONURL,@buf,SizeOf(buf));
                    DBWriteUnicode(i,PluginName,optStationURL,@buf);

                    // "changing" station group
                    dst:=GetNewGroupName(Dialog);
                    if dst<>nil then
                      DBWriteUnicode(i,strCList,'Group',dst)
                    else
                      DBDeleteSetting(i,strCList,'Group');
                      
                  end
                  else if loword(wParam)=IDC_ADD_INI then
                  begin
                    if WritePrivateProfileStringA(firstname.a,'URL'    ,firstname.a,storage) then
                    begin
                      WritePrivateProfileStringA(firstname.a,'Name'   ,nick.a     ,storage);
                      WritePrivateProfileStringA(firstname.a,'Genre'  ,lastname.a ,storage);
                      WritePrivateProfileStringA(firstname.a,'Bitrate',email.a    ,storage);
                    end
                    else
                    begin
                      WritePrivateProfileStringA(firstname.a,'URL'    ,firstname.a,storagep);
                      WritePrivateProfileStringA(firstname.a,'Name'   ,nick.a     ,storagep);
                      WritePrivateProfileStringA(firstname.a,'Genre'  ,lastname.a ,storagep);
                      WritePrivateProfileStringA(firstname.a,'Bitrate',email.a    ,storagep);
                    end;

                  end;
                  mFreeMem(nick);
                  mFreeMem(firstname);
                  mFreeMem(lastname);
                  mFreeMem(email);
                end;
              end;
            end;

          end;
        end;

      end;
    end;

    WM_NOTIFY: begin
      if PNMHdr(lParam)^.code=PSN_APPLY then
      begin

        doShuffle:=IsDlgButtonChecked(Dialog,IDC_SHUFFLE);
        doContRec:=IsDlgButtonChecked(Dialog,IDC_CONTREC);
        PlayFirst:=IsDlgButtonChecked(Dialog,IDC_PLAYFIRST);
        AuConnect:=IsDlgButtonChecked(Dialog,IDC_CONNECT);

        mFreeMem(StatusTmpl);
        StatusTmpl:=GetDlgText(Dialog,IDC_STATUS);

        i:=IsDlgButtonChecked(Dialog,IDC_OFFLINE);
        if i<>asOffline then
        begin
          asOffline:=i;
          SetStatus(0,ID_STATUS_INVISIBLE);
          if ActiveContact<>0 then
            SetStatus(ActiveContact,ID_STATUS_ONLINE);
        end;

        doLoop:=IsDlgButtonChecked(Dialog,IDC_LOOP);
        if chan<>0 then
        begin
{
          BASS_ChannelGetInfo(chan,info);
          if doLoop<>BST_UNCHECKED then
            info.flags:=info.flags or BASS_SAMPLE_LOOP
          else
            info.flags:=info.flags and not BASS_SAMPLE_LOOP;
}
          BASS_ChannelFlags(chan,ord(doLoop<>BST_UNCHECKED),BASS_SAMPLE_LOOP);
        end;

        mFreeMem(recpath);
        mGetMem(recpath,MAX_PATH*SizeOf(WideChar));
        GetDlgItemTextW(Dialog,IDC_ED_RECPATH,@buf,SizeOf(buf) div SizeOf(WideChar));
        PluginLink^.CallService(MS_UTILS_PATHTORELATIVEW,dword(@buf),dword(recpath));
        DBWriteUnicode(0,PluginName,optRecPath,recpath);
      end;
    end;

//  else
//    result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;

function DlgProcOptTech(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
const
  DlgInit:integer=1;
var
  i:integer;
  hEAXCombo:THANDLE;
  ltmp:longbool;
//  info:BASS_CHANNELINFO;
  buf1:array [0..4] of AnsiChar;
  wnd:HWND;
  buf:array [0..MAX_PATH-1] of WideChar;
  dst:pWideChar;
begin
  result:=0;
  case hMessage of
    WM_DESTROY: begin
      hVolCtrl:=0;

      buf1[0]:='E';
      buf1[1]:='Q';
      buf1[2]:='_';
      buf1[4]:=#0;
      for i:=0 to 9 do
      begin
        buf1[3]:=AnsiChar(ORD('0')+i);
        DBWriteByte(0,PluginName,buf1,trunc(eq[i].param.fGain)+15);
        eq[i].wnd:=0;
      end;
      DBWriteByte(0,PluginName,optEQ_OFF ,isEQ_OFF);
    end;

    WM_INITDIALOG: begin
      DlgInit:=1;
      TranslateDialogDefault(Dialog);

      SetButtonIcons(Dialog);
      hVolCtrl:=GetDlgItem(Dialog,IDC_VOLUME);
      SendMessage(hVolCtrl,TBM_SETRANGE,0,(100 shl 16)+0);
      SendMessage(hVolCtrl,TBM_SETPOS,1,DBReadByte(0,PluginName,optVolume,50));

      SetDlgItemInt(Dialog,IDC_BUFFER ,sBuffer ,false);
      SetDlgItemInt(Dialog,IDC_PREBUF ,sPreBuf ,false);
      SetDlgItemInt(Dialog,IDC_TIMEOUT,sTimeout,false);

      hEAXCombo:=GetDlgItem(Dialog,IDC_EAXTYPE);
      for i:=0 to EAX_ENVIRONMENT_COUNT do
        SendMessageW(hEAXCombo,CB_ADDSTRING,0,dword(TranslateW(EAXItems[i].name)));
      SendMessage(hEAXCombo,CB_SETCURSEL,DBReadByte(0,PluginName,optEAXType,0),0);

      wnd:=GetDlgItem(Dialog,IDC_PRESET);
      for i:=0 to HIGH(Presets) do
        SendMessageW(wnd,CB_ADDSTRING,0,dword(Presets[i].name));
      SendMessage(wnd,CB_SETCURSEL,OldEQPreset,0);

      for i:=0 to 9 do
      begin
        eq[i].wnd:=GetDlgItem(Dialog,IDC_EQ00+i);
        SendMessage(eq[i].wnd,TBM_SETRANGE,1,(16 shl 16)-15);
        SendMessage(eq[i].wnd,TBM_SETTIC,0,0);
        SendMessage(eq[i].wnd,TBM_SETPOS,1,-trunc(eq[i].param.fGain));
        SendDlgItemMessage(Dialog,IDC_0+i,WM_SETTEXT,0,dword(eq[i].text));
        EnableWindow(eq[i].wnd,isEQ_OFF=BST_UNCHECKED);
      end;
      
      CheckDlgButton(Dialog,IDC_EQOFF,isEQ_OFF);

      dst:=DBReadUnicode(0,PluginName,optBASSpath,nil);
      SetDlgItemTextW(Dialog,IDC_BASSPATH,dst);
      mFreeMem(dst);

      DlgInit:=0;
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        EN_CHANGE: begin
          if DlgInit=0 then
            SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
        end;

        BN_CLICKED: begin
          case loword(wParam) of

            IDC_BASSPTHBTN: begin
              dst:=nil;
              if SelectDirectory(nil,dst,Dialog,true) then
              begin
                PluginLink^.CallService(MS_UTILS_PATHTORELATIVEW,dword(dst),dword(@buf));
                SetDlgItemTextW(Dialog,IDC_BASSPATH,pWideChar(@buf));
                mFreeMem(dst);
              end;
            end;

            IDC_EQOFF: begin
              isEQ_OFF:=IsDlgButtonChecked(Dialog,IDC_EQOFF);
              if isEQ_OFF=BST_UNCHECKED then
                EQ_ON
              else
                EQ_OFF;

              for i:=0 to 9 do
                EnableWindow(eq[i].wnd,isEQ_OFF=BST_UNCHECKED);
            end;

            IDC_ZERO: begin
              OldEQPreset:=-1;
              for i:=0 to 9 do
              begin
                eq[i].param.fGain:=0;
                SendMessage(eq[i].wnd,TBM_SETPOS,1,0);
                if (chan<>0) and (isEQ_OFF=BST_UNCHECKED) then
                  BASS_FXSetParameters(eq[i].fx,@eq[i].param);
              end;
            end;

            IDC_EQ_ADD: begin
              SetLength(Presets,Length(Presets)+1);

              for i:=0 to 9 do
                Presets[HIGH(Presets)].preset[i]:=-SendMessage(eq[i].wnd,TBM_GETPOS,0,0);

              wnd:=GetDlgItem(Dialog,IDC_PRESET);
              Presets[HIGH(Presets)].name:=GetDlgText(wnd,false);
              if Presets[HIGH(Presets)].name=nil then
                StrDupW(Presets[HIGH(Presets)].name,'New');
              OldEQPreset:=SendMessage(wnd,CB_SETCURSEL,
                SendMessageW(wnd,CB_ADDSTRING,0,dword(Presets[HIGH(Presets)].name)),0);
            end;

            IDC_EQ_DEL: begin
              wnd:=GetDlgItem(Dialog,IDC_PRESET);
              i:=SendMessage(wnd,CB_GETCURSEL,0,0);
              if (i>=0) and (i<=HIGH(Presets)) then
              begin
                SendMessage(wnd,CB_DELETESTRING,i,0);
                mFreeMem(Presets[i].name);
                move(Presets[i+1],Presets[i],(HIGH(Presets)-i)*SizeOf(tPreset));
                SetLength(Presets,Length(Presets)-1);
                OldEQPreset:=-1;
                SendMessage(wnd,CB_SETCURSEL,-1,0);
              end;
            end;

          end;
        end;

        CBN_SELCHANGE: begin
          SendMessage(GetParent(Dialog),PSM_CHANGED,0,0);
          case loword(wParam) of
            IDC_PRESET: begin
              OldEQPreset:=SendDlgItemMessage(Dialog,IDC_PRESET,CB_GETCURSEL,0,0);
              for i:=0 to 9 do
              begin
                SendMessage(eq[i].wnd,TBM_SETPOS,1,-Presets[OldEQPreset].preset[i]);
                eq[i].param.fGain:=Presets[OldEQPreset].preset[i];
                if (chan<>0) and (isEQ_OFF=BST_UNCHECKED) then
                  BASS_FXSetParameters(eq[i].fx,@eq[i].param);
              end;
            end;
            IDC_EAXTYPE: begin
{
              i:=SendDlgItemMessage(Dialog,IDC_EAXTYPE,CB_GETCURSEL,0,0);
              DBWriteByte(0,PluginName,optEAXType,i);
              if i=0 then
                BASS_SetEAXParameters(-1,0,-1,-1)
              else
                BASS_SetEAXPreset(EAXItems[i].code);
}
            end;
          end;
        end;
      end;
    end;

    WM_VSCROLL: begin
      for i:=0 to 9 do
      begin
        if lParam=eq[i].wnd then
        begin
          eq[i].param.fGain:=-SendMessage(lParam,TBM_GETPOS,0,0);
          if (chan<>0) and (isEQ_OFF=BST_UNCHECKED) then
            BASS_FXSetParameters(eq[i].fx,@eq[i].param);
          OldEQPreset:=-1;
          break;
        end;
      end;
    end;

    WM_HSCROLL: begin
       Service_RadioSetVolume(SendMessage(lParam,TBM_GETPOS,0,0),1)
    end;

    WM_NOTIFY: begin
      if PNMHdr(lParam)^.code=PSN_APPLY then
      begin
        SavePresets;

//!!  bass path saving here
        dst:=GetDlgText(Dialog,IDC_BASSPATH);
        DBWriteUnicode(0,PluginName,optBASSPath,dst);
        mFreeMem(dst);

        i:=SendDlgItemMessage(Dialog,IDC_EAXTYPE,CB_GETCURSEL,0,0);
        DBWriteByte(0,PluginName,optEAXType,i);
        if i=0 then
          BASS_SetEAXParameters(-1,0,-1,-1)
        else
          BASS_SetEAXPreset(EAXItems[i].code);

        i:=GetDlgItemInt(Dialog,IDC_PREBUF,ltmp,false);
        if i>100 then i:=100;
        if cardinal(i)<>sPreBuf then
        begin
          sPreBuf:=i;
          BASS_SetConfig(BASS_CONFIG_NET_PREBUF,i);
          DBWriteWord(0,PluginName,optPreBuf,sPreBuf);
        end;

        i:=GetDlgItemInt(Dialog,IDC_BUFFER,ltmp,false);
        if i>20000 then i:=20000;
        if cardinal(i)<>sBuffer then
        begin
          sBuffer:=i;
          BASS_SetConfig(BASS_CONFIG_NET_BUFFER,i);
          DBWriteWord(0,PluginName,optBuffer,sBuffer);
        end;

        i:=GetDlgItemInt(Dialog,IDC_TIMEOUT,ltmp,false);
        if i>30000 then i:=30000;
        if cardinal(i)<>sTimeout then
        begin
          sTimeout:=i;
          BASS_SetConfig(BASS_CONFIG_NET_TIMEOUT,i);
          DBWriteWord(0,PluginName,optTimeout,sTimeout);
        end;

      end;
    end;

//  else
//    result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;

function OnOptInitialise(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  odp:TOPTIONSDIALOGPAGE;
begin
  FillChar(odp,SizeOf(odp),0);
  odp.cbSize     :=SizeOf(odp);
  odp.flags      :=ODPF_BOLDGROUPS;
  odp.Position   :=900003000;
  odp.hInstance  :=hInstance;
  odp.szGroup.a  :='Network';
  odp.szTitle.a  :=PluginName;

  odp.pszTemplate:=MAKEINTRESOURCEA(IDD_SETTING);
  odp.pfnDlgProc :=@DlgProcOpt;
  odp.szTab.a    :='Common';
  PluginLink^.CallService(MS_OPT_ADDPAGE,wParam,dword(@odp));

  odp.pszTemplate:=MAKEINTRESOURCEA(IDD_SETTING_TECH);
  odp.pfnDlgProc :=@DlgProcOptTech;//!!
  odp.szTab.a    :='Technical';
  PluginLink^.CallService(MS_OPT_ADDPAGE,wParam,dword(@odp));

  result:=0;
end;

function OnSettingsChanged(wParam:WPARAM;lParam:LPARAM):integer;cdecl;
var
  buf:array [0..MAX_PATH-1] of AnsiChar;
  i:integer;
  pc:PAnsiChar;
begin
  result:=0;

  with PDBCONTACTWRITESETTING(lParam)^ do
    if (StrCmp(szModule,'Skin')=0) and (StrCmp(szSetting,'UseSound')=0) then
    begin
      SetSndVol(Value.bVal);
//       Mute(Value.bVal);
      exit;
    end;

  if StrCmp(PAnsiChar(PluginLink^.CallService(MS_PROTO_GETCONTACTBASEPROTO,wParam,0)),
             PluginName)<>0 then exit;

  with PDBCONTACTWRITESETTING(lParam)^ do
  begin
    // works only if called AFTER changes
    if StrCmp(szModule,strCList)=0 then
    begin
      if StrCmp(szSetting,optMyHandle)=0 then
      begin
        if value._type=DBVT_DELETED then
        begin
          pc:=DBReadString(wParam,PluginName,optNick);
          DBWriteString(wParam,strCList,optMyHandle,pc);
          mFreeMem(pc);
        end;
      end;
      exit;
    end;

    if StrCmp(szModule,'UserInfo')<>0 then exit;

    if StrCmp(szSetting,optAge)=0 then
    begin
      if value._type=DBVT_DELETED then
        i:=DBReadWord(wParam,PluginName,optAge)
      else
        i:=value.wVal;
      DBWriteString(wParam,PluginName,optBitrate,IntToStr(buf,i));
      exit;
    end;
    
    case value._type of
      DBVT_DELETED: pc:=DBReadString(wParam,PluginName,szSetting);
      DBVT_ASCIIZ : pc:=value.szVal.a;
      DBVT_WCHAR  : WideToAnsi(value.szVal.w,pc,MirandaCP);
      DBVT_UTF8   : UTF8ToANSI(value.szVal.a,pc,MirandaCP);
    else
      exit
    end;

    if      StrCmp(szSetting,optFirstName)=0 then DBWriteString(wParam,PluginName,optStationURL,pc)
    else if StrCmp(szSetting,optNick     )=0 then DBWriteString(wParam,strCList,optMyHandle,pc)
    else if StrCmp(szSetting,optLastName )=0 then DBWriteString(wParam,PluginName,optGenre,pc);

    if value._type<>DBVT_ASCIIZ then
      mFreeMem(pc);
  end;
end;

function OnContactDeleted(wParam:WPARAM;lParam:LPARAM):integer;cdecl;
begin
  result:=0;
  if ActiveContact<>THANDLE(wParam) then exit;
  CallService(MS_RADIO_COMMAND,MRC_STOP,wParam);

{  if StrCmp(PAnsiChar(PluginLink^.CallService(MS_PROTO_GETCONTACTBASEPROTO,wParam,0)),
             PluginName)<>0 then exit;
}
end;
