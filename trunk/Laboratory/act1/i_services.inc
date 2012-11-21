{Basic ActMan services}

function ActSelect(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
begin
  result:=int_ptr(GetMacro(lParam,(wParam and ACCF_ID)<>0));
  if result<>0 then
    with pMacroRecord(result)^ do
    begin
      if (wParam and ACCF_CLEAR)<>0 then
        flags:=flags and not (uint_ptr(wParam) and ACCF_FLAGS)
      else
        flags:=flags or      (uint_ptr(wParam) and ACCF_FLAGS);
    end;
end;

function ActFreeList(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
begin
  result:=0;
  mFreeMem(PAnsiChar(lParam));
end;

function ActGetList(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  pc:^tChain;
  p:pMacroRecord;
  i,cnt:integer;
begin
  p:=pMacroRecord(MacroList);
  cnt:=0;
  for i:=0 to MaxMacros-1 do
  begin
    if (p^.flags and (ACF_ASSIGNED or ACCF_VOLATILE))=ACF_ASSIGNED then inc(cnt);
    inc(p);
  end;
  result:=cnt;
  if lParam=0 then exit;
  if cnt>0 then
  begin
    mGetMem(pc,cnt*SizeOf(tChain)+4);
    puint_ptr(lParam)^:=uint_ptr(pc);
//    {$IFDEF WIN64}pqword{$ELSE}pdword{$ENDIF}(lParam)^:=uint_ptr(pc);
    pdword(pc)^:=SizeOf(tChain);
    inc(PByte(pc),4);

    p:=pMacroRecord(MacroList);
    for i:=0 to MaxMacros-1 do
    begin
      if (p^.flags and (ACF_ASSIGNED or ACCF_VOLATILE))=ACF_ASSIGNED then
      begin
        pc^.descr:=p^.descr;
        pc^.id   :=p^.id;
        pc^.flags:=p^.flags;
        inc(pc);
      end;
      inc(p);
    end;
  end
  else
    puint_ptr(lParam)^:=0;
//    {$IFDEF WIN64}pqword{$ELSE}pdword{$ENDIF}(lParam)^:=0;
end;

//====================== Execute code =======================

procedure DoAction(Macro:pMacroRecord;var WorkData:tWorkData);
var
  res:LRESULT;
  i,cnt:integer;
begin
  cnt:=Macro.ActionCount;
  if cnt<>0 then
  begin
//!!    act:=CloneActions(action);
    i:=0;
    while i<cnt do
    begin
      if (Macro^.ActionList^[i].flags and ACF_DISABLED)=0 then
      begin
        res:=Macro^.ActionList^[i].DoAction(WorkData);
        if res<0 then break
        else if res>0 then // res = next action number+1
        begin
          i:=res-1;
          continue;
        end;
      end;
      inc(i);
    end;
//!!    FreeActionsContinued(act_org);
  end;
end;

type
  pActStartData = ^tActStartData;
  tActStartData = record
    macro   :pMacroRecord;
    event   :THANDLE;
    WorkData:tWorkData;
    flags   :dword;
  end;

procedure ThDoAction(arg:pActStartData); cdecl;
begin
  if (arg^.flags and ACTP_NOTIFY)<>0 then
  begin
    NotifyEventHooks(hevaction,arg^.macro.id,0); // started
    arg^.macro.flags:=arg^.macro.flags or ACF_USEDNOW;
  end;

  DoAction(arg^.macro,arg^.WorkData);

  if (arg^.flags and ACTP_NOTIFY)<>0 then
  begin
    arg^.macro.flags:=arg^.macro.flags and not ACF_USEDNOW;
    NotifyEventHooks(hevaction,arg^.macro.id,1); // finished
  end;

  if arg^.event<>0 then // service, waiting
    SetEvent(arg^.event)
  else if (arg^.flags and ACTP_SAMETHREAD)=0 then // no waiting
  begin
    ClearResult(arg^.WorkData); // free last result memory if needs
    mFreeMem(arg);              // free ActStartData (no time to free after)
  end;
end;

function ActionStarter(macro:pMacroRecord;wd:pWorkData;flags:dword):LPARAM;
var
  tmp:pActStartData;
begin
  mGetMem(tmp,SizeOf(tActStartData));

  tmp^.WorkData.ResultType:=wd^.ResultType;
  case wd^.ResultType of
    rtInt : tmp^.WorkData.LastResult:=wd^.LastResult;
    rtWide: StrDupW(pWideChar(tmp^.WorkData.LastResult),pWideChar(wd^.LastResult));
    rtAnsi: begin
      AnsiToWide(pAnsiChar(wd^.LastResult),pWideChar(tmp^.WorkData.LastResult));
      tmp^.WorkData.ResultType:=rtWide;
    end;
    rtUTF8: begin
      UTF8ToWide(pAnsiChar(wd^.LastResult),pWideChar(tmp^.WorkData.LastResult));
      tmp^.WorkData.ResultType:=rtWide;
    end;
  end;
  tmp^.WorkData.Parameter:=wd^.Parameter;
  tmp^.macro :=macro;
  tmp^.flags :=flags;

  if (flags and ACTP_SAMETHREAD)<>0 then // with waiting, macro or service
  begin
    tmp^.event:=0;
    ThDoAction(tmp);
    // keep text result (for macro from macro)
    if (flags and ACTP_KEEPRESULT)<>0 then
    begin
      wd^.ResultType:=tmp^.WorkData.ResultType;
      if wd^.ResultType=rtInt then
        wd^.LastResult:=tmp^.WorkData.LastResult
      else
        StrDupW(pWideChar(wd^.LastResult),pWideChar(tmp^.WorkData.LastResult));
      result:=0;
    end
    else if tmp^.WorkData.ResultType=rtInt then
      result:=tmp^.WorkData.LastResult
    // result no needs or macro from service
    else
      result:=StrToInt(pWideChar(tmp^.WorkData.LastResult));
  end

  else if (flags and ACTP_WAIT)<>0 then // with waiting, service
  begin
    tmp^.event:=CreateEvent(nil,FALSE,FALSE,nil);
    CloseHandle(mir_forkthread(@ThDoAction,tmp));
    WaitForSingleObjectEx(tmp.event,INFINITE,true);
    CloseHandle(tmp^.event);
    if tmp^.WorkData.ResultType=rtWide then
      result:=StrToInt(pWideChar(tmp^.WorkData.LastResult))
    else
      result:=tmp^.WorkData.LastResult;
  end

  else // no waiting, service or macro
  begin
    tmp^.event:=0;
    CloseHandle(mir_forkthread(@ThDoAction,tmp));
    result:=0;
    exit;
  end;

  ClearResult(tmp^.WorkData); // free last result memory if needs
  mFreeMem(tmp);              // free ActStartData (no time to free after)
end;

//----- execute services -----

function ActRun(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  p:pMacroRecord;
  w:tWorkData;
begin
  result:=-1;
  p:=GetMacro(wParam,true);
  if p<>nil then
  begin
    FillChar(w,SizeOf(w),0);
    w.Parameter:=lParam;
    result:=ActionStarter(p,@w,0);
  end;
end;

function ActRunGroup(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  p:pMacroRecord;
  w:tWorkData;
begin
  result:=-1;
  p:=GetMacro(wParam,false);
  if p<>nil then
  begin
    FillChar(w,SizeOf(w),0);
    w.Parameter:=lParam;
    result:=ActionStarter(p,@w,0);
  end;
end;

function ActRunParam(wParam:WPARAM;lParam:LPARAM):int_ptr;cdecl;
var
  p:pMacroRecord;
  w:tWorkData;
begin
  result:=-1;
  p:=GetMacro(pAct_Param(lParam)^.Id,(pAct_Param(lParam)^.flags and ACTP_BYNAME)=0);

  if p<>nil then
  begin
    FillChar(w,SizeOf(w),0);
    w.Parameter :=pAct_Param(lParam)^.wParam;
    w.LastResult:=pAct_Param(lParam)^.lParam;
    w.ResultType:=pAct_Param(lParam)^.lPType;
    result:=ActionStarter(p,@w,pAct_Param(lParam)^.flags);
  end;
end;
