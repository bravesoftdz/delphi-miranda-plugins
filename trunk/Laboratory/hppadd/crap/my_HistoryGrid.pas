
unit my_HistoryGrid;

interface

uses
  Forms,
  Graphics,
  Controls,
  ComCtrls, // for TCustomRichEdit;

  Windows,
  Messages,
  RichEdit,

  Classes,

  m_api,
  VertSB,
  hpp_global,
  my_RichCache,
  my_GridOptions;

// workaround
type
  THPPRichEdit = TCustomRichEdit;
type
  TGridState = (gsIdle, gsDelete, gsSearch, gsSearchItem, gsLoad, gsSave, gsInline);
  TGridUpdate = (guSize, guAllocate, guFilter, guOptions);
  TGridUpdates = set of TGridUpdate;

  TGridHitTest = (ghtItem, ghtHeader, ghtText, ghtLink, ghtUnknown, ghtButton, ghtSession,
    ghtSessHideButton, ghtSessShowButton, ghtBookmark);
  TGridHitTests = set of TGridHitTest;

  TMouseMoveKey = (mmkControl, mmkLButton, mmkMButton, mmkRButton, mmkShift);
  TMouseMoveKeys = set of TMouseMoveKey;

  TOnPopup = TNotifyEvent;
  TOnTranslateTime = procedure(Sender: TObject; Time: DWord; var Text: String) of object;
  TOnSearchFinished = procedure(Sender: TObject; Text: String; Found: Boolean) of object;
  TOnProcessRichText = procedure(Sender: TObject; Handle: THandle; Item: Integer) of object;
  TOnItemDelete = procedure(Sender: TObject; Index: Integer) of object;
  TOnState = procedure(Sender: TObject; State: TGridState) of object;
  TOnSelect = procedure(Sender: TObject; Item, OldItem: Integer) of object;
  TOnFilterChange = TNotifyEvent;
  TOnItemFilter = procedure(Sender: TObject; Index: Integer; var Show: Boolean) of object;
  TOnSearchItem = procedure(Sender: TObject; Item: Integer; ID: Integer; var Found: Boolean) of object;
  TOnRTLChange = procedure(Sender: TObject; BiDiMode: TBiDiMode) of object;
  TOnOptionsChange = procedure(Sender: TObject) of object;
  TOnChar = procedure(Sender: TObject; var achar: WideChar; Shift: TShiftState) of object;
  TOnProcessInlineChange = procedure(Sender: TObject; Enabled: Boolean) of object;
  TOnBookmarkClick = procedure(Sender: TObject; Item: Integer) of object;
  TOnSelectRequest = TNotifyEvent;

  TUrlClickItemEvent = procedure(Sender: TObject; Item: Integer; Url: String;
    Button: TMouseButton) of object;

  THistoryGrid = class(TScrollingWinControl)
  private
    LogX, LogY: Integer;
    SessHeaderHeight: Integer;
    CHeaderHeight, PHeaderheight: Integer;
    IsCanvasClean: Boolean;
    ProgressRect: TRect;
    BarAdjusted: Boolean;
    LockCount: Integer;
    ClipRect: TRect;
    ShowProgress: Boolean;
    ProgressPercent: Byte;
    SearchPattern: String;
    VLineScrollSize: Integer;
    FContact: THandle;
    FProtocol: AnsiString;
    FLoadedCount: Integer;
    FOnPopup: TOnPopup;
    FTranslateTime: TOnTranslateTime;
    FDblClick: TNotifyEvent;
    FSearchFinished: TOnSearchFinished;
    FOnProcessRichText: TOnProcessRichText;
    FItemDelete: TOnItemDelete;
    FState: TGridState;
    FHideSelection: Boolean;
    FGridNotFocused: Boolean;

    FTxtNoItems: String;
    FTxtStartup: String;
    FTxtNoSuch: String;

    FTxtFullLog: String;
    FTxtPartLog: String;
    FTxtHistExport: String;
    FTxtGenHist1: String;
    FTxtGenHist2: String;
    FTxtSessions: String;

    FSelectionString: String;
    FSelectionStored: Boolean;

    FOnState: TOnState;
    FReversed: Boolean;
    FReversedHeader: Boolean;
    FOptions: TGridOptions;
    FMultiSelect: Boolean;
    FOnSelect: TOnSelect;
    FOnFilterChange: TOnFilterChange;
    FGetXMLData: TGetXMLData;
    FGetMCData: TGetMCData;
    FOnItemFilter: TOnItemFilter;

    FVertScrollBar: TVertScrollBar;

    FRichCache: TRichCache;
    FOnUrlClick: TUrlClickItemEvent;
    FRich: THPPRichEdit;
    FRichInline: THPPRichEdit;
    FItemInline: Integer;
    FRichSave: THPPRichEdit;
    FRichSaveItem: THPPRichEdit;
    FRichSaveOLECB: TRichEditOleCallback;

    FOnInlineKeyDown: TKeyEvent;
    FOnInlineKeyUp: TKeyEvent;
    FOnInlinePopup: TOnPopup;

    FRichHeight: Integer;
    FRichParamsSet: Boolean;
    FOnSearchItem: TOnSearchItem;

    FOnRTLChange: TOnRTLChange;

    FOnOptionsChange: TOnOptionsChange;

    TopItemOffset: Integer;
    MaxSBPos: Integer;
    FShowHeaders: Boolean;
    FCodepage: Cardinal;
    FOnChar: TOnChar;
    WindowPrePainting: Boolean;
    WindowPrePainted: Boolean;
    FExpandHeaders: Boolean;
    FOnProcessInlineChange: TOnProcessInlineChange;

    FOnBookmarkClick: TOnBookmarkClick;
    FShowBookmarks: Boolean;
    FGroupLinked: Boolean;
    FShowBottomAligned: Boolean;
    FOnSelectRequest: TOnSelectRequest;
    FBorderStyle: TBorderStyle;

    FWheelAccumulator: Integer;
    FWheelLastTick: Cardinal;

    FHintRect: TRect;
    // !!    function GetHint: WideString;
    // !!    procedure SetHint(const Value: WideString);
    // !!    function IsHintStored: Boolean;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;

    procedure SetBorderStyle(Value: TBorderStyle);

    procedure SetCodepage(const Value: Cardinal);
    procedure SetShowHeaders(const Value: Boolean);
    function GetIdx(Index: Integer): Integer;
    // Item offset support
    // procedure SetScrollBar
    procedure ScrollGridBy(Offset: Integer; Update: Boolean = True);
    procedure SetSBPos(Position: Integer);
    // FRich events
    // procedure OnRichResize(Sender: TObject; Rect: TRect);
    // procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClick(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMMButtonDown(var Message: TWMRButtonDown); message WM_MBUTTONDOWN;
    procedure WMMButtonUp(var Message: TWMRButtonDown); message WM_MBUTTONUP;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMSysKeyUp(var Message: TWMSysKeyUp); message WM_SYSKEYUP;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure EMGetSel(var Message: TMessage); message EM_GETSEL;
    procedure EMExGetSel(var Message: TMessage); message EM_EXGETSEL;
    procedure EMSetSel(var Message: TMessage); message EM_SETSEL;
    procedure EMExSetSel(var Message: TMessage); message EM_EXSETSEL;
    procedure WMGetText(var Message: TWMGetText); message WM_GETTEXT;
    procedure WMGetTextLength(var Message: TWMGetTextLength); message WM_GETTEXTLENGTH;
    procedure WMSetText(var Message: TWMSetText); message WM_SETTEXT;

    function GetCount: Integer;
    procedure SetContact(const Value: THandle);
    procedure SetPadding(Value: Integer);
    procedure SetSelected(const Value: Integer);
    procedure AddSelected(Item: Integer);
    procedure RemoveSelected(Item: Integer);
    procedure MakeRangeSelected(FromItem, ToItem: Integer);
    procedure MakeSelectedTo(Item: Integer);
    procedure MakeVisible(Item: Integer);
    procedure MakeSelected(Value: Integer);
    function GetSelCount: Integer;
    function GetTime(Time: DWord): String;
    function GetItems(Index: Integer): THistoryItem;
    function IsMatched(Index: Integer): Boolean;
    function IsUnknown(Index: Integer): Boolean;
    procedure WriteString(fs: TFileStream; Text: AnsiString);
    procedure WriteWideString(fs: TFileStream; Text: String);
    procedure CheckBusy;
    function GetSelItems(Index: Integer): Integer;
    procedure SetSelItems(Index: Integer; Item: Integer);
    procedure SetState(const Value: TGridState);
    procedure SetReversed(const Value: Boolean);
    procedure SetReversedHeader(const Value: Boolean);
    procedure AdjustScrollBar;
    procedure SetOptions(const Value: TGridOptions);
    procedure SetMultiSelect(const Value: Boolean);

    procedure SetVertScrollBar(const Value: TVertScrollBar);
    function GetHideScrollBar: Boolean;
    procedure SetHideScrollBar(const Value: Boolean);

    function GetHitTests(X, Y: Integer): TGridHitTests;

    function GetLinkAtPoint(X, Y: Integer): String;
    function GetHintAtPoint(X, Y: Integer; var ObjectHint: WideString; var ObjectRect: TRect): Boolean;
    function GetRichEditRect(Item: Integer; DontClipTop: Boolean = False): TRect;

    procedure SetExpandHeaders(const Value: Boolean);
    procedure SetProcessInline(const Value: Boolean);
    function GetBookmarked(Index: Integer): Boolean;
    procedure SetBookmarked(Index: Integer; const Value: Boolean);
    procedure SetGroupLinked(const Value: Boolean);
    procedure SetHideSelection(const Value: Boolean);

    procedure OnInlineOnExit(Sender: TObject);
    procedure OnInlineOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnInlineOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnInlineOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnInlineOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnInlineOnURLClick(Sender: TObject; const URLText: String; Button: TMouseButton);

    function IsLinkAtPoint(RichEditRect: TRect; X, Y, Item: Integer): Boolean;

  protected
    DownHitTests: TGridHitTests;
    HintHitTests: TGridHitTests;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure CreateParams(var Params: TCreateParams); override;
    // procedure WndProc(var Message: TMessage); override;
    property Canvas: TCanvas read FCanvas;
    procedure Paint;
    procedure PaintHeader(Index: Integer; ItemRect: TRect);
    procedure PaintItem(Index: Integer; ItemRect: TRect);
    procedure DrawProgress;
    procedure DrawMessage(Text: String);
    procedure LoadItem(Item: Integer; LoadHeight: Boolean = True; Reload: Boolean = False);
    procedure DoKeyDown(var Key: Word; ShiftState: TShiftState);
    procedure DoKeyUp(var Key: Word; ShiftState: TShiftState);
    procedure DoChar(var Ch: WideChar; ShiftState: TShiftState);
    procedure DoLButtonDblClick(X, Y: Integer; Keys: TMouseMoveKeys);
    procedure DoLButtonDown(X, Y: Integer; Keys: TMouseMoveKeys);
    procedure DoLButtonUp(X, Y: Integer; Keys: TMouseMoveKeys);
    procedure DoMouseMove(X, Y: Integer; Keys: TMouseMoveKeys);
    procedure DoRButtonDown(X, Y: Integer; Keys: TMouseMoveKeys);
    procedure DoRButtonUp(X, Y: Integer; Keys: TMouseMoveKeys);
    procedure DoMButtonDown(X, Y: Integer; Keys: TMouseMoveKeys);
    procedure DoMButtonUp(X, Y: Integer; Keys: TMouseMoveKeys);

    procedure DoProgress(Position, Max: Integer);
    function CalcItemHeight(Item: Integer): Integer;
    procedure ScrollBy(DeltaX, DeltaY: Integer);
    procedure DeleteItem(Item: Integer);
    procedure SaveStart(Stream: TFileStream; SaveFormat: TSaveFormat; Caption: String);
    procedure SaveItem(Stream: TFileStream; Item: Integer; SaveFormat: TSaveFormat);
    procedure SaveEnd(Stream: TFileStream; SaveFormat: TSaveFormat);

    procedure GridUpdateSize;
    function GetSelectionString: String;
    procedure URLClick(Item: Integer; const URLText: String; Button: TMouseButton); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Contact: THandle read FContact write SetContact;
    property Protocol: AnsiString read FProtocol write FProtocol;
    property LoadedCount: Integer read FLoadedCount;
    procedure Allocate(ItemsCount: Integer; Scroll: Boolean = True);
    property Selected: Integer read FSelected write SetSelected;
    property SelCount: Integer read GetSelCount;
    function FindItemAt(X, Y: Integer; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint; out ItemRect: TRect): Integer; overload;
    function FindItemAt(P: TPoint): Integer; overload;
    function FindItemAt(X, Y: Integer): Integer; overload;
    function GetItemRect(Item: Integer): TRect;
    function IsSelected(Item: Integer): Boolean;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GridUpdate(Updates: TGridUpdates);
    function IsVisible(Item: Integer; Partially: Boolean = True): Boolean;
    procedure Delete(Item: Integer);
    procedure DeleteSelected;
    procedure DeleteAll;
    procedure SelectRange(FromItem, ToItem: Integer);
    procedure SelectAll;
    property Items[Index: Integer]: THistoryItem read GetItems;
    property Bookmarked[Index: Integer]: Boolean read GetBookmarked write SetBookmarked;
    property SelectedItems[Index: Integer]: Integer read GetSelItems write SetSelItems;
    function Search(Text: String; CaseSensitive: Boolean; FromStart: Boolean = False;
      SearchAll: Boolean = False; FromNext: Boolean = False; Down: Boolean = True): Integer;
    function SearchItem(ItemID: Integer): Integer;
    procedure AddItem;
    procedure SaveSelected(FileName: String; SaveFormat: TSaveFormat);
    procedure SaveAll(FileName: String; SaveFormat: TSaveFormat);
    function GetNext(Item: Integer; Force: Boolean = False): Integer;
    function GetDown(Item: Integer): Integer;
    function GetPrev(Item: Integer; Force: Boolean = False): Integer;
    function GetUp(Item: Integer): Integer;
    function GetTopItem: Integer;
    function GetBottomItem: Integer;
    property State: TGridState read FState write SetState;
    function GetFirstVisible: Integer;
    procedure UpdateFilter;

    procedure EditInline(Item: Integer);
    procedure CancelInline(DoSetFocus: Boolean = True);
    procedure AdjustInlineRichedit;
    function GetItemInline: Integer;
    property InlineRichEdit: THPPRichEdit read FRichInline write FRichInline;
    property RichEdit: THPPRichEdit read FRich write FRich;

    property Options: TGridOptions read FOptions write SetOptions;
    property HotString: String read SearchPattern;

    procedure MakeTopmost(Item: Integer);
    procedure ScrollToBottom;
    procedure ResetItem(Item: Integer);
    procedure ResetAllItems;

    procedure IntFormatItem(Item: Integer; var Tokens: TWideStrArray; var SpecialTokens: TIntArray);
    procedure PrePaintWindow;

    property Codepage: Cardinal read FCodepage write SetCodepage;

    property SelectionString: String read GetSelectionString;
  published
    function GetItemRTL(Item: Integer): Boolean;

    // procedure CopyToClipSelected(const Format: WideString; ACodepage: Cardinal = CP_ACP);
    procedure ApplyItemToRich(Item: Integer; RichEdit: THPPRichEdit = nil; ForceInline: Boolean = False);

    function FormatItem(Item: Integer; Format: String): String;
    function FormatItems(ItemList: array of Integer; Format: String): String;
    function FormatSelected(const Format: String): String;

    property ShowBottomAligned: Boolean read FShowBottomAligned write FShowBottomAligned;
    property ShowBookmarks: Boolean read FShowBookmarks write FShowBookmarks;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect;
    property ShowHeaders: Boolean read FShowHeaders write SetShowHeaders;
    property ExpandHeaders: Boolean read FExpandHeaders write SetExpandHeaders default True;
    property GroupLinked: Boolean read FGroupLinked write SetGroupLinked default False;
    property ProcessInline: Boolean write SetProcessInline;
    property TxtStartup: String read FTxtStartup write FTxtStartup;
    property TxtNoItems: String read FTxtNoItems write FTxtNoItems;
    property TxtNoSuch: String read FTxtNoSuch write FTxtNoSuch;
    property TxtFullLog: String read FTxtFullLog write FTxtFullLog;
    property TxtPartLog: String read FTxtPartLog write FTxtPartLog;
    property TxtHistExport: String read FTxtHistExport write FTxtHistExport;
    property TxtGenHist1: String read FTxtGenHist1 write FTxtGenHist1;
    property TxtGenHist2: String read FTxtGenHist2 write FTxtGenHist2;
    property TxtSessions: String read FTxtSessions write FTxtSessions;
    property ProfileName: String read GetProfileName write SetProfileName;
    property ContactName: String read FContactName write SetContactName;
    property OnDblClick: TNotifyEvent read FDblClick write FDblClick;
    property OnPopup: TOnPopup read FOnPopup write FOnPopup;
    property OnTranslateTime: TOnTranslateTime read FTranslateTime write FTranslateTime;
    property OnSearchFinished: TOnSearchFinished read FSearchFinished write FSearchFinished;
    property OnItemDelete: TOnItemDelete read FItemDelete write FItemDelete;
    property OnKeyDown;
    property OnKeyUp;

    property OnInlineKeyDown: TKeyEvent read FOnInlineKeyDown write FOnInlineKeyDown;
    property OnInlineKeyUp: TKeyEvent read FOnInlineKeyUp write FOnInlineKeyUp;
    property OnInlinePopup: TOnPopup read FOnInlinePopup write FOnInlinePopup;

    property OnProcessInlineChange: TOnProcessInlineChange read FOnProcessInlineChange write FOnProcessInlineChange;
    property OnOptionsChange: TOnOptionsChange read FOnOptionsChange write FOnOptionsChange;
    property OnChar: TOnChar read FOnChar write FOnChar;
    property OnState: TOnState read FOnState write FOnState;
    property OnSelect: TOnSelect read FOnSelect write FOnSelect;
    property OnRTLChange: TOnRTLChange read FOnRTLChange write FOnRTLChange;

    property OnUrlClick: TUrlClickItemEvent read FOnUrlClick write FOnUrlClick;

    property OnBookmarkClick: TOnBookmarkClick read FOnBookmarkClick write FOnBookmarkClick;
    property OnItemFilter: TOnItemFilter read FOnItemFilter write FOnItemFilter;
    property OnProcessRichText: TOnProcessRichText read FOnProcessRichText write FOnProcessRichText;
    property OnSearchItem: TOnSearchItem read FOnSearchItem write FOnSearchItem;
    property OnSelectRequest: TOnSelectRequest read FOnSelectRequest write FOnSelectRequest;
    property OnFilterChange: TOnFilterChange read FOnFilterChange write FOnFilterChange;

    property Reversed: Boolean read FReversed write SetReversed;
    property ReversedHeader: Boolean read FReversedHeader write SetReversedHeader;
    property TopItem: Integer read GetTopItem;
    property BottomItem: Integer read GetBottomItem;
    property ItemInline: Integer read GetItemInline;
    property HideSelection: Boolean read FHideSelection write SetHideSelection default False;
    property Align;
    property Anchors;
    property TabStop;
    property Font;
    property Color;
    property ParentColor;
    property BiDiMode;
    property ParentBiDiMode;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property BorderWidth;
    property Ctl3D;
    property ParentCtl3D;
    property Padding: Integer read FPadding write SetPadding;

    property VertScrollBar: TVertScrollBar read FVertScrollBar write SetVertScrollBar;
    property HideScrollBar: Boolean read GetHideScrollBar write SetHideScrollBar;
    // !!    property Hint: String read GetHint write SetHint stored IsHintStored;
    property ShowHint;
  end;

