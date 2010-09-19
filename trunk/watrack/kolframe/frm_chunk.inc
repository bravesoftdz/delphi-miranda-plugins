{Text Chunk processing: frame text output}

const // chunk type
  CT_TEXT    = $01;
  CT_TAB     = $09;
  CT_SPACE   = $20;
  CT_NEWLINE = $0D;

const // macro codes
  ctOpenBold       = 1;
  ctCloseBold      = 2;
  ctOpenItalic     = 3;
  ctCloseItalic    = 4;
  ctOpenUnderline  = 5;
  ctCloseUnderline = 6;
  ctOpenTextColor  = 7;
  ctCloseTextColor = 8;
  ctOpenBkColor    = 9;
  ctCloseBkColor   = 10;
  ctRGB            = 100; // special code for RGB color values

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

procedure ProcessMacro(dc:hdc;Chunk:pChunk);
var
  lf:TLOGFONT;
  i:integer;
begin
  if dc=0 then
    exit;
  if Chunk._Type=CT_NEWLINE then
    exit;
  case Chunk^._type shr 16 of
    ctCloseTextColor: begin
      SetTextColor(dc,TextColor);
    end;

    ctCloseBkColor: begin
      SetBkColor(dc,BkColor);
      SetBkMode(dc,TRANSPARENT);
    end;

    ctOpenBkColor: begin
      case Chunk^.val of
        0:     i:=BkColor;
        1..16: i:=colors[Chunk^.val-1];
      else // and 17
        i:=TextColor;
      end;
      SetTextColor(dc,i);
    end;

    ctOpenTextColor: begin
      SetBkMode(dc,OPAQUE);
      case Chunk^.val of
        1..16: i:=colors[Chunk^.val-1];
        17:    i:=TextColor
      else // and 0
        i:=BkColor;
      end;
      SetBkColor(dc,i);
    end;

    ctOpenTextColor+ctRGB: begin
      SetTextColor(dc,Chunk^.val);
    end;

    ctOpenBkColor+ctRGB: begin
      SetBkMode(dc,OPAQUE);
      SetBkColor(dc,Chunk^.val);
    end;

  else
    begin
      GetObject(GetCurrentObject(dc,OBJ_FONT),SizeOf(lf),@lf);
      case Chunk^._type shr 16 of
        ctOpenBold      : lf.lfWeight   :=FW_BOLD;
        ctCloseBold     : lf.lfWeight   :=FW_NORMAL;
        ctOpenItalic    : lf.lfItalic   :=1;
        ctCloseItalic   : lf.lfItalic   :=0;
        ctOpenUnderline : lf.lfUnderline:=1;
        ctCloseUnderline: lf.lfUnderline:=0;
      end;
      DeleteObject(SelectObject(dc,CreateFontIndirect(lf)));
    end;
  end;
end;

function Macro(var src:pWideChar;var Chunk:pChunk):boolean;
const
  NumMacro = 10;
  macros:array [0..NumMacro-1] of record txt:pWideChar; len:integer; code:integer; end = (
  (txt:'{b}'  ; len:3; code:ctOpenBold      ),
  (txt:'{/b}' ; len:4; code:ctCloseBold     ),
  (txt:'{i}'  ; len:3; code:ctOpenItalic    ),
  (txt:'{/i}' ; len:4; code:ctCloseItalic   ),
  (txt:'{u}'  ; len:3; code:ctOpenUnderline ),
  (txt:'{/u}' ; len:4; code:ctCloseUnderline),
  (txt:'{/cf}'; len:5; code:ctOpenTextColor ),
  (txt:'{/bg}'; len:5; code:ctCloseTextColor),
  (txt:'{cf'  ; len:3; code:ctOpenBkColor   ),
  (txt:'{bg'  ; len:3; code:ctCloseBkColor  ));
var
  pc,pc1:pWideChar;
  typ,i,lval:integer;
  c:WideChar;
