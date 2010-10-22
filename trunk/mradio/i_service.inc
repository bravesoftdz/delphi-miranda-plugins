{services}

function Service_GetCaps(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  case wParam of
    PFLAGNUM_1:
      result:=PF1_EXTSEARCH or PF1_MODEMSGRECV or PF1_ADDSEARCHRES or PF1_BASICSEARCH;
    PFLAGNUM_2:
      result:=PF2_ONLINE or PF2_INVISIBLE or PF2_SHORTAWAY;
    PFLAGNUM_3:
      result:=PF2_ONLINE;// or PF2_INVISIBLE or PF2_SHORTAWAY;
    PFLAGNUM_4:
      result:=PF4_NOCUSTOMAUTH;
    PFLAG_UNIQUEIDSETTING:
      result:=dword(optStationURL)
    else
      result:=0;
  end
end;

function Service_GetName(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  if lParam<>0 then
    StrCopy(PAnsiChar(lParam),Translate(PluginName),wParam);
  result:=0;
end;

function GetAwayMsgProc(hContact:THANDLE):dword;// stdcall;
var
  buf,p:PAnsiChar;
  tmp:array [0..255] of AnsiChar;
  pc:pWideChar;
begin
  if IsVarsInstalled then
  begin
    pc:=ParseVarString(StatusTmpl,ActiveContact);
    WideToAnsi(pc,buf,MirandaCP);
  end
  else
  begin
    mGetMem(buf,1024);
    WideToAnsi(StatusTmpl,p,MirandaCP);
    StrCopy(buf,p);
    mFreeMem(p);
    if StrPos(buf,'%radio_name%')<>nil then
    begin
      p:=DBReadString(ActiveContact,strCList,optMyHandle);
      StrReplace(buf,'%radio_name%',p);
      mFreeMem(p);
    end;
    if StrPos(buf,'%radio_url%')<>nil then
    begin
      p:=DBReadString(ActiveContact,PluginName,optStationURL);
      StrReplace(buf,'%radio_url%',p);
      mFreeMem(p);
    end;
    if StrPos(buf,'%radio_active%')<>nil then
    begin
      StrReplace(buf,'%radio_active%',FastWideToAnsiBuf(ActiveURLw,tmp,MirandaCP));
    end;
    if StrPos(buf,'%radio_genre%')<>nil then
    begin
      p:=DBReadString(ActiveContact,PluginName,optGenre);
      StrReplace(buf,'%radio_genre%',p);
      mFreeMem(p);
    end;
    if StrPos(buf,'%radio_bitrate%')<>nil then
    begin
      p:=DBReadString(ActiveContact,PluginName,optBitrate);
      StrReplace(buf,'%radio_bitrate%',p);
      mFreeMem(p);
    end;
    if StrPos(buf,'%radio_title%')<>nil then
    begin
      StrReplace(buf,'%radio_title%',WideToAnsi(CurDescrw,p,MirandaCP));
      mFreeMem(p);
    end;
    if StrPos(buf,'')<>nil then
    begin
      p:=DBReadString(ActiveContact,PluginName,optActiveCodec);
      StrReplace(buf,'%radio_codec%',p);
      mFreeMem(p);
    end;
    if StrPos(buf,'%radio_status%')<>nil then
    begin
      StrReplace(buf,'%radio_status%',
         Translate(FastWideToAnsiBuf(GetStatusText(PlayStatus),tmp)));
    end;
  end;

  ProtoBroadcastAck(PluginName,hContact,ACKTYPE_AWAYMSG,ACKRESULT_SUCCESS,AckHandle,dword(buf));
  mFreeMem(buf);
  result:=0;
end;

function Service_GetAwayMsg(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  ccs:PCCSDATA;
  res:dword;
begin
  ccs:=PCCSDATA(lParam);
  if (ccs^.hContact<>0) and (PluginStatus=ID_STATUS_ONLINE) and
     (DBReadWord(ccs^.hContact,PluginName,optStatus,ID_STATUS_OFFLINE)=ID_STATUS_ONLINE) then
  begin
    CloseHandle(BeginThread(nil,0,@GetAwayMsgProc,pointer(ccs^.hContact),0,res));
    result:=AckHandle;
  end
  else
    result:=0;
end;

function Service_GetStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  result:=PluginStatus;
end;

function Service_LoadIcon(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
  case loword(wParam) of
    PLI_PROTOCOL: result:=LoadImage(hInstance,MAKEINTRESOURCE(IDI_MAIN),IMAGE_ICON,16,16,LR_SHARED);
//    PLI_ONLINE  : result:=0;
//    PLI_OFFLINE : result:=0;
  else
    result:=0;
  end;
end;

function Service_SetStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
var
  OldStatus:integer;
begin
  result:=0;
  OldStatus:=PluginStatus;
  if wParam<>ID_STATUS_OFFLINE then
    wParam:=ID_STATUS_ONLINE
  else
    mFreeMem(proxy);

  if wParam=PluginStatus then
    exit;
  PluginStatus:=ID_STATUS_OFFLINE;
  if wParam<>ID_STATUS_OFFLINE then
  begin
    if MyInitBASS<>0 then
    begin
      PluginStatus:=ID_STATUS_ONLINE;

      mFreeMem(proxy);
      proxy:=GetProxy(hNetLib);
      BASS_SetConfigPtr(BASS_CONFIG_NET_PROXY,proxy);

{      if asOffline<>BST_UNCHECKED then
        SetStatus(0,ID_STATUS_OFFLINE)
      else
}        SetStatus(0,ID_STATUS_INVISIBLE);

      if (ActiveContact<>0) and (auConnect<>0) then
        ControlCenter(MRC_PLAY,ActiveContact);
//        SetStatus(ActiveContact,ID_STATUS_ONLINE);
    end;
  end
  else //offline
  begin
    StopStation;
    SetStatus(0,ID_STATUS_OFFLINE);
  end;
  ProtoBroadcastAck(PluginName,0,ACKTYPE_STATUS,ACKRESULT_SUCCESS,OldStatus,PluginStatus);
end;

procedure CreateProtoService(serviceName:PAnsiChar;pFunc:pointer);
var
  temp:array [0..MAXMODULELABELLENGTH-1] of AnsiChar;
begin
  StrCopy(StrCopyE(temp,PluginName),serviceName);
  CreateServiceFunction(temp,pFunc);
end;

procedure CreateProtoServices;
begin
  CreateProtoService(PS_GETCAPS          ,@Service_GetCaps);
  CreateProtoService(PS_ADDTOLIST        ,@Service_AddToList);
  CreateProtoService(PS_CREATEADVSEARCHUI,@Service_ExtSearchUI);
  CreateProtoService(PS_SEARCHBYADVANCED ,@Service_SearchByAdvanced);
  CreateProtoService(PS_BASICSEARCH      ,@Service_SearchBasic);
  CreateProtoService(PS_GETNAME          ,@Service_GetName);
  CreateProtoService(PS_LOADICON         ,@Service_LoadIcon);
  CreateProtoService(PS_GETSTATUS        ,@Service_GetStatus);
  CreateProtoService(PS_SETSTATUS        ,@Service_SetStatus);
  CreateProtoService(PSS_GETAWAYMSG      ,@Service_GetAwayMsg);
(*
{
 Asks protocol for the status message for a status
 wParam=(WORD) 0 for current status or a status id
 lParam=SGMA_xxx
 Returns status msg or NULL if there is none.  The protocol have to handle only the current 
 status. Handling messages for other statuses is optional.
 Remember to mir_free the return value
}
  SGMA_UNICODE = 1;        // return Unicode status

  PS_GETMYAWAYMSG = '/GetMyAwayMsg';

*)
(*  {
    wParam : 0
    lParam : Pointer to a null terminated string containing an ID to search for
    Affect : Send a basic search request, see notes
    Returns: A handle to the search request or NULL(0) on failure
    Notes  : All protocols identify users uniquely by a single field
             this service will search by that field.
             -
             All search replies (even protocol-spec extended searches)
             are replied by a series of ack's,-
             -
             Result acks are a series of:
             type=ACKTYPE_SEARCH, result=ACKRESULT_DATA, lParam=Pointer to a TPROTOSEARCHRESULT structure
             -
             ending ack:
             type=ACKTYPE_SEARCH, result=ACKRESULT_SUCCESS, lParam=0
             -
             The pointers in the structure are not guaranteed to be
             valid after the ack is complete.
             -
             The structure to reply with search results can be extended
             per protocol basis (see below)

  }
  PS_BASICSEARCH  = '/BasicSearch';
  PS_BASICSEARCHW = '/BasicSearchW';
*)
end;
