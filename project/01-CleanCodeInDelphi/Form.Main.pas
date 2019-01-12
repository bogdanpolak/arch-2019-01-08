unit Form.Main;

interface

uses
  Winapi.Windows, System.Classes, Vcl.StdCtrls, Vcl.Controls, Vcl.Forms,
  Vcl.ExtCtrls, Data.DB,
  ChromeTabs, ChromeTabsClasses, ChromeTabsTypes,
  System.JSON,
  Messaging.EventBus,
  {TODO 3: [D] Resolve dependency on ExtGUI.ListBox.Books. Too tightly coupled}
  // Dependency is requred by attribute TBooksListBoxConfigurator
  ExtGUI.ListBox.Books;

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
    procedure OnUpdateCaption(MessageID: Integer;
      const AMessagee: TEventMessage);
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
  Helper.TDBGrid,
  // ----------------------------------------------------------------------
  Consts.Application,
  Utils.CipherAES128,
  Utils.General,
  Data.Main,
  ClientAPI.Readers,
  ClientAPI.Books,
  Frame.Import,
  Frame.Welcome,
  Work.ImportReaderReports;

const
  IsInjectBooksDBGridInWelcomeFrame = True;

resourcestring
  SWelcomeScreen = 'Welcome screen';

procedure TForm1.FormResize(Sender: TObject);
begin
  AutoHeightBookListBoxes();
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
  TImportReaderReportsWork.Create(Self).Action.Execute;
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
  DataSrc1.DataSet := DataModMain.dsReaders;
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
  DataSrc2.DataSet := DataModMain.dsReports;
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

procedure TForm1.OnUpdateCaption (MessageID: Integer;
    const AMessagee: TEventMessage);
begin
  Caption := AMessagee.TagString;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // ----------------------------------------------------------
  // Check: If we are in developer mode
  //
  // Developer mode id used to change application configuration
  // during test

  FIsDeveloperMode := Application.IsDevelopeMode;
  TEventBus._Register(EB_Main_Form_UpdateCaption,OnUpdateCaption);
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
    datasrc.DataSet := DataModMain.dsBooks;
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
begin
  tmrAppReady.Enabled := False;
  if FIsDeveloperMode then
    ReportMemoryLeaksOnShutdown := True;
  frm := CreateFrameAndAddChromeTab<TFrameWelcome>('Welcome');
  // TODO 3: use EventBus instead
  DataModMain.MessageManager.RegisterListener(frm);
  if DataModMain.ConnectToDatabaseServer then
  begin
    DataModMain.CheckDatabaseStructureVersion;
    // TODO 3: Check (authenticate) application user before
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
end;

end.
