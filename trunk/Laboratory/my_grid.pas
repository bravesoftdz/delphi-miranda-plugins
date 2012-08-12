unit my_grid;

interface

uses
  windows, KOL,
  hpp_global,
  hpp_events,
  my_richedit,
  my_RichCache;

type
  TGridHitTest = (ghtItem, ghtHeader, ghtText, ghtLink, ghtUnknown, ghtButton, ghtSession,
    ghtSessHideButton, ghtSessShowButton, ghtBookmark);
  TGridHitTests = set of TGridHitTest;

type
  TGridState = (gsIdle, gsDelete, gsSearch, gsSearchItem, gsLoad, gsSave, gsInline);
  TGridUpdate = (guSize, guAllocate, guFilter, guOptions);
  TGridUpdates = set of TGridUpdate;
type // From Classes
  TBiDiMode = (bdLeftToRight, bdRightToLeft, bdRightToLeftNoAlign, bdRightToLeftReadingOnly);
type
  TOnSelect          = procedure(Sender: PObj; Item, OldItem: Integer) of object;
  TGetItemData       = procedure(Sender: PObj; Index: Integer; var Item: THistoryItem) of object;
  TGetNameData       = procedure(Sender: PObj; Index: Integer; var Name: WideString) of object;
  TOnProcessRichText = procedure(Sender: PObj; Handle: THandle; Item: Integer) of object;
  TOnItemFilter      = procedure(Sender: PObj; Index: Integer; var Show: Boolean) of object;
  TOnState           = procedure(Sender: PObj; State: TGridState) of object;

type
  PHistoryGrid = ^THistoryGrid;
  THistoryGrid = object(TObj{TControl})
  private
FForm:PControl;

FContact:THANDLE;
harray:array of THANDLE;
HistoryLength:integer;
    //----- properties fields -----
    FRichCache:PRichCache;
    FRich: PHPPRichEdit;           // Current item
    FRichInline:PHPPRichEdit;      // inline (pesudo-editor) control
    FItems: array of THistoryItem;
    FGetNameData: TGetNameData;    // reassignable procedure to get Name Data
    FGetItemData: TGetItemData;    // reassignable procedure to get Item Data
    FOnProcessRichText: TOnProcessRichText; // RTF postprocessing
    FOnItemFilter: TOnItemFilter;  // Additional item fliter
    FOnState: TOnState;            // Grid state changing

    FGridNotFocused: Boolean;      // if Grid window not in focus
    FSelected: Integer;            // first selected item
    FMultiSelect: Boolean;         // several items selected
    FSelItems,
    TempSelItems: array of Integer;
    FState:TGridState;
    FReversed: Boolean;            // Latest at top or bottom
    FReversedHeader: Boolean;      // Header placement
    FContactName: WideString;      // Saved name of contact
    FProfileName: WideString;      // Saved our name
    FRTLMode: TRTLMode;            // Grid "global" RTL mode
    FBiDiMode: TBiDiMode;          // form field emulation
    FHideSelection: Boolean;

    FVertScrollBar:PControl;       // Scrollbar
    FClient: PControl;             // painting client area
    FRichHeight:integer;

    FFilter     : TMessageTypes;
    FGroupLinked: Boolean; // combine history/log messages to group or not
    FShowBottomAligned: Boolean;
    //----- Text messages -----
    FTxtNoItems : WideString; // Empty history / no items
    FTxtStartup : WideString; // Stsrting message
    FTxtNoSuch  : WideString; // no items for filter
    FTxtSessions: WideString; // session header text

    DownHitTests: TGridHitTests;
    HintHitTests: TGridHitTests;
    // Selection (inline and block) text and flag for it
    FSelectionString: WideString;
    FSelectionStored: Boolean;
    FOnSelect: TOnSelect;

    hHookChange:THANDLE;
    LogX, LogY: Integer;

    SessHeaderHeight,         // Session header height
    CHeaderHeight,            // Contact and Profile headers height,
    PHeaderHeight  : integer; // Calculates on settings changes
    LockCount      : integer;
    ShowBookmarks  : Boolean; // Show bookmarks sign
    ShowHeaders    : Boolean; // Show session sign (to open session header) or not
    ExpandHeaders  : Boolean; // Show session header in history
    GridUpdates    : TGridUpdates; // set of types of updates
    GridWidth      : integer; // Saved grdi width to recognize width changes

    //----- ScrollBar related -----
    TopItemOffset   : integer; // Top item "offscreen" offset
    MaxSBPos        : integer;
    NeededSBPosition: integer; // required (manual) SB position after scroll
    BarAdjusted     : boolean; // ScrollBar requires adjust
    VLineScrollSize : integer;
    //----- Mouse wheel handler temporary variables -----
    FWheelLastTick   :Cardinal;
    FWheelAccumulator:integer;

    FHintRect      : TRect;
    Allocated      : Boolean; // Allocated memory for items, setup scrollbar
    ShowProgress   : Boolean; // Show progress for initialization, deletion etc
    ProgressRect   : TRect;   // Progress view area (usually, client area)
    IsCanvasClean  : Boolean; // Canvas ready to draw progress
    ProgressPercent: byte;

