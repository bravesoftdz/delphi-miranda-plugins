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
  end;

procedure tIcoGrpData.GroupResize(Sender: PObj);
var
  i,lWidth,lOffs,gap:integer;
begin
  if NeedResize then
  begin
    if PControl(Sender)^.ChildCount=0 then exit;

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

procedure RefreshButtonIcons(Owner:PControl);
var
  i:integer;
begin
  for i:=0 to Owner.ChildCount-1 do
  begin
    pIcoButton(Owner.Children[i]).RefreshIcon;
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
    OnMouseDown:=TOnMouse(MakeMethod(nil, @MouseDown));

    D.NeedResize:=true;
  end;

  CreateIcoButton(result,GetIcon,DoAction,WAT_CTRL_VOLDN,300);
  CreateIcoButton(result,GetIcon,DoAction,WAT_CTRL_VOLUP,300);
  CreateIcoButton(result,GetIcon,DoAction,WAT_CTRL_PREV,2000);
  CreateIcoButton(result,GetIcon,DoAction,WAT_CTRL_PLAY);
  CreateIcoButton(result,GetIcon,DoAction,WAT_CTRL_PAUSE);
  CreateIcoButton(result,GetIcon,DoAction,WAT_CTRL_STOP);
  CreateIcoButton(result,GetIcon,DoAction,WAT_CTRL_NEXT,2000);

  D.ShowVolume:=aVolume;
  D.ButtonGap :=aGap;
end;
