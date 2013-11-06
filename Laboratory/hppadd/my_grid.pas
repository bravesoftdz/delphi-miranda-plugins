unit my_grid;

interface

uses
  windows,
  hpp_global,
  hpp_events,
  my_richedit,
  uRect,
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
  TOnSelect          = procedure(Item, OldItem: Integer) of object;
  TOnItemFilter      = procedure(Index: Integer; var Show: Boolean) of object;
  TGetItemData       = procedure(Index: Integer; var Item: THistoryItem) of object;
  TGetNameData       = procedure(Index: Integer; var Name: pWideChar) of object;
  TOnProcessRichText = procedure(Handle: THandle; Item: Integer) of object;
  TOnState           = procedure(State: TGridState) of object;

type
  THistoryGrid = class
  private
    FHandle: THANDLE;
    //----- properties fields -----
    FRichCache:TRichCache;
    FRich: PHPPRichEdit;           // Current item
    FRichInline:PHPPRichEdit;      // inline (pesudo-editor) control
    FItems: array of THistoryItem;
    FGetNameData: TGetNameData;    // reassignable procedure to get Name Data
    FGetItemData: TGetItemData;    // reassignable procedure to get Item Data
    FOnProcessRichText: TOnProcessRichText; // RTF postprocessing
    FOnItemFilter: TOnItemFilter;  // Additional item filter
    FOnState: TOnState;            // Grid state changing

    FGridNotFocused: Boolean;      // if Grid window not in focus
    FSelected: Integer;            // first selected item
    FMultiSelect: Boolean;         // several items selected
    FHideSelection: Boolean;
    FSelItems,
    TempSelItems: array of Integer;
    FState:TGridState;
    FReversed: Boolean;            // Latest at top or bottom
    FReversedHeader: Boolean;      // Header placement
    FRTLMode: TRTLMode;            // Grid "global" RTL mode
    FBiDiMode: TBiDiMode;          // form field emulation
    //**********************
    FContactName: pWideChar;       // Saved name of contact
    FProfileName: pWideChar;       // Saved our name

    //----- Client Area -----
    FClient    : HWND;             // painting client area
    FClientDC  : HDC;              // memory buffer DC 
    FClientBuf : HBITMAP;          // memory buffer bitmap
    FClientRect: TRect;            // Client area rect

    FRichHeight:integer;

    FFilter     : TMessageTypes;   // event types mask to show
    FGroupLinked: Boolean; // combine history/log messages to group or not
    FShowBottomAligned: Boolean;

    //----- Text messages -----
    FMessages: array [0..3] of pWideChar;

    DownHitTests: TGridHitTests;
    HintHitTests: TGridHitTests;
    // Selection (inline and block) text and flag for it
    FSelectionString: WideString;
    FSelectionStored: Boolean;
    FOnSelect: TOnSelect;

    hHookChange:THANDLE;

    SessHeaderHeight,         // Session header height
    CHeaderHeight,            // Contact and Profile headers height,
    PHeaderHeight  : integer; // Calculates on settings changes
    LockCount      : integer;
    FShowBookmarks : Boolean; // Show bookmarks sign
    FShowHeaders   : Boolean; // Show session sign (to open session header) or not
    ExpandHeaders  : Boolean; // Show session header in history
    GridUpdates    : TGridUpdates; // set of types of updates

    //----- ScrollBar related -----
    FScrollBar      : HWND;    // scrollbar control handle
    FSBPosition     : integer; // Current position (item number)
    FSBMax          : integer; // Item count - page (for scroll box moving)
    FSBHidden       : boolean; // Visible scrollbar or not
    TopItemOffset   : integer; // Top item "offscreen" offset
    MaxSBPos        : integer;
    BarAdjusted     : boolean; // ScrollBar requires adjust
    VLineScrollSize : integer;

    //----- Physic -----
    LogX, LogY: Integer;      // DEVICEPIXELS (to not call WinAPI all time)

    //----- Mouse wheel handler temporary variables -----
    FWheelLastTick   :Cardinal;
    FWheelAccumulator:integer;

    FHintRect      : TRect;
    Allocated      : Boolean; // Allocated memory for items, setup scrollbar
    ShowProgress   : Boolean; // Show progress for initialization, deletion etc
    ProgressRect   : TRect;   // Progress view area (usually, client area)
    IsCanvasClean  : Boolean; // Canvas ready to draw progress
    ProgressPercent: byte;

    procedure InitDefaults;

    procedure CheckBusy;
    
    //----- properties helpers -----
    procedure SetState         (const Value: TGridState);
    procedure SetGroupLinked   (const Value: Boolean);
    procedure SetShowHeaders   (const Value: Boolean);
    procedure SetReversed      (const Value: Boolean);
    procedure SetReversedHeader(const Value: Boolean);
    procedure SetFilter        (const Value: TMessageTypes);
    procedure SetRTLMode       (const Value: TRTLMode);
    procedure SetHideSelection (const Value: Boolean);
    procedure SetSelected(Item: Integer);
    function  GetSelectionString: WideString;
    function  GetSelCount: Integer;
    function  GetCount: Integer;
    function  GetItems   (Index: Integer): THistoryItem;
    function  GetSelItems(Index: Integer): Integer;
    procedure SetSelItems(Index: Integer; Item: Integer);
    function  GetGMessage(idx:integer):pWideChar;
    procedure SetGMessage(idx:integer;value:pWideChar);

    //----- Grid settings related -----
    procedure DoOptionsChanged;
    procedure GridUpdateSize;
    procedure UpdateFilter;

    function  GetProfileName: pWideChar;
    procedure SetProfileName(Value: pWideChar);
    procedure SetContactName(Value: pWideChar);

    procedure SetRichRTL(RTL: Boolean; aRichEdit: PHPPRichEdit);
    function  GetItemRTL(Item: Integer): Boolean;

    //----- Select-related functions -----
    procedure MakeSelected     (Item: Integer);
    procedure AddSelected      (Item: Integer);
    procedure RemoveSelected   (Item: Integer);
    procedure MakeSelectedTo   (Item: Integer);
    procedure MakeRangeSelected(FromItem, ToItem: Integer);

    //----- Item-related functions -----
    function FindItemAt(X, Y: Integer; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint): Integer; overload;
    function FindItemAt(X, Y: Integer): Integer; overload;
    function GetDown(Item: Integer): Integer;
    function GetUp  (Item: Integer): Integer;
    function GetIdx (Index: Integer): Integer;

    function  GetFirstVisible: Integer;
    procedure MakeVisible(Item: Integer);

    function IsUnknown(Index: Integer): Boolean;
    function IsMatched(Index: Integer): Boolean; // Item is in filter

    procedure LoadItem            (Item: Integer; LoadHeight: Boolean = True; Reload: Boolean = False);
    function  CalcItemHeight      (Item: Integer): Integer;
    procedure ApplyItemToRich     (Item: Integer; aRichEdit: PHPPRichEdit = nil; ForceInline: Boolean = False);
    procedure ApplyItemToRichCache(Item: Integer; aRichEdit: PHPPRichEdit);
    // replace templates by values (internal)
    function  FormatItems(ItemList: array of Integer; Format: WideString): WideString;
    procedure IntFormatItem(Item: Integer; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);

    function GetHintAtPoint(X, Y: Integer; var ObjectHint: WideString; var ObjectRect: TRect): Boolean;

    //----- painting functions -----
    procedure PaintHeader(Index: Integer; var ItemRect: TRect);
    procedure PaintItem  (Index: Integer; var ItemRect: TRect; const ClipRect: TRect);
    function  Paint(const ClipRect:TRect):lresult;
    procedure DrawMessage(aText: pWideChar);
    procedure DrawProgress;
    procedure DoProgress(lPos, Max: Integer);

    procedure Invalidate;
    procedure Update;

    //----- Scrollbar functions -----
    procedure ScrollGridBy(Offset: Integer; DoUpdate: Boolean = True);
    procedure SetSBPos(Position: Integer);
    procedure AdjustScrollBar;
    procedure SetSBPosition(value:integer);
    procedure SetSBMax     (value:integer);
    procedure SetSBHidden(value:boolean);

    procedure OnGridSCroll(wParam:WPARAM);

