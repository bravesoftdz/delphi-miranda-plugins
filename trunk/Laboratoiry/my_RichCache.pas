unit my_RichCache;

interface

uses
  KOL,
  RichEdit,
  my_richedit,
  Windows;

type
  CacheBitmap = KOL.PBitmap;
type
  PRichItem = ^TRichItem;
  TRichItem = record
    Rich       : THPPRichEdit;
    Bitmap     : CacheBitmap;
    BitmapDrawn: Boolean;
    Height     : Integer; // "real" height for bottomless RichEdit
    GridItem   : Integer;
  end;

  PLockedItem = ^TLockedItem;
  TLockedItem = record
    RichItem: PRichItem;
    SaveRect: TRect;     // can get rect from RichItem.Rich?
  end;

  tOnRichApply = procedure (Sender: PControl; Item:integer; Rich:THPPRichEdit) of object;

  PRichCache = ^TRichCache;
  TRichCache = object(TObj)
  private
    LogX, LogY: Integer;   // used for Bitmap creating
    RichEventMasks: DWord; // (ENM_LINK), in ApplyItemToRich

    FOnRichApply:tOnRichApply;

    FRichWidth: Integer;   // save width to trace width changes only
    FRichHeight: Integer;  // temporary, to set RichItem Height
    FLockedList: PList;    // list of locked items
    Items: array of PRichItem;

    function FindGridItem(GridItem: Integer): Integer;
    procedure PaintRichToBitmap(Item: PRichItem);
    // get richtext context from History grid?
    procedure ApplyItemToRich(Item: PRichItem);

    procedure MoveToTop(Index: Integer);  // current Item to top of cache
    procedure SetWidth(const Value: Integer);
  public
    destructor Destroy; virtual;

    // make Height = -1 to recalc
    procedure ResetAllItems;
    procedure ResetItems(GridItems: array of Integer);
    procedure ResetItem(GridItem: Integer);

    property OnRichApply:tOnRichApply read FOnRichApply write FOnRichApply;
    procedure ResizeRequest(const rc:TRect);

    property Width: Integer read FRichWidth write SetWidth;
    // grid handle to richitems as parent, clear color, transparent window
    // parent for resize?
    procedure WorkOutItemAdded  (GridItem: Integer); // for AddItem
    procedure WorkOutItemDeleted(GridItem: Integer); // for DeleteItem

    function RequestItem(GridItem: Integer): PRichItem;
    function GetItemRichBitmap(GridItem: Integer): CacheBitmap;
    function GetItemByHandle(Handle: THandle): PRichItem;
    // redraw protection (idk what is for)
    function LockItem(Item: PRichItem; SaveRect: TRect): Integer;
    function UnlockItem(Item: Integer): TRect;
  end;

function NewRichCache(aParent:PControl):PRichCache;

implementation

uses
  hpp_global;

const
  CACHE_SIZE = 20;

procedure TRichCache.ApplyItemToRich(Item: PRichItem);
begin
  // force to send the size:
  FRichHeight := -1;
  if Assigned(FOnRichApply) then
  begin
    Item^.Rich.Perform(EM_SETEVENTMASK, 0, 0);
    OnRichApply(@Self,Item^.GridItem,Item^.Rich);

    Item^.Rich.Perform(EM_SETEVENTMASK, 0, ENM_REQUESTRESIZE);
    Item^.Rich.Perform(EM_REQUESTRESIZE, 0, 0);

    Item^.Rich.Perform(EM_SETEVENTMASK, 0, RichEventMasks);
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
    Result.Height := -1;
  end;
  if Result.Height = -1 then
  begin
    ApplyItemToRich(Result);
    Result.Height := FRichHeight;
    Result.Rich.Height := FRichHeight;
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

function TRichCache.GetItemByHandle(Handle: THandle): PRichItem;
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
  LockedItem: PLockedItem;
begin
  Result := -1;
  if Item <> nil then
  begin
    try
      New(LockedItem);
    except
      LockedItem := nil;
    end;
    if Assigned(LockedItem) then
    begin
  //??    Item.Bitmap.Canvas.Lock;
      LockedItem.RichItem := Item;
      LockedItem.SaveRect := SaveRect;
      FLockedList.Add(LockedItem);
      Result := FLockedList.Count;
    end;
  end;
end;

function TRichCache.UnlockItem(Item: Integer): TRect;
var
  LockedItem: PLockedItem;
