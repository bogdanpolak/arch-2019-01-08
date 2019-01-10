unit Form.Main;

interface

uses
  Winapi.Windows, System.Classes, Vcl.StdCtrls, Vcl.Controls, Vcl.Forms,
  Vcl.ExtCtrls, Data.DB,
  ChromeTabs, ChromeTabsClasses, ChromeTabsTypes,
  System.JSON,
  Fake.FDConnection,
  {TODO 3: [D] Resolve dependency on ExtGUI.ListBox.Books. Too tightly coupled}
  // Dependency is requred by attribute TBooksListBoxConfigurator
  ExtGUI.ListBox.Books;

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
    // TODO: Poprawić nazwę pola
    dtReported: TDateTime;
  end;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    lbBooksReaded: TLabel;
    Splitter1: TSplitter;
    lbBooksAvaliable: TLabel;
    lbxBooksReaded: TListBox;
    lbxBooksAvaliable2: TListBox;
    ChromeTabs1: TChromeTabs;
    pnMain: TPanel;
    btnImport: TButton;
    tmrAppReady: TTimer;
    Splitter2: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure ChromeTabs1ButtonCloseTabClick(Sender: TObject; ATab: TChromeTab;
      var Close: Boolean);
    procedure ChromeTabs1Change(Sender: TObject; ATab: TChromeTab;
      TabChangeType: TTabChangeType);
    procedure FormResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure tmrAppReadyTimer(Sender: TObject);
  private
    FBooksConfig: TBooksListBoxConfigurator;
    FIsDeveloperMode: Boolean;
    procedure AutoHeightBookListBoxes();
    procedure InjectBooksDBGrid(aParent: TWinControl);
    // --------------
    function CreateFrameAndAddChromeTab<T: TFrame>(const Caption: String): T;
    // --------------
    procedure ImporNewBooksFromOpenAPI;
    procedure InsertJsonBooksToDataset(jsBooks: TJSONArray; DataSet: TDataSet);
    // --------------
    procedure ImportNewReaderReportsFromOpenAPI;
    procedure ValidateJsonReaderReport(jsRow: TJSONObject);
    function GetJsonReaderReport(jsReaderReport: TJSONObject): TReaderReport;
    procedure InsertReaderReportToDatabase(ReaderReport: TReaderReport);
    procedure LocateBookByISBN(ReaderReport: TReaderReport);
    function AppendNewReaderIntoDatabase(ReaderReport: TReaderReport): Integer;
    procedure AppendNewReportIntoDatabase(readerId: Integer;
      ReaderReport: TReaderReport);
    // --------------
  public
    FDConnection1: TFDConnectionMock;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.StrUtils, System.Math, System.DateUtils, System.SysUtils,
  System.RegularExpressions,
  Vcl.DBGrids,
  System.Variants, Vcl.Graphics,
  System.Generics.Collections,
  // ----------------------------------------------------------------------
  Helper.TDataSet,
  Helper.TJSONObject,
  Helper.TWinControl,
  Helper.TApplication,
  // ----------------------------------------------------------------------
  Consts.Application,
  Utils.CipherAES128,
  Utils.General,
  Data.Main,
  ClientAPI.Readers,
  ClientAPI.Books,
  Frame.Import,
  Frame.Welcome, Helper.TDBGrid;

const
  IsInjectBooksDBGridInWelcomeFrame = True;

const
  SQL_SelectDatabaseVersion = 'SELECT versionnr FROM DBInfo';

const
  SecureKey = 'delphi-is-the-best';
  // SecurePassword = AES 128 ('masterkey',SecureKey)
  SecurePassword = 'hC52IiCv4zYQY2PKLlSvBaOXc14X41Mc1rcVS6kyr3M=';
  Client_API_Token = '20be805d-9cea27e2-a588efc5-1fceb84d-9fb4b67c';

resourcestring
  SWelcomeScreen = 'Welcome screen';
  SDBServerGone = 'Database server is gone';
  SDBConnectionUserPwdInvalid = 'Invalid database configuration.' +
    ' Application database user or password is incorrect.';
  SDBConnectionError = 'Can''t connect to database server. Unknown error.';
  SDBRequireCreate = 'Database is empty. You need to execute script' +
    ' creating required data.';
  SDBErrorSelect = 'Can''t execute SELECT command on the database';
  StrNotSupportedDBVersion = 'Not supported database version. Please' +
    ' update database structures.';

