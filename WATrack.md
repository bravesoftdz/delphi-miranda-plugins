
## Назначение ##
**WATrack** (название произошло от сокращения _WinaAmp track_) - плагин, разработанный для того, чтобы получать и обрабатывать информацию о воспроизводимых в данный момент музыке или видеофильме.

## Основные возможности ##
  * Определение многих аудио- и видеоплееров
  * Определение множества аудио- и видеоформатов
  * Возможность управления плеерами (не всеми)
  * Отображение всплывающих окон про смене трека
  * Установка статусных сообщений по шаблонам
  * Поддержка плагина _Variables_
  * Вставка шаблонных сообщений в окно сообщений
  * Составление статистики и отчета по воспроизводимым файлам
  * Графический _#Фрейм|фрейм_, позволяющий отображать трекбар для текущей позиии, текстовые данные о треке, кнопки управления плеером и "обложку" для трека (диска)

## Особенности работы с другими плагинами ##
WATrack может работать во взаимодействии с некоторыми другими плагинами:
#### _Variables_ ####
В текстовых шаблонах, предназначенных для использования в статусных сообщениях, окнах ввода и пр., могут быть применены скрипты и _#Переменные, используемые в шаблонах|переменные_, образуя тем самым дополнительные возможности для оформления текста. Кроме того, тот же самый механизм может быть использован и для задания шалонов путей для поиска "обложек" к трекам.
#### _NewAwaySystem_ ####
Если этот плагин обнаружен в системе, установка статусов и сообщений происходит через него.
#### _Popup Plus_ ####
В отличие от других плагинов для показа всплывающих окон (например, _YAPP_), во взаимодействии с данным плагином реализована возможность использования кнопок управления плеером, таких же, как и во _#Фрейм|фрейме_
#### [mRadio](mRadio#mRadio.md) или [mRadio Mod](mRadio#mRadio_Mod.md) ####
Взаимодействие с данным плагином заключается в том, что для него, как для плагина, а не самостоятельного плеера, используется несколько иной механизм работы.
#### _ListeningTo_ ####
Этот плагин может использовать в своей работе данные, полученные через WATrack.

## Плееры и форматы ##
### Плееры ###
Список поддерживаемых плееров может быть увеличен двумя способами. Первый из них, для программистов - написать свой плагин-обработчик, используя АПИ, второй - получить класс-текст главного окна и добавить описание плеера в файл player.ini<br />
Формат описания:
```
 [name] Название плеера, как оно будет показано в плагине
 class = класс главного окна плеера
 text = заголовок главного окна плеера (необязательно)
 class1 = альтернативный класс главного окна плеера (необязательно)
 text1 = альтернативный заголовок главного окна плеера (необязательно)
 file = имя файла плеера (если необходимо для идентификации)
 flags = флаги, на данный момент только 8=поддержка Winamp API
 url = URL домашней страницы плеера (необязательно)
```
### Форматы ###

## Переменные, используемые в шаблонах ##
| **макро** | **описание** |
|:----------|:-------------|
| %wndtext% | Текст основного окна плеера|
| %artist%  | Имя исполнителя|
| %title%   | Название композиции|
| %album%   | Альбом       |
| %genre%   | Жанр композиции|
| %file%    | Путь к медиафайлу|
| %kbps%    | Битрейт      |
| %bitrate% | Битрейт      |
| %track%   | Номер трека (в альбоме)|
| %channels% | Количество каналов|
| %mono%    | Тип медиа: "mono"/"stereo"|
| %khz%     | Частота (самплрейт)|
| %samplerate% | Частота (самплрейт)|
| %total%   | Длительность трека, сек|
| %length%  | Длительность трека, сек|
| %year%    | Дата (год) трека (прописанный в теге)|
| %time%    | Текущая позиция при воспроизведении, сек|
| %percent% | %time%/%length% `*` 100%|
| %comment% | Комментарий из тега|
| %player%  | Название плеера|
| %version% | Версия плеера|
| %size%    | Размер медиафайла, байт|
| %type%    | Тип медиафайла (расширение)|
| %vbr%     | VBR или нет (пусто)|
| %status%  | Статус плеера (остановлен, играет, на паузе)|
| %fps%     | FPS - кадров в секунду, только для Видео|
| %codec%   | Видеокодек, только для Видео|
| %width%   | Ширина кадра, только для Видео|
| %height%  | Высота кадра, только для Видео|
| %txtver%  | Версия плеера в текстовом формате|
| %lyric%   | Лирика-текст песни (ID3v2 или ID3v1 теги)|
| %cover%   | Путь к файлу обложки|
| %volume%  | Громкость плеера (0-15)|
| %playerhome% | URL домашней страницы плеера|
| %nstatus% | Статус плеера, аналогично %status%, но без перевода|


