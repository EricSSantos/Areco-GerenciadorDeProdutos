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
    procedure InitializeStatusBar;
    procedure StartTimer;
    function GetComputerNameText: string;
    procedure OpenTabWithForm(const ATitle: string; AFormClass: TFormClass);
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
  InitializeStatusBar;
  StartTimer;
end;

procedure TfrmPrincipal.TimerTimer(Sender: TObject);
begin
  StatusBar.Panels[0].Text := 'Data/Hora: ' + DisplayDateTimeBR(Now);
end;

procedure TfrmPrincipal.InitializeStatusBar;
begin
  StatusBar.Panels[0].Text := 'Data/Hora:';
  StatusBar.Panels[1].Text := 'Computador: ' + GetComputerNameText;
end;

function TfrmPrincipal.GetComputerNameText: string;
var
  buffer: array[0..MAX_COMPUTERNAME_LENGTH + 1] of Char;
  tamanho: DWORD;
begin
  tamanho := Length(buffer);
  if GetComputerName(buffer, tamanho) then
    Result := buffer
  else
    Result := 'Desconhecido';
end;

procedure TfrmPrincipal.StartTimer;
begin
  Timer.Interval := 1000;
  Timer.Enabled := True;
end;

procedure TfrmPrincipal.Produtos1Click(Sender: TObject);
begin
  OpenTabWithForm('Produtos', TfrmProdutos);
end;

procedure TfrmPrincipal.Sair1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.OpenTabWithForm(const ATitle: string; AFormClass: TFormClass);
var
  i: Integer;
  aba: TTabSheet;
  form: TForm;
begin
  for i := 0 to PageControl.PageCount - 1 do
    if PageControl.Pages[i].Caption = ATitle then
    begin
      PageControl.ActivePageIndex := i;
      Exit;
    end;

  aba := TTabSheet.Create(PageControl);
  aba.PageControl := PageControl;
  aba.Caption := ATitle;

  form := AFormClass.Create(Self);
  form.BorderStyle := bsNone;
  form.Align := alClient;
  form.Parent := aba;
  form.Show;

  PageControl.ActivePage := aba;
end;

end.