implementation

constructor THistoryGrid.Create(AOwner: TComponent);
const
  GridStyle = [csCaptureMouse, csClickEvents, csDoubleClicks, csReflector, csOpaque,
    csNeedsBorderPaint];
var
  dc: HDC;
begin
  inherited;
  ShowHint := True;
  HintHitTests := [];

  FRichCache := TRichCache.Create({!!Self});

  FRichParamsSet := False;

  // Ok, now inlined richedit
  FRichInline := THPPRichEdit.Create(Self);
  // workaround of SmileyAdd making richedit visible all the time
  FRichInline.Top := -MaxInt;
  FRichInline.Height := -1;
  FRichInline.Name := 'FRichInline';
  FRichInline.Visible := False;

  FRichInline.WordWrap := True;
  FRichInline.BorderStyle := bsNone;
  FRichInline.ReadOnly := True;

  FRichInline.ScrollBars := ssVertical;
  FRichInline.HideScrollBars := True;

  FRichInline.OnExit := OnInlineOnExit;
  FRichInline.OnKeyDown := OnInlineOnKeyDown;
  FRichInline.OnKeyUp := OnInlineOnKeyUp;
  FRichInline.OnMouseDown := OnInlineOnMouseDown;
  FRichInline.OnMouseUp := OnInlineOnMouseUp;
  FRichInline.OnUrlClick := OnInlineOnURLClick;

  FRichInline.Brush.Style := bsClear;

  FItemInline := -1;

  FCodepage := CP_ACP;

  CHeaderHeight := -1;
  PHeaderheight := -1;
  FExpandHeaders := False;

  TabStop := True;
  MultiSelect := True;

  TxtStartup := 'Starting up...';
  TxtNoItems := 'History is empty';
  TxtNoSuch := 'No such items';
  TxtFullLog := 'Full History Log';
  TxtPartLog := 'Partial History Log';
  TxtHistExport := hppName + ' export';
  TxtGenHist1 := '### (generated by ' + hppName + ' plugin)';
  TxtGenHist2 := '<h6>Generated by <b dir="ltr">' + hppName + '</b> Plugin</h6>';
  TxtSessions := 'Conversation started at %s';

  FReversed := False;
  FReversedHeader := False;

  FState := gsIdle;

  IsCanvasClean := False;

  BarAdjusted := False;
  Allocated := False;

  ShowBottomAligned := False;

  ProgressPercent := 255;
  ShowProgress := False;

  if NewStyleControls then
    ControlStyle := GridStyle
  else
    ControlStyle := GridStyle + [csFramed];

  LockCount := 0;

  // fill all events with unknown to force filter reset
  FFilter := GenerateEvents(FM_EXCLUDE, []) + [mtUnknown, mtCustom];

  FSelected := -1;
  FContact := 0;
  FProtocol := '';
  FPadding := 4;
  FShowBookmarks := True;

  FClient := Graphics.TBitmap.Create;
  FClient.Width := 1;
  FClient.Height := 1;

  FCanvas := FClient.Canvas;
  FCanvas.Font.Name := 'MS Shell Dlg';

  // get line scroll size depending on current dpi
  // default is 13px for standard 96dpi
  dc := GetDC(0);
  LogX := GetDeviceCaps(dc, LOGPIXELSX);
  LogY := GetDeviceCaps(dc, LOGPIXELSY);
  ReleaseDC(0, dc);
  VLineScrollSize := MulDiv(LogY, 13, 96);

  FVertScrollBar := TVertScrollBar.Create(Self, sbVertical);

  VertScrollBar.Increment := VLineScrollSize;

  FBorderStyle := bsSingle;

  FHideSelection := False;
  FGridNotFocused := True;

  FSelectionString := '';
  FSelectionStored := False;
