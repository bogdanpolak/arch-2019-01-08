unit Helper.TDBGrid;

interface

uses
  System.Classes,
  Vcl.DBGrids,
  System.SysUtils;

type
  TDBGridHelper = class helper for TDBGrid
    procedure ForEachColumn(ProcedureToRun: TProc<TColumn>);
    procedure AutoResizeAllColumnsWidth;
  end;

implementation

uses
  Data.DB,
  System.Math;

procedure TDBGridHelper.ForEachColumn(ProcedureToRun: TProc<TColumn>);
var
  Item: TCollectionItem;
  Column: TColumn;
begin
  for Item in Columns do
  begin
    Column := Item as TColumn;
    if Assigned(ProcedureToRun) then
      ProcedureToRun(Column);
  end;
end;

const
  MaxRowsToIterateInDataSet: Integer = 25;

procedure TDBGridHelper.AutoResizeAllColumnsWidth;
var
  DataSet: TDataSet;
  Count, i: Integer;
  ColumnsWidth: array of Integer;
  Bookmark: TBookmark;
begin
  DataSet := Self.DataSource.DataSet;
  if (DataSet <> nil) and DataSet.Active then
  begin
    SetLength(ColumnsWidth, Self.Columns.Count);
    Bookmark := DataSet.GetBookmark;
    DataSet.DisableControls;
    try
      Count := 0;
      DataSet.First;
      while not DataSet.Eof and (Count < MaxRowsToIterateInDataSet) do
      begin
        for i := 0 to Self.Columns.Count - 1 do
          if Self.Columns[i].Visible then
            ColumnsWidth[i] := System.Math.Max(ColumnsWidth[i],
              Self.Canvas.TextWidth(Self.Columns[i].Field.Text + '   '));
        Inc(Count);
        DataSet.Next;
      end;
    finally
      if DataSet.BookmarkValid(Bookmark) then
        DataSet.GotoBookmark(Bookmark);
      DataSet.FreeBookmark(Bookmark);
      DataSet.EnableControls;
    end;
    Count := 0;
    for i := 0 to Self.Columns.Count - 1 do
      if Self.Columns[i].Visible then
      begin
        Self.Columns[i].Width := ColumnsWidth[i];
        Inc(Count, ColumnsWidth[i]);
      end;
  end;
end;

end.
