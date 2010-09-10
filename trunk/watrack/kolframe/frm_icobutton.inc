{}
type
  pIcoButton = ^tIcoButton;
  tIcoButton = object(TControl)
    x: integer;
    y: integer;
    ico_normal :PIcon;
    ico_hover  :PIcon;
    ico_pressed:PIcon;

    destructor Destroy; virtual;
  end;

destructor tIcoButton.Destroy;
begin
  ico_normal.Destroy;
  if ico_hover  <>nil then ico_hover  .Destroy;
  if ico_pressed<>nil then ico_pressed.Destroy;
  inherited;
end;

function WndProcIcoButton( Sender: PControl; var Msg: TMsg; var Rslt:Integer ): boolean;
var
  k:HDC;
  PaintStruct: TPaintStruct;
begin
//  D:=Pointer(Sender.CustomObj);
  Result:=false;
  case msg.message of
{
    WM_CREATE : begin
      If D.f_image.Handle<>0 then 
      SetWindowRgn(Msg.hwnd,BitmapToRegion(D.f_image.Handle,D.ts_color), True);
    end;
}
    WM_PAINT: begin
      k:=Msg.wParam;
      if k=0 then k:= BeginPaint(Sender.Handle, PaintStruct);
//      D.f_image.Draw(k,0,0);
      if Msg.wParam=0 then EndPaint(Sender.Handle, PaintStruct);
      Result:=True;
    end;
{
    WM_DRAWITEM: begin
    end;
}
    WM_LBUTTONDBLCLK,
    WM_LBUTTONDOWN : begin  // Change from normal to pressed
{
      Sender.SetPosition(Sender.Position.X-2,Sender.Position.Y-2);
      Sender.Update;
      Sender.Parent.Update;
}
    end;

    WM_LBUTTONUP: begin // Change from pressed to normal
{
      Sender.SetPosition(sender.Position.X+2,sender.Position.Y+2);
      Sender.Update;
      Sender.Parent.Update;
}
    end;
  end;
end;

// variant - through remap array by number
// one way more - to fill ico handles at start (hicon - can b cnhanged, so - hIcoLib)
function CreateIcoButton(AOwner: PControl; normal,hover,pressed:pAnsiChar):pIcoButton;
var
  ico:HICON;
begin
  Result:=pIcoButton(_NewControl( AOwner, 'BUTTON',
                      WS_CHILD or WS_VISIBLE or
                      BS_USERBUTTON or BS_CHECKBOX or
                      BS_DEFPUSHBUTTON, False, nil ));
  Result.AttachProc(WndProcIcoButton);
  Result.ico_normal:=NewIcon;
  Result.ico_normal.Size     :=16;
  Result.ico_normal.Handle   :=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(normal));
  Result.ico_normal.ShareIcon:=true;

  ico:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(hover));
  if ico<>0 then
  begin
    Result.ico_hover:=NewIcon;
    Result.ico_hover.Size     :=16;
    Result.ico_hover.Handle   :=ico;
    Result.ico_hover.ShareIcon:=true;
  end;
  ico:=PluginLink^.CallService(MS_SKIN2_GETICON,0,dword(pressed));
  if ico<>0 then
  begin
    Result.ico_pressed:=NewIcon;
    Result.ico_pressed.Size     :=16;
    Result.ico_pressed.Handle   :=ico;
    Result.ico_pressed.ShareIcon:=true;
  end;
end;
