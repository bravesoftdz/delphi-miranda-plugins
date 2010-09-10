unit wat_api;

interface

uses windows;

{$Resource genre.res}
{$Include m_music.inc}

function GenreName(idx:cardinal):pWideChar;

implementation

uses common;

const
  MAX_MUSIC_GENRES = 148;

function GenreName(idx:cardinal):pWideChar;
begin
  if idx<MAX_MUSIC_GENRES then
  begin
    mGetMem(result,64*SizeOf(WideChar));
    LoadStringW(hInstance,idx,result,64);
  end
  else
    result:=nil;
end;

end.