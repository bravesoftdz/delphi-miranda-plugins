{
}
unit my_GridOptions;

interface

uses
  Windows,
  kol,
  hpp_global;

type
  TItemOption = record
    MessageType  : TMessageTypes;
    textFont     : PFont;
    textColor    : TColor;
    FontItemIndex: integer; // hppFontItems index
  end;
  TItemOptions = array of TItemOption;

  TGridOptions = class
  private
    hFontChanged,
    hColourChanged,
    hOptionsChanged:THANDLE;

    FLocks: Integer;
    Changed: Integer;

    FColorDivider     : TColor;
    FColorSelectedText: TColor;
    FColorSelected    : TColor;
    FColorSessHeader  : TColor;
    FColorBackground  : TColor;
    FColorLink        : TColor;

    FFontProfile          : PFont;
    FFontContact          : PFont;
    FFontIncomingTimestamp: PFont;
    FFontOutgoingTimestamp: PFont;
    FFontSessHeader       : PFont;
    FFontMessage          : PFont;

    FItemOptions: TItemOptions;

    FRawRTFEnabled  : Boolean;
    FRTLEnabled     : Boolean;
    FShowIcons      : Boolean;
    FOpenDetailsMode: Boolean;

    FBBCodesEnabled       : Boolean;
    FSmileysEnabled       : Boolean;
    FMathModuleEnabled    : Boolean;
    FAvatarsHistoryEnabled: Boolean;

    FTextFormatting: Boolean;

    FClipCopyTextFormat   : WideString;
    FClipCopyFormat       : WideString;
    FReplyQuotedFormat    : WideString;
    FReplyQuotedTextFormat: WideString;
    FSelectionFormat      : WideString;
    FDateTimeFormat       : WideString;


    FForceProfileName: Boolean;
    FProfileName: WideString;

    procedure SetShowIcons(const Value: Boolean);

    procedure SetTextFormatting(const Value: Boolean);
    procedure SetProfileName(const Value: WideString);

    function GetLocked: Boolean;
    procedure DoChange(mask: dword=HGOPT_ALL);
  public
    constructor Create;
    destructor Destroy; override;

    procedure FontReload();
    procedure ColourReload();
    procedure LoadOptions;
    procedure SaveOptions;
    procedure SaveTemplates;

    procedure StartChange;
    procedure EndChange(mask: dword=HGOPT_ALL; const Forced: Boolean = False);

    function AddItemOptions: Integer;
    function GetItemOptions(Mes: TMessageTypes; out textFont: PFont; out textColor: TColor): Integer;

    property ClipCopyFormat       : WideString read FClipCopyFormat        write FClipCopyFormat;
    property ClipCopyTextFormat   : WideString read FClipCopyTextFormat    write FClipCopyTextFormat;
    property ReplyQuotedFormat    : WideString read FReplyQuotedFormat     write FReplyQuotedFormat;
    property ReplyQuotedTextFormat: WideString read FReplyQuotedTextFormat write FReplyQuotedTextFormat;
    property SelectionFormat      : WideString read FSelectionFormat       write FSelectionFormat;
    property DateTimeFormat       : WideString read FDateTimeFormat        write FDateTimeFormat;

    property Locked: Boolean read GetLocked;

    property ColorDivider     : TColor read FColorDivider      write FColorDivider;
    property ColorSelectedText: TColor read FColorSelectedText write FColorSelectedText;
    property ColorSelected    : TColor read FColorSelected     write FColorSelected;
    property ColorSessHeader  : TColor read FColorSessHeader   write FColorSessHeader;
    property ColorBackground  : TColor read FColorBackground   write FColorBackground;
    property ColorLink        : TColor read FColorLink         write FColorLink;

    property FontProfile          : PFont read FFontProfile;
    property FontContact          : PFont read FFontContact;
    property FontIncomingTimestamp: PFont read FFontIncomingTimestamp;
    property FontOutgoingTimestamp: PFont read FFontOutgoingTimestamp;
    property FontSessHeader       : PFont read FFontSessHeader;
    property FontMessage          : PFont read FFontMessage;

    property ItemOptions: TItemOptions read FItemOptions write FItemOptions;

    property RTLEnabled: Boolean read FRTLEnabled write FRTLEnabled;
    property ShowIcons : Boolean read FShowIcons  write SetShowIcons;

    property BBCodesEnabled       : Boolean read FBBCodesEnabled        write FBBCodesEnabled;
    property SmileysEnabled       : Boolean read FSmileysEnabled        write FSmileysEnabled;
    property MathModuleEnabled    : Boolean read FMathModuleEnabled     write FMathModuleEnabled;
    property RawRTFEnabled        : Boolean read FRawRTFEnabled         write FRawRTFEnabled;
    property AvatarsHistoryEnabled: Boolean read FAvatarsHistoryEnabled write FAvatarsHistoryEnabled;

    property OpenDetailsMode: Boolean read FOpenDetailsMode write FOpenDetailsMode;
    property ForceProfileName: Boolean read FForceProfileName;
    property ProfileName: WideString read FProfileName write SetProfileName;

    property TextFormatting: Boolean read FTextFormatting write SetTextFormatting;
  end;

