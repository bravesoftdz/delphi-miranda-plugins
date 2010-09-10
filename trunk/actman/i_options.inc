{Save/load options}

const
  opt_main    = 'AWK_Groups';
  opt_actions = 'AWK_Actions';
  opt_numacts = 'numactions';
  opt_numhk   = 'numgroups';
  opt_firstAction = 'firstaction';

  opt_cproto   = 'cproto';
  opt_cuid     = 'cuid';
  opt_ischat   = 'ischat';

  opt_descr    = 'descr';
  opt_id       = 'id';
  opt_flags    = 'flags';
  opt_flags2   = 'flags2';
  opt_time     = 'time';
  opt_show     = 'show';
  opt_action   = 'action';
  opt_value    = 'value';
  opt_file     = 'file';

  opt_next     = 'next';
  opt_type     = 'type';
  opt_contact  = 'contact';
  opt_text     = 'text';
  opt_prg      = 'program';
  opt_args     = 'arguments';
  opt_service  = 'service';
  opt_wparam   = 'wparam';
  opt_wlparam  = 'wparamlen';
  opt_llparam  = 'lparamlen';
  opt_lparam   = 'lparam';
  opt_chain    = 'chain';
  opt_cond     = 'condition';
  opt_count    = 'count';
  opt_module   = 'module';
  opt_setting  = 'setting';
  opt_oper     = 'operation';
  opt_mathval  = 'mathval';
  opt_operval  = 'operval';
  opt_varval   = 'varval';
  opt_msgtitle = 'msgtitle';
  opt_msgtext  = 'msgtext';
  opt_boxopts  = 'boxopts';

function LoadContact(num:integer):THANDLE;
var
  p,proto:pAnsiChar;
  section:array [0..63] of AnsiChar;
  dbv:TDBVARIANT;
  is_chat:boolean;
begin
  p:=StrEnd(IntToStr(section,num));
  StrCopy(p,opt_cproto); proto  :=DBReadString(0,opt_actions,section);
  StrCopy(p,opt_ischat); is_chat:=DBReadByte  (0,opt_actions,section,0)<>0;
  StrCopy(p,opt_cuid  );
  if is_chat then
    dbv.szVal.W:=DBReadUnicode(0,opt_actions,section,@dbv)
  else
    DBReadSetting(0,opt_actions,section,@dbv);

  result:=FindContactHandle(proto,dbv,is_chat);

  mFreeMem(proto);
  if not is_chat then
    DBFreeVariant(@dbv);
end;

function SaveContact(hContact:THANDLE;num:integer):integer;
var
  p,proto,uid:pAnsiChar;
  cws:TDBVARIANT;
  section:array [0..63] of AnsiChar;
  pw:pWideChar;
  is_chat:boolean;
begin
  result:=0;
  proto:=GetContactProtoAcc(hContact);
  if proto<>nil then
  begin
    p:=StrEnd(IntToStr(section,num));
    is_chat:=IsChat(hContact);
    if is_chat then
    begin
      pw:=DBReadUnicode(hContact,proto,'ChatRoomID');
      StrCopy(p,opt_cuid); DBWriteUnicode(0,opt_actions,section,pw);
      mFreeMem(pw);
      result:=1;
    end
    else
    begin
      uid:=pAnsiChar(CallProtoService(proto,PS_GETCAPS,PFLAG_UNIQUEIDSETTING,0));
      if DBReadSetting(hContact,proto,uid,@cws)=0 then
      begin
        StrCopy(p,opt_cuid); DBWriteSetting(0,opt_actions,section,@cws);
        DBFreeVariant(@cws);
        result:=1;
      end;
    end;
    if result<>0 then
    begin
      StrCopy(p,opt_cproto); DBWriteString(0,opt_actions,section,proto);
      StrCopy(p,opt_ischat); DBWriteByte  (0,opt_actions,section,ord(is_chat));
    end;
  end;
end;

procedure SaveNumValue(setting:pAnsiChar;value:dword;isvar:boolean);
begin
  if isvar then
    DBWriteUnicode(0,opt_actions,setting,pWideChar(value))
  else
    DBWriteDWord  (0,opt_actions,setting,value);
