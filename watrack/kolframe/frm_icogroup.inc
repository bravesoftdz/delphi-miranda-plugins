{Panel = group of icons}
const
  VolBtnDist = 6;
  BtnGap     = 3;
type
  pIcoGrpData = ^tIcoGrpData;
  tIcoGrpData = object(TObj)
    procedure GroupResize(Sender: PObj);
    procedure SaveSettings;
    procedure LoadSettings;
  end;

procedure ShowHideVolBtn;
begin
end;

procedure tIcoGrpData.SaveSettings;
begin
end;

procedure tIcoGrpData.LoadSettings;
begin
  ButtonGap   :=DBReadByte (0,PluginShort,opt_ButtonGap ,BST_UNCHECKED);
end;

procedure tIcoGrpData.GroupResize(Sender: PObj);
var
  i,lWidth,lOffs,gap:integer;
begin
  if scGap in ShowControls then
    gap:=BtnGap
  else
    gap:=0;
  with PControl(Sender)^ do
  begin
    lWidth:=(ChildCount-2)*(16+gap)-gap;
    if scVolume in ShowControls  then
      Inc(lWidth, VolBtnDist+2*(16+gap));
    Width:=lWidth; // reson to call this code twice
    Left:=(Parent.Width-Width) div 2;
  end;

  lOffs:=0;
  if scVolume in ShowControls then
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

function MakeNewButtonGroup(AOwner:PControl):PControl;
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

  include(ShowControls,scVolume);

  with CreateIcoButton(result,WAT_CTRL_VOLDN)^ do
  begin
  end;
  with CreateIcoButton(result,WAT_CTRL_VOLUP)^ do
  begin
  end;
  with CreateIcoButton(result,WAT_CTRL_PREV)^ do
  begin
  end;
  with CreateIcoButton(result,WAT_CTRL_PLAY)^ do
  begin
  end;
  with CreateIcoButton(result,WAT_CTRL_PAUSE)^ do
  begin
  end;
  with CreateIcoButton(result,WAT_CTRL_STOP)^ do
  begin
  end;
  with CreateIcoButton(result,WAT_CTRL_NEXT)^ do
  begin
  end;

end;
