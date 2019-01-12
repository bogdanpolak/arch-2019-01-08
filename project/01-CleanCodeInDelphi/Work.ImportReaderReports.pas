unit Work.ImportReaderReports;

interface

uses
  System.JSON,
  Data.DB,
  MVC.Work;

type
  TReaderReport = record
    email: string;
    firstName: string;
    lastName: string;
    company: string;
    bookISBN: string;
    bookTitle: string;
    rating: Integer;
    oppinion: string;
    // TODO: Poprawiæ nazwê pola
    dtReported: TDateTime;
  end;

type
  TImportReaderReportsWork = class(TWork)
    function DoWork: boolean; override;
  private
  // --------
    const
    Client_API_Token = '20be805d-9cea27e2-a588efc5-1fceb84d-9fb4b67c';
    procedure ImportNewBooksFromOpenAPI;
    procedure InsertJsonBooksToDataset(jsBooks: TJSONArray; DataSet: TDataSet);
    function BooksToDateTime(const s: string): TDateTime;
    function AppendNewReaderIntoDatabase(ReaderReport: TReaderReport): Integer;
    procedure AppendNewReportIntoDatabase(readerId: Integer;
      ReaderReport: TReaderReport);
    function GetJsonReaderReport(jsReaderReport: TJSONObject): TReaderReport;
    procedure ImportNewReaderReportsFromOpenAPI;
    procedure InsertReaderReportToDatabase(ReaderReport: TReaderReport);
    procedure LocateBookByISBN(ReaderReport: TReaderReport);
    procedure ValidateJsonReaderReport(jsRow: TJSONObject);
  end;

implementation

uses
  System.Variants,
  System.SysUtils,
  ClientAPI.Books,
  Data.Main,
  Model.Books, ClientAPI.Readers, Utils.General, Helper.TJSONObject,
  Helper.TDataSet, Messaging.EventBus;

