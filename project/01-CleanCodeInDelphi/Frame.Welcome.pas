unit Frame.Welcome;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Utils.Messages;

type
  TFrameWelcome = class(TFrame)
    Panel1: TPanel;
    lbAppName: TLabel;
    lbAppVersion: TLabel;
    tmrFrameReady: TTimer;
    Bevel1: TBevel;
    procedure tmrFrameReadyTimer(Sender: TObject);
  private
    { Private declarations }
    procedure OnMessage(var Msg: TMessage); message WM_FRAME_MESSAGE;
  public
    procedure AddInfo(level: integer; const Msg: string; show: boolean);
  end;

implementation

{$R *.dfm}

uses
  System.Contnrs,
  Consts.Application, Data.Main;

procedure TFrameWelcome.AddInfo(level: integer; const Msg: string;
  show: boolean);
begin
  // TODO 3: Remove dependency on DataModMain
  DataModMain.PostWelcomeFrameInfo(level,Msg,show);
end;

procedure TFrameWelcome.OnMessage(var Msg: TMessage);
var
  FrameMsg: TMyMessage;
  lbl: TLabel;
begin
  if Msg.WParam = 1 then
  begin
    FrameMsg := TObject(Msg.LParam) as TMyMessage;
    lbl := TLabel.Create(self);
    lbl.Top := Panel1.Height;
    Panel1.Height := Panel1.Height + lbl.Height;
    lbl.Align := alTop;
    lbl.AlignWithMargins := True;
    lbl.Parent := Panel1;
    if FrameMsg.TagInteger > 0 then
      lbl.Caption := '* ' + FrameMsg.Text
    else
      lbl.Caption := FrameMsg.Text;
    { TODO 3: Show messages with TagBoolean = false only in DeveloperMode }
    if FrameMsg.TagBoolean = false then
    begin
      lbl.Font.Style := [fsItalic];
      lbl.Font.Color := clGrayText;
    end;
    lbl.Margins.Left := 10 + FrameMsg.TagInteger * 20;
    lbl.Margins.Top := 0;
    lbl.Margins.Bottom := 0;
  end;
end;

procedure TFrameWelcome.tmrFrameReadyTimer(Sender: TObject);
begin
  tmrFrameReady.Enabled := False;
  lbAppName.Caption := Consts.Application.ApplicationName;
  lbAppVersion.Caption := Consts.Application.ApplicationVersion;
end;

end.
