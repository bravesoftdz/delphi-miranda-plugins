{$ifdef M_API_UNIT}

function ProtoServiceExists(const proto,service: PAnsiChar): int; cdecl;

{$else}

function ProtoServiceExists(const proto,service: PAnsiChar): int; cdecl;
var
  buf:array [0..127] of AnsiChar;
begin
  lStrCpyA(@buf,proto);
  lStrCatA(@buf,service);
  result:=PluginLink^.ServiceExists(@buf);
end;

{$endif}


{$ifdef M_API_UNIT}

function CreateVersionString(version:dword;buf:PAnsiChar):PAnsiChar;
function CreateVersionStringPlugin(pluginInfo:PPluginInfo;buf:PAnsiChar):PAnsiChar;

{$else}

function CreateVersionString(version:dword;buf:PAnsiChar):PAnsiChar;
var
  vers:array [0..3] of integer;
begin
  vers[0]:=(version shr 24) and $FF;
  vers[1]:=(version shr 16) and $FF;
  vers[2]:=(version shr  8) and $FF;
  vers[3]:=version and $FF;
  wvsprintfa(buf,'%d.%d.%d.%d',@vers);
  result:=buf;
end;

function CreateVersionStringPlugin(pluginInfo:PPluginInfo;buf:PAnsiChar):PAnsiChar;
begin
  result:=CreateVersionString(pluginInfo^.version,buf);
end;

{$endif}

{$ifdef M_API_UNIT}

function PLUGIN_MAKE_VERSION(a,b,c,d: Cardinal): int;
function PLUGIN_CMP_VERSION(verA: LongInt; verB: LongInt): int;

{$else}

function PLUGIN_MAKE_VERSION(a,b,c,d: Cardinal): int;
begin
  Result := (a shl 24) or (b shl 16) or (c shl 8) or d;
end;

function PLUGIN_CMP_VERSION(verA: LongInt; verB: LongInt): int;
begin
  Result := 0;
  { could be used to compare for severity of age for positive values, if a<b
  results are minus values, 0 for equal, positive if a is newer }
  Inc(Result, (verA and $FF      ) - (verB and $FF));
  Inc(Result, (verA and $FF00    ) - (verB and $FF00));
  Inc(Result, (verA and $FF0000  ) - (verB and $FF0000));
  Inc(Result, (verA and $FF000000) - (verB and $FF000000));
end;

{$endif}

{$ifdef M_SYSTEM}
  {$ifdef M_API_UNIT}

function CallService(const szService: PAnsiChar; wParam: WPARAM; lParam: LPARAM): int;
function HookEvent(const szHook: PAnsiChar; hook_proc: TMIRANDAHOOK): int;
function CreateServiceFunction(const szName: PAnsiChar; const MirandaService: TMIRANDASERVICE): int;

  {$else}

function CallService(const szService: PAnsiChar; wParam: WPARAM; lParam: lParam): int;
begin
  Result := PluginLink^.CallService(szService, wParam, lParam);
end;

function HookEvent(const szHook: PAnsiChar; hook_proc: TMIRANDAHOOK): int;
begin
  Result := PluginLink^.HookEvent(szHook, @hook_proc);
end;

function CreateServiceFunction(const szName: PAnsiChar; const MirandaService: TMIRANDASERVICE): int;
begin
  Result := PluginLink^.CreateServiceFunction(szName, @MirandaService);
end;

  {$endif}

{$endif}

