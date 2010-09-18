{Panel = group of icons}
const
  VolBtnDist = 6;
  BtnGap     = 3;
type
  pIcoGrpData = ^tIcoGrpData;
  tIcoGrpData = object(TObj)
    ShowVolume:bool;
    ButtonGap:bool;

    procedure GroupResize(Sender: PObj);
    procedure SaveSettings;
    procedure LoadSettings;
  end;

procedure tIcoGrpData.SaveSettings;
begin
end;

procedure tIcoGrpData.LoadSettings;
begin
end;

procedure tIcoGrpData.GroupResize(Sender: PObj);
var
  i,lWidth,lOffs,gap:integer;
begin
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
    Width:=lWidth; // reason to call this code twice
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
    OnResize:=D.GroupResize;
  end;

  CreateIcoButton(result,WAT_CTRL_VOLDN);
  CreateIcoButton(result,WAT_CTRL_VOLUP);
  CreateIcoButton(result,WAT_CTRL_PREV);
  CreateIcoButton(result,WAT_CTRL_PLAY);
  CreateIcoButton(result,WAT_CTRL_PAUSE);
  CreateIcoButton(result,WAT_CTRL_STOP);
  CreateIcoButton(result,WAT_CTRL_NEXT);

  D.ShowVolume:=aVolume;
  D.ButtonGap :=aGap;

end;