begin
  result:=false;
  if src^<>'{' then exit;
  pc:=src;
  lval:=0;
  for i:=0 to NumMacro-1 do
  begin
    if StrCmpW(pc,macros[i].txt,macros[i].len)=0 then
    begin
      typ:=macros[i].code;
      if typ in [ctOpenBkColor, ctOpenTextColor] then // processing color codes
      begin
        inc(pc,macros[i].len);
        if (pc^='#') or ((pc^>='0') and (pc^<='9')) then
        begin
          pc1:=pc;
          if pc^='#' then
            repeat
              inc(pc1);
              c:=pc1^;
            until ((c<'0') or (c>'9')) and
                  ((c<'A') or (c>'F')) and
                  ((c<'a') or (c>'f'))
          else
            repeat
              inc(pc1);
            until (pc1^<'0') or (pc1^>'9');
          if pc1^='}' then
          begin
            result:=true;
            if (pc^='#') then // RGB
            begin
              inc(typ,ctRGB);
              lval:=HexToInt(pc+1);
            end
            else
            begin
              lval:=StrToInt(pc) mod 18;
            end;
            src:=pc1+1;
          end;
        end;
      end
      else
      begin
        inc(src,macros[i].len);
        result:=true;
      end;
      break;
    end;
  end;
  if result then
  begin
    with Chunk^ do
    begin
      _type:=typ shl 16;
      val  :=lval;
      dir  :=ppLeft;
    end;
    inc(Chunk,SizeOf(tChunk));
  end;
end;

function CreateTextChunk(var Chunk:pChunk;src:pWideChar):pWideChar;
var
  i:integer;
begin
  result:=src;
  while ((result^>='A') and (result^<='Z')) or
        ((result^>='a') and (result^<='z')) or
        ((result^>='0') and (result^<='9')) or
        (ORD(result^)>127) do
    inc(result);
  i:=src-result;
  if i>0 then // if no text (but what is this then?)
  begin
    with Chunk^ do
    begin
      _type:=CT_TEXT;
      dir  :=ppLeft;
      txt  :=src;
      val  :=i;
    end;
    inc(Chunk,SizeOf(tChunk));
  end;
end;

function CreateSignChunk(var Chunk:pChunk;src:PWideChar):PWideChar;
begin
  with Chunk^ do
  begin
    _type:=ord(src^);
    add  :=0;
    dir  :=ppLeft;
    val  :=1;
  end;
  result:=src;
  inc(result);
  inc(Chunk,SizeOf(tChunk));
end;

function Split(src:pWideChar):pChunkArray;
var
  p:pWideChar;
  Chunk:pChunk;
  i:integer;
begin
  result:=nil;
  if src=nil then exit;

  i:=StrLenW(src)*SizeOf(tChunk)+1; // last = 0 (powered finalization
  mGetMem(result,i);
  FillChar(result^,i,0);
  Chunk:=@result[0];

  while src^<>#0 do
  begin
    // signes
    while not (((src^>='A') and (src^<='Z')) or
               ((src^>='a') and (src^<='z')) or
               ((src^>='0') and (src^<='9'))) do
    begin
      if (ORD(src^)>127) or (src^='{') then
        break;
      if src^<>#10 then
        src:=CreateSignChunk(Chunk,src)
      else
        inc(src);
      if src^=#0 then exit;
    end;
    // macro: [b][/b][i][/i][u][/u][cf][/cf][bg][/bg]
    if Macro(src,Chunk) then
    begin
    end
    // "{" sign
    else if src^='{' then // if not macro
    begin
      src:=CreateSignChunk(Chunk,src);
    end
    // Unicode/text
    else
    begin
      src:=CreateTextChunk(Chunk,src);
    end;
  end;
end;

procedure DeleteChunks(var Chunk:pChunkArray);
begin
  mFreeMem(Chunk);
end;

procedure MeasureChunk(dc:HDC;Chunk:pChunk;var sz:TSIZE;block:Boolean);
var
  p:pWideChar;
begin
  if ((Chunk^._type shr 16)=0) and (Chunk^._type<>CT_NEWLINE) then
  begin
    if Chunk^._type=CT_TEXT then
      p:=Chunk^.txt
    else
    begin
      p:=@WideChar(Chunk^._type);
    end;
    GetTextExtentPoint32W(dc,p,Chunk^.val,sz);
  end
  else
  begin
    if block then
      ProcessMacro(dc,Chunk);
    sz.cx:=0;
    sz.cy:=0;
  end;
end;

