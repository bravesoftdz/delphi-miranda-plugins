{CList frame}
unit FrameUnit;

interface

implementation

uses io,windows,commdlg,messages,common,commctrl,
     wat_api,wrapper,global,m_api,hlpdlg,macros,dbsettings,waticons,mirutils;

{$include frm_data.inc}
{$include frm_vars.inc}
{$include frm_opt.inc}
{$include frm_rc.inc}
{$include frm_icons.inc}
{$include frm_chunk.inc}

{$resource frm.res}

function SetLayeredWindowAttributes(Hwnd: THandle; crKey: COLORREF; bAlpha: Byte; dwFlags: DWORD): Boolean; stdcall;
   external user32 name 'SetLayeredWindowAttributes';

const
  LWA_COLORKEY = $00000001;
  LWA_ALPHA    = $00000002;

const
  bw=16; // button width
  bh=16; // button height
  th=18; // controls height
  bg=3;  // button/trackbar gap

var
  OldTrackProc:pointer;

procedure SetFrameTitle(title:PAnsiChar;icon:HICON);
begin
  CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,(FrameId shl 16)+FO_TBNAME,dword(title));
  CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,(FrameId shl 16)+FO_ICON,icon);
  CallService(MS_CLIST_FRAMES_UPDATEFRAME,FrameId,FU_TBREDRAW);
end;

// -----------------------

function IsFrameMinimized:bool;
begin
  result:=(CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
          (FrameId shl 16)+FO_FLAGS,0) and F_UNCOLLAPSED)=0;
end;

function IsFrameHidden:bool;
begin
  result:=(CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
          (FrameId shl 16)+FO_FLAGS,0) and F_VISIBLE)=0;
end;

procedure HideFrame;
begin
  if not IsFrameHidden then
  begin
    CallService(MS_CLIST_FRAMES_SHFRAME,FrameId,0);
    HiddenByMe:=true;
  end;
end;

function ShowFrame:integer;
begin
  result:=0;
  if IsFrameHidden then
    if HiddenByMe then
    begin
      CallService(MS_CLIST_FRAMES_SHFRAME,FrameId,0);
      HiddenByMe:=false;
    end
    else
      result:=1;
end;

// ------------------------

function MaskToNum(mask:integer):integer;
var
  i:integer;
begin
  result:=0;
  if mask<>0 then
  begin
    for i:=1 to NumButtons do
    begin
      mask:=mask shr 1;
      if odd(mask) then
      begin
        result:=i;
        break
      end
    end;
  end;
end;

function FindButton(x,y:integer):integer;
var
  pt:TPOINT;
  i:integer;
begin
  pt.x:=x;
  pt.y:=y;
  for i:=1 to NumButtons do
  begin
    if PtInRect(CtrlPos[i],pt) then
    begin
      result:=i;
      exit;
    end;
  end;
  result:=-1;
end;

procedure CalcRect(var src,dst:TRECT;mode:dword);
var
  dh, dw:integer;
begin
// left & top=0!
  if (Mode and frbkStretch)=frbkStretch then
  begin
    if (Mode and frbkProportional)<>0 then
    begin
      if (dst.right*src.bottom)>(src.right*dst.bottom) then
      begin
        dh:=dst.bottom;
        dw:=dh*src.right div src.bottom
      end
      else
      begin
        dw:=dst.right;
        dh:=dw*src.bottom div src.right;
      end;
    end
    else
    begin
      dw:=dst.right;
      dh:=dst.bottom;
    end;
  end
  else
  begin
    dw:=src.right;
    dh:=src.bottom;
  end;
{
    if (Mode and frbkStretchX)<>0 then
    begin
      dw:=dst.right;
      if (Mode and frbkProportional)<>0 then
        dh:=dw*src.bottom div src.right
      else
        dh:=src.bottom;
    end;

    if (Mode and frbkStretchY)<>0 then
    begin
      dh:=dst.bottom;
      if (Mode and frbkProportional)<>0 then
        dw:=dh*src.right div src.bottom
      else
        dw:=src.right;
    end;

    if (Mode and frbkStretch)=0 then
    begin
      dw:=src.right;
      dh:=src.bottom;
    end;
}
    if (Mode and frbkBottom)<>0 then
    begin
      if dh<=dst.bottom then
      begin
        dst.top:=(dst.bottom-dh);
      end
      else
      begin
        src.top:=(dh-dst.bottom);
        dh:=dst.bottom;
        src.bottom:=src.top+dh;
      end;
    end;

    if (Mode and frbkRight)<>0 then
    begin
      if dw<=dst.right then
      begin
        dst.left:=(dst.right-dw);
      end
      else
      begin
        src.left:=(dw-dst.right);
        dw:=dst.right;
        src.right:=src.left+dw;
      end;
    end;

    if (Mode and frbkCenterX)<>0 then
    begin
      if dw<=dst.right then
      begin
        dst.left:=(dst.right-dw) div 2;
      end
      else
      begin
        src.left:=(dw-dst.right) div 2;
        dw:=dst.right;
        src.right:=src.left+dw;
      end;
    end;

    if (Mode and frbkCenterY)<>0 then
    begin
      if dh<=dst.bottom then
      begin
        dst.top:=(dst.bottom-dh) div 2;
      end
      else
      begin
        src.top:=(dh-dst.bottom) div 2;
        dh:=dst.bottom;
        src.bottom:=src.top+dh;
      end;
    end;
//  end;
  dst.right:=dst.left+dw;
  dst.bottom:=dst.top+dh;
end;

// ----- begin of modern code -----

function CreateDIB32(dc:HDC;w,h:integer):HBITMAP;
var
  pt:pointer;
  bi:TBITMAPINFO;
begin
  FillChar(bi,SizeOf(TBITMAPINFO),0);
  bi.bmiHeader.biSize    :=SizeOf(TBITMAPINFOHEADER);
  bi.bmiHeader.biWidth   :=w;
  bi.bmiHeader.biHeight  :=h;
  bi.bmiHeader.biPlanes  :=1;
  bi.bmiHeader.biBitCount:=32;
  result:=CreateDIBSection(dc,bi,DIB_RGB_COLORS,pt,0,0);
