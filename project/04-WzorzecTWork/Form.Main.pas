unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.DBActns, Vcl.StdCtrls,
  MVC.Work,
  System.Messaging;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure OnWork2Notify(const Sender: TObject; const M: System.Messaging.TMessage);
    function AddButtonToContainer<T: TWork>(Container: TWinControl): TButton;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Work.CommandOne,
  Work.Messaging;


function TForm1.AddButtonToContainer <T>(Container: TWinControl): TButton;
var
  btn: TButton;
  Work: TWork;
begin
  btn := TButton.Create(Container);
  btn.Top := 10000;
  btn.Align := alTop;
  btn.AlignWithMargins := True;
  btn.Parent := Container;
  Work := T.Create(btn);
  btn.Action := Work.Action;
  Result := btn;
end;



function StingArrayToString (const aStrings: array of string): string;
var
  S: String;
begin
  Result := '';
  for S in aStrings do
  begin
    Result := Result + ', ' + S;
  end;
end;

procedure TForm1.OnWork2Notify (const Sender: TObject; const M: TMessage);
var
  NotShipped: TNotShippedOrders;
begin
  NotShipped := (M as TMessage<TNotShippedOrders>).Value;
  Caption := StingArrayToString(NotShipped.FOrdes);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  myWork: TWork;
begin
  AddButtonToContainer<TCommandOneWork>(GroupBox1);
  AddButtonToContainer<TMessagingWork>(GroupBox1);
  // -----
  TMessageManager.DefaultManager.SubscribeToMessage(
    TMessage<TNotShippedOrders>,OnWork2Notify );
end;

end.
