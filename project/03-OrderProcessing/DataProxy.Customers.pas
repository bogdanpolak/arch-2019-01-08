unit DataProxy.Customers;

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
  TCustomersProxy = class(TDatasetProxy)
  protected
    procedure ConnectFields; override;
  public
    CustomerID: TWideStringField;
    CompanyName: TWideStringField;
    ContactName: TWideStringField;
    ConstacTitle: TWideStringField;
    Address: TWideStringField;
    City: TWideStringField;
    Region: TWideStringField;
    PostalCode: TWideStringField;
    Country: TWideStringField;
    Phone: TWideStringField;
    Fax: TWideStringField;
    procedure Open(OrderID: integer);
    procedure Close;
    // property DataSet: TDataSet read FDataSet;
  end;

implementation

{ TOrder }

uses
  System.SysUtils,
  Database.Connector;

const
  SQL_SELECT = 'SELECT CUSTOMERID, COMPANYNAME, CONTACTNAME, ' +
    ' CONTACTTITLE, ADDRESS, CITY, REGION, POSTALCODE, COUNTRY PHONE, FAX' +
    ' FROM {id Customers} ';

procedure TCustomersProxy.Close;
begin

end;

procedure TCustomersProxy.ConnectFields;
begin
  CustomerID := FDataSet.FieldByName('CustomerID') as TWideStringField;
  CompanyName := FDataSet.FieldByName('CompanyName') as TWideStringField;
  ContactName := FDataSet.FieldByName('ContactName') as TWideStringField;
  ConstacTitle := FDataSet.FieldByName('ConstacTitle') as TWideStringField;
  Address := FDataSet.FieldByName('Address') as TWideStringField;
  City := FDataSet.FieldByName('City') as TWideStringField;
  Region := FDataSet.FieldByName('Region') as TWideStringField;
  PostalCode := FDataSet.FieldByName('PostalCode') as TWideStringField;
  Country := FDataSet.FieldByName('Country') as TWideStringField;
  Phone := FDataSet.FieldByName('Phone') as TWideStringField;
  Fax := FDataSet.FieldByName('Fax') as TWideStringField;
end;

procedure TCustomersProxy.Open(OrderID: integer);
var
  fdq: TFDQuery;
begin
  if not Assigned(FDataSet) then
    raise Exception.Create('The DataSet is required');
  fdq := TFDQuery.Create(nil);
  fdq.SQL.Text := SQL_SELECT;
  fdq.Connection := GlobalConnector.GetMainConnection;
  FDataSet := fdq;
  FDataSet.Open;
  ConnectFields;
end;

end.
