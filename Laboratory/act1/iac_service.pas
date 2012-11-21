unit iac_service;

interface

implementation

uses
  windows, messages,
  iac_global,
  m_api,
  sedit,strans,
  mirutils,dbsettings,
  syswin,wrapper,common;

{$include i_cnst_service.inc}
{$resource iac_service.res}

const
  ACF_PARNUM  = $00000001; // Param is number
  ACF_UNICODE = $00000002; // Param is Unicode string
  ACF_CURRENT = $00000004; // Param is ignored, used current user handle
                           // from current message window
  ACF_RESULT  = $00000008; // Param is previous action result
  ACF_PARAM   = $00000010; // Param is Call parameter
  ACF_STRUCT  = $00000020;
  ACF_PARTYPE = ACF_PARNUM or ACF_UNICODE or ACF_CURRENT or ACF_PARAM or ACF_STRUCT;

  ACF_RSTRING  = $00010000; // Service result is string
  ACF_RUNICODE = $00020000; // Service result is Widestring
  ACF_RSTRUCT  = $00040000; // Service result in structure
  ACF_RFREEMEM = $00080000; // Need to free memory

  ACF_SCRIPT_PARAM   = $00001000;
  ACF_SCRIPT_SERVICE = $00002000;

const
  opt_service  = 'service';
  opt_wparam   = 'wparam';
  opt_lparam   = 'lparam';

type
  tServiceAction = class(tBaseAction)
    service:PAnsiChar;
    wparam :WPARAM;
    lparam :LPARAM;
    flags2 :dword;

    constructor Create(uid:dword);
    function  Clone:tBaseAction;
    function  DoAction(var WorkData:tWorkData):int;
    procedure Save(node:pointer;fmt:integer);
    procedure Load(node:pointer;fmt:integer);
    procedure Clear;
  end;

//----- Support functions -----

//----- Object realization -----

constructor tServiceAction.Create(uid:dword);
begin
  inherited Create(uid);
end;

function tServiceAction.Clone:tBaseAction;
begin
  result:=tServiceAction.Create(0);
  Duplicate(result);

  tServiceAction(result).flags2 :=flags2;
  StrDup(tServiceAction(result).service,service);

  if (flags and (ACF_PARNUM or ACF_RESULT or ACF_PARAM))=0 then
    StrDup(pAnsiChar(tServiceAction(result).wparam),pAnsiChar(wparam))
  else if ((flags and ACF_PARNUM)<>0) and ((flags and ACF_SCRIPT_PARAM)<>0) then
    StrDup(pAnsiChar(tServiceAction(result).wparam),pAnsiChar(wparam))
  else
    tServiceAction(result).wparam:=wparam;

  if (flags2 and (ACF_PARNUM or ACF_RESULT or ACF_PARAM))=0 then
    StrDup(pAnsiChar(tServiceAction(result).lparam),pAnsiChar(lparam))
  else if ((flags2 and ACF_PARNUM)<>0) and ((flags and ACF_SCRIPT_PARAM)<>0) then
    StrDup(pAnsiChar(tServiceAction(result).lparam),pAnsiChar(lparam))
  else
    tServiceAction(result).lparam:=lparam;
end;

procedure ClearParam(flags:dword; var param);
begin
  if (flags and (ACF_PARNUM or ACF_RESULT or ACF_PARAM))=0 then
    mFreeMem(pointer(param))
  else if ((flags and ACF_PARNUM)<>0) and ((flags and ACF_SCRIPT_PARAM)<>0) then
    mFreeMem(pointer(param));
end;

procedure tServiceAction.Clear;
begin
  mFreeMem(service);
  ClearParam(flags ,wparam);
  ClearParam(flags2,lparam);

  inherited Clear;
end;

procedure PreProcess(flags:dword;var l_param:LPARAM;var WorkData:tWorkData);
var
  tmp1:pWideChar;
