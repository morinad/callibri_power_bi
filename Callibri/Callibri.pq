section Callibri;

[DataSource.Kind="Callibri", Publish="Callibri.Publish"]
shared Callibri.Data = Value.ReplaceType(Callibri.Func, FuncType);

FuncType = type function (
    email as (type text meta [        
        Documentation.FieldCaption = "Callibri e-mail:",
         Documentation.SampleValues = {"xxx@xxx.ru"}
    ]),

    site_num as (type text meta [        
        Documentation.FieldCaption = "Callibri account ID:",
         Documentation.SampleValues = {"12345"}
    ]),
    
    
     tip as (type text meta [        
        Documentation.FieldCaption = "Data type:",
         Documentation.AllowedValues = {"calls","feedbacks","chats","emails"}
    ]),

    start as (type text meta [
        Documentation.FieldCaption = "Start date:",
        Documentation.FieldDescription = "Enter the first date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"2020-02-28"}
    ]),

     end as (type text meta [
        Documentation.FieldCaption = "End date:",
        Documentation.FieldDescription = "Enter the last date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"yesterday"}
    ])
    )
    as table meta [
        Documentation.Name = "Callibri.Data Function",
        Documentation.LongDescription = "Created to get data from Callibri Calltracking.",
        Documentation.Examples = {
        [
            Description = "Returns a list of records from Callibri Calltracking",
            Code = "Callibri.Data(""xxx@xxx.ru"",""12345"",""calls"",""f1Jbn15b79cpqnfhNF015BF"",""2020-02-20"",""yesterday"")",
            Result = "{[Record1],[Record2],[Record3],...}"
        ],
        [
            Description = "Returns a list of records from Callibri Calltracking",
            Code = "Callibri.Data(""xxx@xxx.ru"",""54321"",""chats"",""f1Jbn15b9cpnfhNF015BF"",""500daysAgo"",""today"")",
            Result = "{[Record1],[Record2],[Record3],...}"
        ]
        }
    ];