begin
  SetRect(Result, 0, 0, 0, 0);
  if Item = -1 then
    exit;
  LockedItem := FLockedList.Items[Item];
  if not Assigned(LockedItem) then
    exit;
{??
  if Assigned(LockedItem.RichItem) then
    LockedItem.RichItem.Bitmap.Canvas.Unlock;
}
  Result := LockedItem.SaveRect;
  Dispose(LockedItem);
  FLockedList.Delete(Item);
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
  Range: TFormatRange;
begin
  if (Item^.Bitmap.Width <> Item^.Rich.Width) or (Item^.Bitmap.Height <> Item^.Height) then
  begin
    // to prevent image copy
    Item^.Bitmap.Assign(nil);
    // or Item^.Bitmap.Clear;
    Item^.Bitmap.Width :=Item^.Rich.Width;
    Item^.Bitmap.Height:=Item^.Height;
  end;
  // because RichEdit sometimes paints smaller image
  // than it said when calculating height, we need
  // to fill the background
  BkColor := Item^.Rich.Perform(EM_SETBKGNDCOLOR, 0, 0);
  Item^.Rich.Perform(EM_SETBKGNDCOLOR, 0, BkColor);
//??  Item^.Bitmap.TransparentColor := BkColor;
  Item^.Bitmap.Canvas.Brush.Color := BkColor;
  Item^.Bitmap.Canvas.FillRect(Item^.Bitmap.Canvas.ClipRect);
  with Range do
  begin
    HDC := Item^.Bitmap.Canvas.Handle;
    hdcTarget := HDC;
    SetRect(rc, 0, 0,
      MulDiv(Item^.Bitmap.Width , 1440, LogX),
      MulDiv(Item^.Bitmap.Height, 1440, LogY));
    rcPage := rc;
    chrg.cpMin := 0;
    chrg.cpMax := -1;
  end;
  SetBkMode(Range.hdcTarget, TRANSPARENT);
//messageboxa(0,PAnsiChar(Item^.Rich.RE_Text[reRTF,false]),'',0);
  Item^.Rich.Perform(EM_FORMATRANGE, 1, lParam(@Range));
  Item^.Rich.Perform(EM_FORMATRANGE, 0, 0);
  Item^.BitmapDrawn := True;
end;

function TRichCache.GetItemRichBitmap(GridItem: Integer): CacheBitmap;
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
  Result := Item^.Bitmap;
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
    Items[i].Rich.Width := Value;
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

function NewRichItem(aParent:PControl):PRichItem;
var
  ExStyle: dword;
begin
  New(result);
  result^.Bitmap := NewDIBBitmap(0,0,pf32bit);

  result^.Height   := -1;
  result^.GridItem := -1;

  result^.Rich := NewHPPRichEdit(aParent,[eoNoHScroll, eoNoVScroll,eoMultiline]).RE_Bottomless;
  // make richedit transparent:
  ExStyle := GetWindowLongPtr(result^.Rich.Handle, GWL_EXSTYLE);
  ExStyle := ExStyle or WS_EX_TRANSPARENT;
  SetWindowLongPtr(result^.Rich.Handle, GWL_EXSTYLE, ExStyle);
  // workaround of SmileyAdd making richedit visible all the time
  result^.Rich.Top     := -MaxInt;
  result^.Rich.Height  := -1;
  result^.Rich.Visible := False;
  { Don't give him grid as parent, or we'll have wierd problems with scroll bar }
  result^.Rich.WordWrap:= True;
  result^.Rich.Border  := 0;
  result^.Rich.Brush.BrushStyle := bsClear;

end;

destructor TRichCache.Destroy;
var
  i: Integer;
begin
messagebox(0,'destroy Cache','',0);
  for i := 0 to FLockedList.Count - 1 do
    Dispose(PLockedItem(FLockedList.Items[i]));
  FLockedList.Free;

  for i := 0 to HIGH(Items) do
  begin
    Items[i]^.Rich.Free;
    Items[i]^.Bitmap.Free;
    Dispose(Items[i]);
  end;
  Finalize(Items);
  inherited;
messagebox(0,'destroyed Cache','',0);
end;

function NewRichCache(aParent:PControl):PRichCache;
var
  dc:HDC;
  i:integer;
begin
  New(Result,Create);
  with result^ do
  begin
    FRichWidth  := -1;
    FRichHeight := -1;

    RichEventMasks := ENM_LINK;

    dc := GetDC(0);
    LogX := GetDeviceCaps(dc, LOGPIXELSX);
    LogY := GetDeviceCaps(dc, LOGPIXELSY);
    ReleaseDC(0, dc);

    FLockedList := NewList;

    SetLength(Items, CACHE_SIZE);
    for i := 0 to HIGH(Items) do
      Items[i]:=NewRichItem(aParent);
  end;
end;

end.
