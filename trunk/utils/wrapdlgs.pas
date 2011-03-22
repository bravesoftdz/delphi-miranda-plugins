{$include compilers.inc}
unit wrapdlgs;

interface
uses windows;

// ShlObj
function SelectDirectory(Caption:PAnsiChar;var Directory:PAnsiChar;
         Parent:HWND=0;newstyle:bool=false):Boolean; overload;
function SelectDirectory(Caption:PWideChar;var Directory:PWideChar;
         Parent:HWND=0;newstyle:bool=false):Boolean; overload;

implementation
uses common,shlobj,activex;

{$IFNDEF DELPHI7_UP}
const
  BIF_NEWDIALOGSTYLE = $0040;
{$ENDIF}

function SelectDirectory(Caption:PAnsiChar;var Directory:PAnsiChar;
         Parent:HWND=0;newstyle:bool=false):Boolean;
var
  BrowseInfo:TBrowseInfoA;
  Buffer:array [0..MAX_PATH-1] of AnsiChar;
  ItemIDList:PItemIDList;
  ShellMalloc:IMalloc;
begin
  Result:=False;
  FillChar(BrowseInfo,SizeOf(BrowseInfo),0);
  if (ShGetMalloc(ShellMalloc)=S_OK) and (ShellMalloc<>nil) then
  begin
    with BrowseInfo do
    begin
      hwndOwner     :=Parent;
      pszDisplayName:=@Buffer;
      lpszTitle     :=Caption;
      ulFlags       :=BIF_RETURNONLYFSDIRS;
    end;
    if newstyle then
      if CoInitializeEx(nil,COINIT_APARTMENTTHREADED)<>RPC_E_CHANGED_MODE then
        BrowseInfo.ulFlags:=BrowseInfo.ulFlags or BIF_NEWDIALOGSTYLE;
    try
      ItemIDList:=ShBrowseForFolderA({$IFDEF FPC}@{$ENDIF}BrowseInfo);
      Result:=ItemIDList<>nil;
      if Result then
      begin
        ShGetPathFromIDListA(ItemIDList,Buffer);
        StrDup(Directory,Buffer);
        ShellMalloc.Free(ItemIDList);
      end;
    finally
      if newstyle then CoUninitialize;
    end;
  end;
end;

function SelectDirectory(Caption:PWideChar;var Directory:PWideChar;
         Parent:HWND=0;newstyle:bool=false):Boolean;
var
  BrowseInfo:TBrowseInfoW;
  Buffer:array [0..MAX_PATH-1] of WideChar;
  ItemIDList:PItemIDList;
  ShellMalloc:IMalloc;
begin
  Result:=False;
  FillChar(BrowseInfo,SizeOf(BrowseInfo),0);
  if (ShGetMalloc(ShellMalloc)=S_OK) and (ShellMalloc<>nil) then
  begin
    with BrowseInfo do
    begin
      hwndOwner     :=Parent;
      pszDisplayName:=@Buffer;
      lpszTitle     :=Caption;
      ulFlags       :=BIF_RETURNONLYFSDIRS;
    end;
    if newstyle then
      if CoInitializeEx(nil,COINIT_APARTMENTTHREADED)<>RPC_E_CHANGED_MODE then
        BrowseInfo.ulFlags:=BrowseInfo.ulFlags or BIF_NEWDIALOGSTYLE;
    try
      ItemIDList:=ShBrowseForFolderW({$IFDEF FPC}@{$ENDIF}BrowseInfo);
      Result:=ItemIDList<>nil;
      if Result then
      begin
        ShGetPathFromIDListW(ItemIDList,Buffer);
        StrDupW(Directory,Buffer);
        ShellMalloc.Free(ItemIDList);
      end;
    finally
      if newstyle then CoUninitialize;
    end;
  end;
end;

end.
