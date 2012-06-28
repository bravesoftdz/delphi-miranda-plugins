{
Header file for Miranda plugin developers, which allows you to use AutoLocale with your windowed
plugins. Just call service function "AutoLocale/ChangeLocale"

Author Ni4 (Nickolay L. Olshevsky) , Kiev, Ukraine.
All suggestions, wishes, bug reports please send to dark.ni4@ukr.net.
}
{$IFNDEF M_AUTOLOCALE}
{$DEFINE M_AUTOLOCALE}
{
 Now here is only one function, which allows you to change locale for current user.
 Must be called on WM_ACTIVATE message, for windows which represents messaging sessions.

 Parameters:
  wParam - (WPARAM) of contact identifier in database.
  lParam - doesn't matter.

 Return values:
  last watched user handle.
}
const
  MS_AUTOLOCALE_CHANGELOCALE = 'AutoLocale/ChangeLocale';
{$ENDIF}
