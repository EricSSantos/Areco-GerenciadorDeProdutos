unit FormatUtils;

interface

uses
  System.SysUtils;

function MoneyBR(const Value: Double): string;
function SafeStrToFloatInv(const S: string; out V: Double): Boolean;

implementation

function MoneyBR(const Value: Double): string;
var FS: TFormatSettings;
begin
  FS := TFormatSettings.Create('pt-BR');
  Result := 'R$ ' + FormatFloat('#,##0.00', Value, FS);
end;

function SafeStrToFloatInv(const S: string; out V: Double): Boolean;
var FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  FS.ThousandSeparator := ',';
  Result := TryStrToFloat(S, V, FS);
end;

end.

