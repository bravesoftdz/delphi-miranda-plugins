{FLV file format}
unit fmt_FLV;
{$include compilers.inc}

interface
uses wat_api;

function ReadFLV(var Info:tSongInfo):boolean; cdecl;

implementation
uses windows,common,io,srv_format;

type
  tFLVHeader = packed record
    Signature:array [0..2] of AnsiChar; // FLV
    Version  :byte;
    Flags    :byte;
    Offset   :dword; // reversed byte order
  end;
type
  tFLVStream = packed record
    PreviousTagSize:dword;
    TagType        :byte;
    BodyLength     :array [0..2] of byte;
    Timestamp      :array [0..2] of byte;
    Padding        :dword;
//    Body
  end;

  twork = record
    endptr:PAnsiChar;
    Info  :pSongInfo;
    key   :PAnsiChar;
  end;

//  FLVTagTypes
const
  FLV_AUDIO = 8;
  FLV_VIDEO = 9;
  FLV_META  = $12;

const
  BufSize = 128*1024;

type
  pArr = ^tArr;
  tArr = array [0..7] of byte;

  transform=packed record
    case byte of
      0: (txt:array [0..3] of AnsiChar);
      1: (num:dword);
  end;
  trecode=packed record
    case byte of
      0: (i:int64);
      1: (d:double);
  end;

function Reverse(buf:int64;len:integer):int64;
var
  i:integer;
begin
  result:=0;
  for i:=0 to len-1 do
    result:=(result shl 8)+tArr(buf)[i];
end;

function ProcessTag(var ptr:PAnsiChar;var work:twork;skip:integer):integer; forward;

function ProcessValue(var ptr:PAnsiChar;var work:twork;skip:integer):integer;
var
  tmp:int64;
  i:integer;
  recode:trecode;
  code:integer;
  codec:transform;
  value:array [0..63] of AnsiChar;
begin
  result:=1;
  code:=ord(ptr^); inc(ptr);
  with work do
    case code of
      $00: // numeric, 8 bytes = double
      begin
        if skip=0 then
        begin
          move(ptr^,tmp,8);
          recode.i:=Reverse(tmp,8);
          i:=trunc(recode.d);
          if      StrCmp(key,'duration'     )=0 then Info.total :=i
          else if StrCmp(key,'width'        )=0 then Info.width :=i
          else if StrCmp(key,'height'       )=0 then Info.height:=i
          else if StrCmp(key,'audiodatarate')=0 then Info.kbps  :=i
          else if StrCmp(key,'framerate'    )=0 then Info.fps   :=trunc(recode.d*100)
          else if StrCmp(key,'audiosize'    )=0 then
          begin
            if Info.kbps=0 then
              Info.kbps:=trunc((recode.d*8)/(Info.total*1000))
          end
          else if StrCmp(key,'videocodecid')=0 then
          begin
            case i of
              2:   codec.txt:='H263';
              3:   codec.txt:='Scrn';
              4,5: codec.txt:='VP6 ';
              6:   codec.txt:='Src2';
            end;
            Info.codec:=codec.num;
          end;
        end;
        inc(ptr,8);
      end;
      $01: // boolean, 1 byte = 0 - false; 1 - true
      begin
        inc(ptr);
      end;
      $02: // string, 2 bytes - len; len - string UTF8
      begin
        i:=swap(pWord(ptr)^); inc(ptr,2);
        if skip=0 then
        begin
          move(ptr^,value[0],i);
          value[i]:=#0;
          if StrCmp(key,'creationdate')=0 then
            ANSItoWide(value,Info.Year);
        end;
        inc(ptr,i);
      end;
      $03: // object, xx = string UTF, xx - element; $00 $00 $09
      begin
        repeat
          result:=ProcessTag(ptr,work,skip+1);
        until result<=0;
        if result<0 then
          result:=1;
      end;
      $04: // movie clip
      begin
        result:=0; // break
      end;
  {
      $05, // null
      $06, // undefined
      $0D: // unsupported
      begin
      end;
  }
      $07: // reference
      begin
         result:=0; // break?
      end;
      $08: // mixed array, 4 bytes = num of element [xx = string UTF, xx - element], $00 $00 $09
      begin
        i:=pdword(ptr)^; inc(ptr,4);
        i:=Reverse(i,4);
        while i>0 do
        begin
          result:=ProcessTag(ptr,work,skip+1);
          if result=0 then break
          else if result<0 then
          begin
            result:=1;
            break;
          end;
          dec(i);
        end;
      end;
      $09: // end of object
      begin
        result:=-1;
      end;
      $0A: // array, 4 bytes - num of elements, elements
      begin
        i:=pdword(ptr)^; inc(ptr,4);
        i:=Reverse(i,4);
        while i>0 do
        begin
          result:=ProcessValue(ptr,work,skip+1);
          if result=0 then exit
          else if result<0 then
          begin
            result:=1;
            break;
          end;
          dec(i);
        end;
      end;
      $0B: // date
      begin
        inc(ptr,8+2); // double + 2 bytes - GMT
      end;
      $0C, // longstring, 4 bytes = len, len - string
      $0F: // xml = longstring
      begin
        i:=pdword(ptr)^; inc(ptr,4);
        i:=Reverse(i,4);
        if skip=0 then
        begin
        end;
        inc(ptr,i);
      end;
      $0E: // recordset
      begin
        result:=0; // break
      end;
      $10: // typed object = string UTF, object ($03 type)
      begin
        i:=swap(pWord(ptr)^); inc(ptr,i+2);
        ProcessTag(ptr,work,skip+1)
      end;
      $11: // AMF3 data
      begin
        result:=0; // break
      end;
    end;
