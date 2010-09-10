{OFR file}
unit fmt_OFR;
{$include compilers.inc}

interface
uses wat_api;

function ReadOFR(var Info:tSongInfo):boolean; cdecl;

implementation
uses windows,common,io,tags,srv_format;

type
  tMain = packed record
    ID         :dword; // 'OFR '
    Size       :dword; //15
    SamplesLo  :dword;
    SamplesHi  :word;
    SampleType :byte;
    ChannelsMap:byte;
    Samplerate :dword;
    Encoder    :word;
    Compression:byte;
  end;

function ReadOFR(var Info:tSongInfo):boolean; cdecl;
var
  f:THANDLE;
  Hdr:tMain;
  Samples:int64;
begin
  result:=false;
  f:=Reset(Info.mfile);
  if dword(f)=INVALID_HANDLE_VALUE then
    exit;
  ReadID3v2(f,Info);
  BlockRead(f,Hdr,SizeOf(Hdr));
  Samples:=Hdr.SamplesLo+Hdr.SamplesHi*$10000;
  Info.channels:=Hdr.ChannelsMap+1;
  Info.khz     :=Hdr.Samplerate div 1000;
  Info.total   :=(Samples div Info.channels)*Info.khz;

  ReadAPEv2(f,Info);
  ReadID3v1(f,Info);
  CloseHandle(f);
  result:=true;
end;

initialization
  RegisterFormat('OFR',ReadOFR);
  RegisterFormat('OFS',ReadOFR);
end.
