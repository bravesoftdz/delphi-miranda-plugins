{Panel = group of icons}
const
  VolBtnDist = 6;
  BtnGap     = 3;
type
  pIcoGrpData = ^tIcoGrpData;
  tIcoGrpData = object(TObj)
    ShowVolume:bool;
    ButtonGap:bool;
    NeedResize:boolean;

    procedure GroupResize(Sender: PObj);
    procedure MouseDown(Sender:PControl;var Mouse:TMouseEventData);
  end;

procedure tIcoGrpData.GroupResize(Sender: PObj);
var
  i,lWidth,lOffs,gap:integer;
begin
  if NeedResize then
  begin
    NeedResize:=false;

    if ButtonGap then
      gap:=BtnGap
    else
      gap:=0;

    PControl(Sender)^.Children[0].Visible:=ShowVolume;
    PControl(Sender)^.Children[1].Visible:=ShowVolume;

    with PControl(Sender)^ do
    begin
      lWidth:=(ChildCount-2)*(16+gap)-gap;
      if ShowVolume then
        Inc(lWidth, VolBtnDist+2*(16+gap));
      Width:=lWidth;
      Left:=(Parent.Width-Width) div 2;
    end;

    lOffs:=0;
    if ShowVolume then
    begin
      PControl(Sender)^.Children[0].Left:=lOffs;
      Inc(lOffs,16+gap);
      PControl(Sender)^.Children[1].Left:=lOffs;
      Inc(lOffs,16+gap+VolBtnDist);
    end;

    for i:=2 to PControl(Sender)^.ChildCount-1 do
    begin
      PControl(Sender)^.Children[i].Left:=lOffs;
      Inc(lOffs,16+gap);
    end;

    NeedResize:=true;
  end;
end;

procedure TIcoGrpData.MouseDown(Sender:PControl;var Mouse:TMouseEventData);
var
  wnd:HWND;
begin
  wnd:=GetParent(GetParent(Sender.GetWindowHandle));
  SendMessage(wnd,WM_SYSCOMMAND,
     SC_MOVE or HTCAPTION,MAKELPARAM(Mouse.x,Mouse.y));
end;

procedure RefreshButtonIcons(Owner:PControl);
var
  D:pIcoBtnData;
  i:integer;
begin
  for i:=0 to Owner.ChildCount-1 do
  begin
    D:=pointer(Owner.Children[i].CustomObj);
    D.ico_normal.Handle:=GetIcon(D.action,AST_NORMAL);
    if D.ico_hovered<>nil then
      D.ico_hovered.Handle:=GetIcon(D.action,AST_HOVERED);
    if D.ico_pressed<>nil then
      D.ico_pressed.Handle:=GetIcon(D.action,AST_PRESSED);
  end;
  // refresh
end;

function MakeNewButtonGroup(AOwner:PControl;aVolume,aGap:bool):PControl;
var
  D:pIcoGrpData;
begin
  result:=NewPanel(AOwner,esNone);
  New(D, Create);
  with result^ do
  begin
    CustomObj:=D;
    Transparent:=true;

    SetSize(100,16);
    SetPosition(0,(AOwner.Top+AOwner.Height-18)-Height-2*BtnGap);
    Anchor(true,false,true,true); // good for button reposition

    OnResize   :=D.GroupResize;
    OnMouseDown:=D.MouseDown;

    D.NeedResize:=true;
  end;

  CreateIcoButton(result,WAT_CTRL_VOLDN,300);
  CreateIcoButton(result,WAT_CTRL_VOLUP,300);
  CreateIcoButton(result,WAT_CTRL_PREV,2000);
  CreateIcoButton(result,WAT_CTRL_PLAY);
  CreateIcoButton(result,WAT_CTRL_PAUSE);
  CreateIcoButton(result,WAT_CTRL_STOP);
  CreateIcoButton(result,WAT_CTRL_NEXT,2000);

  D.ShowVolume:=aVolume;
  D.ButtonGap :=aGap;
end;
