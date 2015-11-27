unit RatingsListViewForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Platform,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.ListView.Types,
  FMX.ListView,
  Data.DB,
  Datasnap.DBClient,
  System.Rtti,
  System.Bindings.Outputs,
  Fmx.Bind.Editors,
  Data.Bind.EngExt,
  Fmx.Bind.DBEngExt,
  Data.Bind.Components,
  Data.Bind.DBScope, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation, Data.Bind.ObjectScope, FMX.Ani;

type
  TfrmMainForm = class(TForm)
    ToolBar1: TToolBar;
    Label1: TLabel;
    lvwRatings: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    PrototypeBindSource1: TPrototypeBindSource;
    GradientAnimation1: TGradientAnimation;
    procedure lvwRatingsUpdateObjects(const Sender: TObject; const AItem: TListViewItem);
    procedure LinkFillControlToField1FilledListItem(Sender: TObject; const AEditor: IBindListEditorItem);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Clients : TStringList;
  public
  end;

var
  frmMainForm: TfrmMainForm;

implementation

{$R *.fmx}

uses
  FMX.Objects,
  RatingListItems;

const
  sCode = 'Code';
  sName = 'Name';
  sJanuary = 'Jan';
  sFebruary = 'Feb';
  sMarch = 'Mar';
  sApril = 'Apr';
  sMay = 'May';
  sJune = 'Jun';
  sJuly = 'Jul';
  sAugust = 'Aug';
  sSeptember = 'Sep';
  sOctober = 'Oct';
  sNovember = 'Nov';
  sDecember = 'Dec';

  sNoCding = 'NoCoding';
  sPartialCoding = 'PartialCoding';
  sFullCoding = 'FullCoding';
  sNone = 'Nothing';

procedure TfrmMainForm.lvwRatingsUpdateObjects( const Sender: TObject; const AItem: TListViewItem );
var
  TextLabel: TListItemText;
  MonthIcon: TListItemCodingIcon;
  ObjCount : Integer;
  ScreenSvc: IFMXScreenService;
  ScreenSize : string;
  Gap : integer;
  Start : integer;
