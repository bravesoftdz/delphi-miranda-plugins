unit my_RichCache;

interface

uses
  RichEdit,
  my_richedit,
  CustomGraph,
  Windows;

type
  pCacheBitmap = ^tCacheBitmap;
  tCacheBitmap = record
    DC: HDC;
    oldbitmap:HBITMAP; // to restore
    Width,
    Height: integer;
    Color: TCOLORREF;
  end;
type
  PRichItem = ^TRichItem;
  TRichItem = record
    Rich       : PHPPRichEdit;
    Bitmap     : tCacheBitmap;
    BitmapDrawn: Boolean;
    Height     : Integer; // "real" height for bottomless RichEdit
    GridItem   : Integer;
  end;

  PLockedItem = ^TLockedItem;
  TLockedItem = record
    RichItem: PRichItem;
    SaveRect: TRect;     // can get rect from RichItem.Rich?
  end;

  tOnRichApply = procedure (Item:integer; Rich:PHPPRichEdit) of object;

  TRichCache = class
  private
    Items: array of PRichItem;
    fLockedList:array of TLockedItem; // list of locked items

    FOnRichApply:tOnRichApply;

    LogX, LogY: Integer;   // used for Bitmap creating
    FRichWidth: Integer;   // save width to trace width changes only
    FRichHeight: Integer;  // temporary, to set RichItem Height

    RichEventMasks: DWord; // (ENM_LINK), in ApplyItemToRich

    function FindGridItem(GridItem: Integer): Integer;
    procedure PaintRichToBitmap(Item: PRichItem);
    // get richtext context from History grid?
    procedure ApplyItemToRich(Item: PRichItem);

    procedure MoveToTop(Index: Integer);  // current Item to top of cache
    procedure SetWidth(const Value: Integer);
  public
    destructor Destroy; override;

    // make Height = -1 to recalc
    procedure ResetAllItems;
    procedure ResetItems(GridItems: array of Integer);
    procedure ResetItem (GridItem: Integer);

    property OnRichApply:tOnRichApply read FOnRichApply write FOnRichApply;
    procedure ResizeRequest(const rc:TRect);

    property Width: Integer read FRichWidth write SetWidth;
    // grid handle to richitems as parent, clear color, transparent window
    // parent for resize?
    procedure WorkOutItemAdded  (GridItem: Integer); // for AddItem
    procedure WorkOutItemDeleted(GridItem: Integer); // for DeleteItem

    function RequestItem(GridItem: Integer): PRichItem;
    function GetItemRichBitmap(GridItem: Integer): pCacheBitmap;
    function GetItemByHandle  (Handle: THANDLE): PRichItem;
    // redraw protection (idk what is for)
    function LockItem  (Item: PRichItem; SaveRect: TRect): Integer;
    function UnlockItem(Item: Integer): TRect;
  end;

function NewRichCache(aParent:HWND):TRichCache;

implementation

const
  CACHE_SIZE = 20;

procedure TRichCache.ApplyItemToRich(Item: PRichItem);
begin
  // force to send the size:
  FRichHeight := -1;
  if Assigned(FOnRichApply) then
  begin
    SendMessage(Item^.Rich.Handle, EM_SETEVENTMASK, 0, 0);
    OnRichApply(Item^.GridItem,Item^.Rich);

    SendMessage(Item^.Rich.Handle, EM_SETEVENTMASK, 0, ENM_REQUESTRESIZE);
    SendMessage(Item^.Rich.Handle, EM_REQUESTRESIZE, 0, 0);

    SendMessage(Item^.Rich.Handle, EM_SETEVENTMASK, 0, RichEventMasks);
  end;
end;

function TRichCache.RequestItem(GridItem: Integer): PRichItem;
var
  idx: Integer;
begin
  if GridItem < 0 then
  begin
    result:=nil;
    exit;
  end;
  idx := FindGridItem(GridItem);
  if idx <> -1 then
  begin
    Result := Items[idx];
  end
  else
  begin
    idx := High(Items);
    Result := Items[idx];
    Result.GridItem := GridItem;
    Result.Height   := -1;
  end;
  if Result.Height = -1 then
  begin
    ApplyItemToRich(Result);
    Result.Height := FRichHeight;