end;

procedure SaveActions(first:integer;var start:integer);
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  act:pHKAction;
  i:integer;
begin
  while first<>0 do
  begin
    act:=@ActionList[first];
    p:=StrEnd(IntToStr(section,start));

    StrCopy(p,opt_flags ); DBWriteDWord(0,opt_actions,section,act^.flags);
    StrCopy(p,opt_flags2); DBWriteDWord(0,opt_actions,section,act^.flags2);
    StrCopy(p,opt_type  ); DBWriteByte (0,opt_actions,section,act^.actionType);
    if act^.descr<>nil then
    begin
      StrCopy(p,opt_descr); DBWriteUnicode(0,opt_actions,section,act^.descr);
    end;
    if act^.next=0 then
      i:=0
    else
      i:=start+1;
    StrCopy(p,opt_next); DBWriteWord(0,opt_actions,section,i);

    case act^.actionType of
      ACT_CONTACT: begin
        SaveContact(act^.contact,start);
//        StrCopy(p,opt_contact); DBWriteDWord(0,opt_actions,section,act^.contact);
      end;

      ACT_SERVICE: begin
        StrCopy(p,opt_service); DBWriteString(0,opt_actions,section,act^.service);

        if (act^.flags and (ACF_WCURRENT or ACF_WRESULT or ACF_WPARAM))=0 then
        begin
          StrCopy(p,opt_wparam);
          if (act^.flags and ACF_WPARNUM)<>0 then
            SaveNumValue(section,act^.wparam,(act^.flags2 and ACF2_SRV_WPAR)<>0)
//            DBWriteDWord(0,opt_actions,section,act^.wparam)
          else if act^.wparam<>0 then
          begin
            if (act^.flags and ACF_WSTRUCT)<>0 then
              DBWriteUnicode(0,opt_actions,section,pWideChar(act^.wparam))
            else if (act^.flags and ACF_WUNICODE)<>0 then
              DBWriteUnicode(0,opt_actions,section,pWideChar(act^.wparam))
            else
              DBWriteString(0,opt_actions,section,PAnsiChar(act^.wparam));
          end;
        end;

        if (act^.flags and (ACF_LCURRENT or ACF_LRESULT or ACF_LPARAM))=0 then
        begin
          StrCopy(p,opt_lparam);
          if (act^.flags and ACF_LPARNUM)<>0 then
            SaveNumValue(section,act^.lparam,(act^.flags2 and ACF2_SRV_LPAR)<>0)
//            DBWriteDWord(0,opt_actions,section,act^.lparam)
          else if act^.lparam<>0 then
          begin
            if (act^.flags and ACF_LSTRUCT)<>0 then
              DBWriteUnicode(0,opt_actions,section,pWideChar(act^.lparam))
            else if (act^.flags and ACF_LUNICODE)<>0 then
              DBWriteUnicode(0,opt_actions,section,pWideChar(act^.lparam))
            else
              DBWriteString(0,opt_actions,section,PAnsiChar(act^.lparam));
          end;
        end;

      end;

      ACT_PROGRAM: begin
        StrCopy(p,opt_prg ); DBWriteUnicode(0,opt_actions,section,act^.prgname);
        StrCopy(p,opt_args); DBWriteUnicode(0,opt_actions,section,act^.args);
        StrCopy(p,opt_time); DBWriteDWord  (0,opt_actions,section,act^.time);
        StrCopy(p,opt_show); DBWriteDWord  (0,opt_actions,section,act^.show);
      end;

      ACT_TEXT: begin
        if (act^.flags and ACF_CLIPBRD)=0 then
        begin
          StrCopy(p,opt_text); DBWriteUnicode(0,opt_actions,section,act^.text);
          if (act^.flags and ACF_FILE)<>0 then
          begin
            StrCopy(p,opt_file); DBWriteUnicode(0,opt_actions,section,act^.tfile);
          end;
        end;
      end;

      ACT_ADVANCE: begin
        StrCopy(p,opt_cond   ); DBWriteByte   (0,opt_actions,section,act^.condition);
        StrCopy(p,opt_value  ); DBWriteDWord  (0,opt_actions,section,act^.value);
        StrCopy(p,opt_action ); DBWriteByte   (0,opt_actions,section,act^.action);
        StrCopy(p,opt_operval); DBWriteUnicode(0,opt_actions,section,act^.operval);
        StrCopy(p,opt_oper   ); DBWriteByte   (0,opt_actions,section,act^.oper);
        StrCopy(p,opt_mathval); DBWriteDWord  (0,opt_actions,section,act^.mathval);
        StrCopy(p,opt_varval ); DBWriteUnicode(0,opt_actions,section,act^.varval);
      end;

      ACT_CHAIN: begin
        StrCopy(p,opt_text); DBWriteDWord(0,opt_actions,section,act^.id);
      end;

      ACT_RW: begin
        if (act^.flags and ACF_NOCNTCT)=0 then
          SaveContact(act^.dbcontact,start);
