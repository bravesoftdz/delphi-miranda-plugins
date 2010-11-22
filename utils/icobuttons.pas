unit IcoButtons;

interface

uses KOL;

const
  AST_NORMAL  = 0;
  AST_HOVERED = 1;
  AST_PRESSED = 2;

type
  tGetIconProc = function(action:integer;stat:integer):cardinal;
  tActionProc  = function(action:integer):integer;

type
  pIcoBtnData = ^tIcoBtnData;
  tIcoBtnData = object(TObj)
  private
    rptvalue:cardinal;
    rpttimer:cardinal;

    pGetIcon : tGetIconProc;
    pDoAction: tActionProc;
    
  public
    ico_normal :PIcon;
    ico_hovered:PIcon;
    ico_pressed:PIcon;
    active     :PIcon; // one of ico_*

    action:integer;

    destructor Destroy; virtual;
    procedure MouseEnter(Sender: PObj);
    procedure MouseLeave(Sender: PObj);
    procedure CtrlBtnClick(Sender: PObj);

    property GetIcon : tGetIconProc read pGetIcon  write pGetIcon;
    property DoAction: tActionProc  read pDoAction write pDoAction;
  end;

function CreateIcoButton(AOwner: PControl; GetIconProc:tGetIconProc;
         ActionProc:tActionProc; action:integer; repeattime:integer=0):PControl;

implementation

uses windows, messages;

procedure tIcoBtnData.CtrlBtnClick(Sender: PObj);
var
  D: PIcoBtnData;
begin
  D:=Pointer(PControl(Sender).CustomObj);
  D.DoAction(D.action);
end;

procedure tIcoBtnData.MouseEnter(Sender: PObj);
var
  D: PIcoBtnData;
begin
  D:=Pointer(PControl(Sender).CustomObj);
  if D.ico_hovered<>nil then
  begin
    D.active:=D.ico_hovered;
    PControl(Sender).Update;
//    PControl(Sender).Parent.Update; //??
  end;
end;

procedure tIcoBtnData.MouseLeave(Sender: PObj);
var
  D: PIcoBtnData;
begin
  D:=Pointer(PControl(Sender).CustomObj);
  if D.active=D.ico_hovered then //!!!! for case when mouse button pressed and mouse moved
    D.active:=D.ico_normal;
  PControl(Sender).Update;
//  PControl(Sender).Parent.Update; //??
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
      D.CtrlBtnClick(Sender);
    end;

    WM_LBUTTONDBLCLK,
    WM_LBUTTONDOWN : begin  // Change from normal to pressed

      if D.ico_pressed<>nil then
        D.active:=D.ico_pressed
      else
        Sender.SetPosition(Sender.Position.X-2,Sender.Position.Y-2);
      Sender.Update;
//      Sender.Parent.Update;

      if D.rptvalue<>0 then
      begin
        D.rpttimer:=SetTimer(Sender.GetWindowHandle,1,D.rptvalue,nil);
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
        // mouse still above button?
        if (D.ico_hovered<>nil) and PtInRect(Sender.BoundsRect,tp) then
          D.active:=D.ico_hovered
        else
          D.active:=D.ico_normal;
      end
      else
        Sender.SetPosition(sender.Position.X+2,sender.Position.Y+2);
      Sender.Update;
//      Sender.Parent.Update;

    end;
  end;
end;

function CreateIcoButton(AOwner: PControl; GetIconProc:tGetIconProc;
         ActionProc:tActionProc; action:integer; repeattime:integer=0):PControl;
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

  D.GetIcon :=GetIconProc;
  D.DoAction:=ActionProc;

  D.ico_normal:=NewIcon;
  D.ico_normal.ShareIcon:=true;
  D.ico_normal.Handle   :=D.GetIcon(action,AST_NORMAL);
  D.active:=D.ico_normal;

  ico:=D.GetIcon(action,AST_HOVERED);
  if ico<>0 then
  begin
    D.ico_hovered:=NewIcon;
    D.ico_hovered.ShareIcon:=true;
    D.ico_hovered.Handle   :=ico;
  end
  else
    D.ico_hovered:=nil;
  ico:=D.GetIcon(action,AST_PRESSED);
  if ico<>0 then
  begin
    D.ico_pressed:=NewIcon;
    D.ico_pressed.ShareIcon:=true;
    D.ico_pressed.Handle   :=ico;
  end
  else
    D.ico_pressed:=nil;

  Result.SetSize(16,16);
  Result.SetPosition(0,0);
  Result.AttachProc(WndProcIcoButton);
end;

end.