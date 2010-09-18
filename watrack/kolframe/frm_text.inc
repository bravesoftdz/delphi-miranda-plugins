{Text}
{
  Color
  TextColor

}
const
  awkTextPad = 4; // text block pad from frame border

type
  pTxtBlockData = ^tTxtBlockData;
  tTxtBlockData = object(TObj)
    TextChunk:pChunk;
    FrameLF:TLOGFONT;

    procedure InitFrame;
    procedure CtrlResize(Sender: PObj);
    procedure TextPaint(Sender: PControl; DC: HDC);
    procedure SaveSettings;
    procedure LoadSettings;
  end;

procedure tTxtBlockData.InitFrame;
begin
  FillChar(FrameLF,SizeOf(TLOGFONT),0);
  with FrameLF do
  begin
    lfCharSet       :=DEFAULT_CHARSET;
    lfOutPrecision  :=OUT_DEFAULT_PRECIS;
    lfClipPrecision :=CLIP_DEFAULT_PRECIS;
    lfQuality       :=DEFAULT_QUALITY;
    lfPitchAndFamily:=DEFAULT_PITCH or FF_DONTCARE;
//    dc:=GetDC(FrameWnd);
//    lfHeight     :=-(8*GetDeviceCaps(dc,LOGPIXELSY) div 72);
//    ReleaseDC(FrameWnd,dc);
    lfHeight     :=-10;
    lfWeight     :=FW_DONTCARE;
    lfItalic     :=0;
    lfUnderline  :=0;
    lfStrikeOut  :=0;
    lfFaceName[0]:=#0;
  end;
end;

const
  opt_FrmTxtClr :PAnsiChar = 'frame/frametextcolor';
  opt_FrmFont   :PAnsiChar = 'frame/framefont';
  opt_FrmEffect :PAnsiChar = 'frame/txteffect';
  opt_RollStep  :PAnsiChar = 'frame/rollstep';
  opt_RollGap   :PAnsiChar = 'frame/rollgap';
  opt_RollTail  :PAnsiChar = 'frame/rolltail';
  opt_AlgnCenter:PAnsiChar = 'frame/aligncenter';
  opt_TxtTimer  :PAnsiChar = 'frame/texttimer';
  opt_FrameText :PAnsiChar = 'frame/frametext';

procedure tTxtBlockData.LoadSettings;
var
  setting:array [0..63] of AnsiChar;
begin
  RollStep    :=DBReadByte (0,PluginShort,opt_RollStep  ,2);
  RollGap     :=DBReadByte (0,PluginShort,opt_RollGap   ,16);
  RollTail    :=DBReadByte (0,PluginShort,opt_RollTail  ,20);
  FrmTxtColor :=DBReadDWord(0,PluginShort,opt_FrmTxtClr ,0);
  FrmEffect   :=DBReadByte (0,PluginShort,opt_FrmEffect ,effCut);
  AlignCenter :=DBReadByte (0,PluginShort,opt_AlgnCenter,BST_UNCHECKED);

  FrameText:=DBReadUnicode(0,PluginShort,opt_FrameText);
  
  vTxtTimer:=DBReadWord(0,PluginShort,opt_TxtTimer,10);
  if DBReadStruct(0,PluginShort,opt_FrmFont,@FrameLF,SizeOf(FrameLF))=0 then
    InitFrame;
end;

procedure tTxtBlockData.SaveSettings;
begin
  DBWriteDWord  (0,PluginShort,opt_FrmTxtClr ,FrmTxtColor);
  DBWriteByte   (0,PluginShort,opt_RollStep  ,RollStep);
  DBWriteByte   (0,PluginShort,opt_RollGap   ,RollGap);
  DBWriteByte   (0,PluginShort,opt_RollTail  ,RollTail);
  DBWriteByte   (0,PluginShort,opt_FrmEffect ,FrmEffect);
  DBWriteByte   (0,PluginShort,opt_AlgnCenter,AlignCenter);
  DBWriteWord   (0,PluginShort,opt_TxtTimer  ,vTxtTimer);

  DBWriteDWord  (0,PluginShort,opt_FrmTxtClr ,FrmTxtColor);
  DBWriteUnicode(0,PluginShort,opt_FrameText ,FrameText);
  DBWriteStruct (0,PluginShort,opt_FrmFont   ,@FrameLF,SizeOf(FrameLF));
end;

procedure tTxtBlockData.CtrlResize(Sender: PObj);
var
  tmp:integer;
begin
  tmp:=PControl(Sender).Parent.Width-2*awkTextPad;
  if (PControl(Sender)^.Width)>tmp then
    PControl(Sender)^.Width:=tmp;
end;

procedure tTxtBlockData.TextPaint(Sender: PControl; DC: HDC);
var
  dst:TRECT;
  fnt1:HFONT;
begin
  fnt1:=SelectObject(dc,CreateFontIndirect(FrameLF));
  SetTextColor(dc,FrmTxtColor);
  CopyRect(dst,Sender.BoundsRect);
  InflateRect(dst,-4,-2);

  DrawChunks(dc,TextChunk,dst,true); // i.e. only paint
  DeleteObject(SelectObject(dc,fnt1));
end;

function MakeNewTextBlock(AOwner:PControl):PControl;
var
  D:pTxtBlockData;
begin
  result:=NewPanel(AOwner,esNone);
  New(D, Create);
  with result^ do
  begin
    CustomObj  :=D;
    Transparent:=true;

    Left :=AOwner.Left+awkTextPad;
    Width:=AOwner.Width-awkTextPad*2;
    Anchor(true,true,true,true);

    D.InitFrame;
    D.TextChunk:=Split('Sample of text'#13#10'second {b}line{/b} of text');

    OnResize:=D.CtrlResize;
    OnPaint :=D.TextPaint;
  end;
end;
