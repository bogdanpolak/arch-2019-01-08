unit Model.Books;

interface

uses
  System.Classes,
  System.Generics.Collections,
  DataAccess.Books;

type
  TBookListKind = (blkAll, blkOnShelf, blkAvaliable);

type
  TBook = class
    status: string;
    title: string;
    isbn: string;
    author: string;
    releseDate: TDateTime;
    pages: integer;
    price: currency;
    currency: string;
    imported: TDateTime;
    description: string;
    constructor Create(Books: IBooksDAO); overload;
  end;

  TBookCollection = class(TObjectList<TBook>)
  public
    procedure LoadDataSet(BooksDAO: IBooksDAO);
    function FindByISBN(const isbn: string): TBook;
  end;

  TBooksFactory = class (TComponent)
  private
    FAllBooks: TBookCollection;
    FBooksOnShelf: TBookCollection;
    FBooksAvaliable: TBookCollection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindBook(isbn: string): TBook;
    function GetBookList(kind: TBookListKind): TBookCollection;
    procedure InsertBook(b: TBook);
  end;

implementation

{ TBookCollection }

uses DataAccess.Books.FireDAC, Data.Main;

procedure TBookCollection.LoadDataSet(BooksDAO: IBooksDAO);
begin
  BooksDAO.ForEach(
    procedure(Books: IBooksDAO)
    begin
      self.Add(TBook.Create(Books));
    end);
end;

function TBookCollection.FindByISBN(const isbn: string): TBook;
var
  book: TBook;
begin
  for book in self do
    if book.isbn = isbn then
    begin
      Result := book;
      exit;
    end;
  Result := nil;
end;

{ TBook }

constructor TBook.Create(Books: IBooksDAO);
begin
  inherited Create;
  self.isbn := Books.fldISBN.AsString;
  self.title := Books.fldTitle.AsString;
  self.author := Books.fldAuthors.AsString;
  self.status := Books.fldStatus.AsString;
  self.releseDate := Books.fldReleseDate.Value;
  self.pages := Books.fldPages.Value;
  self.price := Books.fldPrice.Value;
  self.currency := Books.fldCurrency.AsString;
  self.imported := Books.fldImported.Value;
  self.description := Books.fldDescription.AsString;
end;


{ TBooksFactory }

constructor TBooksFactory.Create(AOwner: TComponent);
var
  b: TBook;
  BooksDAO: IBooksDAO;
begin
  inherited;
  // ---------------------------------------------------
  FAllBooks := TBookCollection.Create();
  { TODO 3: Discuss how to remove this dependency. Check implentation uses }
  BooksDAO := GetBooks_FireDAC(DataModMain.dsBooks);
  FAllBooks.LoadDataSet(BooksDAO);
  // ---------------------------------------------------
  FBooksOnShelf := TBookCollection.Create(false);
  FBooksAvaliable := TBookCollection.Create(false);
  for b in FAllBooks do
  begin
    if b.status = 'on-shelf' then
      FBooksOnShelf.Add(b)
    else if b.status = 'avaliable' then
      FBooksAvaliable.Add(b)
  end;
end;

destructor TBooksFactory.Destroy;
begin
  FAllBooks.Free;
  FBooksOnShelf.Free;
  FBooksAvaliable.Free;
  inherited;
end;

function TBooksFactory.GetBookList(kind: TBookListKind)
  : TBookCollection;
begin
  case kind of
    blkAll:
      Result := FAllBooks;
    blkOnShelf:
      Result := FBooksOnShelf;
    blkAvaliable:
      Result := FBooksAvaliable
  else
    Result := FAllBooks;
  end;
end;

procedure TBooksFactory.InsertBook(b: TBook);
begin
  FAllBooks.Add(b);
  if b.status = 'on-shelf' then
    FBooksOnShelf.Add(b)
  else if b.status = 'avaliable' then
    FBooksAvaliable.Add(b);
end;

function TBooksFactory.FindBook(isbn: string): TBook;
begin
  Result := FAllBooks.FindByISBN(isbn);
end;



end.
