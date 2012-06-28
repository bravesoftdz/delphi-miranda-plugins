{}
//type  tDigest = array [0..15] of byte;
(*
const
  client_id  = 'wat';//'wat'; 'tst'
  client_ver = '1.0';
  api_key    = '51f5d25159da31b0814609c3a12900e2';
*)
{$include i_cookies.inc}

const API_URL = 'http://api.myshows.ru/';

const
  defreq = API_URL+'profile/login?login=<login>&password=<password>';

procedure ShowError(code:integer);
var
  buf:array [0..511] of WideChar;
  ppc:pWideChar;
begin
  case code of
    401: begin // “ребуетс€ авторизаци€
      ppc:='Authorization required'; 
    end;
    403: begin // »м€ пользовател€ или пароль не подошли
      ppc:='User name of password wrong';
    end;
    404: begin // Ќе найдено, неправильные параметры
      ppc:='Not found / wrong parameters';
    end;
    500: begin // параметр запроса отсутствует
      ppc:='Wrong query parameters';
    end;
  else
    ppc:='something wrong!';
  end;
  StrCopyW(StrCopyEW(buf,'MyShows: '),TranslateW(ppc));
  
  if PluginLink^.ServiceExists(MS_POPUP_SHOWMESSAGEW)<>0 then
    CallService(MS_POPUP_SHOWMESSAGEW,TWPARAM(@buf),SM_WARNING)
  else
    MessageBoxW(0,@buf,'ERROR',MB_ICONERROR)
end;

function GetMD5Str(digest:TMD5Hash; buf:pAnsiChar):PAnsiChar;
begin
  buf[00]:=HexDigitChrLo[digest[00] shr 4]; buf[01]:=HexDigitChrLo[digest[00] and $0F];
  buf[02]:=HexDigitChrLo[digest[01] shr 4]; buf[03]:=HexDigitChrLo[digest[01] and $0F];
  buf[04]:=HexDigitChrLo[digest[02] shr 4]; buf[05]:=HexDigitChrLo[digest[02] and $0F];
  buf[06]:=HexDigitChrLo[digest[03] shr 4]; buf[07]:=HexDigitChrLo[digest[03] and $0F];
  buf[08]:=HexDigitChrLo[digest[04] shr 4]; buf[09]:=HexDigitChrLo[digest[04] and $0F];
  buf[10]:=HexDigitChrLo[digest[05] shr 4]; buf[11]:=HexDigitChrLo[digest[05] and $0F];
  buf[12]:=HexDigitChrLo[digest[06] shr 4]; buf[13]:=HexDigitChrLo[digest[06] and $0F];
  buf[14]:=HexDigitChrLo[digest[07] shr 4]; buf[15]:=HexDigitChrLo[digest[07] and $0F];
  buf[16]:=HexDigitChrLo[digest[08] shr 4]; buf[17]:=HexDigitChrLo[digest[08] and $0F];
  buf[18]:=HexDigitChrLo[digest[09] shr 4]; buf[19]:=HexDigitChrLo[digest[09] and $0F];
  buf[20]:=HexDigitChrLo[digest[10] shr 4]; buf[21]:=HexDigitChrLo[digest[10] and $0F];
  buf[22]:=HexDigitChrLo[digest[11] shr 4]; buf[23]:=HexDigitChrLo[digest[11] and $0F];
  buf[24]:=HexDigitChrLo[digest[12] shr 4]; buf[25]:=HexDigitChrLo[digest[12] and $0F];
  buf[26]:=HexDigitChrLo[digest[13] shr 4]; buf[27]:=HexDigitChrLo[digest[13] and $0F];
  buf[28]:=HexDigitChrLo[digest[14] shr 4]; buf[29]:=HexDigitChrLo[digest[14] and $0F];
  buf[30]:=HexDigitChrLo[digest[15] shr 4]; buf[31]:=HexDigitChrLo[digest[15] and $0F];
  buf[32]:=#0;
  result:=@buf;
end;

function GetMD5(const data;datalen:integer;var digest:TMD5Hash):TMD5Hash;
begin
  FillChar(digest,16,0);

  md5.md5_hash(pmir_md5_byte_t(data),datalen,digest);

  result:=digest;
end;

