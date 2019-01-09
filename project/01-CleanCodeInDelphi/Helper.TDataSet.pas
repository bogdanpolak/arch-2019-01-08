unit Helper.TDataSet;

interface

uses
  Data.DB;

type
  TDataSetHelper = class helper for TDataSet
    function GetMaxValue(const fieldName: string): integer;
  end;

implementation

{ TDataSetHelper }

function TDataSetHelper.GetMaxValue(const fieldName: string): integer;
var
  v: Integer;
begin
  { TODO 2: [C] [Helper] Extract into TDBGrid.ForEachRow class helper }
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
