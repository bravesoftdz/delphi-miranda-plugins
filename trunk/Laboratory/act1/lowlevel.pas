unit lowlevel;

interface

uses
  windows,
  iac_global;

const
  ACF_USEDNOW  = $20000000;  // action in use (reserved)
  ACF_VOLATILE = $04000000;  // don't save in DB
  ACF_ASSIGNED = $80000000;  // action assigned

type
  pActionList = ^tActionList;
  tActionList = array [0..1023] of tBaseAction;

const
  MacroNameLen = 64;
type
  pMacroRecord = ^tMacroRecord;
  tMacroRecord = record
    id         :dword;
    flags      :dword;     // ACF_* flags
    descr      :array [0..MacroNameLen-1] of WideChar;
    ActionList :pActionList;
    ActionCount:integer;
  end;

type // array dimension - just for indexing
  pMacroList = ^tMAcroList;
  tMacroList  = array [0..1023] of tMacroRecord;


function GetMacro(id:uint_ptr;byid:boolean):pMacroRecord;
function GetMacroNameById(id:dword):PWideChar;

procedure FreeMacro(Macro:pMacroRecord;mask:dword=0);
procedure FreeMacroList;
// clone just assigned values (for editing)
procedure CloneMacro(var dst,src:pMacroRecord);
// clone one macro list to other (for editing)
function CloneMacroList(srclist:pMacroList;count:integer;var dstlist:pMacroList):integer;
// reallocate custom macro list
procedure ReallocMacroList(var aMacroList:pMacroList;var MaxMacro:cardinal);
// allocate (main) macro list
function CreateMacroList(var ML:pMacroList;isize:cardinal):integer;
// new macro record in custom list
function NewMacro(var aMacroList:pMacroList;var MaxMacro:cardinal):cardinal;

var
  MacroList:pMacroList;
const
  MacroCount:integer=0;

implementation

uses Common;

const
  MacroListPage = 8;

//----- Support -----

function GetMacro(id:uint_ptr;byid:boolean):pMacroRecord;
var
  i:integer;
begin
  if byid then
  begin
    for i:=0 to MacroCount-1 do
    begin
      if ((MacroList^[i].flags and ACF_ASSIGNED)<>0) and
         (id=MacroList^[i].id) then
      begin
        result:=@MacroList^[i];
        exit;
      end;
    end;
  end
  else
  begin
    for i:=0 to MacroCount-1 do
    begin
      if ((MacroList^[i].flags and ACF_ASSIGNED)<>0) and
         (StrCmpW(pWideChar(id),MacroList^[i].descr)=0) then
      begin
        result:=@MacroList^[i];
        exit;
      end;
    end;
  end;
  result:=nil;
end;

function GetMacroNameById(id:dword):PWideChar;
var
  p:pMacroRecord;
begin
  p:=GetMacro(id,true);
  if p<>nil then
    result:=@p^.descr
  else
    result:=nil;
end;

//----- Free list code -----

procedure FreeActionList(var src:pActionList; count:integer; mask:dword);
var
  i:integer;
begin
  for i:=0 to count-1 do
  begin
    if (mask=0) or ((src^[i].flags and mask)<>0) then
      src^[i].Free;
  end;
  FreeMem(src);
  src:=nil;
end;

procedure FreeMacro(Macro:pMacroRecord;mask:dword=0);
begin
  with Macro^ do
  begin
    if (flags and ACF_ASSIGNED)<>0 then
    begin
      flags:=0; // make Unassigned
      FreeActionList(ActionList,ActionCount,mask);
      ActionCount:=0;
    end;
  end;
end;

procedure FreeMacroList;
var
  i:integer;
begin
  for i:=0 to MacroCount-1 do
  begin
    FreeMacro(@MacroList[i]);
  end;
  MacroCount:=0;
  FreeMem(MacroList);
  MacroList:=nil;
end;

//----- Clone lists code -----

function CloneActionList(src:pActionList;count:integer):pActionList;
begin
  if src=nil then
  begin
    result:=nil;
    exit;
  end;
  GetMem(result,count*SizeOf(tBaseAction));
  move(src^,result^,count*SizeOf(tBaseAction))
end;

// clone just assigned values
procedure CloneMacro(var dst,src:pMacroRecord);
begin
  if (src^.flags and ACF_ASSIGNED)<>0 then
  begin
    move(src^,dst^,SizeOf(tMacroRecord));
    dst^.ActionList:=CloneActionList(src^.ActionList,src^.ActionCount);
  end;
end;

// clone main macro list to new (custom)
function CloneMacroList(srclist:pMacroList;count:integer;var dstlist:pMacroList):integer;
var
  src,dst:pMacroRecord;
  i:integer;
begin
  result:=0;
  dstlist:=nil;
  if srclist<>nil then
  begin
    for i:=0 to count-1 do
      if (srclist^[i].flags and ACF_ASSIGNED)<>0 then
        inc(result);
    if result>0 then
    begin
      GetMem(dstlist,result*SizeOf(tMacroRecord));
      src:=pMacroRecord(srclist);
      dst:=pMacroRecord(dstlist);
      i:=result;
      while i>0 do
      begin
        if (src^.flags and ACF_ASSIGNED)<>0 then
        begin
          CloneMacro(dst,src);
          inc(dst);
          dec(i);
        end;
        inc(src);
      end;
    end;
  end;
end;

//----- [re]allocation list code -----

procedure ReallocMacroList(var aMacroList:pMacroList;var MaxMacro:cardinal);
var
  i:cardinal;
  tmp:pMacroList;
begin
  i:=(MaxMacro+MacroListPage)*SizeOf(tMacroRecord);
  GetMem(tmp,i);
  FillChar(tmp^,i,0);
  if MaxMacro>0 then
  begin
    move(aMacroList^,tmp^,MaxMacro*SizeOf(tMacroRecord));
    FreeMem(aMacroList);
  end;
  aMacroList:=tmp;
  inc(MaxMacro,MacroListPage);
end;

// allocate (main) macro list
function CreateMacroList(var ML:pMacroList;isize:cardinal):integer;
begin
  if isize<MacroListPage then
    result:=MacroListPage
  else
    result:=isize;
  GetMem  (ML ,result*SizeOf(tMacroRecord));
  FillChar(ML^,result*SizeOf(tMacroRecord),0);
end;

//----- single macro creation -----

procedure InitMacroValue(pMacro:pMacroRecord);
var
  tmp:int64;
begin
  with pMacro^ do
  begin
    StrCopyW(descr,NoDescription,MacroNameLen-1);
    QueryPerformanceCounter(tmp);
    id         :=tmp and $FFFFFFFF;
    flags      :=ACF_ASSIGNED;
  end;
end;

// new macro record in custom list
function NewMacro(var aMacroList:pMacroList;var MaxMacro:cardinal):cardinal;
var
  i:cardinal;
  pMacro:pMacroRecord;
begin
  i:=0;
  pMacro:=pMacroRecord(aMacroList);
  while i<MaxMacro do
  begin
    if (pMacro^.flags and ACF_ASSIGNED)=0 then
    begin
      result:=i;
      InitMacroValue(pMacro);
      exit;
    end;
    inc(i);
    inc(pMacro);
  end;
  // realloc
  result:=MaxMacro;
  ReallocMacroList(aMacroList,MaxMacro);
  InitMacroValue(@(aMacroList^[result]));
end;

end.