end;

function ProcessTag(var ptr:PAnsiChar;var work:twork;skip:integer):integer;
var
  i:integer;
  key:array [0..127] of AnsiChar;
begin
  if ptr>=work.endptr then
  begin
    result:=0;
    exit;
  end;
  result:=1;
  i:=swap(pWord(ptr)^); inc(ptr,2);
  work.key:=@key;
  if i>0 then
    move(ptr^,key[0],i); inc(ptr,i);
  key[i]:=#0;
  result:=ProcessValue(ptr,work,skip);
end;

function ReadFLV(var Info:tSongInfo):boolean; cdecl;
var
  f:THANDLE;
  codec:transform;
  FLVHdr:tFLVHeader;
  StrmHdr:tFLVStream;
  len:integer;
  buf,pp,p,endbuf:PAnsiChar;
  work:twork;
begin
  result:=false;
  f:=Reset(Info.mfile);
  if dword(f)=INVALID_HANDLE_VALUE then
    exit;

  mGetMem(buf,BufSize);
  endbuf:=buf+BlockRead(f,buf^,BufSize);
  p:=buf;
  CloseHandle(f);
  move(p^,FLVHdr,SizeOf(tFLVHeader));
  if (FLVHdr.Signature[0]='F') and (FLVHdr.Signature[1]='L') and
     (FLVHdr.Signature[2]='V') and (FLVHdr.Version=1) then
  begin
    inc(p,SizeOf(tFLVHeader));
    result:=true;
    while (p<endbuf) and ((FLVHdr.flags and 5)<>0) do
    begin
      move(p^,StrmHdr,SizeOf(tFLVStream));
      inc(p,SizeOf(tFLVStream));
      len:=(StrmHdr.BodyLength[0] shl 16)+(StrmHdr.BodyLength[1] shl 8)+
            StrmHdr.BodyLength[2];
      pp:=p;
      case StrmHdr.TagType of
        FLV_AUDIO: begin
          Info.channels:=(ord(p^) and 1)+1;
          // samplesize is (S_Byte and 2) shr 1 = 8 or 16
          case (ord(p^) and $C) shr 2 of
            0: Info.khz:=5;
            1: Info.khz:=11;
            2: Info.khz:=22;
            3: Info.khz:=44;
          end;
          FLVHdr.flags:=FLVHdr.flags and not 4;
        end;
        FLV_VIDEO: begin
          case ord(p^) and $0F of
            2:   codec.txt:='H263';
            3:   codec.txt:='Scrn';
            4,5: codec.txt:='VP6 ';
            6:   codec.txt:='Src2';
          end;
          Info.codec:=codec.num;
          FLVHdr.flags:=FLVHdr.flags and not 1;
        end;
        FLV_META: begin
          work.Info  :=@Info;
          work.endptr:=p+len;
          inc(p); // 2
          ProcessTag(p,work,-1);
        end;
      end;
      p:=pp+len;
    end;
  end;
  mFreeMem(buf);
end;

initialization
  RegisterFormat('FLV',ReadFLV,WAT_OPT_VIDEO);
end.
