unit iac_;

interface

implementation

uses windows, iac_global, mirutils;


type
   = ^;
   = object(tBaseAction)

    function DoAction(var WorkData:tWorkData):int;
    procedure Save(node:pointer;fmt:integer);
    procedure Load(node:pointer;fmt:integer);
    procedure Clear;
  end;

//----- Support functions -----

//----- Object realization -----

procedure .Clear;
begin
end;

function .DoAction(var WorkData:tWorkData):int;
begin
  result:=0;
end;

procedure .Load(node:pointer;fmt:integer);
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

procedure .Save(node:pointer;fmt:integer);
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
      end;
    end;

    WM_HELP: begin
    end;

  end;
end;

//----- Export functions -----

function CreateAction:pBaseAction;
var
  tmp:;
begin
  New(tmp);
  tmp.OnAction:=tmp.DoAction;
  tmp.OnSave  :=tmp.Save;
  tmp.OnLoad  :=tmp.Load;
  tmp.OnClear :=tmp.Clear;

  tmp.contact:=0;

  result:=tmp;
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,,parent,@DlgProc);
end;

//----- Interface part -----

var
  vc:tActModule;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :=
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;

  ModuleLink :=@vc;
end;

begin
  Init;
end.
