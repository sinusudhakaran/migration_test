unit WPRepED;
{--------------------------------------------------------------}
{                                                              }
{ WW   WW   WW  PPPPPPP TTTT OOOO OOOO O    SSSS               }
{  WW  WW  WW   PP   PP  TT  O  O O  O O    SS                 }
{   WW WW WW    PPPPPP   TT  O  O O  O O      SS               }
{    WWWWWW     PP       TT  OOOO OOOO OOOO SSSS               }
{--------------------------------------------------------------}
{ CopyRight (C) 1996-2004 by WPCubed GmbH                      }
{--------------------------------------------------------------}


interface
{$I WPINC.INC}
{--$DEFINE DONTALLOW_FF_FORGROUP}//OFF: Support new page after group functionality

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WPRTEDefs, WPCTRMemo, WPRTEReport, ExtCtrls, Buttons,
  Menus, StdCtrls, ComCtrls, WPUtil, ImgList;

type
  TWPReportBandsDialog = class;
{$IFNDEF T2H}
  TWPReportBandsDialogForm = class(TWPShadedForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    labVisibility: TLabel;
    labDatabase: TLabel;
    labBandType: TLabel;
    labBandOptions: TLabel;
    Bevel1: TBevel;
    VisibleCombo: TComboBox;
    DatabaseCombo: TComboBox;
    BandTypeCombo: TComboBox;
    CheckStretchedData: TCheckBox;
    CheckBetweenData: TCheckBox;
    CheckOutsideData: TCheckBox;
    CheckStretchable: TCheckBox;
    CheckForceNewPage: TCheckBox;
    OnOffCheck: TCheckBox;
    ApplyFormulas: TSpeedButton;
    IgnoreChange: TSpeedButton;
    FinishCode: TEdit;
    labEndCode: TLabel;
    PrepareCode: TEdit;
    labPrepareCode: TLabel;
    StartCode: TEdit;
    labStartCode: TLabel;
    InsertPanel: TPanel;
    NewBand: TButton;
    NewGroup: TButton;
    DeleteBand: TButton;
    AddBandPoupup: TPopupMenu;
    HeaderBand1: TMenuItem;
    DataBand1: TMenuItem;
    FooterBand1: TMenuItem;
    GroupPopup: TPopupMenu;
    GrCreate_Outside: TMenuItem;
    GrCreate_Pos: TMenuItem;
    GrCreate_AtStart: TMenuItem;
    GrCreate_AtEnd: TMenuItem;
    FieldPopup: TPopupMenu;
    Fields1: TMenuItem;
    FieldPanel: TPanel;
    InsertField: TButton;
    PageNum: TMenuItem;
    InsNumberIcons: TImageList;
    P1: TMenuItem;
    P2: TMenuItem;
    P3: TMenuItem;
    P4: TMenuItem;
    P5: TMenuItem;
    P6: TMenuItem;
    P7: TMenuItem;
    ConvertTable1: TMenuItem;
    TabOptions: TTabSheet;
    OptionsStrings: TMemo;
    ApplyOptions: TSpeedButton;
    procedure DatabaseComboClick(Sender: TObject);
    procedure BandTypeComboClick(Sender: TObject);
    procedure VisibleComboClick(Sender: TObject);
    procedure ApplyFormulasClick(Sender: TObject);
    procedure FinishCodeChange(Sender: TObject);
    procedure IgnoreChangeClick(Sender: TObject);
    procedure CheckStretchableClick(Sender: TObject);
    procedure CheckStretchedDataClick(Sender: TObject);
    procedure CheckForceNewPageClick(Sender: TObject);
    procedure OnOffComboClick(Sender: TObject);
    procedure NewBandClick(Sender: TObject);
    procedure NewGroupClick(Sender: TObject);
    procedure DeleteBandClick(Sender: TObject);
    procedure FooterBand1Click(Sender: TObject);
    procedure GrCreate_PosClick(Sender: TObject);
    procedure InsertFieldClick(Sender: TObject);
    procedure Fields1Click(Sender: TObject);
    procedure PageNumClick(Sender: TObject);
    procedure ConvertTable1Click(Sender: TObject);
    procedure ApplyOptionsClick(Sender: TObject);
    procedure OptionsStringsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    WPSuperMerge: TWPSuperMerge;
    ParentDlg: TWPReportBandsDialog;
    FWhileUpdate: Boolean;
  public
    procedure UpdateFrom(SuperMerge: TWPSuperMerge);
    procedure SuperMergeUpdate;
    property  Dialog: TWPReportBandsDialog read ParentDlg;
  end;
{$ENDIF}

  TWPInsertFieldMenuPrepareEvent = procedure(Sender:
    TWPReportBandsDialog; InsertFieldMenu: TPopupMenu) of object;

  {:: The TWPReportBandsDialog can be used convert a regular text editor based
  on WPTools controls into a editor to edit a WPReporter template.
  It is only required that a TWPSuperMerge is attached to the editor.
  Please read more in the PDF manual, chapter "WPReporter Addon". }
  TWPReportBandsDialog = class(TWPCustomAttrDlg)
{$IFNDEF T2H}
  private
    FSuperMerge: TWPSuperMerge;
    FAutoActivate: Boolean;
    FStayOnTop: Boolean;
    FShowFormulas, FShowAddDeleteButton, FShowInsertField: Boolean;
    FWPReportBandsDialogForm: TWPReportBandsDialogForm;
    FOnPrepareInsertFieldMenu: TWPInsertFieldMenuPrepareEvent;
    FDataBases: TStringList;
    procedure UpdateFrom(Sender: TObject);
    procedure SetSuperMerge(x: TWPSuperMerge);
    function GetDatabases: TStrings;
    procedure SetDatabases(x: TStrings);
    procedure OnDataBasesChange(Sender: TObject);
    procedure SetShowFormulas(x: Boolean);
    procedure SetShowInsertField(x: Boolean);
    procedure SetAddDeleteButton(x: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
{$ENDIF}
  public
    destructor Destroy; override;
    constructor Create(aOwner: TComponent); override;
    function Execute: Boolean; override;
    procedure Close; override;
  published
    //:: required - must reference a WPSuperMerge component
    property SuperMerge: TWPSuperMerge read FSuperMerge write SetSuperMerge;
    //:: if true the dialog will pop up if the cursor is placed on a band
    property AutoActivate: Boolean read FAutoActivate write FAutoActivate;
    //:: if true the dialog will be not covered by the main form
    property StayOnTop: Boolean read FStayOnTop write FStayOnTop;
    //:: string list - will be used to fill the combobox with alias names which can be selected for a group band
    property DataBases: TStrings read GetDatabases write SetDatabases;
    //:: Experimental - if true a second page will be visible. This page makes it possible to add WPEvalEngine formulas to bands.
    property ShowFormulas: Boolean read FShowFormulas write SetShowFormulas;
    //:: If true a button with a drop down menu will be displaid to select fields from the list set up with <see class="TWPReporterFieldsCollection" method="AddFields">
    property ShowInsertField: Boolean read FShowInsertField write SetShowInsertField;
    //:: If true bzuttons to insert bands and groups will be displayed.
    property ShowAddDeleteButton: Boolean read FShowAddDeleteButton write SetAddDeleteButton;
    {:: This event is triggered after the items to create a page number
      have been added to the popup menu and before the fields are added from
      the attached SuperMerge component. You can use this event to add custom
      items to the drop down menu, for example to create calculated fields
      which show the sum in a table. (PAINTCALC fields) }
    property OnPrepareInsertFieldMenu: TWPInsertFieldMenuPrepareEvent
      read FOnPrepareInsertFieldMenu write FOnPrepareInsertFieldMenu;
  end;

var
  WPReportBandsDialogForm: TWPReportBandsDialogForm;

implementation

const
  NewPageMode = wppNewPageAfter;
//  NewPageMode = wppNewPageBefore;


{$R *.DFM}

destructor TWPReportBandsDialog.Destroy;
begin
  FDataBases.Free;
  if FWPReportBandsDialogForm <> nil then FWPReportBandsDialogForm.Free;
  if FSuperMerge <> nil then FSuperMerge._InternOnBandChange := nil;
  inherited Destroy;
end;

constructor TWPReportBandsDialog.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FAutoActivate := TRUE;
  FDataBases := TStringList.Create;
  FDataBases.OnChange := OnDataBasesChange;
  FDataBases.Add('MASTER');
  FDataBases.Add('CLIENT');
end;

procedure TWPReportBandsDialog.SetShowFormulas(x: Boolean);
begin
  FShowFormulas := x;
  if FWPReportBandsDialogForm <> nil then
  begin
    FWPReportBandsDialogForm.TabSheet1.TabVisible := x;
    FWPReportBandsDialogForm.TabSheet2.TabVisible := x;
    if not x then FWPReportBandsDialogForm.PageControl1.ActivePageIndex := 0;
  end;
end;

procedure TWPReportBandsDialog.SetAddDeleteButton(x: Boolean);
begin
  FShowAddDeleteButton := x;
  if FWPReportBandsDialogForm <> nil then
  begin
    FWPReportBandsDialogForm.InsertPanel.Visible := FShowAddDeleteButton;
  end;
end;

procedure TWPReportBandsDialog.SetShowInsertField(x: Boolean);
begin
  FShowInsertField := x;
  if FWPReportBandsDialogForm <> nil then
  begin
    FWPReportBandsDialogForm.FieldPanel.Visible := FShowInsertField;
    if FShowInsertField then
      FWPReportBandsDialogForm.FieldPanel.Top := 1000;
  end;
end;

procedure TWPReportBandsDialog.OnDataBasesChange(Sender: TObject);
begin
  if FWPReportBandsDialogForm <> nil then
    FWPReportBandsDialogForm.DatabaseCombo.Items.Assign(FDataBases);
end;

function TWPReportBandsDialog.GetDatabases: TStrings;
begin Result := FDataBases; end;

procedure TWPReportBandsDialog.SetDatabases(x: TStrings);
begin FDataBases.Assign(x); end;

procedure TWPReportBandsDialog.Close;
begin
  if FWPReportBandsDialogForm <> nil then
  begin
    FWPReportBandsDialogForm.Close;
    FWPReportBandsDialogForm.Free;
    FWPReportBandsDialogForm := nil;
  end;
end;

function TWPReportBandsDialog.Execute: Boolean;
begin
  Result := FALSE;
  if FCreateAndFreeDialog and (FWPReportBandsDialogForm <> nil) then
  begin FWPReportBandsDialogForm.Free; FWPReportBandsDialogForm := nil; end;

  if FWPReportBandsDialogForm = nil then
  begin
    FWPReportBandsDialogForm := TWPReportBandsDialogForm.Create(nil);
{$IFDEF WP6}
    FWPReportBandsDialogForm.TabOptions.TabVisible := true;
{$ELSE}
    FWPReportBandsDialogForm.TabOptions.TabVisible := false;
{$ENDIF}
    FWPReportBandsDialogForm.PageControl1.ActivePageIndex := 0;
    FWPReportBandsDialogForm.ParentDlg := Self;
    FWPReportBandsDialogForm.OnOffCheck.Visible := FALSE;
    FWPReportBandsDialogForm.DatabaseCombo.Items.Assign(FDataBases);
    if FStayOnTop then FWPReportBandsDialogForm.FormStyle := fsStayOnTop;
    SetShowFormulas(FShowFormulas);
    SetAddDeleteButton(FShowAddDeleteButton);
    SetShowInsertField(FShowInsertField);
    if (Application <> nil) and (Application.MainForm <> nil) then
    begin
      FWPReportBandsDialogForm.Left := Application.MainForm.Left;
      FWPReportBandsDialogForm.Top := Application.MainForm.Top + 32;
    end;
  end;
  if not FCreateAndFreeDialog then
  begin
    FWPReportBandsDialogForm.Show;
    FWPReportBandsDialogForm.UpdateFrom(SuperMerge);
    Result := FALSE;
  end else
  begin
    FWPReportBandsDialogForm.Free;
    FWPReportBandsDialogForm := nil;
  end;
end;

procedure TWPReportBandsDialog.UpdateFrom(Sender: TObject);
begin
  if (Sender <> nil) and (Sender is TWPSuperMerge) and (FWPReportBandsDialogForm = nil)
    and FAutoActivate and (TWPSuperMerge(Sender).Bands.CurrentBand <> nil)
    then Execute;
  if FWPReportBandsDialogForm <> nil then
    FWPReportBandsDialogForm.UpdateFrom(TWPSuperMerge(Sender));
end;

procedure TWPReportBandsDialog.SetSuperMerge(x: TWPSuperMerge);
begin
  FSuperMerge := x;
  if x <> nil then x.FreeNotification(Self);
  if FSuperMerge <> nil then FSuperMerge._InternOnBandChange := UpdateFrom;
  if FWPReportBandsDialogForm <> nil then
    FWPReportBandsDialogForm.UpdateFrom(nil);
end;

procedure TWPReportBandsDialog.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FSuperMerge <> nil) and (AComponent = FSuperMerge) then FSuperMerge := nil;
    if (FWPReportBandsDialogForm <> nil) and
      (AComponent = FWPReportBandsDialogForm.WPSuperMerge)
      then FWPReportBandsDialogForm.UpdateFrom(nil);
  end;
end;
{ -------------------------------------------------------------- }


procedure TWPReportBandsDialogForm.SuperMergeUpdate;
begin
  if WPSuperMerge <> nil then WPSuperMerge.Invalidate;
end;

procedure TWPReportBandsDialogForm.DatabaseComboClick(Sender: TObject);
var i: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  i := WPSuperMerge.Bands.CurrentBand;
  if i <> nil then
  begin
    if DatabaseCombo.ItemIndex >= 0 then
      i.Alias := DatabaseCombo.Items[DatabaseCombo.ItemIndex]
    else i.Alias := '';
  end; SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.BandTypeComboClick(Sender: TObject);
var i: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  i := WPSuperMerge.Bands.CurrentBand;
  if i <> nil then
  begin
    if WPSuperMerge.Bands.CurrentBandPar.ParagraphType in
      [wpIsReportHeaderBand, wpIsReportDataBand, wpIsReportFooterBand] then
      case BandTypeCombo.ItemIndex of
        0: begin
            i.Style := wpmHeader;
            WPSuperMerge.Bands.CurrentBandPar.ParagraphType := wpIsReportHeaderBand;
          end;
        1: begin i.Style := wpmData;
            WPSuperMerge.Bands.CurrentBandPar.ParagraphType := wpIsReportDataBand;
          end;
        2: begin i.Style := wpmFooter;
            WPSuperMerge.Bands.CurrentBandPar.ParagraphType := wpIsReportFooterBand;
          end;
      end;
    UpdateFrom(WPSuperMerge);
  end;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.VisibleComboClick(Sender: TObject);
var i: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  i := WPSuperMerge.Bands.CurrentBand;
  if i <> nil then
  begin
    i.ShowOnPage :=
      TWPMergeShowOptions(VisibleCombo.ItemIndex);
  end;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.OnOffComboClick(Sender: TObject);
var i: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  i := WPSuperMerge.Bands.CurrentBand;
  if i <> nil then
  begin
    if not OnOffCheck.Checked then
      i.ShowOnPage := wpmShowAll
    else i.ShowOnPage := wpmHide;
  end;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.ApplyFormulasClick(Sender: TObject);
var i: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  i := WPSuperMerge.Bands.CurrentBand;
  if i <> nil then
  begin
    i.StartCode := StartCode.Text;
    i.PrepareCode := PrepareCode.Text;
    i.FinishCode := FinishCode.Text;
    ApplyFormulas.Enabled := FALSE;
    IgnoreChange.Enabled := FALSE;
  end;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.UpdateFrom(SuperMerge: TWPSuperMerge);
var aBand: TWPBand;
  procedure ENABLESTATE(CTRL: TWINCONTROL; ENABLE: BOOLEAN);
  begin
    if ctrl is TComboBox then
    begin
      if enable then TComboBox(ctrl).Color := clWindow else
      begin
        TComboBox(ctrl).ItemIndex := -1;
        TComboBox(ctrl).Color := clBtnFace;
      end;
      TComboBox(ctrl).Enabled := enable;
    end else if ctrl is TEdit then
    begin
      if enable then TEdit(ctrl).Color := clWindow else
      begin
        TEdit(ctrl).Color := clBtnFace;
        TEdit(ctrl).Text := '';
      end;
      TEdit(ctrl).Enabled := enable;
    end;
  end;
begin
  FWhileUpdate := TRUE;
  try
    WPSuperMerge := SuperMerge;

    if (WPSuperMerge = nil) or
      (WPSuperMerge.Bands.CurrentBand = nil) then
    begin
      EnableState(VisibleCombo, FALSE);
      EnableState(DatabaseCombo, FALSE);
      EnableState(BandTypeCombo, FALSE);

      EnableState(StartCode, FALSE);
      EnableState(PrepareCode, FALSE);
      EnableState(FinishCode, FALSE);

      CheckStretchedData.Enabled := FALSE;
      CheckForceNewPage.Enabled := FALSE;
      CheckBetweenData.Enabled := FALSE;
      CheckOutsideData.Enabled := FALSE;
      CheckStretchable.Enabled := FALSE;
      ApplyFormulas.Enabled := FALSE;
      IgnoreChange.Enabled := FALSE;
{$IFDEF WP6}
      OptionsStrings.Lines.Clear;
      ApplyOptions.Enabled := FALSE;
{$ENDIF}
    end else
    begin
      aBand := WPSuperMerge.Bands.CurrentBand;
    { Select Type of Band --------- Group Start/End, Header, Data or Footer }
      EnableState(BandTypeCombo, TRUE);
      if aBand.Style = wpmHeader then BandTypeCombo.ItemIndex := 0
      else if aBand.Style = wpmFooter then BandTypeCombo.ItemIndex := 2
      else if aBand.Style = wpmData then BandTypeCombo.ItemIndex := 1
      else EnableState(BandTypeCombo, FALSE);

{$IFDEF WP6}
      OptionsStrings.Lines.Assign(aBand.BandOptions);
      ApplyOptions.Enabled := FALSE;
{$ENDIF}

      if aBand.Style = wpmGroup then
      begin
        BandTypeCombo.Enabled := FALSE;
        BandTypeCombo.ItemIndex := -1;
        EnableState(DatabaseCombo, TRUE);
        DatabaseCombo.ItemIndex := DatabaseCombo.Items.IndexOf(aBand.Alias);
      end else EnableState(DatabaseCombo, FALSE); { Only Groups may have database alias ! }
    { Select Options for Text }
      if aBand.Style <> wpmData then
      begin CheckStretchable.Checked := FALSE;
        CheckStretchable.Enabled := FALSE;
{$IFNDEF DONTALLOW_FF_FORGROUP}
        if aBand.Style = wpmGroup then
        begin
          CheckForceNewPage.Checked := (NewPageMode in aBand.Options);
          CheckForceNewPage.Enabled := TRUE;
        end else
{$ENDIF}
        begin
          CheckForceNewPage.Enabled := FALSE;
          CheckForceNewPage.Checked := FALSE;
        end;
      end else // Data Band
      begin
        CheckForceNewPage.Checked := (NewPageMode in aBand.Options);
        CheckForceNewPage.Enabled := TRUE;
      {  if WPSuperMerge.Bands.CurrentBandPar.ParentPar<>nil then
        begin
          CheckStretchable.Checked := (wppStretchable in aBand.Options);
          CheckStretchable.Enabled := TRUE;
        end else  }
        begin
          CheckStretchable.Checked := TRUE;
          CheckStretchable.Enabled := FALSE;
        end;
      end;
    { Select Options for Header/Footer/Data }
      if (aBand.Style in [wpmHeader, wpmFooter])
        and (WPSuperMerge.Bands.CurrentBandPar.ParentPar <> nil) then
      begin
        CheckOutsideData.Enabled := TRUE;
        CheckBetweenData.Enabled := TRUE;
     // CheckStretchedData.Enabled := TRUE;
        CheckStretchedData.Enabled := TRUE; //V5.13

        CheckOutsideData.Checked := wpmOutsideData in aBand.Cond;
        CheckBetweenData.Checked := wpmBetweenData in aBand.Cond;
        CheckStretchedData.Checked := wpmStretchedData in aBand.Cond;
     // CheckStretchedData.Checked := false; // wpmStretchedData in aBand.Cond;
        EnableState(PrepareCode, FALSE);
      end else
      begin
        CheckOutsideData.Checked := FALSE;
        CheckOutsideData.Enabled := FALSE;
        CheckStretchedData.Checked := FALSE;
        CheckStretchedData.Enabled := FALSE;
        CheckBetweenData.Checked := FALSE;
        CheckBetweenData.Enabled := FALSE;
        EnableState(PrepareCode, TRUE);
      end;
    { Select Visibility }
      if (aBand.Style in [wpmGroup, wpmData]) or
        (WPSuperMerge.Bands.CurrentBandPar.ParentPar <> nil) then
      begin
        OnOffCheck.Visible := TRUE;
        VisibleCombo.Visible := FALSE;
        OnOffCheck.Checked := aBand.ShowOnPage = wpmHide;
      end else
      begin
        OnOffCheck.Visible := FALSE;
        VisibleCombo.Visible := TRUE;
        EnableState(VisibleCombo, TRUE);
        VisibleCombo.ItemIndex := Integer(aBand.ShowOnPage);
      end;

    { Code - Prepare is only Usuable for Groups! }
      EnableState(StartCode, TRUE);
      EnableState(FinishCode, TRUE);

      StartCode.Text := aBand.StartCode;
      PrepareCode.Text := aBand.PrepareCode;
      FinishCode.Text := aBand.FinishCode;

      ApplyFormulas.Enabled := FALSE;
      IgnoreChange.Enabled := FALSE;
    end;
  finally
    FWhileUpdate := FALSE;
  end;
end;

procedure TWPReportBandsDialogForm.FinishCodeChange(Sender: TObject);
begin
  ApplyFormulas.Enabled := TRUE;
  IgnoreChange.Enabled := TRUE;
end;

procedure TWPReportBandsDialogForm.IgnoreChangeClick(Sender: TObject);
var aBand: TWPBand;
begin
  if WPSuperMerge = nil then exit;
  aBand := WPSuperMerge.Bands.CurrentBand;
  if aBand <> nil then
  begin
    StartCode.Text := aBand.StartCode;
    PrepareCode.Text := aBand.PrepareCode;
    FinishCode.Text := aBand.FinishCode;
  end else
  begin
    StartCode.Text := '';
    PrepareCode.Text := '';
    FinishCode.Text := '';
  end;
  ApplyFormulas.Enabled := FALSE;
  IgnoreChange.Enabled := FALSE;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.CheckStretchableClick(Sender: TObject);
var aBand: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  aBand := WPSuperMerge.Bands.CurrentBand;
  if aBand <> nil then
  begin
    if CheckStretchable.Checked then
      aBand.Options :=
        aBand.Options + [wppStretchable]
    else aBand.Options :=
      aBand.Options - [wppStretchable];
  end;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.CheckForceNewPageClick(Sender: TObject);
var aBand: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  aBand := WPSuperMerge.Bands.CurrentBand;
  if aBand <> nil then
  begin
    if CheckForceNewPage.Checked then
      aBand.Options :=
        aBand.Options + [NewPageMode]
    else aBand.Options :=
      aBand.Options - [NewPageMode];
  end;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.CheckStretchedDataClick(
  Sender: TObject);
var aBand: TWPBand;
const
  cond: array[0..2] of TWPMergeConditions =
  ([wpmOutsideData], [wpmBetweenData], [wpmStretchedData]);
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  aBand := WPSuperMerge.Bands.CurrentBand;
  if aBand <> nil then
  begin
    if TCheckbox(Sender).Checked then
      aBand.Cond :=
        aBand.Cond + cond[TCheckbox(Sender).TAG]
    else aBand.Cond :=
      aBand.Cond - cond[TCheckbox(Sender).TAG];
  end;
  SuperMergeUpdate;
end;

// Add Band

procedure TWPReportBandsDialogForm.NewBandClick(Sender: TObject);
var p: TPoint;
begin
  p := NewBand.ClientToScreen(Point(0, NewBand.Height));
  AddBandPoupup.Popup(p.x, p.y);
end;

procedure TWPReportBandsDialogForm.FooterBand1Click(Sender: TObject);
begin
  if WPSuperMerge <> nil then
    WPSuperMerge.AddBand(TWPMrgStyle((Sender as TMenuItem).Tag));
  SuperMergeUpdate;
end;

// Add Group

procedure TWPReportBandsDialogForm.NewGroupClick(Sender: TObject);
var
  p: TPoint;
  i: Integer;
begin
  p := NewGroup.ClientToScreen(Point(0, NewGroup.Height));
  ConvertTable1.Enabled :=
    (ParentDlg.EditBox <> nil) and (ParentDlg.EditBox.Table <> nil);
  GroupPopup.Popup(p.x, p.y);

  for i := 0 to GroupPopup.Items.Count - 1 do
    GroupPopup.Items[i].Enabled :=
      WPSuperMerge.AddGroupTest(TWPMrgGroupCreate(GroupPopup.Items[i].Tag));
end;


procedure TWPReportBandsDialogForm.ConvertTable1Click(Sender: TObject);
begin
  if (ParentDlg.EditBox <> nil) and (ParentDlg.EditBox.Table <> nil) then
  begin
    WPSuperMerge.ConvertTableIntoGroup(ParentDlg.EditBox.Table);
    ParentDlg.EditBox.DelayedReformat;
  end;
end;

procedure TWPReportBandsDialogForm.GrCreate_PosClick(Sender: TObject);
begin
  if WPSuperMerge <> nil then
    WPSuperMerge.AddGroup(TWPMrgGroupCreate((Sender as TMenuItem).Tag));
  SuperMergeUpdate;
end;

// Delete Band

procedure TWPReportBandsDialogForm.DeleteBandClick(Sender: TObject);
begin
  if WPSuperMerge <> nil then
  begin
    WPSuperMerge.DeleteActive;
    SuperMergeUpdate;
  end;
end;


procedure TWPReportBandsDialogForm.InsertFieldClick(Sender: TObject);
var
  p: TPoint;
begin
  p := InsertField.ClientToScreen(Point(0, InsertField.Height));
  while FieldPopup.Items.Count > 1 do
    FieldPopup.Items.Delete(1);

  if assigned(ParentDlg.OnPrepareInsertFieldMenu) then
    ParentDlg.FOnPrepareInsertFieldMenu(ParentDlg, FieldPopup);

  if WPSuperMerge <> nil then
    WPSuperMerge.Fields.AppendToMenu(FieldPopup, Fields1Click);
  FieldPopup.Popup(p.x, p.y);
end;

procedure TWPReportBandsDialogForm.Fields1Click(Sender: TObject);
var s: string; i: Integer;
begin
  if (Sender is TMenuItem) and (ParentDlg.EditBox <> nil) then
  begin
    s := WPSuperMerge.Fields.GetFieldName(TMenuItem(Sender).Tag);
    if s <> '' then
    begin
      i := Pos('=', s);
      if i > 0 then
        ParentDlg.EditBox.InputMergeField(Copy(s, 1, i - 1), Copy(s, i + 1, Length(s)))
      else ParentDlg.EditBox.InputMergeField(s, s);
      ParentDlg.EditBox.SetFocus;
    end;
  end;
end;

procedure TWPReportBandsDialogForm.PageNumClick(Sender: TObject);
begin
  if (Sender is TMenuItem) and (ParentDlg.EditBox <> nil) then
  begin
    ParentDlg.EditBox.InputTextField(TWPTextFieldType(TMenuItem(Sender).Tag), '');
    ParentDlg.EditBox.SetFocus;
  end;
end;  

procedure TWPReportBandsDialogForm.ApplyOptionsClick(Sender: TObject);
var i: TWPBand;
begin
  if (WPSuperMerge = nil) or FWhileUpdate then exit;
  i := WPSuperMerge.Bands.CurrentBand;
  if i <> nil then
  begin
  {$IFDEF WP6}
    i.BandOptions := OptionsStrings.Lines;
  {$ENDIF}
    ApplyOptions.Enabled := FALSE;
  end;
  SuperMergeUpdate;
end;

procedure TWPReportBandsDialogForm.OptionsStringsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  ApplyOptions.Enabled := TRUE;
end;

end.

