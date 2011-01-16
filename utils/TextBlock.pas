unit TextBlock;

interface

uses KOL, windows;

const
  ppLeft  = 0;
  ppRight = 1;
  //effects
  effCut    = 0;
  effWrap   = 1;
  effRoll   = 2;
  effPong   = 3;
  effCenter = $100;

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

type
  pTextData = ^tTextData;
  tTextData = record
    // runtime data
    UpdTimer   :cardinal;
    TextFont   :HFONT;
    NeedResize :Boolean;

    // working data
    TextChunk  :pChunkArray;
    Text       :pWideChar; // for text chunks

    TextColor  :TCOLORREF;
    BkColor    :TCOLORREF;
    TextLF     :TLOGFONT;

    // options
    TextEffect :dword;
    RollStep   :integer;
    RollGap    :integer;
//    RollTail   :integer;
    UpdInterval :cardinal;
  end;

const
  MaxTxtScrollSpeed = 20;
  awkTextPad = 4; // text block pad from frame border

const
  idx_effect   = 0;
  idx_rollstep = 1;
  idx_rollgap  = 2;
  idx_timer    = 3;
  idx_txtcolor = 4;
  idx_bkcolor  = 5;
  idx_font     = 6;
type
  pTextBlock = ^tTextBlock;
  tTextBlock = object(TControl)
  private
    procedure myCtrlResize(Sender: PObj);
    procedure myTextPaint(Sender: PControl; DC: HDC);
    procedure myMouseDown(Sender:PControl;var Mouse:TMouseEventData);

    procedure ClearText;
    function  Split(src:pWideChar):pChunkArray;

    procedure DrawChunks(dc:HDC;Chunk:pChunk;rc:TRECT;justpaint:boolean);
    procedure DrawLines (dc:HDC;Chunk:pChunk;rc:TRECT;justpaint:boolean);

    function  GetEffect(idx:integer):integer;
    procedure SetEffect(idx:integer;value:integer);

    function  GetText:pWideChar;
    procedure SetText(value:pWideChar);

    function  GetFontData:TLOGFONT;
    procedure SetFontData(const value:TLOGFONT);

  public
    destructor Destroy; virtual;
    procedure DrawText(DC: HDC; justpaint:boolean);

    property Effects   :integer index idx_effect   read GetEffect write SetEffect;
    property RollStep  :integer index idx_rollstep read GetEffect write SetEffect;
    property RollGap   :integer index idx_rollgap  read GetEffect write SetEffect;
    property UpdateTime:integer index idx_timer    read GetEffect write SetEffect;
    property TextColor :integer index idx_txtcolor read GetEffect write SetEffect;
    property BkColor   :integer index idx_bkcolor  read GetEffect write SetEffect;
    property Font      :integer index idx_font     read GetEffect write SetEffect;

    property FontData :TLOGFONT  read GetFontData write SetFontData;
    property BlockText:pWideChar read GetText     write SetText;
  end;

function MakeNewTextBlock(AOwner:PControl;BkColor:TCOLORREF):pTextBlock;

implementation

uses messages,common;

{$include tb_chunk.inc}

function tTextBlock.GetFontData:TLOGFONT;
begin
  result:=pTextData(CustomData).TextLF;
end;

procedure tTextBlock.SetFontData(const value:TLOGFONT);
begin
  move(value,pTextData(CustomData).TextLF,SizeOf(TLOGFONT));
end;

function tTextBlock.GetEffect(idx:integer):integer;
begin
  with pTextData(CustomData)^ do
    case idx of
      idx_effect  : result:=TextEffect;
      idx_rollstep: result:=RollStep;
      idx_rollgap : result:=RollGap;
      idx_txtcolor: result:=TextColor;
      idx_bkcolor : result:=BkColor;
      idx_font    : result:=0;
      idx_timer   : result:=UpdInterval;
    else // it can't be really
      result:=0;
    end;
end;

procedure TimerProc(wnd:HWND;uMsg:cardinal;TB:pTextBlock;dwTime:dword); stdcall;
begin
  TB.DrawText(GetDC(wnd),false);
end;

procedure tTextBlock.SetEffect(idx:integer;value:integer);
var
  DC:HDC;
  OldFont:HFONT;
begin
  with pTextData(CustomData)^ do
    case idx of
      idx_effect  : TextEffect :=value;
      idx_rollstep: RollStep   :=value;
      idx_rollgap : RollGap    :=value;
      idx_txtcolor: TextColor  :=value;
      idx_bkcolor : BkColor    :=value;
      idx_font    : begin
        DC:=GetDC(0);
        OldFont:=SelectObject(DC,value);
        GetObject(GetCurrentObject(dc,OBJ_FONT),SizeOf(TLOGFONT),@TextLF);
        SelectObject(DC,OldFont);
      end;
      idx_timer   : begin
        // stoptimer
        if UpdTimer<>0 then
        begin
          KillTimer(0,UpdTimer);
          UpdTimer:=0;
        end;

        UpdInterval:=value;
        // starttimer
        if UpdInterval>0 then
          UpdTimer:=SetTimer(Self.GetWindowHandle,integer(@Self),(MaxTxtScrollSpeed+1-UpdInterval)*100,@TimerProc);
      end;
    end;