begin
  with WorkData do
  begin
    if (flags and ACF_STRUCT)<>0 then
    begin
      l_param:=uint_ptr(MakeStructure(pAnsiChar(l_param),Parameter,LastResult,ResultType))
    end
    else if (flags and ACF_PARAM)<>0 then
    begin
      l_param:=Parameter;
    end
    else if (flags and ACF_RESULT)<>0 then
    begin
      l_param:=LastResult;
    end
    else if (flags and ACF_CURRENT)<>0 then
    begin
      l_param:=WndToContact(WaitFocusedWndChild(GetForegroundwindow){GetFocus});
    end
    else if (flags and ACF_SCRIPT_PARAM)<>0 then
    begin
      if (flags and ACF_PARNUM)=0 then
      begin
        if (flags and ACF_UNICODE)=0 then
          l_param:=uint_ptr(ParseVarString(pAnsiChar(l_param),Parameter))
        else
          l_param:=uint_ptr(ParseVarString(pWideChar(l_param),Parameter))
      end
      else
      begin
        tmp1:=ParseVarString(pWideChar(l_param),Parameter);
        l_param:=StrToInt(tmp1);
        mFreeMem(tmp1);
      end;
    end;
  end;
end;

procedure PostProcess(flags:dword;var l_param:LPARAM; var WorkData:tWorkData);
var
  code:integer;
  len:integer;
  pc:pAnsiChar;
begin
  if (flags and ACF_STRUCT)<>0 then
  begin
    with WorkData do
    begin
      LastResult:=GetStructureResult(l_param,@code,@len);
      case code of
{
        SST_LAST: begin
          result:=LastResult;
        end;
}
        SST_PARAM: begin //??
          LastResult:=Parameter;
          ResultType:=rtInt;
        end;
        SST_BYTE,SST_WORD,SST_DWORD,
        SST_QWORD,SST_NATIVE: begin
          ResultType:=rtInt;
        end;
        SST_BARR: begin
          StrDup(pAnsiChar(pc),pAnsiChar(LastResult),len);
          AnsiToWide(pAnsiChar(pc),PWideChar(LastResult),MirandaCP);
          mFreeMem(pAnsiChar(pc));
          ResultType:=rtWide;
        end;
        SST_WARR: begin
          StrDupW(pWideChar(LastResult),pWideChar(LastResult),len);
          ResultType:=rtWide;
        end;
        SST_BPTR: begin
          AnsiToWide(pAnsiChar(LastResult),pWideChar(LastResult),MirandaCP);
          ResultType:=rtWide;
        end;
        SST_WPTR: begin
          StrDupW(pWideChar(LastResult),pWideChar(LastResult));
          ResultType:=rtWide;
        end;
      end;
      FreeStructure(l_param);
      l_param:=0;
    end
  end;
end;

function tServiceAction.DoAction(var WorkData:tWorkData):int;
var
  buf:array [0..255] of AnsiChar;
  lservice:pAnsiChar;
  lwparam,llparam:TLPARAM;
  res:int_ptr;
begin
  result:=0;

  lservice:=service;
  lwparam :=wparam;
  llparam :=lparam;
  // Service name processing
  if (flags and ACF_SCRIPT_SERVICE)<>0 then
    lservice:=ParseVarString(lservice,WorkData.Parameter);
    
  StrCopy(buf,lservice);
  if StrPos(lservice,protostr)<>nil then
    if CallService(MS_DB_CONTACT_IS,WorkData.Parameter,0)=0 then
    begin
      if (flags and ACF_SCRIPT_SERVICE)<>0 then
        mFreeMem(lservice);
      exit;
    end
    else
      StrReplace(buf,protostr,GetContactProtoAcc(WorkData.Parameter));

  if ServiceExists(buf)<>0 then
  begin

    PreProcess(flags ,lwparam,WorkData);
    PreProcess(flags2,llparam,WorkData);

    res:=CallServiceSync(buf,lwparam,llparam);
    ClearResult(WorkData);

    // result type processing
    if (flags and ACF_RSTRING)<>0 then
    begin
