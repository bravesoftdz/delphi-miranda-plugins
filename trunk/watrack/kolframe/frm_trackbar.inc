{Trackbar}
type
  pAWKTrackbar = ^tAWKTrackbar;
  tAWKTrackbar = object(TObj)
    procedure CtrlResize(Sender: PObj);
    procedure Erase(Sender: PControl; DC: HDC);
    procedure Paint(Sender: PControl; DC: HDC);
    procedure PressButton  (Sender: PControl;var Mouse: TMouseEventData);
    procedure UnPressButton(Sender: PControl;var Mouse: TMouseEventData);
    procedure DragButton   (Sender: PControl;var Mouse: TMouseEventData);
  end;

function CoordToPos(Trackbar:PTrackbar;x:integer):integer;
var
  range:integer;
  rmin,rmax:integer;
  offsetthumb,width:integer;
  rc:TRect;
begin
  rmin:=Trackbar.RangeMin;
  rmax:=Trackbar.RangeMax;
  range:=rmax-rmin; // logic width

  offsetthumb:=Trackbar.ThumbLen div 2;

  rc:=Trackbar.ChannelRect;
  width:= (rc.right-rc.left)-(offsetthumb*2)-1;
  result:=(range*(x-rc.left-offsetthumb)) div width;

  inc(result,rmin);
  if result>rmax then
    result:=rmax
  else if result<rmin then
    result:=rmin;
end;

procedure tAWKTrackbar.PressButton(Sender: PControl;var Mouse: TMouseEventData);
var
  D: PIcoBtnData;
begin
  D:=Pointer(Sender.CustomObj);
  D.action:=PTrackbar(Sender.Parent).Position;
end;

procedure tAWKTrackbar.UnPressButton(Sender: PControl;var Mouse: TMouseEventData);
var
  D: PIcoBtnData;
begin
  D:=Pointer(Sender.CustomObj);
  D.action:=-1;
end;

procedure tAWKTrackbar.DragButton(Sender: PControl;var Mouse: TMouseEventData);
var
  D: PIcoBtnData;
  pos:integer;
begin
  D:=Pointer(Sender.CustomObj);
  if D.active=D.ico_pressed then
  begin
    pos:=CoordToPos(PTrackbar(Sender.Parent),Sender.Left+Mouse.X);
    if D.action<>pos then
    begin
      D.action:=pos;
      PTrackbar(Sender.Parent).Position:=pos;
    end;
  end;
end;

procedure tAWKTrackbar.CtrlResize(Sender: PObj);
var
  tmp:integer;
begin
  tmp:=PControl(Sender).Parent.Width-16;
  if (PTrackbar(Sender)^.Width)>tmp then
    PTrackbar(Sender)^.Width:=tmp;
end;

procedure tAWKTrackbar.Erase(Sender: PControl; DC: HDC);
begin
end;

procedure tAWKTrackbar.Paint(Sender: PControl; DC: HDC);
var
  rc, rc1:TRECT;
  w:integer;
begin
  SendMessage(Sender.Handle,TBM_GETTHUMBRECT,0,dword(@rc));

  w:=rc.right-rc.left;
  if w<>16 then
    rc.left:=rc.left+(w div 2)-8;

  copyRect(rc1,Sender.BoundsRect);
  rc1.Top:=((rc1.Bottom-rc1.Top) div 2)-2;
  rc1.Bottom:=rc1.Top+4;
  DrawEdge(DC,rc1,EDGE_SUNKEN,BF_RECT or BF_ADJUST);
  Sender.Children[0].Left:=rc.Left;
end;

procedure RefreshTrackbarIcons(Owner:PControl);
var
  D:pIcoBtnData;
begin
  D:=Pointer(Owner.Children[0].CustomObj);
  D.ico_normal.Handle:=GetIcon(D.action,AST_NORMAL); // WAT_CTRL_SEEK
  if D.ico_hovered<>nil then
    D.ico_hovered.Handle:=GetIcon(D.action,AST_HOVERED);
  if D.ico_pressed<>nil then
    D.ico_pressed.Handle:=GetIcon(D.action,AST_PRESSED);
  // refresh
end;

function MakeNewTrackBar(AOwner:PControl):PTrackbar;
var
  D:pAWKTrackbar;
begin
  result:=NewTrackbar(AOwner,[trbNoTicks,trbBoth,trbNoBorder],nil);
  New(D, Create);
  with result^ do
  begin
    CustomObj:=D;
    SetPosition(AOwner.Left+8,AOwner.Top+AOwner.Height-18);
    SetSize(AOwner.Width-16,18);
    Anchor(true,false,true,true);
    ThumbLen:=16;

    RangeMin:=0;
    RangeMax:=100;

    OnResize    :=D.CtrlResize;
    OnEraseBkGnd:=D.Erase;
    OnPaint     :=D.Paint;
  end;

  with CreateIcoButton(result,WAT_CTRL_SEEK)^ do
  begin
    OnClick:=nil;
    OnMouseDown:=D.PressButton;
//    OnMouseUp  :=D.UnPressButton;
    OnMouseMove:=D.DragButton;
  end;
end;
