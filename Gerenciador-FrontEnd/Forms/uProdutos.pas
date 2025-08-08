unit uProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.JSON,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Buttons,
  System.ImageList, Vcl.ImgList, Vcl.StdCtrls, Vcl.WinXCtrls,
  Datasnap.DBClient,
  ApiService, ProdutosController, Produto;

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
  private
    FCarregado: Boolean;
    procedure ConfigurarColunas;
    procedure MontarDataset;
    procedure PreencherDataset(const JsonArray: TJSONArray);
    function  RecordToProduto(const DS: TClientDataSet): TProduto;
    function  RegistrosSelecionadosCount: Integer;
    function  ColetarIdsSelecionados: TArray<string>;
  public
  end;

var
  frmProdutos: TfrmProdutos;

implementation

{$R *.dfm}

uses
  DateTimeUtils, JsonUtils, FormatUtils, System.Generics.Collections;

resourcestring
  MSG_CARREGAR_FALHA    = 'Não foi possível carregar a lista de produtos.';
  MSG_RESPOSTA_INVALIDA = 'O formato da resposta não foi reconhecido.';
  MSG_SEM_SELECAO       = 'Selecione ao menos um item para exclusão.';
  MSG_CONF_EXCLUIR      = 'Confirma a exclusão de %d item(s)? Esta ação não pode ser desfeita.';
  MSG_EXCLUSAO_OK       = '%d item(s) excluídos com sucesso.';
  MSG_EXCLUSAO_FALHA    = 'Não foi possível excluir os itens selecionados.';
  MSG_SEM_ALTERACOES    = 'Não há alterações pendentes.';
  MSG_SALVAR_OK         = 'Alterações realizadas com sucesso.';
  MSG_SALVAR_PARCIAL    = 'Falha ao realizar algumas alterações. Revise os itens destacados.';
  MSG_ATUALIZAR_FALHA   = 'Não foi possível atualizar o produto %s.' + sLineBreak + 'Detalhes: %s';
  MSG_CONF_DESCARTAR    = 'Deseja, descartar alterações realizadas?';
  MSG_OPERACAO_FALHA    = 'Não foi possível concluir a operação.';

procedure TfrmProdutos.FormCreate(Sender: TObject);
begin
  MontarDataset;
  ConfigurarColunas;
  dsProdutos.DataSet := cdsProdutos;

  DBGrid.Options := (DBGrid.Options
    + [dgEditing, dgTitles, dgColLines, dgRowLines]) - [dgIndicator];

  DBGrid.Enabled      := False;
  btnIncluir.Enabled  := False;
  btnGravar.Enabled   := False;
  btnCancelar.Enabled := False;
  btnExcluir.Enabled  := False;
  cdsProdutos.LogChanges := True;
end;

procedure TfrmProdutos.btnBuscarClick(Sender: TObject);
var
  Api : TApiService;
  Ctrl: TProdutosController;
  Msg, Resp: string;
  Root: TJSONValue;
  Arr: TJSONArray;
begin
  cdsProdutos.DisableControls;
  try
    cdsProdutos.EmptyDataSet;
    Api  := TApiService.Create;
    Ctrl := TProdutosController.Create(Api);
    try
      Resp := Ctrl.GetAll(Msg);
      if Msg <> '' then
      begin
        MessageDlg(MSG_CARREGAR_FALHA + sLineBreak + 'Detalhes: ' + Msg, mtError, [mbOK], 0);
        Exit;
      end;

      Root := JsonParse(Resp);
      try
        Arr := nil;

        if Root is TJSONArray then
          Arr := TJSONArray(Root)
        else if Root is TJSONObject then
          Arr := JsonGetArray(TJSONObject(Root), 'data');

        if Assigned(Arr) then
        begin
          PreencherDataset(Arr);
          if cdsProdutos.Active then
            cdsProdutos.MergeChangeLog;
          DBGrid.Enabled      := True;
          btnIncluir.Enabled  := True;
          btnGravar.Enabled   := True;
          btnCancelar.Enabled := True;
          btnExcluir.Enabled  := True;
        end
        else
          MessageDlg(MSG_RESPOSTA_INVALIDA, mtWarning, [mbOK], 0);
      finally
        Root.Free;
      end;
    finally
      Ctrl.Free;
      Api.Free;
    end;
  finally
    cdsProdutos.EnableControls;
  end;