procedure MeasureLine(dc:HDC;Chunk:pChunk;var sz:TSIZE;limit:integer=4096);
var
  csz:TSIZE;
//  fnt1:HFONT;
  lf:TLOGFONT;
  txtcolor,bkcolor:COLORREF;
  bkmode:integer;
begin
  sz.cx:=0;
  sz.cy:=0;
{
    fnt1:=SelectObject(dc,CreateFontIndirect(FrameLF));

    DeleteObject(SelectObject(dc,fnt1));
}
  txtcolor:=GetTextColor(dc);
  bkcolor :=GetBkColor(dc);
  bkmode  :=GetBkMode(dc);
  GetObject(GetCurrentObject(dc,OBJ_FONT),SizeOf(lf),@lf);

  while (Chunk^._type<>0) and (Chunk^._type<>CT_NEWLINE) do
  begin
    MeasureChunk(dc,Chunk,csz,true);
    if (sz.cx+csz.cx)<limit then
    begin
      inc(sz.cx,csz.cx);
      if sz.cy<csz.cy then
        sz.cy:=csz.cy;
    end
//!!
    else if limit<>4096 then
      break;
    inc(Chunk,SizeOf(tChunk));
  end;

  DeleteObject(SelectObject(dc,CreateFontIndirect(lf)));
  SetTextColor(dc,txtcolor);
  SetBkColor  (dc,bkcolor);
  SetBkMode   (dc,bkmode);
end;

procedure DrawChunk(dc:HDC;Chunk:pChunk;rc:TRECT);
var
  p:pWideChar;
begin
  if (Chunk^._type shr 16)=0 then
  begin
    if Chunk^._type=CT_TEXT then
      p:=Chunk^.txt
    else
      p:=@WideChar(Chunk^._type);

    DrawTextW(dc,p,Chunk^.val,rc,
      DT_LEFT or DT_TOP or DT_SINGLELINE or DT_NOPREFIX or DT_EXPANDTABS)
  end
  else
    ProcessMacro(dc,Chunk);
end;

procedure DrawLine(dc:HDC;var Chunk:pChunk;rc:TRECT);
var
  sz:TSIZE;
begin
  while (Chunk^._type<>0) and (Chunk^._type<>CT_NEWLINE) do
  begin
    MeasureChunk(dc,Chunk,sz,false);
    if (rc.left<rc.right) and ((rc.left+sz.cx)>0) then
      DrawChunk(dc,Chunk,rc)
    else if (Chunk^._type shr 16)<>0 then
      ProcessMacro(dc,Chunk);
    inc(rc.left,sz.cx);
    inc(Chunk,SizeOf(tChunk));
  end;
end;

procedure DrawLines(dc:HDC;Chunk:pChunk;rc:TRECT;justpaint:boolean);
var
  sz:TSIZE;
  rc1:TRECT;
  w:integer;
  rgn:HRGN;
  ch:pChunk;
begin
//  InflateRect(rc,-10,-3);
  rgn:=CreateRectRgnIndirect(rc);
  CopyRect(rc1,rc);
  SelectClipRgn(dc,rgn);
  w:=rc.Right-rc.left;
  while Chunk^._type<>0 do
  begin
    MeasureLine(dc,Chunk,sz);
    if sz.cx>0 then
    begin
      rc1.left:=rc.left;
      if sz.cx<w then
      begin
        //!!
        rc1.top:=rc.top;
        if AlignCenter<>BST_UNCHECKED then
          inc(rc1.left,(w-sz.cx) div 2);

        DrawLine(dc,Chunk,rc1)
      end
      else
      begin
        rc1.top:=rc.top;
        if TextEffect=effRoll then
        begin