//!! delete old or not?
      if (flags and ACF_RUNICODE)=0 then
      begin
        AnsiToWide(pAnsiChar(res),pWideChar(WorkData.LastResult),MirandaCP);
        if (flags and ACF_RFREEMEM)<>0 then
          mFreeMem(pAnsiChar(res)); //?? Miranda MM??
      end
      //??
      else if (flags and ACF_RFREEMEM)=0 then
        StrDupW(pWideChar(WorkData.LastResult),pWideChar(res));
      WorkData.ResultType:=rtWide;
    end
    else if (flags and ACF_RSTRUCT)=0 then
      WorkData.ResultType:=rtInt
    else if (flags and ACF_RSTRUCT)<>0 then
    begin
      PostProcess(flags ,lwparam,WorkData);
      PostProcess(flags2,llparam,WorkData);
    end;
    // if parameters replaced through variables
    if ((flags and ACF_SCRIPT_PARAM)<>0) and
       ((flags and ACF_PARNUM  )=0 ) then
      mFreeMem(pointer(lwparam));
    if ((flags2 and ACF_SCRIPT_PARAM)<>0) and
       ((flags2 and ACF_PARNUM  )=0 ) then
      mFreeMem(pointer(llparam));
  end;
  if (flags and ACF_SCRIPT_SERVICE)<>0 then
    mFreeMem(lservice);
end;

function LoadNumValue(setting:pAnsiChar;isvar:boolean):uint_ptr;
begin
  if isvar then
    result:=uint_ptr(DBReadUnicode(0,DBBranch,setting,nil))
  else
    result:=DBReadDWord(0,DBBranch,setting);
end;

procedure LoadParam(section:PAnsiChar;flags:dword; var param:pointer);
begin
  if (flags and (ACF_CURRENT or ACF_RESULT or ACF_PARAM))=0 then
  begin
    if (flags and ACF_PARNUM)<>0 then
      param:=pointer(LoadNumValue(section,(flags and ACF_SCRIPT_PARAM)<>0))

    else if (flags and ACF_STRUCT)<>0 then
      param:=DBReadUTF8(0,DBBranch,section,nil)

    else if (flags and ACF_UNICODE)<>0 then
      param:=DBReadUnicode(0,DBBranch,section,nil)

    else
      param:=DBReadString (0,DBBranch,section,nil);
  end;
end;

procedure tServiceAction.Load(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  inherited Load(node,fmt);

  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));

      StrCopy(pc,opt_service); service:=DBReadString(0,DBBranch,section,nil);

      StrCopy(pc,opt_wparam); LoadParam(section,flags ,pointer(wparam));
      StrCopy(pc,opt_lparam); LoadParam(section,flags2,pointer(lparam));
    end;
{
    1: begin
    end;
}
  end;
end;

procedure SaveNumValue(setting:pAnsiChar;value:uint_ptr;isvar:boolean);
begin
  if isvar then
    DBWriteUnicode(0,DBBranch,setting,pWideChar(value))
  else
    DBWriteDWord  (0,DBBranch,setting,value);
end;

procedure SaveParam(section:PAnsiChar;flags:dword; param:pointer);
begin
  if (flags and (ACF_CURRENT or ACF_RESULT or ACF_PARAM))=0 then
  begin
    if (flags and ACF_PARNUM)<>0 then
      SaveNumValue(section,uint_ptr(param),(flags and ACF_SCRIPT_PARAM)<>0)

    else if pointer(param)<>nil then
    begin
      if (flags and ACF_STRUCT)<>0 then
        DBWriteUTF8(0,DBBranch,section,param)

      else if (flags and ACF_UNICODE)<>0 then
        DBWriteUnicode(0,DBBranch,section,param)

      else
        DBWriteString(0,DBBranch,section,param);
    end;
  end;
end;

procedure tServiceAction.Save(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  inherited Save(node,fmt);

  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));

      StrCopy(pc,opt_service); DBWriteString(0,DBBranch,section,service);

      StrCopy(pc,opt_wparam); SaveParam(section,flags ,pointer(wparam));
      StrCopy(pc,opt_lparam); SaveParam(section,flags2,pointer(lparam));
    end;
{
    1: begin
    end;
}
  end;
end;

//----- Dialog realization -----

const
  ptNumber  = 0;
  ptString  = 1;
  ptUnicode = 2;
  ptCurrent = 3;
  ptResult  = 4;
  ptParam   = 5;
  ptStruct  = 6;
const
  sresInt    = 0;
  sresHex    = 1;
  sresString = 2;
  sresStruct = 3;

procedure MakeResultTypeList(wnd:HWND);
begin
  SendMessage(wnd,CB_RESETCONTENT,0,0);
  InsertString(wnd,sresInt   ,'Integer');
  InsertString(wnd,sresHex   ,'Hexadecimal');
  InsertString(wnd,sresString,'String');
  InsertString(wnd,sresStruct,'Structure');
  SendMessage(wnd,CB_SETCURSEL,0,0);