## Фрейм ##
_Image:Wat\_frame.png|thumb|80px|right_
Плагины контакт-листа, такие как _Clist Modern Layered_,_Clist Nicer_ и _Clist MW_, позволяют добавлять свое окошко (фрейм). В этом окне может быть размещено фоновое изображение, при неоходимости заменяющееся обложкой воспроизводимого диска (альбома).<br />
Трекбар внизу позволяет следить за текущей позиией трека и осуществлять ее перемещение, если обработчик плеера это поддерживает. Выше находятся кнопки управления плеером: Уменьшить/увеличить громкость (могут отключаться) и "предыдущий трек/воспроизвести с начала/пауза-воспроизведение/остановить/следующий трек".<br />
Верхнюю часть фрейма занимает текст, шаблон которого задается в настройках.
В определенных случаях можно задать выравнивание его по центру или плавное перемещение по горизонтали, если вся строкка не помещается. Фоновую картинку также можно выравнивать по сторонам либо центру фрейма.<br />
При воспроизведении музыки в заголовке трека будет отображаться название и иконка активного плеера.

## Настройки (для версии 0.0.6.9) ##
### Вкладка "Common" / "Общее" ###
_Image:Wat\_tab\_common.png|thumb|right|Общие настройки_
Поле для вводе горячей клавиши предназначено для выбора комбинации клавиш для вставки замененного текста шаблона в окно сообщений.
"Refresh time" / "Время обновления" задает промежуток времени для опроса плееров.<br />
Кодовая страница задает кодировку для трансляции юникодных строк в ANSI и наоборот.<br />
Группа параметров задает общее поведение плагина:
  * _Вставлять в сообщение (Insert in messages)_ - вставлять ли текст в сообщения
  * _Использовать статусы (Use status messages)_ - можно ли заменять текст статусных сообщений
  * _Использовать ХСтатус (Use XStatus)_ -можно ли заменять текст сообщений хСтатуса
  * _Независимый ХСтатус (Independed XStatus_) - повдеение для хСтатуса не зависит от текущего статуса
  * _Использовать перехват процесса (Use process implantation)_ - встраивание в процесс плеера (могут быть проблемы с  файрволом)
  * _Простые шаблоны (Simple Template mode)_ - использовать простой режим шаблонов (см. ниже)
  * _Исп. текущий хСтатус (Use existing XStatus)_ - Не заменять хСтатус на выбранный, а использовать текущий
  * _Только если хСтатус 'Музыка' (Only if 'Music' status was set)_ - Заменять текс хСтатуса, только если он установлен в выбранный для музыки / видео
  * _Оставлять хСтатус 'Музыка' (Keep 'Music' XStatus)_ - при окончании воспроизведения медиафайла не возвращать предыдущий статус
  * _Заменять "_" пробелами (Replace underlines with spaces)_- подчеркивания в названиях альбома, артиста и пр. будут заменены на пробелы
  *_Проверять время файла (Check file time)_- при проверке проверять не только имя воспроизводимого файла, но и его время для отслеживания изменений
  *_Проверять в другом потоке (Other thread handle check)_- некоторое замедление проверки, но позволяет избежать зависаний при работе с некоторыми плеерами
  *_Сохранять старый файл (Keep old file)_- По-умолчанию, проверяется использование плеером нового файла. Если опция установлена, то сигналом смены трека будет не появление нового, а исчезновение старого - пригодно при сканировании списка воспроизведения.
  *_(Clear xStatus before set new one)_- При изменении текста для хСтатуса, тот сперва сбрасывается в "нет", а потом восстанавливается с новым текстом. (необходимо для избежания блокировки изменения текста хСтатуса сервером ICQ)_

