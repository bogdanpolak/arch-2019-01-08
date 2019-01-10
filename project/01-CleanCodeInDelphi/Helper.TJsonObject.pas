unit Helper.TJsonObject;

interface

uses
  System.JSON;

type
  TJSONObjectHelper = class helper for TJSONObject
    function IsPairAvaliableAndNotNull(const Key: string): Boolean; inline;
    function GetPairValueAsString(const Key: string): String;
    function GetPairValueAsInteger(const Key: string): integer;
    /// <summary>
    ///  Pobiera warttoœæ pary JSON o kluczu Key. Traktujê j¹ jako tekst
    ///  w formacie ISO Date (ISO8601) UTC i konwertuje j¹ do TDateTime
    /// </summary>
    function GetPairValueAsUtcDate(const Key: string): TDateTime;
    function IsValidIsoDateUtc(const Key: string): Boolean;
  end;

implementation

uses
  System.DateUtils;

function TJSONObjectHelper.IsPairAvaliableAndNotNull(const Key: string): Boolean;
begin
  Result := Assigned(Self.Values[Key]) and not Self.Values[Key].Null;
end;

function TJSONObjectHelper.GetPairValueAsInteger(const Key: string): integer;
begin
  if IsPairAvaliableAndNotNull(Key) then
    Result := (Self.Values[Key] as TJSONNumber).AsInt
  else
    Result := -1;
end;

function TJSONObjectHelper.GetPairValueAsString(const Key: string): String;
begin
  if IsPairAvaliableAndNotNull(Key) then
    Result := Self.Values[Key].Value
  else
    Result := '';
end;

function TJsonObjectHelper.IsValidIsoDateUtc(const Key: string): Boolean;
var
  dt: TDateTime;
begin
  dt := 0;
  Result := System.DateUtils.TryISO8601ToDate(Self.Values[Key].Value, dt);
end;

function TJsonObjectHelper.GetPairValueAsUtcDate(const Key: string) : TDateTime;
begin
  Result := System.DateUtils.ISO8601ToDate(Self.Values[Key].Value, False);;
end;

end.
