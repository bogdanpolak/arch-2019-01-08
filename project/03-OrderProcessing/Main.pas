unit Main;

interface

procedure MainProc;

implementation

uses
  System.SysUtils,
  Shippment,
  DataProxy.Order,
  Order.ShippmentProcesor,
  Database.Connector,
  Database.Connector.Interbase;

procedure MainProc;
var
  Shippment: TShippment;
  processor: TShipmentProcessor;
begin
  GlobalConnector := TInterbaseDatabaseConnector.Create;
  processor := TShipmentProcessor.Create(nil);
  try
    Shippment.OrderID := 11077;
    Shippment.ShipmentDate := Int(Now());
    Shippment.ShipperID := 3;
    processor.ShipOrder(Shippment);
    WriteLn('Order successfully processed....');
  finally
    processor.Free;
  end;
end;

end.
