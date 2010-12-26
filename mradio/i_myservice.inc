{My services}

function Service_RadioPlayStop(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  p:PAnsiChar;
  new:bool;
  hContact:THANDLE;
  cni:TCONTACTINFO;
  i:integer;
begin
  result:=0;
  if lParam=0 then
  begin
    if wParam=0 then
      wParam:=GetCListSelContact;
    p:=GetContactProtoAcc(wParam);
    if (p=nil) or (StrCmp(p,PluginName)<>0) then
      exit;
    hContact:=wParam;
  end
  else
  begin
    FillChar(cni,SizeOf(cni),0);
    cni.cbSize  :=sizeof(cni);
    if lParam=1 then
      cni.dwFlag:=CNF_DISPLAY
    else
      cni.dwFlag:=CNF_DISPLAY or CNF_UNICODE;
    cni.szProto :=PluginName;

    hContact:=PluginLink^.CallService(MS_DB_CONTACT_FINDFIRST,0,0);
    while hContact<>0 do
    begin
      p:=PAnsiChar(PluginLink^.CallService(MS_PROTO_GETCONTACTBASEPROTO,hContact,0));
      if (p<>nil) and (StrCmp(p,PluginName)=0) then
      begin
        cni.hContact:=hContact;
        if PluginLink^.CallService(MS_CONTACT_GETCONTACTINFO,0,integer(@cni))=0 then
        begin
          if lParam=1 then
            i:=StrCmp(pAnsiChar(wParam),cni.retval.szVal.a)
          else
            i:=StrCmpW(pWideChar(wParam),cni.retval.szVal.w);
          mmi.free(cni.retval.szVal.w); //!!!!!!??????
          if i=0 then
            break;
        end;
//???????        CallService(MS_RADIO_COMMAND,MRC_PLAY,hContact);
      end;
      hContact:=PluginLink^.CallService(MS_DB_CONTACT_FINDNEXT,hContact,0);
    end;
  end;
  if hContact<>0 then
  begin
    result:=1;
    if PluginStatus=ID_STATUS_OFFLINE then
      Service_SetStatus(ID_STATUS_ONLINE,0);

    if PlayStatus=RD_STATUS_CONNECT then //break while connect
    begin
      ControlCenter(MRC_STATUS,RD_STATUS_ABORT);
      exit;
    end
    else if PlayStatus=RD_STATUS_ABORT then
      exit;

    new:=ActiveContact<>dword(hContact);

    if ActiveContact<>0 then
      ControlCenter(MRC_STOP,1);

    if new then
      CallService(MS_RADIO_COMMAND,MRC_PLAY,hContact);
  end;
end;

function Service_RadioSettings(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  ood:TOPENOPTIONSDIALOG;
begin
  result:=0;
  ood.cbSize:=SizeOf(ood);
  ood.pszGroup:='Network';
  ood.pszPage :=PluginName;
  ood.pszTab  :='Technical';
  CallService(MS_OPT_OPENOPTIONS,0,dword(@ood));
  if tbUsed then
    CallService(MS_TTB_SETBUTTONOPTIONS,(ttbSettings shl 16)+TTBO_TIPNAME,
        dword(Translate('mRadio settings')));
end;

function Service_RadioRecord(wParam:WPARAM;lParam:LPARAM):int;cdecl;
const
  doRecord:boolean=false;
var
  p:PAnsiChar;
begin
  if (wParam=0) or (dword(wParam)>2) then
  begin
    if not doRecord then  // start recording
    begin
      if hRecButton<>0 then
        SendMessage(hRecButton,BM_SETCHECK,BST_CHECKED,0);
      if tbUsed then
      begin
        CallService(MS_TTB_SETBUTTONSTATE,ttbRecord,TTBST_PUSHED);
        p:='Stop record';
      end;
      doRecord:=true;
    end
    else // stop recording
    begin
      if hRecButton<>0 then
        SendMessage(hRecButton,BM_SETCHECK,BST_UNCHECKED,0);
      if tbUsed then
      begin
        CallService(MS_TTB_SETBUTTONSTATE,ttbRecord,TTBST_RELEASED);
        p:='Start record';
      end;
      doRecord:=false;
    end;
    if tbUsed then
      CallService(MS_TTB_SETBUTTONOPTIONS,(ttbRecord shl 16)+TTBO_TIPNAME,
          dword(Translate(p)));
  end;
  result:=ORD(doRecord);
end;

function Service_RadioGetVolume(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=gVolume;
end;

function Service_RadioSetVolume(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=Service_RadioGetVolume(0,0);
  SetSndVol(wParam);

  DBWriteByte(0,PluginName,optVolume,ABS(wParam));
  if lParam<>2 then // not from Frame
    if hVolFrmCtrl<>0 then
      SendMessage(hVolFrmCtrl,TBM_SETPOS,1,wParam);

  if lParam<>1 then // not from Settings
    if hVolCtrl<>0 then
      SendMessage(hVolCtrl,TBM_SETPOS,1,wParam);
end;

function Service_EqOnOff(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=ord(isEQ_OFF=BST_UNCHECKED);
  case wParam of
    0: begin
      if isEQ_OFF=BST_UNCHECKED then
        EQ_OFF
      else
        EQ_ON;
    end;
    1: EQ_ON;
  else
    EQ_OFF;
  end;
  if eq[0].wnd<>0 then // if options opened
  begin
    CheckDlgButton(GetParent(eq[0].wnd),IDC_EQOFF,isEQ_OFF);
  end;
end;