//        StrCopy(p,opt_contact); DBWriteDWord (0,opt_actions,section,act^.dbcontact);
        StrCopy(p,opt_module ); DBWriteString(0,opt_actions,section,act^.dbmodule);
        StrCopy(p,opt_setting); DBWriteString(0,opt_actions,section,act^.dbsetting);
        StrCopy(p,opt_value  );
        if (act^.flags and ACF_DBUTEXT)=0 then
        begin
          SaveNumValue(section,act^.dbvalue,(act^.flags2 and ACF2_RW_TVAR)<>0);
//          DBWriteDWord(0,opt_actions,section,act^.dbvalue)
        end
        else
          DBWriteUnicode(0,opt_actions,section,pWideChar(act^.dbvalue));
      end;

      ACT_MESSAGE: begin
        StrCopy(p,opt_msgtitle); DBWriteUnicode(0,opt_actions,section,act^.msgtitle);
        StrCopy(p,opt_msgtext ); DBWriteUnicode(0,opt_actions,section,act^.msgtext);
        StrCopy(p,opt_boxopts ); DBWriteByte   (0,opt_actions,section,act^.boxopts); //!!
      end;

    end;
    inc(start);
    first:=ActionList^[first].next;
  end;
end;

procedure SaveGroups;
var
  HK:pHKRecord;
  NumHK:integer;
  i,j:integer;
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  Actions:integer;
begin
  DBDeleteGroup(0,opt_main);
  DBDeleteGroup(0,opt_actions);
  HK:=@GroupList^;
  i:=MaxGroups;
  NumHK:=0;
  Actions:=1;
  DBWriteUnicode(0,opt_main,'CLformat',fCLformat);
  DBWriteByte   (0,opt_main,'CLfilter',ord(fCLfilter));
  while i>0 do
  begin
    with HK^ do
    begin
      if (flags and (ACF_ASSIGNED or ACF_VOLATILE))=ACF_ASSIGNED then
      begin
        p:=StrEnd(IntToStr(section,NumHK));
        StrCopy(p,opt_flags      ); DBWriteDWord(0,opt_main,section,flags);
        if firstAction=0 then
          j:=0
        else
          j:=Actions;
        StrCopy(p,opt_firstAction); DBWriteDWord(0,opt_main,section,j);
        StrCopy(p,opt_id         ); DBWriteDWord(0,opt_main,section,id);

        SaveActions(firstAction,Actions);
        if descr<>nil then
        begin
          StrCopy(p,opt_descr); DBWriteUnicode(0,opt_main,section,descr);
        end;
        inc(NumHK);
      end;
    end;
    inc(HK);
    dec(i);
  end;
  DBWriteWord(0,opt_main   ,opt_numhk  ,NumHK);
  DBWriteWord(0,opt_actions,opt_numacts,Actions-1);
end;

function LoadNumValue(setting:pAnsiChar;isvar:boolean):dword;
begin
  if isvar then
    pWideChar(result):=DBReadUnicode(0,opt_actions,setting,nil)
  else
    result:=DBReadDWord(0,opt_actions,setting);
end;

function LoadActions:integer;
var
  section:array [0..63] of AnsiChar;
  p:PAnsiChar;
  act:pHKAction;
  i:integer;