var
  GridOptions:TGridOptions = nil;

implementation

uses
  m_api,
  Common, dbsettings,
  hpp_contacts,
  hpp_options;

const
  DEFFORMAT_CLIPCOPY        = '%nick%, %smart_datetime%:\n%mes%\n';
  DEFFORMAT_CLIPCOPYTEXT    = '%mes%\n';
  DEFFORMAT_REPLYQUOTED     = '%nick%, %smart_datetime%:\n%quot_mes%\n';
  DEFFORMAT_REPLYQUOTEDTEXT = '%quot_selmes%\n';
  DEFFORMAT_SELECTION       = '%selmes%\n';
  DEFFORMAT_DATETIME        = 'dd.MM.yy HH:mm:ss'; // ShortDateFormat + LongTimeFormat


function GetDBWideStr(setting:PAnsiChar;default:pWideChar):WideString;
var
  tmp:pWideChar;
begin
  tmp:=DBReadUnicode(0,hppDBName,setting,default);
  result:=WideString(tmp);
  FreeMem(tmp);
end;


function OnFontChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  result:=0;
  GridOptions.FontReload();
end;

function OnColourChanged(wParam: WPARAM; lParam: LPARAM): Integer; cdecl;
begin
  result:=0;
  GridOptions.ColourReload();
end;

{ TGridOptions }

function TGridOptions.AddItemOptions: Integer;
var
  i: Integer;
begin
  i := Length(FItemOptions);
  SetLength(FItemOptions, i + 1);
  FItemOptions[i].MessageType := [mtOther];
  FItemOptions[i].textFont    := NewFont;
  Result := i;
end;

constructor TGridOptions.Create;
var
  i,index: integer;
begin
  inherited;

  FRTLEnabled := False;
  FShowIcons := False;

  FSmileysEnabled        := False;
  FBBCodesEnabled        := False;
  FMathModuleEnabled     := False;
  FRawRTFEnabled         := False;
  FAvatarsHistoryEnabled := False;

  FOpenDetailsMode := False;

  FProfileName := '';
  FForceProfileName := False;

  FTextFormatting := True;

  FLocks  := 0;
  Changed := 0;

  FFontContact           := NewFont;
  FFontProfile           := NewFont;
  FFontIncomingTimestamp := NewFont;
  FFontOutgoingTimestamp := NewFont;
  FFontSessHeader        := NewFont;
  FFontMessage           := NewFont;

  // cycle 1: calculate
  index := 0;
  for i := 0 to High(hppFontItems) do
  begin
    if hppFontItems[i].Mes <> [] then
    begin
      Inc(index);
    end;
  end;
  SetLength(FItemOptions,index);

  // cycle 2: initialize
  index := 0;
  for i := 0 to High(hppFontItems) do
  begin
    if hppFontItems[i].Mes <> [] then
    begin
      with FItemOptions[index] do
      begin
        FontItemIndex := i;
        MessageType   := hppFontItems[i].Mes;
        textFont      := NewFont;
      end;
      Inc(index);
    end;
  end;

  hOptionsChanged:=CreateHookableEvent(ME_HPP_OPTIONSCHANGED);

  hFontChanged  :=HookEvent(ME_FONT_RELOAD  ,OnFontChanged);
  hColourChanged:=HookEvent(ME_COLOUR_RELOAD,OnColourChanged);
end;

destructor TGridOptions.Destroy;
var
  i: Integer;
begin
  DestroyHookableEvent(hOptionsChanged);

  UnHookEvent(hFontChanged);
  UnHookEvent(hColourChanged);

  FFontContact.Free;
  FFontProfile.Free;
  FFontIncomingTimestamp.Free;
  FFontOutgoingTimestamp.Free;
  FFontSessHeader.Free;
  FFontMessage.Free;
  for i := 0 to HIGH(FItemOptions) do
  begin
    FItemOptions[i].textFont.Free;
  end;
  Finalize(FItemOptions);

  inherited;
end;

