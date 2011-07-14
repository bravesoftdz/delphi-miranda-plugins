unit UA;

interface

procedure Init;
procedure DeInit;
function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;

implementation

uses
  windows, commctrl, messages,
  mirutils, common, dbsettings, io, m_api, wrapper,
  global;

{$R ua.res}

{$include m_actman.inc}

{$include i_uconst.inc}
{$include i_options.inc}
{$include i_ua.inc}
{$include i_uaplaces.inc}
{$include i_opt_dlg.inc}

// ------------ base interface functions -------------

procedure Init;
begin

  CheckPlacesAbility;
  CreateUActionList;
  if LoadUAs=0 then
  begin
  end
  else
end;

procedure DeInit;
begin
end;

function AddOptionPage(var tmpl:pAnsiChar;var proc:pointer;var name:PAnsiChar):integer;
begin
  result:=0;
  tmpl:=PAnsiChar(IDD_UA);
  proc:=@DlgProcOpt;
  name:='Use Actions';
end;

var
  amLink:tActionLink;

procedure InitLink;
begin
  amLink.next     :=ActionLink;
  amLink.Init     :=@Init;
  amLink.DeInit   :=@Deinit;
  amLink.AddOption:=@AddOptionPage;
  ActionLink      :=@amLink;
end;

initialization
  InitLink;
end.
