unit iac_dbrw;

interface

implementation

uses
  windows, messages,
  iac_global,
  m_api,dbsettings,
  common,mirutils;

{$include i_cnst_database.inc}
{$resource iac_database.res}

const
  ACF_DBWRITE  = $00000001; // write to (not read from) DB 
  ACF_DBBYTE   = $00000002; // read/write byte (def. dword)
  ACF_DBWORD   = $00000004; // read/write word (def. dword)
  ACF_PARAM    = $00000008; // hContact from parameter
  ACF_CURRENT  = $00000010; // hContact is 0 (user settings)
  ACF_RESULT   = $00000020; // hContact is last result value
  ACF_LAST     = $00000040; // use last result for DB writing
  ACF_DBUTEXT  = $00000080; // read/write Unicode string
  ACF_DBANSI   = $00000082; // read/write ANSI string
  ACF_DBDELETE = $00000100; // delete setting
  ACF_NOCNTCT  = ACF_PARAM or ACF_CURRENT or ACF_RESULT;

  ACF_RW_MVAR  = $00000001;
  ACF_RW_SVAR  = $00000002;
  ACF_RW_TVAR  = $00000004;
  ACF_RW_HEX   = $00000008;

type
  tDataBaseAction = class(tBaseAction)
    dbcontact:THANDLE;
    dbmodule :PAnsiChar;
    dbsetting:PAnsiChar;
    dbvalue  :uint_ptr;

    constructor Create(uid:dword);
    function  Clone:tBaseAction;
    function  DoAction(var WorkData:tWorkData):int;
    procedure Save(node:pointer;fmt:integer);
    procedure Load(node:pointer;fmt:integer);
    procedure Clear;
  end;

//----- Support functions -----

//----- Object realization -----

constructor tDataBaseACtion.Create(uid:dword);
begin
  inherited Create(uid);

  dbcontact:=0;
  dbmodule :=nil;
  dbsetting:=nil;
  dbvalue  :=0;
end;

function CreateAction:tBaseAction;
var
  tmp:tDataBaseAction;
begin
  New(tmp);

  tmp.dbcontact:=dbcontact;
  StrDup(tmp.dbmodule ,dbmodule);
  StrDup(tmp.dbsetting,dbsetting);
  if (flags and (or ACF_RW_TVAR))<>0 then
  else
    tmp.dbvalue:=dbvalue;

  result:=tmp;
end;

procedure tDataBaseAction.Clear;
begin
  mFreeMem(dbmodule);
  mFreeMem(dbsetting);
  if (flags and ACF_DBUTEXT)<>0 then
    mFreeMem(dbvalue)
  else if (flags and ACF_RW_TVAR)<>0 then
    mFreeMem(dbvalue);

  inherited Clear;
end;

function DBRW(hContact:THANDLE;avalue:uint_ptr;var WorkData:tWorkData):uint_ptr;
var
  buf ,buf1 :array [0..127] of AnsiChar;
  sbuf:array [0..127] of AnsiChar;
  module,setting:pAnsiChar;
  tmp:pWideChar;
  tmpa,tmpa1:pAnsichar;