end;

procedure PreMultiplyChanells(hbmp:HBITMAP);
type
  tPixel=array [0..3] of Byte;
var
  bmp:TBITMAP;
  flag:bool;
  pBitmapBits:PByte;
  Len:dword;
  bh,bw,y,x,z:integer;
  pPixel:^tPixel;
  alpha:dword;
//f:THANDLE;
begin
  GetObject(hbmp,SizeOf(TBITMAP),@bmp);
  bh:=bmp.bmHeight;
  bw:=bmp.bmWidth;
  z:=bw*4;
  Len:=bh*z;

  mGetMem(pBitmapBits,Len);
  GetBitmapBits(hbmp,Len,pBitmapBits);
  flag:=true;
  for y:=0 to bh-1 do
  begin
    pointer(pPixel):=PAnsiChar(pBitmapBits)+z*y;
{
if y=5 then
begin
  f:=rewrite(PAnsiChar('c:\tt'));
  blockwrite(f,pPixel^,bw*4);
  closehandle(f);
end;
}
    for x:=0 to bw-1 do
    begin
      if pPixel^[3]<>0 then
        flag:=false
      else
        pPixel^[3]:=255;
      inc(pByte(pPixel),4);
    end
  end;

  if not flag then
  begin
//messagebox(0,'cleared','flag',0);
    GetBitmapBits(hbmp,Len,pBitmapBits); // alpha not changed
    for y:=0 to bh-1 do
    begin
      pointer(pPixel):=PAnsiChar(pBitmapBits)+z*y;

      for x:=0 to bw-1 do
      begin
        alpha:=pPixel^[3];
        if alpha<255 then
        begin
          pPixel^[0]:=dword(pPixel^[0])*alpha div 255;
          pPixel^[1]:=dword(pPixel^[1])*alpha div 255;
          pPixel^[2]:=dword(pPixel^[2])*alpha div 255;
        end;
        inc(pByte(pPixel),4);
      end
    end;
  end;
  SetBitmapBits(hbmp,Len,pBitmapBits);
  mFreeMem(pBitmapBits);
end;

function FixBitmap(dc:HDC;var hBmp:HBITMAP):HBITMAP;
var
  dc24,dc32:HDC;
  hBitmap32,obmp24,obmp32:HBITMAP;
  bmpInfo:TBITMAP;
//b:array [0..31] of AnsiChar;
begin
  GetObject(hBmp,SizeOf(TBITMAP),@bmpInfo);
  if bmpInfo.bmBitsPixel<>32 then
  begin
//messagebox(0,inttostr(b,bmpInfo.bmBitsPixel),'bits',0);
    dc32:=CreateCompatibleDC(dc);
    dc24:=CreateCompatibleDC(dc);
    hBitmap32:=CreateDIB32(dc,bmpInfo.bmWidth,bmpInfo.bmHeight);
    obmp24:=SelectObject(dc24,hBmp);
    obmp32:=SelectObject(dc32,hBitmap32);
    BitBlt(dc32,0,0,bmpInfo.bmWidth,bmpInfo.bmHeight,dc24,0,0,SRCCOPY);
    DeleteObject(SelectObject(dc24,obmp24));
    SelectObject(dc32,obmp32);
    DeleteDC(dc24);
    DeleteDC(dc32);
    hBmp:=hBitmap32;
  end;
  PreMultiplyChanells(hBmp);
  result:=hBmp;
end;

// ----- end of modern code -----

procedure PreparePicture(dc:HDC;rc:TRECT);
var
  bmpinfo:TBITMAP;
  src,dst:TRECT;
  x,y,w,h,dh:integer;
  br:HBRUSH;
  hdcbmp:HDC;
  bf:BLENDFUNCTION;
  hOld:THANDLE;
begin
  if (FrmUsePic<>BST_UNCHECKED) and (FrmBkBuf=0) and (hBkPic<>0) then
  begin
    FrmBkBuf:=CreateCompatibleDC(dc);

    FixBitmap(dc,hBkPic);
    FrmBkBmp:=CreateDIB32(dc,rc.right-rc.left,rc.bottom-rc.top);

    DeleteObject(SelectObject(FrmBkBuf,FrmBkBmp));

    br:=CreateSolidBrush(FrmBkColor);
    FillRect(FrmBkBuf,rc,br);
    DeleteObject(br);

    CopyRect(dst,rc);
    hdcbmp:=CreateCompatibleDC(FrmBkBuf);
    GetObject(hBkPic,SizeOf(bmpinfo),@bmpinfo);
    hOld:=SelectObject(hdcbmp,hBkPic);

    SetRect(src,0,0,bmpinfo.bmWidth,bmpinfo.bmHeight);

    if (padding.top+padding.bottom)<(dst.bottom-dst.top) then
      dec(dst.bottom,padding.top+padding.bottom);
    if (padding.left+padding.right)<(dst.right-dst.left) then
      dec(dst.right,padding.left+padding.right);

    CalcRect(src,dst,FrmBkMode);

    w:=1;
    if (FrmBkMode and frbkTileX)<>0 then
    begin
      x:=dst.right;
      while x<rc.right do
      begin
        inc(w);
        inc(x,dst.right);
      end;
    end;
    h:=1;
    if (FrmBkMode and frbkTileY)<>0 then
    begin
      y:=dst.bottom;
      while y<rc.bottom do
      begin
        inc(h);
        inc(y,dst.bottom);
      end;
    end;

bf.BlendOp:=AC_SRC_OVER;
bf.BlendFlags:=0;
bf.SourceConstantAlpha:=255;
bf.AlphaFormat:=1;//AC_SRC_ALPHA;
    
    x:=dst.left+padding.left;
    if x<dst.right then
      while w>0 do
      begin
        dh:=h;
        y:=dst.top+padding.top;
        if y<dst.bottom then
          while dh>0 do
          begin

