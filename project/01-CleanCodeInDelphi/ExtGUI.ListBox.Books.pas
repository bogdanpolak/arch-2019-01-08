unit ExtGUI.ListBox.Books;

interface

uses
  System.Classes, Vcl.StdCtrls, Vcl.Controls, System.Types, Vcl.Graphics,
  Winapi.Windows,
  System.JSON,
  System.Generics.Collections,
  Messaging.EventBus,
  DataAccess.Books,
  Model.Books;


type
  { TODO 3: Too many responsibilities. Separate GUI from structures }
  // Split into 2 classes TBooksContainer TListBoxesForBooks
  // Add new unit: Model.Books.pas
  TBooksListBoxConfigurator = class(TComponent)
  private
    DragedIdx: integer;
    FListBoxOnShelf: TListBox;
    FListBoxAvaliable: TListBox;
    procedure EventOnStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure EventOnDragDrop(Sender, Source: TObject; X, Y: integer);
    procedure EventOnDragOver(Sender, Source: TObject; X, Y: integer;
      State: TDragState; var Accept: Boolean);
    procedure EventOnDrawItem(Control: TWinControl; Index: integer; Rect: TRect;
      State: TOwnerDrawState);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InsertNewBook(b: TBook);
    { TODO 3: Introduce 3 properties: ListBoxOnShelf, ListBoxAvaliable, Books }
    procedure PrepareListBoxes(lbxOnShelf, lbxAvaliable: TListBox);
  end;

implementation

uses
  DataAccess.Books.FireDAC,
  Data.Main;

constructor TBooksListBoxConfigurator.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TBooksListBoxConfigurator.Destroy;
begin
  inherited;
end;

procedure TBooksListBoxConfigurator.InsertNewBook(b: TBook);
begin
  DataModMain.BooksFactory.InsertBook(b);
  FListBoxAvaliable.AddItem(b.title, b);
end;

procedure TBooksListBoxConfigurator.PrepareListBoxes(lbxOnShelf,
  lbxAvaliable: TListBox);
var
  b: TBook;
  BooksOnShelf: TBookCollection;
  BooksAvaliable: TBookCollection;
begin
  FListBoxOnShelf := lbxOnShelf;
  FListBoxAvaliable := lbxAvaliable;
  { TODO 2: Repeated code. Violation of the DRY rule }
  // New private method: SetupListBox
  // -----------------------------------------------------------------
  // ListBox: books on the shelf
  BooksOnShelf := DataModMain.BooksFactory.GetBookList(blkOnShelf);
  for b in BooksOnShelf do
    FListBoxOnShelf.AddItem(b.title, b);
  FListBoxOnShelf.OnDragDrop := EventOnDragDrop;
  FListBoxOnShelf.OnDragOver := EventOnDragOver;
  FListBoxOnShelf.OnStartDrag := EventOnStartDrag;
  FListBoxOnShelf.OnDrawItem := EventOnDrawItem;
  FListBoxOnShelf.Style := lbOwnerDrawFixed;
  FListBoxOnShelf.DragMode := dmAutomatic;
  FListBoxOnShelf.ItemHeight := 50;
  // -----------------------------------------------------------------
  // ListBox: books avaliable
  BooksAvaliable := DataModMain.BooksFactory.GetBookList(blkAvaliable);
  for b in BooksAvaliable do
    FListBoxAvaliable.AddItem(b.title, b);
  FListBoxAvaliable.OnDragDrop := EventOnDragDrop;
  FListBoxAvaliable.OnDragOver := EventOnDragOver;
  FListBoxAvaliable.OnStartDrag := EventOnStartDrag;
  FListBoxAvaliable.OnDrawItem := EventOnDrawItem;
  FListBoxAvaliable.Style := lbOwnerDrawFixed;
  FListBoxAvaliable.DragMode := dmAutomatic;
  FListBoxAvaliable.ItemHeight := 50;