//    function  OnGridMessage(lParam:LPARAM):boolean;
    function  OnGridNotify(lParam:LPARAM):boolean;

    //----- Keys-related messages -----
    function OnKeyMessage(hMessage:UInt; wParam:WPARAM; lParam:LPARAM):lresult;

    //----- Mouse-related messages -----
    procedure OnMouseMessage(hMessage:UInt; wParam:WPARAM; lParam:LPARAM);
    procedure DoLButtonUp     (X,Y:integer);
    procedure OnGridMouseWheel(shift:SmallInt);

    function GetHitTests(X, Y: Integer): TGridHitTests;

	  function GetItemRect    (Item: Integer): TRect;
    function GetRichEditRect(Item: Integer; DontClipTop: Boolean): TRect;
    function GetLinkAtPoint(X, Y: Integer): AnsiString;
    function IsLinkAtPoint (RichEditRect: TRect; X, Y, Item: Integer): Boolean;

    //----- Scroll bar properties -----
    property SBPosition: integer read FSBPosition write SetSBPosition;
    property SBMax: integer read FSBMax write SetSBMax;

  public
    property Handle:THANDLE read FHandle;
	  
    property SelectionString: WideString read GetSelectionString;
    property ShowBottomAligned: Boolean read FShowBottomAligned write FShowBottomAligned;
    property GroupLinked: Boolean read FGroupLinked write SetGroupLinked;
    property ShowBookmarks: Boolean read FShowBookmarks write FShowBookmarks;
    property ShowHeaders: Boolean read FShowHeaders write SetShowHeaders;
    property State: TGridState read FState write SetState;
    property Reversed      : Boolean read FReversed write SetReversed;
    property ReversedHeader: Boolean read FReversedHeader write SetReversedHeader;
    property Filter: TMessageTypes read FFilter write SetFilter;
    property RTLMode : TRTLMode  read FRTLMode  write SetRTLMode;
    property BiDiMode: TBiDiMode read FBiDiMode write FBiDiMode;
    property HideSelection: Boolean read FHideSelection write SetHideSelection;

    property RichEdit      : PHPPRichEdit read FRich       write FRich;
    property InlineRichEdit: PHPPRichEdit read FRichInline write FRichInline;
{*} property OnProcessRichText: TOnProcessRichText read FOnProcessRichText write FOnProcessRichText;
    //----- Item properties -----
    property Count: Integer read GetCount;
    property Items[Index: Integer]: THistoryItem read GetItems;
{*} property OnItemData: TGetItemData read FGetItemData write FGetItemData;
{*} property OnNameData: TGetNameData read FGetNameData write FGetNameData;
{*} property OnItemFilter: TOnItemFilter read FOnItemFilter write FOnItemFilter;

