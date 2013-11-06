{
}
unit my_GridOptions;

interface

uses
  Windows,
  CustomGraph,
  hpp_global;

// hppFontItems indexes for special Font/Color arrays
const
  fiGrid     = 0;
  fiSelected = 1;
  fiSession  = 2;
  fiContact  = 3;
  fiProfile  = 4;
  fiInTime   = 5;
  fiOutTime  = 6;
  fiDivider  = 7;
  fiLink     = 8;

type
  TItemOption = record
    MessageType  : THppMessageType;
    Handle       : HFONT;
    textFont     : LOGFONTW;
    textColor    : TCOLORREF;
    textBkColor  : TCOLORREF;
  end;

  TItemOptions = array of TItemOption;

  TGridOptions = class
  private
    hFontChanged,
    hColourChanged,
    hOptionsChanged:THANDLE;

    FLocks: Integer;
    Changed: Integer;

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

    FTemplates:array [0..5] of pWideChar;

    FForceProfileName: Boolean;
    FProfileName: pWideChar;

    procedure SetShowIcons(const Value: Boolean);
    procedure SetTextFormatting(const Value: Boolean);

    procedure SetProfileName(const Value: pWideChar);

    function GetLocked: Boolean;
    procedure DoChange(mask: dword=HGOPT_ALL);

    function LoadFont(idx:integer):boolean;
    function GetFont(idx:integer):HFONT;
    function GetColor(idx:integer):TCOLORREF;
    function GetTextColor(idx:integer):TCOLORREF;
    function GetTemplate(idx:integer):pWideChar;
    procedure SetTemplate(idx:integer;value:pWideChar);
  public
    constructor Create;
    destructor Destroy; override;

    function FontReload():boolean;
    procedure ColourReload();

    procedure LoadOptions;
    procedure SaveOptions;
    procedure SaveTemplates;

    function GetItemIndex(Mes: THppMessageType): Integer;

    procedure StartChange;
    procedure EndChange(mask: dword=HGOPT_ALL; const Forced: Boolean = False);
    property Locked: Boolean read GetLocked;

    property ClipCopyFormat       : pWideChar index 0 read GetTemplate write SetTemplate;
    property ClipCopyTextFormat   : pWideChar index 1 read GetTemplate write SetTemplate;
    property ReplyQuotedFormat    : pWideChar index 2 read GetTemplate write SetTemplate;
    property ReplyQuotedTextFormat: pWideChar index 3 read GetTemplate write SetTemplate;
    property SelectionFormat      : pWideChar index 4 read GetTemplate write SetTemplate;
    property DateTimeFormat       : pWideChar index 5 read GetTemplate write SetTemplate;

    // to private? public just for export
    property ItemOptions: TItemOptions read FItemOptions write FItemOptions;
    property Font     [i:integer]:HFONT     read GetFont;
    property ColorBack[i:integer]:TCOLORREF read GetColor;
    property ColorText[i:integer]:TCOLORREF read GetTextColor;

    property RTLEnabled: Boolean read FRTLEnabled write FRTLEnabled;
    property ShowIcons : Boolean read FShowIcons  write SetShowIcons;

    property BBCodesEnabled       : Boolean read FBBCodesEnabled        write FBBCodesEnabled;
    property SmileysEnabled       : Boolean read FSmileysEnabled        write FSmileysEnabled;
    property MathModuleEnabled    : Boolean read FMathModuleEnabled     write FMathModuleEnabled;
    property RawRTFEnabled        : Boolean read FRawRTFEnabled         write FRawRTFEnabled;
    property AvatarsHistoryEnabled: Boolean read FAvatarsHistoryEnabled write FAvatarsHistoryEnabled;

    property TextFormatting: Boolean read FTextFormatting write SetTextFormatting;
    property OpenDetailsMode: Boolean read FOpenDetailsMode write FOpenDetailsMode;
    property ForceProfileName: Boolean read FForceProfileName;
    property ProfileName: pWideChar read FProfileName write SetProfileName;
  end;

var
  GridOptions:TGridOptions = nil;

implementation