### Вкладка "Templates" / "Шаблоны" ###
_Image:Wat\_tab\_tmpl2e.png|thumb|left|Простые шаблоны__Image:Wat\_tab\_tmpl1f.png|thumb|right|Расширенные шаблоны_
Реально, эта вкладка может представляться в упрощенном или расширенном режимах. Ниже даны отдельные описания для каждого вида.
Общими являются кнопки для показа подсказок по форматированию текста и переменным плагина.
#### Простой режим ####
В этом режиме страница представлена четырьмя текстовыми полями: для обычных сообщений, для окна чата, для заголовка и тела статуса.
#### Расширенный режим ####
В этом режиме поля для сообщений и чата накладываются друг на друга и выбираются посредством радиокнопок справа в середине.
прочие радиокнопки справа предназначены для выбора различных шаблонов для случаев, когда музыка играет, когда музыка остановлена и когда плеер выключен.<br />
В самом низу этой группы расположены радиокнопки и выпадающий список, с помощью которых можно выбрать хСтатус, который будет использован для случая, когда воспроизводится аудио или видео.<br />
Наконец, слева в верхней половине имеются два списка: список протоколов и статусов для этих протоколов (у каждого протокола - свой).
Протокол и статус _"- default -"_ предназначены для ввода шаблона по-умолчанию, если прочие шаблоны не пере-определены

### Вкладка "Templates" / "Шаблоны" (вторая) ###
_Image:Wat\_tab\_tmpl.png|thumb|200px|right|Дополнительные шаблоны_
Вкладка аналогична предыдущей в простом режиме.<br />
Отличие в том, что она содержит поля ввода шаблона для заголовков и текста для всплывающих окошек, окна фрейма и экспортируемого текста (для вставки в другие приложения).

### Вкладка "Formats" / "Форматы" ###
_Image:Wat\_tab\_format.png|thumb|right|Настройки плееров и форматов_
Список плееров предназначен для того, чтоб видеть, какой плеер является активным на данный момент (он стоит первым) и установки, какие плееры искать при опросе, а какие нет.<br />
Список форматов выполняет аналогичную функцию.<br />
Кнопки под списками позволяют одним-двумя кликами выделить или снять пометку сразу со всех элементов списков.

Настройки в правой части вкладки указывают, в каком виде будут показаны различные данные о файле:
  * Размер (в байтах, килобайтах или мегабайтах)
  * Способ представления размера
  * Количество знаков после запятой
  * способ показа расширения (типа) файла: заглавными или строчными буквами
  * Показывать или нет **CBR** (_constant Bitrate_) наравне с **VBR** (_variable BitRate_)
  * Способ представления названия плеера: все заглавные, все маленькие или как был описан.

### Вкладка "Misc" / "Прочее" ###
_Image:Wat\_tab\_misc.png|thumb|right|Различные настройки_
Слева находится список контактов, где можно установить, кто из них имеет право смотреть информацию о музыке (через меню или запрос в сообщении).<br />
К этой же настройке можно отнести и группу чекбоксов внизу справа. Они предназначены для сохзранения событий в базе, когда кто-то делает запрос на информацию о музыке, и получает ответ, или наоборот, когда текущий пользователь делает подобные запросы и получает ответ.

Выбор горячей клавиши в верхней части справа предназначен для такой комбинации клавиш, при нажати на которую текст, соответствующий шаблону экспортируемого текста, будет вставлен в поле редактирования иного, нежели Миранда, приложения.<br />
Текстовое поле для выбора файла обложки задает файловую маску, по которой будут искаться эти самые обложки.

