program GerenciadorDeProdutos;

uses
  Vcl.Forms,
  uPrincipal in '..\Forms\uPrincipal.pas' {frmPrincipal},
  uProdutos in '..\Forms\uProdutos.pas' {frmProdutos},
  ProdutosController in '..\Controllers\ProdutosController.pas',
  ApiService in '..\DataAccess\ApiService.pas',
  Produto in '..\Entities\Produto.pas',
  DateTimeUtils in '..\Utils\DateTimeUtils.pas',
  JsonUtils in '..\Utils\JsonUtils.pas',
  FormatUtils in '..\Utils\FormatUtils.pas',
  uCadastro in '..\Forms\uCadastro.pas' {frmCadastroDeProduto};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmProdutos, frmProdutos);
  Application.CreateForm(TfrmCadastroDeProduto, frmCadastroDeProduto);
  Application.Run;
end.