uses
  m_api,
  Common, dbsettings,
  hpp_contacts,
  hpp_icons;

const
  DEFFORMAT_CLIPCOPY        = '%nick%, %smart_datetime%:\n%mes%\n';
  DEFFORMAT_CLIPCOPYTEXT    = '%mes%\n';
  DEFFORMAT_REPLYQUOTED     = '%nick%, %smart_datetime%:\n%quot_mes%\n';
  DEFFORMAT_REPLYQUOTEDTEXT = '%quot_selmes%\n';
  DEFFORMAT_SELECTION       = '%selmes%\n';
  DEFFORMAT_DATETIME        = 'dd.MM.yy HH:mm:ss'; // ShortDateFormat + LongTimeFormat

type
  ThppFontType = set of (hppFont, hppColor);

  ThppFontsRec = record
    _type    : ThppFontType;
    name     : PWideChar;
    nameColor: PWideChar;
    Mes      : THppMessageType;
    style    : byte;
    size     : ShortInt;
    color    : TCOLORREF;
    back     : TCOLORREF;
  end;

const
  hppFontItems: array[0..30] of ThppFontsRec = (
    (_type: [hppFont,hppColor]; name: 'Grid messages'; nameColor: nil{'Grid background'}; // message
       Mes:(event:0; direction:0; code:mtUnknown);
       style:0; size: -11; color: $000000; back: $E9EAEB),

    (_type: [hppFont,hppColor]; name: 'Selected text'; nameColor: nil{'Selected background'};
       Mes:(event:0; direction:0; code:mtUnknown);
       style:0; size: -11; color: clHighlightText; back: clHighlight),

    (_type: [hppFont,hppColor]; name: 'Conversation header'; nameColor: nil; // session
       Mes:(event:0; direction:0; code:mtUnknown);
       style:0; size: -11; color: $000000; back: $00D7FDFF),

    (_type: [hppFont]; name: 'Incoming nick'; nameColor: nil;
       Mes:(event:0; direction:0; code:mtUnknown);
       style:DBFONTF_BOLD; size: -11; color: $6B3FC8; back: $000000),

    (_type: [hppFont]; name: 'Outgoing nick'; nameColor: nil;
       Mes:(event:0; direction:0; code:mtUnknown);
       style:DBFONTF_BOLD; size: -11; color: $BD6008; back: $000000),

    (_type: [hppFont]; name: 'Incoming timestamp'; nameColor: nil;
       Mes:(event:0; direction:0; code:mtUnknown);
       style:0; size: -11; color: $000000; back: $000000),

    (_type: [hppFont]; name: 'Outgoing timestamp'; nameColor: nil;
       Mes:(event:0; direction:0; code:mtUnknown);
       style:0; size: -11; color: $000000; back: $000000),

    (_type: [hppColor]; name: nil; nameColor: 'Divider';
       Mes:(event:0; direction:0; code:mtUnknown);
       style:0; size: -11; color: $000000; back: clGray),

    (_type: [hppColor]; name: nil; nameColor: 'Link';
       Mes:(event:0; direction:0; code:mtUnknown);
       style:0; size: -11; color: $000000; back: clBlue),


    (_type: [hppFont,hppColor]; name: 'Incoming message'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming; code:mtMessage);
       style:0; size: -11; color: $000000; back: $DBDBDB),

    (_type: [hppFont,hppColor]; name: 'Outgoing message'; nameColor: nil;
       Mes:(event:0; direction:mtOutgoing; code:mtMessage);
       style:0; size: -11; color: $000000; back: $EEEEEE),

    (_type: [hppFont,hppColor]; name: 'Incoming file'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming; code:mtFile);
       style:0; size: -11; color: $000000; back: $9BEEE3),

    (_type: [hppFont,hppColor]; name: 'Outgoing file'; nameColor: nil;
       Mes:(event:0; direction:mtOutgoing; code:mtFile);
       style:0; size: -11; color: $000000; back: $9BEEE3),

    (_type: [hppFont,hppColor]; name: 'Incoming url'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming; code:mtUrl);
       style:0; size: -11; color: $000000; back: $F4D9CC),
    
    (_type: [hppFont,hppColor]; name: 'Outgoing url'; nameColor: nil;
       Mes:(event:0; direction:mtOutgoing; code:mtUrl);
       style:0; size: -11; color: $000000; back: $F4D9CC),

    (_type: [hppFont,hppColor]; name: 'Incoming SMS Message'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming; code:mtSMS);
       style:0; size: -11; color: $000000; back: $CFF4FE),

    (_type: [hppFont,hppColor]; name: 'Outgoing SMS Message'; nameColor: nil;
       Mes:(event:0; direction:mtOutgoing; code:mtSMS);
       style:0; size: -11; color: $000000; back: $CFF4FE),

    (_type: [hppFont,hppColor]; name: 'Incoming contacts'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming; code:mtContacts);
       style:0; size: -11; color: $000000; back: $FEF4CF),

    (_type: [hppFont,hppColor]; name: 'Outgoing contacts'; nameColor: nil;
       Mes:(event:0; direction:mtOutgoing; code:mtContacts);
       style:0; size: -11; color: $000000; back: $FEF4CF),

    (_type: [hppFont,hppColor]; name: 'System message'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtSystem);
       style:0; size: -11; color: $000000; back: $CFFEDC),

    (_type: [hppFont,hppColor]; name: 'Status changes'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtStatus);
       style:0; size: -11; color: $000000; back: $F0F0F0),

    (_type: [hppFont,hppColor]; name: 'SMTP Simple Email'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtSMTPSimple);
       style:0; size: -11; color: $000000; back: $FFFFFF),

    (_type: [hppFont,hppColor]; name: 'Other events (unknown)'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtOther);
       style:0; size: -11; color: $000000; back: $FFFFFF),

    (_type: [hppFont,hppColor]; name: 'Nick changes'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtNickChange);
       style:0; size: -11; color: $000000; back: $00D7FDFF),

    (_type: [hppFont,hppColor]; name: 'Avatar changes'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtAvatarChange);
       style:0; size: -11; color: $000000; back: $00D7FDFF),

    (_type: [hppFont,hppColor]; name: 'Incoming WATrack notify'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming; code:mtWATrack);
       style:0; size: -11; color: $C08000; back: $C8FFFF),

    (_type: [hppFont,hppColor]; name: 'Outgoing WATrack notify'; nameColor: nil;
       Mes:(event:0; direction:mtOutgoing; code:mtWATrack);
       style:0; size: -11; color: $C08000; back: $C8FFFF),

    (_type: [hppFont,hppColor]; name: 'Status message changes'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtStatusMessage);
       style:0; size: -11; color: $000000; back: $F0F0F0),

    (_type: [hppFont,hppColor]; name: 'Voice calls'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtVoiceCall);
       style:0; size: -11; color: $000000; back: $E9DFAB),

    (_type: [hppFont,hppColor]; name: 'Webpager message'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtWebPager);
       style:0; size: -11; color: $000000; back: $FFFFFF),

    (_type: [hppFont,hppColor]; name: 'EMail Express message'; nameColor: nil;
       Mes:(event:0; direction:mtIncoming+mtOutgoing; code:mtEmailExpress);
       style:0; size: -11; color: $000000; back: $FFFFFF)
  );

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

