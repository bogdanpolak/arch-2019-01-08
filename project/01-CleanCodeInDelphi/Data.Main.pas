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
    // Readers Table:
    mtabReaders: TFDMemTable;
    mtabReadersReaderId: TIntegerField;
    mtabReadersFirstName: TWideStringField;
    mtabReadersLastName: TWideStringField;
    mtabReadersEmail: TWideStringField;
    mtabReadersCompany: TWideStringField;
    mtabReadersBooksRead: TIntegerField;
    mtabReadersLastReport: TDateField;
    mtabReadersCreated: TDateField;
    // ------------------------------------------------------
    // Reports Table:
    mtabReports: TFDMemTable;
    mtabReportsReaderId: TIntegerField;
    mtabReportsISBN: TWideStringField;
    mtabReportsRating: TIntegerField;
    mtabReportsOppinion: TWideStringField;
    mtabReportsReported: TDateField;
    // ------------------------------------------------------
    // Books Table:
    mtabBooks: TFDMemTable;
    mtabBooksISBN: TWideStringField;
    mtabBooksTitle: TWideStringField;
    mtabBooksAuthors: TWideStringField;
    mtabBooksStatus: TWideStringField;
    mtabBooksReleseDate: TDateField;
    mtabBooksPages: TIntegerField;
    mtabBooksPrice: TCurrencyField;
    mtabBooksCurrency: TWideStringField;
    mtabBooksImported: TDateField;
    mtabBooksDescription: TWideStringField;
    // ------------------------------------------------------
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    FDConnection1: TFDConnection;
    dsBooks: TFDQuery;
    dsReaders: TFDQuery;
    dsReports: TFDQuery;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
  private
    procedure MoveMemToQuery_Books;
    procedure MoveMemToQuery_Readers;
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
  ok := mtabReaders.Locate('email', email, []);
  if ok then
    Result := mtabReadersReaderId.Value
  else
    Result := System.Variants.Null()
end;

procedure TDataModMain.MoveMemToQuery_Books;
begin
  dsBooks.Insert;
  dsBooks.FieldByName('ISBN').Value := mtabBooksISBN.Value;
  dsBooks.FieldByName('Title').Value := mtabBooksTitle.Value;
  dsBooks.FieldByName('Authors').Value := mtabBooksAuthors.Value;
  dsBooks.FieldByName('Status').Value := mtabBooksStatus.Value;
  dsBooks.FieldByName('ReleseDate').Value := mtabBooksReleseDate.Value;
  dsBooks.FieldByName('Pages').Value := mtabBooksPages.Value;
  dsBooks.FieldByName('Price').Value := mtabBooksPrice.Value;
  dsBooks.FieldByName('Currency').Value := mtabBooksCurrency.Value;
  dsBooks.FieldByName('Imported').Value := mtabBooksImported.Value;
  dsBooks.FieldByName('Description').Value := mtabBooksDescription.Value;
  dsBooks.Post;
end;

procedure TDataModMain.MoveMemToQuery_Readers;
begin
  dsReaders.Insert;
  dsReaders.FieldByName('ReaderId').Value := mtabReadersReaderId.Value;
  dsReaders.FieldByName('FirstName').Value := mtabReadersFirstName.Value;
  dsReaders.FieldByName('LastName').Value := mtabReadersLastName.Value;
  dsReaders.FieldByName('Email').Value := mtabReadersEmail.Value;
  dsReaders.FieldByName('Company').Value := mtabReadersCompany.Value;
  dsReaders.FieldByName('BooksRead').Value := mtabReadersBooksRead.Value;
  dsReaders.FieldByName('LastReport').Value := mtabReadersLastReport.Value;
  dsReaders.FieldByName('Created').Value := mtabReadersCreated.Value;
  dsReaders.Post;
end;

procedure TDataModMain.OpenDataSets;
var
  JSONFileName: string;
  fname: string;
begin
  { TODO 2: Repeated code. Violation of the DRY rule }
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Load and open Readers table
  JSONFileName := 'json\dbtable-readers.json';
  if FileExists(JSONFileName) then
    fname := JSONFileName
  else if FileExists('..\..\' + JSONFileName) then
    fname := '..\..\' + JSONFileName
  else
    raise Exception.Create('Error Message');
  mtabReaders.LoadFromFile(fname, sfJSON);
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Load and open Books table
  JSONFileName := 'json\dbtable-books.json';
  if FileExists(JSONFileName) then
    fname := JSONFileName
  else if FileExists('..\..\' + JSONFileName) then
    fname := '..\..\' + JSONFileName
  else
    raise Exception.Create('Error Message');
  mtabBooks.LoadFromFile(fname, sfJSON);
  // ----------------------------------------------------------
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
