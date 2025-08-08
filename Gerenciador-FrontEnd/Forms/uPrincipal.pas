unit uPrincipal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ExtCtrls,
  uProdutos;

type
  TfrmPrincipal = class(TForm)
    Timer: TTimer;
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    Controle1: TMenuItem;
    Produtos1: TMenuItem;
    Sair1: TMenuItem;
    PageControl: TPageControl;
    Home: TTabSheet;
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

uses
  DateTimeUtils;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  InicializarStatusBar;
  IniciarTimer;
end;

procedure TfrmPrincipal.TimerTimer(Sender: TObject);
begin
  StatusBar.Panels[0].Text := 'Data/Hora: ' + DisplayDateTimeBR(Now);
end;

procedure TfrmPrincipal.InicializarStatusBar;
begin
  StatusBar.Panels[0].Text := 'Data/Hora:';
  StatusBar.Panels[1].Text := 'Computador: ' + ObterNomeComputador;
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
  for i := 0 to PageControl.PageCount - 1 do
    if PageControl.Pages[i].Caption = Titulo then
    begin
      PageControl.ActivePageIndex := i;
      Exit;
    end;

  Aba := TTabSheet.Create(PageControl);
  Aba.PageControl := PageControl;
  Aba.Caption := Titulo;

  Form := FormClass.Create(Self);
  Form.BorderStyle := bsNone;
  Form.Align := alClient;
  Form.Parent := Aba;
  Form.Show;

  PageControl.ActivePage := Aba;
end;

end.

