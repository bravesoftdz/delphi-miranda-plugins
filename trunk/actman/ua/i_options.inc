{}
const
  opt_ua      :PAnsiChar = 'ACT_UA';
  opt_count   :PAnsiChar = 'count';

  opt_name    :PAnsiChar = 'name';
  opt_flags   :PAnsiChar = 'flags';
  opt_action  :PAnsiChar = 'action';

procedure SaveUAs;
{
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  i,amount:integer;
}
begin
{
  DBDeleteModule(opt_tasks);
  amount:=0;
  for i:=0 to MaxTasks-1 do
  begin
    if (TaskList[i].flags and ACF_ASSIGNED)=0 then
      continue;

    p:=StrEnd(IntToStr(section,amount));
    with TaskList[i] do
    begin
      StrCopy(p,opt_flags ); DBWriteDWord  (0,opt_tasks,section,flags);
      StrCopy(p,opt_name  ); DBWriteUnicode(0,opt_tasks,section,name);
      StrCopy(p,opt_action); DBWriteDWord  (0,opt_tasks,section,action);
    end;
    inc(amount);
  end;
  DBWriteByte(0,opt_tasks,opt_count,amount);
}
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
(*
int ReadSetting(MyActionItem* ActionItem){
	DBVARIANT dbv, dbv2;
	int result = 1;
	char text[200], *szDest;
	mir_snprintf(text, 32, "Act%u_", ActionItem->dwActID);
	szDest = text + strlen(text);

	strcpy(szDest, "Flags");
	ActionItem->wFlags = DBGetContactSettingWord(NULL, MODULE, text,0);

	strcpy(szDest, "MMenuPopup");
	if(!DBGetContactSettingTString(NULL, MODULE, text, &dbv)) {
		_tcscpy(ActionItem->tszMMenuPopup, dbv.ptszVal);
		DBFreeVariant(&dbv);
		result++;
	}
	strcpy(szDest, "MMenuName");
	if(!DBGetContactSettingTString(NULL, MODULE, text, &dbv)) {
		_tcscpy(ActionItem->tszMMenuNameVars, dbv.ptszVal);
		DBFreeVariant(&dbv);
		result++;
	}
	strcpy(szDest, "MMenuVarStr");
	if(!DBGetContactSettingTString(NULL, MODULE, text, &dbv2)) {
		_tcscpy(ActionItem->tszMMenuShowWhenVars, dbv2.ptszVal);
		DBFreeVariant(&dbv2);
		result++;
	}
	strcpy(szDest, "CMenuName");
	if(!DBGetContactSettingTString(NULL, MODULE, text, &dbv)) {
		_tcscpy(ActionItem->tszCMenuNameVars, dbv.ptszVal);
		DBFreeVariant(&dbv);
		result++;
	}
	strcpy(szDest, "CMenuPopup");
	if(!DBGetContactSettingTString(NULL, MODULE, text, &dbv)) {
		_tcscpy(ActionItem->tszCMenuPopup, dbv.ptszVal);
		DBFreeVariant(&dbv);
		result++;
	}
	strcpy(szDest, "CMenuVarStr");
	if(!DBGetContactSettingTString(NULL, MODULE, text, &dbv2)) {
		_tcscpy(ActionItem->tszCMenuShowWhenVars, dbv2.ptszVal);
		DBFreeVariant(&dbv2);
		result++;
	}
	strcpy(szDest, "TMenuPopup");
	if(!DBGetContactSettingTString(NULL, MODULE, text, &dbv)) {
		_tcscpy(ActionItem->tszTMenuPopup, dbv.ptszVal);
		DBFreeVariant(&dbv);
		result++;
	}
	return result;
}

void WriteSetting(MyActionItem* ActionItem){
	char text[200], *szDest;
	mir_snprintf(text, 32, "Act%u_", ActionItem->dwActID);
	szDest = text + strlen(text);

	strcpy(szDest, "Flags");
	if(ActionItem->wFlags == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingWord(NULL, MODULE, text, ActionItem->wFlags);
	strcpy(szDest, "MMenuPopup");
	if(ActionItem->tszMMenuPopup[0] == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingTString(NULL, MODULE, text, ActionItem->tszMMenuPopup);
	strcpy(szDest, "MMenuName");
	if(ActionItem->tszMMenuNameVars[0] == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingTString(NULL, MODULE, text, ActionItem->tszMMenuNameVars);
	strcpy(szDest, "MMenuVarStr");
	if(ActionItem->tszMMenuShowWhenVars[0] == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingTString(NULL, MODULE, text, ActionItem->tszMMenuShowWhenVars);
	strcpy(szDest, "CMenuName");
	if(ActionItem->tszCMenuNameVars[0] == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingTString(NULL, MODULE, text, ActionItem->tszCMenuNameVars);
	strcpy(szDest, "CMenuPopup");
	if(ActionItem->tszCMenuPopup[0] == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingTString(NULL, MODULE, text, ActionItem->tszCMenuPopup);
	strcpy(szDest, "CMenuVarStr");
	if(ActionItem->tszCMenuShowWhenVars[0] == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingTString(NULL, MODULE, text, ActionItem->tszCMenuShowWhenVars);
	strcpy(szDest, "TMenuPopup");
	if(ActionItem->tszTMenuPopup[0] == 0)
		DBDeleteContactSetting(NULL, MODULE, text);
	else
		DBWriteContactSettingTString(NULL, MODULE, text, ActionItem->tszTMenuPopup);
}
*)