AlphaBlend(FrmBkBuf,x,y,dst.right-dst.left,dst.bottom-dst.top,
           hdcbmp,src.left,src.top,src.right-src.left,src.bottom-src.top,
           bf);
(*
           TransparentBlt
            {StretchBlt}(FrmBkBuf,x,y,dst.right-dst.left,dst.bottom-dst.top,
                       hdcbmp,src.left,src.top,src.right-src.left,src.bottom-src.top,
                       AlphaColor);
*)
            inc(y,dst.bottom);
            dec(dh);
          end;
        inc(x,dst.right);
        dec(w);
      end;

    DeleteObject(SelectObject(hdcbmp,hOld));
    DeleteDC(hdcbmp);
    hBkPic:=0;
  end;
end;

procedure RedrawBackground(dc:HDC;const rc:TRECT);
var
  br:HBRUSH;
begin
  if FrmBkBuf<>0 then
  begin
    // client coordinates!
    BitBlt(dc,rc.left,rc.top,rc.right-rc.left,rc.bottom-rc.top,
           FrmBkBuf,rc.left,rc.top,SRCCOPY);
  end
  else
  begin
    br:=CreateSolidBrush(FrmBkColor);
    FillRect(dc,rc,br);
    DeleteObject(br);
  end;
end;

procedure DrawTrackBar(dc:HDC;const drc:TRECT);
var
  rc, rc1:TRECT;
  wnd:HWND;
  w:integer;
begin
  wnd:=GetDlgItem(FrameWnd,IDC_FRM_POS);
  SendMessage(wnd,TBM_GETTHUMBRECT,0,dword(@rc));

  w:=rc.right-rc.left;
  if w<>16 then
    rc.left:=rc.left+(w div 2)-8;

  CopyRect(rc1,drc);
  rc.top:=rc1.bottom-18;
  rc1.top   :=rc1.bottom-12;
  rc1.bottom:=rc1.top+4;
  inc(rc1.left,4); //InflateRect(rc1,0,-4);
  dec(rc1.right,4);

  DrawEdge(dc,rc1,EDGE_SUNKEN,BF_RECT or BF_ADJUST);
  DrawIconEx(dc,rc.left,rc.top,GetIcon(BTN_SLIDER),16,16,0,0,DI_NORMAL);
end;

procedure DrawText(dc:HDC;const rc:TRECT;OnlyText:boolean);
var
  dst:TRECT;
  fnt1:HFONT;
begin
  if ((ShowControls and scShowText)<>0) and
     (FrmChunk<>nil) then
  begin
    fnt1:=SelectObject(dc,CreateFontIndirect(FrameLF));
    SetTextColor(dc,FrmTxtColor);
    CopyRect(dst,rc);
    InflateRect(dst,-4,-2);

    DrawChunks(dc,FrmChunk,dst,not OnlyText); // i.e. only paint
    DeleteObject(SelectObject(dc,fnt1));
  end;
end;

procedure DrawButton(dc:HDC;num:integer;pdrc:PRECT;redraw:boolean);
var
  Icon:HICON;
  rc:TRECT;
begin
  if ((num<>WAT_CTRL_VOLDN) and (num<>WAT_CTRL_VOLUP)) or
     ((ShowControls and scShowVolume)<>0) then
  begin
    Icon:=GetIcon(num);
    if redraw then
      RedrawBackground(dc,CtrlPos[num]);

    CopyRect(rc,CtrlPos[num]);
    if ((CtrlPushed and (1 shl num))<>0) and not CtrlsLoaded then
      InflateRect(rc,-1,-1);
    DrawIconEx(dc,rc.left,rc.top,Icon,rc.right-rc.left,rc.bottom-rc.top,0,0,DI_NORMAL);
    if pdrc<>nil then
    begin
      CopyRect(pdrc^,CtrlPos[num]);
      exit;
    end;
  end;
  if pdrc<>nil then
    SetRectEmpty(pdrc^);
end;

procedure DrawButtons(dc:HDC;redraw:boolean);
var
  i:integer;
begin
{
  if redraw then
  begin
    redraw:=false;
    RedrawBackground(dc,rc);
  end;
}
  for i:=1 to NumButtons do
    DrawButton(dc,i,nil,redraw);
end;

procedure DrawFrame(mask:integer);
var
  tmprc,rc,rc1:TRECT;
  hdcMem,dc:hDC;
  hOSD:HBITMAP;
  hOld:THANDLE;
begin
  dc:=GetDC(FrameWnd);

//  SetWindowLong(wnd,GWL_EXSTYLE,GetwindowLong(wnd,GWL_EXSTYLE) and not WS_EX_LAYERED);
  GetClientRect(FrameWnd,rc1);
