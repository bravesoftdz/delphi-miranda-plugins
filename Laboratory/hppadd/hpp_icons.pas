{
  LoadIcons = skinned (miranda) icons
  LoadIcons2 = iconpack icons

  used by initial load and icon changes event
}
unit hpp_icons;

interface

uses
  windows;

//----- Icons (iconpack) related constants -----
const
  hppIPName = 'historypp_icons.dll';
type
  tHPPIconName = (
    HPP_ICON_CONTACTHISTORY,    {0}
    HPP_ICON_GLOBALSEARCH,      {1}
    HPP_ICON_SESS_DIVIDER,      {2}
    HPP_ICON_SESSION,           {3}
    HPP_ICON_SESS_SUMMER,       {4}
    HPP_ICON_SESS_AUTUMN,       {5}
    HPP_ICON_SESS_WINTER,       {6}
    HPP_ICON_SESS_SPRING,       {7}
    HPP_ICON_SESS_YEAR,         {8}
    HPP_ICON_HOTFILTER,         {9}
    HPP_ICON_HOTFILTERWAIT,     {10}
    HPP_ICON_SEARCH_ALLRESULTS, {11}
    HPP_ICON_TOOL_SAVEALL,      {12}
    HPP_ICON_HOTSEARCH,         {13}
    HPP_ICON_SEARCHUP,          {14}
    HPP_ICON_SEARCHDOWN,        {15}
    HPP_ICON_TOOL_DELETEALL,    {16}
    HPP_ICON_TOOL_DELETE,       {17}
    HPP_ICON_TOOL_SESSIONS,     {18}
    HPP_ICON_TOOL_SAVE,         {19}
    HPP_ICON_TOOL_COPY,         {20}
    HPP_ICON_SEARCH_ENDOFPAGE,  {21}
    HPP_ICON_SEARCH_NOTFOUND,   {22}
    HPP_ICON_HOTFILTERCLEAR,    {23}
    HPP_ICON_SESS_HIDE,         {24}
    HPP_ICON_DROPDOWNARROW,     {25}
    HPP_ICON_CONTACDETAILS,     {26}
    HPP_ICON_CONTACTMENU,       {27}
    HPP_ICON_BOOKMARK,          {28}
    HPP_ICON_BOOKMARK_ON,       {29}
    HPP_ICON_BOOKMARK_OFF,      {30}
    HPP_ICON_SEARCHADVANCED,    {31}
    HPP_ICON_SEARCHRANGE,       {32}
    HPP_ICON_SEARCHPROTECTED,   {33}

    HPP_ICON_EVENT_INCOMING,    {34}
    HPP_ICON_EVENT_OUTGOING,    {35}
    HPP_ICON_EVENT_SYSTEM,      {36}
    HPP_ICON_EVENT_CONTACTS,    {37}
    HPP_ICON_EVENT_SMS,         {38}
    HPP_ICON_EVENT_WEBPAGER,    {39}
    HPP_ICON_EVENT_EEXPRESS,    {40}
    HPP_ICON_EVENT_STATUS,      {41}
    HPP_ICON_EVENT_SMTPSIMPLE,  {42}
    HPP_ICON_EVENT_NICK,        {43}
    HPP_ICON_EVENT_AVATAR,      {44}
    HPP_ICON_EVENT_WATRACK,     {45}
    HPP_ICON_EVENT_STATUSMES,   {46}
    HPP_ICON_EVENT_VOICECALL    {47}
  );

const
  HPP_SKIN_EVENT_MESSAGE     = 1000+0;
  HPP_SKIN_EVENT_URL         = 1000+1;
  HPP_SKIN_EVENT_FILE        = 1000+2;
  HPP_SKIN_OTHER_MIRANDA     = 1000+3;

  SkinIconsCount             = 4;

type
  ThppIntIconsRec = record
    Handle: hIcon;
    id    : THANDLE;
  end;

var
  hppIcons : array [tHppIconName] of ThppIntIconsRec;
  skinIcons: array [0..SkinIconsCount-1] of ThppIntIconsRec;

procedure RegisterIcons;
function LoadSkinIcons:boolean;

implementation

uses
  ShellAPI,
  common,io,
  dbsettings,m_api,
  hpp_events,
  hpp_global;

const
  IconGroups: array [0..4] of pAnsiChar = (
    hppName, // Root
    'Conversations',
    'Toolbar',
    'Search panel',
    'Events'
  );
type
  ThppIconsRec = record
    desc : PAnsiChar;
    group: cardinal;
  end;
