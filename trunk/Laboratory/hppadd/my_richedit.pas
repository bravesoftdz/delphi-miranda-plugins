unit my_richedit;

interface

uses
  Windows, Messages,
  hpp_richedit;

type
  PHPPRichEdit = ^THPPRichEdit;
  THPPRichEdit = record
    handle  : HWND;
    oldproc : pointer;
    IOle    : IRichEditOle;
    IBck    : TRichEditOleCallback;
    ITextDoc: ITextDocument;
    RTL     : Boolean;
  end;

function NewHPPRichEdit(parent:HWND):PHPPRichEdit;
procedure FreeHPPRichEdit(var RE:PHPPRichEdit);

implementation

uses
  RichEdit;

const
  EM_SETEDITSTYLE     = WM_USER + 204;
  SES_EXTENDBACKCOLOR = 4;
(*
function NewREProc(Dialog:HWnd;hMessage:UINT;wParam:WPARAM;lParam:LPARAM):lresult; stdcall;
var
  re:pHPPRichEdit;
  lptr:pointer;
begin
  if hMessage=WM_SIZE then
  begin
    SendMessage(Dialog,EM_REQUESTRESIZE, 0, 0 );
    result:=0;
  end
  else
  begin
    lptr:=pointer(GetWindowLongPtr(Dialog, GWL_USERDATA));
    result:=CallWindowProc(lptr{re.oldproc},Dialog,hMessage,wParam,lParam);
  end;
end;
*)
function NewHPPRichEdit(parent:HWND):PHPPRichEdit;
var
  wnd:HWND;
begin
  wnd:=CreateWindowExA(WS_EX_TRANSPARENT,RichEditClass, nil,
                     {WS_VISIBLE or} WS_CHILD
                     or WS_TABSTOP or WS_BORDER or ES_MULTILINE,
                     0,0,0,0, parent, 0, hInstance, nil);
  if wnd=0 then
  begin
    result:=nil;
    exit;
  end;

  GetMem(result,SizeOf(THPPRichEdit));
  FillChar(result^,SizeOf(THPPRichEdit),0);
  // 1 - create RTF window
  result.Handle:=wnd;

  SendMessage(result.Handle,EM_SETMARGINS   ,EC_LEFTMARGIN or EC_RIGHTMARGIN,0);
  SendMessage(result.Handle,EM_SETEDITSTYLE ,SES_EXTENDBACKCOLOR,SES_EXTENDBACKCOLOR);
  SendMessage(result.Handle,EM_SETOPTIONS   ,ECOOP_OR,ECO_AUTOWORDSELECTION);
  SendMessage(result.Handle,EM_AUTOURLDETECT,1,0);

  SendMessage(result.Handle, EM_SETEVENTMASK, 0,
    ENM_CHANGE or ENM_SELCHANGE or ENM_REQUESTRESIZE or
    ENM_PROTECTED or ENM_LINK or ENM_KEYEVENTS);

{
  Result.oldproc:=pointer(GetWindowLongPtrW(
          Result.Handle,GWL_WNDPROC));
  SetWindowLongPtrW(
          Result.Handle,GWL_USERDATA,LONG_PTR(Result.oldproc));
  SetWindowLongPtrW(
          Result.Handle,GWL_WNDPROC,LONG_PTR(@NewREProc));
}

(*
  // workaround of SmileyAdd making richedit visible all the time
  result^.Rich.Top     := -MaxInt;
  result^.Rich.Height  := -1;

*)
  // 2 - create OLE elements
  result.IBck:=TRichEditOleCallback.Create;
  RichEdit_SetOleCallback (result.Handle, result.IBck as IRichEditOleCallback);
  RichEdit_GetOleInterface(result.Handle, result.IOle);
  result.Iole.QueryInterface(ITextDocument,result.ITextDoc); //??
end;

{
procedure ReleaseObject(var Obj);
begin
  if IUnknown(Obj) <> nil then IUnknown(Obj) := nil;
end;

procedure THppRichedit.CloseObjects;
var
  i: Integer;
  ReObject: TReObject;
begin
  if Assigned(IOle) then
  begin
    ZeroMemory(@ReObject, SizeOf(ReObject));
    ReObject.cbStruct := SizeOf(ReObject);
    with IOle do
    begin
      for i := GetObjectCount - 1 downto 0 do
        if Succeeded(GetObject(i, ReObject, REO_GETOBJ_POLEOBJ)) then
        begin
          if (ReObject.dwFlags and REO_INPLACEACTIVE) <> 0 then
            IOle.InPlaceDeactivate;
          ReObject.poleobj.Close(OLECLOSE_NOSAVE);
          ReleaseObject(ReObject.poleobj);
        end;
    end;
  end;
end;
}

procedure FreeHPPRichEdit(var RE:PHPPRichEdit);
begin
  RE.IBck.Free;
  //RE.IBck._Release;

  //CloseObjects; //= Clear

  //ReleaseObject(RE.IOle); it means

  FreeMem(RE);
  RE:=nil;
end;

end.
