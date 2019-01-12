object ModuleOrders: TModuleOrders
  OldCreateOrder = False
  Height = 150
  Width = 308
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=SQLite_Demo')
    Connected = True
    LoginPrompt = False
    Left = 52
    Top = 22
  end
  object fdqOrders: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT OrderID, CustomerID, OrderDate, RequiredDate FROM Orders'
      'WHERE ShippedDate is NULL AND RequiredDate < :ADAY'
      'ORDER BY RequiredDate')
    Left = 52
    Top = 78
    ParamData = <
      item
        Name = 'ADAY'
        DataType = ftDate
        ParamType = ptInput
        Value = 35947d
      end>
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 168
    Top = 48
  end
end
