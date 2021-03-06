
#Использовать logos
#Использовать readparams

Перем Лог;
Перем Настройки;
Перем БезУдаленияРезервныхКопий;
Перем Задания;

// Основной алгоритм.
// Получить количество файлов в каталоге.
// Если количество файлов в каталоге меньше либо равно минимальному количеству резервных копий, тогда ничего удалять не нужно.
// Вычисление даты, ранее которой нужно удалить резервные копии. Дата резервной копии определяется, как дата изменения файла.
// Сортировка файлов резервных копий по убыванию.
// Удаление файлов с номерами в сортировке больше, чем минимальное количество резервных копий и старше, чем дата удаления резервных копий.

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

    Возврат СтрШаблон("%1: %2 - %3", Формат(ТекущаяДата(), "ДФ='dd.MM.yyyy HH:mm:ss'"), УровниЛога.НаименованиеУровня(Уровень), Сообщение);
	
КонецФункции

Процедура ВывестиСтруктуру(Данные)
	Для каждого КлючИЗначение Из Данные Цикл
		Если ТипЗнч(КлючИЗначение.Значение) = Тип("Структура") ИЛИ ТипЗнч(КлючИЗначение.Значение) = Тип("Соответствие") Тогда
			Лог.Информация(СтрШаблон("%1: : %2:", КлючИЗначение.Ключ, ТипЗнч(КлючИЗначение.Значение)));
			ВывестиСтруктуру(КлючИЗначение.Значение);
		Иначе
			Лог.Информация(СтрШаблон("%1: %2: %3", КлючИЗначение.Ключ, ТипЗнч(КлючИЗначение.Значение), КлючИЗначение.Значение));
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция НастройкиНовоеЗадание()
	Возврат Новый Структура("Каталог,МаскаФайлов,МинимальноеКоличествоРезервныхКопий,ПериодХраненияРезервныхКопий,ТекущаяДата");
КонецФункции

Функция НовыеНастройки() Экспорт
	
	// Инициализация настроек.
	Настройки = Новый Соответствие;
	Настройки.Вставить("Задания", Новый Соответствие);

	БезУдаленияРезервныхКопий = Ложь;

КонецФункции

Функция ПрочитатьНастройки(ФайлНастроек = "") Экспорт
	
	// Инициализация настроек.
	Настройки = Новый Соответствие;
	Настройки.Вставить("Задания", Новый Соответствие);

	БезУдаленияРезервныхКопий = Ложь;

	Если ФайлНастроек = "" ИЛИ ФайлНастроек = Неопределено Тогда
		ТекущийКаталог = ТекущийКаталог();
		ФайлНастроек = ОбъединитьПути(ТекущийКаталог, "settings.json");
	КонецЕсли;

	Лог.Информация("ФайлНастроек:" + ФайлНастроек);
	
	Лог.Отладка("ЧтениеПараметров.Прочитать()");

	ОшибкиЧтения = Неопределено;
	ПрочитанныеНастройки = ЧтениеПараметров.Прочитать(ФайлНастроек, ОшибкиЧтения);

	Лог.Отладка("ОшибкиЧтения.Количество(): " + ОшибкиЧтения.Количество());
	Если ОшибкиЧтения.Количество() > 0 Тогда
		Для каждого цЭлемент Из ОшибкиЧтения Цикл
			Лог.Информация(цЭлемент.Ключ + ": " + цЭлемент.Значение);
		КонецЦикла;
		Возврат Настройки;
	КонецЕсли;

	Для каждого СтрокаПараметров Из ПрочитанныеНастройки Цикл
		ИмяПараметраМассив = СтрРазделить(СтрокаПараметров.Ключ, ".");
		Если ИмяПараметраМассив.Количество() = 2 Тогда
			НастройкиЗадания = Настройки["Задания"];

			ИмяЗадания = ИмяПараметраМассив[0];
			ИмяНастройки = ИмяПараметраМассив[1];
			ТекущееЗадание = НастройкиЗадания[ИмяЗадания];
			Если ТекущееЗадание = Неопределено Тогда
				ТекущееЗадание = НастройкиНовоеЗадание();
				НастройкиЗадания.Вставить(ИмяЗадания, ТекущееЗадание);
			КонецЕсли;
			ТекущееЗадание[ИмяНастройки] = СтрокаПараметров.Значение;
		Иначе
			Настройки.Вставить(СтрокаПараметров.Ключ, СтрокаПараметров.Значение);
		КонецЕсли;
	КонецЦикла;

	ТекущаяДата = ТекущаяДата();
	Для каждого ТекущееЗадание Из Настройки["Задания"] Цикл
		ТекущееЗадание.Значение["ТекущаяДата"] = ТекущаяДата;
	КонецЦикла;

	Лог.Информация("Прочитанные настройки:");
	ВывестиСтруктуру(Настройки);

	НастройкаБезУдаленияРезервныхКопий = Настройки["БезУдаленияРезервныхКопий"];
	Если НастройкаБезУдаленияРезервныхКопий = Истина Тогда
		БезУдаленияРезервныхКопий = Истина;
	КонецЕсли;

	Возврат Настройки;

