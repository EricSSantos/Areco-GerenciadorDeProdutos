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
  public
    constructor Create(AApi: TApiService);
    function GetAll(out AMensagem: string): string;
    function GetById(const AId: string; out AMensagem: string): string;
    function Post(const AProduto: TProduto; out AMensagem: string): string;
    function Put(const AProduto: TProduto; out AMensagem: string): string;
    function Delete(const AId: string; out AMensagem: string): string;
    function DeleteBatch(const Ids: array of string; out AMensagem: string): string; overload;
    function DeleteBatch(const Ids: TStrings; out AMensagem: string): string; overload;
  end;

implementation

{ TProdutosController }

constructor TProdutosController.Create(AApi: TApiService);
begin
  inherited Create;
  FApi := AApi;
end;

function TProdutosController.GetAll(out AMensagem: string): string;
begin
  Result := FApi.Get(ACTION, '', AMensagem);
end;

function TProdutosController.GetById(const AId: string; out AMensagem: string): string;
begin
  Result := FApi.Get(ACTION, AId, AMensagem);
end;

function TProdutosController.Post(const AProduto: TProduto; out AMensagem: string): string;
var
  BodyJson: string;
begin
  BodyJson := TJson.ObjectToJsonString(AProduto);
  Result := FApi.Post(ACTION, '', BodyJson, AMensagem);
end;

function TProdutosController.Put(const AProduto: TProduto; out AMensagem: string): string;
var
  BodyJson: string;
begin
  BodyJson := TJson.ObjectToJsonString(AProduto);
  Result := FApi.Put(ACTION, '', BodyJson, AMensagem);
end;

function TProdutosController.Delete(const AId: string; out AMensagem: string): string;
begin
  Result := FApi.Delete(ACTION, AId, AMensagem);
end;

function TProdutosController.DeleteBatch(const Ids: array of string; out AMensagem: string): string;
var
  JA: TJSONArray;
  I : Integer;
begin
  JA := TJSONArray.Create;
  try
    for I := Low(Ids) to High(Ids) do
      JA.Add(Ids[I]);
    Result := FApi.DeleteBatch(ACTION, 'batch', JA.ToJSON, AMensagem);
  finally
    JA.Free;
  end;
end;

function TProdutosController.DeleteBatch(const Ids: TStrings; out AMensagem: string): string;
var
  JA: TJSONArray;
  I : Integer;
begin
  JA := TJSONArray.Create;
  try
    for I := 0 to Ids.Count - 1 do
      JA.Add(Ids[I]);
    Result := FApi.DeleteBatch(ACTION, 'batch', JA.ToJSON, AMensagem);
  finally
    JA.Free;
  end;
end;

end.

