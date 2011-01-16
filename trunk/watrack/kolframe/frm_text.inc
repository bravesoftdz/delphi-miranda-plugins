{Text}

var
  Template:pWideChar;
const
  TextLF:TLOGFONT = (
    lfHeight        :-10;
    lfWidth         :0;
    lfEscapement    :0;
    lfOrientation   :0;
    lfWeight        :FW_DONTCARE;
    lfItalic        :0;
    lfUnderline     :0;
    lfStrikeOut     :0;
    lfCharSet       :DEFAULT_CHARSET;
    lfOutPrecision  :OUT_DEFAULT_PRECIS;
    lfClipPrecision :CLIP_DEFAULT_PRECIS;
    lfQuality       :DEFAULT_QUALITY;
    lfPitchAndFamily:DEFAULT_PITCH or FF_DONTCARE;
    lfFaceName      :#0);

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

procedure LoadTextSettings;
begin
//  RollTail    :=DBReadByte (0,PluginShort,opt_RollTail  ,20);
  FrameCtrl.TextBlock.RollStep  :=DBReadByte (0,PluginShort,opt_RollStep ,2);
  FrameCtrl.TextBlock.RollGap   :=DBReadByte (0,PluginShort,opt_RollGap  ,16);
  FrameCtrl.TextBlock.TextColor :=DBReadDWord(0,PluginShort,opt_FrmTxtClr,0);
  FrameCtrl.TextBlock.Effects   :=DBReadWord (0,PluginShort,opt_FrmEffect,effCut or effCenter);
  FrameCtrl.TextBlock.UpdateTime:=DBReadWord (0,PluginShort,opt_TxtTimer ,10);

  Template:=DBReadUnicode(0,PluginShort,opt_FrameText);
  
  DBReadStruct(0,PluginShort,opt_FrmFont,@TextLF,SizeOf(TextLF));
//  FrameCtrl.TextBlock.Font:=CreateFontIndirect(TextLF);
  FrameCtrl.TextBlock.FontData:=TextLF;
end;

procedure UpdateTextBlock(TextBlock:PTextBlock;force:boolean);
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
  TextBlock.BlockText:=tmp;
  mFreeMem(tmp);
TextBlock.Invalidate;
end;

procedure SaveTextSettings(withtemplate:boolean);
begin
//  DBWriteByte   (0,PluginShort,opt_RollTail  ,RollTail);
  DBWriteDWord(0,PluginShort,opt_FrmTxtClr,FrameCtrl.TextBlock.TextColor); // reaction on chunk?
  DBWriteByte (0,PluginShort,opt_RollStep ,FrameCtrl.TextBlock.RollStep);
  DBWriteByte (0,PluginShort,opt_RollGap  ,FrameCtrl.TextBlock.RollGap);
  DBWriteWord (0,PluginShort,opt_FrmEffect,FrameCtrl.TextBlock.Effects);
  DBWriteWord (0,PluginShort,opt_TxtTimer ,FrameCtrl.TextBlock.UpdateTime);

  DBWriteStruct(0,PluginShort,opt_FrmFont,@TextLF,SizeOf(TLOGFONT));

  if withtemplate then
  begin
    DBWriteUnicode(0,PluginShort,opt_FrameText,Template);
    UpdateTextBlock(FrameCtrl.TextBlock,true);
  end;
end;

function MakeTextBlock(AOwner:PControl;BkColor:TCOLORREF):pTextBlock;
begin
  result:=MakeNewTextBlock(AOwner,BkColor);
  result.OnMouseDown:=TOnMouse(MakeMethod(nil, @MouseDown));
end;
