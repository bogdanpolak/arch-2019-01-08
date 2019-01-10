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
    procedure Open(aOrderID: integer);
    procedure Close;
    function QuantitySum(): Integer;
    // property DataSet: TDataSet read FDataSet;
  end;

implementation

{ TOrder }

uses Database.Connector,
  Helper.TDataSet;

const
  SQL_SELECT_OrderDetails = 'SELECT * from  "Order Details" ' +
    ' WHERE OrderID = :OrderID';
  SQL_SumQuantity_OrderDetails =  'SELECT sum(Quantity) from  "Order Details" ' +
    ' WHERE OrderID = :OrderID';

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

procedure TOrderDetailsProxy.Open(aOrderID: integer);
var
  fdq: TFDQuery;
  id: string;
begin
  if not Assigned(FDataSet) then
  begin
    fdq := TFDQuery.Create(nil);
    fdq.SQL.Text := SQL_SELECT_OrderDetails;
    fdq.Connection := GlobalConnector.GetMainConnection;
    FDataSet := fdq;
{$IFDEF CONSOLEAPP}
    WriteLn('Created Order Details object....');
{$ENDIF}
  end;
  (FDataSet as TFDQuery).ParamByName('OrderID').AsInteger := aOrderID;
  FDataSet.Open;
  ConnectFields;
  id := self.OrderID.AsString;
{$IFDEF CONSOLEAPP}
  WriteLn('Order details opened.... OrderID: ', id, 'RecordCount:', FDataSet.RecordCount);
{$ENDIF}
end;

function TOrderDetailsProxy.QuantitySum: Integer;
var
  sum: integer;
begin
  FDataSet.ForEachRow(
   procedure
  begin
    sum := sum + Self.Quantity.AsInteger;
    end
  );
  Result := sum;
end;

end.
