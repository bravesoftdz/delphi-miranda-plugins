//----- Event to text translation -----

procedure GetEventTextForMessage(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  msgA: PAnsiChar;
  msgW: PWideChar;
  msglen,lenW: integer;
  i: integer;
begin
  msgA := PAnsiChar(EventInfo.pBlob);
  msgW := nil;
  msglen := StrLen(PAnsiChar(EventInfo.pBlob)) + 1;
  if msglen > integer(EventInfo.cbBlob) then
    msglen := EventInfo.cbBlob;
  if Boolean(EventInfo.flags and DBEF_UTF) then
  begin
    SetLength(Hi.Text, msglen);
    lenW := Utf8ToWideChar(PWideChar(Hi.Text), msglen, msgA, msglen - 1, Hi.CodePage);
    if lenW > 0 then
      SetLength(Hi.Text, lenW - 1)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
  end
  else
  begin
    lenW := 0;
    if integer(EventInfo.cbBlob) >= msglen * SizeOf(WideChar) then
    begin
      msgW := PWideChar(msgA + msglen);
      for i := 0 to ((integer(EventInfo.cbBlob) - msglen) div SizeOf(WideChar)) - 1 do
        if msgW[i] = #0 then
        begin
          lenW := i;
          break;
        end;
    end;
    if (lenW > 0) and (lenW < msglen) then
      SetString(Hi.Text, msgW, lenW)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
  end;
end;

procedure GetEventTextForAuthRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  uin:integer;
  hContact: THANDLE;
  Nick,Name,Email,Reason: AnsiString;
  NickW,ReasonW,ReasonUTF,ReasonACP: WideString;
begin
  // blob is: uin(DWORD), hContact(THANDLE), nick(ASCIIZ), first(ASCIIZ), last(ASCIIZ), email(ASCIIZ)
  uin := PDWord(EventInfo.pBlob)^;
  hContact := PInt_ptr(uint_ptr(Pointer(EventInfo.pBlob)) + SizeOf(dword))^;
  BytePos := SizeOf(dword) + SizeOf(THANDLE);
  // read nick
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Nick, BytePos);
  if Nick = '' then
    NickW := GetContactDisplayName(hContact, '', true)
  else
    NickW := AnsiToWideString(Nick, CP_ACP);
  // read first name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := Name + ' ';
  // read last name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := AnsiString(Trim(WideString(Name)));
  if Name <> '' then
    Name := Name + ', ';
  // read Email
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Email, BytePos);
  if Email <> '' then
    Email := Email + ', ';
  // read reason
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Reason, BytePos);

  ReasonUTF := AnsiToWideString(Reason, CP_UTF8);
  ReasonACP := AnsiToWideString(Reason, hppCodepage);
  if (Length(ReasonUTF) > 0) and (Length(ReasonUTF) < Length(ReasonACP)) then
    ReasonW := ReasonUTF
  else
    ReasonW := ReasonACP;
  Hi.Text := Format(TranslateW('Authorization request by %s (%s%d): %s'),
    [NickW, AnsiToWideString(Name + Email, hppCodepage), uin, ReasonW]);
end;

procedure GetEventTextForYouWereAdded(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  uin: integer;
  hContact:THANDLE;
  Nick,Name,Email: AnsiString;
  NickW: String;
begin
  // blob is: uin(DWORD), hContact(THANDLE), nick(ASCIIZ), first(ASCIIZ), last(ASCIIZ), email(ASCIIZ)
  uin := PDWord(EventInfo.pBlob)^;
  hContact := PInt_ptr(uint_ptr(Pointer(EventInfo.pBlob)) + SizeOf(dword))^;
  BytePos := SizeOf(dword) + SizeOf(THANDLE);
  // read nick
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Nick, BytePos);
  if Nick = '' then
    NickW := GetContactDisplayName(hContact, '', true)
  else
    NickW := AnsiToWideString(Nick, CP_ACP);
  // read first name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := Name + ' ';
  // read last name
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Name, BytePos);
  Name := AnsiString(Trim(WideString(Name)));
  if Name <> '' then
    Name := Name + ', ';
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Email, BytePos);
  if Email <> '' then
    Email := Email + ', ';
  Hi.Text := Format(TranslateW('You were added by %s (%s%d)'),
    [NickW, AnsiToWideString(Name + Email, hppCodepage), uin]);
