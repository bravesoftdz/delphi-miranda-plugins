{}
const
  MODULE_NAME = 'Actions';
const
  opt_ua:PAnsiChar = 'ACT_UA';
  opt_Flags:PAnsiChar = 'Flags';

const
  ICOLIB_ACTSECTION = 'Actions/Registered actions';
  ICOLIB_MNUSECTION = 'Actions/Menu icons';

  SERVICE_WITH_LPARAM_NAME = 'Actions/CallAction';
  MTB_SERVICE_NAME         = 'Actions/MTBAction';

type
  tMenuType = (main_menu,contact_menu,tray_menu);
  pUAMenuItem = ^tUAMenuItem;
  tUAMenuItem = record
    hMenuItem         :THANDLE;
    szMenuPopup       :pWideChar;
    szMenuNameVars    :pWideChar;
    szMenuShowWhenVars:pWideChar;
    hMenuRoot         :THANDLE;
    changed           :boolean;
  end;
type
  pMyActionItem = ^tMyActionItem;
  tMyActionItem = record
    flags               :dword;
    dwActID             :dword;     // action ID
    wSortIndex          :word;
    // UseActions/Action_ID
    szNameID            :pAnsiChar; // uaction ID
    szActDescr          :pWideChar; // action name

    hIcolibIcon,
    hIcolibIconPressed  :THANDLE;

    hMTBButton          :THANDLE;   // Modern toolbar button
    szMTBTooltip        :PAnsiChar;
    szMTBTooltipPressed :PAnsiChar;

    szTabBTooltip       :PWideChar;
    szTabBTooltipPressed:PWideChar;

    hMenuService        :THANDLE;   // common menu service
    UAMenuItem          :array [tMenuType] of tUAMenuItem;
  end;

const
  UAF_NONE      = 0;

  UAF_REGHOTKEY = 1 shl  0; // hotkey
  UAF_REGMTBB   = 1 shl  1; // modern toolbar
  UAF_REGMMENU  = 1 shl  2; // main menu
  UAF_REGCMENU  = 1 shl  3; // contact menu
  UAF_REGTMENU  = 1 shl  4; // tray menu
  UAF_REGTABB   = 1 shl  5; // TabSRMM toolbar
  UAF_USING     = UAF_REGHOTKEY or UAF_REGMTBB or UAF_REGMMENU or UAF_REGCMENU or
                  UAF_REGTMENU or UAF_REGTABB;

  UAF_MMENUSEP  = 1 shl  8; // main menu separated
  UAF_CMENUSEP  = 1 shl  9; // contact menu separated
  UAF_TMENUSEP  = 1 shl 10; // tray menu separated
  UAF_2STATE    = 1 shl 11; // Buttons/menu items are 2-state
  UAF_PRESSED   = 1 shl 12; // Button pressed/menu item selected
  UAF_SAVESTATE = 1 shl 13; // Save or not "pressed" state

  // realtime, no save
  UAF_HKREGGED  = 1 shl 16; // hotkey registered
  UAF_TBREGGED  = 1 shl 17; // TabSRMM button registered
  UAF_DISABLED  = 1 shl 30; // action disabled atm
  UAF_REALTIME  = UAF_HKREGGED or UAF_TBREGGED or UAF_DISABLED;

  UAF_SPECIAL   = 1 shl 31; // for settings read

type
  tNameRec = record
    name   :PAnsiChar;
    service:PAnsiChar;
    mask   :dword;
    enable :boolean;
  end;

const
  NumTypes  = 6;
const
  uaMTB     = 0;
  uaTAB     = 1;
  uaMain    = 2;
  uaContact = 3;
  uaTray    = 4;
  uaHotkey  = 5;
const
  NamesArray: array [0..NumTypes-1] of tNameRec = (
    (name:'CList Modern toolbar'; service:'ToolBar/AddButton'           ; mask:UAF_REGMTBB),
    (name:'TabSRMM toolbar'     ; service:'TabSRMM/ButtonsBar/AddButton'; mask:UAF_REGTABB),
    (name:'Main menu'           ; service:nil                           ; mask:UAF_REGMMENU),
    (name:'Contact menu'        ; service:nil                           ; mask:UAF_REGCMENU),
    (name:'Tray menu'           ; service:'CList/AddTrayMenuItem'       ; mask:UAF_REGTMENU),
    (name:'Core Hotkey'         ; service:nil{MS_HOTKEY_REGISTER}       ; mask:UAF_REGHOTKEY));

var
  UActionList:array of tMyActionItem;
var
  szMyPath:array [0..MAX_PATH] of WideChar;
var
  hServiceWithLParam:THANDLE;
  hMTBService:THANDLE;