procedure LoadFont(Order: Integer; aFont:PFont);
var
  fid: TFontIDW;
  lf: TLogFontW;
  col: TColor;
begin
  fid.cbSize := sizeof(fid);
  StrCopyW(fid.group, hppName);
  StrCopyW(fid.name, hppFontItems[Order].name);
  col := CallService(MS_FONT_GETW, WPARAM(@fid), LPARAM(@lf));

  aFont.LogFontStruct:=lf;
  aFont.Color:=col;
end;

procedure TGridOptions.FontReload();
var
  i: integer;
begin
  // load fonts
  LoadFont(0 , FontContact);
  LoadFont(1 , FontProfile);
  LoadFont(17, FontSessHeader);
  LoadFont(20, FontIncomingTimestamp);
  LoadFont(21, FontOutgoingTimestamp);
  LoadFont(22, FontMessage);

  // load mestype-related
  for i := 0 to High(ItemOptions) do
  begin
    with ItemOptions[i] do
    begin
      LoadFont(FontItemIndex, textFont);
    end;
  end;

  // blocking automatically
  DoChange(HGOPT_FONTSERVICE);
end;

function LoadColour(Order: integer): TColor;
var
  cid: TColourIDW;
begin
  StrCopyW(cid.group, hppName);
  StrCopyW(cid.name, hppFontItems[Order].name);
  result := CallService(MS_COLOUR_GETW, WPARAM(@cid), 0);
end;

function LoadColourDB(Order: integer): TColor;
var
  buf:array [0..31] of AnsiChar;
begin
  IntToStr(StrCopyE(buf,'Color'),Order);
  Result := DBReadDword(0,hppDBName,@buf, Color2RGB(hppFontItems[Order].back));
end;

procedure TGridOptions.ColourReload();
var
  i: integer;
begin
  // load colors
  ColorDivider      := LoadColourDB(0);
  ColorSelectedText := LoadColourDB(1);
  ColorSelected     := LoadColourDB(2);
  ColorSessHeader   := LoadColourDB(17);
  ColorBackground   := LoadColourDB(22);
  ColorLink         := LoadColourDB(29);

  // load mestype-related
  for i := 0 to High(ItemOptions) do
  begin
    with ItemOptions[i] do
    begin
      textColor := LoadColour{DB}(FontItemIndex);
    end;
  end;

  // blocking automatically
  DoChange(HGOPT_FONTSERVICE);
end;

procedure TGridOptions.LoadOptions;
begin
  StartChange;
  try
    FontReload();

    ColourReload();

    // load others
    ShowIcons := DBReadByte(0,hppDBName, 'ShowIcons', 1)<>0;
    RTLEnabled := GetContactRTLMode(0, '');
    // we have no per-proto rtl setup ui, use global instead
    // GridOptions.ShowAvatars := GetDBBool(hppDBName,'ShowAvatars',False);

    RawRTFEnabled  := DBReadByte(0,hppDBName, 'RawRTF' , 1)<>0;
    BBCodesEnabled := DBReadByte(0,hppDBName, 'BBCodes', 1)<>0;

    SmileysEnabled        := DBReadByte(0,hppDBName, 'Smileys'       , byte(SmileyAddExists))<>0;
    MathModuleEnabled     := DBReadByte(0,hppDBName, 'MathModule'    , byte(MathModuleExists))<>0;
    AvatarsHistoryEnabled := DBReadByte(0,hppDBName, 'AvatarsHistory', 1)<>0;

    OpenDetailsMode := DBReadByte(0,hppDBName, 'OpenDetailsMode', 0)<>0;
    TextFormatting  := DBReadByte(0,hppDBName, 'InlineTextFormatting', 1)<>0;

    ProfileName := GetDBWideStr('ProfileName', '');

    ClipCopyFormat        := GetDBWideStr('FormatCopy'           , DEFFORMAT_CLIPCOPY);
    ClipCopyTextFormat    := GetDBWideStr('FormatCopyText'       , DEFFORMAT_CLIPCOPYTEXT);
    ReplyQuotedFormat     := GetDBWideStr('FormatReplyQuoted'    , DEFFORMAT_REPLYQUOTED);
    ReplyQuotedTextFormat := GetDBWideStr('FormatReplyQuotedText', DEFFORMAT_REPLYQUOTEDTEXT);
    SelectionFormat       := GetDBWideStr('FormatSelection'      , DEFFORMAT_SELECTION);
    DateTimeFormat        := GetDBWideStr('DateTimeFormat'       , DEFFORMAT_DATETIME);

  finally
    EndChange(HGOPT_OPTIONS or HGOPT_TEMPLATES);
  end;
end;

