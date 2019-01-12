unit Helper.TDataSet;

interface

uses
  Data.DB, SysUtils;

type

  TDataSetHelper = class helper for TDataSet
    function GetMaxValue(const fieldName: string): integer;
    procedure ForEachRow(ProcedureToRun : TProc);
  end;

implementation

{ TDataSetHelper }

procedure TDataSetHelper.ForEachRow(ProcedureToRun : TProc);
begin
  if Assigned(Self) and Self.Active then
  begin
    Bookmark := Self.GetBookmark;
    Self.DisableControls;
    try
      Self.First;
      while not Self.Eof do
      begin
        if Assigned(ProcedureToRun) then
           ProcedureToRun;
        Self.Next;
      end;
    finally
      Self.GotoBookmark(Bookmark);
      Self.FreeBookmark(Bookmark);
      Self.EnableControls;
    end;
  end;
end;

function TDataSetHelper.GetMaxValue(const fieldName: string): integer;
var
  v: Integer;
begin
  Result := 0;
  Self.DisableControls;
  Self.First;
  while not Self.Eof do
  begin
    v := Self.FieldByName(fieldName).AsInteger;
    if v>Result then
      Result := v;
    Self.Next;
  end;
  Self.EnableControls;
end;

end.
