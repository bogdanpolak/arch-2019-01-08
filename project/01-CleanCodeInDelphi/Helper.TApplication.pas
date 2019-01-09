unit Helper.TApplication;

interface

uses
  Vcl.Forms, SysUtils;

type

  TApplicationHelper = class helper for TApplication

    function IsDevelopeMode : Boolean;

  end;

implementation

{ TApplicationHelper }

function TApplicationHelper.IsDevelopeMode : Boolean;
var
  Extention: string;
  ExeName: string;
  ProjectFileName: string;
begin
{$IFDEF DEBUG}
  Extention := '.dpr';
  ExeName := ExtractFileName(Application.ExeName);
  ProjectFileName := ChangeFileExt(ExeName, Extention);

  Result := FileExists(ProjectFileName)
                      or FileExists('..\..\' + ProjectFileName);
{$ELSE}
  Result := False;
{$ENDIF}
end;

end.
