{}
const
  opt_ua:PAnsiChar = 'ACT_UA';

  opt_Flags:PAnsiChar = 'Flags';

  opt_MTBTooltip        :pAnsiChar = 'MTBTooltip';
  opt_MTBTooltipPressed :pAnsiChar = 'MTBTooltipPressed';

  opt_TabBTooltip       :pAnsiChar = 'TabBTooltip';
  opt_TabBTooltipPressed:pAnsiChar = 'TabBTooltipPressed';

  opt_MMenuPopup       :pAnsiChar = 'MMenuPopup';
  opt_MMenuNameVars    :pAnsiChar = 'MMenuName';
  opt_MMenuShowWhenVars:pAnsiChar = 'MMenuVarStr';

  opt_CMenuPopup       :pAnsiChar = 'CMenuPopup';
  opt_CMenuNameVars    :pAnsiChar = 'CMenuName';
  opt_CMenuShowWhenVars:pAnsiChar = 'CMenuVarStr';

  opt_TMenuPopup       :pAnsiChar = 'TMenuPopup';
  opt_TMenuNameVars    :pAnsiChar = 'TMenuName';
  opt_TMenuShowWhenVars:pAnsiChar = 'TMenuVarStr';


procedure DeleteUASettings(idx:integer);
var
  setting:array [0..63] of AnsiChar;
  p:pAnsiChar;
begin
  with UActionList[idx] do
  begin
    p:=StrEnd(IntToStr(StrCopyE(setting,'Act_'),dwActID));
    p^:='_'; inc(p);

    StrCopy(p,opt_Flags); DBDeleteSetting(0,opt_UA,setting);
  
    StrCopy(p,opt_MTBTooltip        ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_MTBTooltipPressed ); DBDeleteSetting(0,opt_UA,setting);

    StrCopy(p,opt_TabBTooltip       ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_TabBTooltipPressed); DBDeleteSetting(0,opt_UA,setting);

    StrCopy(p,opt_MMenuPopup       ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_MMenuNameVars    ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_MMenuShowWhenVars); DBDeleteSetting(0,opt_UA,setting);

    StrCopy(p,opt_CMenuPopup       ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_CMenuNameVars    ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_CMenuShowWhenVars); DBDeleteSetting(0,opt_UA,setting);

    StrCopy(p,opt_TMenuPopup       ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_TMenuNameVars    ); DBDeleteSetting(0,opt_UA,setting);
    StrCopy(p,opt_TMenuShowWhenVars); DBDeleteSetting(0,opt_UA,setting);
  end;
end;

