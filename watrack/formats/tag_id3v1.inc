{ID3v1 tag}
{$IFDEF Interface}
const
  TAG1Sign = 'TAG';
type
  TID3v1Tag = packed record
    ID:      array [0..2]  of AnsiChar;
    Title:   array [0..29] of AnsiChar;
    Artist:  array [0..29] of AnsiChar;
    Album:   array [0..29] of AnsiChar;
    Year:    array [0..3]  of AnsiChar;
    Comment: array [0..28] of AnsiChar;
    Track:   byte;
    Genre:   byte;
  end;

function ReadID3v1(f:THANDLE; var Info:tSongInfo):longint;
{$ELSE}
const
  Lyric1End  = 'LYRICSEND';
  LyricStart = 'LYRICSBEGIN';
  Lyric2End  = 'LYRICS200';
  LyricEndLen = Length(Lyric1End);
const
  fIND = $494E44;
  fLYR = $4C5952;
  fEAL = $45414C;
  fEAR = $454152;
  fETT = $455454;
  fIMG = $494D47;
  fINF = $494E46;

procedure ID3v1_TagCorrect(var dst:pWideChar;tag:array of AnsiChar);
var
  i:integer;
  s:array [0..31] of AnsiChar;
begin
  i:=High(tag);
  move(tag,s,i+1);
  while (i>0) and (tag[i]<=' ') do dec(i);
  if i>0 then
  begin
    s[i+1]:=#0;
    ANSItoWide(s,dst);
  end;
end;

procedure ID3v1_GetField(ptr:PAnsiChar; var dst:pWideChar; len:integer);
var
  txtfield:array [0..250] of AnsiChar;
begin
  if dst=nil then
  begin
    move(ptr^,txtfield,len);
    txtfield[len]:=#0;
    AnsiToWide(txtfield,dst);
  end;
end;

procedure ID3v1_CheckLyric(var Info:tSongInfo;f:THANDLE;ofs:integer);
const
  maxlen = 5100;
var
  tagHdr:array [0..9] of AnsiChar;
  buf:array [0..maxlen] of AnsiChar;
  ptr,ptr1:PAnsiChar;
  i,size:integer;
  field:dword;
  c:dword;
begin
  Seek(f,ofs);
  BlockRead(f,tagHdr,LyricEndLen);
  tagHdr[9]:=#0;
  if StrCmp(tagHdr,Lyric1End,LyricEndLen)=0 then
  begin
    if Info.lyric=nil then
    begin
      Seek(f,ofs-maxlen);
      BlockRead(f,buf,maxlen);
      buf[maxlen]:=#0;
      ptr:=@buf;
      for i:=0 to maxlen-Length(LyricStart) do
      begin
        if ptr^='L' then
          if StrCmp(ptr,LyricStart,Length(LyricStart))=0 then
          begin
            AnsiToWide(ptr+Length(LyricStart),Info.lyric);
            break;
          end;
        inc(ptr);
      end;
    end;
  end
  else if StrCmp(tagHdr,Lyric2End,LyricEndLen)=0 then
  begin
    Seek(f,ofs-6);
    BlockRead(f,buf,6);
    size:=StrToInt(buf);
    if size<ofs then
    begin
      Seek(f,ofs-size-6);
      mGetMem(ptr,size+1);
      BlockRead(f,ptr^,size);
      if StrCmp(ptr,LyricStart,Length(LyricStart))=0 then
      begin
        ptr1:=ptr+Length(LyricStart);

        while ptr1<ptr+size do
        begin
          field:=(ORD(ptr1^) shl 16)+(ORD((ptr+1)^) shl 8)+ORD((ptr1+2)^);
          inc(ptr1,3);
          move(ptr1^,buf,5);
          buf[5]:=#0;
          i:=StrToInt(buf);
          inc(ptr1,5);
          case field of
            fLYR: if Info.lyric=nil then
            begin
              c:=pword(ptr1+i)^;
              pword(ptr1+i)^:=0;
              if (pword(ptr1)^=$FFFE) or ((pword(ptr1)^=$FEFF)) then
              begin
                StrDupW(Info.lyric,pWidechar(ptr1));
                ChangeUnicode(Info.lyric);
              end
              else
              begin
                AnsiToWide(ptr1,Info.lyric);
              end;
              pword(ptr1+i)^:=c;
            end;
            fEAL: ID3v1_GetField(ptr1,Info.Album,i);
            fEAR: ID3v1_GetField(ptr1,Info.Artist,i);
            fETT: ID3v1_GetField(ptr1,Info.Title,i);
//            fINF:
//            fIMG:
          end;
          inc(ptr1,i);
        end;
      end;
      mFreeMem(ptr);
    end;
  end;
end;

function ReadID3v1(f:THANDLE; var Info:tSongInfo):longint;
var
  Tag:TID3v1Tag;
  ofs:integer;
begin
  result:=0;
  ofs:=FileSize(f)-SizeOf(Tag);
  Seek(f,ofs);
  BlockRead(f,Tag,SizeOf(Tag));
  if Tag.ID=TAG1Sign then
  begin
    if Info.Album  =nil then ID3v1_TagCorrect(Info.Album  ,tag.Album);
    if Info.Artist =nil then ID3v1_TagCorrect(Info.Artist ,tag.Artist);
    if Info.Title  =nil then ID3v1_TagCorrect(Info.Title  ,tag.Title);
    if Info.Comment=nil then ID3v1_TagCorrect(Info.Comment,tag.Comment);
    if Info.Year   =nil then ID3v1_TagCorrect(Info.Year   ,tag.Year);
    if Info.Genre  =nil then Info.Genre:=GenreName(tag.Genre);
    if Info.Track=0 then
    begin
      Info.Track:=tag.Track;
      if Info.Track  >=32 then Info.Track:=0;
    end;
    dec(ofs,9);
    result:=1;
  end
  else
    inc(ofs,SizeOf(tag)-9);
  ID3v1_CheckLyric(Info,f,ofs); // +skipAPEtag
end;
{$ENDIF}
