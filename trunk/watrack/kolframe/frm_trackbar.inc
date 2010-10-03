{Trackbar}
type
  pAWKTrackbar = ^tAWKTrackbar;
  tAWKTrackbar = object(TObj)
    total:integer;
    UpdInterval:integer;

    procedure CtrlResize(Sender: PObj);
    procedure Erase(Sender: PControl; DC: HDC);
    procedure Paint(Sender: PControl; DC: HDC);
    procedure Scroll(Sender:PTrackbar; Code:Integer);
    procedure PressButton  (Sender: PControl;var Mouse: TMouseEventData);
    procedure UnPressButton(Sender: PControl;var Mouse: TMouseEventData);
    procedure DragButton   (Sender: PControl;var Mouse: TMouseEventData);
  end;

procedure TrackbarSetRange(Trackbar:PTrackbar;timer:integer;total:integer=-1);
var
  D:pAWKTrackbar;
  lpercent:real;
begin
  with Trackbar^ do
  begin
    D:=pointer(CustomObj);
    if total<0 then // changing timer only
    begin
      total:=D.total;
      if RangeMax>0 then
        lpercent:=position/RangeMax
      else
        lpercent:=0;
    end
    else            // for new track
    begin
      D.total:=total;
      lpercent:=0;
    end;
    D.UpdInterval:=timer;
    total:=(total*1000) div timer;
    RangeMax:=total;
    LineSize:=total div 100;
    PageSize:=total div 10;
    Position:=round(lpercent*total);
  end;
end;

procedure SetTrackbarPosition(Trackbar:PTrackbar;pos:integer);
var
  D: PIcoBtnData;
begin
  D:=Pointer(Trackbar.Children[0].CustomObj); // slider
  if D.active<>D.ico_pressed then
    Trackbar.Position:=pos;

  Trackbar.Update;
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
  CallService(MS_WAT_PRESSBUTTON,WAT_CTRL_SEEK,
    Cardinal(D.action)*pAWKTrackbar(Sender.Parent.CustomObj).UpdInterval div 1000);
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

procedure tAWKTrackbar.Scroll(Sender:PTrackbar; Code:Integer);
begin
  if code=TB_ENDTRACK then
  begin
    CallService(MS_WAT_PRESSBUTTON,WAT_CTRL_SEEK,
      Cardinal(Sender.Position)*pAWKTrackbar(Sender.CustomObj).UpdInterval div 1000);
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
  if Sender.ChildCount>0 then
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
  New(D, Create);
  result:=NewTrackbar(AOwner,[trbNoTicks,trbBoth,trbNoBorder],D.Scroll);

  with result^ do
  begin
    CustomObj:=D;
    SetSize(AOwner.Width-16,18);
    SetPosition(AOwner.Left+8,AOwner.Top+AOwner.Height-18);
    Anchor(true,false,true,true);
    ThumbLen:=16;

    RangeMin:=0;
    RangeMax:=100;

    OnResize    :=D.CtrlResize;
    OnEraseBkGnd:=D.Erase;
    OnPaint     :=D.Paint;
//    OnScroll    :=D.Scroll;
  end;

  with CreateIcoButton(result,WAT_CTRL_SEEK)^ do
  begin
    OnClick:=nil;
    OnMouseDown:=D.PressButton;
    OnMouseUp  :=D.UnPressButton;
    OnMouseMove:=D.DragButton;
  end;

end;