function DBVersionToString(VerDB: Integer): string;
begin
  Result := (VerDB div 1000).ToString + '.' + (VerDB mod 1000).ToString;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  AutoHeightBookListBoxes();
end;

// ----------------------------------------------------------
//
// Function checks is TJsonObject has field and this field has not null value
//

function BooksToDateTime(const s: string): TDateTime;
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

{ TODO 2: Method is too large. Comments is showing separate methods }
procedure TForm1.btnImportClick(Sender: TObject);
var
  frm: TFrameImport;
  DBGrid1: TDBGrid;
  DataSrc1: TDataSource;
  DBGrid2: TDBGrid;
  DataSrc2: TDataSource;
begin
  ImporNewBooksFromOpenAPI;
  ImportNewReaderReportsFromOpenAPI;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Dynamically Add TDBGrid to TFrameImport
  //
  frm := CreateFrameAndAddChromeTab<TFrameImport>('Readers');
  { TODO 2: discuss TDBGrid dependencies }
  DataSrc1 := TDataSource.Create(frm);
  DBGrid1 := TDBGrid.Create(frm);
  DBGrid1.AlignWithMargins := True;
  DBGrid1.Parent := frm;
  DBGrid1.Align := alClient;
  DBGrid1.DataSource := DataSrc1;
  DataSrc1.DataSet := DataModMain.mtabReaders;
  DBGrid1.AutoResizeAllColumnsWidth();
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  with TSplitter.Create(frm) do
  begin
    Align := alBottom;
    Parent := frm;
    Height := 5;
  end;
  DBGrid1.Margins.Bottom := 0;
  DataSrc2 := TDataSource.Create(frm);
  DBGrid2 := TDBGrid.Create(frm);
  DBGrid2.AlignWithMargins := True;
  DBGrid2.Parent := frm;
  DBGrid2.Align := alBottom;
  DBGrid2.Height := frm.Height div 3;
  DBGrid2.DataSource := DataSrc2;
  DataSrc2.DataSet := DataModMain.mtabReports;
  DBGrid2.Margins.Top := 0;
  DBGrid2.AutoResizeAllColumnsWidth();
end;

procedure TForm1.ChromeTabs1ButtonCloseTabClick(Sender: TObject;
  ATab: TChromeTab; var Close: Boolean);
var
  obj: TObject;
begin
  obj := TObject(ATab.Data);
  (obj as TFrame).Free;
end;

procedure TForm1.ChromeTabs1Change(Sender: TObject; ATab: TChromeTab;
  TabChangeType: TTabChangeType);
var
  obj: TObject;
begin
  if Assigned(ATab) then
  begin
    obj := TObject(ATab.Data);
    if (TabChangeType = tcActivated) and Assigned(obj) then
    begin
      HideAllChildFrames(pnMain);
      (obj as TFrame).Visible := True;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  // ----------------------------------------------------------
  // Check: If we are in developer mode
  //
  // Developer mode id used to change application configuration
  // during test

  FIsDeveloperMode := Application.IsDevelopeMode;

  pnMain.Caption := '';
end;

procedure TForm1.AutoHeightBookListBoxes();
var
  sum: Integer;
  avaliable: Integer;
  labelPixelHeight: Integer;
begin
  { TODO 3: Move into TBooksListBoxConfigurator }
  with TBitmap.Create do
  begin
    Canvas.Font.Size := GroupBox1.Font.Height;
    labelPixelHeight := Canvas.TextHeight('Zg');
    Free;
  end;
  sum := GroupBox1.SumHeightForChildrens([lbxBooksReaded, lbxBooksAvaliable2]);
  avaliable := GroupBox1.Height - sum - labelPixelHeight;
  if GroupBox1.AlignWithMargins then
    avaliable := avaliable - GroupBox1.Padding.Top - GroupBox1.Padding.Bottom;
  if lbxBooksReaded.AlignWithMargins then
    avaliable := avaliable - lbxBooksReaded.Margins.Top -
      lbxBooksReaded.Margins.Bottom;
  if lbxBooksAvaliable2.AlignWithMargins then
    avaliable := avaliable - lbxBooksAvaliable2.Margins.Top -
      lbxBooksAvaliable2.Margins.Bottom;
  lbxBooksReaded.Height := avaliable div 2;
