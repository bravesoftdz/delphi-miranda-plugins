unit dbsettings;
interface

uses windows,m_api;

function DBReadByte (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:byte =0):byte;
function DBReadWord (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:word =0):word;
function DBReadDword(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:dword=0):dword;

function DBReadSetting   (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;dbv:PDBVARIANT):int_ptr;
function DBReadSettingStr(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;dbv:PDBVARIANT):int_ptr;

function DBReadStringLength(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar):integer;
function DBReadString (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         default:PAnsiChar=nil;enc:integer=DBVT_ASCIIZ):PAnsiChar;
function DBReadUTF8   (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:PAnsiChar=nil):PAnsiChar;
function DBReadUnicode(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:PWideChar=nil):PWideChar;

function DBReadStruct (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         ptr:pointer;size:dword):Integer;
function DBWriteStruct(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         ptr:pointer;size:dword):Integer;

function DBWriteSetting(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;dbv:PDBVARIANT):int_ptr;
function DBWriteByte (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:Byte ):int_ptr;
function DBWriteWord (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:Word ):int_ptr;
function DBWriteDWord(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:dword):int_ptr;

function DBWriteString (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         val:PAnsiChar;enc:integer=DBVT_ASCIIZ):int_ptr;
function DBWriteUTF8   (hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:PAnsiChar):int_ptr;
function DBWriteUnicode(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:PWideChar):int_ptr;

function DBFreeVariant(dbv:PDBVARIANT):int_ptr;
function DBDeleteSetting(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar):int_ptr;

function DBDeleteGroup(hContact:THANDLE;szModule:PAnsiChar):int_ptr;

function DBDeleteModule(szModule:PAnsiChar):integer; // 0.8.0+

function DBGetSettingType(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar):integer;

implementation

uses common;

function DBReadByte(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:byte=0):byte;
var
  dbv:TDBVARIANT;
  cgs:TDBCONTACTGETSETTING;
begin
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=@dbv;
  If PluginLink^.CallService(MS_DB_CONTACT_GETSETTING,hContact,lParam(@cgs))<>0 then
    Result:=default
  else
    Result:=dbv.bVal;
end;

function DBReadWord(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:word=0):word;
var
  dbv:TDBVARIANT;
  cgs:TDBCONTACTGETSETTING;
begin
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=@dbv;
  If PluginLink^.CallService(MS_DB_CONTACT_GETSETTING,hContact,lParam(@cgs))<>0 then
    Result:=default
  else
    Result:=dbv.wVal;
end;

function DBReadDword(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:dword=0):dword;
var
  dbv:TDBVARIANT;
  cgs:TDBCONTACTGETSETTING;
begin
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=@dbv;
  If PluginLink^.CallService(MS_DB_CONTACT_GETSETTING,hContact,lParam(@cgs))<>0 then
    Result:=default
  else
    Result:=dbv.dVal;
end;

function DBReadSetting(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;dbv:PDBVARIANT):int_ptr;
var
  cgs:TDBCONTACTGETSETTING;
begin
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=dbv;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_GETSETTING,hContact,lParam(@cgs));
end;

function DBReadSettingStr(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;dbv:PDBVARIANT):int_ptr;
var
  cgs:TDBCONTACTGETSETTING;
begin
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=dbv;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_GETSETTING_STR,hContact,lParam(@cgs));
end;

function DBReadStringLength(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar):integer;
var
  cgs:TDBCONTACTGETSETTING;
  dbv:TDBVARIANT;
  i:int_ptr;
