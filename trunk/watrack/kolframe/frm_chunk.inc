{Text Chunk processing: frame text output}

type
  pChunk = ^tChunk;
  tChunk = record
    next:pChunk;
    _type:integer;   // type
    val  :integer;   // sign value
    txt  :pWideChar; // text value
    add  :integer;   // offset for text effect
    dir  :integer;   // ping-pong directon
  end;

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
    7: begin
      SetTextColor(dc,FrmTxtColor);
    end;
    8: begin
      SetBkColor(dc,FrmBkColor);
      SetBkMode(dc,TRANSPARENT);
    end;
    9: begin
      case Chunk^.val of
        0:     i:=FrmBkColor;
        1..16: i:=colors[Chunk^.val-1];
      else // and 17
        i:=FrmTxtColor;
      end;
      SetTextColor(dc,i);
    end;
    10: begin
      SetBkMode(dc,OPAQUE);
      case Chunk^.val of
        1..16: i:=colors[Chunk^.val-1];
        17:    i:=FrmTxtColor
      else // and 0
        i:=FrmBkColor;
      end;
      SetBkColor(dc,i);
    end;
    109: begin
      SetTextColor(dc,Chunk^.val);
    end;
    110: begin
      SetBkMode(dc,OPAQUE);
      SetBkColor(dc,Chunk^.val);
    end;
  else
    begin
      GetObject(GetCurrentObject(dc,OBJ_FONT),SizeOf(lf),@lf);
      case Chunk^._type shr 16 of
        1: lf.lfWeight:=FW_BOLD;
        2: lf.lfWeight:=FW_NORMAL;
        3: lf.lfItalic:=1;
        4: lf.lfItalic:=0;
        5: lf.lfUnderline:=1;
        6: lf.lfUnderline:=0;
      end;
      DeleteObject(SelectObject(dc,CreateFontIndirect(lf)));
    end;
  end;
end;

function Macro(var src:pWideChar;var Chunk:pChunk):boolean;
const
  NumMacro = 10;
  macros:array [1..NumMacro] of record txt:pWideChar; len:integer; end = (
  (txt:'{b}'  ; len:3),
  (txt:'{/b}' ; len:4),
  (txt:'{i}'  ; len:3),
  (txt:'{/i}' ; len:4),
  (txt:'{u}'  ; len:3),
  (txt:'{/u}' ; len:4),
  (txt:'{/cf}'; len:5),
  (txt:'{/bg}'; len:5),
  (txt:'{cf'  ; len:3),
  (txt:'{bg'  ; len:3));
var
  pc,pc1:pWideChar;
  typ,i,lval:integer;
  ch:pChunk;
  c:WideChar;
begin
  result:=false;
  if src^<>'{' then exit;
  pc:=src;
  for i:=1 to NumMacro do
  begin
    if StrCmpW(pc,macros[i].txt,macros[i].len)=0 then
    begin
      typ:=i;
      lval:=0;
      if i>8 then
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
              inc(typ,100);
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
    mGetMem(ch,SizeOf(tChunk));
    with ch^ do
    begin
      next :=nil;
      _type:=typ shl 16;
      val  :=lval;
      add  :=0;
      dir  :=ppLeft;
    end;
    if Chunk<>nil then
      Chunk^.next:=ch;
    Chunk:=ch;
  end;
end;

function CreateTextChunk(var Chunk:pChunk;src:pWideChar;len:integer):pChunk;
begin
  mGetMem(result,SizeOf(tChunk));
  with result^ do
  begin
    next :=nil;
    _type:=CT_TEXT;
    add  :=0;
    dir  :=ppLeft;
  end;
  if len>0 then
  begin
    result^.val:=len;
    StrDupW(result^.txt,src,len);
  end
  else
    result^.txt:=nil;
  if Chunk<>nil then
    Chunk^.next:=result;
  Chunk:=result;
end;

function CreateSignChunk(var Chunk:pChunk;src:WideChar):pChunk;
begin
  mGetMem(result,SizeOf(tChunk));
  with result^ do
  begin
    next :=nil;
    _type:=ord(src);
    add  :=0;
    dir  :=ppLeft;
  end;
  if Chunk<>nil then
    Chunk^.next:=result;
  Chunk:=result;
end;

function Split(src:pWideChar):pChunk;
var
  p:pWideChar;
  Chunk:pChunk;
