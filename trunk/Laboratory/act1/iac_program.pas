unit iac_program;

interface

implementation

uses
  windows, messages,
  iac_global, m_api, wrapper, syswin,
  mirutils, common, dbsettings;

{$include i_cnst_program.inc}
{$resource iac_program.res}

const
  ACF_CURPATH  = $00000002; // Current (not program) path
  ACF_PRTHREAD = $00000004; // parallel Program

const
  ACF2_PRG_PRG  = $00000001;
  ACF2_PRG_ARG  = $00000002;

const
  opt_prg      = 'program';
  opt_args     = 'arguments';
  opt_time     = 'time';
  opt_show     = 'show';

type
  pProgramAction = ^tProgramAction;
  tProgramAction = object(tBaseAction)
    prgname:pWideChar;
    args   :pWideChar;
    show   :dword;
    time   :dword;

    function DoAction(var WorkData:tWorkData):int;
    procedure Save(node:pointer;fmt:integer);
    procedure Load(node:pointer;fmt:integer);
    procedure Clear;
  end;

//----- Support functions -----

function replany(var str:pWideChar;aparam:LPARAM;alast:pWideChar):boolean;
var
  buf:array [0..31] of WideChar;
  tmp:pWideChar;
begin
  if StrScanW(str,'<')<>nil then
  begin
    result:=true;
    mGetMem(tmp,2048);
    StrCopyW(tmp,str);
    StrReplaceW(tmp,'<param>',IntToStr(buf,aparam));
    StrReplaceW(tmp,'<last>' ,alast);

    str:=tmp;
  end
  else
    result:=false;
end;

//----- Object realization -----

procedure tProgramAction.Clear;
begin
  mFreeMem(prgname);
  mFreeMem(args);

  inherited Clear;
end;

function tProgramAction.DoAction(var WorkData:tWorkData):int;
var
  tmp,tmpp,lpath:PWideChar;
  replPrg ,replArg :PWideChar;
  replPrg1,replArg1:PWideChar;
  pd:LPARAM;
  vars1,vars2,prgs,argss:boolean;
  buf:array [0..31] of WideChar;
begin
  result:=0;

  if WorkData.ResultType=rtInt then
  begin
    StrDupW(pWideChar(WorkData.LastResult),IntToStr(buf,WorkData.LastResult));
    WorkData.ResultType:=rtWide;
  end;

  replPrg:=prgname;
  prgs   :=replany(replPrg,WorkData.Parameter,pWideChar(WorkData.LastResult));

  replArg:=args;
  argss  :=replany(replArg,WorkData.Parameter,pWideChar(WorkData.LastResult));

  if ((flags2 and ACF2_PRG_PRG)<>0) or
     ((flags2 and ACF2_PRG_ARG)<>0) then
  begin
    pd:=WndToContact(WaitFocusedWndChild(GetForegroundwindow){GetFocus});
    if (pd=0) and (CallService(MS_DB_CONTACT_IS,WorkData.Parameter,0)<>0) then
      pd:=WorkData.Parameter;
  end;

  if (flags2 and ACF2_PRG_ARG)<>0 then
  begin
    vars2:=true;
    tmp :=ParseVarString(replArg,pd,pWideChar(WorkData.LastResult));
  end
  else
  begin
    vars2:=false;
    tmp :=replArg;
  end;

  if (flags2 and ACF2_PRG_PRG)<>0 then
  begin
    vars1:=true;
    tmpp :=ParseVarString(replPrg,pd,pWideChar(WorkData.LastResult));
  end
  else
  begin
    vars1:=false;
    tmpp:=replPrg;
  end;
  
  if StrScanW(tmpp,'%')<>nil then
  begin
    mGetMem(replPrg1,8192*SizeOf(WideChar));
    ExpandEnvironmentStringsW(tmpp,replPrg1,8191);
    if vars1 then mFreeMem(tmpp);
    if prgs  then mFreeMem(replPrg);
    tmpp :=replPrg1;
    prgs :=false;
    vars1:=true;
  end;
  if StrScanW(tmp,'%')<>nil then
  begin
    mGetMem(replArg1,8192*SizeOf(WideChar));
    ExpandEnvironmentStringsW(tmp,replArg1,8191);
    if vars2 then mFreeMem(tmp);
    if argss then mFreeMem(replArg);
    tmp  :=replArg1;
    argss:=false;
    vars2:=true;
  end;

  if (flags1 and ACF_CURPATH)=0 then
    lpath:=ExtractW(tmpp,false)
  else
    lpath:=nil;

  if (flags1 and ACF_PRTHREAD)<>0 then
    time:=0
  else if time=0 then
    time:=INFINITE;
  WorkData.LastResult:=ExecuteWaitW(tmpp,tmp,lpath,show,time,@pd);
  WorkData.ResultType:=rtInt;

  if vars2 then mFreeMem(tmp);
  if vars1 then mFreeMem(tmpp);

  if prgs  then mFreeMem(replPrg);
  if argss then mFreeMem(replArg);

  mFreeMem(lpath);
