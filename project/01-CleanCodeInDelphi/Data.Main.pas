unit Data.Main;

interface

uses
  // ------------------------------------------------------------------------
  System.SysUtils, System.Classes, System.JSON, Data.DB,
  // ------------------------------------------------------------------------
  // FireDAC: FDConnection:
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.Phys.Intf, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  // ------------------------------------------------------------------------
  // FireDAC: SQLite:
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  // ------------------------------------------------------------------------
  // FireDAC: FDQuery:
  FireDAC.Comp.DataSet, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Stan.Async,
  // ------------------------------------------------------------------------
  // FireDAC: MemTable JSON Storage:
  FireDAC.Stan.StorageJSON,
  // ------------------------------------------------------------------------
  // Project units:
  Model.Books,
  Utils.Messages;

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
  public
    BooksFactory: TBooksFactory;
    MessageManager: TMessages;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // TODO 3: Move to private section (after migration to EventBus)
    procedure PostWelcomeFrameInfo(level: Integer; const Msg: string;
      show: boolean);
    function ConnectToDatabaseServer: boolean;
    function CheckDatabaseStructureVersion: boolean;
    procedure OpenDataSets;
    function FindReaderByEmil(const email: string): Variant;
  private
    function DBVersionToString(VerDB: Integer): string;
  const
    SecureKey = 'delphi-is-the-best';
    // SecurePassword = AES 128 ('masterkey',SecureKey)
    // SecurePassword = 'hC52IiCv4zYQY2PKLlSvBaOXc14X41Mc1rcVS6kyr3M=';
    // SecurePassword = AES 128 ('<null>',SecureKey)
    SecurePassword = 'EvUlRZOo3hzFEr/IRpHVMA==';
    //
  end;

var
  DataModMain: TDataModMain;

const
  EB_Main_Form_UpdateCaption = 1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

uses
  System.StrUtils,
  System.Variants,
  Helper.TDataSet,
  ClientAPI.Books,
  Utils.CipherAES128, Consts.Application;

resourcestring
  SDBServerGone = 'Database server is gone';
  SDBConnectionUserPwdInvalid = 'Invalid database configuration.' +
    ' Application database user or password is incorrect.';
  SDBConnectionError = 'Can''t connect to database server. Unknown error.';

resourcestring
  SDBRequireCreate = 'Database is empty. You need to execute script' +
    ' creating required data.';
  SDBErrorSelect = 'Can''t execute SELECT command on the database';
  StrNotSupportedDBVersion = 'Not supported database version. Please' +
    ' update database structures.';

function TDataModMain.DBVersionToString(VerDB: Integer): string;
begin
  Result := (VerDB div 1000).ToString + '.' + (VerDB mod 1000).ToString;
end;

constructor TDataModMain.Create(AOwner: TComponent);
begin
  inherited;
  MessageManager := TMessages.Create;
end;

destructor TDataModMain.Destroy;
begin
  MessageManager.Free;
  inherited;
end;

function TDataModMain.FindReaderByEmil(const email: string): Variant;
var
  ok: boolean;
begin
  ok := dsReaders.Locate('email', email, []);
  if ok then
    Result := dsReaders.FieldByName('ReaderId').Value
  else
    Result := System.Variants.Null()
end;

procedure TDataModMain.PostWelcomeFrameInfo(level: Integer; const Msg: string;
  show: boolean);
var
  obj: TMyMessage;
begin
  obj := TMyMessage.Create;
  obj.Text := Msg;
  obj.TagInteger := level;
  obj.TagBoolean := show;
  MessageManager.Add(obj);
  MessageManager.SendMessages;
end;

function TDataModMain.ConnectToDatabaseServer: boolean;
var
  UserName: string;
  Password: string;
  msg1: string;
  EmptyPass: string;
begin
  try
    UserName := FDManager.ConnectionDefs.ConnectionDefByName
      (FDConnection1.ConnectionDefName).Params.UserName;
    EmptyPass := AES128_Encrypt('<null>', SecureKey);
    Password := AES128_Decrypt(SecurePassword, SecureKey);
    if Password='<null>' then
      Password := '';
    FDConnection1.Open(UserName, Password);
    // TODO 1: Magic number - move to resourcestring
    PostWelcomeFrameInfo(0, 'User logged in. [OK]', True);
    // TODO 1: Magic number - move to resourcestring
    PostWelcomeFrameInfo(1, 'Current user: ' + UserName, True);
    Result := True;
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
      PostWelcomeFrameInfo(0, msg1, True);
      PostWelcomeFrameInfo(1, E.Message, False);
      Result := False;
    end;
  end;
end;


const
  SQL_SelectDatabaseVersion = 'SELECT versionnr FROM DBInfo';

function TDataModMain.CheckDatabaseStructureVersion: boolean;
var
  msg1: String;
  VersionNr: Integer;
  IsCorrectVersion: boolean;
begin
  // Check application user and database structure (DB version)
  //
  try
    VersionNr := FDConnection1.ExecSQLScalar(SQL_SelectDatabaseVersion);
    IsCorrectVersion := VersionNr = ExpectedDatabaseVersionNr;
    Result := IsCorrectVersion;
    if IsCorrectVersion then
    begin
      // TODO 1: Magic number - move to resourcestring
      PostWelcomeFrameInfo(0, 'Verified database version. [OK]', True);
      // TODO 1: Magic number - move to resourcestring
      PostWelcomeFrameInfo(1, 'Aktualna wersja bazy: ' +
        DBVersionToString(VersionNr), True);
    end
    else
    begin
      PostWelcomeFrameInfo(0, StrNotSupportedDBVersion, True);
      // TODO 1: Magic number - move to resourcestring (translate)
      PostWelcomeFrameInfo(1, 'Oczekiwana wersja bazy: ' +
        DBVersionToString(ExpectedDatabaseVersionNr), True);
      // TODO 1: Magic number - move to resourcestring (translate)
      PostWelcomeFrameInfo(1, 'Aktualna wersja bazy: ' +
        DBVersionToString(VersionNr), True);
    end;
  except
    on E: EFDDBEngineException do
    begin
      msg1 := System.StrUtils.IfThen(E.kind = ekObjNotExists, SDBRequireCreate,
        SDBErrorSelect);
      PostWelcomeFrameInfo(0, msg1, True);
      PostWelcomeFrameInfo(1, E.Message, False);
      Result := False;
    end;
  end;
end;

procedure TDataModMain.OpenDataSets;
begin
  dsBooks.Open();
  dsReaders.Open();
  dsReports.Open();
  // TODO 4: Delete migration code and FDMemTable-s or extract as a special action
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