procedure hgItemData(Sender: PObj; Index: Integer; var Item: THistoryItem);
function GetItemData(Index: Integer): THistoryItem;
procedure GridProcessRichText(Sender: PObj; Handle: THandle; Item: Integer);

    procedure CheckBusy;
    
    //----- properties helpers -----
    procedure SetState(const Value: TGridState);
    function GetSelectionString: WideString;
    procedure SetGroupLinked(const Value: Boolean);
    procedure SetReversed(const Value: Boolean);
    procedure SetReversedHeader(const Value: Boolean);
    procedure SetFilter(const Value: TMessageTypes);
    procedure SetRTLMode(const Value: TRTLMode);
    procedure SetHideSelection(const Value: Boolean);

    function GetSelCount: Integer;
    procedure SetSelected(const Value: Integer);

    function GetCount: Integer;
    function GetItems(Index: Integer): THistoryItem;
    function GetSelItems(Index: Integer): Integer;
    procedure SetSelItems(Index: Integer; Item: Integer);
    //----- Grid settings related -----
    procedure DoOptionsChanged;
    procedure GridUpdateSize;
    procedure UpdateFilter;

    function GetProfileName: WideString;
    procedure SetProfileName(const Value: WideString);
    procedure SetContactName(const Value: WideString);

    procedure SetRichRTL(RTL: Boolean; aRichEdit: PHPPRichEdit; ProcessTag: Boolean = True);
    function GetItemRTL(Item: Integer): Boolean;
    //----- Select-related functions -----
    procedure MakeSelected(Value: Integer);
    procedure AddSelected(Item: Integer);
    procedure RemoveSelected(Item: Integer);
    procedure MakeSelectedTo(Item: Integer);
    procedure MakeRangeSelected(FromItem, ToItem: Integer);
    //----- Item-related functions -----
    function FindItemAt(X, Y: Integer; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint): Integer; overload;
    function FindItemAt(X, Y: Integer): Integer; overload;
    function GetDown(Item: Integer): Integer;
    function GetUp(Item: Integer): Integer;
    function GetIdx(Index: Integer): Integer;
    function GetFirstVisible: Integer;
    procedure MakeVisible(Item: Integer);
    function IsUnknown(Index: Integer): Boolean;
    function IsMatched(Index: Integer): Boolean; // Item is in filter
    procedure LoadItem(Item: Integer; LoadHeight: Boolean = True; Reload: Boolean = False);
    function CalcItemHeight(Item: Integer): Integer;
    procedure ApplyItemToRich(Item: Integer; aRichEdit: PHPPRichEdit = nil; ForceInline: Boolean = False);
    procedure ApplyItemToRichCache(Sender: PControl; Item: Integer; aRichEdit: PHPPRichEdit);
    // replace templates by values (internal)
    function FormatItems(ItemList: array of Integer; Format: WideString): WideString;
    procedure IntFormatItem(Item: Integer; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);

    function GetHintAtPoint(X, Y: Integer; var ObjectHint: WideString; var ObjectRect: TRect): Boolean;
    //----- painting functions -----
    procedure EraseBkgnd(Sender: PControl; DC: HDC);
    procedure MyPaint(Sender: PControl; DC: HDC);
    procedure PaintHeader(Index: Integer; ItemRect: TRect);
    procedure PaintItem(Index: Integer; ItemRect: TRect);
    procedure Paint;
    procedure DrawMessage(const aText: WideString);
    procedure DrawProgress;
    procedure DoProgress(lPos, Max: Integer);
    //----- Scrollbar functions -----
    procedure ScrollGridBy(Offset: Integer; Update: Boolean = True);
    procedure SetSBPos(Position: Integer);
    procedure AdjustScrollBar;
    //----- Messages (events) processing -----
    procedure OnGridBeforeScroll(Sender: PControl; OldPos, NewPos: Integer;
      Cmd: Word; var AllowChange: Boolean);
    procedure OnGridScroll(Sender: PControl; Cmd: Word);
    procedure OnGridResize(Sender:PObj);
    function OnGridMessage(var Msg:TMsg; var Rslt:Integer):Boolean;
    //----- Mouse-related events -----
    procedure DoLButtonDown(var Mouse:TMouseEventData);
    procedure DoLButtonUp  (var Mouse:TMouseEventData);
    procedure OnGridMouseWheel   (Sender:PControl; var Mouse:TMouseEventData);
    procedure OnGridMouseDown    (Sender:PControl; var Mouse:TMouseEventData);
    procedure OnGridMouseUp      (Sender:PControl; var Mouse:TMouseEventData);
    procedure OnGridMouseDblClick(Sender:PControl; var Mouse:TMouseEventData);
    procedure OnGridMouseMove    (Sender:PControl; var Mouse:TMouseEventData);
    
    function GetHitTests(X, Y: Integer): TGridHitTests;