begin
  if MaxActions<>0 then
  begin
    act:=@ActionList[1];
    while MaxActions>0 do
    begin
      FreeAction(act);
      inc(act);
      dec(MaxActions);
    end;
    FreeMem(ActionList);
  end;

  result:=DBReadWord(0,opt_actions,opt_numacts,ActListPage);
  if result<ActListPage then
    MaxActions:=ActListPage
  else
    MaxActions:=result+1;

  GetMem  (ActionList ,MaxActions*SizeOf(tHKAction));
  FillChar(ActionList^,MaxActions*SizeOf(tHKAction),0);

  act:=@ActionList[1];
  for i:=1 to result do
  begin
    p:=StrEnd(IntToStr(section,i));
    StrCopy(p,opt_flags ); Act^.flags :=DBReadDWord  (0,opt_actions,section,0);
    StrCopy(p,opt_flags2); Act^.flags2:=DBReadDWord  (0,opt_actions,section,0);
    StrCopy(p,opt_descr ); Act^.descr :=DBReadUnicode(0,opt_actions,section,nil);
    if (Act^.flags and ACF_ASSIGNED)<>0 then
    begin
      StrCopy(p,opt_type ); Act^.actionType:=DBReadByte (0,opt_actions,section,ACT_CONTACT);
      StrCopy(p,opt_next ); Act^.next      :=DBReadWord (0,opt_actions,section,0);

      case act^.actionType of
        ACT_CONTACT: begin
          act^.contact:=LoadContact(i);
        end;

        ACT_SERVICE: begin
          StrCopy(p,opt_service);
          act^.service:=DBReadString(0,opt_actions,section,nil);

          if (act^.flags and (ACF_WCURRENT or ACF_WRESULT or ACF_WPARAM))=0 then
          begin
            StrCopy(p,opt_wparam);
            if (act^.flags and ACF_WPARNUM)<>0 then
               act^.wparam:=LoadNumValue(section,(act^.flags2 and ACF2_SRV_WPAR)<>0)
//              act^.wparam:=DBReadDWord(0,opt_actions,section,0)
            else if (act^.flags and ACF_WSTRUCT)<>0 then
              PWideChar(act^.wparam):=DBReadUnicode(0,opt_actions,section,nil)
            else if (act^.flags and ACF_WUNICODE)<>0 then
              PWideChar(act^.wparam):=DBReadUnicode(0,opt_actions,section,nil)
            else
              PAnsiChar(act^.wparam):=DBReadString(0,opt_actions,section,nil);
          end;

          if (act^.flags and (ACF_LCURRENT or ACF_LRESULT or ACF_LPARAM))=0 then
          begin
            StrCopy(p,opt_lparam);
            if (act^.flags and ACF_LPARNUM)<>0 then
               act^.lparam:=LoadNumValue(section,(act^.flags2 and ACF2_SRV_LPAR)<>0)
