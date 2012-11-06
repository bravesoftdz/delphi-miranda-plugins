{}
procedure THistoryGrid.SaveAll(FileName: String; SaveFormat: TSaveFormat);
var
  i: Integer;
  fs: TFileStream;
begin
  if Count = 0 then
    raise Exception.Create('History is empty, nothing to save');
  State := gsSave;
  try
    fs := TFileStream.Create(FileName, fmCreate or fmShareExclusive);
    SaveStart(fs, SaveFormat, TxtFullLog);
    ShowProgress := True;
    if ReversedHeader then
      for i := 0 to SelCount - 1 do
      begin
        SaveItem(fs, FSelItems[i], SaveFormat);
        DoProgress(i, Count - 1);
      end
    else
      for i := Count - 1 downto 0 do
      begin
        SaveItem(fs, i, SaveFormat);
        DoProgress(Count - 1 - i, Count - 1);
      end;
    SaveEnd(fs, SaveFormat);
    fs.Free;
    ShowProgress := False;
    DoProgress(0, 0);
  finally
    State := gsIdle;
  end;
end;

procedure THistoryGrid.SaveSelected(FileName: String; SaveFormat: TSaveFormat);
var
  fs: TFileStream;
  i: Integer;
begin
  Assert((SelCount > 0), 'Save Selection is available when more than 1 item is selected');
  State := gsSave;
  try
    fs := TFileStream.Create(FileName, fmCreate or fmShareExclusive);
    SaveStart(fs, SaveFormat, TxtPartLog);
    ShowProgress := True;
    if (FSelItems[0] > FSelItems[High(FSelItems)]) xor ReversedHeader then
      for i := 0 to SelCount - 1 do
      begin
        SaveItem(fs, FSelItems[i], SaveFormat);
        DoProgress(i, SelCount);
      end
    else
      for i := SelCount - 1 downto 0 do
      begin
        SaveItem(fs, FSelItems[i], SaveFormat);
        DoProgress(SelCount - 1 - i, SelCount);
      end;
    SaveEnd(fs, SaveFormat);
    fs.Free;
    ShowProgress := False;
    DoProgress(0, 0);
  finally
    State := gsIdle;
  end;
end;

const
  css = 'h3 { color: #666666; text-align: center; font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 16pt; }'
    + #13#10 +
    'h4 { text-align: center; font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 14pt; }'
    + #13#10 +
    'h6 { font-weight: normal; color: #000000; text-align: center; font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 8pt; }'
    + #13#10 +
    '.mes { border-top-width: 1px; border-right-width: 0px; border-bottom-width: 0px;' +
    'border-left-width: 0px; border-top-style: solid; border-right-style: solid; border-bottom-style: solid; '
    + 'border-left-style: solid; border-top-color: #666666; border-bottom-color: #666666; ' +
    'padding: 4px; }' + #13#10 + '.text { clear: both; }' + #13#10;

  xml = '<?xml version="1.0" encoding="%s"?>' + #13#10 + '<!DOCTYPE IMHISTORY [' + #13#10 +
    '<!ELEMENT IMHISTORY (EVENT*)>' + #13#10 +
    '<!ELEMENT EVENT (CONTACT, FROM, TIME, DATE, PROTOCOL, ID?, TYPE, FILE?, URL?, MESSAGE?)>' +
    #13#10 + '<!ELEMENT CONTACT (#PCDATA)>' + #13#10 + '<!ELEMENT FROM (#PCDATA)>' + #13#10 +
    '<!ELEMENT TIME (#PCDATA)>' + #13#10 + '<!ELEMENT DATE (#PCDATA)>' + #13#10 +
    '<!ELEMENT PROTOCOL (#PCDATA)>' + #13#10 + '<!ELEMENT ID (#PCDATA)>' + #13#10 +
    '<!ELEMENT TYPE (#PCDATA)>' + #13#10 + '<!ELEMENT FILE (#PCDATA)>' + #13#10 +
    '<!ELEMENT URL (#PCDATA)>' + #13#10 + '<!ELEMENT MESSAGE (#PCDATA)>' + #13#10 +
    '<!ENTITY ME "%s">' + #13#10 + '%s' + '<!ENTITY UNK "UNKNOWN">' + #13#10 + ']>' + #13#10 +
    '<IMHISTORY>' + #13#10;

function ColorToCss(Color: TColor): AnsiString;
var
  first2, mid2, last2: AnsiString;
