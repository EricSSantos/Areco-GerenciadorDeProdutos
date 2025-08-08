unit uProdutos;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.JSON,
  System.StrUtils,
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
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.WinXCtrls,
  Datasnap.DBClient,
  ApiService,
  ProdutosController,
  Produto;

type
  TfrmProdutos = class(TForm)
    Body: TPanel;
    Header: TPanel;
    btnBuscar: TBitBtn;
    btnIncluir: TBitBtn;
    btnExcluir: TBitBtn;
    btnCancelar: TBitBtn;
    btnGravar: TBitBtn;
    sp1: TLabel;
    sp2: TLabel;
    GroupBox: TGroupBox;
    DBGrid: TDBGrid;
    dsProdutos: TDataSource;
    cdsProdutos: TClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure DBGridCellClick(Column: TColumn);
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cdsProdutosAfterPost(DataSet: TDataSet);
    procedure cdsProdutosAfterDelete(DataSet: TDataSet);
  private
    FId: TField;
    FCode, FStock: TIntegerField;
    FName, FDesc: TStringField;
    FPrice: TFloatField;
    FCreated, FUpdated: TDateTimeField;

    FSel: TBooleanField;
    FSelectedCount: Integer;

    procedure ConfigurarColunas;
    procedure MontarDataSet;
    procedure PreencherDataSet(const AArrayJson: TJSONArray);
    function  DataSetParaProduto(const AConjuntoDados: TClientDataSet): TProduto;
    procedure AtualizarUI(AEditMode: Boolean);
    procedure LimparDados;
    function  RegistrosSelecionados: Integer; inline;
    function  ObterIds: TArray<string>;
    function  Errors(const AErrors: TArray<string>): string;
  public
  end;

var
  frmProdutos: TfrmProdutos;

implementation

{$R *.dfm}

uses
  DateTimeUtils,
  JsonUtils,
  FormatUtils,
  System.Generics.Collections;

const
  CAMPO_SELECIONADO       = 'Selected';
  COR_BG_SELECIONADO      = $E6D8AD;
  COR_BG_LINHA_MODIFICADA = $B3DEF5;

resourcestring
  MSG_CARREGAR_FALHA    = 'Não foi possível carregar a lista de produtos.';
  MSG_RESPOSTA_INVALIDA = 'O formato da resposta não foi reconhecido.';
  MSG_SEM_SELECAO       = 'Selecione ao menos um item para exclusão.';
  MSG_CONF_EXCLUIR      = 'Confirma a exclusão de %d item(s)? Esta ação não pode ser desfeita.';
  MSG_EXCLUSAO_OK       = '%d item(s) excluídos com sucesso.';
  MSG_EXCLUSAO_FALHA    = 'Não foi possível excluir os itens selecionados.';
  MSG_SEM_ALTERACOES    = 'Não há alterações pendentes.';
  MSG_SALVAR_OK         = 'Alterações realizadas com sucesso.';
  MSG_ATUALIZAR_FALHA   = 'Não foi possível atualizar o produto %s.' + sLineBreak + 'Detalhes: %s';
  MSG_CONF_DESCARTAR    = 'Deseja descartar as alterações realizadas?';
  MSG_OPERACAO_FALHA    = 'Não foi possível concluir a operação.';

procedure TfrmProdutos.FormCreate(Sender: TObject);
begin
  MontarDataSet;
  ConfigurarColunas;
  DBGrid.DoubleBuffered := True;
  FSelectedCount := 0;
  AtualizarUI(False);
end;

procedure TfrmProdutos.AtualizarUI(AEditMode: Boolean);
var
  temDados, temSelecao, temEdicoes, emEdicao: Boolean;
  procedure ResetUI;
  begin
    btnBuscar.Enabled   := False;
    btnIncluir.Enabled  := False;
    btnExcluir.Enabled  := False;
    btnCancelar.Enabled := False;
    btnGravar.Enabled   := False;
    DBGrid.Enabled      := False;
  end;
