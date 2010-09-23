{Buttons}
type
  pIcoBtnData = ^tIcoBtnData;
  tIcoBtnData = object(TObj)
    ico_normal :PIcon;
    ico_hovered:PIcon;
    ico_pressed:PIcon;

    action:integer;
    active:PIcon; // one of ico_*

    rptvalue:cardinal;
    rpttimer:cardinal;

    destructor Destroy; virtual;
    procedure MouseEnter(Sender: PObj);
    procedure MouseLeave(Sender: PObj);
    procedure CtrlBtnClick(Sender: PObj);
  end;

procedure tIcoBtnData.CtrlBtnClick(Sender: PObj);
var
  D: PIcoBtnData;
begin
  D:=Pointer(PControl(Sender).CustomObj);
  CallService(MS_WAT_PRESSBUTTON,D.action,0);
end;

procedure tIcoBtnData.MouseEnter(Sender: PObj);
var
  D: PIcoBtnData;
begin
  D:=Pointer(PControl(Sender).CustomObj);
  D.active:=D.ico_hovered;
  PControl(Sender).Update;
  PControl(Sender).Parent.Update;
end;

procedure tIcoBtnData.MouseLeave(Sender: PObj);
var
  D: PIcoBtnData;
begin
  D:=Pointer(PControl(Sender).CustomObj);
  if D.active=D.ico_hovered then //!!!! for case when mouse button pressed and mouse moved
    D.active:=D.ico_normal;
  PControl(Sender).Update;
  PControl(Sender).Parent.Update;
end;

destructor tIcoBtnData.Destroy;
begin
  ico_normal.Free;
  if ico_hovered<>nil then ico_hovered.Free;
  if ico_pressed<>nil then ico_pressed.Free;

  inherited;
end;

function WndProcIcoButton( Sender: PControl; var Msg: TMsg; var Rslt:Integer ): boolean;
var
  k:HDC;
  PaintStruct: TPaintStruct;
  D: PIcoBtnData;
  tp:TPOINT;
begin
  D:=Pointer(Sender.CustomObj);
  Result:=false;
  case msg.message of

    WM_PAINT: begin
      k:=Msg.wParam;
      if k=0 then k:= BeginPaint(Sender.Handle, PaintStruct);
      D.active.Draw(k,0,0);
      if Msg.wParam=0 then EndPaint(Sender.Handle, PaintStruct);
      Result:=True;
    end;

    WM_TIMER: begin
      CallService(MS_WAT_PRESSBUTTON,D.action,0);
    end;

    WM_LBUTTONDBLCLK,
    WM_LBUTTONDOWN : begin  // Change from normal to pressed

      if D.ico_pressed<>nil then
        D.active:=D.ico_pressed
      else
        Sender.SetPosition(Sender.Position.X-2,Sender.Position.Y-2);
      Sender.Update;
      Sender.Parent.Update;

      if D.rptvalue<>0 then
      begin
        D.rpttimer:=SetTimer(Sender.GetWindowHandle,1,D.rptvalue,0);
      end;
    end;

    WM_LBUTTONUP: begin // Change from pressed to normal

      if D.rpttimer<>0 then
      begin
        KillTimer(0,D.rpttimer);
        D.rpttimer:=0;
      end;

      if D.ico_pressed<>nil then
      begin
        tp.X:=Loword(msg.LParam);
        tp.Y:=msg.LParam shr 16;
        if PtInRect(Sender.BoundsRect,tp) then  //!! mouse still above button?
          D.active:=D.ico_hovered
        else
          D.active:=D.ico_normal;
      end
      else
        Sender.SetPosition(sender.Position.X+2,sender.Position.Y+2);
      Sender.Update;
      Sender.Parent.Update;

    end;
  end;
end;

function IcoButtonChanged(wParam:WPARAM;lParam:LPARAM):int;cdecl;
begin
end;

// variant - through remap array by number
// one way more - to fill ico handles at start (hicon - can b cnhanged, so - hIcoLib)
function CreateIcoButton(AOwner: PControl; action:integer; repeattime:integer=0):PControl;
var
  ico:HICON;
  D: PIcoBtnData;
begin
  Result:=NewBitBtn(AOwner,'',[bboNoBorder,bboNoCaption],glyphOver,0,0);
  Result.LikeSpeedButton.Flat:=true;
  Result.Transparent:=true;

  New(D, Create);
  Result.CustomObj:=D;

  Result.OnMouseEnter:=D.MouseEnter;
  Result.OnMouseLeave:=D.MouseLeave;
  Result.OnClick     :=D.CtrlBtnClick;

  D.action  :=action;
  D.rptvalue:=repeattime;
  D.rpttimer:=0;

  D.ico_normal:=NewIcon;
  D.ico_normal.ShareIcon:=true;
  D.ico_normal.Handle   :=GetIcon(action,AST_NORMAL);
  D.active:=D.ico_normal;

  ico:=GetIcon(action,AST_HOVERED);
  if ico<>0 then
  begin
    D.ico_hovered:=NewIcon;
    D.ico_hovered.ShareIcon:=true;
    D.ico_hovered.Handle   :=ico;
  end;
  ico:=GetIcon(action,AST_PRESSED);
  if ico<>0 then
  begin
    D.ico_pressed:=NewIcon;
    D.ico_pressed.ShareIcon:=true;
    D.ico_pressed.Handle   :=ico;
  end;

  Result.SetSize(16,16);
  Result.SetPosition(0,0);
  Result.AttachProc(WndProcIcoButton);
end;
