unit iac_global;

interface

uses windows, messages;

const
  DBBranch = 'ActMan';
const
  WM_ACT_SETVALUE = WM_USER + 13;
  WM_ACT_RESET    = WM_USER + 14;
  WM_ACT_SAVE     = WM_USER + 15;
  WM_ACT_REFRESH  = WM_USER + 16; // group, action

const
  isEScript = 1;
const
  rtInt  = 1;
  rtWide = 2;

type
  pWorkData = ^tWorkData;
  tWorkData = record
    hContact  :THANDLE;
    Parameter :LPARAM;
    LastResult:uint_ptr;
    ResultType:integer;   // rt* const
  end;

type
  pBaseAction = ^tBaseAction;
  tBaseAction = object
    ActionDescr:pWideChar; // description (user name)
    UID:dword;             // hash of action type name
    Flags1,
    Flags2:dword;
    parent:pointer;        // pointer to action group (really need?)

    function  DoAction(var WorkData:tWorkData):LRESULT; // process action 
    procedure Load(node:pointer;fmt:integer);           // load/import action
    procedure Save(node:pointer;fmt:integer);           // save/export action
    procedure Clear;                                    // action cleanup
  end;

type
  tCreateActionFunc = function:pBaseAction;
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
    Hash     :dword;             // will be calculated at registration cycle
    DlgHandle:HWND;
  end;

const
  ModuleLink:pActModule=nil;

procedure ClearResult(var WorkData:tWorkData);

procedure InsertString(wnd:HWND;num:dword;str:PAnsiChar);

implementation

uses Common, m_api;


function tBaseAction.DoAction(var WorkData:tWorkData):LRESULT;
begin
  // nothing
end;

procedure tBaseAction.Load(node:pointer;fmt:integer);
begin
  // nothing
end;

procedure tBaseAction.Save(node:pointer;fmt:integer);
begin
  // nothing
end;

procedure tBaseAction.Clear;
begin
  mFreeMem(ActionDescr);
end;


procedure ClearResult(var WorkData:tWorkData);
begin
  if WorkData.ResultType=rtWide then
    mFreeMem(pWideChar(WorkData.LastResult));
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

end.