end;

procedure tTextBlock.ClearText;
var
  D:pTextData;
begin
  D:=CustomData;
  if D.Text<>nil then
  begin
    DeleteChunks(D.TextChunk);
    FreeMem(D.Text);
    D.Text:=nil;
  end;
end;

function tTextBlock.GetText:pWideChar;
begin
  result:=pTextData(CustomData)^.Text;
end;

procedure tTextBlock.SetText(value:pWideChar);
begin
  if StrCmpW(pTextData(CustomData).Text,value)<>0 then
  begin
    ClearText;
    if (value<>nil) and (value^<>#0) then
    begin
      with pTextData(CustomData)^ do
      begin
        GetMem(Text,(StrLenW(value)+1)*SizeOf(WideChar));
        WStrCopy(Text,value);
        TextChunk:=Split(Text);
      end;
    end;
  end;
end;

destructor tTextBlock.Destroy;
var
  D:pTextData;
begin
  D:=pointer(CustomData);
  if D.UpdTimer<>0 then
  begin
    KillTimer(0,D.UpdTimer);
    D.UpdTimer:=0;
  end;
  ClearText;
  inherited;
end;

// avoiding anchors problems
procedure tTextBlock.myCtrlResize(Sender: PObj);
var
  tmp:integer;
  D:pTextData;
begin
  D:=CustomData;
  if D.NeedResize then
  begin
    D.NeedResize:=false;

    tmp:=PControl(Sender).Parent.Width-2*awkTextPad;

    if (PControl(Sender)^.Width)>tmp then
      PControl(Sender)^.Width:=tmp;

    D.NeedResize:=true;
  end;
end;

procedure tTextBlock.DrawText(DC:HDC; justpaint:boolean);
var
  dst:TRECT;
  D:pTextData;
  MemDC:HDC;
begin
  D:=CustomData;
  with D^ do
    if TextChunk<>nil then
    begin
      CopyRect(dst,Self.BoundsRect);

      MemDC:=CreateCompatibleDC(dc);
      SetTextColor(MemDC,TextColor);
      SelectObject(MemDC,CreateCompatibleBitmap(DC,dst.right,dst.bottom));
      DeleteObject(SelectObject(MemDC,CreateFontIndirect(D.TextLF)));

      BitBlt(MemDC,dst.left,dst.top,dst.right-dst.left,dst.bottom-dst.top,
             dc,dst.left,dst.top,SRCCOPY);

      InflateRect(dst,-4,-2); // text padding from text block
      DrawChunks(MemDC,@TextChunk[0],dst,justpaint); // i.e. only paint or roll
      InflateRect(dst,4,2); // text padding from text block

      BitBlt(dc,dst.left,dst.top,dst.right-dst.left,dst.bottom-dst.top,
             MemDC,dst.left,dst.top,SRCCOPY);
      DeleteDC(MemDC);
    end;
end;

procedure tTextBlock.myTextPaint(Sender: PControl; DC: HDC);
begin
  DrawText(DC,true);
end;

procedure tTextBlock.myMouseDown(Sender:PControl;var Mouse:TMouseEventData);
var
  wnd:HWND;
begin
  wnd:=GetParent(GetParent(Sender.GetWindowHandle));
  SendMessage(wnd,WM_SYSCOMMAND,
     SC_MOVE or HTCAPTION,MAKELPARAM(Mouse.x,Mouse.y));
end;

function MakeNewTextBlock(AOwner:PControl;BkColor:TCOLORREF):pTextBlock;
var
  D:pTextData;
begin
  result:=pTextBlock(NewPanel(AOwner,esNone));
//  result:=NewLabel(AOwner,'');
//  result:=NewLabelEffect(AOwner,'',0);
  GetMem(D,SizeOf(tTextData));
  FillChar(D^,SizeOf(tTextData),0);
  result.CustomData :=D;
  result.Transparent:=true;

  result.SetSize(AOwner.Width-awkTextPad*2,40);
  result.SetPosition(AOwner.Left+awkTextPad,awkTextPad);
  result.Anchor(true,true,true,true);

  result.OnResize   :=result.myCtrlResize;
  result.OnPaint    :=result.myTextPaint;
  result.OnMouseDown:=result.myMouseDown;

//    result..InitFrame;
  D.BkColor   :=BkColor;
  D.TextChunk :=nil;
  D.NeedResize:=true;
end;

end.
