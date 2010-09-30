{Text}
{
  Color
  TextColor

}

type
  pChunk = ^tChunk;
  tChunk = record
    _type:integer;   // type
    val  :integer;   // sign value or text length
    txt  :pWideChar; // text value pointer
    add  :integer;   // offset for text effect
    dir  :integer;   // ping-pong directon
  end;
  pChunkArray = ^tChunkArray;
  tChunkArray = array [0..1000] of tChunk;

const
  awkTextPad = 4; // text block pad from frame border

type
  pTxtBlockData = ^tTxtBlockData;
  tTxtBlockData = object(TObj)
    TextChunk  :pChunkArray;
    TextLF     :TLOGFONT;
    TextFont   :HFONT;
    TextColor  :TCOLORREF;
    BkColor    :TCOLORREF;
    Template   :PWideChar;
    CurrentText:PWideChar;
    TextEffect :dword;
    RollStep   :integer;
    RollGap    :integer;
//    RollTail   :integer;
    UpdInterval :cardinal;
    UpdTimer    :cardinal;
    AlignCenter :cardinal;

    destructor Destroy; virtual;
    procedure InitFrame;

    procedure CtrlResize(Sender: PObj);
    procedure TextPaint(Sender: PControl; DC: HDC);
    procedure MouseDown(Sender:PControl;var Mouse:TMouseEventData);

    procedure SaveSettings;
    procedure LoadSettings;
    procedure NewTemplate(src:pWideChar);
    procedure RemakeText;
    procedure ChangeBkColor(newBkColor:TCOLORREF);

    function  Split(src:pWideChar):pChunkArray;
    procedure DrawChunks(dc:HDC;Chunk:pChunk;rc:TRECT;justpaint:boolean);
    procedure DrawLines(dc:HDC;Chunk:pChunk;rc:TRECT;justpaint:boolean);
    function  Macro(var src:pWideChar;var Chunk:pChunk):boolean;
  end;

{$include frm_chunk.inc}

procedure UpdateTextBlock(TextBlock:PControl;force:boolean);
begin
  with pTxtBlockData(TextBlock.CustomObj)^ do
  begin
    if not force then
    begin
      if (StrPosW(Template,'%percent%')=nil) and
         (StrPosW(Template,'%time%'   )=nil) then // need to remake
        exit;
    end;
    RemakeText;
    TextBlock.Update;
//    SendMessage(TextBlock.GetWindowHandle,WM_SIZE,0,0);
  end;
end;

destructor tTxtBlockData.Destroy;
begin
  if UpdTimer<>0 then
  begin
    KillTimer(0,UpdTimer);
    UpdTimer:=0;
  end;

  DeleteChunks(TextChunk);
  if TextFont<>0 then DeleteObject(TextFont);
  mFreeMem(CurrentText);
  mFreeMem(Template);
  inherited;
end;

function WndProcTextBlock( Sender: PControl; var Msg: TMsg; var Rslt:Integer ): boolean;
begin
  result:=false;
  case msg.message of
    WM_TIMER: begin
    end;
  end;
end;

procedure ClearTextBlock(TextBlock:PControl);
var
  D:pTxtBlockData;
begin
  D:=pointer(TextBlock.CustomObj);
  DeleteChunks(D.TextChunk);
  mFreeMem(D.CurrentText); //??
  if D.UpdTimer<>0 then
    KillTimer(0,D.UpdTimer);
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

  AlignCenter :=DBReadByte (0,PluginShort,opt_AlgnCenter,BST_UNCHECKED);

  Template:=DBReadUnicode(0,PluginShort,opt_FrameText);
  
  UpdInterval:=DBReadWord(0,PluginShort,opt_TxtTimer,10);
  if DBReadStruct(0,PluginShort,opt_FrmFont,@TextLF,SizeOf(TextLF))=0 then
    InitFrame;
end;

procedure tTxtBlockData.SaveSettings;
begin
  DBWriteDWord  (0,PluginShort,opt_FrmTxtClr ,TextColor); // reaction on chunk?
  DBWriteByte   (0,PluginShort,opt_RollStep  ,RollStep);
  DBWriteByte   (0,PluginShort,opt_RollGap   ,RollGap);
//  DBWriteByte   (0,PluginShort,opt_RollTail  ,RollTail);
  DBWriteByte   (0,PluginShort,opt_FrmEffect ,TextEffect);
  DBWriteByte   (0,PluginShort,opt_AlgnCenter,AlignCenter);
  DBWriteWord   (0,PluginShort,opt_TxtTimer  ,UpdInterval);

  DBWriteStruct (0,PluginShort,opt_FrmFont   ,@TextLF,SizeOf(TextLF));

  DBWriteUnicode(0,PluginShort,opt_FrameText ,Template);
  RemakeText;
{
  if (UpdInterval>0) and (FrameWnd<>0) then
    UpdTimer:=SetTimer(FrameWnd,TMR_TEXT,(MaxTxtScrollSpeed+1-UpdInterval)*100,nil)
}
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
  if TextChunk<>nil then
  begin
    fnt1:=SelectObject(dc,TextFont);
    SetTextColor(dc,TextColor);
    CopyRect(dst,Sender.BoundsRect);
    InflateRect(dst,-4,-2);

    DrawChunks(dc,@TextChunk[0],dst,true); // i.e. only paint or roll
    SelectObject(dc,fnt1);
  end;
end;

procedure TTxtBlockData.MouseDown(Sender:PControl;var Mouse:TMouseEventData);
var
  wnd:HWND;
begin
  wnd:=GetParent(GetParent(Sender.GetWindowHandle));
  SendMessage(wnd,WM_SYSCOMMAND,
     SC_MOVE or HTCAPTION,MAKELPARAM(Mouse.x,Mouse.y));
end;

procedure TTxtBlockData.RemakeText;
begin
  DeleteChunks(TextChunk);
  mFreeMem(CurrentText);
  CurrentText:=pWideChar(CallService(MS_WAT_REPLACETEXT,0,dword(Template)));
  TextChunk:=Split(CurrentText);
end;

procedure TTxtBlockData.NewTemplate(src:pWideChar);
begin
  mFreeMem(Template);
  StrDupW(Template,src);

  RemakeText;
end;

procedure TTxtBlockData.ChangeBkColor(newBkColor:TCOLORREF);
begin
  BkColor:=newBkColor;
end;

function MakeNewTextBlock(AOwner:PControl;BkColor:TCOLORREF):PControl;
var
  D:pTxtBlockData;
begin
  result:=NewPanel(AOwner,esNone);
//  result:=NewLabel(AOwner,'');
  New(D, Create);
  with result^ do
  begin
    CustomObj  :=D;
    Transparent:=true;

    SetSize(AOwner.Width-awkTextPad*2,40);
    SetPosition(AOwner.Left+awkTextPad,awkTextPad);

    Anchor(true,true,true,true);

    D.LoadSettings;
    D.InitFrame;
    D.BkColor:=BkColor;
    D.TextChunk:=nil;

    OnResize   :=D.CtrlResize;
    OnPaint    :=D.TextPaint;
    OnMouseDown:=D.MouseDown;

    AttachProc(WndProcTextBlock);
  end;
end;
