unit JsonUtils;

interface

uses
  System.SysUtils, System.JSON;

function JsonGetStr(AObject: TJSONObject; const AName: string; const ADefault: string = ''): string;
function JsonGetInt(AObject: TJSONObject; const AName: string; const ADefault: Integer = 0): Integer;
function JsonGetFloat(AObject: TJSONObject; const AName: string; const ADefault: Double = 0): Double;
function JsonGetBool(AObject: TJSONObject; const AName: string; const ADefault: Boolean = False): Boolean;
function JsonGetArray(AObject: TJSONObject; const AName: string): TJSONArray;
function JsonParse(const AValue: string): TJSONValue;

implementation

function JsonGetStr(AObject: TJSONObject; const AName: string; const ADefault: string): string;
var
  jsonValue: TJSONValue;
begin
  Result := ADefault;
  if AObject = nil then
    Exit;
  jsonValue := AObject.GetValue(AName);
  if (jsonValue <> nil) and (jsonValue.Value <> '') then
    Result := jsonValue.Value;
end;

function JsonGetInt(AObject: TJSONObject; const AName: string; const ADefault: Integer): Integer;
var
  jsonValue: TJSONValue;
begin
  Result := ADefault;
  if AObject = nil then
    Exit;
  jsonValue := AObject.GetValue(AName);
  if jsonValue is TJSONNumber then
    Result := TJSONNumber(jsonValue).AsInt;
end;

function JsonGetFloat(AObject: TJSONObject; const AName: string; const ADefault: Double): Double;
var
  jsonValue: TJSONValue;
begin
  Result := ADefault;
  if AObject = nil then
    Exit;
  jsonValue := AObject.GetValue(AName);
  if jsonValue is TJSONNumber then
    Result := TJSONNumber(jsonValue).AsDouble;
end;

function JsonGetBool(AObject: TJSONObject; const AName: string; const ADefault: Boolean): Boolean;
var
  jsonValue: TJSONValue;
begin
  Result := ADefault;
  if AObject = nil then
    Exit;
  jsonValue := AObject.GetValue(AName);
  if jsonValue is TJSONBool then
    Result := TJSONBool(jsonValue).AsBoolean
  else if (jsonValue <> nil) and (jsonValue.Value <> '') then
    Result := SameText(jsonValue.Value, 'true');
end;

function JsonGetArray(AObject: TJSONObject; const AName: string): TJSONArray;
var
  jsonValue: TJSONValue;
begin
  Result := nil;
  if AObject = nil then
    Exit;
  jsonValue := AObject.GetValue(AName);
  if jsonValue is TJSONArray then
    Result := TJSONArray(jsonValue);
end;

function JsonParse(const AValue: string): TJSONValue;
begin
  Result := nil;
  if AValue = '' then
    Exit;
  try
    Result := TJSONObject.ParseJSONValue(AValue);
  except
    Result := nil;
  end;
end;

end.

