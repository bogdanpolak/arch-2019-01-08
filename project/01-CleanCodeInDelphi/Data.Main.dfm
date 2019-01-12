object DataModMain: TDataModMain
  OldCreateOrder = False
  Height = 330
  Width = 440
  object __mtabReports: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 112
    Top = 232
    object __mtabReportsReaderId: TIntegerField
      FieldName = 'ReaderId'
    end
    object __mtabReportsISBN: TWideStringField
      FieldName = 'ISBN'
    end
    object __mtabReportsRating: TIntegerField
      FieldName = 'Rating'
    end
    object __mtabReportsOppinion: TWideStringField
      FieldName = 'Oppinion'
      Size = 2000
    end
    object __mtabReportsReported: TDateField
      FieldName = 'Reported'
    end
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 304
    Top = 232
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Books')
    LoginPrompt = False
    Left = 23
    Top = 20
  end
  object dsBooks: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM Books')
    Left = 107
    Top = 22
  end
  object dsReaders: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM Readers')
    Left = 109
    Top = 77
  end
  object dsReports: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM Reports')
    Left = 110
    Top = 127
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 200
    Top = 24
  end
  object __mtabReaders: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 32
    Top = 232
    object __mtabReadersReaderId: TIntegerField
      FieldName = 'ReaderId'
    end
    object __mtabReadersFirstName: TWideStringField
      FieldName = 'FirstName'
      Size = 100
    end
    object __mtabReadersLastName: TWideStringField
      FieldName = 'LastName'
      Size = 100
    end
    object __mtabReadersEmail: TWideStringField
      FieldName = 'Email'
      Size = 50
    end
    object __mtabReadersCompany: TWideStringField
      FieldName = 'Company'
      Size = 100
    end
    object __mtabReadersBooksRead: TIntegerField
      FieldName = 'BooksRead'
    end
    object __mtabReadersLastReport: TDateField
      FieldName = 'LastReport'
    end
    object __mtabReadersCreated: TDateField
      FieldName = 'Created'
    end
  end
  object __mtabBooks: TFDMemTable
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 200
    Top = 232
    object __mtabBooksISBN: TWideStringField
      FieldName = 'ISBN'
    end
    object __mtabBooksTitle: TWideStringField
      FieldName = 'Title'
      Size = 100
    end
    object __mtabBooksAuthors: TWideStringField
      FieldName = 'Authors'
      Size = 100
    end
    object __mtabBooksStatus: TWideStringField
      FieldName = 'Status'
      Size = 15
    end
    object __mtabBooksReleseDate: TDateField
      FieldName = 'ReleseDate'
    end
    object __mtabBooksPages: TIntegerField
      FieldName = 'Pages'
    end
    object __mtabBooksPrice: TCurrencyField
      FieldName = 'Price'
      DisplayFormat = '###,###,###.00'
      currency = False
    end
    object __mtabBooksCurrency: TWideStringField
      FieldName = 'Currency'
      Size = 10
    end
    object __mtabBooksImported: TDateField
      FieldName = 'Imported'
    end
    object __mtabBooksDescription: TWideStringField
      FieldName = 'Description'
      Size = 2000
    end
  end
end