procedure RegisterFont(Order:integer);
var
  fid: TFontIDW;
begin
  fid.cbSize := sizeof(fid);
  StrCopyW(fid.group, hppName);
  StrCopy (fid.dbSettingsGroup, hppDBName);
  fid.flags := FIDF_DEFAULTVALID+FIDF_ALLOWEFFECTS;
  fid.order := Order;
  StrCopyW(fid.name,hppFontItems[Order].Name);
  IntToStr(StrCopyE(fid.prefix,'Font'),Order);
  StrCopyW(fid.deffontsettings.szFace, 'Tahoma');
  fid.deffontsettings.charset:= DEFAULT_CHARSET;
  fid.deffontsettings.size   := hppFontItems[Order].size;
  fid.deffontsettings.style  := hppFontItems[Order].style;
  fid.deffontsettings.colour := ColorToRGB(hppFontItems[Order].color);
  FontRegisterW(@fid);
end;

procedure RegisterColor(Order:integer);
var
  cid: TColourIDW;
begin
  cid.cbSize := sizeof(cid);
  StrCopyW(cid.group, hppName);
  StrCopy (cid.dbSettingsGroup, hppDBName);
  cid.order := Order;
  if hppFontItems[Order].NameColor=nil then
    StrCopyW(cid.name,hppFontItems[Order].Name)
  else
    StrCopyW(cid.name,hppFontItems[Order].NameColor);
  IntToStr(StrCopyE(cid.setting,'Color'),Order);
  cid.defcolour := ColorToRGB(hppFontItems[Order].back);
  ColourRegisterW(@cid);
