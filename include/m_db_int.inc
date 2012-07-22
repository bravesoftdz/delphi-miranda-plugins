{

Miranda NG: the free IM client for Microsoft* Windows*

Copyright 2012 Miranda NG project,
all portions of this codebase are copyrighted to the people
listed in contributors.txt.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}

{$IFNDEF M_DB_INT}
{$DEFINE M_DB_INT}

type
  PMIDatabase = ^TMIDatabase;
  TMIDatabase = interface
    procedure SetCacheSafetyMode(val:bool); stdcall;

    function GetContactCount():long; stdcall;
    function FindFirstContact(const szProto:PAnsiChar = NIL):THANDLE; stdcall;
    function FindNextContact(hContact:THANDLE; const szProto:PAnsiChar = NIL):THANDLE; stdcall;

    function DeleteContact(hContact:THANDLE):long; stdcall;
    function AddContact():THANDLE; stdcall;
    function IsDbContact(hContact:THANDLE):bool; stdcall;

    function GetEventCount(hContact:THANDLE):long; stdcall;
    function AddEvent(hContact:THANDLE; dbe:PDBEVENTINFO):THANDLE; stdcall;
    function DeleteEvent(hContact:THANDLE; hDbEvent:THANDLE):bool; stdcall;
    function GetBlobSize(hDbEvent:THANDLE):long; stdcall;
    function GetEvent(hDbEvent:THANDLE; dbe:PDBEVENTINFO):bool; stdcall;
    function MarkEventRead(hContact:THANDLE; hDbEvent:THANDLE):bool; stdcall;
    function GetEventContact(hDbEvent:THANDLE):THANDLE; stdcall;
    function FindFirstEvent(hContact:THANDLE):THANDLE; stdcall;
    function FindFirstUnreadEvent(hContact:THANDLE):THANDLE; stdcall;
    function FindLastEvent(hContact:THANDLE):THANDLE; stdcall;
    function FindNextEvent(hDbEvent:THANDLE):THANDLE; stdcall;
    function FindPrevEvent(hDbEvent:THANDLE):THANDLE; stdcall;

    function EnumModuleNames(pFunc:TDBMODULEENUMPROC; pParam:pointer):bool; stdcall;

    function GetContactSetting      (hContact:THANDLE; dbcgs:PDBCONTACTGETSETTING):bool; stdcall;
    function GetContactSettingStr   (hContact:THANDLE; dbcgs:PDBCONTACTGETSETTING):bool; stdcall;
    function GetContactSettingStatic(hContact:THANDLE; dbcgs:PDBCONTACTGETSETTING):bool; stdcall;
    function FreeVariant(dbv:PDBVARIANT):bool; stdcall;
    function WriteContactSetting (hContact:THANDLE; dbcws:PDBCONTACTWRITESETTING):bool; stdcall;
    function DeleteContactSetting(hContact:THANDLE; dbcgs:PDBCONTACTGETSETTING):bool; stdcall;
    function EnumContactSettings (hContact:THANDLE; dbces:PDBCONTACTENUMSETTINGS):bool; stdcall;
    function SetSettingResident  (bIsResident:bool; const pszSettingName:PAnsiChar):bool; stdcall;
    function EnumResidentSettings(pFunc:TDBMODULEENUMPROC; pParam:pointer):bool; stdcall;
  end;

type
  PDATABASELINK = ^TDATABASELINK;
  TDATABASELINK = record
    cbSize : int;
    szShortName:PAnsiChar;  // uniqie short database name
    szFullName:TChar;  // in English, auto-translated by the core
    {
      profile: pointer to a string which contains full path + name
      Affect: The database plugin should create the profile, the filepath will not exist at
        the time of this call, profile will be C:\..\<name>.dat
      Returns: 0 on success, non zero on failure - error contains extended error information, see EMKPRF_
    }
    makeDatabase : function (const profile:TChar; error:Pint):int; cdecl;
    {
      profile: [in] a null terminated string to file path of selected profile
      error: [in/out] pointer to an int to set with error if any
      Affect: Ask the database plugin if it supports the given profile, if it does it will
        return 0, if it doesnt return 1, with the error set in error -- EGROKPRF_  can be valid error
        condition, most common error would be [EGROKPRF_UNKHEADER]
      Note: Just because 1 is returned, doesnt mean the profile is not supported, the profile might be damaged
        etc.
      Returns: 0 on success, non zero on failure
    }
    grokHeader : function (const profile:TChar; error:Pint):int; cdecl;
    {
      Affect: Tell the database to create all services/hooks that a 3.xx legecy database might support into link
      Returns: 0 on success, nonzero on failure
    }
    Load : function (const profile:TChar):PMIDatabase; cdecl;
    {
      Affect: The database plugin should shutdown, unloading things from the core and freeing internal structures
      Returns: 0 on success, nonzero on failure
      Note: Unload() might be called even if Load() was never called, wasLoaded is set to 1 if Load() was ever called.
    }
    Unload : function (db:PMIDatabase):int; cdecl;
  end;

///////////////////////////////////////////////////////////////////////////////
// Database list's services

const
{
  MS_DB_REGISTER_PLUGIN : registers a database plugin
  wParam : 0 (unused)
  lParam : DATABASELINK* = database link description
}
  MS_DB_REGISTER_PLUGIN:PAnsiChar = 'DB/RegisterPlugin';

{
  MS_DB_FIND_PLUGIN : looks for a database plugin suitable to open this file
  wParam : 0 (unused)
  lParam : const TCHAR* = name of the database file
  returns DATABASELINK* of the required plugin or NULL on error
}
  MS_DB_FIND_PLUGIN:PAnsiChar = 'DB/FindPlugin';

{$ENDIF}