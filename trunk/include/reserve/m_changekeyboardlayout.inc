{$IFNDEF M_CHANGEKEYBOARDLAYOUT}
{$DEFINE M_CHANGEKEYBOARDLAYOUT}

const
// change keyboard layout of text
// wParam, lParam must be 0
// returns 0 on success and returns non-zero (-1) on error.
  MS_CKL_CHANGELAYOUT 'ChangeKeyboardLayout/ChangeLayout';

{$ENDIF}
