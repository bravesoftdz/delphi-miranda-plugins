unit iac_chain;

interface

implementation

uses
  windows, messages, commctrl,
  global, iac_global, mirutils, m_api,
  dlgshare,lowlevel,common,dbsettings, wrapper;

{$include m_actman.inc}
{$include i_cnst_chain.inc}
{$resource iac_chain.res}

const
  ACF_BYNAME  = $00000001; // Address action link by name, not Id
  ACF_NOWAIT  = $00000002; // Don't wait execution result, continue
  ACF_KEEPOLD = $00000004; // Don't change LastResult value

const
  opt_chain = 'chain';
//  opt_actname = 'actname';
const
  NoChainText:PWideChar = 'not defined';

type
  tChainAction = class(tBaseAction)
    id     :dword;
    actname:pWideChar;

    constructor Create(uid:dword);
    destructor Destroy; override;
//    function  Clone:tBaseAction; override;
    function  DoAction(var WorkData:tWorkData):LRESULT; override;
    procedure Save(node:pointer;fmt:integer); override;
    procedure Load(node:pointer;fmt:integer); override;
  end;

//----- Support functions -----

//----- Object realization -----

constructor tChainAction.Create(uid:dword);
begin
  inherited Create(uid);

  id     :=0;
  actname:=nil;
end;

destructor tChainAction.Destroy;
begin
  if (flags and ACF_BYNAME)<>0 then
    mFreeMem(actname);

  inherited Destroy;
end;
{
function tChainAction.Clone:tBaseAction;
begin
  result:=tChainAction.Create(0);
  Duplicate(result);

  tChainAction(result).id:=id;
  StrDupW(tChainAction(result).actname,actname);
end;
}
function tChainAction.DoAction(var WorkData:tWorkData):LRESULT;
var
  params:tAct_Param;
begin
  result:=0;

  if (flags and ACF_BYNAME)<>0 then
  begin
    params.flags:=ACTP_BYNAME;
    params.id   :=uint_ptr(actname);
  end
  else
  begin
    params.flags:=0;
    params.id   :=id;
  end;
  if (flags and ACF_NOWAIT)=0 then
    params.flags:=params.flags or ACTP_WAIT;

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

//----- Dialog realization -----

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

procedure FillChainList(Dialog:hwnd);
var
  wnd,list:HWND;
  i:integer;

  li:LV_ITEMW;
  Macro:pMacroRecord;
begin
  wnd:=GetDlgItem(Dialog,IDC_MACRO_LIST);

  SendMessage(wnd,CB_RESETCONTENT,0,0);
  SendMessage(wnd,CB_SETITEMDATA,
    SendMessageW(wnd,CB_ADDSTRING,0,lparam(TranslateW(NoChainText))),0);

  list:=MacroListWindow;
  li.mask      :=LVIF_PARAM;
  li.iSubItem  :=0;
  for i:=0 to SendMessage(list,LVM_GETITEMCOUNT,0,0)-1 do
  begin
    li.iItem:=i;
    SendMessageW(list,LVM_GETITEMW,0,tlparam(@li));
    Macro:=@(EditMacroList^[li.lParam]);
    SendMessage(wnd,CB_SETITEMDATA,
        SendMessageW(wnd,CB_ADDSTRING,0,lparam(@(Macro.descr))),Macro.id);
  end;

end;

function DlgProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
const
  onactchanged:THANDLE=0;

var
  tmp:dword;
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
      with tChainAction(lParam) do
      begin
        if (flags and ACF_BYNAME)<>0 then
          SendDlgItemMessageW(Dialog,IDC_MACRO_LIST,CB_SELECTSTRING,twparam(-1),tlparam(actname))
        else
          CB_SelectData(Dialog,IDC_MACRO_LIST,id);
        if (flags and ACF_NOWAIT)<>0 then
          CheckDlgButton(Dialog,IDC_MACRO_NOWAIT,BST_CHECKED);
        if (flags and ACF_KEEPOLD)<>0 then
          CheckDlgButton(Dialog,IDC_MACRO_KEEPOLD,BST_CHECKED);
      end;
    end;

    WM_ACT_RESET: begin
      SendDlgItemMessage(Dialog,IDC_MACRO_LIST,CB_SETCURSEL,0,0);
      CheckDlgButton(Dialog,IDC_MACRO_NOWAIT ,BST_UNCHECKED);
      CheckDlgButton(Dialog,IDC_MACRO_KEEPOLD,BST_UNCHECKED);
    end;

    WM_ACT_SAVE: begin
      with tChainAction(lParam) do
      begin
        id:=CB_GetData(GetDlgItem(Dialog,IDC_MACRO_LIST));

        if IsDlgButtonChecked(Dialog,IDC_MACRO_NOWAIT)<>BST_UNCHECKED then
          flags:=flags or ACF_NOWAIT;
        if IsDlgButtonChecked(Dialog,IDC_MACRO_KEEPOLD)<>BST_UNCHECKED then
          flags:=flags or ACF_KEEPOLD;
      end;
    end;

    WM_ACT_LISTCHANGE: begin
      if wParam=1 then
      begin
        wnd:=GetDlgItem(Dialog,IDC_MACRO_LIST);
        tmp:=CB_GetData(wnd);
        FillChainList(Dialog);
        CB_SelectData(wnd,tmp);
      end;
    end;
	
    WM_COMMAND: begin
      case wParam shr 16 of
        CBN_SELCHANGE,
        BN_CLICKED: SendMessage(GetParent(GetParent(Dialog)),PSM_CHANGED,0,0);
      end;
    end;

    WM_HELP: begin
      result:=1;
    end;
  end;
//  result:=DefWindowProc(Dialog,hMessage,wParam,lParam);
end;

//----- Export/interface functions -----

var
  vc:tActModule;

function CreateAction:tBaseAction;
begin
  result:=tChainAction.Create(vc.Hash);
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,'IDD_ACTCHAIN',parent,@DlgProc);
end;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :='Chain';
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;
  vc.Icon    :='IDI_CHAIN';
  vc.Hash    :=0;

  ModuleLink :=@vc;
end;

begin
  Init;
end.