КонецФункции


Процедура ДобавитьЗадание(ИмяЗадания, Каталог, МаскаФайлов, МинимальноеКоличествоРезервныхКопий, ПериодХраненияРезервныхКопий, ТекущаяДата) Экспорт
	
	НоваяСтрока = Задания.Добавить();
	НоваяСтрока.ИмяЗадания = ИмяЗадания;
	НоваяСтрока.Каталог = Каталог;
	НоваяСтрока.МаскаФайлов = МаскаФайлов;
	НоваяСтрока.МинимальноеКоличествоРезервныхКопий = МинимальноеКоличествоРезервныхКопий;
	НоваяСтрока.ПериодХраненияРезервныхКопий = ПериодХраненияРезервныхКопий;
	НоваяСтрока.ТекущаяДата = ТекущаяДата;

КонецПроцедуры

Процедура ОчиститьЗадания() Экспорт
	Задания.Очистить();
КонецПроцедуры

Процедура ЗаполнитьЗаданияИзНастроек() Экспорт
	
	Для каждого КлючИЗначение Из Настройки["Задания"] Цикл
		НоваяСтрока = Задания.Добавить();
		НоваяСтрока.ИмяЗадания = КлючИЗначение.Ключ;
		ЗаполнитьЗначенияСвойств(НоваяСтрока, КлючИЗначение.Значение);
	КонецЦикла;

КонецПроцедуры

Функция РезервныеКопии(ФайлыРезервныхКопий)
	
	РезервныеКопии = Новый ТаблицаЗначений;
	РезервныеКопии.Колонки.Добавить("ПолноеИмя");
	РезервныеКопии.Колонки.Добавить("ВремяИзменения");
	РезервныеКопии.Колонки.Добавить("Файл");

	Для каждого ФайлРезервнойКопии Из ФайлыРезервныхКопий Цикл
		НоваяСтрока = РезервныеКопии.Добавить();
		НоваяСтрока.ПолноеИмя = ФайлРезервнойКопии.ПолноеИмя;
		НоваяСтрока.ВремяИзменения = ФайлРезервнойКопии.ПолучитьВремяИзменения();
		НоваяСтрока.Файл = ФайлРезервнойКопии;
	КонецЦикла;

	РезервныеКопии.Сортировать("ВремяИзменения УБЫВ");

	Возврат РезервныеКопии;

КонецФункции