begin
  result:=nil;
  Chunk:=nil;
  if src=nil then exit;
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
      begin
        CreateSignChunk(Chunk,src^);
        if result=nil then
          result:=Chunk;
      end;
      inc(src);
      if src^=#0 then exit;
    end;
    // macro: [b][/b][i][/i][u][/u][cf][/cf][bg][/bg]
    if Macro(src,Chunk) then
    begin
    end
    // Unicode/text
    else if src^='{' then // if not macro
    begin
      CreateSignChunk(Chunk,src^);
      inc(src);
    end
    else
    begin
      p:=src;
      while ((p^>='A') and (p^<='Z')) or
            ((p^>='a') and (p^<='z')) or
            ((p^>='0') and (p^<='9')) or
            (ORD(p^)>127) do
        inc(p);
      CreateTextChunk(Chunk,src,p-src);
      src:=p;
    end;
    if result=nil then
      result:=Chunk;
  end;
end;

procedure DeleteChunks(var Chunk:pChunk);
var
  c:pChunk;
begin
  while Chunk<>nil do
  begin
    if Chunk^._type=CT_TEXT then
      mFreeMem(Chunk^.txt);
    c:=Chunk;
    Chunk:=Chunk^.next;
    mFreeMem(c);
  end;
end;

procedure MeasureChunk(dc:HDC;Chunk:pChunk;var sz:TSIZE;block:Boolean);
var
  buf:array [0..1] of WideChar;
  p:pWideChar;
begin
  if ((Chunk^._type shr 16)=0) and (Chunk^._type<>CT_NEWLINE) then
  begin
    if Chunk^._type=CT_TEXT then
      p:=Chunk^.txt
    else
    begin
      buf[0]:=WideChar(Chunk^._type);
      buf[1]:=#0;
      p:=@buf;
    end;
    GetTextExtentPoint32W(dc,p,StrLenW(p),sz);
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
  bkcolor:=GetBkColor(dc);
  bkmode:=GetBkMode(dc);
  GetObject(GetCurrentObject(dc,OBJ_FONT),SizeOf(lf),@lf);
  while (Chunk<>nil) and (Chunk^._type<>CT_NEWLINE) do
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
    Chunk:=Chunk^.next;
  end;
  DeleteObject(SelectObject(dc,CreateFontIndirect(lf)));
  SetTextColor(dc,txtcolor);
  SetBkColor(dc,bkcolor);
  SetBkMode(dc,bkmode);
end;

procedure DrawChunk(dc:HDC;Chunk:pChunk;rc:TRECT);
var
  buf:array [0..1] of WideChar;
  p:pWideChar;
begin
  if (Chunk^._type shr 16)=0 then
  begin
    if Chunk^._type=CT_TEXT then
      p:=Chunk^.txt
    else
    begin
      buf[0]:=WideChar(Chunk^._type);
      buf[1]:=#0;
      p:=@buf;
      Chunk^.val:=1;
    end;
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
  while (Chunk<>nil) and (Chunk^._type<>CT_NEWLINE) do
  begin
    MeasureChunk(dc,Chunk,sz,false);
    if (rc.left<rc.right) and ((rc.left+sz.cx)>0) then
      DrawChunk(dc,Chunk,rc)
    else if (Chunk^._type shr 16)<>0 then
      ProcessMacro(dc,Chunk);
    inc(rc.left,sz.cx);
    Chunk:=Chunk^.next;
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
  while Chunk<>nil do
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
        if FrmEffect=effRoll then
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
    if Chunk<>nil then
      Chunk:=Chunk^.next;
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
  if (FrmEffect=effRoll) or (FrmEffect=effPong) then
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
  while Chunk<>nil do
  begin
    MeasureChunk(dc,Chunk,sz,false);
    if sz.cx>0 then
    begin
      rc1.right:=rc1.left+sz.cx;
      if rc1.right>rc.right then //!!!
      begin
        case FrmEffect of
          effCut: begin

            if rc1.left<rc.right then
            begin
              rc1.right:=rc.right;
              DrawChunk(dc,Chunk,rc1);
            end;

            Chunk:=Chunk^.next;
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
                Chunk:=chunk^.next;
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
          MeasureLine(dc,Chunk^.next,sz,w);
//          if sz.cx<w then
          inc(rc1.left,(w-sz.cx) div 2);
        end;
      end
      else
        ProcessMacro(dc,Chunk);
//        DrawChunk(dc,Chunk,rc1);
    end;
    Chunk:=Chunk^.next;
  end;
end;