begin
  ResetUI;
  if not AEditMode then
  begin
    btnBuscar.Enabled := True;
    Exit;
  end;

  emEdicao  := cdsProdutos.Active and (cdsProdutos.State in dsEditModes);
  temDados  := cdsProdutos.Active and (cdsProdutos.RecordCount > 0);

  if emEdicao then
    temSelecao := False
  else
    temSelecao := RegistrosSelecionados > 0;

  temEdicoes := cdsProdutos.Active and
                (cdsProdutos.UpdatesPending or cdsProdutos.Modified);

  DBGrid.Enabled      := True;
  btnIncluir.Enabled  := True;
  btnCancelar.Enabled := True;
  btnExcluir.Enabled  := not emEdicao and temSelecao;
  btnGravar.Enabled   := temDados and temEdicoes and not temSelecao;
end;

procedure TfrmProdutos.LimparDados;
begin
  if cdsProdutos.Active then
  begin
    if (cdsProdutos.State in dsEditModes) then
      cdsProdutos.Cancel;
    if cdsProdutos.UpdatesPending then
      cdsProdutos.CancelUpdates;
    cdsProdutos.EmptyDataSet;
  end;
  FSelectedCount := 0;
end;

procedure TfrmProdutos.btnBuscarClick(Sender: TObject);
var
  service: TApiService;
  controller: TProdutosController;
  resposta: TApiResponse;
  json: TJSONValue;
  arrayItens: TJSONArray;
  detalhesErro: string;
begin
  Screen.Cursor := crHourGlass;
  cdsProdutos.DisableControls;
  cdsProdutos.LogChanges := False;
  try
    cdsProdutos.EmptyDataSet;
    FSelectedCount := 0;

    service := TApiService.Create;
    controller := TProdutosController.Create(service);
    try
      resposta := controller.GetAll;
      if not resposta.IsSuccess then
      begin
        detalhesErro := Errors(resposta.Errors);
        if detalhesErro <> '' then
          MessageDlg(MSG_CARREGAR_FALHA + sLineBreak + 'Detalhes: ' + detalhesErro, mtError, [mbOK], 0)
        else if resposta.Title <> '' then
          MessageDlg(MSG_CARREGAR_FALHA + sLineBreak + 'Detalhes: ' + resposta.Title, mtError, [mbOK], 0)
        else
          MessageDlg(MSG_CARREGAR_FALHA, mtError, [mbOK], 0);
        Exit;
      end;

      json := JsonParse(resposta.Data);
      try
        arrayItens := nil;
        if json is TJSONArray then
          arrayItens := TJSONArray(json)
        else if json is TJSONObject then
          arrayItens := JsonGetArray(TJSONObject(json), 'items');

        if not Assigned(arrayItens) then
        begin
          MessageDlg(MSG_RESPOSTA_INVALIDA, mtWarning, [mbOK], 0);
          Exit;
        end;

        PreencherDataSet(arrayItens);
        cdsProdutos.IndexFieldNames := 'Code';
      finally
        json.Free;
      end;

      AtualizarUI(True);

    finally
      controller.Free;
      service.Free;
    end;

  finally
    cdsProdutos.LogChanges := True;
    cdsProdutos.EnableControls;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmProdutos.btnExcluirClick(Sender: TObject);
var
  service: TApiService;
  controller: TProdutosController;
  resposta: TApiResponse;
  idsSelecionados: TArray<string>;
  quantidadeExcluida: Integer;
  detalhesErro: string;