//    InflateRect(rc,1,1);
  hdcMem:=CreateCompatibleDC(dc);
  hOSD:=CreateCompatibleBitmap(dc,rc1.right,rc1.bottom);
  hOld:=SelectObject(hdcMem,hOSD);

  PreparePicture(hdcMem,rc1);
  if (mask and DF_ALL)=DF_ALL then
  begin
    CopyRect(rc,rc1);
    RedrawBackground(hdcMem,rc);
  end
  else
    SetRectEmpty(rc);

  SetBkMode(hdcMem,TRANSPARENT);

  if (ShowControls and scShowTrackBar)<>0 then // trackbar
  begin
    if ((mask and DF_TRACKBAR)<>0) and (StyledTrack<>BST_UNCHECKED) then
    begin
      SetRect(tmprc,rc1.left,rc1.bottom-th-bg,rc1.right,rc1.bottom);
      UnionRect(rc,rc,tmprc);
      if (mask and DF_ALL)<>DF_ALL then
        RedrawBackground(hdcMem,{tmp}rc);
      DrawTrackBar(hdcMem,tmprc);
    end;
    dec(rc1.bottom,th+bg);
  end;
  if ((ShowControls and scShowButtons)<>0) then // buttons
  begin
    if (mask and DF_BUTTON)<>0 then
    begin
      if (mask shr 16)<>0 then
        DrawButton(hdcMem,mask shr 16,@tmprc,true)
      else
      begin
        DrawButtons(hdcMem,(mask and DF_ALL)<>DF_ALL);
        SetRect(tmprc,rc1.left,rc1.bottom-bh-bg,rc1.right,rc1.bottom);
      end;
      UnionRect(rc,rc,tmprc);
    end;
    dec(rc1.bottom,bh+bg);
  end;
  if (mask and DF_TEXT)<>0 then
  begin
    if (mask and DF_ALL)<>DF_ALL then
      RedrawBackground(hdcMem,rc1);
    if (ShowControls and scShowText)<>0 then // text
    begin
      DrawText(hdcMem,rc1,(mask and DF_ALL)=DF_TEXT);
    end;
    UnionRect(rc,rc,rc1)
  end;

  BitBlt(dc,rc.left,rc.top,rc.right-rc.left,rc.bottom-rc.top,
         hdcMem,rc.left,rc.top,SRCCOPY);

  DeleteObject(SelectObject(hdcMem,hOld));
  DeleteDC(hdcMem);

//  SetWindowLong(wnd,GWL_EXSTYLE,GetwindowLong(wnd,GWL_EXSTYLE) or WS_EX_LAYERED);
  ReleaseDC(FrameWnd,dc);
end;

function TrackProc(Wnd:HWnd; hMessage,wParam,lParam:integer):integer; stdcall;
var
  ps:TPAINTSTRUCT;
  i:integer;
begin
  case hMessage of

    WM_MOUSEMOVE: begin
      if CtrlPushed<>0 then
      begin
       i:=MaskToNum(CtrlPushed);
       CtrlPushed :=0;
       DrawFrame(DF_BUTTON+(i shl 16));
//        InvalidateRect(FrameWnd,@CtrlPos[MaskToNum(CtrlPushed)],false);
      end;
      if CtrlHovered<>0 then
      begin
        i:=MaskToNum(CtrlHovered);
        CtrlHovered:=0;
        DrawFrame(DF_BUTTON+(i shl 16));
      end
    end;

    WM_PAINT: begin
      if (ShowControls and scShowTrackBar)<>0 then
      begin
        if StyledTrack<>BST_UNCHECKED then
        begin
          BeginPaint(wnd,ps);
          DrawFrame(DF_TRACKBAR);
          ps.fErase:=true;
          EndPaint(wnd,ps);
          result:=0;
          exit;
        end
      end;
    end;

    WM_ERASEBKGND: begin
      if StyledTrack<>BST_UNCHECKED then
      begin
        result:=1;
        exit
      end;
    end;

  end;
  result:=CallWindowProc(OldTrackProc,Wnd,hMessage,wParam,lParam);
end;

function WAFrameProc(Dialog:HWnd; hMessage,wParam,lParam:DWord):integer; stdcall;
label
  lExit;
var
  rc:TRECT;
  pt:TPOINT;
  w,x,y,h,sz:integer;
  r:PWideChar;
  wnd:hwnd;
  ps:TPAINTSTRUCT;
  psi:PSongInfo;
  hidden:bool;
  tmpstr:PAnsiChar;
  FrmText:pWideChar;
const
  TrackPos:integer=0;
  hBtnTimer:integer=0;

  procedure BtnRepos(btn:integer;offset:integer);
  var
    ly:integer;
  begin
    ly:=y-bg;
    if (ShowControls and scShowTrackBar)<>0 then
      dec(ly,th+bg);
    SetRect(CtrlPos[btn],w+offset,ly-bh,w+offset+bw,ly);
  end;

begin
  result:=0;
  wnd:=GetDlgItem(Dialog,IDC_FRM_POS);

  case hMessage of

    WM_DESTROY: begin
      if FrmChunk<>nil then
      begin
        DeleteChunks(FrmChunk);
        FrmChunk:=nil;
      end;
      mFreeMem(Cover);
{
      wnd:=GetParent(Dialog);
      wnd:=Dialog;
      SetWindowLong(wnd,GWL_EXSTYLE,GetWindowLong(wnd,GWL_EXSTYLE) and not WS_EX_LAYERED);
}
    end;

    WM_INITDIALOG: begin
      OldTrackProc:=pointer(GetWindowLong(wnd,GWL_WNDPROC));
      SetWindowLong(wnd,GWL_WNDPROC,dword(@TrackProc));
//      SendMessage(wnd,TBM_SETLINESIZE,0,1);
//      SendMessage(wnd,TBM_SETPAGESIZE,0,10);
      CtrlPushed:=0;
      CtrlHovered:=0;
      TrackPos:=0;
      result:=1;
    end;

    WM_CTLCOLORSTATIC: begin
      if lParam=wnd then
      begin
        result:=FrmBrush;
      end;
    end;

    WM_SIZE: begin
      if FrmBkBuf<>0 then
      begin
        DeleteDC(FrmBkBuf);
        DeleteObject(FrmBkBmp);
        FrmBkBuf:=0;
      end;
      WAFrameProc(Dialog,WM_WAREFRESH,frcBackPic,0);
      h:=CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
          FO_HEIGHT+(FrameId shl 16),0);
