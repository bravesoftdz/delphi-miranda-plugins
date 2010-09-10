{$IFNDEF M_NCONVERS}
{$DEFINE M_NCONVERS}

// replace smiley tags in a rich edit control... 
// wParam = (WPARAM) 0; not used
// lParam = (LPARAM) (NCONVERS_GETICON*) &ncgi;
// return: TRUE if found, FALSE if not

typ
  PNCONVERS_GETICON = ^NCONVERS_GETICON;
  NCONVERS_GETICON = record
    cbSize        :int;   // = sizeof(NCONVERS_GETSMILEY)
    Protocolname  :PAnsiChar; // NULL means 'default'
    SmileySequence:PAnsiChar; // character string containing the smiley 
    SmileyIcon    :HICON; // RETURN VALUE: this is filled with the icon handle... 
                          // do not destroy!
    Smileylength  :int;   // length of the smiley that is found.
  end;

const
 MS_NCONVERS_GETSMILEYICON = 'nConvers/GetSmileyIcon';

{$ENDIF}
