function MakeTextXMLedA(const Text: AnsiString): AnsiString;
function MakeTextXMLedW(const Text: WideString): WideString;
function MakeFileName(const FileName: String): String;

function MakeTextXMLedA(const Text: AnsiString): AnsiString;
begin;
  Result := Text;
  Result := AnsiString(
    StringReplace(
      StringReplace(
        StringReplace(
          StringReplace(
            StringReplace(
              string(Result),'‘','&apos;',[rfReplaceAll]),
          '“','&quot;',[rfReplaceAll]),
        '<','&lt;',[rfReplaceAll]),
      '>','&gt;',[rfReplaceAll]),
    '&','&amp;',[rfReplaceAll]));
end;

function MakeTextXMLedW(const Text: WideString): WideString;
begin;
  Result := Text;
  Result := StringReplace(Result,'&','&amp;',[rfReplaceAll]);
  Result := StringReplace(Result,'>','&gt;',[rfReplaceAll]);
  Result := StringReplace(Result,'<','&lt;',[rfReplaceAll]);
  Result := StringReplace(Result,'“','&quot;',[rfReplaceAll]);
  Result := StringReplace(Result,'‘','&apos;',[rfReplaceAll]);
end;

(*
This function gets only name of the file
and tries to make it FAT-happy, so we trim out and
":"-s, "\"-s and so on...
*)
function MakeFileName(const FileName: String): String;
begin
  Result := FileName;
  Result :=
    StringReplace(
      StringReplace(
        StringReplace(
          StringReplace(
            StringReplace(
              StringReplace(
                 StringReplace(
                   StringReplace(
                      StringReplace(
                         Result,'|','' ,[rfReplaceAll]),
                   '>','[',[rfReplaceAll]),
                 '<',']',[rfReplaceAll]),
               '"','''',[rfReplaceAll]),
             '?','_',[rfReplaceAll]),
           '*','_',[rfReplaceAll]),
         '/','_',[rfReplaceAll]),
       '\','_',[rfReplaceAll]),
    ':','_',[rfReplaceAll]);
end;
