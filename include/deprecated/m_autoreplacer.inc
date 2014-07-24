{
  AutoReplacer plugin
  by Angelo Luiz Tartari
}

{$IFNDEF M_AUTOREPLACER}
{$DEFINE M_AUTOREPLACER}

const

{
  Adds a window handle to AutoReplacer.
  This handle must belong to any window based on a editbox (editbox, richtext, TMemo, TEdit, TMaskEdit, etc.).
  After adding a handle, AutoReplacer will automatically work on this window.
  wParam = 0
  lParam = (LPARAM)(HWND)hwnd
  Returns: 0 on success, -1 if hwnd is invalid, 1 on error.
}
  MS_AUTOREPLACER_ADDWINHANDLE:PAnsiChar = 'AutoReplacer/AddWinHandle';

{
  Removes a window handle from AutoReplacer's list.
  wParam = 0
  lParam = (LPARAM)(HWND)hwnd
  Returns: 0 on success, -1 if hwnd is invalid, 1 if hwnd wasn't found.
}
  MS_AUTOREPLACER_REMWINHANDLE:PAnsiChar = 'AutoReplacer/RemWinHandle';

{$ENDIF}