function GetRichEditRect(Item: Integer; DontClipTop: Boolean): TRect;
    function GetLinkAtPoint(X, Y: Integer): AnsiString;
    function IsLinkAtPoint(RichEditRect: TRect; X, Y, Item: Integer): Boolean;
  public
	  function GetItemRect(Item: Integer): TRect;
function FillHistory(hContact:THANDLE):integer;
    property SelectionString: WideString read GetSelectionString;
    property ShowBottomAligned: Boolean read FShowBottomAligned write FShowBottomAligned;
    property GroupLinked: Boolean read FGroupLinked write SetGroupLinked default False;
    property State: TGridState read FState write SetState;
    property Reversed: Boolean read FReversed write SetReversed;
    property ReversedHeader: Boolean read FReversedHeader write SetReversedHeader;
    property Filter: TMessageTypes read FFilter write SetFilter;
    property RTLMode: TRTLMode read FRTLMode write SetRTLMode;
    property BiDiMode: TBiDiMode read FBiDiMode write FBiDiMode;
    property HideSelection: Boolean read FHideSelection write SetHideSelection default False;

    property VertScrollBar:PControl read FVertScrollBar;
    property RichEdit: PHPPRichEdit read FRich write FRich;
    property InlineRichEdit: PHPPRichEdit read FRichInline write FRichInline;
    property OnProcessRichText: TOnProcessRichText read FOnProcessRichText write FOnProcessRichText;
    //----- Item properties -----
    property Count: Integer read GetCount;
    property Items[Index: Integer]: THistoryItem read GetItems;
    property OnItemData: TGetItemData read FGetItemData write FGetItemData;
    property OnNameData: TGetNameData read FGetNameData write FGetNameData;

    property OnSelect: TOnSelect read FOnSelect write FOnSelect;
    property SelectedItems[Index: Integer]: Integer read GetSelItems write SetSelItems;
    property Selected: Integer read FSelected write SetSelected;
    property SelCount: Integer read GetSelCount;
    property MultiSelect: Boolean read FMultiSelect write FMultiSelect;

    property ProfileName: WideString read GetProfileName write SetProfileName;
    property ContactName: WideString read FContactName write SetContactName;
    //----- Text messages properties -----
    property TxtStartup : WideString read FTxtStartup  write FTxtStartup;
    property TxtNoItems : WideString read FTxtNoItems  write FTxtNoItems;
    property TxtNoSuch  : WideString read FTxtNoSuch   write FTxtNoSuch;
    property TxtSessions: WideString read FTxtSessions write FTxtSessions;

    destructor Destroy; virtual;
    procedure Allocate(ItemsCount: Integer; Scroll: Boolean = True);
    //----- Grid settings related -----
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GridUpdate(Updates: TGridUpdates);
    //----- Scrollbar functions -----
    procedure ScrollToBottom;

    function GetTopItem: Integer;
    function GetBottomItem: Integer;
    function GetNext(Item: Integer; Force: Boolean = False): Integer;
    function GetPrev(Item: Integer; Force: Boolean = False): Integer;
    function IsVisible(Item: Integer; Partially: Boolean = True): Boolean;
    function IsSelected(Item: Integer): Boolean;
    procedure SelectAll;
    procedure SelectRange(FromItem, ToItem: Integer);
    // replace templates by values
    function FormatSelected(const Format: WideString): WideString;
  end;