// direction!!
// sz - linesize ; w - frame width, chunk^add = chunk size
          inc(sz.cx,RollGap);
          rc1.left:=rc.left-Chunk^.add;
          if (sz.cx-Chunk^.add)<w then
          begin
            ch:=Chunk;
            DrawLine(dc,ch,rc1);
            rc1.left:=rc1.left+sz.cx;
          end;
          if not justpaint then
          begin
            inc(Chunk^.add,RollStep);
            if Chunk^.add>=sz.cx then
              Chunk^.add:=0;
          end;
{
          inc(sz.cx,RollGap);
          rc1.left:=rc.left-Chunk^.add;
          if (sz.cx-Chunk^.add)<w then
          begin
            ch:=Chunk;
            DrawLine(dc,ch,rc1);
            rc1.left:=rc1.left+sz.cx;
          end;
          if not justpaint then
          begin
            inc(Chunk^.add,RollStep);
            if Chunk^.add>=sz.cx then
              Chunk^.add:=0;
          end;
}
        end
        else
        begin
          if not justpaint then
          begin
            if Chunk^.dir=ppLeft then
            begin
              inc(Chunk^.add,RollStep);
              if (sz.cx-Chunk^.add)<(w-RollGap) then
              begin
                Chunk^.dir:=ppRight;
              end;
            end
            else
            begin
              dec(Chunk^.add,RollStep);
              if Chunk^.add<=-RollGap then
              begin
                Chunk^.dir:=ppLeft;
              end;
            end;
          end;
          rc1.left:=rc.left-Chunk^.add;
        end;
        DrawLine(dc,Chunk,rc1) // with offset
      end;
    end
    else
      DrawChunk(dc,Chunk,rc1);
    inc(rc.top,sz.cy);

    if rc.top>rc.bottom then
      break;
    if Chunk^._type<>0 then
      inc(Chunk,SizeOf(tChunk));
  end;
  SelectClipRgn(dc,0);
  DeleteObject(rgn);
end;

procedure DrawChunks(dc:HDC;Chunk:pChunk;rc:TRECT;justpaint:boolean);
var
  sz:TSIZE;
  rc1:TRECT;
  h:integer;
  w:integer;
begin
  if (TextEffect=effRoll) or (TextEffect=effPong) then
  begin
    DrawLines(dc,Chunk,rc,justpaint);
    exit;
  end;
  CopyRect(rc1,rc);
  w:=rc.right-rc.left;
  h:=0;
//!!
  if AlignCenter<>BST_UNCHECKED then
  begin
    MeasureLine(dc,Chunk,sz,w);
    inc(rc1.left,(w-sz.cx) div 2);
  end;
  while Chunk^._type<>0 do
  begin
    MeasureChunk(dc,Chunk,sz,false);
    if sz.cx>0 then
    begin
      rc1.right:=rc1.left+sz.cx;
      if rc1.right>rc.right then //!!!
      begin
        case TextEffect of
          effCut: begin

            if rc1.left<rc.right then
            begin
              rc1.right:=rc.right;
              DrawChunk(dc,Chunk,rc1);
            end;

            inc(Chunk,SizeOf(tChunk));
            inc(rc1.left,sz.cx);
            continue;
          end;

          effWrap: begin
            if sz.cx>=w then
            begin
              while (Chunk<>nil) and (Chunk^._type<>CT_NEWLINE) do
              begin
                if (Chunk^._type shr 16)<>0 then
                  ProcessMacro(dc,Chunk);
                inc(Chunk,SizeOf(tChunk));
              end;
              if Chunk=nil then
                exit;
            end;
            inc(rc1.top,h);
            rc1.left:=rc.left;
        //!!
            if AlignCenter<>BST_UNCHECKED then
            begin
              MeasureLine(dc,Chunk,sz,w);
              inc(rc1.left,(w-sz.cx) div 2);
              continue;
            end;
          end;
        end;
      end;
      rc1.bottom:=rc1.top+sz.cy;
      if rc1.bottom>rc.bottom then
      begin
        break;
      end;
      DrawChunk(dc,Chunk,rc1);
      inc(rc1.left,sz.cx);
      if h<sz.cy then
        h:=sz.cy;
    end
    else
    begin
      if Chunk^._type=CT_NEWLINE then
      begin
        inc(rc1.top,h);
        rc1.left:=rc.left;
    //!!
        if AlignCenter<>BST_UNCHECKED then
        begin
          inc(Chunk,SizeOf(tChunk));
          MeasureLine(dc,Chunk,sz,w);
//          if sz.cx<w then
          inc(rc1.left,(w-sz.cx) div 2);
          continue;
        end;
      end
      else
        ProcessMacro(dc,Chunk);
//        DrawChunk(dc,Chunk,rc1);
    end;
    inc(Chunk,SizeOf(tChunk));
  end;
end;