end;

function THistoryGrid.GetBookmarked(Index: Integer): Boolean;
begin
  Result := Items[Index].Bookmarked;
end;

procedure THistoryGrid.SetBookmarked(Index: Integer; const Value: Boolean);
var
  r: TRect;
begin
  // don't set unknown items, we'll got correct bookmarks when we load them anyway
  if IsUnknown(Index) then
    exit;
  if Bookmarked[Index] = Value then
    exit;
  FItems[Index].Bookmarked := Value;
  if IsVisible(Index) then
  begin
    r := GetItemRect(Index);
    InvalidateRect(Handle, @r, False);
    Update;
  end;
end;

procedure THistoryGrid.SetCodepage(const Value: Cardinal);
begin
  if FCodepage = Value then
    exit;
  FCodepage := Value;
  ResetAllItems;
end;

procedure THistoryGrid.SetContact(const Value: THandle);
begin
  if FContact = Value then
    exit;
  FContact := Value;
end;

procedure THistoryGrid.SetExpandHeaders(const Value: Boolean);
var
  i: Integer;
begin
  if FExpandHeaders = Value then
    exit;
  FExpandHeaders := Value;
  for i := 0 to Length(FItems) - 1 do
  begin
    if FItems[i].HasHeader then
    begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;
  BarAdjusted := False;
  AdjustScrollBar;
  Invalidate;