//!!
      if h>0 then
        DBWriteWord(0,PluginShort,opt_FrmHeight,h);

      GetClientRect(Dialog,rc);
      x:=rc.right-rc.left;
      y:=rc.bottom-rc.top;
      if (ShowControls and scShowButtons)<>0 then // buttons
      begin
        if ButtonGap=BST_UNCHECKED then
          sz:=bw
        else
          sz:=bw+4;
        if (ShowControls and scShowVolume)<>0 then
        begin
          w:=(x-sz*6-bw) div 2;
          BtnRepos(WAT_CTRL_VOLDN,0);
          BtnRepos(WAT_CTRL_VOLUP,bw);
          BtnRepos(WAT_CTRL_PREV ,sz*2);
          BtnRepos(WAT_CTRL_PLAY ,sz*3);
          BtnRepos(WAT_CTRL_PAUSE,sz*4);
          BtnRepos(WAT_CTRL_STOP ,sz*5);
          BtnRepos(WAT_CTRL_NEXT ,sz*6);
        end
        else
        begin
          SetRectEmpty(CtrlPos[WAT_CTRL_VOLUP]);
          SetRectEmpty(CtrlPos[WAT_CTRL_VOLDN]);
          w:=(x-sz*4-bw) div 2;
          BtnRepos(WAT_CTRL_PREV ,0);
          BtnRepos(WAT_CTRL_PLAY ,sz);
          BtnRepos(WAT_CTRL_PAUSE,sz*2);
          BtnRepos(WAT_CTRL_STOP ,sz*3);
          BtnRepos(WAT_CTRL_NEXT ,sz*4);
        end;
      end;
      if (ShowControls and scShowTrackBar)<>0 then // trackbar
        MoveWindow(wnd,rc.left,rc.bottom-th,x,th,true);
//!!
      DrawFrame(DF_ALL);
    end;

    WM_ERASEBKGND: begin
      result:=1;
    end;

    WM_PAINT: begin
      BeginPaint(Dialog,ps);
      DrawFrame(DF_ALL);
      EndPaint(Dialog,ps);
    end;

    WM_TIMER: begin
      case wParam of
        TMR_FRAME: begin
          WAFrameProc(FrameWnd{Dialog},WM_WAREFRESH,frcRefresh,0);
        end;
//!! scroll text (not only painting)
        TMR_TEXT: begin
          DrawFrame(DF_TEXT);
        end;
        TMR_BUTTON: begin
          x:=MaskToNum(CtrlPushed);
          CallService(MS_WAT_PRESSBUTTON,x,0);
        end;
      end;
    end;

    WM_LBUTTONUP: begin
      if CtrlPushed<>0 then
      begin
        x:=MaskToNum(CtrlPushed);
        if hBtnTimer<>0 then
        begin
          CallService(MS_WAT_PRESSBUTTON,x,0);
          KillTimer(FrameWnd{Dialog},hBtnTimer);
          hBtnTimer:=0;
        end;
        CtrlPushed:=0;
        DrawFrame(DF_BUTTON+(x shl 16));
      end;
    end;

    WM_MOUSEMOVE: begin
      if CtrlPushed<>0 then
      begin
        x:=MaskToNum(CtrlPushed);
        pt.x:=LoWord(lParam);
        pt.y:=lParam shr 16;
        if PtInRect(CtrlPos[x],pt) then
          exit;
        if hBtnTimer<>0 then
        begin
          CallService(MS_WAT_PRESSBUTTON,hBtnTimer,0);
          KillTimer(FrameWnd{Dialog},hBtnTimer);
          hBtnTimer:=0;
        end;
        CtrlPushed:=0;
      end
      else
      begin
        x:=FindButton(LoWord(lParam),lParam shr 16);
        if x<0 then
        begin
          if CtrlHovered<>0 then
          begin
            x:=MaskToNum(CtrlHovered);
            CtrlHovered:=0;
          end;
        end
        else
        begin
          if (CtrlHovered and (1 shl x))=0 then
          begin
            y:=MaskToNum(CtrlHovered);
            CtrlHovered:=1 shl x;
            if y<>0 then
              DrawFrame(DF_BUTTON+(y shl 16)); // uncovered button
          end;
        end;
      end;
      if x>0 then
      begin
        DrawFrame(DF_BUTTON+(x shl 16));
      end;
    end;
{
    WM_LBUTTONDBLCLK: begin
    end;
}
    WM_LBUTTONDOWN: begin
      if wParam=MK_LBUTTON then
      begin
        x:=FindButton(LoWord(lParam),lParam shr 16);
        if x>0 then
        begin
          CtrlPushed:=1 shl x;
          DrawFrame(DF_BUTTON+(x shl 16));

          if (x=WAT_CTRL_VOLUP) or (x=WAT_CTRL_VOLDN) then
          begin
            hBtnTimer:=SetTimer(FrameWnd,TMR_BUTTON,300,nil)
          end
          else
            CallService(MS_WAT_PRESSBUTTON,x,0);
        end
        else
        begin
          GetCursorPos(pt);
          result:=SendMessage(GetParent(FrameWnd{Dialog}),WM_SYSCOMMAND,
             SC_MOVE or HTCAPTION,MAKELPARAM(pt.x,pt.y));
        end;
      end
      else
        result:=1;
    end;

    WM_WAREFRESH: begin
      case wParam of
        // Initial fill
        frcInit: begin
          WAFrameProc(FrameWnd,WM_WAREFRESH,frcTimer,0);
          WAFrameProc(FrameWnd,WM_WAREFRESH,frcBackPic,1);
          if (ShowControls and scShowText)<>0 then
          begin
            FrmText:=pWideChar(CallService(MS_WAT_REPLACETEXT,0,dword(FrameText)));
            if FrmChunk<>nil then
              DeleteChunks(FrmChunk);
            FrmChunk:=Split(FrmText);
            mFreeMem(FrmText);
          end;
          if not IsFrameHidden then
          begin
            DrawFrame(DF_ALL);
          end;
        end;
        // init (clear)
        frcClear: begin
          if FrmChunk<>nil then
          begin
            DeleteChunks(FrmChunk);
            FrmChunk:=nil;
          end;
          mFreeMem(Cover);
          WAFrameProc(FrameWnd,WM_WAREFRESH,frcBackPic,1);
          if ((ShowControls and scShowText)<>0) and (lParam=0) then
          begin
            DrawFrame(DF_TEXT{ or DF_TRACKBAR});
          end;
        end;
        // refresh
        frcRefresh,frcForce: begin
          hidden:=IsFrameHidden;
          if vFrmTimer>0 then
          begin

            if (ShowControls and scShowText)<>0 then
            begin
              if (FrameText<>nil) and
                ((StrPosW(FrameText,'%time%'   )<>nil) or
                 (StrPosW(FrameText,'%percent%')<>nil)) or
                 (wParam=frcForce) then
              begin
                FrmText:=pWideChar(CallService(MS_WAT_REPLACETEXT,0,dword(FrameText)));
                if FrmChunk<>nil then
                  DeleteChunks(FrmChunk);
                FrmChunk:=Split(FrmText);
                mFreeMem(FrmText);
