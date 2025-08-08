unit FormatUtils;

interface

uses
  System.SysUtils;

function MoneyBR(const AValue: Double): string;
function SafeStrToFloatInv(const AValue: string; out AResult: Double): Boolean;

implementation

function MoneyBR(const AValue: Double): string;
var
  formatSettings: TFormatSettings;
begin
  formatSettings := TFormatSettings.Create('pt-BR');
  Result := 'R$ ' + FormatFloat('#,##0.00', AValue, formatSettings);
end;

function SafeStrToFloatInv(const AValue: string; out AResult: Double): Boolean;
var
  formatSettings: TFormatSettings;
begin
  formatSettings := TFormatSettings.Create;
  formatSettings.DecimalSeparator := '.';
  formatSettings.ThousandSeparator := ',';
  Result := TryStrToFloat(AValue, AResult, formatSettings);
end;

end.

