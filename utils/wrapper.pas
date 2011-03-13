{$include compilers.inc}
unit wrapper;

interface
uses windows;

function  LV_GetLParam  (list:HWND;item:integer=-1):lresult;
function  LV_SetLParam  (list:HWND;lParam:LPARAM;item:integer=-1):lresult;
function  LV_ItemAtPos(wnd:HWND;Pt:TPOINT;var SubItem:dword):Integer; overload;
function  LV_ItemAtPos(wnd:HWND;x,y:integer;var SubItem:dword):Integer; overload;
procedure LV_SetItem (handle:hwnd;str:PAnsiChar;item:integer;subitem:integer=0);
procedure LV_SetItemW(handle:hwnd;str:PWideChar;item:integer;subitem:integer=0);
function  LV_MoveItem(list:hwnd;direction:integer;item:integer=-1):integer;
function  LV_GetColumnCount(list:HWND):lresult;
function  LV_CheckDirection(list:HWND):integer; // bit 0 - can move up, bit 1 - down

function ShowDlg (dst:PAnsiChar;fname:PAnsiChar=nil;Filter:PAnsiChar=nil;open:boolean=true):boolean;
function ShowDlgW(dst:PWideChar;fname:PWideChar=nil;Filter:PWideChar=nil;open:boolean=true):boolean;

function SelectDirectory(Caption:PAnsiChar;var Directory:PAnsiChar;
         Parent:HWND=0;newstyle:bool=false):Boolean; overload;
function SelectDirectory(Caption:PWideChar;var Directory:PWideChar;
         Parent:HWND=0;newstyle:bool=false):Boolean; overload;

implementation
uses messages,common,shlobj,activex,commctrl,commdlg;

{.$IFNDEF DELPHI10_UP}
const
  LVM_SORTITEMSEX = LVM_FIRST + 81;
{.$ENDIF}
{$IFNDEF DELPHI7_UP}
const
  BIF_NEWDIALOGSTYLE = $0040;
{$ENDIF}

function ShowDlg(dst:PAnsiChar;fname:PAnsiChar=nil;Filter:PAnsiChar=nil;open:boolean=true):boolean;
var
  NameRec:OpenFileNameA;
begin
  FillChar(NameRec,SizeOf(NameRec),0);
  with NameRec do
  begin
    LStructSize:=SizeOf(NameRec);
    if fname=nil then
      dst[0]:=#0
    else if fname<>dst then
      StrCopy(dst,fname);
//    lpstrInitialDir:=dst;
    lpStrFile  :=dst;
    lpStrFilter:=Filter;
    if Filter<>nil then
    begin
      lpstrDefExt:=StrEnd(Filter)+1;
      inc(lpstrDefExt,2); // skip "*."
    end;
    NMaxFile   :=511;
    Flags      :=OFN_EXPLORER or OFN_OVERWRITEPROMPT;// or OFN_HIDEREADONLY;
  end;
  if open then
    result:=GetOpenFileNameA({$IFDEF FPC}@{$ENDIF}NameRec)
  else
    result:=GetSaveFileNameA({$IFDEF FPC}@{$ENDIF}NameRec);
end;

function ShowDlgW(dst:PWideChar;fname:PWideChar=nil;Filter:PWideChar=nil;open:boolean=true):boolean;
var
  NameRec:OpenFileNameW;
begin
  FillChar(NameRec,SizeOf(NameRec),0);
  with NameRec do
  begin
    LStructSize:=SizeOf(NameRec);
    if fname=nil then
      dst[0]:=#0
    else if fname<>dst then
      StrCopyW(dst,fname);
//    lpstrInitialDir:=dst;
    lpStrFile  :=dst;
    lpStrFilter:=Filter;
    if Filter<>nil then
    begin
      lpstrDefExt:=StrEndW(Filter)+1;
      inc(lpstrDefExt,2); // skip "*."
    end;
    NMaxFile   :=511;
    Flags      :=OFN_EXPLORER or OFN_OVERWRITEPROMPT;// or OFN_HIDEREADONLY;
  end;
  if open then
    result:=GetOpenFileNameW({$IFDEF FPC}@{$ENDIF}NameRec)
  else
    result:=GetSaveFileNameW({$IFDEF FPC}@{$ENDIF}NameRec)
end;

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

//----- ListView functions -----

procedure LV_SetItem(handle:hwnd;str:PAnsiChar;item:integer;subitem:integer=0);
var
  li:LV_ITEMA;
begin
//  zeromemory(@li,sizeof(li));
  li.mask    :=LVIF_TEXT;
  li.pszText :=str;
  li.iItem   :=item;
  li.iSubItem:=subitem;
  SendMessageA(handle,LVM_SETITEMA,0,lparam(@li));
end;