Callibri.Func =(email as text, site_num as text, tip as text, start as text, end as text)=>
 let 
     mail = email,
     num = site_num,
     typ = tip,
     startCalc=
       let
       x = Number.From(Date.From(dateFunc(end))-Date.From(dateFunc(start))),
       Source = List.Dates(Date.From(dateFunc(start)), x+1, #duration(1, 0, 0, 0)),
       #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
       #"Changed Type" = Table.TransformColumnTypes(#"Converted to Table",{{"Column1", type date}}),
       #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Column1", "DimDate"}}),
        #"Вставлено: месяц" = Table.AddColumn(#"Renamed Columns", "Неделя", each Date.WeekOfYear([DimDate]), Int64.Type),
        #"Вставлено: год" = Table.AddColumn(#"Вставлено: месяц", "Год", each Date.Year([DimDate]), Int64.Type),
        #"Удаленные дубликаты" = Table.Distinct(#"Вставлено: год", {"Неделя", "Год"}),
        #"Удаленные столбцы" = Table.RemoveColumns(#"Удаленные дубликаты",{"Неделя", "Год"}),
        #"Измененный тип" = Table.TransformColumnTypes(#"Удаленные столбцы",{{"DimDate", type text}}),
        #"Разделить столбец по разделителю" = Table.SplitColumn(#"Измененный тип", "DimDate", Splitter.SplitTextByDelimiter(".", QuoteStyle.Csv), {"DimDate.1", "DimDate.2", "DimDate.3"}),
        #"Добавлен пользовательский объект" = Table.AddColumn(#"Разделить столбец по разделителю", "DimDate", each [DimDate.1]&"."&[DimDate.2]&"."&[DimDate.3]),
        #"Другие удаленные столбцы" = Table.SelectColumns(#"Добавлен пользовательский объект",{"DimDate"}),
        #"Переименованные столбцы" = Table.RenameColumns(#"Другие удаленные столбцы",{{"DimDate", "DimDate1"}}),
        tip1 = Table.TransformColumnTypes(#"Переименованные столбцы",{{"DimDate1", type date}}),
        #"Сортированные строки" = Table.Sort(tip1,{{"DimDate1", Order.Ascending}}),
        #"Добавлен индекс" = Table.AddIndexColumn( #"Сортированные строки", "Индекс", 1, 1),
        #"Измененный тип1" = Table.TransformColumnTypes(#"Добавлен индекс",{{"DimDate1", type text}})
        in
        #"Измененный тип1",
    
        endCalc=
        let
        x =  Number.From(Date.From(dateFunc(end))-Date.From(dateFunc(start))),
        Source = List.Dates(Date.From(dateFunc(end)), x+1, #duration(-1, 0, 0, 0)),
        #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        #"Changed Type" = Table.TransformColumnTypes(#"Converted to Table",{{"Column1", type date}}),
        #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Column1", "DimDate"}}),
        #"Вставлено: месяц" = Table.AddColumn(#"Renamed Columns", "Неделя", each Date.WeekOfYear([DimDate]), Int64.Type),
        #"Вставлено: год" = Table.AddColumn(#"Вставлено: месяц", "Год", each Date.Year([DimDate]), Int64.Type),
        #"Удаленные дубликаты" = Table.Distinct(#"Вставлено: год", {"Неделя", "Год"}),
        #"Удаленные столбцы" = Table.RemoveColumns(#"Удаленные дубликаты",{"Неделя", "Год"}),
        #"Измененный тип" = Table.TransformColumnTypes(#"Удаленные столбцы",{{"DimDate", type text}}),
        #"Разделить столбец по разделителю" = Table.SplitColumn(#"Измененный тип", "DimDate", Splitter.SplitTextByDelimiter(".", QuoteStyle.Csv), {"DimDate.1", "DimDate.2", "DimDate.3"}),
        #"Добавлен пользовательский объект" = Table.AddColumn(#"Разделить столбец по разделителю", "DimDate", each [DimDate.1]&"."&[DimDate.2]&"."&[DimDate.3]),
        #"Другие удаленные столбцы" = Table.SelectColumns(#"Добавлен пользовательский объект",{"DimDate"}),
        #"Переименованные столбцы" = Table.RenameColumns(#"Другие удаленные столбцы",{{"DimDate", "DimDate2"}}),
        tip2 = Table.TransformColumnTypes(#"Переименованные столбцы",{{"DimDate2", type date}}),
        #"Сортированные строки" = Table.Sort(tip2,{{"DimDate2", Order.Ascending}}),
        #"Добавлен индекс" = Table.AddIndexColumn(#"Сортированные строки", "Индекс", 1, 1),
        #"Измененный тип1" = Table.TransformColumnTypes(#"Добавлен индекс",{{"DimDate2", type text}})
        in
        #"Измененный тип1",

    
    get=( dateF as text, dateL as text) => 
        let
           Источник = Json.Document(Web.Contents("https://api.callibri.ru", [ 
                RelativePath="site_get_statistics",
                Query = [ 
                  user_email = mail, 
                  site_id = num,
                  date1 = dateF,
                  date2 = dateL,
                  user_token = Extension.CurrentCredential()[Key]
                       ]])),
            res =Источник[channels_statistics]{0},
            fin = Table.FromList(Record.Field(res,tip), Splitter.SplitByNothing(), null, null, ExtraValues.Error)
            
        in
            fin,
        
     
        Источник = Table.NestedJoin(endCalc,{"Индекс"},startCalc,{"Индекс"},"Запрос1",JoinKind.LeftOuter),
        #"Развернутый элемент Запрос1" = Table.ExpandTableColumn(Источник, "Запрос1", {"DimDate1"}, {"DimDate1"}),
        #"Удаленные столбцы" = Table.RemoveColumns(#"Развернутый элемент Запрос1",{"Индекс"}),
        #"Переупорядоченные столбцы" = Table.ReorderColumns(#"Удаленные столбцы",{"DimDate1", "DimDate2"}),
        #"Измененный тип" = Table.TransformColumnTypes(#"Переупорядоченные столбцы",{{"DimDate1", type text}, {"DimDate2", type text}}),
        #"Добавлен пользовательский объект2" = Table.AddColumn(#"Измененный тип", "Пользовательская", each get([DimDate1],[DimDate2])),
    #"Удаленные ошибки" = Table.RemoveRowsWithErrors(#"Добавлен пользовательский объект2", {"Пользовательская"}),
      #"Добавлен пользовательский объект" = Table.AddColumn( #"Удаленные ошибки", "Пользовательский", each Table.RowCount([Пользовательская])),
    #"Строки с примененным фильтром" = Table.SelectRows(#"Добавлен пользовательский объект", each ([Пользовательский] <> 0)),
    #"Другие удаленные столбцы" = Table.SelectColumns(#"Строки с примененным фильтром",{"Пользовательская"}),
    #"Развернутый элемент Пользовательская" = Table.ExpandTableColumn(#"Другие удаленные столбцы", "Пользовательская", {"Column1"}, {"Данные"})
in
    #"Развернутый элемент Пользовательская"
   ;


    
        


dateFunc= (dat)=>
       if dat = "yesterday" then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()) , -1),"dd.MM.yyyy") 
       else if dat = "today" then Date.ToText(Date.From(DateTime.LocalNow()),"dd.MM.yyyy")
       else if (try Number.From(Text.BeforeDelimiter(dat,"daysAgo")) otherwise 0) >0 then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()),-1*Number.From(Text.BeforeDelimiter(dat,"daysAgo"))),"dd.MM.yyyy") 
       else dat ;



Callibri = [
    TestConnection = (dataSourcePath) => 
        { 
        "Callibri.Data", 
        Json.Document(dataSourcePath)[email],
        Json.Document(dataSourcePath)[site_num],
        Json.Document(dataSourcePath)[tip],
        Json.Document(dataSourcePath)[start],
        Json.Document(dataSourcePath)[end]
        },
    Authentication = [
                 Key = []
       ],
    Label = "Callibri Connection"
];



Callibri.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { "Callibri Connector", "Callibri Help" },
    LearnMoreUrl = "https://www.youtube.com/channel/UCqSLNYLN_3mf6nA1Xf7fu1g/",
    SourceImage = Callibri.Icons,
    SourceTypeImage = Callibri.Icons
];



Callibri.Icons = [
    Icon16 = { Extension.Contents("Callibri16.png"), Extension.Contents("Callibri20.png"), Extension.Contents("Callibri24.png"), Extension.Contents("Callibri32.png") },
    Icon32 = { Extension.Contents("Callibri32.png"), Extension.Contents("Callibri40.png"), Extension.Contents("Callibri48.png"), Extension.Contents("Callibri64.png") }
];