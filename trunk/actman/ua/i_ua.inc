{}
{}
const
  MODULE = 'Actions';
  ICOLIB_ACTSECTION = 'Actions/Registered actions';
  ICOLIB_MNUSECTION = 'Actions/Menu icons';
  SERVICE_WITH_LPARAM_NAME = MODULE+'/CallAction';

type
  MyActionItem = record
    flags               :dword;
    dwActID             :dword;     // action ID
    wSortIndex          :word;
    // UseActions/Action_ID
    szNameID            :pAnsiChar; // uaction ID
    szActDescr          :pWideChar; // action name

    hIcolibIconOn,
    hIcolibIconOff      :THANDLE;

    hMTBButton          :THANDLE;   // Modern toolbar button
    wReggedTabButton    :word;      // TabSRMM button

    hMenuService        :THANDLE;   // common menu service
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
  end;
  tUActionList = array [0..1023] of MyActionItem;
  pUActionList = ^tUActionList;

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

var
  UActionList:array of MyActionItem;

function AddUAction:integer;
begin
  result:=0;
end;

procedure DeleteUAction(num:integer);
begin
end;

function CreateUActionList:integer;
var
  ptr,ptr1:pChain;
  i:integer;
  buf:array [0..127] of AnsiChar;
  p:pAnsiChar;
begin
  result:=CallService(MS_ACT_GETLIST,0,LPARAM(@ptr));
  SetLength(UActionList,result);
  if result>0 then
  begin
    ptr1:=ptr;
    inc(pbyte(ptr),4);
    p:=StrCopyE(StrCopyE(buf,MODULE),'/Action_');
    for i:=0 to result-1 do
    begin
      FillChar(UActionList[i],SizeOf(MyActionItem),0);

      with UActionList[i] do
      begin
        // get Action settings
        dwActID:=ptr^.id;
        if (ptr^.flags and ACCF_DISABLED)<>0 then
          flags:=UAF_DISABLED;
        StrDupW(szActDescr,ptr^.descr);
        wSortIndex:=i;
        
        // prepare for work
        IntToStr(p,ptr^.id);
        StrDup(szNameID,@buf);
      end;
      inc(ptr);
    end;
    CallService(MS_ACT_FREELIST,0,LPARAM(ptr1));
  end;
end;