begin
  FillChar(dbv,SizeOf(dbv),0);
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=@dbv;
  i:=PluginLink^.CallService(MS_DB_CONTACT_GETSETTING_STR,hContact,lParam(@cgs));
  if (i<>0) or (dbv.szVal.a=nil) or (dbv.szVal.a^=#0) then
    result:=0
  else
    result:=lstrlena(dbv.szVal.a);
//!!  if i=0 then
    DBFreeVariant(@dbv);
end;

function DBReadString(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         default:PAnsiChar=nil;enc:integer=DBVT_ASCIIZ):PAnsiChar;
var
  cgs:TDBCONTACTGETSETTING;
  dbv:TDBVARIANT;
  i:int_ptr;
begin
  FillChar(dbv,SizeOf(dbv),0);
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=@dbv;
  dbv._type    :=enc;
  i:=PluginLink^.CallService(MS_DB_CONTACT_GETSETTING_STR,hContact,lParam(@cgs));
  if i=0 then
    default:=dbv.szVal.a;

  if (default=nil) or (default^=#0) then
    result:=nil
  else
    StrDup(result,default);

//!!  if i=0 then
    DBFreeVariant(@dbv);
end;

function DBReadUTF8(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:PAnsiChar=nil):PAnsiChar;
begin
  result:=DBReadString(hContact,szModule,szSetting,default,DBVT_UTF8);
end;

function DBReadUnicode(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;default:PWideChar=nil):PWideChar;
var
  cgs:TDBCONTACTGETSETTING;
  dbv:TDBVARIANT;
  i:int_ptr;
begin
  FillChar(dbv,SizeOf(dbv),0);
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  cgs.pValue   :=@dbv;
  dbv._type    :=DBVT_WCHAR;
  i:=PluginLink^.CallService(MS_DB_CONTACT_GETSETTING_STR,hContact,lParam(@cgs));
  if i=0 then
    default:=dbv.szVal.w;

  if (default=nil) or (default^=#0) then
    result:=nil
  else
    StrDupW(result,default);

//!!  if i=0 then
    DBFreeVariant(@dbv);
end;

function DBReadStruct(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         ptr:pointer;size:dword):Integer;
var
  dbv:TDBVariant;
begin
  FillChar(dbv,SizeOf(dbv),0);
  dbv._type:=DBVT_BLOB;
  dbv.pbVal:=nil;
  if (DBReadSetting(0,szModule,szSetting,@dbv)=0) and
     (dbv.pbVal<>nil) and (dbv.cpbVal=size) then
  begin
    move(dbv.pbVal^,ptr^,size);
    DBFreeVariant(@dbv);
    result:=1;
  end
  else
    result:=0;
end;

function DBWriteStruct(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         ptr:pointer;size:dword):Integer;
var
  cws:TDBCONTACTWRITESETTING;
begin
  cws.szModule    :=szModule;
  cws.szSetting   :=szSetting;
  cws.value._type :=DBVT_BLOB;
  cws.value.pbVal :=ptr;
  cws.value.cpbVal:=size;
  result:=PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING,0,lParam(@cws));
end;

function DBWriteSetting(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;dbv:PDBVARIANT):int_ptr;
var
  cws: TDBCONTACTWRITESETTING;
begin
  cws.szModule  :=szModule;
  cws.szSetting :=szSetting;
  move(dbv^,cws.value,SizeOf(TDBVARIANT));
  Result := PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING, hContact, lParam(@cws));
end;

function DBWriteByte(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:Byte):int_ptr;
var
  cws:TDBCONTACTWRITESETTING;
begin
  cws.szModule   :=szModule;
  cws.szSetting  :=szSetting;
  cws.value._type:=DBVT_BYTE;
  cws.value.bVal :=Val;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING,hContact,lParam(@cws));
end;

function DBWriteWord(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:Word):int_ptr;
var
  cws:TDBCONTACTWRITESETTING;
begin
  cws.szModule   :=szModule;
  cws.szSetting  :=szSetting;
  cws.value._type:=DBVT_WORD;
  cws.value.wVal :=Val;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING,hContact,lParam(@cws));
end;

function DBWriteDWord(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:dword):int_ptr;
var
  cws:TDBCONTACTWRITESETTING;
begin
  cws.szModule   :=szModule;
  cws.szSetting  :=szSetting;
  cws.value._type:=DBVT_DWORD;
  cws.value.dVal :=Val;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING,hContact,lParam(@cws));
end;

function DBWriteString(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;
         val:PAnsiChar;enc:integer=DBVT_ASCIIZ):int_ptr;
var
  cws:TDBCONTACTWRITESETTING;
begin
  cws.szModule     :=szModule;
  cws.szSetting    :=szSetting;
  cws.value._type  :=enc;
  if val=nil then
    val:='';
  cws.value.szVal.a:=Val;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING,hContact,lParam(@cws));
end;

function DBWriteUTF8(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:PAnsiChar):int_ptr;
begin
  result:=DBWriteString(hContact,szModule,szSetting,val,DBVT_UTF8);
end;

function DBWriteUnicode(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar;val:PWideChar):int_ptr;
begin
  result:=DBWriteString(hContact,szModule,szSetting,PAnsiChar(val),DBVT_WCHAR);
{
var
  cws:TDBCONTACTWRITESETTING;
begin
  cws.szModule     :=szModule;
  cws.szSetting    :=szSetting;
  cws.value._type  :=DBVT_WCHAR;
  cws.value.szVal.w:=Val;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_WRITESETTING,hContact,lParam(@cws));
}
end;

function DBFreeVariant(dbv:PDBVARIANT):int_ptr;
begin
  Result:=PluginLink^.CallService(MS_DB_CONTACT_FREEVARIANT,0,lParam(dbv));
end;