### Вкладка "Frame" / "Фрейм" ###
_Image:Wat\_tab\_frame1.png|thumb|right|Фрейм, настройки внешнего вида_
Верхняя левая опция включает или отключает поддержку Фрейма в плагине.
Бегунок _"Transparence" / "Прозрачность"_ задает прозрачность окна фрейма, а путем нажатия на кнопку _"Back color" / "Цвет фона"_ можно сменить его цвет.<br />
Кнопка  и поле ввода для изображения задают фоновую картинку ,отображаемую в окне фрейма. Если помечена опция _"Use cover instead of picture" / "Обложка вместо изображения"_, то при наличии обложки, она будет заменять выбранную фоновую картинку.<br />
Справа вверху находятся три чекбокса, указывающий, какие именно части будут показаны в окне фрейма: информация (по шаблону), панель управления - кнопки управления плеером, а также опция, показывать ли кнопки управления громкостью вместе с прочими кнопками или нет.

Центральная часть настроек посвящена различным вариантам размещения картинки на фоне окна фрейма.
_"Use styled trackbar" / "Исп. стилизованный ползунок"_ - настройка указывает, использовать ли иконку бегунка, определенную пользователем, или же стандартное оформление Windows.<br />
Опция _"Show trackbar" / "Полоса перемотки"_ указывает, показывать полоску для "перемотки" файла (изменеия позиции воспроизведения) либо нет.<br />
Слева внизу находится 4 поля ввода, указывающие отступы фоновой картинки от краев окна фрейма.<br />
Справа можно выбрать время одновления окна фрейма (важно для перемотки текста и перемещения ползунка)<br />
Если выбрана опция _"Use buttons gap" / "Пропуск между кнопками"_, то кнопки управления плеером будут разделены друг от друга небольшими промежутками.<br />
_"Hide frame when player not found" / "Прятать фрейм когда плеер не найден"_ - позволяет скрывать окно фрейма, когда в нем нет необходимости, т.е. когда никакой плеер не запущен.<br />
_"Hide frame when no music played" / "Прятать фрейм когда музыка не играет"_ - сходная опция, но фрейм бутдет скрыт и тогда, когда плеер запущен, но ни один файл не воспроизводится.

### Вкладка "Frame 2" / "Фрейм 2" ###
_Image:Wat\_tab\_frame2.png|thumb|right|Фрейм, настройки текста_
Настройки на этой вкладке относятся к виду текста во фрейме, таких как Шрифт, видеоэффекты и отображение текста.<br />
Группа **"Text movement" / "Движение текста"**:
  * Скорость движения текста (Text rotation speed) - скорость прокрутки текста в окне фрейма
  * Шаг прокрутки (Scroll step) - расстояние в пикселях для перемещения текста на один шаг
  * Промежуток прокрутки (Scroll gap) - промежуток между "хвостом" и "головой" текста при прокрутке.
  * Мин. хвост прокрутки (Minimum scroll tail) - "пробелы" перед "головой" и после "хвоста" текста - сейчас не используется.

Группа **"Text effect" / "Эффект текста"**:
  * _"Cut" / "Вырезать"_ - Текст, не помещающийся в строке, обрезается
  * _"Wrap" / "Переносить"_ - Текст, не помещающийся в строке, переносится на следующую
  * _"Roll" / "Прокручивать"_ - Текст, не помещающийся в строке, прокручивается
  * _"PingPong" / "ПингПонг"_ - Текст, не помещающийся в строке, прокручивается в пределах строки влево и вправо, не выходя за ее пределы
  * _"Align text to center" / "Центровать текст"_ - выравнивать текст в строке по центру

