{}
function LangPackHash(str:pAnsiChar):int; assembler;
asm
		xor  edx,edx
		mov  esi,str
		xor  cl,cl
@@lph_top:
		xor  eax,eax
		and  cl,31
		mov  al,[esi]
		inc  esi
		test al,al
		jz   @@lph_end
		rol  eax,cl
		add  cl,5
		xor  edx,eax
		jmp  @@lph_top
@@lph_end:
		mov  eax,edx
end;

function LangPackHashW(str:pAnsiChar):int; assembler;
asm
		xor  edx,edx
		mov  esi,str
		xor  cl,cl
@@lph_top:
		xor  eax,eax
		and  cl,31
		mov  al,[esi]
		inc  esi
		inc  esi
		test al,al
		jz   @@lph_end
		rol  eax,cl
		add  cl,5
		xor  edx,eax
		jmp  @@lph_top
@@lph_end:
		mov  eax,edx
end;


type
  PLangPackEntry = ^TLangPackEntry;
  TLangPackEntry = record
    linePos    :cardinal;
    english    :PAnsiChar;//not currently used, the hash does everything
    local      :pAnsiChar;
    wlocal     :pWideChar;
  end;
  TLangPackEntryArray = array of TLangPackEntry;

{
  global+local: Plus - easier search; minus - data doubling, eat more space
  2 hash arrays = Hashes+lines in different structures (place economy)
  really, global hashes - just for non-rebuildabled plugins
}
type //my
  THashEntry = record
    Hash    :dword;    // english line hash
    EntryNum:cardinal; // index strings data in "entry" array
  end;
  THashEntryArray = array of THashEntry;

type
  TLangPackStruct = record
    filename         :pWideChar;
    language         :PAnsiChar;
    lastModifiedUsing:PAnsiChar;
    authors          :PAnsiChar;
    authorEmail      :PAnsiChar;
    entry            :TLangPackEntryArray;
    entryCount       :int;
    localeID         :LCID;
    defaultANSICp    :dword;
    GlobHashes       :THashEntryArray;
    // we can move local hashes to common, one array
    // then LangRec have pointers to hashEntries, not translations
    // !!To make GlobHashes, we can make it on the fly or combine locales and sort
  end;

type
  TLangRec = record
    uuid     :TGUID;   // need to get Plugin Lang pack handle (16 bytes)
    pstart   ,         // starting  index of translations in full list
    pend     :integer; // finishing index of translations in full list
    numhashes:int;
    LocHashes:THashEntryArray;
  end;
  TALangRec = array of TLangRec;

var
  langpack:TLangPackStruct;
const
  LangRecNum   :integer   = 0;
  LangDirectory:TALangRec = nil;

const
  LDEntryNumber = 128; // just directory capacity;

//------------------------
(*
This is part to "register" plugin langpack part.
Allocating memory for "directory" structure at "common" section reading
and fill "directory" data. 'end of section' filling in file reasing code
*)
// wParam - start line number
// lParam - plugin uuid (to load just needed translates)
// result - plugin number (order)
//!! NEED - to recognize, need we that plugin or not?
function RegisterLangPlugin(wParam:WPARAM; lParam:LPARAM):int; cdecl;
begin
  if lParam<>0 then
  begin
    // Check what we need this plugin translation
    // (requires plugin names list)
    // just keep empty body if don't need filter
{
    result:=-1;
    exit;
}
    if LangRecNum=HIGH(LangDirectory) then // too much plugins, reallocate
    begin
      SetLength(LangDirectory,Length(LangDirectory)+8);
    end;
  end
  else
  begin // for "common" section
    SetLength(LangDirectory,LDEntryNumber);
  end;

  if LangRecNum>0 then
  begin
    LangDirectory[LangRecNum-1].pend:=wParam-1;
  end;
  FillChar(LangDirectory[LangRecNum],SizeOf(TLangRec),0);
  with LangDirectory[LangRecNum] do
  begin
    uuid:=StringToGUID(PAnsiChar(lParam));
    pstart:=wParam;
    result:=LangRecNum;
  end;
  inc(LangRecNum);
