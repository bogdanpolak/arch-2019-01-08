unit DataProxy.Categories;

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
  TCategoriesProxy = class(TDatasetProxy)
  protected
    procedure ConnectFields; override;
  public
    CategoryID: TIntegerField;
    CategoryName: TWideStringField;
    Description: TWideMemoField;
    Picture: TBlobField;
    procedure Open(OrderID: integer);
    procedure Close;
    // property DataSet: TDataSet read FDataSet;
  end;

implementation

{ TOrder }

uses
  System.SySUtils,
  Database.Connector;

const
  SQL_SELECT = 'SELECT CATEGORYID, CATEGORYNAME. DESCRIPTION, PICTURE ' +
    'FROM {id Categories}';

procedure TCategoriesProxy.Close;
begin

end;

procedure TCategoriesProxy.ConnectFields;
begin
  CategoryID := FDataSet.FieldByName('CATEGORYID') as TIntegerField;
  CategoryName := FDataSet.FieldByName('CATEGORYNAME') as TWideStringField;
  Description := FDataSet.FieldByName('DESCRIPTION') as TWideMemoField;
  Picture := FDataSet.FieldByName('PICTURE') as TBlobField;
end;

procedure TCategoriesProxy.Open(OrderID: integer);
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
