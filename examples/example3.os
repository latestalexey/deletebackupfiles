// Пример 3
// Выполняется чтение заданий из файла настроек, переданного как параметр скрипту.
// В файле настроек используется настройка "БезУдаленияРезервныхКопий" и находится описание двух заданий:
//    Хранение как минимум 4 полных резервных копий в каталоге d:\\full в течении 31 дня,
//    Хранение как минимум 14 дифференциальных резервных копий в каталоге d:\\diff в течении 14 дней,

#Использовать cmdline
#Использовать "..\..\deletebackupfiles"

// Обработка параметров командной строки.
Парсер = Новый ПарсерАргументовКоманднойСтроки();	
Парсер.ДобавитьПараметр("ПутьКФайлу");
Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);

// Чтение настроек из переданного файла. 
// Если файл не был передан, то выполняется чтение из файла по умолчанию "settings.json".
ФайлНастроек = Параметры["ПутьКФайлу"];

Попытка
	// Чтение настроек из переданного файла. 
	// Если файл не был передан, то выполняется чтение из файла по умолчанию "settings.json".
	УдалениеФайловРезервныхКопий.ПрочитатьНастройки(ФайлНастроек);
	
	УдалениеФайловРезервныхКопий.ЗаполнитьЗаданияИзНастроек();
	
	УдалениеФайловРезервныхКопий.УдалитьУстаревшиеРезервныеКопии();
Исключение
	Сообщить("Ошибка удаления устаревших резервных копий!");
КонецПопытки;