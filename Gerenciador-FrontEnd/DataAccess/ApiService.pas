unit ApiService;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  IdHTTP;

type
  EApiException = class(Exception);

  THttpMethod = (hmGET, hmPOST, hmPUT, hmDELETE, hmDELETE_BATCH);

  TApiResponse = record
    StatusCode: Integer;
    Title     : string;
    Data      : string;
    Errors    : TArray<string>;
    IsSuccess : Boolean;
    class function Success(const AData: string; AStatusCode: Integer = 200;
      const ATitle: string = ''): TApiResponse; static;
    class function Fail(const AErrors: TArray<string>; AStatusCode: Integer;
      const ATitle: string): TApiResponse; static;
  end;

  TIdHTTPEx = class(TIdHTTP)
  public
    function DeleteWithBody(const AUrl: string; ASource: TStream): string;
  end;

  TApiService = class
  private
    fParams: TStringList;
    fHttp  : TIdHTTPEx;
    const BASE_URL = 'http://localhost:5289';
    function BuildURL(const AAction, ASuffix: string): string;
    procedure SetupHTTP;
    class function Is2xx(const ACode: Integer): Boolean; static;
    class function ToStringArray(const AJsonArray: TJSONArray): TArray<string>; static;
    class function ExtractResponse(const ABody: string; const AFallbackStatus: Integer = 200): TApiResponse; static;
  public
    constructor Create;
    destructor Destroy; override;
    property Params: TStringList read fParams;
    function ExecuteRequest(const AMethod: THttpMethod; const AAction: string;
      ARequestBody: TStream; const ASuffix: string): TApiResponse;
    function Get(const AAction, ASuffix: string): TApiResponse;
    function Post(const AAction, ASuffix, ABodyJson: string): TApiResponse;
    function Put(const AAction, ASuffix, ABodyJson: string): TApiResponse;
    function Delete(const AAction, ASuffix: string): TApiResponse;
    function DeleteBatch(const AAction, ASuffix, ABodyJson: string): TApiResponse;
  end;

implementation

uses
  IdException,
  System.StrUtils;

class function TApiResponse.Success(const AData: string; AStatusCode: Integer;
  const ATitle: string): TApiResponse;
begin
  Result.StatusCode := AStatusCode;
  Result.Title      := ATitle;
  Result.Data       := AData;
  Result.Errors     := [];
  Result.IsSuccess  := True;
end;

class function TApiResponse.Fail(const AErrors: TArray<string>; AStatusCode: Integer;
  const ATitle: string): TApiResponse;
begin
  Result.StatusCode := AStatusCode;
  Result.Title      := ATitle;
  Result.Data       := '';
  Result.Errors     := AErrors;
  Result.IsSuccess  := False;
end;

function TIdHTTPEx.DeleteWithBody(const AUrl: string; ASource: TStream): string;
var
  resposta: TStringStream;
begin
  if Assigned(ASource) then
    ASource.Position := 0;
  resposta := TStringStream.Create('', TEncoding.UTF8);
  try
    DoRequest('DELETE', AUrl, ASource, resposta, []);
    Result := resposta.DataString;
  finally
    resposta.Free;
  end;
end;

constructor TApiService.Create;
begin
  inherited Create;
  fParams := TStringList.Create;
  fHttp   := TIdHTTPEx.Create(nil);
  SetupHTTP;
end;

destructor TApiService.Destroy;
begin
  fHttp.Free;
  fParams.Free;
  inherited;
end;

procedure TApiService.SetupHTTP;
begin
  fHttp.Request.ContentType   := 'application/json; charset=utf-8';
  fHttp.Request.Accept        := 'application/json';
  fHttp.Request.AcceptCharset := 'utf-8';
  fHttp.HandleRedirects       := True;
end;

function TApiService.BuildURL(const AAction, ASuffix: string): string;
var
  baseUrl, url, query: string;
begin
  baseUrl := BASE_URL.TrimRight(['/']) + AAction;
  if ASuffix <> '' then
  begin
    if ASuffix[1] = '/' then
      url := baseUrl + ASuffix
    else
      url := baseUrl + '/' + ASuffix;
  end
  else
    url := baseUrl;
  if fParams.Count > 0 then
  begin
    fParams.Delimiter := '&';
    fParams.StrictDelimiter := True;
    query := fParams.DelimitedText;
    url := url + '?' + query;
  end;
  Result := url;
end;

class function TApiService.Is2xx(const ACode: Integer): Boolean;
begin
  Result := (ACode >= 200) and (ACode <= 299);
end;

class function TApiService.ToStringArray(const AJsonArray: TJSONArray): TArray<string>;
var
  i: Integer;
  item: TJSONValue;
  listaTemp: TStringList;