procedure LV_SetItemW(handle:hwnd;str:PWideChar;item:integer;subitem:integer=0);
var
  li:LV_ITEMW;
begin
//  zeromemory(@li,sizeof(li));
  li.mask    :=LVIF_TEXT;
  li.pszText :=str;
  li.iItem   :=item;
  li.iSubItem:=subitem;
  SendMessageW(handle,LVM_SETITEMW,0,lparam(@li));
end;

function LV_GetLParam(list:HWND;item:integer=-1):lresult;
var
  li:LV_ITEMW;
begin
  if item<0 then
  begin
    item:=SendMessage(list,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
    if item<0 then
    begin
      result:=-1;
      exit;
    end;
  end;
  li.iItem   :=item;
  li.mask    :=LVIF_PARAM;
  li.iSubItem:=0;
  SendMessageW(list,LVM_GETITEMW,0,lparam(@li));
  result:=li.lParam;
end;

function LV_SetLParam(list:HWND;lParam:LPARAM;item:integer=-1):lresult;
var
  li:LV_ITEMW;
begin
  if item<0 then
  begin
    item:=SendMessage(list,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
    if item<0 then
    begin
      result:=-1;
      exit;
    end;
  end;
  li.iItem   :=item;
  li.mask    :=LVIF_PARAM;
  li.lParam  :=lParam;
  li.iSubItem:=0;
  SendMessageW(list,LVM_SETITEMW,0,windows.lparam(@li));
  result:=lParam;
end;

function LV_ItemAtPos(wnd:HWND;Pt:TPOINT;var SubItem:dword):Integer;
var
  HTI:LV_HITTESTINFO;
begin
  HTI.pt.x := Pt.X;
  HTI.pt.y := Pt.Y;
  SendMessage(wnd,LVM_SUBITEMHITTEST,0,lparam(@HTI));
  Result :=HTI.iItem;
  if @SubItem<>nil then
    SubItem:=HTI.iSubItem;
end;

function LV_ItemAtPos(wnd:HWND;x,y:integer;var SubItem:dword):Integer; overload;
var
  HTI:LV_HITTESTINFO;
begin
  HTI.pt.x := x;
  HTI.pt.y := y;
  SendMessage(wnd,LVM_SUBITEMHITTEST,0,lparam(@HTI));
  Result :=HTI.iItem;
  if @SubItem<>nil then
    SubItem:=HTI.iSubItem;
end;

function LV_Compare(lParam1,lParam2,param:LPARAM):integer; stdcall;
var
  olditem,neibor:integer;
begin
  result:=lParam1-lParam2;
  neibor :=hiword(param);
  olditem:=loword(param);
  if neibor>olditem then
  begin
    if (lParam1=olditem) and (lParam2<=neibor) then
      result:=1;
  end
  else
  begin
    if (lParam2=olditem) and (lParam1>=neibor) then
      result:=1;
  end;
end;

function LV_MoveItem(list:hwnd;direction:integer;item:integer=-1):integer;
begin
  if ((direction>0) and (item=(SendMessage(list,LVM_GETITEMCOUNT,0,0)-1))) or
     ((direction<0) and (item=0)) then
  begin
    result:=item;
    exit;
  end;

  if item<0 then
    item:=SendMessage(list,LVM_GETNEXTITEM,-1,LVNI_FOCUSED);
  SendMessageW(list,LVM_SORTITEMSEX,wparam(item)+(wparam(item+direction) shl 16),lparam(@LV_Compare));
  result:=item+direction;
end;

function LV_GetColumnCount(list:HWND):lresult;
begin
  result:=SendMessage(SendMessage(list,LVM_GETHEADER,0,0),HDM_GETITEMCOUNT,0,0);
end;

function LV_CheckDirection(list:HWND):integer;
var
  i,cnt{,selcnt}:integer;
  stat,first,last,focus: integer;
begin
  first :=-1;
  last  :=-1;
  focus :=-1;
  cnt   :=SendMessage(list,LVM_GETITEMCOUNT,0,0)-1;
//  selcnt:=SendMessage(list,LVM_GETSELECTEDCOUNT,0,0);
  for i:=0 to cnt do
  begin
    stat:=SendMessage(list,LVM_GETITEMSTATE,i,LVIS_SELECTED or LVIS_FOCUSED);
    if (stat and LVIS_SELECTED)<>0 then
    begin
      if (stat and LVIS_FOCUSED)<>0 then
        focus:=i;
      if first<0 then first:=i;
      last:=i;
    end;
  end;
  result:=0;
  if focus<0 then
    focus:=first;
  if focus>=0 then
    result:=result or ((focus+1) shl 16);
  if first>0 then // at least one selected and not first
  begin
    result:=(result or 1){ or (first+1) shl 16};
  end;
  if (last>=0) and (last<cnt) then
    result:=result or 2;
end;

end.