end;

procedure THistoryGrid.SetProcessInline(const Value: Boolean);
begin
  if State = gsInline then
  begin
    FRichInline.Lines.BeginUpdate;
    ApplyItemToRich(Selected, FRichInline);
    FRichInline.SelStart := 0;
    FRichInline.Lines.EndUpdate;
  end;
  if Assigned(FOnProcessInlineChange) then
    FOnProcessInlineChange(Self, Value);
end;

procedure THistoryGrid.SetShowHeaders(const Value: Boolean);
var
  i: Integer;
begin
  if FShowHeaders = Value then
    exit;
  FShowHeaders := Value;
  for i := 0 to Length(FItems) - 1 do
  begin
    if FItems[i].HasHeader then
    begin
      FItems[i].Height := -1;
      FRichCache.ResetItem(i);
    end;
  end;
  BarAdjusted := False;
  AdjustScrollBar;
  Invalidate;
end;

var
  // WasDownOnGrid hack was introduced
  // because I had the following problem: when I have
  // history of contact A opened and have search results
  // with messages from A, and if the history is behind the
  // search results window, when I double click A's message
  // I get hisory to the front with sometimes multiple messages
  // selected because it 1) selects right message;
  // 2) brings history window to front; 3) sends wm_mousemove message
  // to grid saying that left button is pressed (???) and because
  // of that shit grid thinks I'm selecting several items. So this
  // var is used to know whether mouse button was down down on grid
  // somewhere else
  WasDownOnGrid: Boolean = False;

