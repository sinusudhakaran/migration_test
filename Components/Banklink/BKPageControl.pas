unit BKPageControl;

interface

uses
  SysUtils,
  Classes,
  Controls,
  RzTabs,
  RzPanel,
  RzCommon;

type
  TBKPageControl = class(TRzPageControl)
  private
    procedure SetRPageCaption(const Value: string);
    function GetRPageCaption: string;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    function AddTab(ATabIndex: integer = -1; ATabCaption: string = ''; ATabName: string = ''; IsTabVisible : boolean = false):
      TRZTabSheet;
    function AddTabWithPanel(ATabIndex: integer = -1; ATabCaption: string = ''; ATabName: string =
      ''; IsTabVisible : boolean = false; APanelName: string = ''): TRZPanel;
  published
    { Published declarations }
    property RPageCaption: string read GetRPageCaption write SetRPageCaption;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKPageControl]);
end;

{ TBKPageControl }

function TBKPageControl.AddTab(ATabIndex: integer; ATabCaption: string; ATabName: string; IsTabVisible : boolean):
  TRZTabSheet;
var
  i: integer;
  x: integer;
begin
  if (ATabIndex < 0) then
    i := 0
  else
    if (ATabIndex > Self.PageCount) then
      i := Self.PageCount
    else
      i := ATabIndex;
  Result := TRzTabSheet.Create(Self.Owner);
  Result.TabVisible := IsTabVisible;
  Result.Parent := Self;
  Result.PageControl := Self;
  Result.Height := Self.ClientHeight;
  Result.Width := Self.ClientWidth;
  if (Trim(ATabName) <> '') and not Assigned(Self.Owner.FindComponent(ATabName)) then
    Result.Name := ATabName
  else
    begin
      x := 1;
      while Assigned(Self.Owner.FindComponent(Format('%s_Page_%d', [Self.Name, x]))) do
        inc(x);
      Result.Name := Format('%s_Page_%d', [Self.Name, x]);
    end;

  if (Trim(ATabCaption) <> '') then
    Result.Caption := ATabCaption
  else
    Result.Caption := Format('Page %d', [i]);
  if Self.PageCount > 1 then
    Result.PageIndex := i;
end;

function TBKPageControl.AddTabWithPanel(ATabIndex: integer; ATabCaption: string;
  ATabName: string; IsTabVisible : boolean; APanelName: string): TRZPanel;
var
  ts: TRzTabSheet;
  x: integer;
  s: string;
begin
  ts := AddTab(ATabIndex, ATabCaption, ATabName, IsTabVisible);

  Result := TRzPanel.Create(Self.Owner);
  Result.Parent := ts;
  //Result.BorderSides := [];
  Result.BorderInner := fsFlat;
  Result.BorderOuter := fsFlat;
  if (Trim(APanelName) <> '') and not Assigned(Self.Owner.FindComponent(APanelName)) then
    Result.Name := APanelName
  else
    begin
      x := 1;
      s := Format('%s_%d', [ts.Name, x]);
      while Assigned(Self.Owner.FindComponent(s)) do
        begin
          inc(x);
          s := Format('%s_%d', [ts.Name, x]);
        end;
      Result.Name := s;
    end;
  Result.Align := alClient;
end;

function TBKPageControl.GetRPageCaption: string;
begin
  Result := '';
  if Assigned(ActivePage) then
    Result := ActivePage.Caption;
end;

procedure TBKPageControl.SetRPageCaption(const Value: string);
var
  x: integer;
begin
  if Value = '' then
    ActivePage := nil;

  for x := 0 to PageCount - 1 do
    if Pages[x].Caption = Value then
      begin
        ActivePage := Pages[x];
        Exit;
      end;
end;

end.

