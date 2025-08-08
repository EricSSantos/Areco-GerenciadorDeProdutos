unit DateTimeUtils;

interface

uses
  System.SysUtils, System.DateUtils;

function ParseISO8601(const AValue: string; out ADateTime: TDateTime): Boolean;
function FormatISO8601UTC(const ADateTime: TDateTime): string;
function DisplayDateTimeBR(const ADateTime: TDateTime): string;

implementation

function ParseISO8601(const AValue: string; out ADateTime: TDateTime): Boolean;
begin
  Result := False;
  ADateTime := 0;
  if AValue = '' then
    Exit;
  try
    ADateTime := ISO8601ToDate(AValue, False);
    Result := True;
  except
    Result := False;
  end;
end;

function FormatISO8601UTC(const ADateTime: TDateTime): string;
var
  utcDate: TDateTime;
begin
  if ADateTime = 0 then
    Exit('');
  utcDate := TTimeZone.Local.ToUniversalTime(ADateTime);
  Result := DateToISO8601(utcDate, True);
end;

function DisplayDateTimeBR(const ADateTime: TDateTime): string;
begin
  if ADateTime = 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy hh:nn', ADateTime);
end;

end.