end;


{ TGridOptions }
function TGridOptions.GetTemplate(idx:integer):pWideChar;
begin
  result:=FTemplates[idx];
end;

procedure TGridOptions.SetTemplate(idx:integer;value:pWideChar);
begin
  if value<>FTemplates[idx] then
  begin
    mFreeMem(FTemplates[idx]);
    //!! strdup
    FTemplates[idx]:=value;
  end;
end;

function TGridOptions.GetItemIndex(Mes: THppMessageType): Integer;
var
  i: Integer;
begin
  i := 0;
  Result := 0;
  while i <= High(FItemOptions) do
  begin
    if (FItemOptions[i].MessageType.code = Mes.code) and
      ((FItemOptions[i].MessageType.direction and Mes.direction)<>0) then
    begin
      Result := i;
      break;
    end
    else
    begin
      if FItemOptions[i].MessageType.code = mtOther then
      begin
        Result := i;
      end;
      Inc(i);
    end;
  end;
end;

function TGridOptions.LoadFont(idx:integer):boolean;
var
  fid: TFontIDW;
  lf : LOGFONTW;
  col: TCOLORREF;
begin
  FillChar(lf,SizeOf(lf),0);

//  fid.cbSize := sizeof(fid);
  StrCopyW(fid.group, hppName);
  StrCopyW(fid.name , hppFontItems[idx].name);
  col := CallService(MS_FONT_GETW, WPARAM(@fid), LPARAM(@lf));

  with FItemOptions[idx] do
    if (col<>textColor) or not CompareMem(@lf,@textFont,SizeOf(lf)) then
    begin
      // font was not used before
      if (col=textColor) and (Handle=0) then
        result:=false
      else
        result:=true;
      textColor:=col;
      move(lf,textFont,SizeOf(lf));
      if Handle<>0 then
      begin
        DeleteObject(Handle);
        Handle:=0; // new will be created on demand
      end;
    end
    else
      result:=false;
end;

function TGridOptions.FontReload():boolean;
var
  i: integer;
begin
  result:=false;

  for i := 0 to High(ItemOptions) do
  begin
    //## read font settings just for fonts
    if hppFont in hppFontItems[i]._type then
      if LoadFont(i) then
        result:=True;
//      result:=LoadFont(i) or result;
  end;

  if result then
    DoChange(HGOPT_FONTSERVICE);
end;

procedure TGridOptions.ColourReload();
var
  cid: TColourIDW;
  lcolor:TCOLORREF;
  i: integer;
  changed:boolean;
begin
  StrCopyW(cid.group, hppName);
  changed:=false;
  for i := 0 to High(ItemOptions) do
  begin
    //## just if color here
    if hppColor in hppFontItems[i]._type then
    begin
      StrCopyW(cid.name, hppFontItems[i].name);
      with ItemOptions[i] do
      begin
        lcolor := CallService(MS_COLOUR_GETW, WPARAM(@cid), 0);
        if lcolor <> textBkColor then
        begin
          textBkColor:=lcolor;
          changed:=true;
        end;
      end;
    end;
  end;

  if changed then
    DoChange(HGOPT_FONTSERVICE);
end;

function TGridOptions.GetFont(idx:integer):HFONT;
begin
  with FItemOptions[idx] do
  begin
    if Handle=0 then
    begin
      Handle:=CreateFontIndirectW({$IFDEF FPC}@{$ENDIF}textFont);
    end;
    result:=Handle;
  end;