end;

procedure GetEventTextForSms(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  cp: Cardinal;
begin
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  Hi.Text := AnsiToWideString(PAnsiChar(EventInfo.pBlob), cp);
end;

procedure GetEventTextForContacts(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Contacts: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  Contacts := '';
  While BytePos < Cardinal(EventInfo.cbBlob) do
  begin
    Contacts := Contacts + #13#10;
    ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Contacts, BytePos);
    Contacts := Contacts + ' (ICQ: ';
    ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Contacts, BytePos);
    Contacts := Contacts + ')';
  end;
  if Boolean(EventInfo.flags and DBEF_SENT) then
    Hi.Text := 'Outgoing contacts: %s'
  else
    Hi.Text := 'Incoming contacts: %s';
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  hi.Text := Format(TranslateUnicodeString(hi.Text),[AnsiToWideString(Contacts,cp)]);
end;

procedure GetEventTextForWebPager(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  hi.Text := Format(TranslateW('Webpager message from %s (%s): %s'),
                           [AnsiToWideString(Name,cp),
                           AnsiToWideString(Email,cp),
                           AnsiToWideString(#13#10+Body,cp)]);
end;

procedure GetEventTextForEmailExpress(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  Hi.Text := Format(TranslateW('Email express from %s (%s): %s'),
    [AnsiToWideString(Name, cp), AnsiToWideString(Email, cp),
    AnsiToWideString(#13#10 + Body, cp)]);
end;

procedure GetEventTextForStatusChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  tmp: THistoryItem;
begin
  tmp.Codepage := hppCodepage;
  GetEventTextForMessage(EventInfo,tmp);
  hi.Text := Format(TranslateW('Status change: %s'),[tmp.Text]);
end;

procedure GetEventTextForAvatarChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  msgA: PAnsiChar;
  msgW: PWideChar;
  msglen,lenW: Cardinal;
  i: integer;
begin
  msgA := PAnsiChar(EventInfo.pBlob);
  msgW := nil;
  msglen := lstrlenA(PAnsiChar(EventInfo.pBlob)) + 1;
  if msglen > Cardinal(EventInfo.cbBlob) then
    msglen := EventInfo.cbBlob;
  if Boolean(EventInfo.flags and DBEF_UTF) then
  begin
    SetLength(Hi.Text, msglen);
    lenW := Utf8ToWideChar(PWideChar(Hi.Text), msglen, msgA, msglen - 1, Hi.CodePage);
    if Integer(lenW) > 0 then
      SetLength(Hi.Text, lenW - 1)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
  end
  else
  begin
    lenW := 0;
    if Cardinal(EventInfo.cbBlob) >= msglen * SizeOf(WideChar) then
    begin
      msgW := PWideChar(msgA + msglen);
      for i := 0 to ((Cardinal(EventInfo.cbBlob) - msglen) div SizeOf(WideChar)) - 1 do
        if msgW[i] = #0 then
        begin
          lenW := i;
          break;
        end;
    end;
    if (lenW > 0) and (lenW < msglen) then
      SetString(Hi.Text, msgW, lenW)
    else
      Hi.Text := AnsiToWideString(msgA, Hi.CodePage, msglen - 1);
    msglen := msglen + (lenW + 1) * SizeOf(WideChar);
  end;
  if msglen < Cardinal(EventInfo.cbBlob) then
  begin
    msgA := msgA + msglen;
    if lstrlenA(msgA) > 0 then
      Hi.Extended := msgA;
  end;
end;

function GetEventTextForICQSystem(EventInfo: TDBEventInfo; const Template: WideString): WideString;
var
  BytePos: LongWord;
  Body: AnsiString;
  uin: Integer;
  Name: WideString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob), EventInfo.cbBlob, Body, BytePos);
  if Cardinal(EventInfo.cbBlob) < (BytePos + 4) then
    uin := 0
  else
    uin := PDWord(PAnsiChar(EventInfo.pBlob) + BytePos)^;
  if Cardinal(EventInfo.cbBlob) < (BytePos + 8) then
    Name := TranslateW('''(Unknown Contact)''' { TRANSLATE-IGNORE } )
  else
    Name := GetContactDisplayName(PDWord(PAnsiChar(EventInfo.pBlob) + BytePos + 4)^, '', true);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  Result := Format(Template, [Name, uin, AnsiToWideString(#13#10 + Body, cp)]);
end;

procedure GetEventTextForICQAuthGranted(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Authorization request granted by %s (%d): %s'));
end;

procedure GetEventTextForICQAuthDenied(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Authorization request denied by %s (%d): %s'));
end;

procedure GetEventTextForICQSelfRemove(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('User %s (%d) removed himself from your contact list: %s'));
end;

procedure GetEventTextForICQFutureAuth(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Authorization future request by %s (%d): %s'));
end;

procedure GetEventTextForICQClientChange(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('User %s (%d) changed icq client: %s'));
end;

procedure GetEventTextForICQCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Status request by %s (%d):%s'));
end;

procedure GetEventTextForICQIgnoreCheckStatus(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := GetEventTextForICQSystem(EventInfo,
    TranslateW('Ignored status request by %s (%d):%s'));
end;

procedure GetEventTextForICQBroadcast(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Body,Name,Email: AnsiString;
  cp: Cardinal;
begin
  BytePos := 0;
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Body,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Name,BytePos);
  ReadStringTillZeroA(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Email,BytePos);
  hi.Text := TranslateW('Broadcast message from %s (%s): %s');
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := hppCodepage;
  hi.Text := Format(hi.Text,[AnsiToWideString(Name,cp),
                             AnsiToWideString(Email,cp),
                             AnsiToWideString(#13#10+Body,cp)]);
end;

procedure GetEventTextForJabberChatStates(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  if EventInfo.cbBlob = 0 then exit;
  case PByte(EventInfo.pBlob)^ of
    JABBER_DB_EVENT_CHATSTATES_GONE:
      hi.Text := TranslateW('closed chat session');
  end;
end;

procedure GetEventTextWATrackRequest(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := TranslateW('WATrack: information request');
end;

procedure GetEventTextWATrackAnswer(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  BytePos: LongWord;
  Artist,Title,Album,Template: WideString;
begin
  BytePos := 0;
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Artist  ,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Title   ,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Album   ,BytePos);
  ReadStringTillZeroW(Pointer(EventInfo.pBlob),EventInfo.cbBlob,Template,BytePos);
  if (Artist <> '') or (Title <> '') or (Album <> '') then
  begin
    if Template <> '' then
      Template := Template + #13#10;
    Template := Template + Format//WideFormat
      (TranslateW('Artist: %s'#13#10'Title: %s'#13#10'Album: %s'),
      [Artist, Title, Album]);
  end;
  hi.Text := Format(TranslateW('WATrack: %s'),[Template]);
end;

procedure GetEventTextWATrackError(EventInfo: TDBEventInfo; var Hi: THistoryItem);
begin
  hi.Text := TranslateW('WATrack: request denied');
end;

procedure GetEventTextForOther(EventInfo: TDBEventInfo; var Hi: THistoryItem);
var
  cp: Cardinal;
begin
  TextBuffer.Allocate(EventInfo.cbBlob+1);
  StrCopy(TextBuffer.Buffer,PAnsiChar(EventInfo.pBlob),EventInfo.cbBlob);
  if Boolean(EventInfo.flags and DBEF_UTF) then
    cp := CP_UTF8
  else
    cp := Hi.CodePage;
  hi.Text := AnsiToWideString(PAnsiChar(TextBuffer.Buffer),cp);
end;
