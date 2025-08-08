unit DataSetUtils;

interface

uses
  Data.DB, Datasnap.DBClient;

procedure DS_SaveBookmark(DS: TDataSet; out Bmk: TBookmark);
procedure DS_RestoreBookmark(DS: TDataSet; var Bmk: TBookmark);

procedure DS_BeginSilent(const CDS: TClientDataSet; out OldLog: Boolean);
procedure DS_EndSilent(const CDS: TClientDataSet; const OldLog: Boolean);

procedure DS_ToggleBooleanField(const CDS: TClientDataSet; const FieldName:
  string; Silent: Boolean = True);
procedure DS_SetBooleanForAll(const CDS: TClientDataSet; const FieldName:
  string; Value: Boolean; Silent: Boolean = True);
function  DS_CountTrue(const CDS: TClientDataSet; const FieldName: string): Integer;

implementation

procedure DS_SaveBookmark(DS: TDataSet; out Bmk: TBookmark);
begin
  if (DS <> nil) and DS.Active then Bmk := DS.GetBookmark else Bmk := nil;
end;

procedure DS_RestoreBookmark(DS: TDataSet; var Bmk: TBookmark);
begin
  if (DS <> nil) and DS.Active and (Bmk <> nil) then
  begin
    DS.GotoBookmark(Bmk);
    DS.FreeBookmark(Bmk);
    Bmk := nil;
  end;
end;

procedure DS_BeginSilent(const CDS: TClientDataSet; out OldLog: Boolean);
begin
  OldLog := CDS.LogChanges;
  CDS.DisableControls;
  CDS.LogChanges := False;
end;

procedure DS_EndSilent(const CDS: TClientDataSet; const OldLog: Boolean);
begin
  CDS.LogChanges := OldLog;
  CDS.EnableControls;
end;

procedure DS_ToggleBooleanField(const CDS: TClientDataSet; const FieldName: string; Silent: Boolean);
var OldLog: Boolean;
begin
  if (CDS = nil) or not CDS.Active or CDS.IsEmpty then Exit;
  if Silent then DS_BeginSilent(CDS, OldLog);
  try
    CDS.Edit;
    CDS.FieldByName(FieldName).AsBoolean := not CDS.FieldByName(FieldName).AsBoolean;
    CDS.Post;
  finally
    if Silent then DS_EndSilent(CDS, OldLog);
  end;
end;

procedure DS_SetBooleanForAll(const CDS: TClientDataSet; const FieldName:
  string; Value: Boolean; Silent: Boolean);
var OldLog: Boolean; Bmk: TBookmark;
begin
  if (CDS = nil) or not CDS.Active then Exit;
  if Silent then DS_BeginSilent(CDS, OldLog);
  DS_SaveBookmark(CDS, Bmk);
  try
    CDS.First;
    while not CDS.Eof do
    begin
      if CDS.FieldByName(FieldName).AsBoolean <> Value then
      begin
        CDS.Edit;
        CDS.FieldByName(FieldName).AsBoolean := Value;
        CDS.Post;
      end;
      CDS.Next;
    end;
  finally
    DS_RestoreBookmark(CDS, Bmk);
    if Silent then DS_EndSilent(CDS, OldLog);
  end;
end;

function DS_CountTrue(const CDS: TClientDataSet; const FieldName: string): Integer;
var Bmk: TBookmark;
begin
  Result := 0;
  if (CDS = nil) or not CDS.Active then Exit;
  DS_SaveBookmark(CDS, Bmk);
  CDS.DisableControls;
  try
    CDS.First;
    while not CDS.Eof do
    begin
      if CDS.FieldByName(FieldName).AsBoolean then Inc(Result);
      CDS.Next;
    end;
  finally
    CDS.EnableControls;
    DS_RestoreBookmark(CDS, Bmk);
  end;
end;

end.

