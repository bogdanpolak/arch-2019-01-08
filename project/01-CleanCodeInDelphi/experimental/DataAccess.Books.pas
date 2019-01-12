unit DataAccess.Books;

interface

uses
  Data.DB, System.SysUtils;

type
  IBooksDAO = interface(IInterface)
    ['{F8482010-9FCB-4994-B7E9-47F1DB115075}']
    function fldISBN: TStringField;
    function fldTitle: TStringField;
    function fldAuthors: TStringField;
    function fldStatus: TStringField;
    function fldReleseDate: TDateField;
    function fldPages: TIntegerField;
    function fldPrice: TBCDField;
    function fldCurrency: TStringField;
    function fldImported: TDateTimeField;
    function fldDescription: TStringField;
    procedure ForEach(proc: TProc<IBooksDAO>);
  end;


implementation

end.
