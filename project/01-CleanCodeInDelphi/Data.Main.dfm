object DataModMain: TDataModMain
  OldCreateOrder = False
  Height = 385
  Width = 467
  object mtabReports: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 136
    Top = 24
    object mtabReportsReaderId: TIntegerField
      FieldName = 'ReaderId'
    end
    object mtabReportsISBN: TWideStringField
      FieldName = 'ISBN'
    end
    object mtabReportsRating: TIntegerField
      FieldName = 'Rating'
    end
    object mtabReportsOppinion: TWideStringField
      FieldName = 'Oppinion'
      Size = 2000
    end
    object mtabReportsReported: TDateField
      FieldName = 'Reported'
    end
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 320
    Top = 72
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Books')
    LoginPrompt = False
    Left = 55
    Top = 164
  end
  object dsBooks: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM Books')
    Left = 139
    Top = 166
  end
  object dsReaders: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM Readers')
    Left = 141
    Top = 221
  end
  object dsReports: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM Reports')
    Left = 142
    Top = 271
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 232
    Top = 168
  end
end
