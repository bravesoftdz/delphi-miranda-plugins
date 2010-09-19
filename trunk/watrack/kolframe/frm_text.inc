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
    TextChunk  :pChunkArray;
    TextLF     :TLOGFONT;
    TextFont   :HFONT;
    TextColor  :TCOLORREF;
    Template   :PWideChar;
    CurrentText:PWideChar;
    TextEffect :dword;
    RollStep   :integer;
    RollGap    :integer;
//    RollTail   :integer;

    destructor Destroy; virtual;
    procedure InitFrame;
    procedure CtrlResize(Sender: PObj);
    procedure TextPaint(Sender: PControl; DC: HDC);
    procedure SaveSettings;
    procedure LoadSettings;
  end;

destructor tTxtBlockData.Destroy;
begin
  if TextFont<>0 then DeleteObject(TextFont);
  mFreeMem(CurrentText);
  mFreeMem(Template);
  inherited;
end;

procedure tTxtBlockData.InitFrame;
begin
  FillChar(TextLF,SizeOf(TLOGFONT),0);
  with TextLF do
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
  TextFont:=CreateFontIndirect(TextLF);
end;

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

procedure tTxtBlockData.LoadSettings;
begin
  RollStep    :=DBReadByte (0,PluginShort,opt_RollStep  ,2);
  RollGap     :=DBReadByte (0,PluginShort,opt_RollGap   ,16);
//  RollTail    :=DBReadByte (0,PluginShort,opt_RollTail  ,20);
  TextColor   :=DBReadDWord(0,PluginShort,opt_FrmTxtClr ,0);
  TextEffect  :=DBReadByte (0,PluginShort,opt_FrmEffect ,effCut);

//??  AlignCenter :=DBReadByte (0,PluginShort,opt_AlgnCenter,BST_UNCHECKED);

  Template:=DBReadUnicode(0,PluginShort,opt_FrameText);
  
//  vTxtTimer:=DBReadWord(0,PluginShort,opt_TxtTimer,10);
  if DBReadStruct(0,PluginShort,opt_FrmFont,@TextLF,SizeOf(TextLF))=0 then
    InitFrame;
end;

procedure tTxtBlockData.SaveSettings;
begin
  DBWriteDWord  (0,PluginShort,opt_FrmTxtClr ,TextColor);
  DBWriteByte   (0,PluginShort,opt_RollStep  ,RollStep);
  DBWriteByte   (0,PluginShort,opt_RollGap   ,RollGap);
//  DBWriteByte   (0,PluginShort,opt_RollTail  ,RollTail);
  DBWriteByte   (0,PluginShort,opt_FrmEffect ,TextEffect);
//!!  DBWriteByte   (0,PluginShort,opt_AlgnCenter,AlignCenter);
//!!  DBWriteWord   (0,PluginShort,opt_TxtTimer  ,vTxtTimer);

  DBWriteUnicode(0,PluginShort,opt_FrameText ,Template);
  DBWriteStruct (0,PluginShort,opt_FrmFont   ,@TextLF,SizeOf(TextLF));
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
  fnt1:=SelectObject(dc,TextFont);
  SetTextColor(dc,TextColor);
  CopyRect(dst,Sender.BoundsRect);
  InflateRect(dst,-4,-2);

  DrawChunks(dc,@TextChunk[0],dst,true); // i.e. only paint or roll
  SelectObject(dc,fnt1);
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
    StrDupW(D.CurrentText,'Sample {bg1}of{/bg} text'#13#10'second {b}line{/b} of text');
    D.TextChunk:=Split(D.CurrentText);

    OnResize:=D.CtrlResize;
    OnPaint :=D.TextPaint;
  end;
end;