(*
{$ifdef M_DATABASE}

  {$ifdef M_API_UNIT}

function DBGetContactSettingByte(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; errorValue: Integer): Integer;
function DBGetContactSettingWord(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; errorValue: Integer): Integer;
function DBGetContactSettingDword(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; errorValue: Integer): Integer;
function DBGetContactSetting(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; dbv: PDBVARIANT): Integer;
function DBGetContactSettingStr(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; dbv: PDBVARIANT): Integer;
function DBFreeVariant(dbv: PDBVARIANT): integer;
function DBDeleteContactSetting(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar): Integer;
function DBWriteContactSettingByte(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; val: Byte): Integer;
function DBWriteContactSettingWord(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; val: Word): Integer;
function DBWriteContactSettingDWord(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; val: LongInt): Integer;
function DBWriteContactSettingString(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; const val: PAnsiChar): Integer;
function DBWriteContactSettingUnicode(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; const val: PWideChar): Integer;

  {$else}

function DBGetContactSettingByte(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; errorValue: Integer): Integer;
var
  dbv: TDBVARIANT;
  cgs: TDBCONTACTGETSETTING;
begin
  cgs.szModule  := szModule;
  cgs.szSetting := szSetting;
  cgs.pValue    := @dbv;
  If PluginLink^.CallService(MS_DB_CONTACT_GETSETTING, hContact, lParam(@cgs)) <> 0 then
    Result := ErrorValue
  else
    Result := dbv.bVal;
end;

function DBGetContactSettingWord(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; errorValue: Integer): Integer;
var
  dbv: TDBVARIANT;
  cgs: TDBCONTACTGETSETTING;
begin
  cgs.szModule  := szModule;
  cgs.szSetting := szSetting;
  cgs.pValue    := @dbv;
  If PluginLink^.CallService(MS_DB_CONTACT_GETSETTING, hContact, lParam(@cgs)) <> 0 then
    Result := ErrorValue
  else
    Result := dbv.wVal;
end;

function DBGetContactSettingDword(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; errorValue: Integer): Integer;
var
  dbv: TDBVARIANT;
  cgs: TDBCONTACTGETSETTING;
begin
  cgs.szModule  := szModule;
  cgs.szSetting := szSetting;
  cgs.pValue    := @dbv;
  If PluginLink^.CallService(MS_DB_CONTACT_GETSETTING, hContact, lParam(@cgs)) <> 0 then
    Result := ErrorValue
  else
    Result := dbv.dVal;
end;

function DBGetContactSetting(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; dbv: PDBVARIANT): Integer;
var
  cgs: TDBCONTACTGETSETTING;
begin
  cgs.szModule  := szModule;
  cgs.szSetting := szSetting;
  cgs.pValue    := dbv;
  Result := PluginLink^.CallService(MS_DB_CONTACT_GETSETTING, hContact, lParam(@cgs));
end;

function DBGetContactSettingStr(hContact: THandle;
    const szModule: PAnsiChar; const szSetting: PAnsiChar; dbv: PDBVARIANT): Integer;
var
  cgs: TDBCONTACTGETSETTING;
begin
  cgs.szModule  := szModule;
  cgs.szSetting := szSetting;
  cgs.pValue    := dbv;
  Result := PluginLink^.CallService(MS_DB_CONTACT_GETSETTING_STR, hContact, lParam(@cgs));
end;

function DBFreeVariant(dbv: PDBVARIANT): Integer;
begin
  Result := PluginLink^.CallService(MS_DB_CONTACT_FREEVARIANT, 0, lParam(dbv));
end;

function DBDeleteContactSetting(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar): Integer;
var
  cgs: TDBCONTACTGETSETTING;
begin
  cgs.szModule  := szModule;
  cgs.szSetting := szSetting;
  Result := PluginLink^.CallService(MS_DB_CONTACT_DELETESETTING, hContact, lParam(@cgs));
end;

function DBWriteContactSettingByte(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; val: Byte): Integer;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule    := szModule;
  cws.szSetting   := szSetting;
  cws.value._type := DBVT_BYTE;
  cws.value.bVal  := Val;
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, hContact, lParam(@cws));
end;

function DBWriteContactSettingWord(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; val: Word): Integer;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule    := szModule;
  cws.szSetting   := szSetting;
  cws.value._type := DBVT_WORD;
  cws.value.wVal  := Val;
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, hContact, lParam(@cws));
end;

function DBWriteContactSettingDWord(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; val: LongInt): Integer;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule    := szModule;
  cws.szSetting   := szSetting;
  cws.value._type := DBVT_DWORD;
  cws.value.dVal  := Val;
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, hContact, lParam(@cws));
end;

function DBWriteContactSettingString(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; const val: PAnsiChar): Integer;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule     := szModule;
  cws.szSetting    := szSetting;
  cws.value._type  := DBVT_ASCIIZ;
  cws.value.szVal.a:= Val;
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, hContact, lParam(@cws));
end;

