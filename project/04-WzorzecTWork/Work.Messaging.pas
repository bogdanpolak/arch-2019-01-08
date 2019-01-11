unit Work.Messaging;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.ExtCtrls,
  MVC.Work,
  Module.MessagingWork;

type
  TNotShippedOrders = record
    FOrdes: array of String;
    function ToString: String;
  end;

type
  TMessagingWork = class(TWork)
  private
    FWorkerTimer: TTimer;
    Data: TNotShippedOrders;
    FOrdersModule: TModuleOrders;
    FInProgress: boolean;
    procedure WorkerTimerEvent(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function DoWork: boolean; override;
  end;

implementation

uses
  Messaging.EventBus;

{ TMessagingWork }

constructor TMessagingWork.Create(AOwner: TComponent);
begin
  inherited;
  FOrdersModule := TModuleOrders.Create(Self);
  FWorkerTimer := TTimer.Create(Self);
  FWorkerTimer.Enabled := False;
  FWorkerTimer.Interval := 20;
  FWorkerTimer.OnTimer := WorkerTimerEvent;
  Caption := '[Work2] Start getting data';
end;

destructor TMessagingWork.Destroy;
begin
  inherited;

end;

function TMessagingWork.DoWork: boolean;
var
  isBusy: boolean;
begin
  isBusy := FWorkerTimer.Enabled;
  if isBusy then
    Caption := 'Just working ... I''m busy now!'
  else
  begin
    FOrdersModule.qOrders.First;
    SetLength(Data.FOrdes, 0);
    FWorkerTimer.Tag := 0;
    FWorkerTimer.Enabled := True;
  end;
  Result := True;
end;

{ TNotShippedOrders }

function TNotShippedOrders.ToString: String;
var
  S: String;
begin
  Result := '';
  for S in FOrdes do
  begin
    Result := Result + ', ' + S;
  end;
end;


procedure TMessagingWork.WorkerTimerEvent(Sender: TObject);
var
  isFoundNotShipped: boolean;
  StrOrderId: string;
  AMessage: TEventMessage;
begin
  isFoundNotShipped := FOrdersModule.LocateNearestNotShippedOrder();
  if isFoundNotShipped then
  begin
    StrOrderId := FOrdersModule.qOrdersOrderID.Value.ToString;
    Caption := 'Order: ' + StrOrderId;
    Data.FOrdes := Data.FOrdes + [StrOrderId];
    FOrdersModule.qOrders.Next;
  end
  else
  begin
    FWorkerTimer.Enabled := False;
    Caption := 'Done';
    AMessage.TagString := Data.ToString;
    TEventBus._Post(1,AMessage);
  end;
end;

end.
