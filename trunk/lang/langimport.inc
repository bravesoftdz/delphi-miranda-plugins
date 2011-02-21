{}
(*
Here is main function to read Langpack from XML file.
Really, it can be adopted to presented INI-like file.
Just introduce some special "plugin section" separators
*)
// mean, filename is Ansi, XML content is unicode
// sort by hash - inside one "group"
function LoadLangPackXML(const fname:PAnsiChar):int;
var
  f:THANDLE;
  i,
  plgnnum,          // cycle, current plugin number (in langpack)
  nodenum,          // cycle, current node(line) number in group
  plugnum:integer;  // amount of registered plugins
  res:pWideChar;
  root,node,actnode:HXML;
  xmlparser:XML_API_W;
  linenum:integer;  // total loaded lines amount
  ld:integer;
begin
  result:=0;
  i:=GetFSize(fname);
  if i=0 then
    exit;
  mGetMem (res ,i+SizeOf(WideChar));
  FillChar(res^,i+SizeOf(WideChar),0);
  f:=Reset(fname);
  BlockRead(f,res^,i);
  CloseHandle(f);

  xmlparser.cbSize:=SizeOf(XML_API_W);
  CallService(MS_SYSTEM_GET_XI,0,dword(@xmlparser));
  with xmlparser do
  begin
    root:=parseString(ChangeUnicode(res),@i,nil);
    //----- DESCRIPTION section -----
    actnode:=getNthChild(root,'Description',0);
    if actnode<>0 then
    begin
      node:=getNthChild(actnode,'Language',0);
      FastWideToAnsi(GetText(node),langpack.Language);
      node:=getNthChild(actnode,'Last-Modified-Using',0);
      FastWideToAnsi(GetText(node),langpack.lastModifiedUsing);
      node:=getNthChild(actnode,'Authors',0);
      FastWideToAnsi(GetText(node),langpack.authors);
      node:=getNthChild(actnode,'Author-email',0);
      FastWideToAnsi(GetText(node),langpack.authorEmail);
      node:=getNthChild(actnode,'Locale',0);
{
			char szBuf[20], *stopped;

			lrtrim(pszColon + 1);
			langID = (USHORT)strtol(pszColon + 1, &stopped, 16);
			langPack.localeID := MAKELCID(langID, 0);
			GetLocaleInfoA(langPack.localeID, LOCALE_IDEFAULTANSICODEPAGE, szBuf, 10);
			szBuf[5]:=#0;                       // codepages have max. 5 digits
			langPack.defaultANSICp = StrToInt(szBuf);
}
    end;
    
    ld:=-1;
    linenum:=0;
    //----- COMMON section -----
    actnode:=getNthChild(root,'Common',0);
    if actnode<>0 then
    begin
      ld:=RegisterLangPlugin(0,0);
      begin
        nodenum:=0;
        repeat
          node:=getNthChild(actnode,'string',nodenum);
          if node=0 then
            break;
          AddLine(ld,getAttrValue(node,'text'),getAttrValue(node,'translate'));
          inc(linenum);
          inc(nodenum);
        until false;
// realized in RegisterLangPlugin and MakeGlobalHashes
//        LangDirectory[0].pend:=linenum-1; // close langpack common part ^_^
      end;
    end;

    //----- PLUGINS section -----
    if ld=0 then // all ok
    begin
      plgnnum:=0;
      plugnum:=0;
      repeat
        actnode:=getNthChild(root,'Plugin',plgnnum);
        if actnode=0 then break;
        inc(plgnnum);
        // register plugin start. "true", if we need this plugin
        ld:=RegisterLangPlugin(linenum,dword(getAttrValue(actnode,'uuid')));
        if ld>0 then
        begin
          inc(plugnum);
          nodenum:=0;
          repeat
            node:=getNthChild(actnode,'string',nodenum);
            if node=0 then
              break;
            AddLine(ld,getAttrValue(node,'text'),getAttrValue(node,'translate'));
            inc(linenum);
            inc(nodenum);
          until false;
// realized in RegisterLangPlugin and MakeGlobalHashes
//          LangDirectory[plgnum].pend:=linenum-1; // close langpack plugin part ^_^
        end;
      until false;
    end;

    DestroyNode(root);
  end;
  mFreeMem(res);
  MakeGlobalHashes(linenum-1);
end;

function LoadLangPack(const fname:PAnsiChar):int;
var
  sl:PWStrList;
  sla:PStrList;
  i,ld:integer;
  linenum:integer;
begin
  result:=0;
  sla:=NewStrList;
  sla.LoadFromFile(fname);
  i:=0;
  RegisterLangPlugin(0,0);
  linenum:=0;
  ld:=0;
  while i<sla.Count do
  begin
    // next plugin
    if (sla.ItemPtrs[i][0]=';') and (sla.ItemPtrs[i][1]='{') then
    begin
      ld:=RegisterLangPlugin(linenum,dword(sla.ItemPtrs[i])+1);
      if ld>0 then
      begin
      end;
    end
    // next string
    else if sla.ItemPtrs[i][0]='[' then
    begin
      (StrEnd(sla.ItemPtrs[i])-1)^:=#0;
      AddLine(ld,sla.ItemPtrs[i]+1,sla.ItemPtrs[i+1]);
      inc(linenum);
      inc(i);
    end;

    inc(i);
  end;

  sla.Free;
  MakeGlobalHashes(linenum-1);

end;
