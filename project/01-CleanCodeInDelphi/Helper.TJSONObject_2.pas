unit Helper.TJSONObject;

interface

uses
  System.JSON;

type
  TJSONObjectHelper = class helper for TJSONObject
    function FieldAvaliable(const fieldName: string): Boolean; inline;
    function GetJSONValueAsString(const fieldName: string): String;
    function GetJSONValueAsInteger(const fieldName: string): integer;
  end;

implementation

{ TJSONObjectHelper }

function TJSONObjectHelper.FieldAvaliable(const fieldName: string): Boolean;
begin
  Result := Assigned(Self.Values[fieldName]) and not Self.Values[fieldName].Null;
end;

function TJSONObjectHelper.GetJSONValueAsInteger(const fieldName: string): integer;
begin
  if fieldAvaliable(fieldName) then
    Result := (Self.Values[fieldName] as TJSONNumber).AsInt
  else
    Result := -1;
end;

function TJSONObjectHelper.GetJSONValueAsString(const fieldName: string): String;
begin
  if fieldAvaliable(fieldName) then
    Result := Self.Values[fieldName].Value
  else
    Result := '';
end;

end.
