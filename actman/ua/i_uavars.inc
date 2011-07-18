{}
const
  ICOLIB_ACTSECTION = 'Actions/Registered actions';
  ICOLIB_MNUSECTION = 'Actions/Menu icons';
  SERVICE_WITH_LPARAM_NAME = 'Actions/CallAction';

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
    pressed           :boolean;
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
    wReggedTabButton    :word;      // TabSRMM button

    hMenuService        :THANDLE;   // common menu service
    UAMenuItem:array [tMenuType] of tUAMenuItem;
{
    // Main menu item
    hMainMenuItem       :THANDLE;
    szMMenuPopup        :pWideChar;
    szMMenuNameVars     :pWideChar;
    szMMenuShowWhenVars :pWideChar;
    hMMenuRoot          :THANDLE;
    // Contact menu item
    hContactMenuItem    :THANDLE;
    szCMenuNameVars     :pWideChar;
    szCMenuPopup        :pWideChar;
    szCMenuShowWhenVars :pWideChar;
    hCMenuRoot          :THANDLE;
    // Tray menu item
    hTrayMenuItem       :THANDLE;
    szTMenuNameVars     :pWideChar;
    szTMenuPopup        :pWideChar;
    szTMenuShowWhenVars :pWideChar;
    hTMenuRoot          :THANDLE;
}
  end;

const
  UAF_NONE       = 0;

  UAF_REGHOTKEY  = 1 shl  0; // hotkey
  UAF_REGMTBB    = 1 shl  1; // modern toolbar
  UAF_REGMMENU   = 1 shl  2; // main menu
  UAF_REGCMENU   = 1 shl  3; // contact menu
  UAF_REGTMENU   = 1 shl  4; // tray menu
  UAF_REGTABB    = 1 shl  5; // TabSRMM toolbar
  UAF_USING      = UAF_REGHOTKEY or UAF_REGMTBB or UAF_REGMMENU or UAF_REGCMENU or
                   UAF_REGTMENU or UAF_REGTABB;

  UAF_MMENUSEP   = 1 shl  6; // main menu separated
  UAF_CMENUSEP   = 1 shl  7; // contact menu separated
  UAF_TMENUSEP   = 1 shl  8; // tray menu separated
  // realtime
  UAF_HKREGGED   = 1 shl 16; // hotkey registered
  UAF_DISABLED   = 1 shl 30; // action disabled atm

  UAF_SPECIAL    = 1 shl 31; // for settings read

var
  UActionList:array of tMyActionItem;
var
  szMyPath:array [0..MAX_PATH] of WideChar;