end;

procedure TForm1.InjectBooksDBGrid(aParent: TWinControl);
var
  datasrc: TDataSource;
  DataGrid: TDBGrid;
begin
  begin
    datasrc := TDataSource.Create(aParent);
    DataGrid := TDBGrid.Create(aParent);
    DataGrid.AlignWithMargins := True;
    DataGrid.Parent := aParent;
    DataGrid.Align := alClient;
    DataGrid.DataSource := datasrc;
    datasrc.DataSet := DataModMain.mtabBooks;
    DataGrid.AutoResizeAllColumnsWidth();
  end;
end;

function TForm1.CreateFrameAndAddChromeTab<T>(const Caption: String): T;
var
  frm: T;
  tab: TChromeTab;
begin
  frm := T.Create(pnMain);
  frm.Parent := pnMain;
  frm.Visible := True;
  frm.Align := alClient;
  tab := ChromeTabs1.Tabs.Add;
  tab.Caption := Caption;
  tab.Data := pointer(frm);
  Result := frm;
end;

procedure TForm1.Splitter1Moved(Sender: TObject);
begin
  (Sender as TSplitter).Tag := 1;
end;

procedure TForm1.tmrAppReadyTimer(Sender: TObject);
var
  frm: TFrameWelcome;
  VersionNr: Integer;
  msg1: string;
  UserName: string;
  password: string;
  res: Variant;
begin
  tmrAppReady.Enabled := False;
  if FIsDeveloperMode then
    ReportMemoryLeaksOnShutdown := True;

  frm := CreateFrameAndAddChromeTab<TFrameWelcome>('Welcome');
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // Connect to database server
  // Check application user and database structure (DB version)
  //
  try
    UserName := FDManager.ConnectionDefs.ConnectionDefByName
      (FDConnection1.ConnectionDefName).Params.UserName;
    password := AES128_Decrypt(SecurePassword, SecureKey);
    FDConnection1.Open(UserName, password);
  except
    on E: EFDDBEngineException do
    begin
      case E.kind of
        ekUserPwdInvalid:
          msg1 := SDBConnectionUserPwdInvalid;
        ekServerGone:
          msg1 := SDBServerGone;
      else
        msg1 := SDBConnectionError
      end;
      frm.AddInfo(0, msg1, True);
      frm.AddInfo(1, E.Message, False);
      exit;
    end;
  end;
  try
    res := FDConnection1.ExecSQLScalar(SQL_SelectDatabaseVersion);
  except
    on E: EFDDBEngineException do
    begin
      msg1 := IfThen(E.kind = ekObjNotExists, SDBRequireCreate, SDBErrorSelect);
      frm.AddInfo(0, msg1, True);
      frm.AddInfo(1, E.Message, False);
      exit;
    end;
  end;
  VersionNr := res;
  if VersionNr <> ExpectedDatabaseVersionNr then
  begin
    frm.AddInfo(0, StrNotSupportedDBVersion, True);
    frm.AddInfo(1, 'Oczekiwana wersja bazy: ' +
      DBVersionToString(ExpectedDatabaseVersionNr), True);
    frm.AddInfo(1, 'Aktualna wersja bazy: ' + DBVersionToString
      (VersionNr), True);
  end;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  DataModMain.OpenDataSets;
  // ----------------------------------------------------------
  // ----------------------------------------------------------
  //
  // * Initialize ListBox'es for books
  // * Load books form database
  // * Setup drag&drop functionality for two list boxes
  // * Setup OwnerDraw mode
  //
  FBooksConfig := TBooksListBoxConfigurator.Create(self);
  FBooksConfig.PrepareListBoxes(lbxBooksReaded, lbxBooksAvaliable2);
  // ----------------------------------------------------------
  // ----------------------------`------------------------------
  //
  // Create Books Grid for Quality Tests
  if FIsDeveloperMode and IsInjectBooksDBGridInWelcomeFrame then
    InjectBooksDBGrid(frm);