begin
  Result := IntToHex(Color, 6);
  if Length(Result) > 6 then
    SetLength(Result, 6);
  // rotate for HTML color format from AA AB AC to AC AB AA
  first2 := Copy(Result, 1, 2);
  mid2 := Copy(Result, 3, 2);
  last2 := Copy(Result, 5, 2);
  Result := '#' + last2 + mid2 + first2;
end;

function FontToCss(Font: TFont): AnsiString;
begin
  Result := 'color: ' + ColorToCss(Font.Color) + '; font: '; // color
  if fsItalic in Font.Style then // font-style
    Result := Result + 'italic '
  else
    Result := Result + 'normal ';
  Result := Result + 'normal '; // font-variant
  if fsBold in Font.Style then // font-weight
    Result := Result + 'bold '
  else
    Result := Result + 'normal ';
  Result := Result + intToStr(Font.Size) + 'pt '; // font-size
  Result := Result + 'normal '; // line-height
  Result := Result + // font-family
    Font.Name + ', Tahoma, Verdana, Arial, sans-serif; ';
  Result := Result + 'text-decoration: none;'; // decoration
end;

procedure THistoryGrid.SaveStart(Stream: TFileStream; SaveFormat: TSaveFormat; Caption: String);
var
  ProfileID, ContactID, Proto: String;

  procedure SaveHTML;
  var
    title, head1, head2: AnsiString;
    i: Integer;
  begin
    title := UTF8Encode(WideFormat('%s [%s] - [%s]', [Caption, ProfileName, ContactName]));
    head1 := UTF8Encode(WideFormat('%s', [Caption]));
    head2 := UTF8Encode(WideFormat('%s (%s: %s) - %s (%s: %s)', [ProfileName, Proto, ProfileID,
      ContactName, Proto, ContactID]));
    WriteString(Stream, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
      + #13#10);
    if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and Options.RTLEnabled) then
      WriteString(Stream, '<html dir="rtl">')
    else
      WriteString(Stream, '<html dir="ltr">');
    WriteString(Stream, '<head>' + #13#10);
    WriteString(Stream, '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
      + #13#10);
    WriteString(Stream, '<title>' + MakeTextHtmled(title) + '</title>' + #13#10);
    WriteString(Stream, '<style type="text/css"><!--' + #13#10);
    WriteString(Stream, css);

    if (RTLMode = hppRTLEnable) or ((RTLMode = hppRTLDefault) and Options.RTLEnabled) then
    begin
      WriteString(Stream, '.nick { float: right; }' + #13#10);
      WriteString(Stream, '.date { float: left; clear: left; }' + #13#10);
    end
    else
    begin
      WriteString(Stream, '.nick { float: left; }' + #13#10);
      WriteString(Stream, '.date { float: right; clear: right; }' + #13#10);
    end;
    WriteString(Stream, '.nick#inc { ' + FontToCss(Options.FontContact) + ' }' + #13#10);
    WriteString(Stream, '.nick#out { ' + FontToCss(Options.FontProfile) + ' }' + #13#10);
    WriteString(Stream, '.date#inc { ' + FontToCss(Options.FontIncomingTimestamp) + ' }'
      + #13#10);
    WriteString(Stream, '.date#out { ' + FontToCss(Options.FontOutgoingTimestamp) + ' }'
      + #13#10);
    WriteString(Stream, '.url { color: ' + ColorToCss(Options.ColorLink) + '; }' + #13#10);
    for i := 0 to High(Options.ItemOptions) do
      WriteString(Stream, AnsiString('.mes#event' + intToStr(i) + ' { background-color: ' +
        ColorToCss(Options.ItemOptions[i].textColor) + '; ' + FontToCss(Options.ItemOptions[i].textFont) + ' }' + #13#10));
    if ShowHeaders then
      WriteString(Stream, '.mes#session { background-color: ' +
        ColorToCss(Options.ColorSessHeader) + '; ' + FontToCss(Options.FontSessHeader) + ' }'
        + #13#10);
    WriteString(Stream, '--></style>' + #13#10 + '</head><body>' + #13#10);
    WriteString(Stream, '<h4>' + MakeTextHtmled(head1) + '</h4>' + #13#10);
    WriteString(Stream, '<h3>' + MakeTextHtmled(head2) + '</h3>' + #13#10);
  end;

  procedure SaveXML;
  var
    mt: TMessageType;
    Messages, enc: String;
  begin
    // enc := 'windows-'+IntToStr(GetACP);
    enc := 'utf-8';
    Messages := '';
    for mt := Low(EventRecords) to High(EventRecords) do
    begin
      if not(mt in EventsDirection + EventsExclude) then
        Messages := Messages + Format('<!ENTITY %s "%s">' + #13#10,
          [EventRecords[mt].xml, UTF8Encode(TranslateUnicodeString(EventRecords[mt].Name))
          ] { TRANSLATE-IGNORE } );
    end;
    WriteString(Stream, AnsiString(Format(xml, [enc, UTF8Encode(ProfileName), Messages])));
  end;

  procedure SaveUnicode;
  begin
    WriteString(Stream, #255#254);
    WriteWideString(Stream, '###'#13#10);
    if Caption = '' then
      Caption := TxtHistExport;
    WriteWideString(Stream, WideFormat('### %s'#13#10, [Caption]));
    WriteWideString(Stream, WideFormat('### %s (%s: %s) - %s (%s: %s)'#13#10,
      [ProfileName, Proto, ProfileID, ContactName, Proto, ContactID]));
    WriteWideString(Stream, TxtGenHist1 + #13#10);
    WriteWideString(Stream, '###'#13#10#13#10);
  end;

  procedure SaveText;
  begin
    WriteString(Stream, '###'#13#10);
    if Caption = '' then
      Caption := TxtHistExport;
    WriteString(Stream, WideToAnsiString(WideFormat('### %s'#13#10, [Caption]), Codepage));
    WriteString(Stream, WideToAnsiString(WideFormat('### %s (%s: %s) - %s (%s: %s)'#13#10,
      [ProfileName, Proto, ProfileID, ContactName, Proto, ContactID]), Codepage));
    WriteString(Stream, WideToAnsiString(TxtGenHist1 + #13#10, Codepage));
    WriteString(Stream, '###'#13#10#13#10);
  end;

  procedure SaveRTF;
  begin
    FRichSaveItem := THPPRichEdit.CreateParented(Handle);
    FRichSave := THPPRichEdit.CreateParented(Handle);
    FRichSaveOLECB := TRichEditOleCallback.Create(FRichSave);
    FRichSave.Perform(EM_SETOLECALLBACK, 0,
      lParam(TRichEditOleCallback(FRichSaveOLECB) as IRichEditOleCallback));
  end;

  procedure SaveMContacts;
  begin
    mcHeader.DataSize := 0;
    Stream.Write(mcHeader, SizeOf(mcHeader))
  end;

begin
  Proto := AnsiToWideString(Protocol, Codepage);
  ProfileID := AnsiToWideString(GetContactID(0, Protocol, False), Codepage);
  ContactID := AnsiToWideString(GetContactID(Contact, Protocol, True), Codepage);
  case SaveFormat of
    sfHTML:
      SaveHTML;
    sfXML:
      SaveXML;
    sfMContacts:
      SaveMContacts;
    sfRTF:
      SaveRTF;
    sfUnicode:
      SaveUnicode;
    sfText:
      SaveText;
  end;
end;

procedure THistoryGrid.SaveEnd(Stream: TFileStream; SaveFormat: TSaveFormat);

  procedure SaveHTML;
  begin
    WriteString(Stream, '<div class=mes></div>' + #13#10);
    WriteString(Stream, UTF8Encode(TxtGenHist2) + #13#10);
    WriteString(Stream, '</body></html>');
  end;

  procedure SaveXML;
  begin
    WriteString(Stream, '</IMHISTORY>');
  end;

  procedure SaveUnicode;
  begin;
  end;

  procedure SaveText;
  begin;
  end;

  procedure SaveRTF;
  begin
    FRichSave.Lines.SaveToStream(Stream);
    FRichSave.Perform(EM_SETOLECALLBACK, 0, 0);
    FRichSave.Destroy;
    FRichSaveItem.Destroy;
    FRichSaveOLECB.Free;
  end;

  procedure SaveMContacts;
  begin
    Stream.Seek(SizeOf(mcHeader) - SizeOf(mcHeader.DataSize), soFromBeginning);
    Stream.Write(mcHeader.DataSize, SizeOf(mcHeader.DataSize));
  end;

begin
  case SaveFormat of
    sfHTML:      SaveHTML;
    sfXML:       SaveXML;
    sfRTF:       SaveRTF;
    sfMContacts: SaveMContacts;
    sfUnicode:   SaveUnicode;
    sfText:      SaveText;
  end;
end;

procedure THistoryGrid.SaveItem(Stream: TFileStream; Item: Integer; SaveFormat: TSaveFormat);

  procedure MesTypeToStyle(mt: TMessageTypes; out mes_id, type_id: AnsiString);
  var
    i: Integer;
    Found: Boolean;
  begin
    mes_id := 'unknown';
    if mtIncoming in mt then
      type_id := 'inc'
    else
      type_id := 'out';
    i := 0;
    Found := False;
    while (not Found) and (i <= High(Options.ItemOptions)) do
      if (MessageTypesToDWord(Options.ItemOptions[i].MessageType) and MessageTypesToDWord(mt))
        >= MessageTypesToDWord(mt) then
        Found := True
      else
        Inc(i);
    mes_id := 'event' + intToStr(i);
  end;

  procedure SaveHTML;
  var
    mes_id, type_id: AnsiString;
    nick, Mes, Time: String;
    txt: AnsiString;
    FullHeader: Boolean;
  begin
    MesTypeToStyle(FItems[Item].MessageType, mes_id, type_id);
    FullHeader := not(FGroupLinked and FItems[Item].LinkedToPrev);
    if FullHeader then
    begin
      Time := GetTime(Items[Item].Time);
      if mtIncoming in FItems[Item].MessageType then
        nick := ContactName
      else
        nick := ProfileName;
      if Assigned(FGetNameData) then
        FGetNameData(Self, Item, nick);
      nick := nick + ':';
    end;
    Mes := FItems[Item].Text;
    if Options.RawRTFEnabled and IsRTF(FItems[Item].Text) then
    begin
      ApplyItemToRich(Item);
      Mes := GetRichString(FRich.Handle, False);
    end;
    txt := MakeTextHtmled(UTF8Encode(Mes));
    try
      txt := UrlHighlightHtml(txt);
    except
    end;
    if Options.BBCodesEnabled then
    begin
      try
        txt := DoSupportBBCodesHTML(txt);
      except
      end;
    end;
    if ShowHeaders and FItems[Item].HasHeader then
    begin
      WriteString(Stream, '<div class=mes id=session>' + #13#10);
      WriteString(Stream, #9 + '<div class=text>' +
        MakeTextHtmled(UTF8Encode(WideFormat(TxtSessions, [Time]))) + '</div>' + #13#10);
      WriteString(Stream, '</div>' + #13#10);
    end;
    WriteString(Stream, '<div class=mes id=' + mes_id + '>' + #13#10);
    if FullHeader then
    begin
      WriteString(Stream, #9 + '<div class=nick id=' + type_id + '>' +
        MakeTextHtmled(UTF8Encode(nick)) + '</div>' + #13#10);
      WriteString(Stream, #9 + '<div class=date id=' + type_id + '>' +
        MakeTextHtmled(UTF8Encode(Time)) + '</div>' + #13#10);
    end;
    WriteString(Stream, #9 + '<div class=text>' + #13#10#9 + txt + #13#10#9 + '</div>'
      + #13#10);
    WriteString(Stream, '</div>' + #13#10);
  end;

  procedure SaveXML;
  var
    XmlItem: TXMLItem;
  begin
    if not Assigned(FGetXMLData) then
      exit;
    FGetXMLData(Self, Item, XmlItem);
    WriteString(Stream, '<EVENT>' + #13#10);
    WriteString(Stream, #9 + '<CONTACT>' + XmlItem.Contact + '</CONTACT>' + #13#10);
    WriteString(Stream, #9 + '<FROM>' + XmlItem.From + '</FROM>' + #13#10);
    WriteString(Stream, #9 + '<TIME>' + XmlItem.Time + '</TIME>' + #13#10);
    WriteString(Stream, #9 + '<DATE>' + XmlItem.Date + '</DATE>' + #13#10);
    WriteString(Stream, #9 + '<PROTOCOL>' + XmlItem.Protocol + '</PROTOCOL>' + #13#10);
    WriteString(Stream, #9 + '<ID>' + XmlItem.ID + '</ID>' + #13#10);
    WriteString(Stream, #9 + '<TYPE>' + XmlItem.EventType + '</TYPE>' + #13#10);
    if XmlItem.Mes <> '' then
      WriteString(Stream, #9 + '<MESSAGE>' + XmlItem.Mes + '</MESSAGE>' + #13#10);
    if XmlItem.FileName <> '' then
      WriteString(Stream, #9 + '<FILE>' + XmlItem.FileName + '</FILE>' + #13#10);
    if XmlItem.Url <> '' then
      WriteString(Stream, #9 + '<URL>' + XmlItem.Url + '</URL>' + #13#10);
    WriteString(Stream, '</EVENT>' + #13#10);
  end;

  procedure SaveUnicode;
  var
    nick, Mes, Time: String;
    FullHeader: Boolean;
  begin
    FullHeader := not(FGroupLinked and FItems[Item].LinkedToPrev);
    if FullHeader then
    begin
      Time := GetTime(FItems[Item].Time);
      if mtIncoming in FItems[Item].MessageType then
        nick := ContactName
      else
        nick := ProfileName;
      if Assigned(FGetNameData) then
        FGetNameData(Self, Item, nick);
    end;
    Mes := FItems[Item].Text;
    if Options.RawRTFEnabled and IsRTF(Mes) then
    begin
      ApplyItemToRich(Item);
      Mes := GetRichString(FRich.Handle, False);
    end;
    if Options.BBCodesEnabled then
      Mes := DoStripBBCodes(Mes);
    if FullHeader then
      WriteWideString(Stream, WideFormat('[%s] %s:'#13#10, [Time, nick]));
    WriteWideString(Stream, Mes + #13#10 + #13#10);
  end;

  procedure SaveText;
  var
    Time: AnsiString;
    nick, Mes: String;
    FullHeader: Boolean;
  begin
    FullHeader := not(FGroupLinked and FItems[Item].LinkedToPrev);
    if FullHeader then
    begin
      Time := WideToAnsiString(GetTime(FItems[Item].Time), Codepage);
      if mtIncoming in FItems[Item].MessageType then
        nick := ContactName
      else
        nick := ProfileName;
      if Assigned(FGetNameData) then
        FGetNameData(Self, Item, nick);
    end;
    Mes := FItems[Item].Text;
    if Options.RawRTFEnabled and IsRTF(Mes) then
    begin
      ApplyItemToRich(Item);
      Mes := GetRichString(FRich.Handle, False);
    end;
    if Options.BBCodesEnabled then
      Mes := DoStripBBCodes(Mes);
    if FullHeader then
      WriteString(Stream, AnsiString(Format('[%s] %s:'#13#10, [Time, nick])));
    WriteString(Stream, WideToAnsiString(Mes, Codepage) + #13#10 + #13#10);
  end;

  procedure SaveRTF;
  var
    RTFStream: AnsiString;
    Text: String;
    FullHeader: Boolean;
  begin
    FullHeader := not(FGroupLinked and FItems[Item].LinkedToPrev);
    if FullHeader then
    begin
      if mtIncoming in FItems[Item].MessageType then
        Text := ContactName
      else
        Text := ProfileName;
      if Assigned(FGetNameData) then
        FGetNameData(Self, Item, Text);
      Text := Text + ' [' + GetTime(FItems[Item].Time) + ']:';
      RTFStream := '{\rtf1\par\b1 ' + FormatString2RTF(Text) + '\b0\par}';
      SetRichRTF(FRichSave.Handle, RTFStream, True, False, False);
    end;
    ApplyItemToRich(Item, FRichSaveItem, True);
    GetRichRTF(FRichSaveItem.Handle, RTFStream, False, False, False, False);
    SetRichRTF(FRichSave.Handle, RTFStream, True, False, False);
  end;

  procedure SaveMContacts;
  var
    MCItem: TMCItem;
  begin
    if not Assigned(FGetMCData) then
      exit;
    FGetMCData(Self, Item, MCItem, ssInit);
    Stream.Write(MCItem.Buffer^, MCItem.Size);
    FGetMCData(Self, Item, MCItem, ssDone);
    Inc(mcHeader.DataSize, MCItem.Size);
  end;

begin
  LoadItem(Item, False);
  case SaveFormat of
    sfHTML:
      SaveHTML;
    sfXML:
      SaveXML;
    sfRTF:
      SaveRTF;
    sfMContacts:
      SaveMContacts;
    sfUnicode:
      SaveUnicode;
    sfText:
      SaveText;
  end;
end;

procedure THistoryGrid.WriteString(fs: TFileStream; Text: AnsiString);
begin
  fs.Write(Text[1], Length(Text));
end;

procedure THistoryGrid.WriteWideString(fs: TFileStream; Text: String);
begin
  fs.Write(Text[1], Length(Text) * SizeOf(Char));
end;
