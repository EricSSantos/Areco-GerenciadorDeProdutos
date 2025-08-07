unit uProdutos;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  System.ImageList,
  Vcl.ImgList, Vcl.StdCtrls, Vcl.WinXCtrls, Datasnap.DBClient;

type
  TfrmProdutos = class(TForm)
    Body: TPanel;
    Header: TPanel;
    btnIncluir: TBitBtn;
    btnEditar: TBitBtn;
    btnExcluir: TBitBtn;
    btnCancelar: TBitBtn;
    btnGravar: TBitBtn;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    DBGrid1: TDBGrid;
    Label2: TLabel;
    btnBuscar: TBitBtn;
    dsProdutos: TDataSource;
    cdsProdutos: TClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProdutos: TfrmProdutos;

implementation

{$R *.dfm}


procedure TfrmProdutos.FormCreate(Sender: TObject);
begin
  //
end;


procedure TfrmProdutos.btnBuscarClick(Sender: TObject);
begin
  //
end;

end.
