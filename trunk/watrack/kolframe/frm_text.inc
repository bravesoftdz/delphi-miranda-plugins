{Text}

const
  opt_FrmTxtClr :PAnsiChar = 'frame/frametextcolor';
  opt_FrmFont   :PAnsiChar = 'frame/framefont';
  opt_FrmEffect :PAnsiChar = 'frame/txteffect';
  opt_RollStep  :PAnsiChar = 'frame/rollstep';
  opt_RollGap   :PAnsiChar = 'frame/rollgap';
//  opt_RollTail  :PAnsiChar = 'frame/rolltail';
  opt_AlgnCenter:PAnsiChar = 'frame/aligncenter';
  opt_TxtTimer  :PAnsiChar = 'frame/texttimer';
  opt_FrameText :PAnsiChar = 'frame/frametext';

procedure LoadSettings;
begin
//  RollTail    :=DBReadByte (0,PluginShort,opt_RollTail  ,20);
  FrameCtrl.TextBlock.RollStep  :=DBReadByte (0,PluginShort,opt_RollStep ,2);
  FrameCtrl.TextBlock.RollGap   :=DBReadByte (0,PluginShort,opt_RollGap  ,16);
  FrameCtrl.TextBlock.TextColor :=DBReadDWord(0,PluginShort,opt_FrmTxtClr,0);
  FrameCtrl.TextBlock.Effects   :=DBReadWord (0,PluginShort,opt_FrmEffect,effCut or effCenter);
  FrameCtrl.TextBlock.UpdateTime:=DBReadWord (0,PluginShort,opt_TxtTimer ,10);

  Template:=DBReadUnicode(0,PluginShort,opt_FrameText);
  
  if DBReadStruct(0,PluginShort,opt_FrmFont,@TextLF,SizeOf(TextLF))=0 then
    InitFrame;
  FrameCtrl.TextBlock.Font:=CreateFontIndirect(TextLF);
end;

procedure SaveSettings;
begin
//  DBWriteByte   (0,PluginShort,opt_RollTail  ,RollTail);
  DBWriteDWord(0,PluginShort,opt_FrmTxtClr,FrameCtrl.TextBlock.TextColor); // reaction on chunk?
  DBWriteByte (0,PluginShort,opt_RollStep ,FrameCtrl.TextBlock.RollStep);
  DBWriteByte (0,PluginShort,opt_RollGap  ,FrameCtrl.TextBlock.RollGap);
  DBWriteWord (0,PluginShort,opt_FrmEffect,FrameCtrl.TextBlock.Effects);
  DBWriteWord (0,PluginShort,opt_TxtTimer ,FrameCtrl.TextBlock.UpdateTime);

  DBWriteStruct(0,PluginShort,opt_FrmFont,@TextLF,SizeOf(TextLF));
  if FrameCtrl.TextBlock.Font<>0 then
    DeleteObject(FrameCtrl.TextBlock.Font);
  FrameCtrl.TextBlock.Font:=CreateFontIndirect(TextLF);

  DBWriteUnicode(0,PluginShort,opt_FrameText,Template);
  NewTemplate(TextBlock,Template);
end;

procedure MouseDown(Sender:PControl;var Mouse:TMouseEventData);
var
  wnd:HWND;
begin
  wnd:=GetParent(GetParent(Sender.GetWindowHandle));
  SendMessage(wnd,WM_SYSCOMMAND,
     SC_MOVE or HTCAPTION,MAKELPARAM(Mouse.x,Mouse.y));
end;

procedure UpdateTextBlock(TextBlock:PControl;force:boolean);
var
  tmp:pWideChar;
begin
  if not force then
  begin
    if (StrPosW(Template,'%percent%')=nil) and
       (StrPosW(Template,'%time%'   )=nil) then // need to |remake
      exit;
  end;
  tmp:=pWideChar(CallService(MS_WAT_REPLACETEXT,0,dword(Template)));
  TextBlock.Text:=tmp;
  mFreeMem(tmp);
  TextBlock.Invalidate;
end;

procedure NewTemplate(TextBlock:pControl; src:pWideChar);
begin
  mFreeMem(Template);
  StrDupW(Template,src);

  UpdateTextBlock(TextBlock,true);
end;

function MakeTextBlock(AOwner:PControl;BkColor:TCOLORREF):pTextBlock;
begin
  result:=MakeNewTextBlock(AOwner,BkColor);
end;
