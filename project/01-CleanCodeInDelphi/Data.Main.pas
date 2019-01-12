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
    __mtabReports: TFDMemTable;
    __mtabReportsReaderId: TIntegerField;
    __mtabReportsISBN: TWideStringField;
    __mtabReportsRating: TIntegerField;
    __mtabReportsOppinion: TWideStringField;
    __mtabReportsReported: TDateField;
    // ------------------------------------------------------
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDConnection1: TFDConnection;
    dsBooks: TFDQuery;
    dsReaders: TFDQuery;
    dsReports: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    __mtabReaders: TFDMemTable;
    __mtabReadersReaderId: TIntegerField;
    __mtabReadersFirstName: TWideStringField;
    __mtabReadersLastName: TWideStringField;
    __mtabReadersEmail: TWideStringField;
    __mtabReadersCompany: TWideStringField;
    __mtabReadersBooksRead: TIntegerField;
    __mtabReadersLastReport: TDateField;
    __mtabReadersCreated: TDateField;
    __mtabBooks: TFDMemTable;
    __mtabBooksISBN: TWideStringField;
    __mtabBooksTitle: TWideStringField;
    __mtabBooksAuthors: TWideStringField;
    __mtabBooksStatus: TWideStringField;
    __mtabBooksReleseDate: TDateField;
    __mtabBooksPages: TIntegerField;
    __mtabBooksPrice: TCurrencyField;
    __mtabBooksCurrency: TWideStringField;
    __mtabBooksImported: TDateField;
    __mtabBooksDescription: TWideStringField;
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
  dsReports.Open();
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