begin
  module :=dbmodule;
  setting:=dbsetting;

  if WorkData.ResultType=rtWide then
    FastWideToAnsiBuf(pWideChar(WorkData.LastResult),@sbuf)
  else
    IntToStr(sbuf,WorkData.LastResult);

  if (flags and ACF_RW_MVAR)<>0 then module :=ParseVarString(module ,hContact,sbuf);
  if (flags and ACF_RW_SVAR)<>0 then setting:=ParseVarString(setting,hContact,sbuf);
  StrCopy(buf,module);
  StrReplace(buf,protostr,GetContactProtoAcc(hContact));

  StrReplace(buf,'<last>',sbuf);
  StrCopy(buf1,setting);
  StrReplace(buf1,'<last>',sbuf);

  if (flags and ACF_RW_TVAR)<>0 then
    pWideChar(avalue):=ParseVarString(pWideChar(avalue),hContact,@sbuf);

  if ((flags  and ACF_DBUTEXT)=0) and
     ((flags and ACF_RW_TVAR)<>0) then
  begin
    tmp:=pWideChar(avalue);
    avalue:=StrToInt(tmp);
    mFreeMem(tmp);
  end;

  if (flags and ACF_DBDELETE)<>0 then
  begin
    result:=DBDeleteSetting(hContact,buf,setting);
  end
  else if (flags and ACF_DBWRITE)<>0 then
  begin
    if (flags and ACF_DBANSI)=ACF_DBANSI then
    begin
      WideToAnsi(pWideChar(avalue),tmpa,MirandaCP);
      DBWriteString(hContact,buf,buf1,tmpa);
      mFreeMem(tmpa);
      if (flags and ACF_RW_TVAR)=0 then
        StrDupW(pWideChar(avalue),pWideChar(avalue));
    end
    else if (flags and ACF_DBBYTE )=ACF_DBBYTE then DBWriteByte(hContact,buf,setting,avalue)
    else if (flags and ACF_DBWORD )=ACF_DBWORD then DBWriteWord(hContact,buf,setting,avalue)
    else if (flags and ACF_DBUTEXT)=ACF_DBUTEXT then
    begin
      DBWriteUnicode(hContact,buf,buf1,pWideChar(avalue));
      if (flags and ACF_RW_TVAR)=0 then
        StrDupW(pWideChar(avalue),pWideChar(avalue));
    end
    else DBWriteDWord(hContact,buf,setting,avalue);

    result:=avalue;
  end
  else
  begin
    if (flags and ACF_DBANSI)=ACF_DBANSI then
    begin
      WideToAnsi(pWideChar(avalue),tmpa1,MirandaCP);
      tmpa:=DBReadString(hContact,buf,buf1,tmpa1);
      AnsiToWide(tmpa,PWideChar(result),MirandaCP);
      mFreeMem(tmpa1);
      mFreeMem(tmpa);

      if (flags and ACF_RW_TVAR)<>0 then
        mFreeMem(avalue);
    end
    else if (flags and ACF_DBBYTE )=ACF_DBBYTE then result:=DBReadByte(hContact,buf,setting,avalue)
    else if (flags and ACF_DBWORD )=ACF_DBWORD then result:=DBReadWord(hContact,buf,setting,avalue)
    else if (flags and ACF_DBUTEXT)=ACF_DBUTEXT then
    begin
      result:=uint_ptr(DBReadUnicode(hContact,buf,buf1,pWideChar(avalue)));
      if (flags and ACF_RW_TVAR)<>0 then
        mFreeMem(avalue);
    end
    else result:=DBReadDWord(hContact,buf,setting,avalue);

  end;
  if (flags and ACF_RW_MVAR)<>0 then mFreeMem(module);
  if (flags and ACF_RW_SVAR)<>0 then mFreeMem(setting);
end;

function tDataBaseAction.DoAction(var WorkData:tWorkData):int;
var
  i,val:uint_ptr;
  buf:array [0..31] of WideChar;
begin
  result:=0;

  if      (flags and ACF_CURRENT)<>0 then i:=0
  else if (flags and ACF_PARAM  )<>0 then i:=WorkData.Parameter
  else if (flags and ACF_RESULT )<>0 then i:=WorkData.LastResult
  else
    i:=dbcontact;
  if (flags and ACF_LAST)=0 then
    val:=dbvalue
  else
  begin
    val:=WorkData.LastResult;
    if (flags and ACF_DBUTEXT)<>0 then
    begin
      if WorkData.ResultType=rtInt then
        val:=uint_ptr(IntToStr(buf,val));
    end
    else
    begin
      if WorkData.ResultType=rtWide then
        val:=StrToInt(pWideChar(val));
    end;
  end;

  val:=DBRW(i,val,WorkData);
  ClearResult(WorkData);
  WorkData.LastResult:=val;

  if (flags and ACF_DBUTEXT)<>0 then
    WorkData.ResultType:=rtWide
  else
    WorkData.ResultType:=rtInt;
end;

procedure tDataBaseAction.Load(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
    end;
{
    1: begin
    end;
}
  end;
end;

procedure tDataBaseAction.Save(node:pointer;fmt:integer);
var
  section: array [0..127] of AnsiChar;
  pc:pAnsiChar;
begin
  case fmt of
    0: begin
      pc:=StrCopyE(section,pAnsiChar(node));
    end;
{
    1: begin
    end;
}
  end;
end;

//----- Dialog realization -----

procedure ClearFields(Dialog:HWND);
begin
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
  result:=tDataBaseAction.Create(vc.Hash);
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,'IDD_ACTDATABASE',parent,@DlgProc);
end;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :='Database';
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;

  ModuleLink :=@vc;
end;

begin
  Init;
end.
