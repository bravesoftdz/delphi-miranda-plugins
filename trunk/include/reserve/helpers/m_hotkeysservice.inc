{$IFNDEF M_HOTKEYSSERVICE}
{$DEFINE M_HOTKEYSSERVICE}

const
  HKS_SERVICE_NAME = 'HotkeysService';

// Modifiers for hotkeys
//  MOD_ALT     = $0001;
//  MOD_CONTROL = $0002;
//  MOD_SHIFT   = $0004;
//  MOD_WIN     = $0008;
  MOD_GLOBAL = $0010;

// FLAGS
// inherit modifiers from group (specified modifiers ignored)
  HKS_ACTION_SHAREMODIFIERS = 1;
// register item, but disable
  HKS_INITIALLY_DISABLED = 2;

// Structure of hotkey
type
  PHKSHotkey = ^THKSHotkey;
  THKSHotkey = record
    case boolean of
      false: (
        key      :WORD;
        modifiers:WORD;);
      true: (hotkey:DWORD)
  end;

const
// ITEM TYPES
  HKS_ITEM_MODULE = 1;
  HKS_ITEM_GROUP  = 2;
  HKS_ITEM_ACTION = 3;
  HKS_ITEM_MACRO  = 4;

// Structure passed to RegisterItem service.
// Used only for registration pursposes, so free it after call.
// name, owner and itemType field is mandatory.
// owner is item ID or must be 0 for 1st level items (module, single action or macro)
// itemType can be one of ITEM TYPES constants.
// flags can be combined from FLAGS constants.
// Group can contain other groups and items and optionally
//   set group modifiers. Only item can be tree leaf.
// If creating group, hotkey.modifiers will be used
//   as group modifiers (if nonzero)
// If creating action, hotkey is optional. If hotkey.key is filled, then
//   hotkey will be assigned to item (if unused).
// If creating macro, hotkey is mandatory.

type
  PHKSItem = ^THKSItem;
  THKSItem = record
    owner   :int;
    name    :PAnsiChar;
    itemType:int;
    hotkey  :THKSHotkey;
    flags   :int;
  end;

const
{
 Register item
 wParam: item data in PKHSItem format
 lParam: 0
 Returns HANDLE called "ID" in loWord.
   For actions and macros, hiWord returns state: 0 if ok, other if passed hotkey
     can't be registered (for example already used)
   In other cases hiWord is useless
}
  MS_HKS_REGISTER_ITEM = 'HotkeysService/RegisterItem';

{
 Unregister item
 If item is Group, then all subItems will be unregistered.
 wParam: item ID
 lParam: 0
 Returns: 0 on success, other on fail
}
  MS_HKS_UNREGISTER_ITEM = 'HotkeysService/UnregisterItem';

{
 Assign hotkey to item. If item is group, then only
   modifiers are taken as group modifiers. Do not call on modules.
 Hotkey consists of modifiers in hiWord and key in loWord.
 wParam: item ID
 lParam: hotkey as PHKS_Hotkey to register
 Returns:
   on success: hotkey
   on error: 0
}
  MS_HKS_ASSIGN_HOTKEY = 'HotkeysService/AssignHotkey';

{
 Get hotkey assigned to item. Don't apply to modules.
 wParam: item ID
 lParam: 0
 Returns: hotkey assigned, 0 otherwise.
}
  MS_HKS_GET_HOTKEY = 'HotkeysService/GetAssignedHotkey';

{
 Unassign hotkey from item. Only valid on action and macro items.
 wParam: item ID
 lParam: 0
 Returns: 0 on success, other on fail
}
  MS_HKS_UNASSIGN_HOTKEY = 'HotkeysService/UnassignHotkey';

{
 Enable/Disable item.
 If item is group or module, then all subItems will be affected.
 wParam: item ID
 lParam: 1 to enable, anything else to disable
 Returns: 0 on success, other on fail
}
  MS_HKS_ENABLE_ITEM = 'HotkeysService/EnableItem';

{
 Hotkey to text
 wParam: hotkey to textify
 lParam: address to place string, space must be allocated
 Returns: 0
}
  MS_HKS_TO_TEXT = 'HotkeysService/HotkeyToText';

{
 Get hotkey from text
 wParam: text to convert to hotkey
 lParam: 0
 Returns: hotkey
}
  MS_HKS_FROM_TEXT = 'HotkeysService/HotkeyFromText';

type
  PHKSEvent = ^TTHKSEvent;
  THKSEvent = record
    itemId  :int;
    moduleId:int;
    name    :PAnsiChar;
    itemType:int;
    hotkey  :THKSHotkey;
  end;	

const
{
 Event when hotkey is pressed
 wParam: PHKSEvent
 lParam: 0
}
  ME_HKS_KEY_PRESSED = 'HotkeysService/HotkeyPressed';

// Util functions ////////////////////////////////////////////////////////////////////////
(*
static int HKS_RegisterModule(AnsiChar *name)
{
	THKSItem item = {0};
	
	if (!ServiceExists(MS_HKS_REGISTER_ITEM))
		return -1;
	
	item.name = name;
	item.itemType = HKS_ITEM_MODULE;

	return LOWORD(CallService(MS_HKS_REGISTER_ITEM, (WPARAM) &item, 0));
}


static int HKS_RegisterAction(int owner, AnsiChar *name, int modifiers, AnsiChar key, int flags)
{
	THKSItem item = {0};
	
	if (!ServiceExists(MS_HKS_REGISTER_ITEM))
		return -1;
	
	item.owner = owner;
	item.name = name;
	item.itemType = HKS_ITEM_ACTION;
	item.flags = flags;

	if (key != 0)
	{
		item.hotkey.key = (WORD) key;
		item.hotkey.modifiers = modifiers;
	}

	return LOWORD(CallService(MS_HKS_REGISTER_ITEM, (WPARAM) &item, 0));
}


static int HKS_RegisterGroup(int owner, AnsiChar *name, int modifiers, int flags)
{
	THKSItem item = {0};
	
	if (!ServiceExists(MS_HKS_REGISTER_ITEM))
		return -1;
	
	item.owner = owner;
	item.name = name;
	item.itemType = HKS_ITEM_GROUP;
	item.flags = flags;
	item.hotkey.modifiers = modifiers;

	return LOWORD(CallService(MS_HKS_REGISTER_ITEM, (WPARAM) &item, 0));
}

static int HKS_Unregister(int id)
{
	THKSItem item = {0};
	
	if (!ServiceExists(MS_HKS_UNREGISTER_ITEM))
		return -1;
	
	return CallService(MS_HKS_UNREGISTER_ITEM, (WPARAM) id, 0);
}
*)
{$ENDIF}