const
  CodingScreenWidth = 300;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, IInterface(ScreenSvc)) then
  begin
    ScreenSize := Format('Resolution: %fX%f', [ScreenSvc.GetScreenSize.X, ScreenSvc.GetScreenSize.Y]);
  end;

  Gap := (Screen.Size.Width - 150 ) div 13;
  Start := -5;

  MonthIcon := AItem.Objects.FindObject( sDecember ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sDecember;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sNovember ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sNovember;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sOctober ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sOctober;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sSeptember ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sSeptember;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sAugust ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sAugust;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sJuly ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sJuly;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sJune ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sJune;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sMay ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sMay;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sApril ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sApril;
    MonthIcon.PlaceOffset.X :=Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sMarch ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sMarch;
    MonthIcon.PlaceOffset.X := Start;
  end;

  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sFebruary ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sFebruary;
    MonthIcon.PlaceOffset.X := Start;
  end;
  Start := Start - Gap;
  MonthIcon := AItem.Objects.FindObject( sJanuary ) as TListItemCodingIcon;
  if MonthIcon = nil then
  begin
    MonthIcon := TListItemCodingIcon.Create( AItem );
    MonthIcon.Name := sJanuary;
    MonthIcon.PlaceOffset.X := Start;
  end;

  Start := Start - Gap - 30;
  TextLabel := AItem.Objects.FindObject( sName ) as TListItemText;
  if TextLabel = nil then
  begin
    TextLabel := TListItemText.Create( AItem );
    TextLabel.Name := sName;
    TextLabel.Align := TListItemAlign.Trailing;
    TextLabel.VertAlign := TListItemAlign.Center;
    TextLabel.TextAlign := TTextAlign.taCenter;
    TextLabel.PlaceOffset.X := Start;
    TextLabel.PlaceOffset.Y := 10;
    TextLabel.Font.Size := 16;
    TextLabel.TextColor := TAlphaColors.Violet;
    TextLabel.Width := 50;
    TextLabel.Height := 20;
  end;
 TextLabel := AItem.Objects.FindObject( sCode ) as TListItemText;
  if TextLabel = nil then
  begin
    TextLabel := TListItemText.Create( AItem );
    TextLabel.Name := sCode;
    TextLabel.Align := TListItemAlign.Trailing;
    TextLabel.VertAlign := TListItemAlign.Center;
    TextLabel.TextAlign := TTextAlign.taCenter;
    TextLabel.PlaceOffset.X := Start;//Screen.Size.Width div 2 - CodingScreenWidth div 2;//-430;
    TextLabel.PlaceOffset.Y := -4;
    TextLabel.TextColor := TAlphaColors.Purple;
    TextLabel.Font.Size := 13;
    TextLabel.Width := 40;
    TextLabel.Height := 18;
  end;










end;

procedure TfrmMainForm.FormShow(Sender: TObject);
begin


  {cdsClients.CreateDataSet;
  cdsClients.Open;
  cdsClients.Insert;
  cdsClients.FieldByName('Code').AsString := '434';
  cdsClients.FieldByName('Name').AsString := 'sinu';
  cdsClients.FieldByName('Jan').AsString := '1';
  cdsClients.FieldByName('Feb').AsString := '1';
  cdsClients.FieldByName('Mar').AsString := '1';
  cdsClients.Post;}

  PrototypeBindSource1.Active := True;
  lvwRatings.EditMode := False;

end;

procedure TfrmMainForm.LinkFillControlToField1FilledListItem( Sender: TObject; const AEditor: IBindListEditorItem );
var
  Item: TListViewItem;
  RatingIcon: TListItemCodingIcon;
  TextLabel: TListItemText;
  RatingField, TextField: TField;
  Client : TStringList;
begin
  // Code to assign to the list item as it is being updated by LiveBindings
  if AEditor.CurrentIndex >= 0 then
  begin
    Item := lvwRatings.Items[ AEditor.CurrentIndex ];
    Client := TStringList.Create;
    try
      Client.CommaText := Clients.Strings[AEditor.CurrentIndex];

      TextLabel := Item.Objects.FindObject( sCode ) as TListItemText;
//      TextField := BindSourceDB1.DataSet.FindField( sCode );
      if ( TextLabel <> nil ) then
        TextLabel.Text := Client.Strings[0];

      TextLabel := Item.Objects.FindObject( sName ) as TListItemText;
      if ( TextLabel <> nil ) then
        TextLabel.Text := Client.Strings[1];

      RatingIcon := Item.Objects.FindObject( sJanuary ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType:= StrToIntDef(Client.Strings[2],1);

      RatingIcon := Item.Objects.FindObject( sFebruary ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[3],1);

      RatingIcon := Item.Objects.FindObject( sMarch ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[4],1);

      RatingIcon := Item.Objects.FindObject( sApril ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[5],1);

      RatingIcon := Item.Objects.FindObject( sMay ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[6],1);
      RatingIcon := Item.Objects.FindObject( sJune ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[7],1);
      RatingIcon := Item.Objects.FindObject( sJuly ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[8],1);
      RatingIcon := Item.Objects.FindObject( sAugust ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[9],1);
      RatingIcon := Item.Objects.FindObject( sSeptember ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[10],1);
      RatingIcon := Item.Objects.FindObject( sOctober ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[11],1);
      RatingIcon := Item.Objects.FindObject( sNovember ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[12],1);

      RatingIcon := Item.Objects.FindObject( sDecember ) as TListItemCodingIcon;
      if ( RatingIcon <> nil ) then
        RatingIcon.CodingType := StrToIntDef(Client.Strings[13],1);
    finally
      FreeAndNil(Client);
    end;
  end;
end;




procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  Clients := TStringList.Create;
  Clients.Add('1, sinu, 0,1,1,0,1,1,1,1,2,1,1,3');
  Clients.Add('2, vinu, 1,3,2,1,1,1,1,1,1,1,1,1');
  Clients.Add('3, tinu, 1,1,1,1,1,1,1,3,1,1,1,1');
  Clients.Add('4, renu, 1,1,1,1,1,2,1,1,1,1,1,1');
  Clients.Add('5, manu, 1,1,1,1,1,1,1,1,1,1,1,1');
  Clients.Add('6, venu, 1,1,1,2,1,1,1,1,1,1,1,1');
  Clients.Add('7, binu, 1,1,1,1,2,1,1,1,3,1,1,1');
  Clients.Add('8, minu, 1,1,2,1,1,2,1,1,1,1,1,1');
  Clients.Add('9, kinu,1,1,1,1,1,2,1,1,1,3,1,1');
  Clients.Add('10, linu, 1,1,2,1,1,1,1,2,1,1,2,1');
end;

procedure TfrmMainForm.FormResize(Sender: TObject);
(*
var
  Item: TListViewItem;
  RatingIcon: TListItemRatingIcon;
  PortraitMode: Boolean;
*)
begin
  (*
  PortraitMode := Width < Height;

  lvwRatings.BeginUpdate;
  try
    for Item in lvwRatings.Items do
    begin
      RatingIcon := Item.Objects.FindObject( sRatingPureeing ) as TListItemRatingIcon;
      if RatingIcon <> nil then
      begin
        RatingIcon.Visible := PortraitMode;
      end;
    end;
  finally
    lvwRatings.EndUpdate;
  end;
  *)
end;


end.