function THistoryGrid.GetItemRect(Item: Integer): TRect;
var
  tmp, idx, SumHeight: Integer;
  succ: Boolean;
begin
  Result := Rect(0, 0, 0, 0);
  SumHeight := -TopItemOffset;
  if Item = -1 then
    exit;
  if not IsMatched(Item) then
    exit;
  if GetIdx(Item) < GetIdx(GetFirstVisible) then
  begin
    idx := GetFirstVisible;
    tmp := GetUp(idx);
    if tmp <> -1 then
      idx := tmp;
    { .TODO: fix here, don't go up, go down from 0 }
    if Reversed then
      succ := (idx <= Item)
    else
      succ := (idx >= Item);
    while succ do
    begin
      LoadItem(idx);
      Inc(SumHeight, FItems[idx].Height);
      idx := GetPrev(idx);
      if idx = -1 then
        break;
      if Reversed then
        succ := (idx <= Item)
      else
        succ := (idx >= Item);
    end;
    Result := Rect(0, -SumHeight, ClientWidth, -SumHeight + FItems[Item].Height);
    exit;
  end;

  idx := GetFirstVisible;

  while GetIdx(idx) < GetIdx(Item) do
  begin
    LoadItem(idx);
    Inc(SumHeight, FItems[idx].Height);
    idx := GetNext(idx);
    if idx = -1 then
      break;
  end;

  Result := Rect(0, SumHeight, ClientWidth, SumHeight + FItems[Item].Height);
end;

function THistoryGrid.GetItemRTL(Item: Integer): Boolean;
begin
  if FItems[Item].RTLMode = hppRTLDefault then
  begin
    if RTLMode = hppRTLDefault then
      Result := Options.RTLEnabled
    else
      Result := (RTLMode = hppRTLEnable);
  end
  else
    Result := (FItems[Item].RTLMode = hppRTLEnable)
end;


procedure THistoryGrid.EMGetSel(var Message: TMessage);
var
  M: TWMGetTextLength;
begin
  WMGetTextLength(M);
  Puint_ptr(Message.wParam)^ := 0;
  Puint_ptr(Message.lParam)^ := M.Result;
end;

procedure THistoryGrid.EMExGetSel(var Message: TMessage);
var
  M: TWMGetTextLength;
begin
  Message.wParam := 0;
  if Message.lParam = 0 then
    exit;
  WMGetTextLength(M);
  TCharRange(Pointer(Message.lParam)^).cpMin := 0;
  TCharRange(Pointer(Message.lParam)^).cpMax := M.Result;
end;

procedure THistoryGrid.EMSetSel(var Message: TMessage);
begin
  FSelectionStored := False;
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnSelectRequest) then
    FOnSelectRequest(Self);
end;

procedure THistoryGrid.EMExSetSel(var Message: TMessage);
begin
  FSelectionStored := False;
  if csDestroying in ComponentState then
    exit;
  if Assigned(FOnSelectRequest) then
    FOnSelectRequest(Self);
end;

procedure THistoryGrid.WMGetText(var Message: TWMGetText);
var
  len: Integer;
  str: String;
begin
  str := SelectionString;
  len := Min(Message.TextMax - 1, Length(str));
  if len >= 0 then { W }
    StrLCopy(PChar(Message.Text), PChar(str), len);
  Message.Result := len;
end;

procedure THistoryGrid.WMGetTextLength(var Message: TWMGetTextLength);
var
  str: String;
begin
  str := SelectionString;
  Message.Result := Length(str);
end;