function NewHistoryGrid(aParent:PControl):PHistoryGrid;


implementation

uses
  Messages,
  RichEdit,
  KolOleRe2, //!!
  Common,
  m_api,
  hpp_options,
  hpp_arrays,
  hpp_strparser,
  hpp_itemprocess,
  my_rtf,
  my_GridOptions;

const
  Padding = 4;

function PointInRect(Pnt: TPoint; Rct: TRect): Boolean;
begin
  Result := (Pnt.X >= Rct.Left) and (Pnt.X <= Rct.Right) and (Pnt.Y >= Rct.Top) and
    (Pnt.Y <= Rct.Bottom);
end;

function DoRectsIntersect(R1, R2: TRect): Boolean;
begin
  Result := (Max(R1.Left, R2.Left) < Min(R1.Right, R2.Right)) and
    (Max(R1.Top, R2.Top) < Min(R1.Bottom, R2.Bottom));
end;

function GetDateTimeString(Time:Dword):WideString;
var
  buf:array [0..300] of WideChar;
  ST: TSystemTime;
begin
  if Assigned(GridOptions) then
  begin
    if DateTime2SystemTime(TimestampToDateTime(Time)+VCLDate0,ST) then
    begin
      GetDateFormatW(LOCALE_USER_DEFAULT,0,@ST,pWideChar(GridOptions.DateTimeFormat),@buf,300);
      GetTimeFormatW(LOCALE_USER_DEFAULT,0,@ST,@buf,@buf,300);
      result:=buf;
      exit;
    end;
  end;
  result:='';
end;

//----- History Grid implementation -----

procedure THistoryGrid.SetRichRTL(RTL: Boolean; aRichEdit: PHPPRichEdit; ProcessTag: Boolean = True);
var
  pf: PARAFORMAT2;
  lExStyle: DWord;
begin
  // we use RichEdit.Tag here to save previous RTL state to prevent from
  // reapplying same state, because SetRichRTL is called VERY OFTEN
  // (from ApplyItemToRich)
  if (aRichEdit.Tag = Cardinal(RTL)) and ProcessTag then
    exit;
  ZeroMemory(@pf, SizeOf(pf));
  pf.cbSize := SizeOf(pf);
  pf.dwMask := PFM_RTLPARA;
  lExStyle := DWord(GetWindowLongPtr(aRichEdit.Handle, GWL_EXSTYLE)) and
    not(WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_RIGHT or WS_EX_LEFT);
  if RTL then
  begin
    lExStyle := lExStyle or (WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_LEFT);
    pf.wReserved := PFE_RTLPARA;
  end
  else
  begin
    lExStyle := lExStyle or WS_EX_RIGHT;
    pf.wReserved := 0;
  end;
  RichEdit.Perform(EM_SETPARAFORMAT, 0, lParam(@pf));
  SetWindowLongPtr(aRichEdit.Handle, GWL_EXSTYLE, lExStyle);
  if ProcessTag then
    aRichEdit.Tag := Cardinal(RTL);
end;