//!!!!    Result.Rich.Height := FRichHeight;
    SetWindowPos(Result.Rich.Handle,0,0,0,FRichWidth,FRichHeight,
        SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOZORDER);
    Result.BitmapDrawn := False;
    MoveToTop(idx);
  end;
end;

function TRichCache.FindGridItem(GridItem: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  if GridItem = -1 then
    exit;
  for i := 0 to HIGH(Items) do
    if Items[i].GridItem = GridItem then
    begin
      Result := i;
      break;
    end;
end;

function TRichCache.GetItemByHandle(Handle: THANDLE): PRichItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(Items) do
    if Items[i].Rich.Handle = Handle then
    begin
      if Items[i].Height = -1 then
        break;
      Result := Items[i];
      break;
    end;
end;

function TRichCache.LockItem(Item: PRichItem; SaveRect: TRect): Integer;
var
  i:integer;
begin
  Result := -1;
  if Item <> nil then
  begin
    for i:=0 to HIGH(fLockedList) do
    begin
      if fLockedList[i].RichItem=nil then
      begin
        Result:=i;
        break;
      end;
    end;
    if Result=-1 then
    begin
      Result:=Length(fLockedList);
      SetLength(fLockedList,Result+8);
      //?? clear new items?
    end;

    fLockedList[Result].RichItem := Item;
    fLockedList[Result].SaveRect := SaveRect;
  end;
end;

function TRichCache.UnlockItem(Item: Integer): TRect;
begin
  SetRectEmpty(Result);
  if Item = -1 then
    exit;
  if fLockedList[Item].RichItem=nil then
    exit;

  Result := fLockedList[Item].SaveRect;
  fLockedList[Item].RichItem:=nil;
end;

procedure TRichCache.MoveToTop(Index: Integer);
var
  i: Integer;
  Item: PRichItem;
begin
  if (Index = 0) or (Index >= Length(Items)) then
    exit;
  Item := Items[Index];
  for i := Index downto 1 do
    Items[i] := Items[i - 1];
  Items[0] := Item;
end;

procedure TRichCache.PaintRichToBitmap(Item: PRichItem);
var
  BkColor: TCOLORREF;
  Range: RichEdit.TFormatRange;
  br:HBRUSH;
  rc:TRect;
  lhandle:HBITMAP;
  tmpdc:HDC;
begin
  with Item^.Bitmap do
    if (Width <> FRichWidth) or (Height <> Item^.Height) then
    begin
      Width :=FRichWidth;
      Height:=Item^.Height;
      tmpdc:=GetDC(0);
      lhandle:=SelectObject(DC,CreateCompatibleBitmap(tmpdc,Width,Height));
      ReleaseDC(0,tmpdc);
      if oldbitmap=0 then
        oldbitmap:=lhandle
      else
        DeleteObject(lhandle);
    end;
  // because RichEdit sometimes paints smaller image
  // than it said when calculating height, we need
  // to fill the background
  BkColor := SendMessage(Item^.Rich.Handle, EM_SETBKGNDCOLOR, 0, 0);
  SendMessage(Item^.Rich.Handle, EM_SETBKGNDCOLOR, 0, BkColor);
//??  Item^.Bitmap.TransparentColor := BkColor;

  Item^.Bitmap.Color:=BkColor;
  br:=CreateSolidBrush(BkColor);
  SetRect(rc,0,0,Item^.Bitmap.Width,Item^.Bitmap.Height);
  FillRect(Item^.Bitmap.DC,rc,br);
  DeleteObject(br);

  Range.hdc := Item^.Bitmap.DC;
  Range.hdcTarget := Range.hdc;
  SetRect(Range.rc, 0, 0,
    Item^.Bitmap.Width  * 1440 div LogX,
    Item^.Bitmap.Height * 1440 div LogY);
  Range.rcPage := rc;
  Range.chrg.cpMin := 0;
  Range.chrg.cpMax := -1;
  SetBkMode(Range.hdcTarget, TRANSPARENT);

  SendMessage(Item^.Rich.Handle, EM_FORMATRANGE, 1, lParam(@Range));
  SendMessage(Item^.Rich.Handle, EM_FORMATRANGE, 0, 0);
  Item^.BitmapDrawn := True;
end;

function TRichCache.GetItemRichBitmap(GridItem: Integer): pCacheBitmap;
var
  Item: PRichItem;
begin
  Item := RequestItem(GridItem);
  if Item = nil then
  begin
    result:=nil;
    exit;
  end;
  if not Item^.BitmapDrawn then
    PaintRichToBitmap(Item);
  Result := @Item^.Bitmap;
end;

procedure TRichCache.ResetAllItems;
var
  i: Integer;
begin
  for i := 0 to High(Items) do
  begin
    Items[i].Height := -1;
  end;
end;

procedure TRichCache.ResetItem(GridItem: Integer);
var
  idx: Integer;
begin
  if GridItem = -1 then
    exit;
  idx := FindGridItem(GridItem);
  if idx = -1 then
    exit;
  Items[idx].Height := -1;
end;

procedure TRichCache.ResetItems(GridItems: array of Integer);
var
  i: Integer;
  idx: Integer;
  ItemsReset: Integer;
begin
  ItemsReset := 0;
  for i := 0 to HIGH(GridItems) do
  begin
    idx := FindGridItem(GridItems[i]);
    if idx <> -1 then
    begin
      Items[idx].Height := -1;
      Inc(ItemsReset);
    end;
    // no point in searching, we've reset all items
    if ItemsReset >= Length(Items) then
      break;
  end;
end;

procedure TRichCache.SetWidth(const Value: Integer);
var
  i: Integer;
begin
  if FRichWidth = Value then
    exit;
  FRichWidth := Value;
  for i := 0 to HIGH(Items) do
  begin
//!!!!    Items[i].Rich.Width := Value;
    SetWindowPos(Items[i].Rich.Handle,0,0,0,FRichWidth,FRichHeight,
        SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOZORDER);
    Items[i].Height := -1;
  end;
end;

procedure TRichCache.WorkOutItemAdded(GridItem: Integer);
var
  i: Integer;
begin
  for i := 0 to HIGH(Items) do
    if Items[i].Height <> -1 then
    begin
      if Items[i].GridItem >= GridItem then
        Inc(Items[i].GridItem);
    end;
end;

procedure TRichCache.WorkOutItemDeleted(GridItem: Integer);
var
  i: Integer;
begin
  for i := 0 to HIGH(Items) do
    if Items[i].Height <> -1 then
    begin
      if Items[i].GridItem = GridItem then
        Items[i].Height := -1
      else if Items[i].GridItem > GridItem then
        Dec(Items[i].GridItem);
    end;
end;

procedure TRichCache.ResizeRequest(const rc:TRect);
begin
  FRichHeight := rc.Bottom - rc.Top;
end;

function NewRichItem(aParent:HWND):PRichItem;
var
  tmp:PHPPRichEdit;
begin
  tmp := NewHPPRichEdit(aParent);
  if tmp = nil then
  begin
    result:=nil;
    exit;
  end;

  New(result);
  result.Bitmap.Width :=0;
  result.Bitmap.Height:=0;
//!!
  result.Bitmap.DC    :=CreateCompatibleDC(0);
  result.Bitmap.oldbitmap:=0;

  result^.Height   := -1;
  result^.GridItem := -1;

  result^.Rich := tmp;
end;

destructor TRichCache.Destroy;
var
  i: Integer;
begin

//  Finalize(fLockedList);
  fLockedList := nil;

  for i := 0 to HIGH(Items) do
  begin
    with Items[i]^ do
    begin
      DestroyWindow(Rich.Handle);
      if Bitmap.oldbitmap<>0 then
        DeleteObject(SelectObject(Bitmap.DC,Bitmap.oldbitmap));
      DeleteDC(Bitmap.DC);
    end;
    Dispose(Items[i]);
  end;
  Finalize(Items);
  inherited;
end;

function NewRichCache(aParent:HWND):TRichCache;
var
  dc:HDC;
  i:integer;
begin
  Result:=TRichCache.Create;
  with result do
  begin
    FRichWidth  := -1;
    FRichHeight := -1;

    RichEventMasks := ENM_LINK;

    dc := GetDC(0);
    LogX := GetDeviceCaps(dc, LOGPIXELSX);
    LogY := GetDeviceCaps(dc, LOGPIXELSY);
    ReleaseDC(0, dc);

    SetLength(Items, CACHE_SIZE);
    for i := 0 to HIGH(Items) do
    begin
      Items[i]:=NewRichItem(aParent);
    end;
  end;
end;

end.