function DBWriteContactSettingUnicode(hContact: THandle; const szModule: PAnsiChar; const szSetting: PAnsiChar; const val: PWideChar): Integer;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule     := szModule;
  cws.szSetting    := szSetting;
  cws.value._type  := DBVT_WCHAR;
  cws.value.szVal.w:= Val;
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, hContact, lParam(@cws));
end;

  {$endif}

{$endif}
*)
{$ifdef M_NETLIB}

  {$ifdef M_API_UNIT}

function Netlib_CloseHandle(Handle: THandle): int;
function Netlib_GetBase64DecodedBufferSize(const cchEncoded: int): int;
function Netlib_GetBase64EncodedBufferSize(const cbDecoded: int): int;
function Netlib_Send(hConn: THandle; const buf: PAnsiChar; len: int; flags: int): int;
function Netlib_Recv(hConn: THandle; const buf: PAnsiChar; len: int; flags: int): int;
procedure Netlib_Log(hNetLib: THandle; const sz: PAnsiChar);

  {$else}

function Netlib_CloseHandle(Handle: THandle): int;
begin
  Result := PluginLink^.CallService(MS_NETLIB_CLOSEHANDLE, Handle, 0);
end;

function Netlib_GetBase64DecodedBufferSize(const cchEncoded: int): int;
begin
  Result := (cchEncoded shr 2) * 3;
end;

function Netlib_GetBase64EncodedBufferSize(const cbDecoded: int): int;
begin
  Result := (cbDecoded * 4+11) div 12*4+1;
end;

function Netlib_Send(hConn: THandle; const buf: PAnsiChar; len: int; flags: int): int;
var
  nlb: TNETLIBBUFFER;
begin
  nlb.buf   := buf;
  nlb.len   := len;
  nlb.flags := flags;
  Result := PluginLink^.CallService(MS_NETLIB_SEND, wParam(hConn), lParam(@nlb));
end;

function Netlib_Recv(hConn: THandle; const buf: PAnsiChar; len: int; flags: int): int;
var
  nlb: TNETLIBBUFFER;
begin
  nlb.buf   := buf;
  nlb.len   := len;
  nlb.flags := flags;
  Result := PluginLink^.CallService(MS_NETLIB_RECV, wParam(hConn), lParam(@nlb));
end;

procedure Netlib_Log(hNetLib: THandle; const sz: PAnsiChar);
begin
  PluginLink^.CallService(MS_NETLIB_LOG, hNetLib, lParam(sz));
end;

  {$endif}

{$endif}

{$ifdef M_UTILS}

  {$ifdef M_API_UNIT}

function WindowList_Add(hList: THandle; hWnd: HWND; hContact: THandle): int;
function WindowList_Remove(hList: THandle; hWnd: THandle): int;
function WindowList_Find(hList: THandle; hContact: THandle): int;
function WindowList_Broadcast(hList: THandle; message: int; wParam: WPARAM; lParam: LPARAM): int;
function Utils_SaveWindowPosition(hWnd: THandle; hContact: THandle; const szModule, szNamePrefix: PAnsiChar): int;
function Utils_RestoreWindowPosition(hWnd: THandle; hContact: THandle; Flags: int; const szModule, szNamePrefix: PAnsiChar): int;
function mir_a2u(src:PAnsiChar):pWideChar;
function mir_u2a(src:PWideChar):PAnsiChar;

  {$else}

function WindowList_Add(hList: THandle; hWnd: hWnd; hContact: THandle): int;
var
  wle: TWINDOWLISTENTRY;
begin
  wle.hList    := hList;
  wle.hWnd     := hWnd;
  wle.hContact := hContact;
  Result := PluginLink^.CallService(MS_UTILS_ADDTOWINDOWLIST, 0, lParam(@wle));
end;

function WindowList_Remove(hList: THandle; hWnd: THandle): int;
begin
  Result := PluginLink^.CallService(MS_UTILS_REMOVEFROMWINDOWLIST, hList, hWnd);
end;

function WindowList_Find(hList: THandle; hContact: THandle): int;
begin
  Result := PluginLink^.CallService(MS_UTILS_FINDWINDOWINLIST, hList, hContact);
end;

function WindowList_Broadcast(hList: THandle; message: int; wParam: WPARAM; lParam: LPARAM): int;
var
  msg: TMSG;