{*} property OnState: TOnState read FOnState write FOnState;

{*} property OnSelect: TOnSelect read FOnSelect write FOnSelect;
    property SelectedItems[Index: Integer]: Integer read GetSelItems write SetSelItems;
    property Selected: Integer read FSelected write SetSelected;
    property SelCount: Integer read GetSelCount;
    property MultiSelect: Boolean read FMultiSelect write FMultiSelect;

    property ProfileName: pWideChar read GetProfileName write SetProfileName;
    property ContactName: pWideChar read FContactName   write SetContactName;
    //----- Text messages properties -----
    property TxtStartup : pWideChar index 0 read GetGMessage write SetGMessage; // Empty history / no items
    property TxtNoItems : pWideChar index 1 read GetGMessage write SetGMessage; // Stsrting message        
    property TxtNoSuch  : pWideChar index 2 read GetGMessage write SetGMessage; // no items for filter     
    property TxtSessions: pWideChar index 3 read GetGMessage write SetGMessage; // session header text     
    //----- Scroll bar properties -----
    property SBHidden: boolean read FSBHidden write SetSBHidden;

    destructor Destroy; override;
    procedure Allocate(ItemsCount: Integer; Scroll: Boolean = True);

    //----- Grid settings related -----
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GridUpdate(Updates: TGridUpdates);

    //----- Scrollbar functions -----
    procedure ScrollToBottom;

    function GetTopItem   : Integer;
    function GetBottomItem: Integer;
    function GetNext(Item: Integer; Force: Boolean = False): Integer;
    function GetPrev(Item: Integer; Force: Boolean = False): Integer;
    function IsVisible (Item: Integer; Partially: Boolean = True): Boolean;
    function IsSelected(Item: Integer): Boolean;
    procedure SelectAll;
    procedure SelectRange(FromItem, ToItem: Integer);
    // replace templates by values
    function FormatSelected(const Format: WideString): WideString;
  end;


