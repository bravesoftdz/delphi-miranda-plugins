; пример описания лэнгпака
; первая часть - без GUID - общая

;{9584DA04-FB4F-40c1-9325-E4F9CAAFCB5D}
[Contact window]
Окно контакта
[Text insert]
Вставка текста
==============
НЕ РЕАЛИЗОВАНО:
1)построить глобальный хэш (если надо) +сортировка
2)построить список плагинов с их УИДами - 
для плагинозависимого перевода и чтоб убрать лишние секции
------------------------
как несколько УИДов обрабатывать (не реализовано)
1 - 2 comments 1 by 1
;{}
;{}

2 - several in one line
;{}{}
------------------------
примеры врапперов-хелперов:

function TranslateW(sz: PWideChar): PWideChar;
begin
  Result := PWideChar(PluginLink^.CallService(MS_LANGPACK_TRANSLATESTRING,
    LPHandle shl 16 + LANG_UNICODE, lParam(sz)));
end;

function TranslateDialogDefault(hwndDlg: THandle): int;
var
  lptd: TLANGPACKTRANSLATEDIALOG;
begin
  lptd.cbSize         := sizeof(lptd);
  lptd.flags          := 0;
  lptd.hwndDlg        := hwndDlg;
  lptd.ignoreControls := nil;
  Result := PluginLink^.CallService(MS_LANGPACK_TRANSLATEDIALOG, LPHandle shl 16, lParam(@lptd));
end;

единственно, надо будет в хедере объявить переменную (LPHandle в сырцах),
инициализируемую изначально нулем (вариант - вообще использовать не непосредственно её,
а UUID, определенный в PluginInfo

