unit ApiService;

interface

uses
  System.Classes,
  System.SysUtils,
  IdHTTP;

type
  EApiException = class(Exception);

  THttpMethod = (hmGET, hmPOST, hmPUT, hmDELETE, hmDELETE_BATCH);

  // Subclasse só pra permitir delete com body (batch)
  TIdHTTPEx = class(TIdHTTP)
  public
    function DeleteWithBody(const AUrl: string; ASource: TStream): string;
  end;

  TApiService = class
  private
    FParams: TStringList;
    FHTTP  : TIdHTTPEx;
    const BASE_URL = 'http://localhost:5289';
    function BuildURL(const AAction, ASuffix: string): string;
    procedure SetupHTTP;
  public
    constructor Create;
    destructor Destroy; override;
    property Params: TStringList read FParams;
    function ExecuteRequest(const AMethod: THttpMethod; const AAction: string;
      ARequestBody: TStream; const ASuffix: string; out AMensagem: string): string; overload;
    function ExecuteRequest(const AMethod: THttpMethod; const AAction: string;
      ARequestBody: TStream; const ASuffix: string): string; overload;
    function Get(const AAction, ASuffix: string; out AMensagem: string): string;
    function Post(const AAction, ASuffix, ABodyJson: string; out AMensagem: string): string;
    function Put(const AAction, ASuffix, ABodyJson: string; out AMensagem: string): string;
    function Delete(const AAction, ASuffix: string; out AMensagem: string): string;
    function DeleteBatch(const AAction, ASuffix, ABodyJson: string; out AMensagem: string): string;
  end;

implementation

uses
  IdException;

{ TIdHTTPEx }

function TIdHTTPEx.DeleteWithBody(const AUrl: string; ASource: TStream): string;
var
  LResp: TStringStream;
begin
  if Assigned(ASource) then
    ASource.Position := 0;

  LResp := TStringStream.Create('', TEncoding.UTF8);
  try
    DoRequest('DELETE', AUrl, ASource, LResp, []);
    Result := LResp.DataString;
  finally
    LResp.Free;
  end;
end;

{ TApiService }

constructor TApiService.Create;
begin
  inherited Create;
  FParams := TStringList.Create;
  FHTTP   := TIdHTTPEx.Create(nil);
  SetupHTTP;
end;

destructor TApiService.Destroy;
begin
  FHTTP.Free;
  FParams.Free;
  inherited;
end;

procedure TApiService.SetupHTTP;
begin
  FHTTP.Request.ContentType := 'application/json';
  FHTTP.Request.Accept      := 'application/json';
  FHTTP.HandleRedirects     := True;
end;

function TApiService.BuildURL(const AAction, ASuffix: string): string;
var
  Base, Url, Query: string;
begin
  Base := BASE_URL.TrimRight(['/']) + AAction;

  if ASuffix <> '' then
  begin
    if ASuffix[1] = '/' then
      Url := Base + ASuffix
    else
      Url := Base + '/' + ASuffix;
  end
  else
    Url := Base;

  if FParams.Count > 0 then
  begin
    FParams.Delimiter := '&';
    Query := FParams.DelimitedText;
    Url := Url + '?' + Query;
  end;

  Result := Url;
end;

function TApiService.ExecuteRequest(const AMethod: THttpMethod; const AAction:
  string; ARequestBody: TStream; const ASuffix: string; out AMensagem: string): string;
var
  Url: string;
begin
  AMensagem := '';
  Url := BuildURL(AAction, ASuffix);

  if Assigned(ARequestBody) then
    ARequestBody.Position := 0;

  try
    case AMethod of
      hmGET         : Result := FHTTP.Get(Url);
      hmPOST        : Result := FHTTP.Post(Url, ARequestBody);
      hmPUT         : Result := FHTTP.Put(Url, ARequestBody);
      hmDELETE      : Result := FHTTP.Delete(Url);
      hmDELETE_BATCH: Result := FHTTP.DeleteWithBody(Url, ARequestBody);
    else
      raise EApiException.Create('Método HTTP não suportado.');
    end;
  except
    on E: EIdHTTPProtocolException do
      AMensagem := Format('Erro %d: %s', [E.ErrorCode, E.ErrorMessage]);
    on E: Exception do
      AMensagem := E.Message;
  end;
end;

function TApiService.ExecuteRequest(const AMethod: THttpMethod; const AAction:
  string; ARequestBody: TStream; const ASuffix: string): string;
var
  Msg: string;
begin
  Result := ExecuteRequest(AMethod, AAction, ARequestBody, ASuffix, Msg);
  if Msg <> '' then
    raise EApiException.Create(Msg);
end;

function TApiService.Get(const AAction, ASuffix: string; out AMensagem: string): string;
begin
  Result := ExecuteRequest(hmGET, AAction, nil, ASuffix, AMensagem);
end;

function TApiService.Post(const AAction, ASuffix, ABodyJson: string; out AMensagem: string): string;
var
  S: TStringStream;
begin
  S := TStringStream.Create(ABodyJson, TEncoding.UTF8);
  try
    Result := ExecuteRequest(hmPOST, AAction, S, ASuffix, AMensagem);
  finally
    S.Free;
  end;
end;

function TApiService.Put(const AAction, ASuffix, ABodyJson: string; out AMensagem: string): string;
var
  S: TStringStream;
begin
  S := TStringStream.Create(ABodyJson, TEncoding.UTF8);
  try
    Result := ExecuteRequest(hmPUT, AAction, S, ASuffix, AMensagem);
  finally
    S.Free;
  end;
end;

function TApiService.Delete(const AAction, ASuffix: string; out AMensagem: string): string;
begin
  Result := ExecuteRequest(hmDELETE, AAction, nil, ASuffix, AMensagem);
end;

function TApiService.DeleteBatch(const AAction, ASuffix, ABodyJson: string; out AMensagem: string): string;
var
  S: TStringStream;
begin
  S := TStringStream.Create(ABodyJson, TEncoding.UTF8);
  try
    Result := ExecuteRequest(hmDELETE_BATCH, AAction, S, ASuffix, AMensagem);
  finally
    S.Free;
  end;
end;

end.