procedure THistoryGrid.WMSetText(var Message: TWMSetText);
begin
  FSelectionStored := False;
end;

procedure THistoryGrid.MakeTopmost(Item: Integer);
begin
  if (Item < 0) or (Item >= Count) then
    exit;
  SetSBPos(GetIdx(Item));
end;


function THistoryGrid.GetItems(Index: Integer): THistoryItem;
begin
  if (Index < 0) or (Index > High(FItems)) then
    exit;
  if IsUnknown(Index) then
    LoadItem(Index, False);
  Result := FItems[Index];
end;

function THistoryGrid.GetItemInline: Integer;
begin
  if State = gsInline then
    Result := FItemInline
  else
    Result := -1;
end;

procedure THistoryGrid.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array [TBorderStyle] of DWord = (0, WS_BORDER);
  ReadOnlys: array [Boolean] of DWord = (0, ES_READONLY);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := dword(Style) or BorderStyles[FBorderStyle] or ReadOnlys[True];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    with WindowClass do
      // style := style or CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW;
      Style := Style or CS_HREDRAW or CS_VREDRAW;
  end;
end;

procedure THistoryGrid.WMSetCursor(var Message: TWMSetCursor);
var
  P: TPoint;
  NewCursor: TCursor;
begin
  inherited;
  if State <> gsIdle then
    exit;
  if Message.HitTest = SmallInt(HTERROR) then
    exit;
  NewCursor := crDefault;
  P := ScreenToClient(Mouse.CursorPos);
  HintHitTests := GetHitTests(P.X, P.Y);
  if HintHitTests * [ghtButton, ghtLink] <> [] then
    NewCursor := crHandPoint;
  if Windows.GetCursor <> Screen.Cursors[NewCursor] then
  begin
    Windows.SetCursor(Screen.Cursors[NewCursor]);
    Message.Result := 1;
  end
  else
    Message.Result := 0;
end;

procedure THistoryGrid.WMSetFocus(var Message: TWMSetFocus);
var
  r: TRect;
begin
  if not((csDestroying in ComponentState) or IsChild(Handle, Message.FocusedWnd)) then
  begin
    CheckBusy;
    if FHideSelection and FGridNotFocused then
    begin
      if SelCount > 0 then
      begin
        FRichCache.ResetItems(FSelItems);
        Invalidate;
      end;
    end
    else if (FSelected <> -1) and IsVisible(FSelected) then
    begin
      r := GetItemRect(Selected);
      InvalidateRect(Handle, @r, False);
    end;
  end;
  FGridNotFocused := False;
  inherited;
end;

procedure THistoryGrid.WMKillFocus(var Message: TWMKillFocus);
var
  r: TRect;
begin
  if not((csDestroying in ComponentState) or IsChild(Handle, Message.FocusedWnd)) then
  begin
    if FHideSelection and not FGridNotFocused then
    begin
      if SelCount > 0 then
      begin
        FRichCache.ResetItems(FSelItems);
        Invalidate;
      end;
    end
    else if (FSelected <> -1) and IsVisible(FSelected) then
    begin
      r := GetItemRect(Selected);
      InvalidateRect(Handle, @r, False);
    end;
    FGridNotFocused := True;
  end;
  inherited;
end;

procedure THistoryGrid.WMCommand(var Message: TWMCommand);
begin
  inherited;
  if csDestroying in ComponentState then
    exit;
  if Message.Ctl = FRichInline.Handle then
  begin
    case Message.NotifyCode of
      EN_SETFOCUS:
        begin
          if State <> gsInline then
          begin
            FGridNotFocused := False;
            Windows.SetFocus(Handle);
            FGridNotFocused := True;
            PostMessage(Handle, WM_SETFOCUS, Handle, 0);
          end;
        end;
      EN_KILLFOCUS:
        begin
          if State = gsInline then
          begin
            CancelInline(False);
            PostMessage(Handle, WM_KILLFOCUS, Handle, 0);
          end;
          Message.Result := 0;
        end;
    end;
  end;
end;


function THistoryGrid.Search(Text: String; CaseSensitive: Boolean;
  FromStart: Boolean = False; SearchAll: Boolean = False; FromNext: Boolean = False;
  Down: Boolean = True): Integer;
var
  StartItem: Integer;
  C, Item: Integer;
begin
  Result := -1;

  if not CaseSensitive then
    Text := WideUpperCase(Text);

  if Selected = -1 then
  begin
    FromStart := True;
    FromNext := False;
  end;

  if FromStart then
  begin
    if Down then
      StartItem := GetTopItem
    else
      StartItem := GetBottomItem;
  end
  else if FromNext then
  begin
    if Down then
      StartItem := GetNext(Selected)
    else
      StartItem := GetPrev(Selected);

    if StartItem = -1 then
    begin
      StartItem := Selected;
    end;
  end
  else
  begin
    StartItem := Selected;
    if Selected = -1 then
      StartItem := GetNext(-1, True);
  end;

  Item := StartItem;

  C := Count;
  CheckBusy;
  State := gsSearch;
  try
    while (Item >= 0) and (Item < C) do
    begin
      if CaseSensitive then
      begin
        // need to strip bbcodes
        if Pos(Text, FItems[Item].Text) <> 0 then
        begin
          Result := Item;
          break;
        end;
      end
      else
      begin
        // need to strip bbcodes
        if Pos(Text, string(WideUpperCase(FItems[Item].Text))) <> 0 then
        begin
          Result := Item;
          break;
        end;
      end;

      if SearchAll then
        Inc(Item)
      else if Down then
        Item := GetNext(Item)
      else
        Item := GetPrev(Item);

      if Item <> -1 then
      begin
        // prevent GetNext from drawing progress
        IsCanvasClean := True;
        ShowProgress := True;
        DoProgress(Item, C - 1);
        ShowProgress := False;
      end;
    end;

    ShowProgress := False;
    DoProgress(0, 0);
  finally
    State := gsIdle;
  end;
end;

{$include my_saving.inc}