Процедура УдалитьУстаревшиеРезервныеКопии() Экспорт
	
	// Вывод начала операции удаления файлов резервных копий.
	Лог.Информация("Начало операции удаления файлов резервных копий");
	
	Для каждого Задание Из Задания Цикл
		
		// Вывод начала задания по удалению файлов резервных копий.
		Лог.Информация("Начало задания удаления файлов резервных копий");
		
		// Вывод параметров задания.
		Лог.Информация("Каталог: "+Задание.Каталог);
		Лог.Информация("МаскаФайлов: "+Задание.МаскаФайлов);
		Лог.Информация("МинимальноеКоличествоРезервныхКопий: "+Задание.МинимальноеКоличествоРезервныхКопий);
		Лог.Информация("ПериодХраненияРезервныхКопий: "+Задание.ПериодХраненияРезервныхКопий);
		Лог.Информация("ТекущаяДата: "+Задание.ТекущаяДата);

		// Проверка заполнения необходимых настроек задания.
		ТекстСообщения = "Для задания ""%1"" не заполнена настройка ""%2""! Задание будет пропущено.";
		
		Если Не ЗначениеЗаполнено(Задание.Каталог) Тогда
			Лог.Предупреждение(СтрШаблон(ТекстСообщения, Задание.ИмяЗадания, "Каталог"));
			Продолжить;
		КонецЕсли;

		Если Не ЗначениеЗаполнено(Задание.МаскаФайлов) Тогда
			Лог.Предупреждение(СтрШаблон(ТекстСообщения, Задание.ИмяЗадания, "МаскаФайлов"));
			Продолжить;
		КонецЕсли;

		Если Не ЗначениеЗаполнено(Задание.ТекущаяДата) Тогда
			Лог.Предупреждение(СтрШаблон(ТекстСообщения, Задание.ИмяЗадания, "ТекущаяДата"));
			Продолжить;
		КонецЕсли;

		// Проверка на существование каталога с резервными копиями.
		ПроверкаКаталог = Новый Файл(Задание.Каталог);
		Если Не ПроверкаКаталог.Существует() Тогда
			ТекстСообщения = "Для задания ""%1"" не существует указанного каталога с резервными копиями ""%2""! Задание будет пропущено.";
			Лог.Предупреждение(СтрШаблон(ТекстСообщения, Задание.ИмяЗадания, Задание.Каталог));
			Продолжить;
		КонецЕсли;

		Если Не ПроверкаКаталог.ЭтоКаталог() Тогда
			ТекстСообщения = "Для задания ""%1"" не существует указанного каталога с резервными копиями ""%2""! Задание будет пропущено.";
			Лог.Предупреждение(СтрШаблон(ТекстСообщения, Задание.ИмяЗадания, Задание.Каталог));
			Продолжить;
		КонецЕсли;

		ФайлыРезервныхКопий = НайтиФайлы(Задание.Каталог, Задание.МаскаФайлов);

		// Удаление из массива найденных файлов резервных копий каталогов.
		КаталогиКУдалениюИзМассива = Новый Массив();
		Для Инд = 0 По ФайлыРезервныхКопий.Количество()-1 Цикл
			Если ФайлыРезервныхКопий[Инд].ЭтоКаталог() Тогда
				КаталогиКУдалениюИзМассива.Добавить(Инд);
			КонецЕсли;
		КонецЦикла;
		
		Для каждого ИндексЭлемента Из КаталогиКУдалениюИзМассива Цикл
			ФайлыРезервныхКопий.Удалить(ИндексЭлемента);
		КонецЦикла;

		КоличествоФайловРезервныхКопийВКаталоге = ФайлыРезервныхКопий.Количество();

		// Вывод количества файлов резервных копий в каталоге.
		Лог.Информация("КоличествоФайловРезервныхКопийВКаталоге: "+КоличествоФайловРезервныхКопийВКаталоге);

		Если КоличествоФайловРезервныхКопийВКаталоге <= Задание.МинимальноеКоличествоРезервныхКопий Тогда
			// Количество файлов в каталоге меньше либо равно минимальному количеству резервных копий, тогда ничего удалять не нужно.
			Лог.Информация("Количество файлов резервных копий в каталоге меньше или равно минимальному количеству хранимых резервных копий.");
			Лог.Информация("Не нужно удалять файлы резервных копий.");
		Иначе

			РезервныеКопииКУдалению = Новый Массив;
			
			// Расчет минимальной даты сохраняемых резервных копий.
			// Пример1: текущая дата = 07.01.2018, период хранения резервных копия = 0, 
			// т.е. будут удалены даже резервные копии от текущей даты, а минимальный период = 08.01.2018 00:00:00.
			// Пример2: текущая дата = 07.01.2018, период хранения резервных копия = 1, 
			// т.е. будут сохранены резервные копии от текущей даты, а минимальный период = 07.01.2018 00:00:00.
			// Пример3: текущая дата = 07.01.2018, период хранения резервных копия = 2, 
			// т.е. будут сохранены резервные копии от текущей даты и за день до нее, а минимальный период = 06.01.2018 00:00:00.
			МинимальнаяДатаСохраняемыхРезервныхКопий = НачалоДня(Задание.ТекущаяДата) - (Задание.ПериодХраненияРезервныхКопий - 1) * 86400;
			
			// Вывод минимальной даты сохраняемых резервных копий.
			Лог.Информация("МинимальнаяДатаСохраняемыхРезервныхКопий: "+МинимальнаяДатаСохраняемыхРезервныхКопий);

			РезервныеКопии = РезервныеКопии(ФайлыРезервныхКопий);

			// Выбор к удалению файлов с номерами в сортировке больше, чем минимальное количество резервных копий 
			// и старше, чем дата удаления резервных копий.
			Для Инд = Задание.МинимальноеКоличествоРезервныхКопий+1 По КоличествоФайловРезервныхКопийВКаталоге Цикл
				РезервнаяКопия = РезервныеКопии[Инд-1]; //РезервныеКопии[0].ВремяИзменения
				Если РезервнаяКопия.ВремяИзменения < МинимальнаяДатаСохраняемыхРезервныхКопий Тогда
					РезервныеКопииКУдалению.Добавить(РезервнаяКопия.ПолноеИмя);

					// Вывод информации о резервной копии к удалению.
					Лог.Информация(
							СтрШаблон("РезервнаяКопияКУдалению: %1 %2",
										Формат(РезервнаяКопия.ВремяИзменения, "YYYY.MM.dd HH:mm:ss"),
										РезервнаяКопия.ПолноеИмя));
				КонецЕсли;
			КонецЦикла;

			Если РезервныеКопииКУдалению.Количество() = 0 Тогда
				Лог.Информация("Все файлы резервных копий младше минимальной даты сохраняемых резервных копий.");
				Лог.Информация("Не нужно удалять файлы резервных копий.");
			Иначе
				Если БезУдаленияРезервныхКопий Тогда
					Лог.Информация("Удаление файлов резервных копий не предусмотрено настройками.");
				Иначе
					// Удаление файлов резервных копий.
					Для каждого РезервнаяКопияКУдалению Из РезервныеКопииКУдалению Цикл
						УдалитьФайлы(РезервнаяКопияКУдалению);

						// Вывод информации об удалении резервной копии.
						Лог.Информация("УдалениеРезервнойКопии: "+РезервнаяКопияКУдалению);
					КонецЦикла;
				КонецЕсли;
				
			КонецЕсли;

		КонецЕсли;

		// Вывод завершения задания по удалению файлов резервных копий.
		Лог.Информация("Конец задания удаления файлов резервных копий");

	КонецЦикла;

	// Вывод завершения операции удаления файлов резервных копий.
	Лог.Информация("Конец операции удаления файлов резервных копий");