procedure addSaveUA(setting:pAnsiChar;txt:pWideChar); overload;
begin
  if (txt=nil) or (txt^=#0) then DBDeleteSetting(0,opt_UA,setting)
  else DBWriteUnicode(0,opt_UA,setting,txt);
end;

procedure addSaveUA(setting:pAnsiChar;txt:pAnsiChar); overload;
begin
  if (txt=nil) or (txt^=#0) then DBDeleteSetting(0,opt_UA,setting)
  else DBWriteString(0,opt_UA,setting,txt);
end;

procedure SaveUA(idx:integer);
var
  setting:array [0..63] of AnsiChar;
  p:pAnsiChar;
begin
  with UActionList[idx] do
  begin
    p:=StrEnd(IntToStr(StrCopyE(setting,'Act_'),dwActID));
    p^:='_'; inc(p);

    StrCopy(p,opt_Flags); DBWriteDWord(0,opt_UA,setting,flags and not UAF_REALTIME);

    StrCopy(p,opt_MTBTooltip       ); addSaveUA(setting,szMTBTooltip);
    StrCopy(p,opt_MTBTooltipPressed); addSaveUA(setting,szMTBTooltipPressed);

    StrCopy(p,opt_TabBTooltip       ); addSaveUA(setting,szTabBTooltip);
    StrCopy(p,opt_TabBTooltipPressed); addSaveUA(setting,szTabBTooltipPressed);

    with UAMenuItem[main_menu] do
    begin
      StrCopy(p,opt_MMenuPopup       ); addSaveUA(setting,szMenuPopup);
      StrCopy(p,opt_MMenuNameVars    ); addSaveUA(setting,szMenuNameVars);
      StrCopy(p,opt_MMenuShowWhenVars); addSaveUA(setting,szMenuShowWhenVars);
    end;

    with UAMenuItem[contact_menu] do
    begin
      StrCopy(p,opt_CMenuPopup       ); addSaveUA(setting,szMenuPopup);
      StrCopy(p,opt_CMenuNameVars    ); addSaveUA(setting,szMenuNameVars);
      StrCopy(p,opt_CMenuShowWhenVars); addSaveUA(setting,szMenuShowWhenVars);
    end;

    with UAMenuItem[tray_menu] do
    begin
      StrCopy(p,opt_TMenuPopup       ); addSaveUA(setting,szMenuPopup);
      StrCopy(p,opt_TMenuNameVars    ); addSaveUA(setting,szMenuNameVars);
      StrCopy(p,opt_TMenuShowWhenVars); addSaveUA(setting,szMenuShowWhenVars);
    end;

  end;
end;

procedure SaveUAs;
var
  i:integer;
begin
  for i:=0 to HIGH(UActionList) do
    SaveUA(i);
end;

function LoadUA(idx:integer):integer;
var
  setting:array [0..63] of AnsiChar;
  p:pAnsiChar;
begin
  result:=0;
  with UActionList[idx] do
  begin
    p:=StrEnd(IntToStr(StrCopyE(setting,'Act_'),dwActID));
    p^:='_'; inc(p);

    StrCopy(p,opt_Flags); flags:=DBReadDWord(0,opt_UA,setting,dword(UAF_SPECIAL));
    if flags=dword(UAF_SPECIAL) then // no settings
      exit;

    flags:=flags and not UAF_REALTIME;
    result:=1;

    StrCopy(p,opt_MTBTooltip       ); szMTBTooltip       :=DBReadString(0,opt_UA,setting);
    StrCopy(p,opt_MTBTooltipPressed); szMTBTooltipPressed:=DBReadString(0,opt_UA,setting);
                                      
    StrCopy(p,opt_TabBTooltip       ); szTabBTooltip       :=DBReadUnicode(0,opt_UA,setting);
    StrCopy(p,opt_TabBTooltipPressed); szTabBTooltipPressed:=DBReadUnicode(0,opt_UA,setting);

    with UAMenuItem[main_menu] do
    begin
      StrCopy(p,opt_MMenuPopup       ); szMenuPopup       :=DBReadUnicode(0,opt_UA,setting);
      StrCopy(p,opt_MMenuNameVars    ); szMenuNameVars    :=DBReadUnicode(0,opt_UA,setting);
      StrCopy(p,opt_MMenuShowWhenVars); szMenuShowWhenVars:=DBReadUnicode(0,opt_UA,setting);
    end;

    with UAMenuItem[contact_menu] do
    begin
      StrCopy(p,opt_CMenuPopup       ); szMenuPopup       :=DBReadUnicode(0,opt_UA,setting);
      StrCopy(p,opt_CMenuNameVars    ); szMenuNameVars    :=DBReadUnicode(0,opt_UA,setting);
      StrCopy(p,opt_CMenuShowWhenVars); szMenuShowWhenVars:=DBReadUnicode(0,opt_UA,setting);
    end;

    with UAMenuItem[tray_menu] do
    begin
      StrCopy(p,opt_TMenuPopup       ); szMenuPopup       :=DBReadUnicode(0,opt_UA,setting);
      StrCopy(p,opt_TMenuNameVars    ); szMenuNameVars    :=DBReadUnicode(0,opt_UA,setting);
      StrCopy(p,opt_TMenuShowWhenVars); szMenuShowWhenVars:=DBReadUnicode(0,opt_UA,setting);
    end;
  end;
end;

function LoadUAs:integer;
{
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  i:integer;
}
begin
  result:=0;
{
  MaxTasks:=DBReadByte(0,opt_tasks,opt_count);
  result:=MaxTasks;
  if MaxTasks>0 then
  begin
    GetMem  (TaskList ,MaxTasks*SizeOf(tTaskRec));
    FillChar(TaskList^,MaxTasks*SizeOf(tTaskRec),0);
    for i:=0 to MaxTasks-1 do
    begin
      p:=StrEnd(IntToStr(section,i));
      with TaskList[i] do
      begin
        StrCopy(p,opt_flags ); flags    :=DBReadDWord  (0,opt_tasks,section);
        StrCopy(p,opt_name  ); name     :=DBReadUnicode(0,opt_tasks,section);
        StrCopy(p,opt_action); action   :=DBReadDWord  (0,opt_tasks,section);
      end;
    end;
  end;
}
end;

procedure SetAllActionUsers(var ActionItem:tMyActionItem);
var
  buf:array [0..63] of AnsiChar;
begin
  if (ActionItem.flags and UAF_REGHOTKEY)<>0 then
    AddCoreHotkey(ActionItem)
  else
    DeleteCoreHotkey(ActionItem);

  DeleteMTBButton(ActionItem); // no modify command there, just delete, then insert back
  if (ActionItem.flags and UAF_REGMTBB)<>0 then
    AddMTBButton(ActionItem);

  if (ActionItem.flags and UAF_REGTABB)<>0 then
    AddTabBBButton(ActionItem)
  else
    DeleteTabBBButton(ActionItem);

  if (ActionItem.flags and UAF_REGMMENU)<>0 then
  begin
    if ActionItem.UAMenuItem[main_menu].changed then
      DeleteMainMenuItem(ActionItem);
    AddMainMenuItem(ActionItem)
  end
  else
    DeleteMainMenuItem(ActionItem);

  if (ActionItem.flags and UAF_REGCMENU)<>0 then
  begin
    if ActionItem.UAMenuItem[contact_menu].changed then
      DeleteContactMenuItem(ActionItem);
    AddContactMenuItem(ActionItem)
  end
  else
    DeleteContactMenuItem(ActionItem);

  if (ActionItem.flags and UAF_REGTMENU)<>0 then
  begin
    if ActionItem.UAMenuItem[tray_menu].changed then
      DeleteTrayMenuItem(ActionItem);
    AddTrayMenuItem(ActionItem)
  end
  else
    DeleteTrayMenuItem(ActionItem);

  if ((ActionItem.flags and (UAF_REGMMENU or UAF_REGCMENU or UAF_REGTMENU))=0) and
      (ActionItem.hMenuService<>0) then
  begin
    PluginLink^.DestroyServiceFunction(ActionItem.hMenuService);
    ActionItem.hMenuService:=0;
  end;

  // First run (ok ok, if ppl ask for it....)
  StrCat(IntToStr(StrCopyE(buf,'Act'),ActionItem.dwActID),'_FirstRun');
  if DBReadByte(0,opt_UA,buf,0)<>0 then
  begin
    CAllService(MS_ACT_RUNBYID,ActionItem.dwActID,0);
    DBDeleteSetting(0,opt_UA,buf);
  end;
end;

procedure DeleteUAction(num:integer);
var
  ActionItem:pMyActionItem;
  buf:array [0..63] of AnsiChar;
begin
  DeleteUASettings(num);

  ActionItem:=@UActionList[num];

  DeleteIcolibIcon(ActionItem^);

  if (ActionItem.flags and UAF_REGHOTKEY)<>0 then
    DeleteCoreHotkey(ActionItem^);

  if (ActionItem.flags and UAF_REGMTBB)<>0 then
    DeleteMTBButton(ActionItem^);

  if (ActionItem.flags and UAF_REGTABB)<>0 then
    DeleteTabBBButton(ActionItem^);

  if (ActionItem.flags and UAF_REGMMENU)<>0 then
    DeleteMainMenuItem(ActionItem^);

  if (ActionItem.flags and UAF_REGCMENU)<>0 then
    DeleteContactMenuItem(ActionItem^);

  if (ActionItem.flags and UAF_REGTMENU)<>0 then
    DeleteTrayMenuItem(ActionItem^);

  if ((ActionItem.flags and (UAF_REGMMENU or UAF_REGCMENU or UAF_REGTMENU))=0) and
      (ActionItem.hMenuService<>0) then
  begin
    PluginLink^.DestroyServiceFunction(ActionItem.hMenuService);
    ActionItem.hMenuService:=0;
  end;

  StrCat(IntToStr(StrCopyE(buf,'Act'),ActionItem.dwActID),'_FirstRun');
  DBDeleteSetting(0,opt_UA,buf);

  // Free Memory
  mFreeMem(ActionItem.szNameID);
  mFreeMem(ActionItem.szActDescr);
  
  mFreeMem(ActionItem.szMTBTooltip);
  mFreeMem(ActionItem.szMTBTooltipPressed);

  mFreeMem(ActionItem.szTabBTooltip);
  mFreeMem(ActionItem.szTabBTooltipPressed);

  with ActionItem.UAMenuItem[main_menu] do
  begin
    mFreeMem(szMenuPopup);
    mFreeMem(szMenuNameVars);
    mFreeMem(szMenuShowWhenVars);
  end;

  with ActionItem.UAMenuItem[contact_menu] do
  begin
    mFreeMem(szMenuPopup);
    mFreeMem(szMenuNameVars);
    mFreeMem(szMenuShowWhenVars);
  end;

  with ActionItem.UAMenuItem[tray_menu] do
  begin
    mFreeMem(szMenuPopup);
    mFreeMem(szMenuNameVars);
    mFreeMem(szMenuShowWhenVars);
  end;

  // compact list
  if num<HIGH(UActionList) then
  begin
    move(UActionList[num+1],UActionList[num],(HIGH(UACtionList)-num)*SizeOf(tMyActionItem));
  end;
  SetLength(UActionList,Length(UActionList)-1);
end;
