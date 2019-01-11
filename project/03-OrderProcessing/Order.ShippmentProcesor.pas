unit Order.ShippmentProcesor;

interface

uses
  System.Classes,
  Shippment,
  DataProxy.Order,
  Order.Validator;

type
  TShipmentProcessor = class(TComponent)
  private
  public
    procedure ShipOrder (Shippment: TShippment);
  end;

implementation

uses DataProxy.OrderDetails, Data.DataProxy;

procedure TShipmentProcessor.ShipOrder (Shippment: TShippment);
var
  isValid: Boolean;
  OrderDetails: TOrderDetailsProxy;
  Order: TOrderProxy;
  OrderValidator: TOrderValidator;
begin
  OrderValidator := TOrderValidator.Create;
  try
    Order := TOrderProxy.Create(Self);
    Order.Open(Shippment.OrderID);
    OrderDetails := TOrderDetailsProxy.Create(Self);
    OrderDetails.Open(Shippment.OrderID);
    Order.Edit;
    Order.ShippedDate.Value := Shippment.ShipmentDate;
    Order.ShipVia.Value := Shippment.ShipperID;
    isValid := OrderValidator.isValid(Order);
    if isValid then
      Order.Post;
  finally
    OrderValidator.Free;
  end;
{$IFDEF CONSOLEAPP}
  WriteLn('Order has been processed....');
{$ENDIF}
end;

end.