end;

procedure TBooksListBoxConfigurator.EventOnStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
  lbx: TListBox;
begin
  lbx := Sender as TListBox;
  DragedIdx := lbx.ItemIndex;
end;

procedure TBooksListBoxConfigurator.EventOnDragDrop(Sender, Source: TObject;
  X, Y: integer);
var
  lbx2: TListBox;
  lbx1: TListBox;
  b: TBook;
  srcList: TBookCollection;
  dstList: TBookCollection;
  BooksOnShelf: TBookCollection;
  BooksAvaliable: TBookCollection;
begin
  lbx1 := Source as TListBox;
  lbx2 := Sender as TListBox;
  b := lbx1.Items.Objects[DragedIdx] as TBook;

  BooksOnShelf := DataModMain.BooksFactory.GetBookList(blkOnShelf);
  BooksAvaliable := DataModMain.BooksFactory.GetBookList(blkAvaliable);
  if lbx1 = FListBoxOnShelf then
  begin
    srcList := BooksOnShelf;
    dstList := BooksAvaliable;
  end
  else
  begin
    srcList := BooksAvaliable;
    dstList := BooksOnShelf;
  end;
  dstList.Add(srcList.Extract(b));
  lbx1.Items.Delete(DragedIdx);
  lbx2.AddItem(b.title, b);
end;

procedure TBooksListBoxConfigurator.EventOnDragOver(Sender, Source: TObject;
  X, Y: integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TListBox) and (DragedIdx >= 0) and (Sender <> Source);
end;

procedure TBooksListBoxConfigurator.EventOnDrawItem(Control: TWinControl;
  Index: integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  ACanvas: TCanvas;
  b: TBook;
  r2: TRect;
  lbx: TListBox;
  colorTextTitle: integer;
  colorTextAuthor: integer;
  colorBackground: integer;
  colorGutter: integer;
begin
  // TOwnerDrawState = set of (odSelected, odGrayed, odDisabled, odChecked,
  // odFocused, odDefault, odHotLight, odInactive, odNoAccel, odNoFocusRect,
  // odReserved1, odReserved2, odComboBoxEdit);
  lbx := Control as TListBox;

  // if (odSelected in State) and (odFocused in State) then
  if (odSelected in State) then
  begin
    colorGutter := $F0FFD0;
    colorTextTitle := clHighlightText;
    colorTextAuthor := $FFFFC0;
    colorBackground := clHighlight;
  end
  else
  begin
    colorGutter := $A0FF20;
    colorTextTitle := lbx.Font.Color;
    colorTextAuthor := $909000;
    colorBackground := lbx.Color;
  end;
  b := lbx.Items.Objects[Index] as TBook;
  s := b.title;
  ACanvas := lbx.Canvas;
  ACanvas.Brush.Color := colorBackground;
  r2 := Rect;
  r2.Left := 0;
  ACanvas.FillRect(r2);
  ACanvas.Brush.Color := colorGutter;
  r2 := Rect;
  r2.Left := 0;
  InflateRect(r2, -3, -5);
  r2.Right := r2.Left + 6;
  ACanvas.FillRect(r2);
  ACanvas.Brush.Color := colorBackground;
  Rect.Left := Rect.Left + 13;
  ACanvas.Font.Color := colorTextAuthor;
  ACanvas.Font.Size := lbx.Font.Size;
  ACanvas.TextOut(13, Rect.Top + 2, b.author);
  r2 := Rect;
  r2.Left := 13;
  r2.Top := r2.Top + ACanvas.TextHeight('Ag');
  ACanvas.Font.Color := colorTextTitle;
  ACanvas.Font.Size := lbx.Font.Size + 2;
  InflateRect(r2, -2, -1);
  DrawText(ACanvas.Handle, PChar(s), Length(s), r2,
    // DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
    DT_LEFT or DT_WORDBREAK);
end;

end.