//!!
                if not hidden then
                  DrawFrame(DF_TEXT);
              end;
            end;

            if (ShowControls and scShowTrackBar)<>0 then
            begin
              if (TrackPos>=0) and
                 (CallService(MS_WAT_GETMUSICINFO,WAT_INF_CHANGES,dword(@psi))<>
                 WAT_PLS_NOTFOUND) then
                SendMessage(wnd,TBM_SETPOS,1,psi^.time*1000 div vFrmTimer);

              if not hidden then
                DrawFrame(DF_TRACKBAR);
            end;

          end;

          if (ShowControls and scShowButtons)<>0 then
          begin
            GetCursorPos(pt);
            GetWindowRect(FrameWnd,rc);
            x:=0;
            if not PtInRect(rc,pt) then
            begin
              if CtrlPushed<>0 then
              begin
                if hBtnTimer<>0 then
                begin
                  CallService(MS_WAT_PRESSBUTTON,hBtnTimer,0);
                  KillTimer(FrameWnd,hBtnTimer);
                  hBtnTimer:=0;
                end;
                x:=MaskToNum(CtrlPushed);
                CtrlPushed:=0;
              end
              else if CtrlHovered<>0 then
              begin
                x:=MaskToNum(CtrlHovered);
                CtrlHovered:=0;
              end;
              if not hidden and (x>0) then
              begin
                DrawFrame(DF_BUTTON+(x shl 16));
              end;
            end;
          end;

        end;
        // Show/hide components
        frcShowHide: begin
          h:=CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
               FO_HEIGHT+(FrameId shl 16),0);
          y:=h;

          if (lParam and scShowButtons)<>0 then // buttons
          begin
            if (ShowControls and scShowButtons)=0 then
              dec(h,bh+bg)
            else
              inc(h,bh+bg);
          end;
          if (lParam and scShowTrackBar)<>0 then // trackbar
          begin
            if (ShowControls and scShowTrackBar)=0 then
              dec(h,th+bg)
            else
              inc(h,th+bg);
          end;
          if (lParam and scShowText)<>0 then // text changed
          begin
            if (ShowControls and scShowText)=0 then
            begin
              FrameHeight:=h;
              if (ShowControls and scShowButtons)<>0 then
                dec(FrameHeight,bh+bg);
              if (ShowControls and scShowTrackBar)<>0 then
                dec(FrameHeight,th+bg);
              dec(h,FrameHeight);
            end
            else // Show Info
              inc(h,FrameHeight);
          end;

          if h=0 then
            h:=1;

          CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,
              FO_HEIGHT+(FrameId shl 16),h);

          if CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
                           FO_FLOATING+(FrameId shl 16),0)>0 then
          begin
            GetWindowRect(GetParent(FrameWnd),rc);
            SetWindowPos(GetParent(FrameWnd),0,rc.left,rc.top,
                rc.right-rc.left,rc.bottom-rc.top-y+h,0);
          end;

          if (ShowControls and scShowText)<>0 then
            WAFrameProc(FrameWnd,WM_WAREFRESH,frcForce,0);

          if (ShowControls and scShowTrackBar)=0 then
            ShowWindow(wnd,SW_HIDE)
          else
          begin
            WAFrameProc(FrameWnd,WM_WAREFRESH,frcTimer,0);
            ShowWindow(wnd,SW_SHOW);
          end;
