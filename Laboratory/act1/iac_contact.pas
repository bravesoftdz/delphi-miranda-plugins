unit iac_contact;

interface

implementation

uses
  windows, messages,
  m_api, iac_global, common,
  contact,
  wrapper, mirutils, dbsettings;

{$include i_cnst_contact.inc}
{$resource iac_contact.res}

const
  ACF_KEEPONLY = $00000001; // keep contact handle in Last, don't show window

type
  tContactAction = class(tBaseAction)
    contact:THANDLE;

    constructor Create(uid:dword);
    function  Clone:tBaseAction;
    function  DoAction(var WorkData:tWorkData):LRESULT;
    procedure Save(node:pointer;fmt:integer);
    procedure Load(node:pointer;fmt:integer);
  end;

//----- Support functions -----

constructor tContactAction.Create(uid:dword);
begin
  inherited Create(uid);

  contact:=0;
end;

function tContactAction.Clone:tBaseAction;
begin
  result:=tContactAction.Create(0);
  Duplicate(result);

  tContactAction(result).contact:=contact;
end;

function OpenContact(hContact:THANDLE):THANDLE;
begin
  ShowContactDialog(hContact);
{
  if CallService(MS_DB_CONTACT_IS,hContact,0)<>0 then
  begin
    if ServiceExists(MS_MSG_CONVERS)<>0 then
    begin
      CallService(MS_MSG_CONVERS,hContact,0)
    end
    else
      CallService(MS_MSG_SENDMESSAGE,hContact,0)
  end;
}
  result:=hContact;
end;

//----- Object realization -----

function tContactAction.DoAction(var WorkData:tWorkData):LRESULT;
begin
  ClearResult(WorkData);

  if (flags and ACF_KEEPONLY)=0 then
    WorkData.LastResult:=OpenContact(contact)
  else
    WorkData.LastResult:=contact;

  WorkData.ResultType:=rtInt;

  result:=0;
end;

procedure tContactAction.Load(node:pointer;fmt:integer);
begin
  inherited Load(node,fmt);
  case fmt of
    0: contact:=LoadContact(DBBranch,node);
{
    1: begin
      if StrCmpW(tmp,ioContactWindow)=0 then
      begin
        actionType:=ACT_CONTACT;
        contact:=ImportContact(actnode);
  //      contact:=StrToInt(getAttrValue(actnode,ioNumber));
        if StrToInt(getAttrValue(actnode,ioKeepOnly))=1 then
          flags:=flags or ACF_KEEPONLY;
      end
    end;
}
  end;
end;

procedure tContactAction.Save(node:pointer;fmt:integer);
begin
  inherited Save(node,fmt);
  case fmt of
    0: SaveContact(contact,DBBranch,node);
{
    1: begin
        sub:=AddChild(actnode,ioContactWindow,nil);
        ExportContact(sub,contact);
//        AddAttrInt(sub,ioNumber,0); // contact
        if (flags and ACF_KEEPONLY)<>0 then AddAttrInt(sub,ioKeepOnly,1);
    end;
}
  end;
end;

//----- Dialog realization -----

var
  fCLfilter:byte;
  fCLformat:pWideChar;

function DlgProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  wnd:HWND;
  i:integer;
begin
  result:=0;

  case hMessage of
    WM_DESTROY: begin
      mFreeMem(fCLformat);
    end;

    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);

      fCLfilter:=DBReadByte   (0,DBBranch,'CLfilter',BST_UNCHECKED);
      fCLformat:=DBReadUnicode(0,DBBranch,'CLformat');
      FillContactList(GetDlgItem(Dialog,IDC_CONTACTLIST),fCLfilter<>BST_UNCHECKED,fCLformat);
    end;

    WM_ACT_SETVALUE: begin
      with tContactAction(lParam) do
      begin
        if (flags and ACF_KEEPONLY)<>0 then
          CheckDlgButton(Dialog,IDC_CNT_KEEP,BST_CHECKED);

        SendDlgItemMessage(Dialog,IDC_CONTACTLIST,CB_SETCURSEL,
          FindContact(GetDlgItem(Dialog,IDC_CONTACTLIST),contact),0);
      end;
    end;

    WM_ACT_RESET: begin
      CheckDlgButton(Dialog,IDC_CNT_KEEP,BST_UNCHECKED);

      CheckDlgButton(Dialog,IDC_CNT_FILTER,fCLfilter);
      SetDlgItemTextW(Dialog,IDC_EDIT_FORMAT,fCLformat);
    end;

    WM_ACT_SAVE: begin
      with tContactAction(lParam) do
      begin
        contact:=SendDlgItemMessage(Dialog,IDC_CONTACTLIST,CB_GETITEMDATA,
            SendDlgItemMessage(Dialog,IDC_CONTACTLIST,CB_GETCURSEL,0,0),0);
        if IsDlgButtonChecked(Dialog,IDC_CNT_KEEP)=BST_CHECKED then
          flags:=flags or ACF_KEEPONLY;
      end;
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        BN_CLICKED: begin
          case loword(wParam) of
            IDC_CNT_FILTER,
            IDC_CNT_APPLY: begin
              if loword(wParam)=IDC_CNT_APPLY then
              begin
                mFreeMem(fCLformat);
                fCLformat:=GetDlgText(Dialog,IDC_EDIT_FORMAT);
                DBWriteUnicode(0,DBBranch,'CLformat',fCLformat);
              end
              else
              begin
                fCLfilter:=IsDlgButtonChecked(Dialog,IDC_CNT_FILTER);
                DBWriteByte(0,DBBranch,'CLfilter',fCLfilter);
              end;
// Saving and restoring contact after list rebuild
              wnd:=GetDlgItem(Dialog,IDC_CONTACTLIST);
              i:=SendMessage(wnd,CB_GETITEMDATA,SendMessage(wnd,CB_GETCURSEL,0,0),0);

              FillContactList(wnd,fCLfilter<>BST_UNCHECKED,fCLformat);
              
              SendMessage(wnd,CB_SETCURSEL,FindContact(wnd,i),0);
            end;
          end;
        end;
      end;
    end;
  end;
end;

//----- Export/interface functions -----

var
  vc:tActModule;

function CreateAction:tBaseAction;
begin
  result:=tContactAction.Create(vc.Hash);
end;

function CreateDialog(parent:HWND):HWND;
begin
  result:=CreateDialogW(hInstance,'IDD_ACTCONTACT',parent,@DlgProc);
end;

procedure Init;
begin
  vc.Next    :=ModuleLink;

  vc.Name    :='Contact';
  vc.Dialog  :=@CreateDialog;
  vc.Create  :=@CreateAction;
  vc.Icon    :='IDI_CONTACT';

  ModuleLink :=@vc;
end;

begin
  Init;
end.