function TImportReaderReportsWork.BooksToDateTime(const s: string): TDateTime;
const
  months: array [1 .. 12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
  m: string;
  y: string;
  i: Integer;
  mm: Integer;
  yy: Integer;
begin
  m := s.Substring(0, 3);
  y := s.Substring(4);
  mm := 0;
  for i := 1 to 12 do
    if months[i].ToUpper = m.ToUpper then
      mm := i;
  if mm = 0 then
    raise ERangeError.Create('Incorect mont name in the date: ' + s);
  yy := y.ToInteger();
  Result := EncodeDate(yy, mm, 1);
end;


// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
//
// Import new Books data from OpenAPI
//
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

procedure TImportReaderReportsWork.ImportNewBooksFromOpenAPI;
var
  jsBooks: TJSONArray;
begin
  jsBooks := ImportBooksFromWebService(Client_API_Token);
  try
    InsertJsonBooksToDataset(jsBooks, DataModMain.dsBooks);
  finally
    jsBooks.Free;
  end;
end;

procedure TImportReaderReportsWork.InsertJsonBooksToDataset(jsBooks: TJSONArray;
  DataSet: TDataSet);
var
  jsBook: TJSONObject;
  TextBookReleseDate: string;
  b: TBook;
  b2: TBook;
  i: Integer;
begin
  for i := 0 to jsBooks.Count - 1 do
  begin
    jsBook := jsBooks.Items[i] as TJSONObject;
    b := TBook.Create;
    b.status := jsBook.Values['status'].Value;
    b.title := jsBook.Values['title'].Value;
    b.isbn := jsBook.Values['isbn'].Value;
    b.author := jsBook.Values['author'].Value;
    TextBookReleseDate := jsBook.Values['date'].Value;
    b.releseDate := BooksToDateTime(TextBookReleseDate);
    b.pages := (jsBook.Values['pages'] as TJSONNumber).AsInt;
    b.price := StrToCurr(jsBook.Values['price'].Value);
    b.currency := jsBook.Values['currency'].Value;
    b.description := jsBook.Values['description'].Value;
    b.imported := Now;
    b2 := DataModMain.BooksFactory.GetBookList(blkAll).FindByISBN(b.isbn);
    if not Assigned(b2) then
    begin
      DataModMain.BooksFactory.InsertBook(b);
      // ----------------------------------------------------------------
      // Append report into the database:
      // Fields: ISBN, Title, Authors, Status, ReleseDate, Pages, Price,
      // Currency, Imported, Description
      DataSet.InsertRecord([b.isbn, b.title, b.author, b.status, b.releseDate,
        b.pages, b.price, b.currency, b.imported, b.description]);
    end;
  end;
end;


// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
//
// Import new Books data from OpenAPI
//
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

procedure TImportReaderReportsWork.ImportNewReaderReportsFromOpenAPI;
var
  jsData: TJSONArray;
  i: Integer;
  jsReaderReport: TJSONObject;
  ss: array of string;
  ReaderReport: TReaderReport;
  AMessage: TEventMessage;
begin
  jsData := ImportReaderReportsFromWebService(Client_API_Token);
  try
    for i := 0 to jsData.Count - 1 do
    begin
      jsReaderReport := jsData.Items[i] as TJSONObject;
      ValidateJsonReaderReport(jsReaderReport);
      ReaderReport := GetJsonReaderReport(jsReaderReport);
      InsertReaderReportToDatabase(ReaderReport);
      ss := ss + [ReaderReport.rating.ToString];
    end;
     AMessage.TagString := String.Join(' ,', ss);
     TEventBus._Post(EB_Main_Form_UpdateCaption, AMessage );
  finally
    jsData.Free;
  end;
end;

procedure TImportReaderReportsWork.ValidateJsonReaderReport(jsRow: TJSONObject);
var
  email: string;
begin
  email := jsRow.Values['email'].Value;
  if not CheckEmail(email) then
    raise Exception.Create('Invalid email addres');
  if not jsRow.IsValidIsoDateUtc('created') then
    raise Exception.Create('Invalid date. Expected ISO format')
end;

function TImportReaderReportsWork.GetJsonReaderReport(jsReaderReport
  : TJSONObject): TReaderReport;
begin
  with Result do
  begin
    email := jsReaderReport.GetPairValueAsString('email');
    firstName := jsReaderReport.GetPairValueAsString('firstName');
    lastName := jsReaderReport.GetPairValueAsString('lastname');
    company := jsReaderReport.GetPairValueAsString('company');
    bookISBN := jsReaderReport.GetPairValueAsString('book-isbn');
    bookTitle := jsReaderReport.GetPairValueAsString('book-title');
    rating := jsReaderReport.GetPairValueAsInteger('rating');
    oppinion := jsReaderReport.GetPairValueAsString('oppinion');
    dtReported := jsReaderReport.GetPairValueAsUtcDate('created');
  end;
end;

procedure TImportReaderReportsWork.InsertReaderReportToDatabase
  (ReaderReport: TReaderReport);
var
  VarReaderId: Variant;
  readerId: Integer;
begin
  LocateBookByISBN(ReaderReport);
  VarReaderId := DataModMain.FindReaderByEmil(ReaderReport.email);
  if VarReaderId = Null then
    readerId := AppendNewReaderIntoDatabase(ReaderReport)
  else
    readerId := VarReaderId;
  AppendNewReportIntoDatabase(readerId, ReaderReport);
end;

procedure TImportReaderReportsWork.LocateBookByISBN(ReaderReport
  : TReaderReport);
var
  b: TBook;
begin
  b :=DataModMain.BooksFactory.FindBook(ReaderReport.bookISBN);
  if not Assigned(b) then
    raise Exception.Create('Invalid book isbn');
end;

function TImportReaderReportsWork.AppendNewReaderIntoDatabase
  (ReaderReport: TReaderReport): Integer;
var
  readerId: Integer;
begin
  readerId := DataModMain.dsReaders.GetMaxValue('ReaderId') + 1;
  //
  // Fields: ReaderId, FirstName, LastName, Email, Company, BooksRead,
  // LastReport, ReadersCreated
  //
  DataModMain.dsReaders.AppendRecord([readerId, ReaderReport.firstName,
    ReaderReport.lastName, ReaderReport.email, ReaderReport.company, 1,
    ReaderReport.dtReported, Now]);
  Result := readerId;
end;

procedure TImportReaderReportsWork.AppendNewReportIntoDatabase
  (readerId: Integer; ReaderReport: TReaderReport);
begin
  // ----------------------------------------------------------------
  //
  // Append report into the database:
  // Fields: ReaderId, ISBN, Rating, Oppinion, Reported
  //
  DataModMain.dsReports.AppendRecord([readerId, ReaderReport.bookISBN,
    ReaderReport.rating, ReaderReport.oppinion, ReaderReport.dtReported]);
end;


// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

function TImportReaderReportsWork.DoWork: boolean;
begin
  inherited;
  ImportNewBooksFromOpenAPI;
  ImportNewReaderReportsFromOpenAPI;
  Result := True;
end;

end.
