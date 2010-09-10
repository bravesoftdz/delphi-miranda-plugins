{TTA file}
unit fmt_TTA;
{$include compilers.inc}

interface
uses wat_api;

function ReadTTA(var Info:tSongInfo):boolean; cdecl;

implementation
uses windows,common,io,tags,srv_format;

const
  TTA1_SIGN = $31415454;
type
  tTTAHeader = packed record
    id           :dword;
    format       :word;
    channels     :word;
    bitspersample:word;
    samplerate   :dword;
    datalength   :dword;
    crc32        :dword;
  end;

function ReadTTA(var Info:tSongInfo):boolean; cdecl;
var
  f:THANDLE;
  hdr:tTTAHeader;
begin
  result:=false;
  f:=Reset(Info.mfile);
  if dword(f)=INVALID_HANDLE_VALUE then
    exit;
  ReadID3v2(f,Info);
  BlockRead(f,hdr,SizeOf(tTTAHeader));
  if hdr.id<>TTA1_SIGN then
    exit;
  Info.channels:=hdr.channels;
  Info.khz     :=hdr.samplerate;
  Info.kbps    :=hdr.bitspersample div 1000; //!!
  if hdr.samplerate<>0 then
    Info.total:=hdr.datalength div hdr.samplerate;
  ReadID3v1(f,Info);
  CloseHandle(f);
  result:=true;
end;

initialization
  RegisterFormat('TTA',ReadTTA);
end.