begin
  idsSelecionados := ObterIds;
  if Length(idsSelecionados) = 0 then
  begin
    MessageDlg(MSG_SEM_SELECAO, mtInformation, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(Format(MSG_CONF_EXCLUIR, [Length(idsSelecionados)]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    service := TApiService.Create;
    controller := TProdutosController.Create(service);
    try
      resposta := controller.DeleteBatch(idsSelecionados);

      if not resposta.IsSuccess then
      begin
        detalhesErro := Errors(resposta.Errors);
        if detalhesErro = '' then
          detalhesErro := resposta.Title;
        if detalhesErro = '' then
          detalhesErro := MSG_EXCLUSAO_FALHA;

        MessageDlg(detalhesErro, mtError, [mbOK], 0);
        Exit;
      end;

      quantidadeExcluida := 0;
      cdsProdutos.DisableControls;
      try
        cdsProdutos.First;
        while not cdsProdutos.Eof do
        begin
          if FSel.AsBoolean then
          begin
            cdsProdutos.Delete;
            Inc(quantidadeExcluida);
            Dec(FSelectedCount);
          end
          else
            cdsProdutos.Next;
        end;
      finally
        cdsProdutos.EnableControls;
      end;

      if cdsProdutos.Active and (cdsProdutos.ChangeCount > 0) then
        cdsProdutos.MergeChangeLog;

      MessageDlg(Format(MSG_EXCLUSAO_OK, [quantidadeExcluida]), mtInformation, [mbOK], 0);
      AtualizarUI(True);
    finally
      controller.Free;
      service.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmProdutos.btnGravarClick(Sender: TObject);
var
  service: TApiService;
  controller: TProdutosController;
  resposta: TApiResponse;
  houveErro: Boolean;
  detalhes, codigoStr: string;
  dataSet: TClientDataSet;
  produto: TProduto;
begin
  if cdsProdutos.State in dsEditModes then
    cdsProdutos.Post;

  if not cdsProdutos.UpdatesPending then
  begin
    MessageDlg(MSG_SEM_ALTERACOES, mtInformation, [mbOK], 0);
    Exit;
  end;

  service := TApiService.Create;
  controller := TProdutosController.Create(service);
  houveErro := False;
  dataSet := TClientDataSet.Create(nil);
  try
    dataSet.Data := cdsProdutos.Delta;
    dataSet.First;
    while not dataSet.Eof do
    begin
      if dataSet.UpdateStatus = usModified then
      begin
        produto := DataSetParaProduto(dataSet);
        try
          resposta := controller.Put(produto);
          if not resposta.IsSuccess then
          begin
            houveErro := True;
            detalhes := Errors(resposta.Errors);
            if detalhes = '' then
              detalhes := resposta.Title;

            if dataSet.FindField('Code') <> nil then
              codigoStr := dataSet.FieldByName('Code').AsString
            else
              codigoStr := '(s/ código)';

            MessageDlg(Format(MSG_ATUALIZAR_FALHA, [codigoStr,
                 IfThen(detalhes <> '', detalhes, MSG_OPERACAO_FALHA)]), mtError, [mbOK], 0);
          end;
        finally
          produto.Free;
        end;
      end;
      dataSet.Next;
    end;

    if not houveErro then
    begin
      cdsProdutos.MergeChangeLog;
      MessageDlg(MSG_SALVAR_OK, mtInformation, [mbOK], 0);
    end;

  finally
    dataSet.Free;
    controller.Free;
    service.Free;
  end;
end;

procedure TfrmProdutos.btnCancelarClick(Sender: TObject);
begin
  if cdsProdutos.Active and (cdsProdutos.UpdatesPending or (cdsProdutos.State in dsEditModes)) then
  begin
    if MessageDlg(MSG_CONF_DESCARTAR, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

    if cdsProdutos.State in dsEditModes then
      cdsProdutos.Cancel;

    if cdsProdutos.UpdatesPending then
      cdsProdutos.CancelUpdates;
  end;

  LimparDados;
  AtualizarUI(False);
end;

procedure TfrmProdutos.ConfigurarColunas;
var
  coluna: TColumn;
begin
  DBGrid.Columns.Clear;

  // Checkbox
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'Selected';
  coluna.Title.Caption   := '';
  coluna.Width           := 28;
  coluna.ReadOnly        := True;
  coluna.Title.Alignment := taCenter;
  coluna.Alignment       := taCenter;

  // Código
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'Code';
  coluna.Title.Caption   := 'Código';
  coluna.Width           := 60;
  coluna.ReadOnly        := True;
  coluna.Alignment       := taCenter;
  coluna.Title.Alignment := taCenter;

  // Nome
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'Name';
  coluna.Title.Caption   := 'Nome';
  coluna.Width           := 220;

  // Descrição
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'Description';
  coluna.Title.Caption   := 'Descrição';
  coluna.Width           := 280;

  // Preço
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'Price';
  coluna.Title.Caption   := 'Preço (R$)';
  coluna.Width           := 60;
  coluna.Alignment       := taRightJustify;
  coluna.Title.Alignment := taRightJustify;

  // Estoque
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'Stock';
  coluna.Title.Caption   := 'Estoque';
  coluna.Width           := 60;
  coluna.Alignment       := taRightJustify;
  coluna.Title.Alignment := taRightJustify;

  // Criado em
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'CreatedAt';
  coluna.Title.Caption   := 'Criado em';
  coluna.Width           := 140;
  coluna.ReadOnly        := True;

  // Atualizado em
  coluna := DBGrid.Columns.Add;
  coluna.FieldName       := 'UpdatedAt';
  coluna.Title.Caption   := 'Atualizado em';
  coluna.Width           := 140;
  coluna.ReadOnly        := True;
end;

procedure TfrmProdutos.MontarDataSet;
var
  campoSelecao: TBooleanField;
begin
  cdsProdutos.Close;
  cdsProdutos.FieldDefs.Clear;
  cdsProdutos.FieldDefs.Add('Selected',    ftBoolean);
  cdsProdutos.FieldDefs.Add('Id',          ftString, 36);
  cdsProdutos.FieldDefs.Add('Code',        ftInteger);
  cdsProdutos.FieldDefs.Add('Name',        ftString, 255);
  cdsProdutos.FieldDefs.Add('Description', ftString, 500);
  cdsProdutos.FieldDefs.Add('Price',       ftFloat);
  cdsProdutos.FieldDefs.Add('Stock',       ftInteger);
  cdsProdutos.FieldDefs.Add('CreatedAt',   ftDateTime);
  cdsProdutos.FieldDefs.Add('UpdatedAt',   ftDateTime);
  cdsProdutos.CreateDataSet;
  campoSelecao := TBooleanField(cdsProdutos.FieldByName('Selected'));
  campoSelecao.DisplayValues := ';';

  FSel     := TBooleanField(cdsProdutos.FieldByName('Selected'));
  FId      := cdsProdutos.FieldByName('Id');
  FCode    := TIntegerField(cdsProdutos.FieldByName('Code'));
  FName    := TStringField(cdsProdutos.FieldByName('Name'));
  FDesc    := TStringField(cdsProdutos.FieldByName('Description'));
  FPrice   := TFloatField(cdsProdutos.FieldByName('Price'));
  FStock   := TIntegerField(cdsProdutos.FieldByName('Stock'));
  FCreated := TDateTimeField(cdsProdutos.FieldByName('CreatedAt'));
  FUpdated := TDateTimeField(cdsProdutos.FieldByName('UpdatedAt'));
  FSel.DisplayValues := ';';
end;

procedure TfrmProdutos.PreencherDataSet(const AArrayJson: TJSONArray);
var
  i: Integer;
  texto: string;
  objeto: TJSONObject;
  data: TDateTime;
begin
  for i := 0 to AArrayJson.Count - 1 do
  begin
    if not (AArrayJson.Items[i] is TJSONObject) then
      Continue;

    objeto := TJSONObject(AArrayJson.Items[i]);

    cdsProdutos.Append;
    FSel.AsBoolean   := False;
    FId.AsString     := JsonGetStr(objeto, 'id');
    FCode.AsInteger  := JsonGetInt(objeto, 'code');
    FName.AsString   := JsonGetStr(objeto, 'name');
    FDesc.AsString   := JsonGetStr(objeto, 'description');
    FPrice.AsFloat   := JsonGetFloat(objeto, 'price');
    FStock.AsInteger := JsonGetInt(objeto, 'stock');

    texto := JsonGetStr(objeto, 'createdAt');
    if ParseIsO8601(texto, data) then FCreated.AsDateTime := data;

    texto := JsonGetStr(objeto, 'updatedAt');
    if ParseIsO8601(texto, data) then FUpdated.AsDateTime := data;

    cdsProdutos.Post;
  end;
end;

function TfrmProdutos.DataSetParaProduto(const AConjuntoDados: TClientDataSet): TProduto;
begin
  Result := TProduto.Create;
  Result.Id          := AConjuntoDados.FieldByName('Id').AsString;
  Result.Code        := AConjuntoDados.FieldByName('Code').AsInteger;
  Result.Name        := AConjuntoDados.FieldByName('Name').AsString;
  Result.Description := AConjuntoDados.FieldByName('Description').AsString;
  Result.Price       := AConjuntoDados.FieldByName('Price').AsFloat;
  Result.Stock       := AConjuntoDados.FieldByName('Stock').AsInteger;
  Result.CreatedAt   := AConjuntoDados.FieldByName('CreatedAt').AsDateTime;
  if not AConjuntoDados.FieldByName('UpdatedAt').IsNull then
    Result.UpdatedAt := AConjuntoDados.FieldByName('UpdatedAt').AsDateTime;
end;

function TfrmProdutos.RegistrosSelecionados: Integer;
begin
  Result := FSelectedCount;
end;

function TfrmProdutos.ObterIds: TArray<string>;
var
  lista: TList<string>;
  marcador: TBookmark;
begin
  SetLength(Result, 0);
  if not cdsProdutos.Active then Exit;

  lista := TList<string>.Create;
  marcador := cdsProdutos.GetBookmark;
  try
    cdsProdutos.DisableControls;
    cdsProdutos.First;
    while not cdsProdutos.Eof do
    begin
      if FSel.AsBoolean then
        lista.Add(FId.AsString);
      cdsProdutos.Next;
    end;
    Result := lista.ToArray;
  finally
    if marcador <> nil then cdsProdutos.GotoBookmark(marcador);
    cdsProdutos.FreeBookmark(marcador);
    cdsProdutos.EnableControls;
    lista.Free;
  end;
end;

function TfrmProdutos.Errors(const AErrors: TArray<string>): string;
var
  s: string;
begin
  Result := '';
  for s in AErrors do
    if s.Trim <> '' then
      Result := Result + IfThen(Result <> '', sLineBreak) + s.Trim;
end;

procedure TfrmProdutos.DBGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DOWN)
     and cdsProdutos.Active
     and not (cdsProdutos.State in dsEditModes)
     and (cdsProdutos.RecordCount > 0)
     and (cdsProdutos.RecNo = cdsProdutos.RecordCount) then
  begin
    Key := 0;
  end;
end;

procedure TfrmProdutos.DBGridCellClick(Column: TColumn);
var
  novo: Boolean;
  prevLog: Boolean;
begin
  if (Column.FieldName = CAMPO_SELECIONADO) and not cdsProdutos.IsEmpty then
  begin
    prevLog := cdsProdutos.LogChanges;
    cdsProdutos.DisableControls;
    try
      cdsProdutos.LogChanges := False;
      cdsProdutos.Edit;
      novo := not FSel.AsBoolean;
      FSel.AsBoolean := novo;
      cdsProdutos.Post;
    finally
      cdsProdutos.LogChanges := prevLog;
      cdsProdutos.EnableControls;
    end;

    if novo then Inc(FSelectedCount) else Dec(FSelectedCount);
    AtualizarUI(True);
    DBGrid.Invalidate;
  end;
end;

procedure TfrmProdutos.DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  retanguloCheck: TRect;
  desenhoCheck: UINT;
  estaSelecionado: Boolean;
  linhaModificada: Boolean;
  corFundo: TColor;
begin
  if not cdsProdutos.Active then
  begin
    DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    Exit;
  end;

  estaSelecionado := FSel.AsBoolean;
  linhaModificada := (cdsProdutos.UpdateStatus = usModified);

  if estaSelecionado then
    corFundo := COR_BG_SELECIONADO
  else if linhaModificada and (Column.FieldName <> CAMPO_SELECIONADO) then
    corFundo := COR_BG_LINHA_MODIFICADA
  else
    corFundo := DBGrid.Color;

  DBGrid.Canvas.Brush.Color := corFundo;
  DBGrid.Canvas.FillRect(Rect);

  if SameText(Column.FieldName, CAMPO_SELECIONADO) then
  begin
    retanguloCheck := Rect;
    InflateRect(retanguloCheck, -1, -1);
    desenhoCheck := DFCS_BUTTONCHECK;
    if estaSelecionado then
      desenhoCheck := desenhoCheck or DFCS_CHECKED;

    DrawFrameControl(DBGrid.Canvas.Handle, retanguloCheck, DFC_BUTTON, desenhoCheck);
    Exit;
  end;

  DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmProdutos.cdsProdutosAfterPost(DataSet: TDataSet);
begin
  AtualizarUI(True);
  DBGrid.Repaint;
end;

procedure TfrmProdutos.cdsProdutosAfterDelete(DataSet: TDataSet);
begin
  AtualizarUI(True);
  DBGrid.Repaint;
end;

end.

