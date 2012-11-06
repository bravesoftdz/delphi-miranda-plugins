unit EditWrapper;

interface

uses windows;

function MakeEditField(Dialog:HWND; id:uint):HWND;
procedure SetEditFlags(Dialog:HWND; id:uint; flags:dword);

implementation

uses messages,commctrl,common,wrapper,m_api;

{$R editwrapper.res}
{$include 'i_text_const.inc'}

type
  pUserData = ^tUserData;
  tUserData = record
    SavedProc    :pointer;
    LinkedControl:HWND;
    flags        :dword;
  end;


// if need to change button text, will pass button (not edit field) handle as parameter
function EditWndProc(Dialog:HWnd;hMessage:uint;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  pc:pWideChar;
  btnwnd:HWND;
  ptr:pUserData;
  title:pWideChar;
begin
  result:=0;

  case hMessage of
    WM_DESTROY: begin
    end;

    WM_INITDIALOG: begin
      TranslateDialogDefault(Dialog);
      ptr:=pUserData(GetWindowLongPtrW(HWND(lParam),GWLP_USERDATA));

      pc:=GetDlgText(ptr^.LinkedControl);
      SetDlgItemTextW(Dialog,IDC_TEXT_EDIT,pc);
      mFreeMem(pc);

      SetWindowLongPtrW(Dialog,GWLP_USERDATA,lParam);
      CheckDlgButton(Dialog,IDC_TEXT_SCRIPT,ptr^.flags);
    end;

    WM_COMMAND: begin
      case wParam shr 16 of
        BN_CLICKED: begin
          case loword(wParam) of
            IDC_TEXT_WRAP: begin
            end;

            IDOK: begin
              pc:=GetDlgText(Dialog,IDC_TEXT_EDIT);
              btnwnd:=GetWindowLongPtrW(Dialog,GWLP_USERDATA);
              ptr:=pUserData(GetWindowLongPtrW(btnwnd,GWLP_USERDATA));

              if IsDlgButtonChecked(Dialog,IDC_TEXT_SCRIPT)<>BST_UNCHECKED then
              begin
                ptr^.flags:=1;
                title:='S';
              end
              else
              begin
                ptr^.flags:=0;
                title:='T';
              end;
              SendMessageW(btnwnd,WM_SETTEXT,0,tlParam(title));
              SendMessageW(ptr^.LinkedControl,WM_SETTEXT,0,tlParam(pc));
              mFreeMem(pc);

              EndDialog(Dialog,0);
            end;

            IDCANCEL: begin // clear result / restore old value
              EndDialog(Dialog,0);
            end;
          end;
        end;
      end;
    end;

    WM_NOTIFY: begin
      case integer(PNMHdr(lParam)^.code) of
        PSN_APPLY: begin
        end;
      end;
    end;
  end;
end;

//----- Edit button processing -----

function EditControlProc(Dialog:HWnd;hMessage:uint;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  oldproc:pointer;
  ptr:pUserData;
begin
  ptr:=pUserData(GetWindowLongPtrW(Dialog,GWLP_USERDATA));
  oldproc:=ptr^.SavedProc;

  case hMessage of
    WM_DESTROY: begin
      SetWindowLongPtrW(Dialog,GWLP_WNDPROC,long_ptr(oldproc));
      mFreeMem(ptr);
    end;

    WM_INITDIALOG: begin
    end;

    WM_LBUTTONDOWN: begin
      DialogBoxParamW(hInstance,'IDD_EDITCONTROL',GetParent(Dialog),@EditWndProc,Dialog);
      result:=0;
      exit;
    end;
  end;

  result:=CallWindowProc(oldproc,Dialog,hMessage,wParam,lParam)
end;

function MakeEditField(Dialog:HWND; id:uint):HWND;
var
  rc,rcp:TRECT;
  ctrl:HWND;
  pu:pUserData;
  title:pWideChar;
begin
  ctrl:=GetDlgItem(Dialog,id);
  GetWindowRect(ctrl,rc ); // screen coords
  GetWindowRect(Dialog ,rcp); // screen coords of parent

  if GetWindowLongPtrW(ctrl,GWLP_USERDATA)=0 then
    title:='T'
  else
    title:='S';

  result:=CreateWindowW('BUTTON',title,WS_CHILD+WS_VISIBLE+BS_PUSHBUTTON+BS_CENTER+BS_VCENTER,
          rc.left-rcp.left, rc.top-rcp.top+(rc.bottom-rc.top-16) div 2, 16,16,
          Dialog,0,hInstance,nil);
  if result<>0 then
  begin
    SetWindowLongPtrW(ctrl,GWLP_USERDATA,long_ptr(result));
    mGetMem(pu,SizeOf(tUserData));
    pu^.SavedProc:=pointer(SetWindowLongPtrW(result,GWL_WNDPROC,long_ptr(@EditControlProc)));
    pu^.LinkedControl:=ctrl;
    SetWindowLongPtrW(result,GWLP_USERDATA,long_ptr(pu));
    inc(rc.left,20);
    MoveWindow(ctrl,
      rc.left-rcp.left, rc.top-rcp.top, rc.right-rc.left, rc.bottom-rc.top,
      false);
  end;
end;

procedure SetEditFlags(Dialog:HWND; id:uint; flags:dword);
var
  ctrl:HWND;
  pu:pUserData;
begin
  ctrl:=GetWindowLongPtrW(GetDlgItem(Dialog,id),GWLP_USERDATA);
  pu:=pUserData(GetWindowLongPtrW(ctrl,GWLP_USERDATA));
  pu^.flags:=flags;
end;

end.