const
  hppIconsDefs : array [tHppIconName] of ThppIconsRec = (
    // HPP interface icons
    (desc:'Contact history';           group:0), {HPP_ICON_CONTACTHISTORY}
    (desc:'History search';            group:0), {HPP_ICON_GLOBALSEARCH}
    (desc:'Conversation divider';      group:1), {HPP_ICON_SESS_DIVIDER}
    (desc:'Conversation icon';         group:1), {HPP_ICON_SESSION}
    (desc:'Conversation summer';       group:1), {HPP_ICON_SESS_SUMMER}
    (desc:'Conversation autumn';       group:1), {HPP_ICON_SESS_AUTUMN}
    (desc:'Conversation winter';       group:1), {HPP_ICON_SESS_WINTER}
    (desc:'Conversation spring';       group:1), {HPP_ICON_SESS_SPRING}
    (desc:'Conversation year';         group:1), {HPP_ICON_SESS_YEAR}
    (desc:'Filter';                    group:2), {HPP_ICON_HOTFILTER}
    (desc:'In-place filter wait';      group:3), {HPP_ICON_HOTFILTERWAIT}
    (desc:'Search All Results';        group:0), {HPP_ICON_SEARCH_ALLRESULTS}
    (desc:'Save All';                  group:2), {HPP_ICON_TOOL_SAVEALL}
    (desc:'Search';                    group:2), {HPP_ICON_HOTSEARCH}
    (desc:'Search Up';                 group:3), {HPP_ICON_SEARCHUP}
    (desc:'Search Down';               group:3), {HPP_ICON_SEARCHDOWN}
    (desc:'Delete All';                group:2), {HPP_ICON_TOOL_DELETEALL}
    (desc:'Delete';                    group:2), {HPP_ICON_TOOL_DELETE}
    (desc:'Conversations';             group:2), {HPP_ICON_TOOL_SESSIONS}
    (desc:'Save';                      group:2), {HPP_ICON_TOOL_SAVE}
    (desc:'Copy';                      group:2), {HPP_ICON_TOOL_COPY}
    (desc:'End of page';               group:3), {HPP_ICON_SEARCH_ENDOFPAGE}
    (desc:'Phrase not found';          group:3), {HPP_ICON_SEARCH_NOTFOUND}
    (desc:'Clear in-place filter';     group:3), {HPP_ICON_HOTFILTERCLEAR}
    (desc:'Conversation hide';         group:1), {HPP_ICON_SESS_HIDE}
    (desc:'Drop down arrow';           group:2), {HPP_ICON_DROPDOWNARROW}
    (desc:'User Details';              group:2), {HPP_ICON_CONTACDETAILS}
    (desc:'User Menu';                 group:2), {HPP_ICON_CONTACTMENU}
    (desc:'Bookmarks';                 group:2), {HPP_ICON_BOOKMARK}
    (desc:'Bookmark enabled';          group:0), {HPP_ICON_BOOKMARK_ON}
    (desc:'Bookmark disabled';         group:0), {HPP_ICON_BOOKMARK_OFF}
    (desc:'Advanced Search Options';   group:2), {HPP_ICON_SEARCHADVANCED}
    (desc:'Limit Search Range';        group:2), {HPP_ICON_SEARCHRANGE}
    (desc:'Search Protected Contacts'; group:2), {HPP_ICON_SEARCHPROTECTED}
    // Message types (events) icons
    (desc:'Incoming events'; group:4 {idx:HPP_ICON_EVENT_INCOMING}),
    (desc:'Outgoing events'; group:4 {idx:HPP_ICON_EVENT_OUTGOING}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_SYSTEM}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_CONTACTS}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_SMS}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_WEBPAGER}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_EEXPRESS}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_STATUS}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_SMTPSIMPLE}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_NICK}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_AVATAR}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_WATRACK}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_STATUSMES}),
    (desc:nil; group:4 {idx:HPP_ICON_EVENT_VOICECALL})
  );

function LoadSkinIcons:boolean;
var
  i: Integer;
  ic: hIcon;
begin
  result := false;
  for i := 0 to High(skinIcons) do
  begin
    ic := LoadSkinnedIcon(skinIcons[i].id);
    if skinIcons[i].handle <> ic then
    begin
      skinIcons[i].handle := ic;
      result := true;
    end;
  end;
end;

function LoadHppIcons:boolean;
var
  i: tHppIconName;
  ic: hIcon;
begin
  result := false;
  for i := Low(tHppIconName) to High(tHppIconName) do
  begin
    ic := CallService(MS_SKIN2_GETICONBYHANDLE, 0, LPARAM(hppIcons[i].id));
    if hppIcons[i].handle <> ic then
    begin
      hppIcons[i].handle := ic;
      result := true;
    end;
  end;
end;

function ExpandFileName(FileName: pWideChar): pWideChar;
var
  FName: PWideChar;
  Buffer: array[0..MAX_PATH - 1] of WideChar;
  Len: Integer;
begin
  Len := GetFullPathNameW(FileName, Length(Buffer), @Buffer, FName);
  if Len < Length(Buffer) then
    StrDupW(Result, Buffer)
  else if Len > 0 then
  begin
    mGetMem(Result, Len+1);
    GetFullPathNameW(FileName, Len, Result, FName);
  end;
