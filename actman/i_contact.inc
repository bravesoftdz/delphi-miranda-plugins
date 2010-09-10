{hkContact}
const
  defformat = '%name% - %uid% (%account%:%group%)';

procedure FillContactList(list:hwnd; filter:boolean=true;format:pWideChar=nil);
var
  hContact:THANDLE;
  buf:array [0..511] of WideChar;
  buf1:array [0..63] of WideChar;
  p:PWideChar;
  uid:pAnsiChar;
  ldbv:TDBVARIANT;
  acc:pAnsiChar;
begin
  if format=nil then format:=defformat;

  SendMessage(list,CB_RESETCONTENT,0,0);
  hContact:=CallService(MS_DB_CONTACT_FINDFIRST,0,0);
  while hContact<>0 do
  begin
    if ((not filter) and ((IsContactActive(hContact)+1)>=0)) or // + disabled (not deleted)
            (filter  and  (IsContactActive(hContact)   >=0)) then
    begin
      StrCopyW(buf,format);
      if StrPosW(buf,'%name%')<>nil then
        StrReplaceW(buf,'%name%',
          PWideChar(CallService(MS_CLIST_GETCONTACTDISPLAYNAME,hContact,GCDNF_UNICODE)));

      if StrPosW(buf,'%group%')<>nil then
      begin
        p:=DBReadUnicode(hContact,strCList,'Group',nil);
        StrReplaceW(buf,'%group%',p);
        mFreeMem(p);
      end;

      acc:=nil;
      if StrPosW(buf,'%account%')<>nil then
      begin
        acc:=GetContactProtoAcc(hContact);
        StrReplaceW(buf,'%account%',FastAnsiToWideBuf(acc,buf1));
      end;

      if StrPosW(buf,'%uid%')<>nil then
      begin
        if acc=nil then
          acc:=GetContactProtoAcc(hContact);
        if IsChat(hContact) then
        begin
          p:=DBReadUnicode(hContact,acc,'ChatRoomID');
          StrReplaceW(buf,'%uid%',p);
          mFreeMem(p);
        end
        else
        begin
          uid:=pAnsiChar(CallProtoService(acc,PS_GETCAPS,PFLAG_UNIQUEIDSETTING,0));
          if dword(uid)<>CALLSERVICE_NOTFOUND then
          begin
            if DBReadSetting(hContact,acc,uid,@ldbv)=0 then
            begin
              case ldbv._type of
                DBVT_DELETED: p:='[deleted]';
                DBVT_BYTE   : p:=IntToStr(buf1,ldbv.bVal);
                DBVT_WORD   : p:=IntToStr(buf1,ldbv.wVal);
                DBVT_DWORD  : p:=IntToStr(buf1,ldbv.dVal);
                DBVT_UTF8   : UTF8ToWide(ldbv.szVal.A,p);
                DBVT_ASCIIZ : AnsiToWide(ldbv.szVal.A,p,MirandaCP);
                DBVT_WCHAR  : p:=ldbv.szVal.W;
                DBVT_BLOB   : p:='blob';
              end;
              StrReplaceW(buf,'%uid%',p);
              if ldbv._type in [DBVT_UTF8,DBVT_ASCIIZ] then
                mFreeMem(p);
              DBFreeVariant(@ldbv);
            end;
          end;
          StrReplaceW(buf,'%uid%',nil);
        end;
      end;

      SendMessage(list,CB_SETITEMDATA,
          SendMessageW(list,CB_ADDSTRING,0,dword(@buf)),
          hContact);
    end;
    hContact:=CallService(MS_DB_CONTACT_FINDNEXT,hContact,0);
  end;
end;

function FindContact(list:hwnd;contact:cardinal):integer;
var
  i,j:integer;
begin
  result:=0;
  j:=SendMessage(list,CB_GETCOUNT,0,0);
  for i:=0 to j-1 do
  begin
    if dword(SendMessage(list,CB_GETITEMDATA,i,0))=contact then
    begin
      result:=i;
      break;
    end;
  end;
end;
