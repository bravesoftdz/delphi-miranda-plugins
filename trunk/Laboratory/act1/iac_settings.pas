unit iac_settings;

interface

implementation

uses
   windows, messages,
  iac_global, dlgshare,
  m_api, mirutils, dbsettings, common, wrapper;

{$include i_cnst_settings.inc}
{$resource iac_settings.res}


//----- Support functions -----


//----- Dialog realization -----

procedure ClearFields(Dialog:HWND);
begin
  CheckDlgButton(Dialog,IDC_CNT_FILTER,BST_UNCHECKED);
  SetDlgItemTextW(Dialog,IDC_EDIT_FORMAT,'');
end;

function DlgProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  fCLformat:pWideChar;
begin
  result:=0;

  case hMessage of
    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);

      OptSetButtonIcon(GetDlgItem(Dialog,IDC_CNT_APPLY),ACI_APPLY);
    end;

    WM_ACT_SETVALUE: begin
      ClearFields(Dialog);
    end;

    WM_ACT_RESET: begin
      ClearFields(Dialog);

      CheckDlgButton (Dialog,IDC_CNT_FILTER,DBReadByte(0,DBBranch,'CLfilter',BST_UNCHECKED));
      fCLformat:=DBReadUnicode(0,DBBranch,'CLformat');
      SetDlgItemTextW(Dialog,IDC_EDIT_FORMAT,fCLformat);
      mFreeMem(fCLformat);
    end;

    WM_ACT_SAVE: begin
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        BN_CLICKED: begin
          case loword(wParam) of
            IDC_CNT_APPLY: begin
              fCLformat:=GetDlgText(Dialog,IDC_EDIT_FORMAT);
              DBWriteUnicode(0,DBBranch,'CLformat',fCLformat);
              mFreeMem(fCLformat);
            end;

            IDC_CNT_FILTER: begin
              DBWriteByte(0,DBBranch,'CLfilter',IsDlgButtonChecked(Dialog,IDC_CNT_FILTER));
            end;

          end;
        end;
      end;
    end;

    WM_HELP: begin
      result:=1;
    end;

  end;
end;

//----- Export/interface functions -----

var
  vc:tActModule;

function CreateAction:tBaseAction;
begin
  result:=nil;
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,'IDD_SETTINGS',parent,@DlgProc);
end;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :='Settings';
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;
  vc.Icon    :='IDI_SETTINGS';
  vc.Hash    :=1;

  ModuleLink :=@vc;
end;

begin
  Init;
end.
