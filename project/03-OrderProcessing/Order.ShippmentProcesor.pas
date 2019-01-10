unit Order.ShippmentProcesor;

interface

uses
  Shippment,
  DataProxy.Order,
  DataProxy.OrderDetails,
  Order.Validator;

type
  TShipmentProcessor = class
  private
    FShippment: TShippment;
    FOrder: TOrderProxy;
//    FOrderDetails: TOrderDetailsProxy;
    FOrderValidator: TOrderValidator;
  public
    constructor Create(aShippment: TShippment);
    destructor Destroy; override;
    procedure ShipCurrentOrder;

  end;

implementation

constructor TShipmentProcessor.Create(aShippment: TShippment);
begin
  FShippment := aShippment;
  FOrder := TOrderProxy.Create(nil);
//  FOrderDetails := TOrderDetailsProxy.Create(nil);
  FOrderValidator := TOrderValidator.Create;
end;

destructor TShipmentProcessor.Destroy;
begin
  FOrder.Close;
  FOrder.Free;
//  FOrderDetails.Free;
  FOrderValidator.Free;
  inherited;
end;

procedure TShipmentProcessor.ShipCurrentOrder;
var
  isValid: Boolean;
begin
  FOrder.Open(FShippment.OrderID);
//  FOrderDetails.Open(FShippment.OrderID);
  isValid := FOrderValidator.isValid(FOrder);
  //if isValid then
  // FOrder.Post;
{$IFDEF CONSOLEAPP}
  if isValid then
    WriteLn('Order has been processed...succefull')
  else
    WriteLn('Order has been processed...failed')
{$ENDIF}

end;

end.