procedure THistoryGrid.CheckBusy;
begin
  if State = gsInline then
    CancelInline;
  if State <> gsIdle then
    raise EAbort.Create('Grid is busy');
end;

function THistoryGrid.GetSelItems(Index: Integer): Integer;
begin
  Result := FSelItems[Index];
end;

procedure THistoryGrid.SetSelItems(Index: Integer; Item: Integer);
begin
  AddSelected(Item);
end;

procedure THistoryGrid.SetMultiSelect(const Value: Boolean);
begin
  FMultiSelect := Value;
end;


function THistoryGrid.IsLinkAtPoint(RichEditRect: TRect; X, Y, Item: Integer): Boolean;
var
  P: TPoint;
  cr: CHARRANGE;
  cf: CharFormat2;
  cp: Integer;
  res: DWord;
begin
  Result := False;
  P := Point(X - RichEditRect.Left, Y - RichEditRect.Top);
  ApplyItemToRich(Item);

  cp := FRich.Perform(EM_CHARFROMPOS, 0, lParam(@P));
  if cp = -1 then
    exit; // out of richedit area
  cr.cpMin := cp;
  cr.cpMax := cp + 1;
  FRich.Perform(EM_EXSETSEL, 0, lParam(@cr));

  ZeroMemory(@cf, SizeOf(cf));
  cf.cbSize := SizeOf(cf);
  cf.dwMask := CFM_LINK;
  res := FRich.Perform(EM_GETCHARFORMAT, SCF_SELECTION, lParam(@cf));
  // no link under point
  Result := (((res and CFM_LINK) > 0) and ((cf.dwEffects and CFE_LINK) > 0)) or
    (((res and CFM_REVISED) > 0) and ((cf.dwEffects and CFE_REVISED) > 0));
end;

function THistoryGrid.GetHitTests(X, Y: Integer): TGridHitTests;
var
  Item: Integer;
  ItemRect: TRect;
  HeaderHeight: Integer;
  HeaderRect, SessRect: TRect;
  ButtonRect: TRect;
  P: TPoint;
  RTL: Boolean;
  Sel: Boolean;
  FullHeader: Boolean;
  TimestampOffset: Integer;
begin
  Result := [];
  FHintRect := Rect(0, 0, 0, 0);
  Item := FindItemAt(X, Y);
  if Item = -1 then
    exit;
  Include(Result, ghtItem);

  FullHeader := not(FGroupLinked and FItems[Item].LinkedToPrev);
  ItemRect := GetItemRect(Item);
  RTL := GetItemRTL(Item);
  Sel := IsSelected(Item);
  P := Point(X, Y);

  if FullHeader and (ShowHeaders) and (ExpandHeaders) and (FItems[Item].HasHeader) then
  begin
    if Reversed xor ReversedHeader then
    begin
      SessRect := Rect(ItemRect.Left, ItemRect.Top, ItemRect.Right,
        ItemRect.Top + SessHeaderHeight);
      Inc(ItemRect.Top, SessHeaderHeight);
    end
    else
    begin
      SessRect := Rect(ItemRect.Left, ItemRect.Bottom - SessHeaderHeight - 1, ItemRect.Right,
        ItemRect.Bottom - 1);
      Dec(ItemRect.Bottom, SessHeaderHeight);
    end;
    if PtInRect(SessRect, P) then
    begin
      Include(Result, ghtSession);
      InflateRect(SessRect, -3, -3);
      if RTL then
        ButtonRect := Rect(SessRect.Left, SessRect.Top, SessRect.Left + 16, SessRect.Bottom)
      else
        ButtonRect := Rect(SessRect.Right - 16, SessRect.Top, SessRect.Right, SessRect.Bottom);
      if PtInRect(ButtonRect, P) then
      begin
        Include(Result, ghtSessHideButton);
        Include(Result, ghtButton);
        FHintRect := ButtonRect;
      end;
    end;
  end;

  Dec(ItemRect.Bottom); // divider
  InflateRect(ItemRect, -Padding, -Padding); // paddings

  if FullHeader then
  begin
    Dec(ItemRect.Top, Padding);
    Inc(ItemRect.Top, Padding div 2);

    if mtIncoming in FItems[Item].MessageType then
      HeaderHeight := CHeaderHeight
    else
      HeaderHeight := PHeaderheight;

    HeaderRect := Rect(ItemRect.Left, ItemRect.Top, ItemRect.Right,
      ItemRect.Top + HeaderHeight);
    Inc(ItemRect.Top, HeaderHeight + (Padding - (Padding div 2)));
    if PtInRect(HeaderRect, P) then
    begin
      Include(Result, ghtHeader);
      if (ShowHeaders) and (not ExpandHeaders) and (FItems[Item].HasHeader) then
      begin
        if RTL then
          ButtonRect := Rect(HeaderRect.Right - 16, HeaderRect.Top, HeaderRect.Right,
            HeaderRect.Bottom)
        else
          ButtonRect := Rect(HeaderRect.Left, HeaderRect.Top, HeaderRect.Left + 16,
            HeaderRect.Bottom);
        if PtInRect(ButtonRect, P) then
        begin
          Include(Result, ghtSessShowButton);
          Include(Result, ghtButton);
          FHintRect := ButtonRect;
        end;
      end;
      if ShowBookmarks and (Sel or FItems[Item].Bookmarked) then
      begin
        if mtIncoming in FItems[Item].MessageType then
          Canvas.Font.Assign(Options.FontIncomingTimestamp)
        else
          Canvas.Font.Assign(Options.FontOutgoingTimestamp);
        TimestampOffset := Canvas.TextExtent(GetTime(FItems[Item].Time)).cX + Padding;
        if RTL then
          ButtonRect := Rect(HeaderRect.Left + TimestampOffset, HeaderRect.Top,
            HeaderRect.Left + TimestampOffset + 16, HeaderRect.Bottom)
        else
          ButtonRect := Rect(HeaderRect.Right - 16 - TimestampOffset, HeaderRect.Top,
            HeaderRect.Right - TimestampOffset, HeaderRect.Bottom);
        if PtInRect(ButtonRect, P) then
        begin
          Include(Result, ghtBookmark);
          Include(Result, ghtButton);
          FHintRect := ButtonRect;
        end;
      end;
    end;
  end;

  if PtInRect(ItemRect, P) then
  begin
    Include(Result, ghtText);
    FHintRect := ItemRect;
    if IsLinkAtPoint(ItemRect, X, Y, Item) then
      Include(Result, ghtLink)
    else
      Include(Result, ghtUnknown);
  end;