procedure TGridOptions.SaveOptions;
begin
  StartChange;
  try
    DBWriteByte(0, hppDBName, 'ShowIcons', byte(ShowIcons));
    DBWriteByte(0, hppDBName, 'RTL'      , byte(RTLEnabled));
    // DBWriteByte(0, hppDBName, 'ShowAvatars', byte(ShowAvatars));

    DBWriteByte(0, hppDBName, 'RawRTF' , byte(RawRTFEnabled));
    DBWriteByte(0, hppDBName, 'BBCodes', byte(BBCodesEnabled));

    DBWriteByte(0, hppDBName, 'Smileys'       , byte(SmileysEnabled));
    DBWriteByte(0, hppDBName, 'MathModule'    , byte(MathModuleEnabled));
    DBWriteByte(0, hppDBName, 'AvatarsHistory', byte(AvatarsHistoryEnabled));

    DBWriteByte(0, hppDBName, 'OpenDetailsMode', byte(OpenDetailsMode));
  finally
    EndChange(HGOPT_OPTIONS);
  end;
end;

procedure TGridOptions.SaveTemplates;
begin
  StartChange;
  try
    DBWriteUnicode(0, hppDBName, 'FormatCopy'           , pWideChar(ClipCopyFormat));
    DBWriteUnicode(0, hppDBName, 'FormatCopyText'       , pWideChar(ClipCopyTextFormat));
    DBWriteUnicode(0, hppDBName, 'FormatReplyQuoted'    , pWideChar(ReplyQuotedFormat));
    DBWriteUnicode(0, hppDBName, 'FormatReplyQuotedText', pWideChar(ReplyQuotedTextFormat));
    DBWriteUnicode(0, hppDBName, 'FormatSelection'      , pWideChar(SelectionFormat));
    DBWriteUnicode(0, hppDBName, 'DateTimeFormat'       , pWideChar(DateTimeFormat));
  finally
    EndChange(HGOPT_TEMPLATES);
  end;
end;

procedure TGridOptions.DoChange(mask: dword=HGOPT_ALL);
begin
  Inc(Changed);
  if FLocks > 0 then
    exit;

  NotifyEventHooks(hOptionsChanged,mask,0);

  Changed := 0;
end;

function TGridOptions.GetLocked: Boolean;
begin
  Result := (FLocks > 0);
end;

procedure TGridOptions.StartChange;
begin
  Inc(FLocks);
end;

procedure TGridOptions.EndChange(mask:dword=HGOPT_ALL;const Forced: Boolean = False);
begin
  if FLocks = 0 then
    exit;
  Dec(FLocks);
  if Forced then
    Inc(Changed);
  if (FLocks = 0) and (Changed > 0) then
    DoChange(mask);
end;

function TGridOptions.GetItemOptions(Mes: TMessageTypes; out textFont: PFont; out textColor: TColor): Integer;
var
  i: Integer;
begin
  i := 0;
  Result := 0;
  while i <= High(FItemOptions) do
  begin
    if (MessageTypesToDWord(FItemOptions[i].MessageType) and MessageTypesToDWord(Mes)) >=
        MessageTypesToDWord(Mes) then
    begin
      textFont  := FItemOptions[i].textFont;
      textColor := FItemOptions[i].textColor;
      Result := i;
      break;
    end
    else
    begin
      if mtOther in FItemOptions[i].MessageType then
      begin
        textFont  := FItemOptions[i].textFont;
        textColor := FItemOptions[i].textColor;
        Result := i;
      end;
      Inc(i);
    end;
  end;
end;

procedure TGridOptions.SetTextFormatting(const Value: Boolean);
begin
  if FTextFormatting = Value then
    exit;
  FTextFormatting := Value;
  if FLocks > 0 then
    exit;
  try
    NotifyEventHooks(hOptionsChanged,HGOPT_OPTIONS,0);
  finally
    DBWriteByte(0,hppDBName,'InlineTextFormatting',Byte(Value));
  end;
end;

procedure TGridOptions.SetShowIcons(const Value: Boolean);
begin
  if FShowIcons = Value then
    exit;
  FShowIcons := Value;
  Self.StartChange;
  try
    if Value then
      LoadIcons;
    DoChange(HGOPT_OPTIONS);
  finally
    Self.EndChange;
  end;
end;

procedure TGridOptions.SetProfileName(const Value: WideString);
begin
  if Value = FProfileName then
    exit;
  FProfileName := Value;
  FForceProfileName := (Value <> '');
  DoChange(HGOPT_TEMPLATES);
end;

initialization

finalization
  if GridOptions <> nil then
    GridOptions.Free;
end.