end;

procedure MakeParamTypeList(wnd:HWND);
begin
  SendMessage(wnd,CB_RESETCONTENT,0,0);
  InsertString(wnd,ptNumber ,'number value');
  InsertString(wnd,ptString ,'ANSI string');
  InsertString(wnd,ptUnicode,'Unicode string');
  InsertString(wnd,ptCurrent,'current contact');
  InsertString(wnd,ptResult ,'last result');
  InsertString(wnd,ptParam  ,'parameter');
  InsertString(wnd,ptStruct ,'structure');
  SendMessage(wnd,CB_SETCURSEL,0,0);
end;

procedure ClearFields(Dialog:HWND);
begin
  SetDlgItemTextW(Dialog,IDC_EDIT_SERVICE,nil);
  SetDlgItemTextW(Dialog,IDC_EDIT_WPAR,nil);
  SetDlgItemTextW(Dialog,IDC_EDIT_LPAR,nil);

  EnableWindow(GetDlgItem(Dialog,IDC_EDIT_WPAR),true);
  SendMessage (GetDlgItem(Dialog,IDC_EDIT_WPAR),CB_RESETCONTENT,0,0);
  EnableWindow(GetDlgItem(Dialog,IDC_EDIT_LPAR),true);
  SendMessage (GetDlgItem(Dialog,IDC_EDIT_LPAR),CB_RESETCONTENT,0,0);
//    SendDlgItemMessage(Dialog,IDC_FLAG_WPAR,CB_SETCURSEL,0,0);
//    SendDlgItemMessage(Dialog,IDC_FLAG_LPAR,CB_SETCURSEL,0,0);
  CB_SelectData(GetDlgItem(Dialog,IDC_FLAG_WPAR),ptNumber);
  CB_SelectData(GetDlgItem(Dialog,IDC_FLAG_LPAR),ptNumber);

  CB_SelectData(GetDlgItem(Dialog,IDC_SRV_RESULT),sresInt);

  CheckDlgButton(Dialog,IDC_RES_FREEMEM,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_RES_UNICODE,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_RES_SIGNED ,BST_UNCHECKED);

  CB_SelectData(Dialog,IDC_SRV_RESULT,sresInt);
end;

function DlgProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
begin
  result:=0;

  case hMessage of
    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);
    end;

    WM_ACT_SETVALUE: begin
      ClearFields(Dialog);
{
          if SendDlgItemMessageA(Dialog,IDC_EDIT_SERVICE,CB_SELECTSTRING,twparam(-1),tlparam(service))<>CB_ERR then
            ReloadService
          else
            SetDlgItemTextA(Dialog,IDC_EDIT_SERVICE,service);

          if (flags2 and ACF2_SRV_WPAR)<>0 then ButtonOn(IDC_SRV_WPAR);
          if (flags2 and ACF2_SRV_LPAR)<>0 then ButtonOn(IDC_SRV_LPAR);
          if (flags2 and ACF2_SRV_SRVC)<>0 then ButtonOn(IDC_SRV_SRVC);

          if (flags and ACF_MESSAGE)<>0 then ButtonOn(IDC_RES_MESSAGE);
          if (flags and ACF_POPUP  )<>0 then ButtonOn(IDC_RES_POPUP);
          if (flags and ACF_INSERT )<>0 then ButtonOn(IDC_RES_INSERT);

          if (flags and ACF_HEX)<>0 then
            i:=sresHex
          else if (flags and ACF_STRUCT)<>0 then
            i:=sresStruct
          else if (flags and ACF_STRING)<>0 then
          begin
            i:=sresString;
            if (flags  and ACF_UNICODE )<>0 then ButtonOn(IDC_RES_UNICODE);
            if (flags2 and ACF2_FREEMEM)<>0 then ButtonOn(IDC_RES_FREEMEM);
          end
          else
          begin
            i:=sresInt;
            if (flags and ACF_SIGNED)<>0 then
              ButtonOn(IDC_RES_SIGNED);
          end;
          CB_SelectData(Dialog,IDC_SRV_RESULT,i);

          if (flags and ACF_WPARAM)<>0 then
          begin
            EnableWindow(GetDlgItem(Dialog,IDC_EDIT_WPAR),false);
            i:=ptParam;
          end
          else if (flags and ACF_WRESULT)<>0 then
          begin
            EnableWindow(GetDlgItem(Dialog,IDC_EDIT_WPAR),false);
            i:=ptResult;
          end
          else if (flags and ACF_WPARNUM)<>0 then
          begin
            if (flags and ACF_WCURRENT)<>0 then
            begin
              EnableWindow(GetDlgItem(Dialog,IDC_EDIT_WPAR),false);
              i:=ptCurrent
            end
            else
            begin
              i:=ptNumber;
              SetNumValue(GetDlgItem(Dialog,IDC_EDIT_WPAR),wparam,
                  (flags2 and ACF2_SRV_WPAR)<>0,
                  (flags2 and ACF2_SRV_WHEX)<>0);
//              SetDlgItemInt(Dialog,IDC_EDIT_WPAR,wparam,true)
            end;
          end
          else if (flags and ACF_WSTRUCT)<>0 then
          begin
            i:=ptStruct;
            SHControl(IDC_EDIT_WPAR,SW_HIDE);
            SHControl(IDC_WSTRUCT  ,SW_SHOW);
            mFreeMem(wstruct);
            StrDup(wstruct,PAnsiChar(wparam));
          end
          else if (flags and ACF_WUNICODE)<>0 then
          begin
            i:=ptUnicode;
            SetDlgItemTextW(Dialog,IDC_EDIT_WPAR,pWideChar(wparam));
          end
          else
          begin
            i:=ptString;
            SetDlgItemTextA(Dialog,IDC_EDIT_WPAR,PAnsiChar(wparam));
          end;
          CB_SelectData(GetDlgItem(Dialog,IDC_FLAG_WPAR),i);
          SendDlgItemMessage(Dialog,IDC_FLAG_WPAR,CB_SETCURSEL,i,0);

          if (flags and ACF_LPARAM)<>0 then
          begin
            EnableWindow(GetDlgItem(Dialog,IDC_EDIT_LPAR),false);
            i:=ptParam;
          end
          else if (flags and ACF_LRESULT)<>0 then
          begin
            EnableWindow(GetDlgItem(Dialog,IDC_EDIT_LPAR),false);
            i:=ptResult;
          end
          else if (flags and ACF_LPARNUM)<>0 then
          begin
            if (flags and ACF_LCURRENT)<>0 then
            begin
              EnableWindow(GetDlgItem(Dialog,IDC_EDIT_LPAR),false);
              i:=ptCurrent;
            end
            else
            begin
              i:=ptNumber;
              SetNumValue(GetDlgItem(Dialog,IDC_EDIT_LPAR),lparam,
                  (flags2 and ACF2_SRV_LPAR)<>0,
                  (flags2 and ACF2_SRV_LHEX)<>0);
//              SetDlgItemInt(Dialog,IDC_EDIT_LPAR,lparam,true)
            end;
          end
          else if (flags and ACF_LSTRUCT)<>0 then
          begin
            i:=ptStruct;
            SHControl(IDC_EDIT_LPAR,SW_HIDE);
            SHControl(IDC_LSTRUCT  ,SW_SHOW);
            mFreeMem(lstruct);
            StrDup(lstruct,PAnsiChar(lparam));
          end
          else if (flags and ACF_LUNICODE)<>0 then
          begin
            i:=ptUnicode;
            SetDlgItemTextW(Dialog,IDC_EDIT_LPAR,pWideChar(lparam));
          end
          else
          begin
            i:=ptString;
            SetDlgItemTextA(Dialog,IDC_EDIT_LPAR,PAnsiChar(lparam));
          end;
          CB_SelectData(GetDlgItem(Dialog,IDC_FLAG_LPAR),i);

}
    end;

    WM_ACT_RESET: begin
      ClearFields(Dialog);
    end;

    WM_ACT_SAVE: begin
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        EN_CHANGE: begin
        end;
      end;
    end;

    WM_HELP: begin
    end;

  end;
end;

//----- Export/interface functions -----

var
  vc:tActModule;

function CreateAction:tBaseAction;
begin
  result:=tServiceAction.Create(vc.Hash);
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,'IDD_ACTSERVICE',parent,@DlgProc);
end;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :='Service';
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;

  ModuleLink :=@vc;
end;

begin
  Init;
end.
