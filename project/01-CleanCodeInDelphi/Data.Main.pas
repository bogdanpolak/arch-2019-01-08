unit Data.Main;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.StorageJSON, Model.Books, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.DApt;

type
  TDataModMain = class(TDataModule)
    // ------------------------------------------------------
    // Reports Table:
    mtabReports: TFDMemTable;
    mtabReportsReaderId: TIntegerField;
    mtabReportsISBN: TWideStringField;
    mtabReportsRating: TIntegerField;
    mtabReportsOppinion: TWideStringField;
    mtabReportsReported: TDateField;
    // ------------------------------------------------------
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDConnection1: TFDConnection;
    dsBooks: TFDQuery;
    dsReaders: TFDQuery;
    dsReports: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
  private
  public
    BooksFactory: TBooksFactory;
    procedure OpenDataSets;
    function FindReaderByEmil(const email: string): Variant;
  end;

var
  DataModMain: TDataModMain;

const
  EB_Main_Form_UpdateCaption = 1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

uses
  System.Variants, ClientAPI.Books, Helper.TDataSet;

function TDataModMain.FindReaderByEmil(const email: string): Variant;
var
  ok: Boolean;
begin
  ok := dsReaders.Locate('email', email, []);
  if ok then
    Result := dsReaders.FieldByName('ReaderId').Value
  else
    Result := System.Variants.Null()
end;

procedure TDataModMain.OpenDataSets;
begin
  dsBooks.Open();
  dsReaders.Open();
  // ----------------------------------------------------------
  //
  // Reports table
  mtabReports.CreateDataSet;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Transfer Memory Table to FDQuery
  //
  // dsBooks.Open();
  // mtabBooks.ForEachRow( MoveMemToQuery_Books );
  // dsReaders.Open();
  // mtabReaders.ForEachRow( MoveMemToQuery_Readers );
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Create BooksFactory
  BooksFactory := TBooksFactory.Create(Self);
end;

end.