КонецПроцедуры


Процедура ЗадатьНачальныеНастройки()
	
	Лог = Логирование.ПолучитьЛог("oscript.deletebackupfiles.messages");
	Лог.УстановитьУровень(УровниЛога.Информация);
	Лог.УстановитьУровень(УровниЛога.Отладка);
	ФайлЖурнала = Новый ВыводЛогаВФайл();
	ФайлЖурнала.ОткрытьФайл("oscript.deletebackupfiles.messages.log");
	Лог.ДобавитьСпособВывода(ФайлЖурнала);
	Лог.ДобавитьСпособВывода(Новый ВыводЛогаВКонсоль());
	Лог.УстановитьРаскладку(ЭтотОбъект);

	Задания = Новый ТаблицаЗначений;
	Задания.Колонки.Добавить("ИмяЗадания");
	Задания.Колонки.Добавить("Каталог");
	Задания.Колонки.Добавить("МаскаФайлов");
	Задания.Колонки.Добавить("МинимальноеКоличествоРезервныхКопий"); // Минимальное количество хранимых резервных копий. Меньше этого количества не будет удалено резервных копий.
	Задания.Колонки.Добавить("ПериодХраненияРезервныхКопий"); // Период хранения резервных копий в днях. 0 - Будут удалены все резервные копии. 1 - Будут сохранены только копии от текущей даты.
	Задания.Колонки.Добавить("ТекущаяДата");	// Дата, относительно которой выполняется расчет периода хранения резервных копий.

	НовыеНастройки();

КонецПроцедуры

ЗадатьНачальныеНастройки();
