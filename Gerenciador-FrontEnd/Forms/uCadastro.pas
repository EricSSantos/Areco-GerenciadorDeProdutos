unit uCadastro;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.StrUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Produto,
  ProdutosController,
  ApiService;

type
  TfrmCadastroDeProduto = class(TForm)
    Body: TPanel;
    Footer: TPanel;
    btnGravar: TBitBtn;
    btnCancelar: TBitBtn;
    GroupBox: TGroupBox;
    lnlNome: TLabel;
    lblDescricao: TLabel;
    lblPreco: TLabel;
    lblQtd: TLabel;
    edtNome: TEdit;
    edtDescricao: TEdit;
    edtPreco: TEdit;
    edtQuantidade: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
  private
    procedure LimparCampos;
    procedure MostrarDialogoConfirmacao(const AMensagem: string; var AResultado: Integer);
    function IsMoeda(const AValor: string): Boolean;
    function IsInteiro(const AValor: string): Boolean;
    function ValidarEntradas(out AMensagem: string): Boolean;
    function JuntarErros(const AErros: TArray<string>): string;
    procedure CadastrarProduto(const AProduto: TProduto; out AMensagemErro: string; out ASucesso: Boolean);
  public
  end;

var
  frmCadastroDeProduto: TfrmCadastroDeProduto;

implementation

{$R *.dfm}

procedure TfrmCadastroDeProduto.LimparCampos;
begin
  edtNome.Text := '';
  edtDescricao.Text := '';
  edtPreco.Text := '';
  edtQuantidade.Text := '';
end;

procedure TfrmCadastroDeProduto.MostrarDialogoConfirmacao(const AMensagem: string; var AResultado: Integer);
begin
  AResultado := MessageDlg(AMensagem, mtConfirmation, [mbYes, mbNo], 0);
end;

function TfrmCadastroDeProduto.IsMoeda(const AValor: string): Boolean;
var
  valor: Currency;
begin
  Result := TryStrToCurr(Trim(AValor), valor);
end;

function TfrmCadastroDeProduto.IsInteiro(const AValor: string): Boolean;
var
  valor: Integer;
begin
  Result := TryStrToInt(Trim(AValor), valor);
end;

function TfrmCadastroDeProduto.JuntarErros(const AErros: TArray<string>): string;
var
  erro: string;
begin
  Result := '';
  for erro in AErros do
    if Trim(erro) <> '' then
      Result := Result + IfThen(Result <> '', sLineBreak) + Trim(erro);
end;

procedure TfrmCadastroDeProduto.CadastrarProduto(const AProduto: TProduto; out AMensagemErro: string; out ASucesso: Boolean);
var
  api: TApiService;
  controlador: TProdutosController;
  resposta: TApiResponse;
begin
  ASucesso := False;
  AMensagemErro := '';
  api := TApiService.Create;
  try
    controlador := TProdutosController.Create(api);
    try
      resposta := controlador.Post(AProduto);
      ASucesso := resposta.IsSuccess;
      if not ASucesso then
      begin
        AMensagemErro := JuntarErros(resposta.Errors);
        if AMensagemErro = '' then
          AMensagemErro := resposta.Title;
        if AMensagemErro = '' then
          AMensagemErro := 'Não foi possível cadastrar o produto.';
      end;
    finally
      controlador.Free;
    end;
  finally
    api.Free;
  end;
end;

function TfrmCadastroDeProduto.ValidarEntradas(out AMensagem: string): Boolean;
begin
  AMensagem := '';
  if Trim(edtNome.Text) = '' then
    AMensagem := AMensagem + IfThen(AMensagem <> '', sLineBreak) + 'Informe o nome do produto.';
  if Trim(edtDescricao.Text) = '' then
    AMensagem := AMensagem + IfThen(AMensagem <> '', sLineBreak) + 'Informe a descrição.';
  if Trim(edtPreco.Text) = '' then
    AMensagem := AMensagem + IfThen(AMensagem <> '', sLineBreak) + 'Informe o preço.';
  if Trim(edtQuantidade.Text) = '' then
    AMensagem := AMensagem + IfThen(AMensagem <> '', sLineBreak) + 'Informe a quantidade.';
  if (AMensagem = '') and (not IsMoeda(edtPreco.Text)) then
    AMensagem := AMensagem + IfThen(AMensagem <> '', sLineBreak) + 'Preço inválido.';
  if (AMensagem = '') and (not IsInteiro(edtQuantidade.Text)) then
    AMensagem := AMensagem + IfThen(AMensagem <> '', sLineBreak) + 'Quantidade inválida.';
  Result := AMensagem = '';
end;

procedure TfrmCadastroDeProduto.FormCreate(Sender: TObject);
begin
  LimparCampos;
end;

procedure TfrmCadastroDeProduto.btnCancelarClick(Sender: TObject);
var
  resposta: Integer;
  temEntrada: Boolean;
begin
  temEntrada := (Trim(edtNome.Text) <> '') or
                (Trim(edtDescricao.Text) <> '') or
                (Trim(edtPreco.Text) <> '') or
                (Trim(edtQuantidade.Text) <> '');
  if not temEntrada then
  begin
    ModalResult := mrCancel;
    Exit;
  end;
  MostrarDialogoConfirmacao('Deseja cancelar a operação?', resposta);
  if resposta = mrYes then
    ModalResult := mrCancel;
end;

procedure TfrmCadastroDeProduto.btnGravarClick(Sender: TObject);
var
  respostaConfirmacao: Integer;
  mensagemErro: string;
  sucesso: Boolean;
  entidade: TProduto;
  preco: Currency;
  quantidade: Integer;
begin
  if not ValidarEntradas(mensagemErro) then
  begin
    MessageDlg(mensagemErro, mtWarning, [mbOK], 0);
    Exit;
  end;
  MostrarDialogoConfirmacao('Deseja confirmar a operação?', respostaConfirmacao);
  if respostaConfirmacao <> mrYes then
    Exit;
  TryStrToCurr(Trim(edtPreco.Text), preco);
  TryStrToInt(Trim(edtQuantidade.Text), quantidade);
  entidade := TProduto.Create;
  try
    entidade.Name := Trim(edtNome.Text);
    entidade.Description := Trim(edtDescricao.Text);
    entidade.Price := preco;
    entidade.Stock := quantidade;
    Screen.Cursor := crHourGlass;
    btnGravar.Enabled := False;
    btnCancelar.Enabled := False;
    try
      CadastrarProduto(entidade, mensagemErro, sucesso);
    finally
      btnGravar.Enabled := True;
      btnCancelar.Enabled := True;
      Screen.Cursor := crDefault;
    end;
    if sucesso then
    begin
      ShowMessage('Produto salvo com sucesso.');
      ModalResult := mrOk;
    end
    else
      ShowMessage('Falha ao salvar produto: ' + mensagemErro);
  finally
    entidade.Free;
  end;
end;

end.