function NewHistoryGrid(aParent:HWND):THistoryGrid;


implementation

uses
  Messages,
  RichEdit,
  Common, CustomGraph,
  m_api,
  hpp_richedit,
  hpp_arrays,
  hpp_strparser,
  hpp_itemprocess,
  hpp_icons,
  my_rtf,
  my_GridOptions;

const
  SBPageSize = 20;
  Padding = 4;

function GetDateTimeString(Time:Dword):pWideChar;
var
  buf:array [0..300] of WideChar;
  ST: TSystemTime;
  aft,lft:TFILETIME;
begin
  if Assigned(GridOptions) then
  begin
    UnixTimeToFileTime(Time,aft);
    FileTimeToLocalFileTime(aft, lft);
    FileTimeToSystemTime(aft,ST);
    GetDateFormatW(LOCALE_USER_DEFAULT,0,@ST,GridOptions.DateTimeFormat,@buf,300);
    GetTimeFormatW(LOCALE_USER_DEFAULT,0,@ST,@buf,@buf,300);
    StrDupW(result,buf);
  end
  else
    result:=nil;
end;

function THistoryGrid.GetGMessage(idx:integer):pWideChar;
begin
  result:=FMessages[idx];
end;

procedure THistoryGrid.SetGMessage(idx:integer;value:pWideChar);
begin
  if StrCmpW(value,FMessages[idx])<>0 then
  begin
    mFreeMem(FMessages[idx]);
    StrDupW (FMessages[idx],value);
  end;
end;

procedure THistoryGrid.Update;
begin
  UpdateWindow(FHandle);
end;

procedure THistoryGrid.Invalidate;
begin
  InvalidateRect(FHandle, nil, true);
end;

//----- History Grid implementation -----

procedure THistoryGrid.SetRichRTL(RTL: Boolean; aRichEdit: PHPPRichEdit);
var
  pf: PARAFORMAT2;
  lExStyle: DWord;
begin
  // we use RichEdit.Tag here to save previous RTL state to prevent from
  // reapplying same state, because SetRichRTL is called VERY OFTEN
  // (from ApplyItemToRich)
  if aRichEdit.RTL = RTL then
    exit;

  ZeroMemory(@pf, SizeOf(pf));
  pf.cbSize := SizeOf(pf);
  pf.dwMask := PFM_RTLPARA;
  lExStyle := DWord(GetWindowLongPtrW(aRichEdit.Handle, GWL_EXSTYLE)) and
    not(WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_RIGHT or WS_EX_LEFT);
  if RTL then
  begin
    lExStyle := lExStyle or (WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_LEFT);
    {$IFDEF FPC}pf.wEffects{$ELSE}pf.wReserved{$ENDIF} := PFE_RTLPARA;
  end
  else
  begin
    lExStyle := lExStyle or WS_EX_RIGHT;
    {$IFDEF FPC}pf.wEffects{$ELSE}pf.wReserved{$ENDIF} := 0;
  end;
  SendMessage(RichEdit.Handle, EM_SETPARAFORMAT, 0, lParam(@pf));
  SetWindowLongPtrW(aRichEdit.Handle, GWL_EXSTYLE, lExStyle);

  aRichEdit.RTL := RTL;
end;

{$include hg_support.inc}
{$include hg_gridsettings.inc}
{$include hg_format.inc}
{$include hg_items.inc}
{$include i_scroll.inc}
{$include hg_selections.inc}
{$include hg_re.inc}
{$include hg_hint.inc}

{$include i_messages.inc}
{$include i_mouse.inc}
{$include i_keys.inc}
{$include i_paint.inc}

{$include i_cwproc.inc}
{$include i_gwproc.inc}

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
    FItems[i].MessageType.code := mtUnknown;
    FRichCache.ResetItem(i); //?? if was before? or after deleting?
  end;

  SBMax := ItemsCount + SBPageSize - 1;
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

  Invalidate;
end;

destructor THistoryGrid.Destroy;
var
  i:integer;
begin
  UnhookEvent(hHookChange);
  
  // Destroy GDI objects
  DestroyWindow(FHandle); // FClient+FScrollBar are child windows, muse destroy automatically
  DeleteDC(FClientDC);
  if FClientBuf<>0 then
    DeleteObject(FClientBuf);