begin
  msg.message := message;
  msg.wParam  := wParam;
  msg.lParam  := lParam;
  Result := PluginLink^.CallService(MS_UTILS_BROADCASTTOWINDOWLIST, hList, Integer(@Msg));
end;

function Utils_SaveWindowPosition(hWnd: THandle; hContact: THandle; const szModule, szNamePrefix: PAnsiChar): int;
var
  swp: TSAVEWINDOWPOS;
begin
  swp.hWnd     := hWnd;
  swp.hContact := hContact;
  swp.szModule := szModule;
  swp.szNamePrefix := szNamePrefix;
  Result := PluginLink^.CallService(MS_UTILS_SAVEWINDOWPOSITION, 0, lParam(@swp));
end;

function Utils_RestoreWindowPosition(hWnd: THandle; hContact: THandle; Flags: int; const szModule, szNamePrefix: PAnsiChar): int;
var
  swp: TSAVEWINDOWPOS;
begin
  swp.hWnd         := hWnd;
  swp.hContact     := hContact;
  swp.szModule     := szModule;
  swp.szNamePrefix := szNamePrefix;
  Result := PluginLink^.CallService(MS_UTILS_RESTOREWINDOWPOSITION, Flags, lParam(@swp));
end;

function mir_a2u(src:PAnsiChar):pWideChar;
var
  codepage:int;
  cbLen:int;
begin
  codepage:=PluginLink^.CallService('LangPack/GetCodePage',0,0 );

  cbLen:= MultiByteToWideChar(codepage,0,src,-1,NIL,0);
  result:=mmi.malloc(sizeof(WideChar)*(cbLen+1));
  if result=nil then
    exit;

  MultiByteToWideChar(codepage,0,src,-1,result,cbLen);
  result[cbLen]:=#0;
end;

function mir_u2a(src:PWideChar):PAnsiChar;
var
  codepage:int;
  cbLen:int;
begin
  codepage:=PluginLink^.CallService('LangPack/GetCodePage',0,0 );

  cbLen:= WideCharToMultiByte(codepage,0,src,-1,NIL,0,nil,nil);
  result:=mmi.malloc(cbLen+1);
  if result=nil then
    exit;

  WideCharToMultiByte(codepage,0,src,-1,result,cbLen,nil,nil);
  result[cbLen]:=#0;
end;
  {$endif}

{$endif}

{$ifdef M_LANGPACK}

  {$ifdef M_API_UNIT}

function Translate(sz: PAnsiChar): PAnsiChar;
function Translatew(sz: PWideChar): PWideChar;
function TranslateString(const sz: string): string;
function TranslateDialogDefault(hwndDlg: THandle): int;

  {$else}

