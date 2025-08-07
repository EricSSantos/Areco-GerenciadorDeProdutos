unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.Menus, Vcl.ExtCtrls,
  uProdutos, Vcl.Imaging.pngimage;

type
  TfrmPrincipal = class(TForm)
    Timer: TTimer;
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    Controle1: TMenuItem;
    Produtos1: TMenuItem;
    Sair1: TMenuItem;
    Usuarios: TMenuItem;
    PageControl: TPageControl;
    Home: TTabSheet;
    Image1: TImage;

    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure Produtos1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);

  private
    procedure InicializarStatusBar;
    procedure IniciarTimer;
    function ObterNomeComputador: string;
    procedure AbrirAbaComFormulario(const Titulo: string; FormClass: TFormClass);
  public
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  InicializarStatusBar;
  IniciarTimer;
end;

procedure TfrmPrincipal.TimerTimer(Sender: TObject);
begin
  StatusBar.Panels[1].Text := 'Data/Hora: ' +
    FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
end;

procedure TfrmPrincipal.InicializarStatusBar;
begin
  StatusBar.Panels[0].Text := 'Usuário: Eric Silva';
  StatusBar.Panels[1].Text := 'Data/Hora: ';
  StatusBar.Panels[2].Text := 'Computador: ' + ObterNomeComputador;
end;

function TfrmPrincipal.ObterNomeComputador: string;
var
  Buffer: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
  Tamanho: DWORD;
begin
  Tamanho := Length(Buffer);
  if GetComputerName(Buffer, Tamanho) then
    Result := Buffer
  else
    Result := 'Desconhecido';
end;

procedure TfrmPrincipal.IniciarTimer;
begin
  Timer.Interval := 1000;
  Timer.Enabled := True;
end;

procedure TfrmPrincipal.Produtos1Click(Sender: TObject);
begin
  AbrirAbaComFormulario('Produtos', TfrmProdutos);
end;

procedure TfrmPrincipal.Sair1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.AbrirAbaComFormulario(const Titulo: string; FormClass: TFormClass);
var
  i: Integer;
  Aba: TTabSheet;
  Form: TForm;
begin
  // Verifica se a aba já está aberta
  for i := 0 to PageControl.PageCount - 1 do
  begin
    if PageControl.Pages[i].Caption = Titulo then
    begin
      PageControl.ActivePageIndex := i;
      Exit;
    end;
  end;

  // Cria nova aba
  Aba := TTabSheet.Create(PageControl);
  Aba.PageControl := PageControl;
  Aba.Caption := Titulo;

  // Cria e embute o form
  Form := FormClass.Create(Self);
  Form.BorderStyle := bsNone;
  Form.Align := alClient;
  Form.Parent := Aba;
  Form.Show;

  PageControl.ActivePage := Aba;
end;

end.

