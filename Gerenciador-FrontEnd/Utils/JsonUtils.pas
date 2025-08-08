unit JsonUtils;

interface

uses
  System.SysUtils, System.JSON;

function JsonGetStr(Obj: TJSONObject; const Name: string; const ADefault: string = ''): string;
function JsonGetInt(Obj: TJSONObject; const Name: string; const ADefault: Integer = 0): Integer;
function JsonGetFloat(Obj: TJSONObject; const Name: string; const ADefault: Double = 0): Double;
function JsonGetBool(Obj: TJSONObject; const Name: string; const ADefault: Boolean = False): Boolean;
function JsonGetArray(Obj: TJSONObject; const Name: string): TJSONArray;
function JsonParse(const S: string): TJSONValue;

implementation

function JsonGetStr(Obj: TJSONObject; const Name: string; const ADefault: string): string;
var V: TJSONValue;
begin
  Result := ADefault;
  if Obj = nil then Exit;
  V := Obj.GetValue(Name);
  if (V <> nil) and (V.Value <> '') then
    Result := V.Value;
end;

function JsonGetInt(Obj: TJSONObject; const Name: string; const ADefault: Integer): Integer;
var V: TJSONValue;
begin
  Result := ADefault;
  if Obj = nil then Exit;
  V := Obj.GetValue(Name);
  if (V is TJSONNumber) then
    Result := TJSONNumber(V).AsInt;
end;

function JsonGetFloat(Obj: TJSONObject; const Name: string; const ADefault: Double): Double;
var V: TJSONValue;
begin
  Result := ADefault;
  if Obj = nil then Exit;
  V := Obj.GetValue(Name);
  if (V is TJSONNumber) then
    Result := TJSONNumber(V).AsDouble;
end;

function JsonGetBool(Obj: TJSONObject; const Name: string; const ADefault: Boolean): Boolean;
var V: TJSONValue;
begin
  Result := ADefault;
  if Obj = nil then Exit;
  V := Obj.GetValue(Name);
  if (V is TJSONBool) then
    Result := TJSONBool(V).AsBoolean
  else if (V <> nil) and (V.Value <> '') then
    Result := SameText(V.Value, 'true');
end;

function JsonGetArray(Obj: TJSONObject; const Name: string): TJSONArray;
var V: TJSONValue;
begin
  Result := nil;
  if Obj = nil then Exit;
  V := Obj.GetValue(Name);
  if V is TJSONArray then
    Result := TJSONArray(V);
end;

function JsonParse(const S: string): TJSONValue;
begin
  Result := nil;
  if S = '' then Exit;
  try
    Result := TJSONObject.ParseJSONValue(S);
  except
    Result := nil;
  end;
end;

end.