//  FRichInline.Free;

  // Destroy cache
  FRich := nil; //!! check for FreeHPPRichEdit in cache??
  FRichCache.Free;

  // Destroy strings
  mFreeMem(FContactName);
  mFreeMem(FProfileName);
  for i:=0 to HIGH(FMessages) do
    mFreeMem(FMessages[i]);

  //!!
  Finalize(FItems);

  inherited;
end;

// all class fields must be initialized by 0, false, nil
procedure THistoryGrid.InitDefaults;
var
  dc:HDC;
begin
//  ShowBottomAligned := False;
  CHeaderHeight := -1;
  PHeaderheight := -1;
//  ExpandHeaders := False;

  TxtStartup  := 'Starting up...';
  TxtNoItems  := 'History is empty';
  TxtNoSuch   := 'No such items';
  TxtSessions := 'Conversation started at %s';

//  FReversed := False;
//  FReversedHeader := False;
  FState := gsIdle;
//  IsCanvasClean := False;
  Multiselect := true;
//  Allocated := False;

//  BarAdjusted := False;
//  FSBHidden := false;

  FSelected := -1;
//  FContact := 0;
//  FProtocol := '';
  ShowBookmarks := True;

  FSelectionString := ''; //?? need to change to PWideChar;
//  FSelectionStored := False;

//  LockCount:=0;

  FFilter:=[mtUnknown, //!!mtIncoming, mtOutgoing,
           mtMessage, mtUrl, mtFile, mtSystem];

//  FHideSelection:=false;
  FGridNotFocused:=true;

  FClientDC:=CreateCompatibleDC(0);

  // Physic
  dc := GetDC(0);
  LogX := GetDeviceCaps(dc, LOGPIXELSX);
  LogY := GetDeviceCaps(dc, LOGPIXELSY);
  ReleaseDC(0, dc);

  VLineScrollSize := (LogY*13) div 96;//MulDiv(LogY, 13, 96);

//  FWheelLastTick   := 0;
//  FWheelAccumulator:= 0;

end;

function NewHistoryGrid(aParent:HWND):THistoryGrid;
//var rc:TRect;
begin
  result:=THistoryGrid.Create;

  // Create Main window
  result.FHandle:=CreateWindowExW(0,'STATIC',nil,WS_CHILD+WS_VISIBLE,
      CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
      aParent,0,hInstance,result);
  if result.FHandle<>0 then
  begin
    SetWindowLongPtrW(result.FHandle,GWL_WNDPROC,LONG_PTR(@GridWndProc));
    SetWindowLongPtrW(result.FHandle,GWLP_USERDATA,long_ptr(result));

//    GetClientRect(result.FHandle, rc);

    // Create the scroll bar.
    result.FScrollBar := CreateWindowExW(0,'SCROLLBAR',nil,
        WS_CHILD or WS_VISIBLE or SBS_VERT or SBS_RIGHTALIGN,
        CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
//        rc.Left,rc.Top,rc.Right,rc.Bottom,
        result.FHandle,0,hInstance,nil);

    if result.FScrollBar<>0 then
    begin
      SetWindowLongPtrW(result.FScrollBar,GWLP_USERDATA,long_ptr(result));
    end;

    // Create client window (Log)
    result.FClient:=CreateWindowExW(0,'STATIC',nil,WS_CHILD+WS_VISIBLE,
        CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
//        rc.Left,rc.Top,rc.Right,rc.Bottom,
        result.FHandle,0,hInstance,nil);

    if result.FClient<>0 then
    begin
      SetWindowLongPtrW(result.FClient,GWL_WNDPROC,LONG_PTR(@ClientWndProc));
      SetWindowLongPtrW(result.FClient,GWLP_USERDATA,long_ptr(result));

      // Create cache
      result.FRichCache:=NewRichCache(result.FClient);
      result.FRichCache.OnRichApply:=result.ApplyItemToRichCache;

      // Inline Editor
  //    result.InlineRichEdit:=NewHPPRichEdit(result.FClient,[]);

    end;

    result.InitDefaults;

    result.hHookChange:=HookEventObj(ME_HPP_OPTIONSCHANGED,@OnChange,result);

    result.GridUpdate([guSize,guOptions]); // not sure about guSize here really
  end;
end;

end.