end;

function FindIconsDll(ForceCheck: boolean): pWideChar;
var
  hppMessage: pWideChar;
  CountIconsDll: Integer;
  DoCheck: boolean;
  hppIconsDir,hppPluginsDir:pWideChar;
  hppDll,tmppath: array [0..MAX_PATH-1] of WideChar;
begin
  DoCheck := ForceCheck or (DBReadByte(0,hppDBName, 'CheckIconPack', 1)<>0);

  GetModuleFileNameW(hInstance, @hppDll, MAX_PATH);
  hppPluginsDir := ExtractW(hppDll,false);

  StrCopyW(StrCopyEW(tmppath,hppPluginsDir),'..\Icons\');
  hppIconsDir := ExpandFileName(tmppath);
  
  StrCopyW(StrCopyEW(tmppath,hppIconsDir),hppIPName);
  if FileExists(tmppath) then
    StrDupW(Result,tmppath)
  else
  begin
    StrCopyW(StrCopyEW(tmppath,hppPluginsDir),hppIPName);
    if FileExists(tmppath) then
      StrDupW(Result,tmppath)
    else
    begin
      StrDupW(Result,hppDll);

      if DoCheck then
      begin
        DoCheck := false;
        hppMessage :=
          FormatStrW
          (TranslateW
          ('Cannot load icon pack (%s) from:'#13#10'%s'#13#10'%s'#13#10'This can cause no icons will be shown.'),
          [hppIPName, hppIconsDir,hppPluginsDir]);
        MessageBoxW(0{hppMainWindow}, hppMessage, hppName + ' Error', MB_ICONERROR or MB_OK);
        mFreeMem(hppMessage);
      end;
    end;
  end;
  mFreeMem(hppIconsDir);
  mFreeMem(hppPluginsDir);

  if DoCheck then
  begin
    CountIconsDll := ExtractIconExW(Result, -1, hIcon(nil^), hIcon(nil^), 0);
    if CountIconsDll < ord(High(tHPPIconName)) then
    begin
      hppMessage :=
        FormatStrW
        (TranslateW
        ('You are using old icon pack from:'#13#10'%s'#13#10'This can cause missing icons, so update the icon pack.'),
        [Result]);
      MessageBoxW(0{hppMainWindow}, hppMessage, hppName + ' Warning', MB_ICONWARNING or MB_OK);
      mFreeMem(hppMessage);
    end;
  end;
end;

procedure RegisterIcons;
var
  sid: TSKINICONDESC;
  i: tHppIconName;
  j{,mt}: TBuiltinMessageType;
  hppIconPack: pWideChar;
  groupbuf:array [0..127] of AnsiChar;
  namebuf:array [0..7] of AnsiChar;
  p:pAnsiChar;
  pp:pAnsiChar;
begin
  hppIconPack := FindIconsDll(false);

  ZeroMemory(@sid, sizeof(sid));
  sid.cbSize          := sizeof(sid);
  sid.Flags           := SIDF_PATH_UNICODE; // group/descr = ansi
  sid.szDefaultFile.w := hppIconPack;
  sid.szSection.a     := @groupbuf;
  sid.pszName         := @namebuf;

  p:=StrCopyE(groupbuf,hppName + '/');
  pp:=StrCopyE(namebuf,'h++_');
  for i := Low(tHppIconName) to High(tHppIconName) do
  begin
    with hppIconsDefs[i] do
    begin
      StrCopy(p,IconGroups[group]);
      IntToStr(pp,ord(i),3);
      sid.iDefaultIndex:= ord(i);
      if desc=nil then // events (message type)
      begin
        for j:=Low(TBuiltinMessageType) to High(TBuiltinMessageType) do
        begin
          if EventRecords[j].idx = ord(i) then
          begin
            sid.szDescription.a := EventRecords[j].Name;
            break;
          end;
        end;
      end
      else
        sid.szDescription.a := desc;
      hppIcons[i].id := Skin_AddIcon(@sid);
    end;
  end;
{
  StrCopyW(p,IconGroups[4]);
  for mt := Low(EventRecords) to High(EventRecords) do
  begin
    if EventRecords[mt].idx > 0 then
    begin
      sid.pszName         := hppIcons[EventRecords[mt].idx].name;
      sid.szDescription.w := EventRecords[mt].name;
      sid.iDefaultIndex   := EventRecords[mt].i;
      hppIcons[EventRecords[mt].i].id := Skin_AddIcon(@sid);
    end
    else
      skinIcons[EventRecords[mt].i].id := EventRecords[mt].iSkin;
  end;
}
  mFreeMem(hppIconPack);

  // update icon handles from icolib
  LoadSkinIcons;
  LoadHppIcons;
end;

end.
