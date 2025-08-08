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
  FormatUtils in '..\Utils\FormatUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmProdutos, frmProdutos);
  Application.Run;
end.
