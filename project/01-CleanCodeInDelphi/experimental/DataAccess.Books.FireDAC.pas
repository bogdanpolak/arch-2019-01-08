unit DataAccess.Books.FireDAC;

interface

uses
  Data.DB, System.SysUtils, FireDAC.Comp.DataSet,
  DataAccess.Base, DataAccess.Books;

type
  TFDBooksDAO = class(TBaseDAO, IBooksDAO)
  strict private
    FFieldISBN: TStringField;
    FFieldTitle: TStringField;
    FFieldAuthors: TStringField;
    FFieldStatus: TStringField;
    FFieldReleseDate: TDateField;
    FFieldPages: TIntegerField;
    FFieldPrice: TBCDField;
    FFieldCurrency: TStringField;
    FFieldImported: TDateTimeField;
    FFieldDescription: TStringField;
  strict protected
    procedure BindDataSetFields(); override;
  public
    constructor Create(DataSet: TFDDataSet);
    function fldISBN: TStringField;
    function fldTitle: TStringField;
    function fldAuthors: TStringField;
    function fldStatus: TStringField;
    function fldReleseDate: TDateField;
    function fldPages: TIntegerField;
    function fldPrice: TBCDField;
    function fldCurrency: TStringField;
    function fldImported: TDateTimeField;
    function fldDescription: TStringField;
    procedure ForEach(proc: TProc<IBooksDAO>);
  end;

function GetBooks_FireDAC(DataSet: TFDDataSet): IBooksDAO;

implementation

procedure TFDBooksDAO.BindDataSetFields;
begin
  if Assigned(FDataSet) and FDataSet.Active then
  begin
    FFieldISBN := FDataSet.FieldByName('ISBN') as TStringField;
    FFieldTitle := FDataSet.FieldByName('Title') as TStringField;
    FFieldAuthors := FDataSet.FieldByName('Authors') as TStringField;
    FFieldStatus := FDataSet.FieldByName('Status') as TStringField;
    FFieldReleseDate := FDataSet.FieldByName('ReleseDate') as  TDateField;
    FFieldPages := FDataSet.FieldByName('Pages') as TIntegerField;
    FFieldPrice := FDataSet.FieldByName('Price') as TBCDField;
    FFieldCurrency := FDataSet.FieldByName('Currency') as TStringField;
    FFieldImported := FDataSet.FieldByName('Imported') as TDateTimeField;
    FFieldDescription := FDataSet.FieldByName('Description') as TStringField;
  end
  else
    raise Exception.Create('Error Message');
end;

constructor TFDBooksDAO.Create(DataSet: TFDDataSet);
begin
  inherited Create();
  LinkDataSet(DataSet, true);
end;


function TFDBooksDAO.fldAuthors: TStringField;
begin
  Result := FFieldISBN;
end;

function TFDBooksDAO.fldCurrency: TStringField;
begin
  Result := FFieldCurrency
end;

function TFDBooksDAO.fldDescription: TStringField;
begin
  Result := FFieldDescription
end;

function TFDBooksDAO.fldImported: TDateTimeField;
begin
  Result := FFieldImported;
end;

function TFDBooksDAO.fldISBN: TStringField;
begin
  Result := FFieldISBN;
end;

function TFDBooksDAO.fldPages: TIntegerField;
begin
  Result := FFieldPages;
end;

function TFDBooksDAO.fldPrice: TBCDField;
begin
  Result := FFieldPrice;
end;

function TFDBooksDAO.fldReleseDate: TDateField;
begin
  Result := FFieldReleseDate;
end;

function TFDBooksDAO.fldStatus: TStringField;
begin
  Result := FFieldStatus;
end;

function TFDBooksDAO.fldTitle: TStringField;
begin
  Result := FFieldTitle;
end;

procedure TFDBooksDAO.ForEach(proc: TProc<IBooksDAO>);
begin
  FDataSet.First;
  while not FDataSet.Eof do
  begin
    proc(self);
    FDataSet.Next;
  end;
end;

function GetBooks_FireDAC(DataSet: TFDDataSet): IBooksDAO;
begin
  Result := TFDBooksDAO.Create(DataSet);
end;

end.