{$include hg_support.inc}
{$include hg_gridsettings.inc}
{$include hg_format.inc}
{$include hg_items.inc}
{$include hg_scroll.inc}
{$include hg_selections.inc}
{$include hg_re.inc}
{$include hg_paint.inc}
{$include hg_messages.inc}
{$include hg_mouse.inc}
{$include hg_hint.inc}

procedure THistoryGrid.Allocate(ItemsCount: Integer; Scroll: Boolean = True);
var
  i: Integer;
  PrevCount: Integer;
begin
  PrevCount := Length(FItems);
  SetLength(FItems, ItemsCount);
  for i := PrevCount to ItemsCount - 1 do
  begin
    FItems[i].Height := -1;
    FItems[i].MessageType := [mtUnknown];
    FRichCache.ResetItem(i); //?? if was before? or after deleting?
  end;

  VertScrollBar.SBMax := ItemsCount + FVertScrollBar.SBPageSize - 1;
//??  VertScrollBar.Range := ItemsCount + FVertScrollBar.SBPageSize - 1;
  BarAdjusted := False;

  Allocated := True;

  if Scroll then
  begin
    if Reversed xor ReversedHeader then
      SetSBPos(GetIdx(GetBottomItem))
    else
      SetSBPos(GetIdx(GetTopItem));
  end
  else
    AdjustScrollBar;

  FClient.Invalidate;
end;

destructor THistoryGrid.Destroy;
begin
messagebox(0,'destroy Grid','',0);
  UnhookEvent(hHookChange);

  FVertScrollBar.Free;

//  FRichInline.Free;

  FRich := nil;
  FRichCache.Free;

  FClient.Free;
  Finalize(FItems);

  inherited;
messagebox(0,'destroyed Grid','',0);
end;

function NewHistoryGrid(aParent:PControl):PHistoryGrid;
var
  dc:HDC;
begin
  New(Result,Create);

  result.ShowBottomAligned := False;
  result.GridWidth := 0;
  result.CHeaderHeight := -1;
  result.PHeaderheight := -1;
  result.ExpandHeaders := False;
  result.TxtStartup := 'Starting up...';
  result.TxtNoItems := 'History is empty';
  result.TxtNoSuch := 'No such items';
  result.TxtSessions := 'Conversation started at %s';
  result.FReversed := False;
  result.FReversedHeader := False;
  result.FState := gsIdle;
  result.IsCanvasClean := False;
  result.Multiselect := true;
//  result.BarAdjusted := False;
  result.Allocated := False;

  result.FSelected := -1;
//  result.FContact := 0;
//  result.FProtocol := '';
  result.ShowBookmarks := True;

  result.FSelectionString := '';
  result.FSelectionStored := False;

  result.LockCount:=0;
  dc := GetDC(0);
  result.LogX := GetDeviceCaps(dc, LOGPIXELSX);
  result.LogY := GetDeviceCaps(dc, LOGPIXELSY);
  ReleaseDC(0, dc);
  result.VLineScrollSize := (result.LogY*13) div 96;//MulDiv(result.LogY, 13, 96);