end;

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
//
// Import new Books data from OpenAPI
//
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

procedure TForm1.ImporNewBooksFromOpenAPI;
var
  jsBooks: TJSONArray;
begin
  jsBooks := ImportBooksFromWebService(Client_API_Token);
  try
    InsertJsonBooksToDataset(jsBooks, DataModMain.mtabBooks);
  finally
    jsBooks.Free;
  end;
end;

procedure TForm1.InsertJsonBooksToDataset(jsBooks: TJSONArray;
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
    b2 := FBooksConfig.GetBookList(blkAll).FindByISBN(b.isbn);
    if not Assigned(b2) then
    begin
      FBooksConfig.InsertNewBook(b);
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

procedure TForm1.ImportNewReaderReportsFromOpenAPI;
var
  jsData: TJSONArray;
  i: Integer;
  jsReaderReport: TJSONObject;
  ss: array of string;
  ReaderReport: TReaderReport;
begin
  jsData := ImportReaderReportsFromWebService(Client_API_Token);
  try
    for i := 0 to jsData.Count - 1 do
    begin
      jsReaderReport := jsData.Items[i] as TJSONObject;
      ValidateJsonReaderReport(jsReaderReport);
      ReaderReport := GetJsonReaderReport(jsReaderReport);
      InsertReaderReportToDatabase(ReaderReport);
      if FIsDeveloperMode then
        Insert([ReaderReport.rating.ToString], ss, maxInt);
    end;
    if FIsDeveloperMode then
      Caption := String.Join(' ,', ss);
  finally
    jsData.Free;
  end;
end;

procedure TForm1.ValidateJsonReaderReport(jsRow: TJSONObject);
var
  email: string;
begin
  email := jsRow.Values['email'].Value;
  if not CheckEmail(email) then
    raise Exception.Create('Invalid email addres');
  if not jsRow.IsValidIsoDateUtc('created') then
    raise Exception.Create('Invalid date. Expected ISO format')
end;

function TForm1.GetJsonReaderReport(jsReaderReport: TJSONObject): TReaderReport;
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

procedure TForm1.InsertReaderReportToDatabase(ReaderReport: TReaderReport);
var
  VarReaderId: Variant;
  ReaderId: Integer;
begin
  LocateBookByISBN(ReaderReport);
  VarReaderId := DataModMain.FindReaderByEmil(ReaderReport.email);
  if VarReaderId = Null then
    ReaderId := AppendNewReaderIntoDatabase(ReaderReport)
  else
    ReaderId := VarReaderId.AsInter;
  AppendNewReportIntoDatabase(ReaderId, ReaderReport);
end;

procedure TForm1.LocateBookByISBN(ReaderReport: TReaderReport);
var
  b: TBook;
begin
  b := FBooksConfig.GetBookList(blkAll).FindByISBN(ReaderReport.bookISBN);
  if not Assigned(b) then
    raise Exception.Create('Invalid book isbn');
end;

function TForm1.AppendNewReaderIntoDatabase(ReaderReport
  : TReaderReport): Integer;
var
  readerId: Integer;
begin
  readerId := DataModMain.mtabReaders.GetMaxValue('ReaderId') + 1;
  //
  // Fields: ReaderId, FirstName, LastName, Email, Company, BooksRead,
  // LastReport, ReadersCreated
  //
  DataModMain.mtabReaders.AppendRecord([readerId, ReaderReport.firstName,
    ReaderReport.lastName, ReaderReport.email, ReaderReport.company, 1,
    ReaderReport.dtReported, Now]);
  Result := readerId;
end;

procedure TForm1.AppendNewReportIntoDatabase(readerId: Integer;
  ReaderReport: TReaderReport);
begin
  // ----------------------------------------------------------------
  //
  // Append report into the database:
  // Fields: ReaderId, ISBN, Rating, Oppinion, Reported
  //
  DataModMain.mtabReports.AppendRecord([readerId, ReaderReport.bookISBN,
    ReaderReport.rating, ReaderReport.oppinion, ReaderReport.dtReported]);
end;


// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

end.
