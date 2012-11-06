unit iac_chain;

interface

implementation

uses
  windows, messages,
  iac_global, mirutils, m_api,
  common,dbsettings;

{$include m_actions.inc}
{$include m_actman.inc}
{$include i_cnst_chain.inc}
{$resource iac_chain.res}

const
  ACF_BYNAME   = $00000001; // Address action link by name, not Id

const
  opt_chain = 'chain';
//  opt_actname = 'actname';
const
  NoChainText:PWideChar = 'not defined';

type
  pChainAction = ^tChainAction;
  tChainAction = object(tBaseAction)
    id: dword;
    actname:pWideChar;

    function DoAction(var WorkData:tWorkData):LRESULT;
    procedure Save(node:pointer;fmt:integer);
    procedure Load(node:pointer;fmt:integer);
    procedure Clear;
  end;

//----- Support functions -----

//----- Object realization -----

function tChainAction.DoAction(var WorkData:tWorkData):LRESULT;
var
  params:tAct_Param;
begin
  result:=0;

  if (flags1 and ACF_BYNAME)<>0 then
  begin
    params.flags:=ACTP_BYNAME or ACTP_WAIT;
    params.id   :=uint_ptr(actname);
  end
  else
  begin
    params.flags:=ACTP_WAIT;
    params.id   :=id;
  end;
  params.wParam:=WorkData.Parameter;
  params.lParam:=WorkData.LastResult;
  CallService(MS_ACT_RUNPARAMS,0,tlparam(@params));
  WorkData.LastResult:=params.lParam;
  WorkData.ResultType:=rtInt;
end;

procedure tChainAction.Load(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  inherited Load(node,fmt);
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
      StrCopy(pc,opt_chain); id:=DBReadDWord(0,DBBranch,section);
//      StrCopy(pc,opt_actname); actname:=DBReadUnicode(0,DBBranch,section);
    end;
{
    1: begin
    end;
}
  end;
end;

procedure tChainAction.Save(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  inherited Save(node,fmt);
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
      StrCopy(pc,opt_chain); DBWriteDWord(0,DBBranch,section,id);
//      StrCopy(pc,opt_actname); DBWriteUnicode(0,DBBranch,section,actname);
    end;
{
    1: begin
    end;
}
  end;
end;

procedure tChainAction.Clear;
begin
  if (flags1 and ACF_BYNAME)<>0 then
    mFreeMem(actname);
  inherited Clear;
end;

//----- Dialog realization -----

procedure FillChainList(Dialog:hwnd);
var
  wnd:HWND;
  i,count:integer;
  ptr,ptr1:pChain;
begin
  wnd:=GetDlgItem(Dialog,IDC_GROUP_LIST);

  SendMessage(wnd,CB_RESETCONTENT,0,0);
  SendMessage(wnd,CB_SETITEMDATA,
    SendMessageW(wnd,CB_ADDSTRING,0,lparam(TranslateW(NoChainText))),0);

  count:=CallService(MS_ACT_GETLIST,0,TLPARAM(@ptr));
  if count>0 then
  begin
    ptr1:=ptr;
    inc(pbyte(ptr),4);
    for i:=0 to count-1 do
    begin
      if (ptr^.flags and (ACF_ASSIGNED or ACF_VOLATILE))=ACF_ASSIGNED then
      begin
        SendMessage(wnd,CB_SETITEMDATA,
          SendMessageW(wnd,CB_ADDSTRING,0,lparam(ptr^.descr)),ptr^.id);
      end;
    end;

    CallService(MS_ACT_FREELIST,0,TLPARAM(ptr1));
  end;
end;

function ActListChange(wParam:WPARAM;lParam:LPARAM):integer; cdecl;
var
  ptr,ptr1:pChain;
  count:integer;
begin
  result:=0;

  count:=CallService(MS_ACT_GETLIST,0,TLPARAM(@ptr));

  if count>0 then
  begin
    ptr1:=ptr;
    inc(pbyte(ptr),4);
    CallService(MS_ACT_FREELIST,0,TLPARAM(ptr1));
  end;

end;

procedure SelectGroup(Dialog:HWND;id:dword);
var
  i:integer;
  ptr,ptr1:pChain;
  count:integer;
  pc:pWideChar;
begin
  count:=CallService(MS_ACT_GETLIST,0,TLPARAM(@ptr));
  if count>0 then
  begin
    pc:=NoChainText;
    ptr1:=ptr;
    inc(pbyte(ptr),4);
    for i:=0 to count-1 do
    begin
      if ((ptr^.flags and (ACF_ASSIGNED or ACF_VOLATILE))=ACF_ASSIGNED) and
         (id=ptr^.id) then
      begin
        pc:=ptr^.descr;
        break;
      end;
    end;

    SendDlgItemMessageW(Dialog,IDC_GROUP_LIST,CB_SELECTSTRING,twparam(-1),tlparam(pc));
    CallService(MS_ACT_FREELIST,0,TLPARAM(ptr1));
    exit;
  end;
  SendDlgItemMessageW(Dialog,IDC_GROUP_LIST,CB_SELECTSTRING,twparam(-1),tlparam(NoChainText));
end;

function DlgProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
const
  onactchanged:THANDLE=0;

var
  i:integer;
  wnd:HWND;
begin
  result:=0;

  case hMessage of
    WM_DESTROY: begin
      UnhookEvent(onactchanged);
    end;

    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);

      FillChainList(Dialog);
      onactchanged:=HookEvent(ME_ACT_CHANGED,@ActListChange);
    end;

    WM_ACT_SETVALUE: begin
      with pChainAction(lParam)^ do
      begin
        if (flags1 and ACF_BYNAME)<>0 then
          SendDlgItemMessageW(Dialog,IDC_GROUP_LIST,CB_SELECTSTRING,twparam(-1),tlparam(actname))
        else
          SelectGroup(Dialog,id);
      end;
    end;

    WM_ACT_RESET: begin
      SendDlgItemMessage(Dialog,IDC_GROUP_LIST,CB_SETCURSEL,0,0);
    end;

    WM_ACT_SAVE: begin
      with pChainAction(lParam)^ do
      begin
        wnd:=GetDlgItem(Dialog,IDC_GROUP_LIST);
        i:=SendMessage(wnd,CB_GETCURSEL,0,0);
        if i>0 then
          id:=SendMessage(wnd,CB_GETITEMDATA,i,0)
        else
          id:=0;
      end;
    end;

{
    WM_COMMAND: begin
      case wParam shr 16 of
      end;
    end;
}
  end;
end;

//----- Export functions -----

function CreateAction:pBaseAction;
var
  tmp:pChainAction;
begin
  New(tmp);

  tmp.id     :=0;
  tmp.actname:=nil;

  result:=tmp;
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,'IDD_ACTCHAIN',parent,@DlgProc);
end;

//----- Interface part -----

var
  vc:tActModule;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :='Chain';
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;
  vc.Icon    :='IDI_CHAIN';

  ModuleLink :=@vc;
end;

begin
  Init;
end.
