unit iac_global;

interface

uses windows, messages,m_api;

var
  xmlparser:XML_API_W;

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
function GetLinkByName(name:pAnsiChar):pActModule;

function ImportContact(node:HXML):THANDLE;

implementation


uses Common, global, dbsettings, base64, mirutils;

const
  ioDisabled = 'disabled';
  ioName     = 'name';
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

    1: begin
      with xmlparser do
      begin
        if StrToInt(getAttrValue(HXML(node),ioDisabled))=1 then
          flags:=flags or ACF_DISABLED;

        StrDupW(ActionDescr,getAttrValue(HXML(node),ioName));
      end;
    end;
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

function GetLinkByName(name:pAnsiChar):pActModule;
begin
  result:=ModuleLink;
  while (result<>nil) and (StrCmp(result.Name,name)<>0) do
    result:=result^.Next;
end;

const
  ioCProto   = 'cproto';
  ioIsChat   = 'ischat';
  ioCUID     = 'cuid';
  ioCUIDType = 'cuidtype';

function ImportContact(node:HXML):THANDLE;
var
  proto:pAnsiChar;
  tmpbuf:array [0..63] of AnsiChar;
  dbv:TDBVARIANT;
  is_chat:boolean;
begin
  with xmlparser do
  begin
    proto:=FastWideToAnsiBuf(getAttrValue(node,ioCProto),tmpbuf);
    if (proto=nil) or (proto^=#0) then
    begin
      result:=0;
      exit;
    end;
    is_chat:=StrToInt(getAttrValue(node,ioIsChat))<>0;

    if is_chat then
    begin
      dbv.szVal.W:=getAttrValue(node,ioCUID);
    end
    else
    begin
      FillChar(dbv,SizeOf(TDBVARIANT),0);
      dbv._type:=StrToInt(getAttrValue(node,ioCUIDType));
      case dbv._type of
        DBVT_BYTE  : dbv.bVal:=StrToInt(getAttrValue(node,ioCUID));
        DBVT_WORD  : dbv.wVal:=StrToInt(getAttrValue(node,ioCUID));
        DBVT_DWORD : dbv.dVal:=StrToInt(getAttrValue(node,ioCUID));
        DBVT_ASCIIZ: FastWideToAnsi(getAttrValue(node,ioCUID),dbv.szVal.A);
        DBVT_UTF8  : WideToUTF8(getAttrValue(node,ioCUID),dbv.szVal.A);
        DBVT_WCHAR : StrDupW(dbv.szVal.W,getAttrValue(node,ioCUID));
        DBVT_BLOB  : begin
          Base64Decode(FastWideToAnsi(getAttrValue(node,ioCUID),pAnsiChar(dbv.pbVal)),dbv.pbVal);
        end;
      end;
    end;
  end;
  result:=FindContactHandle(proto,dbv,is_chat);
  if not is_chat then
    case dbv._type of
      DBVT_WCHAR,
      DBVT_ASCIIZ,
      DBVT_UTF8  : mFreeMem(dbv.szVal.A);
      DBVT_BLOB  : mFreeMem(dbv.pbVal);
    end;
end;

end.
