unit Helper.TJsonObject;

interface
uses
  System.JSON;

type
  TJsonObjectHelper = class helper for TJsonObject
    function IsFieldAvaliable(const fieldName: string) : Boolean; inline;
    function IsValidIsoDateUtc(const Field: string): Boolean;
    function GetIsoDateUtcFromValidatedValue(const Field: string) : TDateTime;
  end;

implementation

uses
  System.DateUtils, System.SysUtils;

function TJsonObjectHelper.IsFieldAvaliable(const fieldName: string) : Boolean;
begin
  Result := Assigned(Self.Values[fieldName]) and not Self.Values[fieldName].Null;
end;

function TJsonObjectHelper.IsValidIsoDateUtc(const Field: string): Boolean;
begin
  var dt: TDateTime := 0;
  Result := System.DateUtils.TryISO8601ToDate(Self.Values[Field].Value, dt);
end;

function TJsonObjectHelper.GetIsoDateUtcFromValidatedValue(const Field: string) : TDateTime;
begin
  Result := System.DateUtils.ISO8601ToDate(Self.Values[Field].Value, False);;
end;

end.
