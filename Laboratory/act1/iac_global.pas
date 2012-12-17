unit iac_global;

interface

uses windows, messages;

const
  IcoLibPrefix = 'action_type_';
const
  NoDescription:PWideChar='No Description';
const
  DBBranch = 'ActMan';
const
  protostr = '<proto>';
const
  WM_ACT_SETVALUE   = WM_USER + 13;
  WM_ACT_RESET      = WM_USER + 14;
  WM_ACT_SAVE       = WM_USER + 15;
  WM_ACT_LISTCHANGE = WM_USER + 16; // group, action

const
  ACF_DISABLED   = $10000000;  // action disabled
  ACF_REPLACED   = $20000000;  // action replaced by new in options
  ACF_INTRODUCED = $40000000;  // action is newly created (not saved) in options

const
  isEScript = 1;
const
  rtInt  = 1;
  rtWide = 2;
// maybe will be introduced for initial values only
  rtAnsi = 3;
  rtUTF8 = 4;

type
  pWorkData = ^tWorkData;
  tWorkData = record
    Parameter  :LPARAM;
    LastResult :uint_ptr;
    ResultType :integer;   // rt* const
    ActionList :pointer;
    ActionCount:integer;
  end;

type
  pBaseAction = ^tBaseAction;
  tBaseAction = class
    ActionDescr:pWideChar; // description (user name)
    UID        :dword;     // hash of action type name
    flags      :dword;

    procedure Duplicate(var dst:tBaseAction);

    constructor Create(uid:dword);
    destructor Destroy; override;
//    function  Clone:tBaseAction; virtual;
    function  DoAction(var WorkData:tWorkData):LRESULT; virtual; // process action
    procedure Load(node:pointer;fmt:integer); virtual;           // load/import action
    procedure Save(node:pointer;fmt:integer); virtual;           // save/export action
  end;

type
  tCreateActionFunc = function:tBaseAction;
  tCreateDialogFunc = function(parent:HWND):HWND;

type
  pActModule = ^tActModule;
  tActModule = record
    Next     :pActModule;
    Name     :pAnsiChar;         // action type name
    Dialog   :tCreateDialogFunc; // action dialog creating
    Create   :tCreateActionFunc; // action object creation
    Icon     :pAnsiChar;         // icon resource name
    // runtime data
    DlgHandle:HWND;
    Hash     :dword;             // will be calculated at registration cycle
  end;

const
  ModuleLink:pActModule=nil;

function ClearResult(var WorkData:tWorkData):uint_ptr;
function GetResultNumber(var WorkData:tWorkData):uint_ptr;

procedure InsertString(wnd:HWND;num:dword;str:PAnsiChar);

function GetLink(hash:dword):pActModule;

implementation

uses Common, m_api, global, dbsettings;

const
  opt_uid   = 'uid';
  opt_descr = 'descr';
  opt_flags = 'flags';

constructor tBaseAction.Create(uid:dword);
begin
  if uid<>0 then
  begin
    StrDupW(ActionDescr,NoDescription);
    Self.UID:=uid;
    Flags:=0;
  end;
end;

destructor tBaseAction.Destroy;
begin
  mFreeMem(ActionDescr);

  inherited Destroy;
end;

procedure tBaseAction.Duplicate(var dst:tBaseAction);
begin
  StrDupW(dst.ActionDescr,ActionDescr);
  dst.UID  :=UID;
  dst.Flags:=Flags;
end;
{
function tBaseAction.Clone:tBaseAction;
begin
  //dummy
  result:=nil;
end;
}
function tBaseAction.DoAction(var WorkData:tWorkData):LRESULT;
begin
  result:=0;
  // nothing
end;

procedure tBaseAction.Load(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
      mFreeMem(ActionDescr); // created by constructor
      StrCopy(pc,opt_descr); ActionDescr:=DBReadUnicode(0,DBBranch,section,NoDescription);
      StrCopy(pc,opt_flags); flags      :=DBReadDword  (0,DBBranch,section);
      // UID reading in main program, set by constructor
    end;
{
    1: begin
    end;
}
  end;
end;

procedure tBaseAction.Save(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
      StrCopy(pc,opt_uid  ); DBWriteDWord  (0,DBBranch,section,uid);
      StrCopy(pc,opt_flags); DBWriteDWord  (0,DBBranch,section,flags);
      StrCopy(pc,opt_descr); DBWriteUnicode(0,DBBranch,section,ActionDescr);
    end;
{
    1: begin
    end;
}
  end;
end;

function ClearResult(var WorkData:tWorkData):uint_ptr;
begin
  if WorkData.ResultType=rtWide then
  begin
    mFreeMem(pWideChar(WorkData.LastResult));
    result:=0;
  end
  else
    result:=WorkData.LastResult;
end;

function GetResultNumber(var WorkData:tWorkData):uint_ptr;
begin
  if WorkData.ResultType=rtInt then
    result:=WorkData.LastResult
  else
  begin
    if (pWideChar(WorkData.LastResult)[0]='$') and
       (AnsiChar(pWideChar(WorkData.LastResult)[1]) in sHexNum) then
      result:=HexToInt(pWideChar(WorkData.LastResult)+1)
    else
    if (pWideChar(WorkData.LastResult)[0]='0') and
       (pWideChar(WorkData.LastResult)[1]='x') and
       (AnsiChar(pWideChar(WorkData.LastResult)[2]) in sHexNum) then
      result:=HexToInt(pWideChar(WorkData.LastResult)+2)
    else
      result:=StrToInt(pWideChar(WorkData.LastResult));
  end;
end;

procedure InsertString(wnd:HWND;num:dword;str:PAnsiChar);
var
  buf:array [0..127] of WideChar;
begin
  SendMessageW(wnd,CB_SETITEMDATA,
      SendMessageW(wnd,CB_ADDSTRING,0,
          lparam(TranslateW(FastAnsiToWideBuf(str,buf)))),
      num);
{
  SendMessageW(wnd,CB_INSERTSTRING,num,
      dword(TranslateW(FastAnsiToWideBuf(str,buf))));
}
end;

function GetLink(hash:dword):pActModule;
begin
  result:=ModuleLink;
  while (result<>nil) and (result.Hash<>hash) do
    result:=result^.Next;
end;

end.