//              act^.lparam:=DBReadDWord(0,opt_actions,section,0)
            else if (act^.flags and ACF_LSTRUCT)<>0 then
              PWideChar(act^.lparam):=DBReadUnicode(0,opt_actions,section,nil)
            else if (act^.flags and ACF_LUNICODE)<>0 then
              PWideChar(act^.lparam):=DBReadUnicode(0,opt_actions,section,nil)
            else
              PAnsiChar(act^.lparam):=DBReadString(0,opt_actions,section,nil);
          end;

        end;

        ACT_PROGRAM: begin
          StrCopy(p,opt_prg ); Act^.prgname:=DBReadUnicode(0,opt_actions,section,nil);
          StrCopy(p,opt_args); Act^.args   :=DBReadUnicode(0,opt_actions,section,nil);
          StrCopy(p,opt_time); Act^.time   :=DBReadDWord  (0,opt_actions,section,0);
          StrCopy(p,opt_show); Act^.show   :=DBReadDWord  (0,opt_actions,section,SW_SHOW);
        end;

        ACT_TEXT: begin
          if (act^.flags and ACF_CLIPBRD)=0 then
          begin
            StrCopy(p,opt_text); Act^.text:=DBReadUnicode(0,opt_actions,section,nil);
            if (act^.flags and ACF_FILE)<>0 then
            begin
              StrCopy(p,opt_file); Act^.tfile:=DBReadUnicode(0,opt_actions,section,nil);
            end;
          end;
        end;

        ACT_ADVANCE: begin
          StrCopy(p,opt_cond   ); act^.condition:=DBReadByte   (0,opt_actions,section);
          StrCopy(p,opt_value  ); act^.value    :=DBReadDWord  (0,opt_actions,section);
          StrCopy(p,opt_action ); act^.action   :=DBReadByte   (0,opt_actions,section);
          StrCopy(p,opt_oper   ); act^.oper     :=DBReadByte   (0,opt_actions,section);
          StrCopy(p,opt_mathval); act^.mathval  :=DBReadDWord  (0,opt_actions,section);
          StrCopy(p,opt_operval); act^.operval  :=DBReadUnicode(0,opt_actions,section);
          StrCopy(p,opt_varval ); act^.varval   :=DBReadUnicode(0,opt_actions,section);
        end;

        ACT_CHAIN: begin
          StrCopy(p,opt_text); act^.id:=DBReadDWord(0,opt_actions,section);
        end;

        ACT_RW: begin
          if (act^.flags and ACF_NOCNTCT)=0 then
            act^.dbcontact:=LoadContact(i);
          StrCopy(p,opt_module ); act^.dbmodule :=DBReadString(0,opt_actions,section);
          StrCopy(p,opt_setting); act^.dbsetting:=DBReadString(0,opt_actions,section);
          StrCopy(p,opt_value  );

          if (act^.flags and ACF_DBUTEXT)=0 then
            act^.dbvalue:=LoadNumValue(section,(act^.flags2 and ACF2_RW_TVAR)<>0)
          else
            pWideChar(act^.dbvalue):=DBReadUnicode(0,opt_actions,section);
        end;

        ACT_MESSAGE: begin
          StrCopy(p,opt_msgtitle); act^.msgtitle:=DBReadUnicode(0,opt_actions,section);
          StrCopy(p,opt_msgtext ); act^.msgtext :=DBReadUnicode(0,opt_actions,section);
          StrCopy(p,opt_boxopts ); act^.boxopts :=DBReadByte   (0,opt_actions,section);
        end;

      end;
    end;
    inc(act);
  end;
end;

procedure LoadGroups;
var
  HK:pHKRecord;
  i:dword;
  p:PAnsiChar;
  section:array [0..63] of AnsiChar;
  NumGroups,NumActions:dword;
begin

  if MaxGroups>0 then
  begin
    while MaxGroups>0 do
    begin
      FreeGroup(MaxGroups);
      dec(MaxGroups);
    end;
    FreeMem(GroupList);
  end;
  
  NumGroups:=DBReadWord(0,opt_main,opt_numhk,HKListPage);
  if NumGroups<HKListPage then
    MaxGroups:=HKListPage
  else
    MaxGroups:=NumGroups;
  GetMem  (GroupList ,MaxGroups*SizeOf(tHKRecord));
  FillChar(GroupList^,MaxGroups*SizeOf(tHKRecord),0);

  NumActions:=LoadActions;

  HK:=@GroupList^; //??
  i:=0;
  while i<NumGroups do
  begin
    p:=StrEnd(IntToStr(section,i));
    StrCopy(p,opt_flags);
    with HK^ do
    begin
      flags:=DBReadDWord(0,opt_main,section,0{integer(ACF_ASSIGNED or ACF_DISABLED)});
      if (flags and ACF_ASSIGNED)<>0 then // not needed in normal cases
      begin
        StrCopy(p,opt_descr      ); descr      :=DBReadUnicode(0,opt_main,section,nil);
        StrCopy(p,opt_firstAction); firstAction:=DBReadDWord  (0,opt_main,section,0);
        StrCopy(p,opt_id         ); id         :=DBReadDWord  (0,opt_main,section);
        if firstAction>NumActions then
          firstAction:=0;
        if descr=nil then
          StrDupW(descr,TranslateW('No Description'));
      end;
    end;
    inc(HK);
    inc(i);
  end;
  fCLfilter:=DBReadByte   (0,opt_main,'CLfilter',0)<>0;
  fCLformat:=DBReadUnicode(0,opt_main,'CLformat');
end;