end;

// add translation to array, return line number
function AddToLangpack(szTranslate:pWideChar):int; overload;
begin
  with langpack do
  begin
    if HIGH(entry)<0 then
      SetLength(entry,LDEntryNumber)
    else if entryCount=HIGH(entry) then
      SetLength(entry,Length(entry)+LDEntryNumber);

    WideToAnsi(szTranslate,entry[entryCount].local);
    StrDupW(entry[entryCount].wlocal,szTranslate);

    result:=entryCount;
    inc(entryCount);
  end;
end;

function AddToLangpack(szTranslate:pAnsiChar):int; overload;
begin
  with langpack do
  begin
    if HIGH(entry)<0 then
      SetLength(entry,LDEntryNumber)
    else if entryCount=HIGH(entry) then
      SetLength(entry,Length(entry)+LDEntryNumber);

    AnsiToWide(szTranslate,entry[entryCount].wlocal);
    StrDup(entry[entryCount].local,szTranslate);

    result:=entryCount;
    inc(entryCount);
  end;
end;

//??
procedure MakeGlobalHashes(num:int);
var
  i,size:integer;
begin
  // close last plugin section
  if LangRecNum>0 then
  begin
    LangDirectory[LangRecNum-1].pend:=num;
  end;

  size:=0;
  for i:=0 to HIGH(LangDirectory) do
  begin
    inc(size,LangDirectory[i].numhashes);
  end;
  SetLength(langpack.GlobHashes,size);
  size:=0;
  for i:=0 to HIGH(LangDirectory) do
  begin
    move(LangDirectory[i].LocHashes[0],langpack.GlobHashes[size],LangDirectory[i].numhashes*SizeOf(THashEntry));
    inc(size,LangDirectory[i].numhashes);
  end;
  // can do GlobHashes sort here
end;

// add translated line to main array
procedure AddLine(block:integer;szSource:pWideChar;szTranslate:pWideChar); overload;
begin
  with LangDirectory[block] do
  begin
    if HIGH(LocHashes)<0 then // 1st line
      SetLength(LocHashes,LDEntryNumber)
    else if numhashes=HIGH(LocHashes) then
      SetLength(LocHashes,Length(LocHashes)+LDEntryNumber);

    with LocHashes[numhashes] do
    begin
      EntryNum:=AddToLangpack(szTranslate);
      Hash    :=LangPackHashW(pAnsiChar(szSource));
    end;

    inc(numhashes);
  end;
end;

procedure AddLine(block:integer;szSource:pAnsiChar;szTranslate:pAnsiChar); overload;
begin
  with LangDirectory[block] do
  begin
    if HIGH(LocHashes)<0 then // 1st line
      SetLength(LocHashes,LDEntryNumber)
    else if numhashes=HIGH(LocHashes) then
      SetLength(LocHashes,Length(LocHashes)+LDEntryNumber);

    with LocHashes[numhashes] do
    begin
      EntryNum:=AddToLangpack(szTranslate);
      Hash    :=LangPackHash(szSource);
    end;

    inc(numhashes);
  end;
end;

{$i langimport.inc}

//-------------------------
(*
 Small code part, must be used as service, i think, to get "langpack" handle
 for separate plugin. Usable for New API only.
*)
// Return langpack handle - for plugin-depend translation
// lParam = pointer to uuid ?
function GetLangPackHandle(wPAram:WPARAM;lParam:LPARAM):int; cdecl;
var
  i:integer;
begin
  for i:=1 to LangRecNum-1 do // 0 = common translate
  begin
    with TGUID(LangDirectory[i].uuid) do
    begin
      if D1=PGUID(lParam).D1 then
        if D2=PGUID(lParam).D2 then
          if D3=PGUID(lParam).D3 then
            if int64(D4)=int64(PGUID(lParam).D4) then
            begin
              result:=i;
              exit;
            end;
    end;
  end;
  result:=0;