begin
  if AJsonArray = nil then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  listaTemp := TStringList.Create;
  try
    for i := 0 to AJsonArray.Count - 1 do
    begin
      item := AJsonArray.Items[i];
      if item is TJSONString then
        listaTemp.Add(TJSONString(item).Value)
      else
        listaTemp.Add(item.ToJSON);
    end;
    SetLength(Result, listaTemp.Count);
    for i := 0 to listaTemp.Count - 1 do
      Result[i] := listaTemp[i];
  finally
    listaTemp.Free;
  end;
end;

class function TApiService.ExtractResponse(const ABody: string; const AFallbackStatus: Integer): TApiResponse;
var
  json: TJSONValue;
  objeto: TJSONObject;
  codigo: Integer;
  titulo: string;
  dados, erros: TJSONValue;
begin
  if Trim(ABody) = '' then
    Exit(TApiResponse.Fail(['Resposta vazia da API.'], AFallbackStatus, 'Falha ao realizar a operação.'));
  json := TJSONObject.ParseJSONValue(ABody);
  try
    if not (json is TJSONObject) then
      Exit(TApiResponse.Success(ABody, AFallbackStatus, ''));
    objeto := TJSONObject(json);
    if objeto.TryGetValue<Integer>('statusCode', codigo) then
    begin
      titulo := '';
      objeto.TryGetValue<string>('title', titulo);
      dados := objeto.Values['data'];
      erros := objeto.Values['errors'];
      if Is2xx(codigo) then
      begin
        if Assigned(dados) then
          Exit(TApiResponse.Success(dados.ToJSON, codigo, titulo))
        else
          Exit(TApiResponse.Success('null', codigo, titulo));
      end
      else
      begin
        if erros is TJSONArray then
          Exit(TApiResponse.Fail(ToStringArray(TJSONArray(erros)), codigo, titulo))
        else
          Exit(TApiResponse.Fail(['Falha ao realizar a operação.'], codigo, titulo));
      end;
    end;
    dados := objeto.Values['data'];
    if Assigned(dados) then
      Exit(TApiResponse.Success(dados.ToJSON, AFallbackStatus, ''));
    Exit(TApiResponse.Success(objeto.ToJSON, AFallbackStatus, ''));
  finally
    json.Free;
  end;
end;

function TApiService.ExecuteRequest(const AMethod: THttpMethod; const AAction: string;
  ARequestBody: TStream; const ASuffix: string): TApiResponse;
var
  url, conteudo: string;
  codigo: Integer;
begin
  url := BuildURL(AAction, ASuffix);
  if Assigned(ARequestBody) then
    ARequestBody.Position := 0;
  try
    case AMethod of
      hmGET          : conteudo := fHttp.Get(url);
      hmPOST         : conteudo := fHttp.Post(url, ARequestBody);
      hmPUT          : conteudo := fHttp.Put(url, ARequestBody);
      hmDELETE       : conteudo := fHttp.Delete(url);
      hmDELETE_BATCH : conteudo := fHttp.DeleteWithBody(url, ARequestBody);
    else
      raise EApiException.Create('Método HTTP não suportado.');
    end;
    codigo := fHttp.ResponseCode;
    if (codigo = 204) and (Trim(conteudo) = '') then
      Exit(TApiResponse.Success('null', codigo, ''));
    Result := ExtractResponse(conteudo, codigo);
  except
    on E: EIdHTTPProtocolException do
    begin
      if Trim(E.ErrorMessage) <> '' then
        Result := ExtractResponse(E.ErrorMessage, E.ErrorCode)
      else
        Result := TApiResponse.Fail([E.Message], E.ErrorCode, 'Erro HTTP');
    end;
    on E: Exception do
      Result := TApiResponse.Fail([E.Message], 0, 'Erro de comunicação');
  end;
end;

function TApiService.Get(const AAction, ASuffix: string): TApiResponse;
begin
  Result := ExecuteRequest(hmGET, AAction, nil, ASuffix);
end;

function TApiService.Post(const AAction, ASuffix, ABodyJson: string): TApiResponse;
var
  body: TStringStream;
begin
  body := TStringStream.Create(ABodyJson, TEncoding.UTF8);
  try
    Result := ExecuteRequest(hmPOST, AAction, body, ASuffix);
  finally
    body.Free;
  end;
end;

function TApiService.Put(const AAction, ASuffix, ABodyJson: string): TApiResponse;
var
  body: TStringStream;
begin
  body := TStringStream.Create(ABodyJson, TEncoding.UTF8);
  try
    Result := ExecuteRequest(hmPUT, AAction, body, ASuffix);
  finally
    body.Free;
  end;
end;

function TApiService.Delete(const AAction, ASuffix: string): TApiResponse;
begin
  Result := ExecuteRequest(hmDELETE, AAction, nil, ASuffix);
end;

function TApiService.DeleteBatch(const AAction, ASuffix, ABodyJson: string): TApiResponse;
var
  body: TStringStream;
begin
  body := TStringStream.Create(ABodyJson, TEncoding.UTF8);
  try
    Result := ExecuteRequest(hmDELETE_BATCH, AAction, body, ASuffix);
  finally
    body.Free;
  end;
end;

end.

