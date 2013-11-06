(*
    History++ plugin for Miranda IM: the free IM client for Microsoft* Windows*

    Copyright (C) 2006-2009 theMIROn, 2003-2006 Art Fedorov.
    History+ parts (C) 2001 Christian Kastner

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

{-----------------------------------------------------------------------------
 hpp_options (historypp project)

 Version:   1.0
 Created:   31.03.2003
 Author:    Oxygen

 [ Description ]

 Options module which has one global options variable and
 manages all options throu all history windows

 [ History ]
 1.0 (31.03.2003) - Initial version

 [ Modifications ]

 [ Knows Inssues ]
 None

 Contributors: theMIROn, Art Fedorov
-----------------------------------------------------------------------------}


unit hpp_options;

interface

uses
  Windows,
  m_api,
  hpp_global;

type
  TSaveFilter = record
    Index: Integer;
    Filter: WideString;
    DefaultExt: WideString;
    Owned: TSaveFormats;
    OwnedIndex: Integer;
  end;

var
  MetaContactsProto: PAnsiChar;
var
  ShowHistoryCount: Boolean;
var
  SaveFormats: array[TSaveFormat] of TSaveFilter;

//!!procedure TranslateSaveFilters;
//!!procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: Boolean = False);

function SmileyAddExists:boolean;
function MathModuleExists:boolean;
function MetaContactsExists:boolean;
function MeSpeakExists:boolean;

implementation

const
  SaveFormatsDef: array[TSaveFormat] of TSaveFilter = (
    (Index: -1; Filter:'All files';         DefaultExt:'*.*'   ; Owned:[]; OwnedIndex: -1),
    (Index: 1;  Filter:'HTML file';         DefaultExt:'*.html'; Owned:[]; OwnedIndex: -1),
    (Index: 2;  Filter:'XML file';          DefaultExt:'*.xml' ; Owned:[]; OwnedIndex: -1),
    (Index: 3;  Filter:'RTF file';          DefaultExt:'*.rtf' ; Owned:[]; OwnedIndex: -1),
    (Index: 4;  Filter:'mContacts files';   DefaultExt:'*.dat' ; Owned:[]; OwnedIndex: -1),
    (Index: 5;  Filter:'Unicode text file'; DefaultExt:'*.txt' ; Owned:[sfUnicode,sfText]; OwnedIndex: 1),
    (Index: 6;  Filter:'Text file';         DefaultExt:'*.txt' ; Owned:[sfUnicode,sfText]; OwnedIndex: 2));

{$include m_mathmodule.inc}
{$include m_speak.inc}

{!!
procedure PrepareSaveDialog(SaveDialog: TSaveDialog; SaveFormat: TSaveFormat; AllFormats: boolean = false);
var
  sf: TSaveFormat;
begin
  SaveDialog.Filter := '';
  if SaveFormat = sfAll then
    SaveFormat := Succ(SaveFormat);
  if AllFormats then
  begin
    for sf := Low(SaveFormats) to High(SaveFormats) do
      if sf <> sfAll then
        SaveDialog.Filter := SaveDialog.Filter + SaveFormats[sf].Filter + '|';
    SaveDialog.FilterIndex := SaveFormats[SaveFormat].Index;
  end
  else
  begin
    if SaveFormats[SaveFormat].Owned = [] then
    begin
      SaveDialog.Filter := SaveFormats[SaveFormat].Filter + '|';
      SaveDialog.Filter := SaveDialog.Filter + SaveFormats[sfAll].Filter;
      SaveDialog.FilterIndex := 1;
    end
    else
    begin
      for sf := Low(SaveFormats) to High(SaveFormats) do
        if sf in SaveFormats[SaveFormat].Owned then
          SaveDialog.Filter := SaveDialog.Filter + SaveFormats[sf].Filter + '|';
      SaveDialog.FilterIndex := SaveFormats[SaveFormat].OwnedIndex;
    end;
  end;
  SaveDialog.DefaultExt := SaveFormats[SaveFormat].DefaultExt;
end;
}
{!!
procedure TranslateSaveFilters;
var
  sf: TSaveFormat;
begin
  for sf := Low(SaveFormatsDef) to High(SaveFormatsDef) do
  begin
    SaveFormats[sf] := SaveFormatsDef[sf];
    SaveFormats[sf].Filter := Format('%s (%s)|%s',
      [TranslateWideString(SaveFormatsDef[sf].Filter),
      SaveFormatsDef[sf].DefaultExt, SaveFormatsDef[sf].DefaultExt]);
  end;
end;
}
function SmileyAddExists:boolean;
begin
  result:=boolean(ServiceExists(MS_SMILEYADD_REPLACESMILEYS));
end;

function MathModuleExists:boolean;
begin
  result:=boolean(ServiceExists(MATH_RTF_REPLACE_FORMULAE));
end;

function MetaContactsExists:boolean;
begin
  result:=boolean(ServiceExists(MS_MC_GETMOSTONLINECONTACT));
  if result then
  begin
    MetaContactsProto:=PAnsiChar(CallService(MS_MC_GETPROTOCOLNAME, 0, 0));
    if not Assigned(MetaContactsProto) then
      result:=false;
  end
  else
    MetaContactsProto:=nil;
end;

function MeSpeakExists:boolean;
begin
  result:=boolean(ServiceExists(MS_SPEAK_SAY_W));
end;

end.
