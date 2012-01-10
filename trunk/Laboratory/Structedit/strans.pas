{}
unit strans;

interface

uses windows;

const
  char_separator = '|';
  char_hex       = '$';
  char_return    = '*';
  char_script    = '%';
{$IFDEF Miranda}
  char_mmi       = '&';
{$ENDIF}
const
  SST_BYTE    = 0;
  SST_WORD    = 1;
  SST_DWORD   = 2;
  SST_QWORD   = 3;
  SST_NATIVE  = 4;
  SST_BARR    = 5;
  SST_WARR    = 6;
  SST_BPTR    = 7;
  SST_WPTR    = 8;
  SST_LAST    = 9;
  SST_PARAM   = 10;
  SST_UNKNOWN = -1;

type
  // int_ptr = to use aligned structure data at start
  PStructResult = ^TStructResult;
  TStructResult = record
    typ   :int_ptr;
    len   :int_ptr;
    offset:int_ptr;
  end;
type
  TStructType = record
    typ  :integer;
    short:PAnsiChar;
    full :PAnsiChar;
  end;
const
  MaxStructTypes = 11;
const
  StructElems: array [0..MaxStructTypes-1] of TStructType = (
    (typ:SST_BYTE  ; short:'byte'  ; full:'Byte'),
    (typ:SST_WORD  ; short:'word'  ; full:'Word'),
    (typ:SST_DWORD ; short:'dword' ; full:'DWord'),
    (typ:SST_QWORD ; short:'qword' ; full:'QWord'),
    (typ:SST_NATIVE; short:'native'; full:'NativeInt'),
    (typ:SST_BARR  ; short:'b.arr' ; full:'Byte Array'),
    (typ:SST_WARR  ; short:'w.arr' ; full:'Word Array'),
    (typ:SST_BPTR  ; short:'b.ptr' ; full:'Pointer to bytes'),
    (typ:SST_WPTR  ; short:'w.ptr' ; full:'Pointer to words'),
    (typ:SST_LAST  ; short:'last'  ; full:'Last result'),
    (typ:SST_PARAM ; short:'param' ; full:'Parameter'));


///////////////
const
  rtInt  = 1;
  rtWide = 2;

function MakeStructure(txt:pAnsiChar;aparam,alast:LPARAM
         {$IFDEF Miranda}; restype:integer=rtInt{$ENDIF}):pointer;

function GetStructureResult(var struct):int_ptr;

procedure FreeStructure(var struct;descr:pAnsiChar);


implementation

uses common{$IFDEF Miranda}, m_api, mirutils{$ENDIF};


type
  pint_ptr = ^int_ptr;
  TWPARAM = WPARAM;
  TLPARAM = LPARAM;

// adjust offset to field
function AdjustSize(var summ:int_ptr;len:integer;adjust:integer):integer;
begin
  result:=summ;
  // packed, byte or array of byte
  if adjust=0 then
    adjust:={$IFDEF WIN32}4{$ELSE}8{$ENDIF}; // SizeOf(int_ptr);

  if (adjust=1) or (hiword(len)=1) then
  else
    case adjust of
      2: begin
        result:=result+(summ mod 2);
      end;
      4: begin
        if hiword(len)>2 then
          result:=result+(summ mod 4)
        else
          result:=result+(summ mod 2);
      end;
      8: begin
        if hiword(len)>4 then
          result:=result+(summ mod 8)
        else if hiword(len)>2 then
          result:=result+(summ mod 4)
        else
          result:=result+(summ mod 2);
      end;
    end;
  
  summ:=result;
end;

function GetOneElement(txt:pAnsiChar;var len:integer;var value:pAnsiChar):integer;
var
  pc,pc1:pAnsiChar;
  i,llen:integer;