function TranslateW(sz: PWideChar): PWideChar;
begin
  { the return value maybe NULL(0) -- it's upto the caller to know if the allocated
  string has to be removed from the DLL heap, this has little to do with Miranda,
  but if a dynamic string is passed and a return string is used -- the dynamic
  string is lost -- be careful, lazy? use TranslateString (note it's slower) }
  Result := PWideChar(PluginLink^.CallService(MS_LANGPACK_TRANSLATESTRING, LANG_UNICODE, lParam(sz)));
end;

function Translate(sz: PAnsiChar): PAnsiChar;
begin
  { the return value maybe NULL(0) -- it's upto the caller to know if the allocated
  string has to be removed from the DLL heap, this has little to do with Miranda,
  but if a dynamic string is passed and a return string is used -- the dynamic
  string is lost -- be careful, lazy? use TranslateString (note it's slower) }
  Result := PAnsiChar(PluginLink^.CallService(MS_LANGPACK_TRANSLATESTRING, 0, lParam(sz)));
end;

function TranslateString(const sz:string):string;
begin
  Result:=string(PAnsiChar(PluginLink^.CallService(MS_LANGPACK_TRANSLATESTRING,0,lparam(sz))));
end;

function TranslateDialogDefault(hwndDlg: THandle): int;
var
  lptd: TLANGPACKTRANSLATEDIALOG;
begin
  lptd.cbSize         := sizeof(lptd);
  lptd.flags          := 0;
  lptd.hwndDlg        := hwndDlg;
  lptd.ignoreControls := nil;
  Result := PluginLink^.CallService(MS_LANGPACK_TRANSLATEDIALOG, 0, lParam(@lptd));
end;

  {$endif}

{$endif}

{$ifdef M_PROTOCOLS}
  {$ifdef M_API_UNIT}

function CallContactService(hContact: THandle; const szProtoService: PAnsiChar; wParam: WPARAM; lParam: LPARAM): int;
function CallProtoService(const szModule, szService: PAnsiChar; wParam: WPARAM; lParam: LPARAM): int;

  {$else}

function CallContactService(hContact: THandle; const szProtoService: PAnsiChar; wParam: WPARAM; lParam: LPARAM): int;
var
  css: TCCSDATA;
begin
  css.hContact       := hContact;
  css.szProtoService := szProtoService;
  css.wParam         := wParam;
  css.lParam         := lParam;
  Result := PluginLink^.CallService(MS_PROTO_CALLCONTACTSERVICE, 0, Integer(@css));
end;

function CallProtoService(const szModule, szService: PAnsiChar; wParam: WPARAM; lParam: LPARAM): int;
var
  szStr: array[0..MAXMODULELABELLENGTH*2] of AnsiChar;
begin
  lstrcpya(szStr, szModule);
  lstrcata(szStr, szService);
  Result := PluginLink^.CallService(szStr, wParam, lParam);
end;

  {$endif}
{$endif}

{$ifdef M_PROTOMOD}
  {$ifdef M_API_UNIT}

function ProtoBroadcastAck(const szModule: PAnsiChar; hContact: THandle; type_: int; result_: int; hProcess: THandle; lParam: LPARAM): int;
function CreateProtoServiceFunction(const szModule, szService: PAnsiChar; serviceProc: TMIRANDASERVICE): int;

  {$else}

function ProtoBroadcastAck(const szModule: PAnsiChar; hContact: THandle; type_: int; result_: int; hProcess: THandle; lParam: LPARAM): int;
var
  ack: TACKDATA;
begin
  ack.cbSize   := sizeof(TACKDATA);
  ack.szModule := szModule;
  ack.hContact := hContact;
  ack._type    := type_;
  ack._result  := result_;
  ack.hProcess := hProcess;
  ack.lParam   := lParam;
  Result := PluginLink^.CallService(MS_PROTO_BROADCASTACK, 0, Integer(@ack));
end;

function CreateProtoServiceFunction(const szModule, szService: PAnsiChar; serviceProc: TMIRANDASERVICE): int;
var
  szStr: array[0..MAXMODULELABELLENGTH*2] of AnsiChar;
begin
  lstrcpya(szStr, szModule);
  lstrcata(szStr, szService);
  Result := PluginLink^.CreateServiceFunction(szStr, @serviceProc);
end;

  {$endif}

{$endif}

{$ifdef M_SKIN}

  {$ifdef M_API_UNIT}

function LoadSkinnedIcon(id: int): THandle;
function LoadSkinnedProtoIcon(const szProto: PAnsiChar; status: int): THandle;
function SkinAddNewSound(const name, description, defaultFile: PAnsiChar): int;
function SkinPlaySound (const name: PAnsiChar): int;

  {$else}

function LoadSkinnedIcon(id: int): THandle;
begin
  Result := PluginLink^.CallService(MS_SKIN_LOADICON, id, 0);
end;

function LoadSkinnedProtoIcon(const szProto: PAnsiChar; status: int): THandle;
begin
  Result := PluginLink^.CallService(MS_SKIN_LOADPROTOICON, wParam(szProto), status);
end;

function SkinAddNewSound(const name, description, defaultFile: PAnsiChar): int;
var
  ssd: TSKINSOUNDDESC;
begin
  ssd.cbSize         := sizeof(ssd);
  ssd.pszName        := name;
  ssd.pszDescription := description;
  ssd.pszDefaultFile := defaultFile;
  Result := PluginLink^.CallService(MS_SKIN_ADDNEWSOUND, 0, lParam(@ssd));
end;

function SkinPlaySound (const name: PAnsiChar): int;
begin
  Result := PluginLink^.CallService(MS_SKIN_PLAYSOUND, 0, lParam(name));
end;

  {$endif}

{$endif}
