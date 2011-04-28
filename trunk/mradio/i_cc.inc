{}
{
function Mute(arg:integer=-1):boolean;
var
  vol:integer;
begin
  if arg<0 then
    result:=DBReadByte(0,'Skin','UseSound')=0
  else
  begin
    result:=true;
    if chan<>0 then
    begin
      if arg=0 then
        vol:=0
      else
        vol:=Volume;
      BASS_ChannelSetAttributes(chan,-1,vol,-101);
    end;
  end;
end;
}

function GetStatusText(status:integer):PWideChar;
begin
  case status of
    RD_STATUS_PAUSED : result:='paused';
    RD_STATUS_STOPPED: result:='stopped';
    RD_STATUS_CONNECT: result:='connecting';
    RD_STATUS_ABORT  : result:='aborting';
    RD_STATUS_PLAYING: result:='playing';
  else
    result:=nil;
  end;
end;

procedure ConstructMsg(astr:PWideChar;status:integer=-1;astr1:PWideChar=nil);
var
  buf:PWideChar;
  astrlen,astr1len,statuslen:integer;
  sstatus:PWideChar;
  p:pWideChar;
begin
  if (astr<>nil) and (astr^<>#0) then
    astrlen:=StrLenW(astr)
  else
    astrlen:=0;
  if (astr1<>nil) and (astr1^<>#0) then
    astr1len:=StrLenW(astr1)+3
  else
    astr1len:=0;

  statuslen:=0;
  if status>=0 then
  begin
    sstatus:=TranslateW(GetStatusText(status));
    if sstatus<>nil then
      statuslen:=StrLenW(sstatus)+3;
  end;

  if (astrlen+astr1len+statuslen)>0 then
  begin
    mGetMem(buf,(astrlen+astr1len+statuslen+1)*SizeOf(WideChar));
    p:=buf;
    if astrlen>0 then
      p:=StrCopyEW(p,astr);
    if astr1len>0 then
    begin
      if astrlen>0 then
      begin
        p^:=' '; inc(p);
        p^:='-'; inc(p);
        p^:=' '; inc(p);
      end;
      p:=StrCopyEW(p,astr1);
    end;
    if statuslen>0 then
    begin
      p^:=' '; inc(p);
      p^:='('; inc(p);
      p:=StrCopyEW(p,sstatus);
      p^:=')'; inc(p);
      p^:=#0;
    end;
    DBWriteUnicode(ActiveContact,strCList,optStatusMsg,buf);
    mFreeMem(buf);
  end
  else
    DBDeleteSetting(ActiveContact,strCList,optStatusMsg);
end;

function ControlCenter(code:WPARAM;arg:LPARAM):int_ptr; cdecl;
var
  res:uint_ptr;
  tmpbuf,buf1:array [0..MAX_PATH-1] of WideChar;
  plFile:pWideChar;
  plLocal:boolean;
begin
  result:=0;
  case code of
    MRC_PLAY : begin
      if arg<>0 then
      begin
        ActiveURLw:=DBReadUnicode(arg,PluginName,optStationURL);
        if (ActiveURLw=nil) or (ActiveURLw^=#0) then exit;

        ActiveContact:=arg;
        RemoteSong:=StrPosW(ActiveURLw,'://')<>nil;

        if IsPlaylist(ActiveURLw)<>0 then
        begin

          if RemoteSong then
          begin
            GetTempPathW(MAX_PATH,tmpbuf);
            GetTempFileNameW(tmpbuf,'mr',GetCurrentTime,buf1);
            if not GetFile(ActiveURLw,buf1,hNetlib) then
            begin
              exit;
            end;
            plFile:=@buf1;
            PlLocal:=false;
          end
          else
          begin
            plFile:=ActiveuRLw;
            PlLocal:=true;
          end;

          plist:=CreatePlaylist(plFile);
          if not plLocal then
            DeleteFileW(PlFile);

          if plist<>nil then
          begin
            if plist.GetCount=0 then
            begin
              plist.Free;
              plist:=nil;
              ActiveContact:=0;
              exit;
            end;
            plist.Shuffle:=doShuffle<>BST_UNCHECKED;

            if not plist.Shuffle then
            begin
              if PlayFirst=BST_UNCHECKED then
                plist.Track:=DBReadWord(ActiveContact,PluginName,optCurElement);
            end;
            
            mFreeMem(ActiveURLw);
            ActiveURLw:=plist.GetSong;
          end;
        end
        else
          plist:=nil;

        RemoteSong:=StrPosW(ActiveURLw,'://')<>nil; // coz activeuRLw can be changed
        if (ActiveURLw<>nil) and (ActiveURLw^<>#0) then
        begin
          if RemoteSong then
          begin
            if GetWorkOfflineStatus<>0 then
            begin
              Error('Can''t connect to net. Please, clear ''Work offline'' option in Internet settings');
              ControlCenter(MRC_STATUS,RD_STATUS_NOSTATION);
              exit;
            end;
          end;
          if Assigned(plist) then
            ControlCenter(MRC_STATUS,RD_STATUS_CONNECT);
          CloseHandle(BeginThread(nil,0,@OpenURL,ActiveURLw,0,res));
        end;
      end
      else if chan<>0 then
      begin
        BASS_ChannelPlay(chan,true);
        ControlCenter(MRC_STATUS,RD_STATUS_PLAYING);
      end
      else if Assigned(plist) then
      begin
        CloseHandle(BeginThread(nil,0,@OpenURL,ActiveURLw,0,res));
      end;
//      PluginLink^.NotifyEventHooks(hhRadioStatus,MRC_PLAY,lparam(ActiveURLw));
    end;

    MRC_RECORD: begin
      result:=CallService(MS_RADIO_RECORD,arg,0);

      if ((result<>0) and (arg=2)) or   // record on and need to stop
         ((result= 0) and (arg=1)) then // no record and need to start
        result:=CallService(MS_RADIO_RECORD,0,0);

      PluginLink^.NotifyEventHooks(hhRadioStatus,MRC_RECORD,result);
    end;

    MRC_PAUSE: begin
      if chan<>0 then
      begin
        if PlayStatus=RD_STATUS_PLAYING then
        begin
          BASS_ChannelPause(chan);
          ControlCenter(MRC_STATUS,RD_STATUS_PAUSED);
          PluginLink^.NotifyEventHooks(hhRadioStatus,MRC_PAUSE,1);
        end
        else if PlayStatus=RD_STATUS_PAUSED then
        begin
          BASS_ChannelPlay(chan,false);
          ControlCenter(MRC_STATUS,RD_STATUS_PLAYING);
          PluginLink^.NotifyEventHooks(hhRadioStatus,MRC_PAUSE,0);
        end;
      end
      else
      begin
        ActiveContact:=DBReadDWord(0,PluginName,optLastStn);
        if ActiveContact<>0 then
          ControlCenter(MRC_PLAY,ActiveContact);
      end;
    end;

    MRC_STOP: begin
      ControlCenter(MRC_RECORD,2);
      if Assigned(plist) and (arg=0) then
      begin
        if chan<>0 then
        begin
          BASS_ChannelStop(chan);
          ControlCenter(MRC_STATUS,RD_STATUS_STOPPED);
        end;
      end
      else
      begin
        if Assigned(plist) then
        begin
          DBWriteWord(ActiveContact,PluginName,optCurElement,plist.Track);
          plist.free;
        end;
//??        StopStation;
        ControlCenter(MRC_STATUS,RD_STATUS_NOSTATION);
        DBDeleteSetting(0,PluginName,optActiveURL);
        DBDeleteSetting(0,PluginName,optTitle);
        DBDeleteSetting(0,PluginName,optArtist);
      end;
      StopStation;
      PluginLink^.NotifyEventHooks(hhRadioStatus,MRC_STOP,0);
    end;

    MRC_MUTE: begin
      CallService(MS_RADIO_MUTE,0,arg);
    end;

    MRC_NEXT: begin
      if Assigned(plist) then
      begin
        StopStation;
        ActiveURLw:=plist.Next;
        ControlCenter(MRC_PLAY,0);
      end;
    end;

    MRC_PREV: begin
      if Assigned(plist) then
      begin
        StopStation;
        ActiveURLw:=plist.Previous;
        ControlCenter(MRC_PLAY,0)
      end;
    end;

    MRC_STATUS: begin
      if arg=RD_STATUS_GET then
        result:=PlayStatus
      else
      begin
        PlayStatus:=arg;

        ConstructMsg(nil,arg);
        case lobyte(arg) of
          RD_STATUS_NOSTATION: begin
            DBDeleteSetting(ActiveContact,strCList,optStatusMsg);
{            if asOffline<>BST_UNCHECKED then
              SetStatus(ActiveContact,ID_STATUS_OFFLINE)
            else
}              SetStatus(ActiveContact,ID_STATUS_INVISIBLE);
            ActiveContact:=0;
          end;
          RD_STATUS_CONNECT: begin
            SetStatus(ActiveContact,ID_STATUS_AWAY);
          end;
          RD_STATUS_ABORT  : begin
          end;
          RD_STATUS_PLAYING: begin
            DBWriteUnicode(0,PluginName,optActiveURL,ActiveURLw);
            SetStatus(ActiveContact,ID_STATUS_ONLINE);
            ConstructMsg(CurDescrW);
            DBWriteString(0,PluginName,optActiveCodec,GetMusicFormat);
//!!
            PluginLink^.NotifyEventHooks(hhRadioStatus,MRC_PLAY,lparam(ActiveURLw));
          end;
          RD_STATUS_PAUSED : begin
          end;
          RD_STATUS_STOPPED: begin
          end;
        end;
      end;
    end;

    MRC_SEEK: begin
      if not RemoteSong and (chan<>0) then
      begin
        if integer(arg)=-1 then // get position
        begin
          result:=trunc(BASS_ChannelBytes2Seconds(chan,BASS_ChannelGetPosition(chan,BASS_POS_BYTE)));
          if result<0 then
            result:=0;
        end
        else
        begin
          BASS_ChannelSetPosition(chan,BASS_ChannelSeconds2Bytes(chan,arg),BASS_POS_BYTE);
          PluginLink^.NotifyEventHooks(hhRadioStatus,MRC_SEEK,arg);
        end;
      end;
    end;
  end;
end;
