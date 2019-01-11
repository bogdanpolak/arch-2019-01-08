unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.DBActns, Vcl.StdCtrls,
  Messaging.EventBus,
  MVC.Work;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    procedure FormCreate(Sender: TObject);
  private
    function AddButtonToContainer<T: TWork>(Container: TWinControl): TButton;
    procedure OnWork2Finished(MessageID: Integer;
      const AMessagee: TEventMessage);
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


procedure TForm1.OnWork2Finished (MessageID: Integer;
    const AMessagee: TEventMessage);
begin
  Caption := AMessagee.TagString;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  myWork: TWork;
begin
  TEventBus._Register(1,OnWork2Finished);
  AddButtonToContainer<TCommandOneWork>(GroupBox1);
  AddButtonToContainer<TMessagingWork>(GroupBox1);
end;

end.