end;

procedure TfrmProdutos.btnExcluirClick(Sender: TObject);
var
  Api  : TApiService;
  Ctrl : TProdutosController;
  Msg  : string;
  Ids  : TArray<string>;
  Deleted: Integer;
begin
  Ids := ColetarIdsSelecionados;
  if Length(Ids) = 0 then
  begin
    MessageDlg(MSG_SEM_SELECAO, mtInformation, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(Format(MSG_CONF_EXCLUIR, [Length(Ids)]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Api  := TApiService.Create;
  Ctrl := TProdutosController.Create(Api);
  try
    Ctrl.DeleteBatch(Ids, Msg);
    if Msg <> '' then
    begin
      MessageDlg(MSG_EXCLUSAO_FALHA + sLineBreak + 'Detalhes: ' + Msg, mtError, [mbOK], 0);
      Exit;
    end;

    Deleted := 0;
    cdsProdutos.DisableControls;
    try
      cdsProdutos.Last;
      while not cdsProdutos.BOF do
      begin
        if cdsProdutos.FieldByName('Selected').AsBoolean then
        begin
          cdsProdutos.Delete;
          Inc(Deleted);
        end
        else
          cdsProdutos.Prior;
      end;
    finally
      cdsProdutos.EnableControls;
    end;

    if cdsProdutos.Active and (cdsProdutos.ChangeCount > 0) then
      cdsProdutos.MergeChangeLog;

    MessageDlg(Format(MSG_EXCLUSAO_OK, [Deleted]), mtInformation, [mbOK], 0);
  finally
    Ctrl.Free;
    Api.Free;
  end;
end;

procedure TfrmProdutos.btnGravarClick(Sender: TObject);
var
  Api  : TApiService;
  Ctrl : TProdutosController;
  Msg  : string;
  Bmk  : TBookmark;
  HadError: Boolean;
  Prod : TProduto;
begin
  if cdsProdutos.State in dsEditModes then
    cdsProdutos.Post;

  if not cdsProdutos.UpdatesPending then
  begin
    MessageDlg(MSG_SEM_ALTERACOES, mtInformation, [mbOK], 0);
    Exit;
  end;

  Api  := TApiService.Create;
  Ctrl := TProdutosController.Create(Api);
  Bmk := cdsProdutos.GetBookmark;
  HadError := False;
  try
    cdsProdutos.DisableControls;
    try
      cdsProdutos.First;
      while not cdsProdutos.Eof do
      begin
        if cdsProdutos.UpdateStatus = usModified then
        begin
          Prod := RecordToProduto(cdsProdutos);
          try
            Ctrl.Put(Prod, Msg);
            if Msg <> '' then
            begin
              HadError := True;
              MessageDlg(Format(MSG_ATUALIZAR_FALHA,
                [cdsProdutos.FieldByName('Code').AsString, Msg]),
                mtError, [mbOK], 0);
            end;
          finally
            Prod.Free;
          end;
        end;
        cdsProdutos.Next;
      end;
    finally
      cdsProdutos.EnableControls;
    end;

    if not HadError then
    begin
      cdsProdutos.MergeChangeLog;
      MessageDlg(MSG_SALVAR_OK, mtInformation, [mbOK], 0);
    end
    else
      MessageDlg(MSG_SALVAR_PARCIAL, mtWarning, [mbOK], 0);
  finally
    if Bmk <> nil then cdsProdutos.GotoBookmark(Bmk);
    cdsProdutos.FreeBookmark(Bmk);
    Ctrl.Free;
    Api.Free;
  end;
end;

procedure TfrmProdutos.btnCancelarClick(Sender: TObject);
begin
  if not ((cdsProdutos.State in dsEditModes) or cdsProdutos.UpdatesPending) then
  begin
    MessageDlg(MSG_SEM_ALTERACOES, mtInformation, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(MSG_CONF_DESCARTAR, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if cdsProdutos.State in dsEditModes then
      cdsProdutos.Cancel;
    cdsProdutos.CancelUpdates;
  end;
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
  OldLog: Boolean;
begin
  if (Column.FieldName = 'Selected') and not cdsProdutos.IsEmpty then
  begin
    OldLog := cdsProdutos.LogChanges;
    cdsProdutos.DisableControls;
    try
      cdsProdutos.LogChanges := False;
      cdsProdutos.Edit;
      cdsProdutos.FieldByName('Selected').AsBoolean :=
        not cdsProdutos.FieldByName('Selected').AsBoolean;
      cdsProdutos.Post;
    finally
      cdsProdutos.LogChanges := OldLog;
      cdsProdutos.EnableControls;
    end;

    DBGrid.Invalidate;
  end;
end;

procedure TfrmProdutos.DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  COLOR_SELECTED = $E6D8AD;
  COLOR_MODIFIED = $B3DEF5;
var
  R: TRect;
  Flags: UINT;
  IsChecked, IsModified: Boolean;
  Bg: TColor;
begin
  if not cdsProdutos.Active then
  begin
    DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    Exit;
  end;

  IsChecked  := cdsProdutos.FieldByName('Selected').AsBoolean;
  IsModified := (cdsProdutos.UpdateStatus = usModified);

  if IsChecked then
    Bg := COLOR_SELECTED
  else if IsModified and (Column.FieldName <> 'Selected') then
    Bg := COLOR_MODIFIED
  else
    Bg := clWindow;

  DBGrid.Canvas.Brush.Color := Bg;
  DBGrid.Canvas.FillRect(Rect);

  if Column.FieldName = 'Selected' then
  begin
    R := Rect;
    InflateRect(R, -6, -4);
    Flags := DFCS_BUTTONCHECK;
    if IsChecked then
      Flags := Flags or DFCS_CHECKED;
    DrawFrameControl(DBGrid.Canvas.Handle, R, DFC_BUTTON, Flags);
    Exit;
  end;

  DBGrid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TfrmProdutos.ConfigurarColunas;
var
  Col: TColumn;
begin
  DBGrid.Columns.Clear;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'Selected';
  Col.Title.Caption := '';
  Col.Width := 28;
  Col.ReadOnly := True;
  Col.Title.Alignment := taCenter;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'Code';
  Col.Title.Caption := 'Código';
  Col.Width := 60;
  Col.ReadOnly := True;
  Col.Alignment := taCenter;
  Col.Title.Alignment := taCenter;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'Name';
  Col.Title.Caption := 'Nome';
  Col.Width := 220;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'Description';
  Col.Title.Caption := 'Descrição';
  Col.Width := 280;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'Price';
  Col.Title.Caption := 'Preço (R$)';
  Col.Width := 60;
  Col.Alignment := taRightJustify;
  Col.Title.Alignment := taRightJustify;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'Stock';
  Col.Title.Caption := 'Estoque';
  Col.Width := 60;
  Col.Alignment := taRightJustify;
  Col.Title.Alignment := taRightJustify;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'CreatedAt';
  Col.Title.Caption := 'Criado em';
  Col.Width := 140;
  Col.ReadOnly := True;

  Col := DBGrid.Columns.Add;
  Col.FieldName := 'UpdatedAt';
  Col.Title.Caption := 'Atualizado em';
  Col.Width := 140;
  Col.ReadOnly := True;
end;

procedure TfrmProdutos.MontarDataset;
begin
  cdsProdutos.Close;
  cdsProdutos.FieldDefs.Clear;
  cdsProdutos.FieldDefs.Add('Selected',   ftBoolean);
  cdsProdutos.FieldDefs.Add('Id',         ftString, 36);
  cdsProdutos.FieldDefs.Add('Code',       ftInteger);
  cdsProdutos.FieldDefs.Add('Name',       ftString, 255);
  cdsProdutos.FieldDefs.Add('Description',ftString, 500);
  cdsProdutos.FieldDefs.Add('Price',      ftFloat);
  cdsProdutos.FieldDefs.Add('Stock',      ftInteger);
  cdsProdutos.FieldDefs.Add('CreatedAt',  ftDateTime);
  cdsProdutos.FieldDefs.Add('UpdatedAt',  ftDateTime);
  cdsProdutos.CreateDataSet;
end;

procedure TfrmProdutos.PreencherDataset(const JsonArray: TJsONArray);
var
  i: integer;
  s: string;
  Obj: TJsONObject;
  dt: TDateTime;
begin
  for i := 0 to JsonArray.Count - 1 do
  begin
    if not (JsonArray.items[i] is TJsONObject) then
      Continue;

    Obj := TJsONObject(JsonArray.items[i]);

    cdsProdutos.Append;
    cdsProdutos.FieldByName('selected').AsBoolean := False;

    cdsProdutos.FieldByName('id').Asstring          := JsonGetstr(Obj, 'id');
    cdsProdutos.FieldByName('Code').Asinteger       := JsonGetint(Obj, 'code');
    cdsProdutos.FieldByName('Name').Asstring        := JsonGetstr(Obj, 'name');
    cdsProdutos.FieldByName('Description').Asstring := JsonGetstr(Obj, 'description');
    cdsProdutos.FieldByName('Price').AsFloat        := JsonGetFloat(Obj, 'price');
    cdsProdutos.FieldByName('stock').Asinteger      := JsonGetint(Obj, 'stock');

    s := JsonGetstr(Obj, 'createdAt');
    if ParseisO8601(s, dt) then
      cdsProdutos.FieldByName('CreatedAt').AsDateTime := dt;

    s := JsonGetstr(Obj, 'updatedAt');
    if ParseisO8601(s, dt) then
      cdsProdutos.FieldByName('UpdatedAt').AsDateTime := dt;

    cdsProdutos.Post;
  end;

  cdsProdutos.indexFieldNames := 'Code';
end;

function TfrmProdutos.RecordToProduto(const DS: TClientDataSet): TProduto;
begin
  Result := TProduto.Create;
  Result.Id          := DS.FieldByName('Id').AsString;
  Result.Code        := DS.FieldByName('Code').AsInteger;
  Result.Name        := DS.FieldByName('Name').AsString;
  Result.Description := DS.FieldByName('Description').AsString;
  Result.Price       := DS.FieldByName('Price').AsFloat;
  Result.Stock       := DS.FieldByName('Stock').AsInteger;
  Result.CreatedAt   := DS.FieldByName('CreatedAt').AsDateTime;
  if not DS.FieldByName('UpdatedAt').IsNull then
    Result.UpdatedAt := DS.FieldByName('UpdatedAt').AsDateTime;
end;

function TfrmProdutos.RegistrosSelecionadosCount: Integer;
var
  Bmk: TBookmark;
begin
  Result := 0;
  if not cdsProdutos.Active then Exit;

  Bmk := cdsProdutos.GetBookmark;
  try
    cdsProdutos.DisableControls;
    cdsProdutos.First;
    while not cdsProdutos.Eof do
    begin
      if cdsProdutos.FieldByName('Selected').AsBoolean then
        Inc(Result);

      cdsProdutos.Next;
    end;
  finally
    if Bmk <> nil then
      cdsProdutos.GotoBookmark(Bmk);

    cdsProdutos.FreeBookmark(Bmk);
    cdsProdutos.EnableControls;
  end;
end;

function TfrmProdutos.ColetarIdsSelecionados: TArray<string>;
var
  L: TList<string>;
  Bmk: TBookmark;
begin
  SetLength(Result, 0);
  if not cdsProdutos.Active then Exit;

  L := TList<string>.Create;
  Bmk := cdsProdutos.GetBookmark;
  try
    cdsProdutos.DisableControls;
    cdsProdutos.First;
    while not cdsProdutos.Eof do
    begin
      if cdsProdutos.FieldByName('Selected').AsBoolean then
        L.Add(cdsProdutos.FieldByName('Id').AsString);
      cdsProdutos.Next;
    end;
    Result := L.ToArray;
  finally
    if Bmk <> nil then cdsProdutos.GotoBookmark(Bmk);
    cdsProdutos.FreeBookmark(Bmk);
    cdsProdutos.EnableControls;
    L.Free;
  end;
end;

end.

