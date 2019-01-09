unit Helper.TJsonObject;

interface

uses
  System.JSON;

type
  TJSONObjectHelper = class helper for TJSONObject
    // TODO 1: Nazwa metody: IsPairAvaliableAndNotNull (const Key: string)
    function FieldAvaliable(const fieldName: string): Boolean; inline;
    // TODO 1: Nazwa metody: GetPairValueAsString (const Key: string)
    function GetJSONValueAsString(const fieldName: string): String;
    // TODO 1: Nazwa metody: GetPairValueAsInteger (const Key: string)
    function GetJSONValueAsInteger(const fieldName: string): integer;
    // TODO 1: Nazwa metody: GetPairValueAsUtcDate (const Key: string)
    function GetIsoDateUtcFromValidatedValue(const Field: string): TDateTime;
    function IsValidIsoDateUtc(const Field: string): Boolean;
  end;

implementation

uses
  System.DateUtils;

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

function TJsonObjectHelper.IsValidIsoDateUtc(const Field: string): Boolean;
var
  dt: TDateTime;
begin
  dt := 0;
  Result := System.DateUtils.TryISO8601ToDate(Self.Values[Field].Value, dt);
end;

function TJsonObjectHelper.GetIsoDateUtcFromValidatedValue(const Field: string) : TDateTime;
begin
  Result := System.DateUtils.ISO8601ToDate(Self.Values[Field].Value, False);;
end;

end.
