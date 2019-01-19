unit Work.Messaging;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.ExtCtrls,
  Pattern.Work;

type
  TOrders = record
    FOrdes: array of String;
    function ToString: String;
  end;

type
  TMessagingWork = class(TWork)
  private
    FForEachOrderDelay: word;
    FInProgress: boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function DoWork: boolean; override;
    property InProgress: boolean read FInProgress;
  end;

implementation

uses
  System.Threading,
  Pattern.EventBus,
  Module.MessagingWork;

{ TOrders }

function TOrders.ToString: String;
var
  S: String;
begin
  Result := '';
  for S in FOrdes do
  begin
    if Result = '' then
      Result := S
    else
      Result := Result + ', ' + S;
  end;

end;

{ TMessagingWork }

constructor TMessagingWork.Create(AOwner: TComponent);
begin
  inherited;
  FInProgress := False;
  FForEachOrderDelay := 60;
  Caption := '[Work2] Start getting data';
end;

destructor TMessagingWork.Destroy;
begin
  inherited;

end;

function ISODateStringToDate(const DateStr: String): TDateTime;
var
  AFormatSettings: TFormatSettings;
begin
  AFormatSettings := TFormatSettings.Create;
  AFormatSettings.DateSeparator := '-';
  AFormatSettings.ShortDateFormat := 'yyyy.mm.dd';
  Result := StrToDate(DateStr, AFormatSettings);
end;

function TMessagingWork.DoWork: boolean;
var
  isBusy: boolean;
  dtDay: TDateTime;
begin
  Action.Enabled := False;
  FInProgress := True;
  dtDay := ISODateStringToDate('1998-06-01');
  TEventBus._PostString(1, ' ... ');
  TTask.Run(
    procedure()
    var
      OrdersModule: TModuleOrders;
      StrOrderId: string;
      NotShippedOrders: TOrders;
    begin
      OrdersModule := TModuleOrders.Create(Self);
      OrdersModule.fdqOrders.ParamByName('ADAY').AsDate := dtDay;
      OrdersModule.fdqOrders.Open();
      while not OrdersModule.fdqOrders.Eof do
      begin
        StrOrderId := OrdersModule.fdqOrders.FieldByName('OrderID').AsString;
        System.Classes.TThread.Synchronize(nil,
          procedure()
          begin
            Caption := 'Order: ' + StrOrderId;
          end);
        NotShippedOrders.FOrdes := NotShippedOrders.FOrdes + [StrOrderId];
        OrdersModule.fdqOrders.Next;
        sleep (FForEachOrderDelay);
      end;
      OrdersModule.Free;
      System.Classes.TThread.Synchronize(nil,
        procedure()
        begin
          Caption := 'Done';
          TEventBus._PostString(1, NotShippedOrders.ToString);
          Action.Enabled := True;
        end);
    end);
  FInProgress := False;
  Result := True;
end;

end.
