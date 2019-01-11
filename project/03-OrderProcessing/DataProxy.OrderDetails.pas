unit DataProxy.OrderDetails;

interface

uses
  Data.DB,
  Data.DataProxy,
  // FireDAC - TFDQuery ------------------------------
  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.Stan.Param,
  FireDAC.Stan.Async;

type
  TOrderDetailsProxy = class(TDatasetProxy)
  protected
    procedure ConnectFields; override;
  public
    OrderID: TIntegerField;
    ProductID: TIntegerField;
    UnitPrice: TBCDField;
    Quantity: TSmallintField;
    Discount: TSingleField;
    procedure Open(OrderID: integer);
    procedure Close;
    // property DataSet: TDataSet read FDataSet;
  end;

implementation

{ TOrder }

uses Database.Connector;

const
  SQL_SELECT_OrderDetails = 'SELECT * FROM "Order Details" WHERE OrderID = :OrderID';

procedure TOrderDetailsProxy.Close;
begin

end;

procedure TOrderDetailsProxy.ConnectFields;
begin
  OrderID := FDataSet.FieldByName('OrderID') as TIntegerField;
  ProductID := FDataSet.FieldByName('ProductID') as TIntegerField;
  UnitPrice := FDataSet.FieldByName('UnitPrice') as TBCDField;
  Quantity := FDataSet.FieldByName('Quantity') as TSmallintField;
  Discount := FDataSet.FieldByName('Discount') as TSingleField;
end;

procedure TOrderDetailsProxy.Open(OrderID: integer);
var
  fdq: TFDQuery;
  cust: string;
  id: string;
begin
  if not Assigned(FDataSet) then
  begin
    fdq := TFDQuery.Create(nil);
    fdq.SQL.Text := SQL_SELECT_OrderDetails;
    fdq.Connection := GlobalConnector.GetMainConnection;
    FDataSet := fdq;
{$IFDEF CONSOLEAPP}
    WriteLn('Created Order DAO object....');
{$ENDIF}
  end;
  (FDataSet as TFDQuery).ParamByName('OrderID').AsInteger := OrderID;
  FDataSet.Open;
  ConnectFields;
{$IFDEF CONSOLEAPP}
  WriteLn('Order Details opened.... loaded: ',FDataSet.RecordCount);
{$ENDIF}
end;

end.
