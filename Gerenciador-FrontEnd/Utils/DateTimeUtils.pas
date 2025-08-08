unit DateTimeUtils;

interface

uses
  System.SysUtils, System.DateUtils;

function ParseISO8601(const S: string; out D: TDateTime): Boolean;
function FormatISO8601UTC(const D: TDateTime): string;
function DisplayDateTimeBR(const D: TDateTime): string;

implementation

function ParseISO8601(const S: string; out D: TDateTime): Boolean;
begin
  Result := False;
  D := 0;
  if S = '' then Exit;
  try
    D := ISO8601ToDate(S, False);
    Result := True;
  except
    Result := False;
  end;
end;

function FormatISO8601UTC(const D: TDateTime): string;
var
  U: TDateTime;
begin
  if D = 0 then Exit('');
  U := TTimeZone.Local.ToUniversalTime(D);
  Result := DateToISO8601(U, True);
end;

function DisplayDateTimeBR(const D: TDateTime): string;
begin
  if D = 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy hh:nn', D);
end;

end.