end;

function TGridOptions.GetColor(idx:integer):TCOLORREF;
begin
  with FItemOptions[idx] do
  begin
    result:=textBkColor;
  end;
end;

function TGridOptions.GetTextColor(idx:integer):TCOLORREF;
begin
  with FItemOptions[idx] do
  begin
    if textFont.lfFaceName[0]=#0 then
      result:=textBkColor
    else
      result:=textColor;
  end;
end;

constructor TGridOptions.Create;
var
  i: integer;
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

  FProfileName := nil;
  FForceProfileName := False;

  FillChar(FTemplates,SizeOf(FTemplates),0);

  FTextFormatting := True;

  FLocks  := 0;
  Changed := 0;

  SetLength(FItemOptions,Length(hppFontItems));

  for i := 0 to High(hppFontItems) do
  begin
    FillChar(FItemOptions[i], SizeOf(TItemOption),0);
    with FItemOptions[i] do
    begin
      MessageType := hppFontItems[i].Mes;
    end;

    if hppFont in hppFontItems[i]._type then
      RegisterFont(i);
    if hppColor in hppFontItems[i]._type then
      RegisterColor(i);
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

  for i := 0 to HIGH(FItemOptions) do
  begin
    if FItemOptions[i].Handle<>0 then
      DeleteObject(FItemOptions[i].Handle);
  end;
  Finalize(FItemOptions);

  ClipCopyFormat       :=nil;
  ClipCopyTextFormat   :=nil;
  ReplyQuotedFormat    :=nil;
  ReplyquotedTextFormat:=nil;
  SelectionFormat      :=nil;
  DateTimeFormat       :=nil;

  mFreeMem(FProfileName);
  inherited;
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

    FProfileName := DBReadUnicode(0,hppDBName,'ProfileName', nil);

    ClipCopyFormat        := DBReadUnicode(0,hppDBName,'FormatCopy'           , DEFFORMAT_CLIPCOPY);
    ClipCopyTextFormat    := DBReadUnicode(0,hppDBName,'FormatCopyText'       , DEFFORMAT_CLIPCOPYTEXT);
    ReplyQuotedFormat     := DBReadUnicode(0,hppDBName,'FormatReplyQuoted'    , DEFFORMAT_REPLYQUOTED);
    ReplyQuotedTextFormat := DBReadUnicode(0,hppDBName,'FormatReplyQuotedText', DEFFORMAT_REPLYQUOTEDTEXT);
    SelectionFormat       := DBReadUnicode(0,hppDBName,'FormatSelection'      , DEFFORMAT_SELECTION);
    DateTimeFormat        := DBReadUnicode(0,hppDBName,'DateTimeFormat'       , DEFFORMAT_DATETIME);

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
    DBWriteUnicode(0, hppDBName, 'FormatCopy'           , ClipCopyFormat);
    DBWriteUnicode(0, hppDBName, 'FormatCopyText'       , ClipCopyTextFormat);
    DBWriteUnicode(0, hppDBName, 'FormatReplyQuoted'    , ReplyQuotedFormat);
    DBWriteUnicode(0, hppDBName, 'FormatReplyQuotedText', ReplyQuotedTextFormat);
    DBWriteUnicode(0, hppDBName, 'FormatSelection'      , SelectionFormat);
    DBWriteUnicode(0, hppDBName, 'DateTimeFormat'       , DateTimeFormat);
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
  StartChange;
  try
    if Value then
      LoadSkinIcons;
    DoChange(HGOPT_OPTIONS);
  finally
    EndChange;
  end;
end;

procedure TGridOptions.SetProfileName(const Value: pWideChar);
begin
  if StrCmpW(Value,FProfileName)=0 then
    exit;
  mFreeMem(FProfileName);
  StrDupW(FProfileName,Value); //!!!!
  FForceProfileName := (Value <> nil);
  DoChange(HGOPT_TEMPLATES);
end;

initialization

finalization
  if GridOptions <> nil then
    GridOptions.Free;
end.