//            SendMessage(GetParent(Dialog),WM_SIZE,SIZE_RESTORED,
//               (h shl 16)+rc.right);
          DrawFrame(DF_ALL);
          CallService(MS_CLIST_FRAMES_UPDATEFRAME,FrameId,
              FU_FMREDRAW+FU_FMPOS);
        end;
        // background picture
        frcBackPic: begin
          tmpstr:=ParseVarString(FrmBkPic);
          if lParam<>0 then // check the same file, ie only 'next pic'
          begin
            if (FrmUseCover<>BST_UNCHECKED) and (Cover<>nil) and (Cover^<>#0) then
            begin
              if cover=nil then
              begin
                if lastbkpic=nil then goto lExit;
              end
              else
              begin
                PAnsiChar(r):=strend(cover);
                while (PAnsiChar(r)^<>'\') do dec(PAnsiChar(r));
                if StrCmp(PAnsiChar(r),'\WAT_CO~1.',10)<>0 then
                  if StrCmp(Cover,lastbkpic)=0 then goto lExit;
              end;
            end
            else if (tmpstr<>nil) and (tmpstr^<>#0) then
            begin
              if StrCmp(tmpstr,lastbkpic)=0 then goto lExit;
            end;
          end;
          if FrmBkBuf<>0 then
          begin
            DeleteDC(FrmBkBuf);
            DeleteObject(FrmBkBmp);
            FrmBkBuf:=0;
          end;
          if (FrmUseCover<>BST_UNCHECKED) and (Cover<>nil) and (Cover^<>#0) then
          begin
            if isFreeImagePresent then
              hBkPic:=CallService(MS_IMG_LOAD,dword(Cover),0{IMGL_WCHAR})
            else
              hBkPic:=0;
            if hBkPic=0 then
              hBkPic:=CallService(MS_UTILS_LOADBITMAP,0,dword(Cover));
            if hBkPic<>0 then
            begin
              mFreeMem(lastbkpic);
              StrDup(lastbkpic,Cover);
              goto lExit;
            end;
          end;
          if (tmpstr<>nil) and (tmpstr^<>#0) then
          begin
            mFreeMem(lastbkpic);
            if isFreeImagePresent then
              hBkPic:=CallService(MS_IMG_LOAD,dword(tmpstr),0)
            else
              hBkPic:=0;
            if hBkPic=0 then
              hBkPic:=CallService(MS_UTILS_LOADBITMAP,0,dword(tmpstr));
            if hBkPic<>0 then
              StrDup(lastbkpic,tmpstr);
          end;
lExit:
          mFreeMem(tmpstr);
        end;
        frcTimer: begin
          if (ShowControls and scShowTrackBar)<>0 then
          begin
            if vFrmTimer>0 then
            begin
              x:=TotalTime*1000 div vFrmTimer;
              SendMessage(wnd,TBM_SETLINESIZE,0,x div 100);
              SendMessage(wnd,TBM_SETPAGESIZE,0,x div 10);
              SendMessage(wnd,TBM_SETRANGEMAX,1,x);
            end;
          end;
        end;
        frcSetAlpha: begin
          if @SetLayeredWindowAttributes<>nil  then
          begin
            if CallService(MS_CLIST_FRAMES_GETFRAMEOPTIONS,
                (FrameId shl 16)+FO_FLOATING,0)>0 then
            begin
              wnd:=GetParent(FrameWnd);
              x:=GetWindowLongW(wnd,GWL_EXSTYLE);
              if FrmAlpha<>255 then
              begin
                if (x and WS_EX_LAYERED)=0 then
                  SetWindowLongW(wnd,GWL_EXSTYLE,x or WS_EX_LAYERED);
                SetLayeredWindowAttributes(wnd,0,FrmAlpha,LWA_ALPHA);
              end
              else if (x and WS_EX_LAYERED)<>0 then
                SetWindowLongW(wnd,GWL_EXSTYLE,x and not WS_EX_LAYERED);
            end;
          end;
        end;
      end;
    end;

    WM_HSCROLL: begin
      if lParam=wnd then
      begin
        if LoWord(wParam)=SB_ENDSCROLL then
        begin
          x:=SendMessage(lParam,TBM_GETPOS,0,0);
          if x<>TrackPos then // to avoid doble execution
          begin
            TrackPos:=x;
            CallService(MS_WAT_PRESSBUTTON,WAT_CTRL_SEEK,Cardinal(x)*vFrmTimer div 1000);
          end
          else
            TrackPos:=-1;
        end
        else
          TrackPos:=-1;
      end;
    end;
  else
    DefWindowProc(Dialog,hMessage,wParam,lParam);
  end;
end;

function NewPlStatus(wParam:WPARAM;lParam:LPARAM):int;cdecl;
const
  needToChange:boolean=true;
var
  buf:array [0..127] of AnsiChar;
  bufw:array [0..511] of WideChar;
  tmp:integer;
begin
  result:=0;
  case wParam of
{
    WAT_EVENT_NEWTEMPLATE: begin
      if lParam=TM_FRAMEINFO then
        SendMessage(FrameWnd,WM_WAREFRESH,frcForce,0);
    end;
}
    WAT_EVENT_PLAYERSTATUS: begin
      case lParam of
        WAT_PLS_NORMAL  : exit;//SetFrameTitle(PSongInfo(lParam));
        WAT_PLS_NOMUSIC : begin
          if HideFrameNoMusic<>BST_UNCHECKED then
          begin
            HideFrame;
            tmp:=1;
          end
          else
          begin
            tmp:=ShowFrame;
          end;
          SendMessage(FrameWnd,WM_WAREFRESH,frcClear,tmp);
        end;
        WAT_PLS_NOTFOUND: begin
          if HideFrameNoPlayer<>BST_UNCHECKED then
            HideFrame;
          SetFrameTitle('',0);
          needToChange:=true;
          CallService(MS_CLIST_FRAMES_SETFRAMEOPTIONS,(FrameId shl 16)+FO_TBNAME,
                      dword(PluginShort));
          SendMessage(FrameWnd,WM_WAREFRESH,frcClear,1);
          if not IsFrameHidden then
            CallService(MS_CLIST_FRAMES_UPDATEFRAME,FrameId,FU_TBREDRAW);
        end;
      end;
      DrawFrame(DF_ALL);
//      InvalidateRect(FrameWnd,0,false); //??
    end;
    WAT_EVENT_NEWTRACK: begin
      mFreeMem(Cover);
      if (PSongInfo(lParam)^.Cover<>nil) and (PSongInfo(lParam)^.Cover^<>#0) then
      begin
        GetShortPathNameW(PSongInfo(lParam)^.Cover,bufw,SizeOf(bufw));
        WideToAnsi(bufw,Cover);
      end;

      TotalTime:=PSongInfo(lParam)^.total;
      SendMessage(FrameWnd,WM_WAREFRESH,frcInit,0);
      if needToChange then // only if not player replacing without pause
      begin
        FastWideToAnsiBuf(PSongInfo(lParam)^.player,buf);
        SetFrameTitle(buf,PSongInfo(lParam)^.icon);
        needToChange:=false;
      end;
      ShowFrame;
    end;
    WAT_EVENT_NEWPLAYER: begin
      needToChange:=true;
    end;
    WAT_EVENT_PLUGINSTATUS: begin
      case lParam of
        dsEnabled: ShowFrame;
        dsPermanent: HideFrame;
      end;
    end;
  end;
end;

procedure CreateFrame(parent:HWND);
var
  Frame:TCLISTFrame;
  rc:TRECT;
  tmp:HWND;
  p:PSongInfo;
begin
  if PluginLink^.ServiceExists(MS_CLIST_FRAMES_ADDFRAME)=0 then
    exit;
  hBkPic:=0;
  FrmBkBuf:=0;
  if parent=0 then
    parent:=CallService(MS_CLUI_GETHWND,0,0);
  if FrameWnd=0 then
    FrameWnd:=CreateDialog(hInstance,'WAFRAME',parent,@WAFrameProc);
  if FrameWnd<>0 then
  begin
    FillChar(Frame,SizeOf(Frame),0);
    with Frame do
    begin
      cbSize  :=SizeOf(Frame);
      hWnd    :=FrameWnd;
      hIcon   :=0;
      align   :=alTop;
      GetClientRect(FrameWnd,rc);
      height  :=DBReadWord(0,PluginShort,opt_FrmHeight,rc.bottom-rc.top);
      Flags   :=0;//{F_VISIBLE or} F_SHOWTB;
      name.a  :=PluginShort;
      TBName.a:=PluginShort;
    end;
    FrameHeight:=Frame.height;
    FrmBrush:=CreateSolidBrush(FrmBkColor);
    if StyledTrack<>BST_UNCHECKED then
    begin
      tmp:=GetDlgItem(FrameWnd,IDC_FRM_POS);
      SetWindowLongW(tmp,GWL_EXSTYLE,
          GetWindowLongW(tmp,GWL_EXSTYLE) or WS_EX_TRANSPARENT);
    end;
    FrameId:=CallService(MS_CLIST_FRAMES_ADDFRAME,dword(@Frame),0);
    if FrameId>=0 then
    begin
      plStatusHook:=PluginLink^.HookEvent(ME_WAT_NEWSTATUS,@NewPlStatus);

      if CallService(MS_WAT_PLUGINSTATUS,2,0)<>WAT_RES_DISABLED then
      begin
        SendMessage(FrameWnd,WM_WAREFRESH,frcSetAlpha,0);
        if (ShowControls and scShowTrackBar)=0 then
          ShowWindow(GetDlgItem(FrameWnd,IDC_FRM_POS),SW_HIDE);
      end;
      DrawFrame(DF_ALL); //??
  //    InvalidateRect(FrameWnd,nil,true);

      if ((FrmEffect=effRoll) or (FrmEffect=effPong)) then
        if vTxtTimer>0 then
          hTxtTimer:=SetTimer(FrameWnd,TMR_TEXT,(MaxTxtScrollSpeed+1-vTxtTimer)*100,nil)
        else
          hTxtTimer:=0;

      if vFrmTimer>0 then
        hFrmTimer:=SetTimer(FrameWnd,TMR_FRAME,vFrmTimer,nil)
      else
        hFrmTimer:=0;

      if CallService(MS_WAT_GETMUSICINFO,WAT_INF_UNICODE,dword(@p))<>
         WAT_PLS_NOTFOUND then
      begin
        if p^.status<>WAT_MES_STOPPED then
          NewPlStatus(WAT_EVENT_NEWTRACK,dword(p));
      end;
    end;
  end;
end;

procedure DestroyFrame;
begin
  if hFrmTimer<>0 then
  begin
    KillTimer(FrameWnd,hFrmTimer);
    hFrmTimer:=0;
  end;
  if hTxtTimer<>0 then
  begin
    KillTimer(FrameWnd,hTxtTimer);
    hTxtTimer:=0;
  end;

  if FrameId>=0 then
  begin
    PluginLink^.UnhookEvent(plStatusHook);
    CallService(MS_CLIST_FRAMES_REMOVEFRAME,FrameId,0);
    DestroyWindow(FrameWnd);
    DeleteObject(FrmBrush);
    FrameId:=-1;
  end;
  FrameWnd:=0;
end;

{$include frm_dlg1.inc}
{$include frm_dlg2.inc}

// ---------------- base interface procedures ----------------
function InitProc(aGetStatus:boolean=false):integer;
var
  buf:array [0..255] of WideChar;
  size:integer;
  pc:pWideChar;
begin
  if aGetStatus then
  begin
    if GetModStatus=0 then
    begin
      result:=0;
      exit;
    end;
  end
  else
    SetModStatus(1);
  result:=1;

  FrameWnd:=0;
  FrameId :=-1;
  FrmChunk:=nil;
  TotalTime:=0;
  isFreeImagePresent:=PluginLink^.ServiceExists(MS_IMG_LOAD)<>0;
  loadframe;

  RegisterButtonIcons;
  sic:=PluginLink^.HookEvent(ME_SKIN2_ICONSCHANGED,@IconChanged);

  CreateFrame(0);

  FillChar(buf,SizeOf(buf),0);
  StrCopyW(buf,TranslateW('All Bitmaps'));
  StrCatW (buf,' (*.bmp;*.jpg;*.gif;*.png)');
  pc:=StrEndW(buf)+1;
  StrCopyW(pc,'*.BMP;*.RLE;*.JPG;*.JPEG;*.GIF;*.PNG');
  size:=(StrEndW(pc)+2-@buf)*SizeOf(WideChar);
  mGetMem(BMPFilter,size);
  move(buf,BMPFilter^,size);
end;

procedure DeInitProc(aSetDisable:boolean);
begin
  if aSetDisable then
    SetModStatus(0);

  DBWriteByte(0,PluginShort,opt_HiddenByMe,ord(HiddenByMe));
  PluginLink^.UnhookEvent(sic);
  mFreeMem(BMPFilter);
  mFreeMem(FrameText);
  DestroyFrame;
end;

function AddOptionsPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
const
  count:integer=2;
begin
  if count=0 then
    count:=2;
  if count=2 then
  begin
    tmpl:='FRAME';
    proc:=@DlgProcOptions5;
    name:='Frame (main)';
  end
  else
  begin
    tmpl:='FRAME2';
    proc:=@DlgProcOptions51;
    name:='Frame (text)';
  end;

  dec(count);
  result:=count;
end;

var
  Frame:twModule;

procedure Init;
begin
  Frame.Next      :=ModuleLink;
  Frame.Init      :=@InitProc;
  Frame.DeInit    :=@DeInitProc;
  Frame.AddOption :=@AddOptionsPage;
  Frame.ModuleName:='Frame';
  ModuleLink      :=@Frame;
end;

begin
  Init;
end.