function Handshake(login, password:PAnsiChar):boolean;
var
  buf:array [0..32] of AnsiChar;
  digest:TMD5Hash;
  request:array [0..511] of AnsiChar;
  res:pAnsiChar;
  stat:mir_md5_state_t;
begin
  result:=false;
  GetMD5Str(GetMD5(password,StrLen(password),digest),buf);
  md5.md5_init(@stat);
  md5.md5_append(@stat,@buf,32);
  md5.md5_finish(@stat,digest);
  StrCopy(request,defreq);
  StrReplace(request,'<login>'   ,login);
  StrReplace(request,'<password>',buf);

  res:=SendRequestCookies(request,false);
//  res:=SendRequest(request,REQUEST_GET);
  if res<>nil then
  begin
    if uint_ptr(res)<$0FFF then
    begin
      ShowError(int_ptr(res));
    end
    else
    begin
      result:=true;
      mFreeMem(res);
    end;
  end;
end;

function Encode(dst,src:pAnsiChar):PAnsiChar;
begin
  while src^<>#0 do
  begin
    if not (src^ in [' ','%','+','&','?',#128..#255]) then
      dst^:=src^
    else
    begin
      dst^:='%'; inc(dst);
      dst^:=HexDigitChr[ord(src^) shr 4]; inc(dst);
      dst^:=HexDigitChr[ord(src^) and $0F];
    end;
    inc(src);
    inc(dst);
  end;
  dst^:=#0;
  result:=dst;
end;

function SendMSRequest(request:pAnsiChar;doShowError:boolean):boolean;
var
  res:pAnsiChar;
begin
  result:=true;
  res:=SendRequestCookies(request,true);
  if (uint_ptr(res)<>200) and (uint_ptr(res)<$0FFF) then
  begin
//!!    if int_ptr(res)=401 then
    begin
      Handshake(msh_login,msh_password);

      res:=SendRequestCookies(request,true);
    end;
    if (uint_ptr(res)<$0FFF) then
      if (uint_ptr(res)<>200) and doShowError then
      begin
        ShowError(int_ptr(res));
        result:=false;
      end;
  end;
end;

function Scrobble:boolean;
var
  si:pSongInfoA;
  buf:array [0..511] of AnsiChar;
//  bufw:array [0..511] of WideChar;
  res,pc:PAnsiChar;
  shId,epId:pAnsiChar;
  json:TJSONSERVICEINTERFACE;
  jn,jroot:PJSONNODE;
begin
  result:=false;

  si:=pointer(CallService(MS_WAT_RETURNGLOBAL,WAT_INF_UTF8,0));
  Encode(buf,si.mfile);
  pc:=Extract(buf,true);
  
  // Episode search by filename
  StrCopy(StrCopyE(buf,API_URL+'shows/search/file/?q='),pc);
  mFreeMem(pc);
  res:=SendRequest(buf,REQUEST_GET);
  if uint_ptr(res)>$0FFF then
  begin
    CallService(MS_JSON_GETINTERFACE,wparam(@json),0);

    jroot:=json.parse(res);

    jn:=json.get(jroot,'show');
    shId:=json.as_string(json.get(jn,'id'));

    jn:=json.get(jn,'episodes');
    epId:=json.name(json.at(jn,0));
{
kinopoiskId
image
ruTitle
episodes:{:{id:
}
  end
  else
  begin
    if res<>nil then
      ShowError(int_ptr(res));
    exit;
  end;

  // Show mark as "watching"
  StrCopy(StrCopyE(StrCopyE(buf,API_URL+'profile/shows/'),shId),'/watching');
  if SendMSRequest(buf,false) then
  begin
    // Episode check
    StrCopy(StrCopyE(buf,API_URL+'profile/episodes/check/'),epId);
  //  StrCopy(request,API_URL+'profile/shows/');
    if SendMSRequest(buf,true) then
    begin
      //!! add option to show it??
      if PluginLink^.ServiceExists(MS_POPUP_SHOWMESSAGE)<>0 then
      begin
        json.free(shId);
        json.free(epId);

        jn:=json.get(jroot,'show');
        shId:=json.as_string(json.get(jn,'title'));
        jn:=json.get(jn,'episodes');
        epId:=json.as_string(json.get(jn,'title'));

        StrCopy(
          StrCopyE(
            StrCopyE(
              StrCopyE(
                StrCopyE(buf,'Show "'),
              shId),
            '"'#13#10'episode "'),
          epId),
        '" checked');
        CallService(MS_POPUP_SHOWMESSAGE,TWPARAM(@buf),SM_NOTIFY);
      end;
      result:=true;
    end;
  end;
  json.free(shId);
  json.free(epId);

  json.delete_(jroot);
end;

(*
//----- Get Info service functions -----

function FullEncode(dst,src:pAnsiChar):PAnsiChar;
begin
  while src^<>#0 do
  begin
    if src^ in ['A'..'Z','a'..'z','0'..'9'] then
      dst^:=src^
    else
    begin
      dst^:='%'; inc(dst);
      dst^:=HexDigitChr[ord(src^) shr 4]; inc(dst);
      dst^:=HexDigitChr[ord(src^) and $0F];
    end;
    inc(src);
    inc(dst);
  end;
  dst^:=#0;
  result:=dst;
end;

var
  xmlparser:XML_API_W;

function FixInfo(info:pWideChar):pWideChar;
var
  pc,ppc:pWideChar;
  cnt:cardinal;
  need:boolean;
begin
  pc:=info;
  cnt:=0;
  need:=false;
  while pc^<>#0 do
  begin
    if pc^=#$0D then
    begin
      inc(cnt);
      inc(pc);
      if pc^<>#$0A then
        need:=true;
    end
    else
      inc(pc);
  end;
  if need then
  begin
    mGetMem(result,(StrLenW(info)+1+cnt)*SizeOf(WideChar));
    pc:=info;
    ppc:=result;
    while pc^<>#0 do
    begin
      ppc^:=pc^;
      if pc^=#$0D then
      begin
        inc(ppc);
        ppc^:=#$0A;
      end;
      inc(pc);
      inc(ppc);
    end;
    ppc^:=#0;
  end
  else
    StrDupW(result,info);
end;

function GetArtistInfo(var data:tLastFMInfo;lang:integer):int;
var
  si:pSongInfo;
  res,pc:pAnsiChar;
  request:array [0..1023] of AnsiChar;
  root,actnode,node,nnode:HXML;
  i:integer;
  pcw,p,pp:PWideChar;
  artist:pAnsiChar;
begin
  result:=0;
  if data.artist=nil then
  begin
    si:=pointer(CallService(MS_WAT_RETURNGLOBAL,WAT_INF_UNICODE,0));
    pWideChar(artist):=si^.artist;
  end
  else
    pWideChar(artist):=data.artist;
  if artist=nil then
    exit;
  WideToUTF8(pWideChar(artist),artist);
  pc:=FullEncode(StrCopyE(request,
      'http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&api_key='+api_key+'&artist='),
      artist);
  mFreeMem(artist);
  if lang<>0 then
    StrCopyE(StrCopyE(pc,'&lang='),pAnsiChar(@lang));
  res:=SendRequest(request,REQUEST_GET);
  if res<>nil then
  begin
    UTF8ToWide(res,pcw);
    mFreeMem(res);
    xmlparser.cbSize:=XML_API_SIZEOF_V1;
    CallService(MS_SYSTEM_GET_XI,0,dword(@xmlparser));
    with xmlparser do
    begin
      i:=StrLenW(pcw)*SizeOf(WideChar);
      root:=parseString(pcw,@i,nil);

      actnode:=getChild(getChild(root,0),0); // "artist"

      if data.artist=nil then
        StrDupW(data.artist,getText(GetNthChild(actnode,'name',0)));

      i:=0;
      repeat
        node:=GetNthChild(actnode,'image',i);
        if node=0 then break;
        if StrCmpW(GetAttrValue(node,'size'),'medium')=0 then
        begin
          WideToUTF8(GetText(node),data.image);
          break;
        end;
        inc(i);
      until false;

      // bio
      p:=StrPosW(pcw,'<content><![CDATA[');
      if p<>nil then
      begin
        inc(p,18);
        pp:=StrPosW(p,']]');
        if pp<> nil then pp^:=#0;
        data.info:=FixInfo(p);
      end;

      // similar
      i:=0;
      pcw:=pWideChar(@request); pcw^:=#0;
      node:=GetNthChild(actnode,'similar',0);
      repeat
        nnode:=GetNthChild(GetNthChild(node,'artist',i),'name',0);
        if nnode=0 then break;
        if pcw<>@request then
        begin
          pcw^:=','; inc(pcw);
          pcw^:=' '; inc(pcw);
        end;
          pcw:=StrCopyEW(pcw,GetText(nnode));
        inc(i);
      until false;
      pcw:=#0;
      StrDupW(data.similar,pWideChar(@request));

      // tags
      i:=0;
      pcw:=pWideChar(@request); pcw^:=#0;
      node:=GetNthChild(actnode,'tags',0);
      repeat
        nnode:=GetNthChild(GetNthChild(node,'tag',i),'name',0);
        if nnode=0 then break;
        if pcw<>@request then
        begin
          pcw^:=','; inc(pcw);
          pcw^:=' '; inc(pcw);
        end;
          pcw:=StrCopyEW(pcw,GetText(nnode));
        inc(i);
      until false;
      pcw:=#0;
      StrDupW(data.tags,pWideChar(@request));
      DestroyNode(root);
      mFreeMem(pcw);
    end;
  end;
end;

function GetAlbumInfo(var data:tLastFMInfo;lang:integer):int;
var
  si:pSongInfo;
  res,pc:pAnsiChar;
  request:array [0..1023] of AnsiChar;
  root,actnode,node,nnode:HXML;
  i:integer;
  p,pp,pcw:PWideChar;
  album,artist:pAnsiChar;
begin
  result:=0;
  si:=nil;
  if data.album=nil then
  begin
    si:=pointer(CallService(MS_WAT_RETURNGLOBAL,WAT_INF_UNICODE,0));
    pWideChar(album):=si^.album;
  end
  else
    pWideChar(album):=data.album;
  if album=nil then
    exit;
  WideToUTF8(pWideChar(album),album);
  pc:=FullEncode(StrCopyE(request,
     'http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key='+api_key+'&album='),
     album);
  mFreeMem(album);
  if data.artist=nil then
  begin
    if si=nil then
      si:=pointer(CallService(MS_WAT_RETURNGLOBAL,WAT_INF_UNICODE,0));
    pWideChar(artist):=si^.artist;
  end
  else
    pWideChar(artist):=data.artist;
  if artist<>nil then
  begin
    WideToUTF8(pWideChar(artist),artist);
    pc:=FullEncode(StrCopyE(pc,'&artist='),artist);
    mFreeMem(artist);
  end;

  if lang<>0 then
    StrCopyE(StrCopyE(pc,'&lang='),pAnsiChar(@lang));

  res:=SendRequest(request,REQUEST_GET);
  if res<>nil then
  begin
    UTF8ToWide(res,pcw);
    mFreeMem(res);
    xmlparser.cbSize:=XML_API_SIZEOF_V1;
    CallService(MS_SYSTEM_GET_XI,0,dword(@xmlparser));
    with xmlparser do
    begin
      i:=StrLenW(pcw)*SizeOf(WideChar);
      root:=parseString(pcw,@i,nil);

      actnode:=getChild(getChild(root,0),0); // "album"

      if data.album=nil then
        StrDupW(data.album,getText(GetNthChild(actnode,'name',0)));
      StrDupW(data.release,getText(GetNthChild(actnode,'releasedate',0)));
      if data.artist=nil then
        StrDupW(data.artist,getText(GetNthChild(actnode,'artist',0)));

      i:=0;
      repeat
        node:=GetNthChild(actnode,'image',i);
        if node=0 then break;
        if StrCmpW(GetAttrValue(node,'size'),'medium')=0 then
        begin
          WideToUTF8(GetText(node),data.image);
          break;
        end;
        inc(i);
      until false;

      p:=StrPosW(pcw,'<content><![CDATA[');
      if p<>nil then
      begin
        inc(p,18);
        pp:=StrPosW(p,']]');
        if pp<> nil then pp^:=#0;
        data.info:=FixInfo(p);
      end;

      // tags
      i:=0;
      pcw:=pWideChar(@request); pcw^:=#0;
      node:=GetNthChild(actnode,'toptags',0);
      repeat
        nnode:=GetNthChild(GetNthChild(node,'tag',i),'name',0);
        if nnode=0 then break;
        if pcw<>@request then
        begin
          pcw^:=','; inc(pcw);
          pcw^:=' '; inc(pcw);
        end;
          pcw:=StrCopyEW(pcw,GetText(nnode));
        inc(i);
      until false;
      pcw:=#0;
      StrDupW(data.tags,pWideChar(@request));

      DestroyNode(root);
      mFreeMem(pcw);
    end;
  end;
end;

function GetTrackInfo(var data:tLastFMInfo;lang:integer):int;
var
  si:pSongInfo;
  res,pc:pAnsiChar;
  request:array [0..1023] of AnsiChar;
  root,actnode,node,anode:HXML;
  i:integer;
  p,pp,pcw:PWideChar;
  title,artist:pAnsiChar;
begin
  result:=0;
  si:=nil;
  if data.album=nil then
  begin
    si:=pointer(CallService(MS_WAT_RETURNGLOBAL,WAT_INF_UNICODE,0));
    pWideChar(title):=si^.title;
  end
  else
    pWideChar(title):=data.title;
  if title=nil then
    exit;
  WideToUTF8(pWideChar(title),title);
  pc:=FullEncode(StrCopyE(request,
     'http://ws.audioscrobbler.com/2.0/?method=track.getinfo&api_key='+api_key+'&track='),
     title);
  mFreeMem(title);
  if data.artist=nil then
  begin
    if si=nil then
      si:=pointer(CallService(MS_WAT_RETURNGLOBAL,WAT_INF_UNICODE,0));
    pWideChar(artist):=si^.artist;
  end
  else
    pWideChar(artist):=data.artist;
  if artist<>nil then
  begin
    WideToUTF8(pWideChar(artist),artist);
    pc:=FullEncode(StrCopyE(pc,'&artist='),artist);
    mFreeMem(artist);
  end;

  if lang<>0 then
    StrCopyE(StrCopyE(pc,'&lang='),pAnsiChar(@lang));

  res:=SendRequest(request,REQUEST_GET);
  if res<>nil then
  begin
    UTF8ToWide(res,pcw);
    mFreeMem(res);
    xmlparser.cbSize:=XML_API_SIZEOF_V1;
    CallService(MS_SYSTEM_GET_XI,0,dword(@xmlparser));
    with xmlparser do
    begin
      i:=StrLenW(pcw)*SizeOf(WideChar);
      root:=parseString(pcw,@i,nil);

      actnode:=getChild(getChild(root,0),0); // "track"
      if data.artist=nil then
        StrDupW(data.artist,getText(GetNthChild(GetNthChild(actnode,'artist',0),'name',0)));

      anode:=GetNthChild(actnode,'album',i);

      if data.album=nil then
        StrDupW(data.album,getText(GetNthChild(anode,'title',0)));

      data.trknum:=StrToInt(getAttrValue(anode,'position'));
      if data.title=nil then
        StrDupW(data.title,getText(GetNthChild(actnode,'name',0)));

      i:=0;
      repeat
        node:=GetNthChild(anode,'image',i);
        if node=0 then break;
        if StrCmpW(GetAttrValue(node,'size'),'medium')=0 then
        begin
          WideToUTF8(GetText(node),data.image);
          break;
        end;
        inc(i);
      until false;

      p:=StrPosW(pcw,'<content><![CDATA[');
      if p<>nil then
      begin
        inc(p,18);
        pp:=StrPosW(p,']]');
        if pp<> nil then pp^:=#0;
        data.info:=FixInfo(p);
      end;

      // tags
      i:=0;
      pcw:=pWideChar(@request); pcw^:=#0;
      node:=GetNthChild(actnode,'toptags',0);
      repeat
        anode:=GetNthChild(GetNthChild(node,'tag',i),'name',0);
        if anode=0 then break;
        if pcw<>@request then
        begin
          pcw^:=','; inc(pcw);
          pcw^:=' '; inc(pcw);
        end;
        pcw:=StrCopyEW(pcw,GetText(anode));
        inc(i);
      until false;
      pcw:=#0;
      StrDupW(data.tags,pWideChar(@request));

      DestroyNode(root);
      mFreeMem(pcw);
    end;
  end;
end;
*)