begin
  if txt^=char_return then inc(txt);
  if txt^=char_script then inc(txt);
{$IFDEF Miranda}
  if txt^=char_mmi then inc(txt);
{$ENDIF}
  // element name
  pc:=txt;
  llen:=0;
  repeat
    inc(pc);
    inc(llen);
  until pc^ IN [#0,' ',char_separator];

  // recogninze data type
  i:=0;
  while i<MaxStructTypes do
  begin
    if StrCmp(txt,StructElems[i].short,llen)=0 then //!!
      break;
    inc(i);
  end;
  if i>=MaxStructTypes then
  begin
    result:=SST_UNKNOWN;
    exit;
  end;

  // next - alias, starting from letter
  // start: points to separator or space
  if pc^<>char_separator then
  begin
    inc(pc); // skip space
    if pc^ in sIdFirst then
      repeat
        inc(pc);
      until (pc^=' ') or (pc^=char_separator);
  end;

  // next - values
  // if has empty simple value, then points to next element but text-to-number will return 0 anyway
  if pc^=' ' then inc(pc); // points to value or nothing if no args
  result:=StructElems[i].typ;
  case result of
    SST_LAST,SST_PARAM: ;

    SST_BYTE,SST_WORD,SST_DWORD,SST_QWORD,SST_NATIVE: begin
      value:=pc;
    end;

    SST_BARR,SST_WARR,SST_BPTR,SST_WPTR: begin
      len:=StrToInt(pc);
      txt:=pc;
      pc:=StrScan(txt,' ');
      if (len>0) and (pc<>txt) and (pc<>nil) then
        value:=pc+1
      else
        value:=nil;
    end;
  end;

  // low word = total element size, high word = align size
  case result of
    SST_LAST,SST_PARAM: len:=SizeOf(LPARAM)+(SizeOf(LPARAM) shl 16);
    SST_BYTE  : len:=1+(1 shl 16);
    SST_WORD  : len:=2+(2 shl 16);
    SST_DWORD : len:=4+(4 shl 16);
    SST_QWORD : len:=8+(8 shl 16);
    SST_NATIVE: len:=SizeOf(LPARAM)+(SizeOf(LPARAM) shl 16); // SizeOf(NativeInt)
    SST_BARR  : len:=len+(1 shl 16);
    SST_WARR  : len:=len+(2 shl 16);
{
    SST_BPTR  : len:=SizeOf(pointer)+(SizeOf(pointer) shl 16);
    SST_WPTR  : len:=SizeOf(pointer)+(SizeOf(pointer) shl 16);
}
  end;
end;

procedure TranslateBlob(dst:pByte;src:pAnsiChar;isbyte:boolean);
var
  buf:array [0..7] of AnsiChar;
begin
  if isbyte then
  begin
    dst^:=0;
    buf[2]:=#0;
    while (src^<>#0) and (src^<>char_separator) do
    begin
      if (src^=char_hex) and ((src+1)^ in sHexNum) and ((src+2)^ in sHexNum) then
      begin
        buf[0]:=(src+1)^;
        buf[1]:=(src+2)^;
        inc(src,2+1);
        dst^:=HexToInt(buf);
      end
      else
      begin
        dst^:=ord(src^);
        inc(src);
      end;
      inc(dst);
    end;
  end
  else // u
  begin
    pword(dst)^:=0;
    buf[4]:=#0;
    while (src^<>#0) and (src^<>char_separator) do
    begin
      if (src^=char_hex) and
         ((src+1)^ in sHexNum) and
         ((src+2)^ in sHexNum) then
      begin
        buf[0]:=(src+1)^;
        buf[1]:=(src+2)^;
        if ((src+3)^ in sHexNum) and
           ((src+4)^ in sHexNum) then
        begin
          buf[2]:=(src+3)^;
          buf[3]:=(src+4)^;
          pWord(dst)^:=HexToInt(buf);
          inc(src,4+1);
          inc(dst,2);
        end
        else
        begin
          buf[2]:=#0;
          dst^:=HexToInt(buf);
          inc(dst);
          inc(src,2+1);
        end;
      end
      else
      begin
//        pWideChar(dst)^:=CharUTF8ToWide(src);
//        inc(src,UTF8CharLen(src));
        inc(dst,2);
      end;
    end;
  end;
end;

function MakeStructure(txt:pAnsiChar;aparam,alast:LPARAM
         {$IFDEF Miranda}; restype:integer=rtInt{$ENDIF}):pointer;
var
  i,len:integer;
  summ:int_ptr;
  value,lsrc:pAnsiChar;
  res:pByte;
  ppc,p,pc:pAnsiChar;
{$IFDEF Miranda}
  buf:array [0..31] of WideChar;
  pLast: pWideChar;
  lmmi:boolean;
{$ENDIF}
  align:integer;
  code,alen,ofs:integer;
begin
  result:=nil;
  if (txt=nil) or (txt^=#0) then
    exit;

  StrDup(pc,txt);

  ppc:=pc;
  summ:=0;

  align:=ord(pc^)-ord('0');//StrToInt(pc);
  lsrc:=StrScan(pc,char_separator)+1;

  code:=0;
  alen:=0;
  ofs :=0;

  // size calculation
  while lsrc^<>#0 do
  begin
    p:=StrScan(lsrc,char_separator);
//    if p<>nil then p^:=#0;

    i:=GetOneElement(lsrc,len,value);
    AdjustSize(summ,len,align);

    if (pc^=char_return) and (code<0) then
    begin
      code:=i;
      alen:=len;
      ofs :=summ;
    end;

    if (i=SST_BPTR) or (i=SST_WPTR) then
      len:=SizeOf(pointer)+(SizeOf(pointer) shl 16);

    inc(summ,loword(len));
    if p=nil then break;
    lsrc:=p+1;
  end;

  inc(summ,SizeOF(TStructResult));
  mGetMem (PAnsiChar(result) ,summ);
  FillChar(PAnsiChar(result)^,summ,0);
  res:=pByte(pAnsiChar(result)+SizeOF(TStructResult));
  with PStructResult(result)^ do
  begin
    typ   :=code;
    len   :=alen;
    offset:=ofs;
  end;

  pc:=ppc;

  // translation
  lsrc:=StrScan(pc,char_separator)+1;

  while lsrc^<>#0 do
  begin
    p:=StrScan(lsrc,char_separator);
    pc:=ppc;
    StrCopy(pc,lsrc,p-lsrc);
    i:=GetOneElement(pc,len,value);
    if pc^=char_return then inc(pc);
    if pc^=char_script then
    begin
{$IFDEF Miranda}
    if restype=rtInt then
      pLast:=IntToStr(buf,alast)
    else
      pLast:=pWideChar(alast);
    // in value must be converted to unicode
//!!    value:=ParseVarString(value,aparam,pLast);
{$ENDIF}
      inc(pc);
    end;
{$IFDEF Miranda}
    if pc^=char_mmi then
    begin
      lmmi:=true;
      inc(pc);
    end
    else
    lmmi:=false;
{$ENDIF}

    AdjustSize(int_ptr(res),len,align);
    case i of
      SST_LAST: begin
        pint_ptr(res)^:=alast;
      end;
      SST_PARAM: begin
        pint_ptr(res)^:=aparam;
      end;
      SST_BYTE: begin
        pByte(res)^:=StrToInt(value);
      end;
      SST_WORD: begin
        pWord(res)^:=StrToInt(value);
      end;
      SST_DWORD: begin
        pDWord(res)^:=StrToInt(value);
      end;
      SST_QWORD: begin
        pint64(res)^:=StrToInt(value);
      end;
      SST_NATIVE: begin
        pint_ptr(res)^:=StrToInt(value);
      end;
      SST_BARR: begin
        TranslateBlob(pByte(res),value,true);
      end;
      SST_WARR: begin
        TranslateBlob(pByte(res),value,false);
      end;
      SST_BPTR: begin
        if len=0 then
          pint_ptr(res)^:=0
        else
        begin
{$IFDEF Miranda}
          if lmmi then
            lsrc:=mmi.malloc(len+SizeOf(AnsiChar));
          else
{$ENDIF}
          mGetMem (lsrc ,len+SizeOf(AnsiChar));
          FillChar(lsrc^,len+SizeOf(AnsiChar),0);
          TranslateBlob(pByte(lsrc),value,true);
          pint_ptr(res)^:=uint_ptr(lsrc);
        end;
        len:=SizeOf(pointer)+(SizeOf(pointer) shl 16);
      end;
      SST_WPTR: begin
        if len=0 then
          pint_ptr(res)^:=0
        else
        begin
{$IFDEF Miranda}
          if lmmi then
            lsrc:=mmi.malloc(len+SizeOf(WideChar));
          else
{$ENDIF}
          mGetMem (lsrc ,len+SizeOf(WideChar));
          FillChar(lsrc^,len+SizeOf(WideChar),0);
          TranslateBlob(pByte(lsrc),value,false);
          pint_ptr(res)^:=uint_ptr(lsrc);
        end;
        len:=SizeOf(pointer)+(SizeOf(pointer) shl 16);
      end;
    end;
    if pc^=char_script then
    begin
{$IFDEF Miranda}
      mFreeMem(value);
{$ENDIF}
    end;
    inc(int_ptr(res),loword(len));

    if p=nil then break;
    lsrc:=p+1;
  end;
  mFreeMem(ppc);
end;

function GetStructureResult(var struct):int_ptr;
var
  loffset,llen,ltype:integer;
begin
  with PStructResult(pAnsiChar(struct)-SizeOF(TStructResult))^ do
  begin
    ltype  :=typ   ;
    llen   :=len   ;
    loffset:=offset;
  end;

  case ltype of
    SST_LAST : result:=0;
    SST_PARAM: result:=0;

    SST_BYTE  : result:=pByte   (pAnsiChar(struct)+loffset)^;
    SST_WORD  : result:=pWord   (pAnsiChar(struct)+loffset)^;
    SST_DWORD : result:=pDword  (pAnsiChar(struct)+loffset)^;
    SST_QWORD : result:=pint64  (pAnsiChar(struct)+loffset)^;
    SST_NATIVE: result:=pint_ptr(pAnsiChar(struct)+loffset)^;

    SST_BARR: result:=int_ptr(pAnsiChar(struct)+loffset); //??
    SST_WARR: result:=int_ptr(pAnsiChar(struct)+loffset); //??

    SST_BPTR: result:=pint_ptr(pAnsiChar(struct)+loffset)^; //??
    SST_WPTR: result:=pint_ptr(pAnsiChar(struct)+loffset)^; //??
  else
    result:=0;
  end;
end;

procedure FreeStructure(var struct;descr:pAnsiChar);
var
  summ:int_ptr;
  typ,len:integer;
  value,lsrc:pAnsiChar;
  p,pc:pAnsiChar;
  align:integer;
begin
  if (descr=nil) or (descr^=#0) then
    exit;

  StrDup(pc,descr);

  lsrc:=pc;

  // align = ALWAYS for non-empty structures
  align:=ord(pc^)-ord('0');//StrToInt(pc);
  lsrc:=StrScan(lsrc,char_separator)+1;

  summ:=0;
  while lsrc^<>#0 do
  begin
    p:=StrScan(lsrc,char_separator);
    if p<>nil then p^:=#0;

    typ:=GetOneElement(pc,len,value);
    AdjustSize(summ,len,align);
    case typ of
      SST_BPTR,SST_WPTR: begin
        value:=pAnsiChar(pint_ptr(pAnsiChar(struct)+summ)^);
        mFreeMem(value);
        len:=SizeOf(pointer)+(SizeOf(pointer) shl 16);
      end;
    end;
    inc(summ,loword(len));

    if p=nil then break;
    lsrc:=p+1;
  end;
  mFreeMem(pc);

  pointer(struct):=pointer(pAnsiChar(struct)-SizeOF(TStructResult));
  mFreeMem(struct);
end;

end.
