unit Produto;

interface

uses
  System.SysUtils,
  System.JSON;

type
  TProduto = class
  private
    FId: string;
    FCode: Integer;
    FName: string;
    FDescription: string;
    FPrice: Currency;
    FStock: Integer;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    constructor Create;
    procedure FromJSON(const AJSON: string); overload;
    procedure FromJSONObject(const AObj: TJSONObject); overload;
    function ToJSON: string;
    function ToJSONObject: TJSONObject;
    class function FromJSONArray(const AJSON: string): TArray<TProduto>; static;
    class function ToJSONArray(const AItems: TArray<TProduto>): string; static;
    property Id: string read FId write FId;
    property Code: Integer read FCode write FCode;
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Price: Currency read FPrice write FPrice;
    property Stock: Integer read FStock write FStock;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

procedure FreeArrayOfProduto(var Arr: TArray<TProduto>);

implementation

uses
  JsonUtils, DateTimeUtils;

procedure FreeArrayOfProduto(var Arr: TArray<TProduto>);
var
  I: Integer;
begin
  for I := Low(Arr) to High(Arr) do
    Arr[I].Free;
  SetLength(Arr, 0);
end;

constructor TProduto.Create;
begin
  inherited;
  FId := '';
  FCode := 0;
  FName := '';
  FDescription := '';
  FPrice := 0;
  FStock := 0;
  FCreatedAt := 0;
  FUpdatedAt := 0;
end;

procedure TProduto.FromJSON(const AJSON: string);
var
  Obj: TJSONObject;
begin
  Obj := TJSONObject(JsonParse(AJSON));
  if not Assigned(Obj) then
    raise Exception.Create('JSON inválido para TProduto');
  try
    FromJSONObject(Obj);
  finally
    Obj.Free;
  end;
end;

procedure TProduto.FromJSONObject(const AObj: TJSONObject);
var
  S: string;
  V: TJSONValue;
  DT: TDateTime;
begin
  FId    := JsonGetStr(AObj, 'id');
  FCode  := JsonGetInt(AObj, 'code');
  FName  := JsonGetStr(AObj, 'name');

  V := AObj.Values['description'];
  if (V = nil) or (V is TJSONNull) then
    FDescription := ''
  else
    FDescription := JsonGetStr(AObj, 'description');

  FPrice := Currency(JsonGetFloat(AObj, 'price', 0.0));
  FStock := JsonGetInt(AObj, 'stock');

  S := JsonGetStr(AObj, 'createdAt');
  if ParseISO8601(S, DT) then
    FCreatedAt := DT
  else
    FCreatedAt := 0;

  S := JsonGetStr(AObj, 'updatedAt');
  if ParseISO8601(S, DT) then
    FUpdatedAt := DT
  else
    FUpdatedAt := 0;
end;

function TProduto.ToJSONObject: TJSONObject;
begin
  Result := TJSONObject.Create;
  try
    if FId <> '' then
      Result.AddPair('id', FId)
    else
      Result.AddPair('id', TJSONNull.Create);

    Result.AddPair('code',  TJSONNumber.Create(FCode));
    Result.AddPair('name',  FName);

    if FDescription <> '' then
      Result.AddPair('description', FDescription)
    else
      Result.AddPair('description', TJSONNull.Create);

    Result.AddPair('price', TJSONNumber.Create(Double(FPrice)));
    Result.AddPair('stock', TJSONNumber.Create(FStock));

    if FCreatedAt > 0 then
      Result.AddPair('createdAt', FormatISO8601UTC(FCreatedAt))
    else
      Result.AddPair('createdAt', TJSONNull.Create);

    if FUpdatedAt > 0 then
      Result.AddPair('updatedAt', FormatISO8601UTC(FUpdatedAt))
    else
      Result.AddPair('updatedAt', TJSONNull.Create);
  except
    Result.Free;
    raise;
  end;
end;

function TProduto.ToJSON: string;
var
  Obj: TJSONObject;
begin
  Obj := ToJSONObject;
  try
    Result := Obj.ToJSON;
  finally
    Obj.Free;
  end;
end;

class function TProduto.FromJSONArray(const AJSON: string): TArray<TProduto>;
var
  Arr: TJSONArray;
  I: Integer;
  Item: TProduto;
begin
  SetLength(Result, 0);
  Arr := TJSONArray(JsonParse(AJSON));
  if not Assigned(Arr) then
    raise Exception.Create('JSON de lista inválido para TProduto');
  try
    SetLength(Result, Arr.Count);
    for I := 0 to Arr.Count - 1 do
    begin
      Item := TProduto.Create;
      Item.FromJSONObject(Arr.Items[I] as TJSONObject);
      Result[I] := Item;
    end;
  finally
    Arr.Free;
  end;
end;

class function TProduto.ToJSONArray(const AItems: TArray<TProduto>): string;
var
  JA: TJSONArray;
  I: Integer;
begin
  JA := TJSONArray.Create;
  try
    for I := Low(AItems) to High(AItems) do
      JA.AddElement(AItems[I].ToJSONObject);
    Result := JA.ToJSON;
  finally
    JA.Free;
  end;
end;

end.

