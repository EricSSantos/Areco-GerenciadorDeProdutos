unit ProdutosController;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  Rest.JSON,
  ApiService,
  Produto;

type
  TProdutosController = class
  private
    FApi: TApiService;
    const ACTION = '/api/v1/products';
    function JsonArrayFrom(const AIds: array of string): string; overload;
    function JsonArrayFrom(const AIds: TStrings): string; overload;
  public
    constructor Create(AApi: TApiService);
    function GetAll: TApiResponse;
    function GetById(const AId: string): TApiResponse;
    function Post(const AProduct: TProduto): TApiResponse;
    function Put(const AProduct: TProduto): TApiResponse;
    function Delete(const AId: string): TApiResponse;
    function DeleteBatch(const AIds: array of string): TApiResponse; overload;
    function DeleteBatch(const AIds: TStrings): TApiResponse; overload;
  end;

implementation

constructor TProdutosController.Create(AApi: TApiService);
begin
  inherited Create;
  FApi := AApi;
end;

function TProdutosController.GetAll: TApiResponse;
begin
  Result := FApi.Get(ACTION, '');
end;

function TProdutosController.GetById(const AId: string): TApiResponse;
begin
  Result := FApi.Get(ACTION, AId);
end;

function TProdutosController.Post(const AProduct: TProduto): TApiResponse;
var
  bodyJson: string;
begin
  bodyJson := TJson.ObjectToJsonString(AProduct);
  Result := FApi.Post(ACTION, '', bodyJson);
end;

function TProdutosController.Put(const AProduct: TProduto): TApiResponse;
var
  bodyJson: string;
begin
  bodyJson := TJson.ObjectToJsonString(AProduct);
  Result := FApi.Put(ACTION, '', bodyJson);
end;

function TProdutosController.Delete(const AId: string): TApiResponse;
begin
  Result := FApi.Delete(ACTION, AId);
end;

function TProdutosController.DeleteBatch(const AIds: array of string): TApiResponse;
begin
  Result := FApi.DeleteBatch(ACTION, 'batch', JsonArrayFrom(AIds));
end;

function TProdutosController.DeleteBatch(const AIds: TStrings): TApiResponse;
begin
  Result := FApi.DeleteBatch(ACTION, 'batch', JsonArrayFrom(AIds));
end;

function TProdutosController.JsonArrayFrom(const AIds: array of string): string;
var
  jsonArray: TJSONArray;
  i: Integer;
begin
  jsonArray := TJSONArray.Create;
  try
    for i := Low(AIds) to High(AIds) do
      jsonArray.Add(AIds[i]);
    Result := jsonArray.ToJSON;
  finally
    jsonArray.Free;
  end;
end;

function TProdutosController.JsonArrayFrom(const AIds: TStrings): string;
var
  jsonArray: TJSONArray;
  i: Integer;
begin
  jsonArray := TJSONArray.Create;
  try
    for i := 0 to AIds.Count - 1 do
      jsonArray.Add(AIds[i]);
    Result := jsonArray.ToJSON;
  finally
    jsonArray.Free;
  end;
end;

end.