{##}
  result.FForm := NewForm(nil,'History Grid').SetSize(400,200);
  result.FForm.Show;
  result.FClient := NewPanel(result.FForm,esNone).SetAlign(caClient);
//  result.FClient := NewAlienPanel(0,esNone);
//  result.FClient := NewForm(nil{aParent},'panel');
  result.FRichCache:=NewRichCache(result.FClient);
  result.FRichCache.OnRichApply:=result.ApplyItemToRichCache;
//  result.InlineRichEdit:=NewHPPRichEdit(result.FClient,[]);

  result.FWheelLastTick   := 0;
  result.FWheelAccumulator:= 0;
  result.FForm.OnMouseWheel :=result.OnGridMouseWheel;
  result.FForm.OnMouseDown  :=result.OnGridMouseDown;
  result.FForm.OnMouseUp    :=result.OnGridMouseUp;
  result.FForm.OnMouseDblClk:=result.OnGridMouseDblClick;
  result.FForm.OnMouseMove  :=result.OnGridMouseMove;

  if result.FClient<>nil then
  begin
    with result.FClient^ do
    begin
//      SetSize(400,200);

      OnEraseBkgnd:=result.EraseBkgnd;
      OnPaint     :=result.MyPaint;
      OnResize    :=result.OnGridResize;
      OnMessage   :=result.OnGridMessage;
//      Show;
      OnMouseWheel :=result.OnGridMouseWheel;
      OnMouseDown  :=result.OnGridMouseDown;
      OnMouseUp    :=result.OnGridMouseUp;
      OnMouseDblClk:=result.OnGridMouseDblClick;
      OnMouseMove  :=result.OnGridMouseMove;

//      GetWindowHandle;
      Visible:=true;
    end;
    result.FVertScrollBar:=NewScrollBar(result.FForm, sbVertical).SetAlign(caRight);
    result.FVertScrollBar.OnSBBeforeScroll:=result.OnGridBeforeScroll;
    result.FVertScrollBar.OnSBScroll      :=result.OnGridScroll;
  end;

  result.hHookChange:=HookEventObj(ME_HPP_OPTIONSCHANGED,@OnChange,result);

  result.GridUpdate([guSize,guOptions]);

  result.FGetItemData := result.hgItemData;
  result.OnProcessRichText := result.GridProcessRichText;

  result.FFilter:=[mtUnknown, mtIncoming, mtOutgoing,
                  mtMessage, mtUrl, mtFile, mtSystem];

  result.FHideSelection:=false;
  result.FGridNotFocused:=true;
end;

function THistoryGrid.FillHistory(hContact:THANDLE):integer;
var
  i:integer;
  hDBEvent:THANDLE;
begin
FContact:=hContact;
  HistoryLength := CallService(MS_DB_EVENT_GETCOUNT, hContact, 0);
  SetLength(harray,HistoryLength);
  hDBEvent := CallService(MS_DB_EVENT_FINDFIRST, hContact, 0);
  for i:=0 to HistoryLength-1 do
  begin
    harray[i]:=hDBEvent;
    hDBEvent := CallService(MS_DB_EVENT_FINDNEXT, hDBEvent, 0);
  end;
  result:=HistoryLength;
  Allocate(result);
end;

function THistoryGrid.GetItemData(Index: Integer): THistoryItem;
var
  hDBEvent: THandle;
begin
  hDBEvent := harray[Index];
  Result := ReadEvent(hDBEvent);
end;

procedure THistoryGrid.hgItemData(Sender: PObj; Index: Integer; var Item: THistoryItem);
begin
  Item := GetItemData(Index);
end;

procedure THistoryGrid.GridProcessRichText(Sender: PObj; Handle: THandle; Item: Integer);
var
  ItemRenderDetails: TItemRenderDetails;
begin
  ZeroMemory(@ItemRenderDetails, SizeOf(ItemRenderDetails));
  ItemRenderDetails.cbSize      := SizeOf(ItemRenderDetails);
  ItemRenderDetails.hContact    := FContact;
  ItemRenderDetails.hDBEvent    := harray[Item];
  ItemRenderDetails.pProto      := PAnsiChar(Items[Item].Proto);
  ItemRenderDetails.pModule     := PAnsiChar(Items[Item].Module);
  ItemRenderDetails.pText       := nil;
  ItemRenderDetails.pExtended   := PAnsiChar(Items[Item].Extended);
  ItemRenderDetails.dwEventTime := Items[Item].Time;
  ItemRenderDetails.wEventType  := Items[Item].EventType;
  ItemRenderDetails.IsEventSent := (mtOutgoing in Items[Item].MessageType);

  if IsSelected(Item) then
    ItemRenderDetails.dwFlags := ItemRenderDetails.dwFlags or IRDF_SELECTED;
  ItemRenderDetails.bHistoryWindow := IRDHW_CONTACTHISTORY;//IRDHW_EXTERNALGRID;
  AllHistoryRichEditProcess(WParam(Handle), LParam(@ItemRenderDetails));
//  NotifyEventHooks(hHppRichEditItemProcess, WParam(Handle), LParam(@ItemRenderDetails));
end;


end.
