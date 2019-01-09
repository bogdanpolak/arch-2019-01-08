unit Helper.TDBGrid;

interface

uses
  System.Classes,
  Vcl.DBGrids,
  System.SysUtils;

type
  TDBGridHelper = class helper for TDBGrid
    procedure ForEachRow(ProcedureToRun : TProc<TColumn>);
  end;
implementation

procedure TDBGridHelper.ForEachRow(ProcedureToRun : TProc<TColumn>);
begin
  for var ColumnItem in Columns do
  begin
    var Column := ColumnItem as TColumn;
    if Assigned(ProcedureToRun) then
      ProcedureToRun(Column);
  end;
end;
end.