end;

//------------------------------------
(*
  Template for TranslateString realization
*)
// for compatibility - "handle" is in hiword
function LangPackTranslateString(szEnglish:pAnsiChar; W:int):pAnsiChar;
var
	key:dword;
	i,line:integer;
begin
	if (langPack.entryCount = 0) or (szEnglish = nil) then
	begin
	  result:=szEnglish;
	  exit;
	end;

	if loword(w)=0 then
	  key := LangPackHash(szEnglish)
	else
  	key := LangPackHashW(szEnglish);

  // main search cycle here
  line:=-1;
  if hiword(w)<>0 then // got LP plugin handle
  begin
    for i:=0 to LangDirectory[hiword(w)].numhashes-1 do
    begin
      if LangDirectory[hiword(w)].LocHashes[i].hash=key then
      begin
        line:=LangDirectory[hiword(w)].LocHashes[i].EntryNum;
        break;
      end;
    end;
  	
  	if line<0 then
  	begin
      for i:=0 to LangDirectory[0].numhashes-1 do
      begin
        if LangDirectory[0].LocHashes[i].hash=key then
        begin
          line:=LangDirectory[0].LocHashes[i].EntryNum;
          break;
        end;
      end;
  	end;
  end
  else
  begin
    for i:=0 to HIGH(langpack.GlobHashes) do
    begin
      if langpack.GlobHashes[i].hash=key then
      begin
        line:=langpack.GlobHashes[i].EntryNum;
        break;
      end;
    end;
  end;

	if line>=0 then
	begin
  	if loword(W)=0 then
  	  result:=langpack.entry[line].local
  	else
  	  result:=pAnsiChar(langpack.entry[line].wlocal);
  end
  else
	  result:=szEnglish;
end;

{$i lpservices.inc}

function LoadLangPackModule:int;
var
	hFind:THANDLE;
	szSearch: array [0..MAX_PATH-1] of AnsiChar;
	fd: TWin32FindData;
	tmp:PAnsiChar;
begin
	bModuleInitialized := TRUE;

	ZeroMemory(@langPack,sizeof(langPack));
	LoadLangPackServices();
	tmp:='langpack_*.txt';
  CallService(MS_UTILS_PATHTOABSOLUTE,dword(tmp),dword(@szSearch));

	hFind := FindFirstFile( szSearch, fd);
	if hFind<>INVALID_HANDLE_VALUE then
	begin
    CallService(MS_UTILS_PATHTOABSOLUTE,dword(@fd.cFileName),dword(@szSearch));
		FindClose(hFind);
    LoadLangPack{XML}(szSearch);
	end;
	result:=0;
end;

(*
  Simple part - just free memory from directory when it not needed anymore
*)
procedure FreeLangDirectory;
var
  i:integer;
begin
  for i:=0 to LangRecNum-1 do
  begin
    SetLength(LangDirectory[i].LocHashes,0);
    LangDirectory[i].LocHashes:=nil;
  end;

  SetLength(LangDirectory,0); // with nil
  LangDirectory:=nil;
  LangRecNum:=0;
end;

procedure UnloadLangPackModule();
var
  i:integer;
begin
	if not bModuleInitialized then
	  exit;

	for i:=0 to langPack.entryCount-1 do
	begin
	  with langPack.entry[i] do
	  begin
//  		mFreeMem(english);
  		mFreeMem(local);
  		mFreeMem(wlocal);
		end;
	end;

	if langPack.entryCount>0 then
	begin
		SetLength(langPack.entry,0);
		langPack.entry     :=nil;
		langPack.entryCount:=0;
  end;	
  SetLength(langpack.GlobHashes,0);
  langpack.GlobHashes:=nil;

  FreeLangDirectory;
end;