function DBDeleteSetting(hContact:THandle;szModule:PAnsiChar;szSetting:PAnsiChar):int_ptr;
var
  cgs:TDBCONTACTGETSETTING;
begin
  cgs.szModule :=szModule;
  cgs.szSetting:=szSetting;
  Result:=PluginLink^.CallService(MS_DB_CONTACT_DELETESETTING,hContact,lParam(@cgs));
end;
{
type
  pdbenumrec = ^dbenumrec;
  dbenumrec = record
    num:integer;
    ptr:PAnsiChar;
  end;
function EnumSettingsProc(const szSetting:PAnsiChar;lParam:LPARAM):int; cdecl;
begin
  with pdbenumrec(lParam)^ do
  begin
    lstrcpya(ptr,szSetting);
    while ptr^<>#0 do inc(ptr);
    inc(ptr);
    inc(num);
  end;
  result:=0;
end;
//  hContact = 0
function DBDeleteGroup(hContact:THANDLE;szModule:PAnsiChar):integer;
var
  ces:TDBCONTACTENUMSETTINGS;
  cgs:TDBCONTACTGETSETTING;
  p:PAnsiChar;
  rec:dbenumrec;
begin
  GetMem(p,65520);
  rec.num   :=0;
  rec.ptr   :=p;
  ces.pfnEnumProc:=@EnumSettingsProc;
  ces.szModule   :=szModule;
  ces.lParam     :=integer(@rec);
  ces.ofsSettings:=0;
  result:=PluginLink^.CallService(MS_DB_CONTACT_ENUMSETTINGS,hContact,dword(@ces));
  cgs.szModule :=szModule;
  rec.ptr:=p;
  with rec do
    while num>0 do
    begin
      dec(num);
      cgs.szSetting:=ptr;
      PluginLink^.CallService(MS_DB_CONTACT_DELETESETTING,hContact,lParam(@cgs));
      while ptr^<>#0 do inc(ptr);
      inc(ptr);
    end;
  FreeMem(p);
end;
}

type
  ppchar = ^pAnsiChar;

function EnumSettingsProc(const szSetting:PAnsiChar;lParam:LPARAM):int; cdecl;
begin
  lstrcpya(ppchar(lParam)^,szSetting);
  while ppchar(lParam)^^<>#0 do inc(ppchar(lParam)^);
  inc(ppchar(lParam)^);
  result:=0;
end;
function EnumSettingsProcCalc(const szSetting:PAnsiChar;lParam:LPARAM):int; cdecl;
begin
  inc(pint_ptr(lParam)^,lstrlena(szSetting)+1);
  result:=0;
end;
//  hContact = 0
function DBDeleteGroup(hContact:THANDLE;szModule:PAnsiChar):int_ptr;
var
  ces:TDBCONTACTENUMSETTINGS;
  cgs:TDBCONTACTGETSETTING;
  p:PAnsiChar;
  num:integer;
  ptr:pAnsiChar;
begin
  ces.szModule:=szModule;
  num:=0;

  ces.pfnEnumProc:=@EnumSettingsProcCalc;
  ces.lParam     :=lParam(@num);
  ces.ofsSettings:=0;
  PluginLink^.CallService(MS_DB_CONTACT_ENUMSETTINGS,hContact,lparam(@ces));

  GetMem(p,num+1);
  ptr:=p;
  ces.pfnEnumProc:=@EnumSettingsProc;
  ces.lParam     :=lparam(@ptr);
  ces.ofsSettings:=0;
  result:=PluginLink^.CallService(MS_DB_CONTACT_ENUMSETTINGS,hContact,lparam(@ces));
  ptr^:=#0;

  cgs.szModule:=szModule;
  ptr:=p;
  while ptr^<>#0 do
  begin
    cgs.szSetting:=ptr;
    PluginLink^.CallService(MS_DB_CONTACT_DELETESETTING,hContact,lParam(@cgs));
    while ptr^<>#0 do inc(ptr);
    inc(ptr);
  end;
  FreeMem(p);
end;

function DBDeleteModule(szModule:PAnsiChar):integer; // 0.8.0+
begin
  result:=0;
  PluginLink^.CallService(MS_DB_MODULE_DELETE,0,lParam(szModule));
end;

function DBGetSettingType(hContact:THANDLE;szModule:PAnsiChar;szSetting:PAnsiChar):integer;
var
  ldbv:TDBVARIANT;
begin
  if DBReadSetting(hContact,szModule,szSetting,@ldbv)=0 then
  begin
    result:=ldbv._type;
    DBFreeVariant(@ldbv);
  end
  else
    result:=DBVT_DELETED;
end;

begin
end.