end;

procedure THistoryGrid.RemoveSelected(Item: Integer);
begin
  IntSortedArray_Remove(TIntArray(FSelItems), Item);
  FRichCache.ResetItem(Item);
end;

procedure THistoryGrid.ResetItem(Item: Integer);
begin
  // we need to adjust scrollbar after ResetItem if GetIdx(Item) >= MaxSBPos
  // as it's currently used to handle deletion with headers, adjust
  // is run after deletion ends, so no point in doing it here
  if IsUnknown(Item) then
    exit;
  FItems[Item].Height := -1;
  FItems[Item].MessageType := [mtUnknown];
  FRichCache.ResetItem(Item);
end;

procedure THistoryGrid.ResetAllItems;
var
  DoChanges: Boolean;
  i: Integer;
begin
  if not Allocated then
    exit;
  BeginUpdate;
  DoChanges := False;
  for i := 0 to Length(FItems) - 1 do
    if not IsUnknown(i) then
    begin
      DoChanges := True;
      // cose it's faster :)
      FItems[i].MessageType := [mtUnknown];
    end;
  if DoChanges then
    GridUpdate([guOptions]);
  EndUpdate;
end;

function THistoryGrid.GetRichEditRect(Item: Integer; DontClipTop: Boolean): TRect;
var
  res: TRect;
  hh: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  if Item = -1 then
    exit;
  Result := GetItemRect(Item);
  Inc(Result.Left, Padding);
  Dec(Result.Right, Padding);
  if FGroupLinked and FItems[Item].LinkedToPrev then
    hh := 0
  else if mtIncoming in FItems[Item].MessageType then
    hh := CHeaderHeight
  else
    hh := PHeaderheight;
  Inc(Result.Top, hh + Padding);
  Dec(Result.Bottom, Padding + 1);
  if (Items[Item].HasHeader) and (ShowHeaders) and (ExpandHeaders) then
  begin
    if Reversed xor ReversedHeader then
      Inc(Result.Top, SessHeaderHeight)
    else
      Dec(Result.Bottom, SessHeaderHeight);
  end;
  res := ClientRect;
{$IFDEF DEBUG}
  OutputDebugString
    (PWideChar(Format('GetRichEditRect client: Top:%d Left:%d Bottom:%d Right:%d',
    [res.Top, res.Left, res.Bottom, res.Right])));
  OutputDebugString
    (PWideChar(Format('GetRichEditRect item_2: Top:%d Left:%d Bottom:%d Right:%d',
    [Result.Top, Result.Left, Result.Bottom, Result.Right])));
{$ENDIF}
  if DontClipTop and (Result.Top < res.Top) then
    res.Top := Result.Top;
  IntersectRect(Result, res, Result);
end;

function THistoryGrid.SearchItem(ItemID: Integer): Integer;
var
  i : Integer;
  Found: Boolean;
begin
  if not Assigned(OnSearchItem) then
    raise Exception.Create('You must handle OnSearchItem event to use SearchItem function');
  Result := -1;
  State := gsSearchItem;
  try
    State := gsSearchItem;
    ShowProgress := True;
    for i := 0 to Count - 1 do
    begin
      if IsUnknown(i) then
        LoadItem(i, False);
      Found := False;
      OnSearchItem(Self, i, ItemID, Found);
      if Found then
      begin
        Result := i;
        break;
      end;
      DoProgress(i + 1, Count);
    end;
    ShowProgress := False;
  finally
    State := gsIdle;
  end;
end;

procedure THistoryGrid.SetBorderStyle(Value: TBorderStyle);
var
  Style, ExStyle: DWord;
begin
  if FBorderStyle = Value then
    exit;
  FBorderStyle := Value;
  if HandleAllocated then
  begin
    Style   := DWord(GetWindowLongPtr(Handle, GWL_STYLE)) and WS_BORDER;
    ExStyle := DWord(GetWindowLongPtr(Handle, GWL_EXSTYLE)) and not WS_EX_CLIENTEDGE;
    if Ctl3D and NewStyleControls and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    SetWindowLongPtr(Handle, GWL_STYLE, Style);
    SetWindowLongPtr(Handle, GWL_EXSTYLE, ExStyle);
  end;
end;

procedure THistoryGrid.CMBiDiModeChanged(var Message: TMessage);
var
  ExStyle: Cardinal;
begin
  if HandleAllocated then
  begin
    ExStyle := DWord(GetWindowLongPtr(Handle, GWL_EXSTYLE)) and
      not(WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_RIGHT or WS_EX_LEFT);
    AddBiDiModeExStyle(ExStyle);
    SetWindowLongPtr(Handle, GWL_EXSTYLE, ExStyle);
  end;
end;

procedure THistoryGrid.CMCtl3DChanged(var Message: TMessage);
var
  Style, ExStyle: DWord;
begin
  if HandleAllocated then
  begin
    Style   := DWord(GetWindowLongPtr(Handle, GWL_STYLE)) and WS_BORDER;
    ExStyle := DWord(GetWindowLongPtr(Handle, GWL_EXSTYLE)) and not WS_EX_CLIENTEDGE;
    if Ctl3D and NewStyleControls and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    SetWindowLongPtr(Handle, GWL_STYLE, Style);
    SetWindowLongPtr(Handle, GWL_EXSTYLE, ExStyle);
  end;
end;

procedure THistoryGrid.URLClick(Item: Integer; const URLText: String; Button: TMouseButton);
begin
  Application.CancelHint;
  Cursor := crDefault;
  if Assigned(OnUrlClick) then
    OnUrlClick(Self, Item, URLText, Button);
end;

end.