end;

procedure tProgramAction.Load(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  inherited Load(node,fmt);
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
      StrCopy(pc,opt_prg ); prgname:=DBReadUnicode(0,DBBranch,section,nil);
      StrCopy(pc,opt_args); args   :=DBReadUnicode(0,DBBranch,section,nil);
      StrCopy(pc,opt_time); time   :=DBReadDWord  (0,DBBranch,section,0);
      StrCopy(pc,opt_show); show   :=DBReadDWord  (0,DBBranch,section,SW_SHOW);
    end;
{
    1: begin
    end;
}
  end;
end;

procedure tProgramAction.Save(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  inherited Save(node,fmt);
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
      StrCopy(pc,opt_prg ); DBWriteUnicode(0,DBBranch,section,prgname);
      StrCopy(pc,opt_args); DBWriteUnicode(0,DBBranch,section,args);
      StrCopy(pc,opt_time); DBWriteDWord  (0,DBBranch,section,time);
      StrCopy(pc,opt_show); DBWriteDWord  (0,DBBranch,section,show);
    end;
{
    1: begin
    end;
}
  end;
end;

//----- Dialog realization -----

procedure MakeFileEncList(wnd:HWND);
begin
  SendMessage(wnd,CB_RESETCONTENT,0,0);
{
  InsertString(wnd,0,'Ansi');
  InsertString(wnd,1,'UTF8');
  InsertString(wnd,2,'UTF8+sign');
  InsertString(wnd,3,'UTF16');
  InsertString(wnd,4,'UTF16+sign');
}
  SendMessage(wnd,CB_SETCURSEL,0,0);
end;

procedure ClearFields(Dialog:HWND);
begin
  SetDlgItemTextW(Dialog,IDC_EDIT_PROCTIME,nil);
  SetDlgItemTextW(Dialog,IDC_EDIT_PRGPATH,nil);
  SetDlgItemTextW(Dialog,IDC_EDIT_PRGARGS,nil);

  CheckDlgButton(Dialog,IDC_FLAG_NORMAL,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_FLAG_HIDDEN,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_FLAG_MINIMIZE,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_FLAG_MAXIMIZE,BST_UNCHECKED);

  CheckDlgButton(Dialog,IDC_FLAG_CURPATH,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_FLAG_CONTINUE,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_FLAG_PARALLEL,BST_UNCHECKED);

  CheckDlgButton(Dialog,IDC_PRG_PRG,BST_UNCHECKED);
  CheckDlgButton(Dialog,IDC_PRG_ARG,BST_UNCHECKED);
end;

procedure FillFileName(Dialog:HWND;idc:integer);
var
  pw,ppw:pWideChar;
begin
  mGetMem(pw,1024*SizeOf(WideChar));
  ppw:=GetDlgText(Dialog,idc);
  if ShowDlgW(pw,ppw) then
    SetDlgItemTextW(Dialog,idc,pw);
  mFreeMem(ppw);
  mFreeMem(pw);
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

      with pProgramAction(lParam)^ do
      begin
        if (flags2 and ACF2_PRG_PRG)<>0 then
          CheckDlgButton(Dialog,IDC_PRG_PRG,BST_CHECKED);
        if (flags2 and ACF2_PRG_ARG)<>0 then
          CheckDlgButton(Dialog,IDC_PRG_ARG,BST_CHECKED);

        SetDlgItemTextW(Dialog,IDC_EDIT_PRGPATH ,prgname);
        SetDlgItemTextW(Dialog,IDC_EDIT_PRGARGS ,args);
        SetDlgItemInt  (Dialog,IDC_EDIT_PROCTIME,time,false);
        case show of
          SW_HIDE         : CheckDlgButton(Dialog,IDC_FLAG_HIDDEN,BST_CHECKED);
          SW_SHOWMINIMIZED: CheckDlgButton(Dialog,IDC_FLAG_MINIMIZE,BST_CHECKED);
          SW_SHOWMAXIMIZED: CheckDlgButton(Dialog,IDC_FLAG_MAXIMIZE,BST_CHECKED);
        else
          {SW_SHOWNORMAL   :} CheckDlgButton(Dialog,IDC_FLAG_NORMAL,BST_CHECKED);
        end;
        if (flags1 and ACF_CURPATH)<>0 then
          CheckDlgButton(Dialog,IDC_FLAG_CURPATH,BST_CHECKED);
        if (flags1 and ACF_PRTHREAD)<>0 then
          CheckDlgButton(Dialog,IDC_FLAG_PARALLEL,BST_CHECKED)
        else
          CheckDlgButton(Dialog,IDC_FLAG_CONTINUE,BST_CHECKED);
      end;
    end;

    WM_ACT_RESET: begin
      ClearFields(Dialog);

      CheckDlgButton(Dialog,IDC_FLAG_PARALLEL,BST_CHECKED);
      CheckDlgButton(Dialog,IDC_FLAG_NORMAL,BST_CHECKED);
      SetDlgItemInt(Dialog,IDC_EDIT_PROCTIME,0,false);
    end;

    WM_ACT_SAVE: begin
      with pProgramAction(lParam)^ do
      begin
          prgname:=GetDlgText(Dialog,IDC_EDIT_PRGPATH);
  {
          p:=GetDlgText(IDC_EDIT_PRGPATH);
          if p<>nil then
          begin
            CallService(MS_UTILS_PATHTORELATIVE,dword(p),dword(@buf));
            StrDupW(prgname,@buf);
            mFreeMem(p);
          end;
  }
          args:=GetDlgText(Dialog,IDC_EDIT_PRGARGS);
          if IsDlgButtonChecked(Dialog,IDC_FLAG_PARALLEL)=BST_CHECKED then
            flags1:=flags1 or ACF_PRTHREAD;
          if IsDlgButtonChecked(Dialog,IDC_FLAG_CURPATH)=BST_CHECKED then
            flags1:=flags1 or ACF_CURPATH;
          time:=GetDlgItemInt(Dialog,IDC_EDIT_PROCTIME,pbool(nil)^,false);
          if IsDlgButtonChecked(Dialog,IDC_FLAG_MINIMIZE)=BST_CHECKED then
            show:=SW_SHOWMINIMIZED
          else if IsDlgButtonChecked(Dialog,IDC_FLAG_MAXIMIZE)=BST_CHECKED then
            show:=SW_SHOWMAXIMIZED
          else if IsDlgButtonChecked(Dialog,IDC_FLAG_HIDDEN)=BST_CHECKED then
            show:=SW_HIDE
          else //if IsDlgButtonChecked(Dialog,IDC_FLAG_NORMAL)=BST_CHECKED then
            show:=SW_SHOWNORMAL;

          if IsDlgButtonChecked(Dialog,IDC_PRG_PRG)=BST_CHECKED then
            flags2:=flags2 or ACF2_PRG_PRG;
          if IsDlgButtonChecked(Dialog,IDC_PRG_ARG)=BST_CHECKED then
            flags2:=flags2 or ACF2_PRG_ARG;
      end;
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        EN_CHANGE: begin
        end;

        BN_CLICKED: begin
          case loword(wParam) of
            IDC_PROGRAM: begin
              FillFileName(Dialog,IDC_EDIT_PRGPATH);
            end;
          end;
        end;
      end;
    end;

    WM_HELP: begin
      MessageBoxW(0,
        TranslateW('Text <last> replacing'#13#10+
          'by last result'#13#10#13#10+
          'Text <param> replacing'#13#10+
          'by parameter'),
        TranslateW('Text'),0);
    end;

  end;
end;

//----- Export functions -----

function CreateAction:pBaseAction;
var
  tmp:pProgramAction;
begin
  New(tmp);

  tmp.show   :=0;
  tmp.time   :=0;
  tmp.prgname:=nil;
  tmp.args   :=nil;

  result:=tmp;
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,'IDD_ACTPROGRAM',parent,@DlgProc);
end;

//----- Interface part -----

var
  vc:tActModule;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :='Program';
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;

  ModuleLink :=@vc;
end;

begin
  Init;
end.