### Вкладка "Statistic" / "Статистика" ###
_Image:Wat\_tab\_stat.png|thumb|right|Настройки статистики_
Опция _"Disable logfile" / "Отключить лог"_ говорит сама за себя. Когда галочка стоит, лог не ведется, т.е. статистика в это время не будет составляться.<br />
Поля _"Statistic log file" / "Лог статистики"_, _"report filename" / "Файл отчета"_ и _"Template file" / "Файл шаблона"_ и кнопки рядом с ними позволяют выбрать файлы, в которых будет записываться лог, рапорт о статистике и шаблон для оформления рапорта соответственно. Если файл шаблона не указан, будет использоватья встроенный.<br />
Кнопка _"Delete" / "Удалить"_ предназначена для удаления файла лога, кнопка _"Sort" / "Сортировка"_ для выполнения сортировки файла лога, _"Report" / "Отчет"_ - для составления отчета на основе данных из лога.<br />
Поле _"Autosort period" / "Сорт. автоматически"_ позволяет указать промежуток в днях, когда лог будет автоматически отсортирован.
При нажатии на кнопку _"Export default" / "Сохр. стандр."_ встроенный шаблон для оформления отчета записывается в файл. После чего его можно отредактироать по собственному вкусу и указать в качестве нового шаблона.<br />
Группа настроек **"Show in report" / "Показывать в отчете"** позволяет настроить, что именно (какие группы по рейтингу) будет помещено в файл отчета.<br />
Группа настроек **"Sort log file" / "Сортировать логи"** позволяет выбрать, по какому именно критерию, а также по возрастанию либо убыванию, будет отсортирован лог.<br />
Поле _"Report Items" / "Число записей"_ указывает максимальное количество пунктов статистики для каждой из показываемых групп.
_"Open report" / "Открыть отчет"_ - эта опция указывает, открывать ли полученный отчет в программе для просмотра или только записывать на диск.<br />
_"Add report file ext." / "Добавить к отчету расширение"_ - если помечено, то в случае отсуствия расширения для файла отчета, оно будет добавлено автоматически.

### Настройка для всплывающих окон ###
_Image:Wat\_tab\_popup.png|thumb|right|Настройки всплывающих окон_
Верхняя левая настрока (чекбокс) служит для управления всплывающими окнами: отображать их или нет.<br />
Группа **"Pause" / "Пауза"** указывает, сколько секунд должно отображаться всплывающее окно на экране.<br />
Группа **"Colors" / "Цвета"** позволяет настроить цветовую гамму всплывающих окон.<br />
Группа **"Actions" / "Действия"** позволяет настроить реакцию при нажатии левой или правой кнопкой мыши на всплывающем окне.<br />
Возможные на данный момент действия:
**Закрыть всплывающее окно** Отобразить информацию о треке
**Открыть окно плеера** Перейти на следующий трек

Чекбокс _"Show filename" / "Показывать имя файла"_ указывает, показывать или нет в информационном окне имя воспроизводимого файла.
Опция _"Show by request only" / "Только по запросу"_ указывает, что показ всплывающего окна будет производиться только при вызове через сервис, меню или кнопку.<br />
Группа **"Hotkey" / "Горячая клавиша"** позволяет выбрать горячие клавиши для показа всплывающего окна, а так же выбрать: локальная это будет комбинация или глобальная.

## Схожие плагины ##
  * _WinampControl_
  * _ListeningTo_
  * _WinampXStatus_
  * Отдельные скрипты для _MBot_

## Ссылки ##
  * http://awkward.miranda.im/
  * http://awkward.miranda.im/watrack.zip
  * [MirandaOrgFileListingURL|2345]
  * [MirandaOrgThread|4660]
  * [MirandaRuTheme|25.0]
  * [Тема на польском форуме](http://www.miranda-im.pl/viewtopic.php?t=4576)
  * [Тема на немецком форуме](http://forum.miranda-im.de/index.php?topic=1161.0)
  * Тема на [miranda-planet](http://miranda-planet.com/forum/index.php?showtopic=254&hl=WATrack)
  * Тема на [carleone.clan.su](http://carleone.clan.su/forum/4-143-1)