unit ListEntriesAdvancedDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CodeDateAccountDlg, ExtCtrls, StdCtrls, AccountSelectorFme,
  DateSelectorFme, ComCtrls, RzPanel, RptParams, Buttons, clObj32, OmniXML;

type
  TListEntriesParam = class (TRPTParameters)
  protected
    procedure LoadFromClient (Value : TClientObj); override;
    procedure SaveToClient   (Value : TClientObj); override;
    procedure ReadFromNode (Value : IXMLNode); override;
    procedure SaveToNode   (Value : IXMLNode); override;
  public
    JournalOnly : boolean;
    SortBy      : byte;
    Include     : byte;
    TwoColumn   : boolean;
    ShowBalance : boolean;
    ShowNotes   : boolean;
    WrapNarration: Boolean;
    ShowOP      : boolean;
  end;

  TdlgListEntriesAdvanced = class(TdlgCodeDateAccount)
    radButton1: TRadioButton;
    radButton2: TRadioButton;
    Label6: TLabel;
    Label7: TLabel;
    Label5: TLabel;
    cmbSortBy: TComboBox;
    chkShowNotes: TCheckBox;
    rbSingleCol: TRadioButton;
    rbTwoCol: TRadioButton;
    cmbInclude: TComboBox;
    chkShowBalance: TCheckBox;
    Bevel1: TBevel;
    Label4: TLabel;
    pnlNZOnly: TPanel;
    rbShowNarration: TRadioButton;
    rbShowOtherParty: TRadioButton;
    chkWrap: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure cmbIncludeChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



function EnterLEPrintDateRange( dlgCaption : string; dlgText :string;
                                var DateFrom,DateTo : integer;
                                HelpCtx: integer;
                                Blank : Boolean;
                                Params : TListEntriesParam): boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  bkXPThemes,
  globals,
  yesnodlg,
  stdaTest,
  ReportDefs,
  InfoMoreFrm,
  MainFrm,
  selectDate,
  imagesfrm,
  baObj32,
  WarningMoreFrm,
  ovcDate,
  bkConst,
  StdHints,
  UBatchBase;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgListEntriesAdvanced.FormCreate(Sender: TObject);
begin
  inherited;
  bkXPThemes.ThemeForm( Self);
  SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TdlgListEntriesAdvanced.SetUpHelp;
begin
   //other components hints will be set in the ancestor form
   cmbSortBy.Hint   :=
                    'Select the order to sort the Entries by|' +
                    'Sort entires by Effective Date or Date of Presentation';
   cmbInclude.Hint  :=
                    'Select which transactions to include|' +
                    'Include all or uncoded or invalidly coded transactions or transactions with invalid GST Rate';
   btnOK.Hint       :=
                    STDHINTS.PrintHint;
   btnFile.Hint       := STDHINTS.PrintToFileHint;
   btnOK.Hint         := STDHINTS.PrintHint;
end;
//------------------------------------------------------------------------------
function EnterLEPrintDateRange( dlgCaption : string; dlgText :string;
                                var DateFrom,DateTo : integer;
                                HelpCtx: integer;
                                Blank : Boolean;
                                Params : TListEntriesParam): boolean;
var
  MyDlg : TdlgListEntriesAdvanced;
  i: Integer;
  p : Pointer;
  lFilter: set of byte;
begin
  Result := false;
  Params.RunBtn := BTN_NONE;

  MyDlg := TdlgListEntriesAdvanced.Create(Application.MainForm); {create a coding date dialog and get values}
  try
    with MyDlg do begin
      BKHelpSetUp(MyDlg, HelpCtx);
      caption            := dlgCaption;
      Label1.caption     := dlgText;
      AllowBlank         := Blank;
      btnpreview.Visible := true;
      btnPreview.default := true;
      btnFile.visible    := true;
      btnOK.default      := false;
      btnOK.Caption      := '&Print';
      eDateSelector.NextControl := cmbSortBy;
      RptParams := Params;

      //load lists
      lFilter := rptParams.AccountFilter;
      if lFilter = [] then
         LFilter :=  [btBank .. btYearEndAdjustments]; // ?? is that correct ??

      fmeAccountSelector1.LoadAccounts( MyClient,lFilter );
      fmeAccountSelector1.btnSelectAllAccounts.Click;

    end;


    //load combo box for sort by order
    //Set the 'Input' values
    with MyDlg do begin
      cmbSortBy.Clear;
      cmbSortBy.Items.Add(csNames[csDateEffective]);
      cmbSortBy.Items.Add(csNames[csDatePresented]);
      if Params.SortBy = csDatePresented then
        cmbSortBy.ItemIndex := 1
      else
        cmbSortBy.ItemIndex := 0;

      cmbInclude.Clear;
      cmbInclude.Items.Add( esNames[esAllEntries ]);
      cmbInclude.Items.Add( esNames[esUncodedOnly ]);
      cmbInclude.ItemIndex := Params.Include;

      pnlNZOnly.Visible := params.Client.clFields.clCountry = whNewZealand;
      rbSingleCol.Checked := True;

      chkShowBalance.Checked := Params.ShowBalance;
      chkWrap.Checked := Params.WrapNarration;

      if not pnlNZOnly.Visible then
        Top := Top - pnlNZOnly.Height;

      rbShowOtherParty.checked := Params.ShowOP;
      chkShowNotes.Checked     := Params.ShowNotes;
      rbTwoCol.Checked         := Params.TwoColumn;
      rbSingleCol.Checked      := not rbTwoCol.Checked;

      cmbIncludeChange(nil); // Updates chkShowBalance.Enabled
      if chkShowBalance.Enabled then
         chkShowBalance.Checked := Params.ShowBalance;


      for I := 0 to fmeAccountSelector1.AccountCheckBox.Count - 1 do
         fmeAccountSelector1.AccountCheckBox.Checked[I] := (
            Params.AccountList.IndexOf(fmeAccountSelector1.AccountCheckBox.Items.Objects[i])>=0);

      dlgDateFrom := DateFrom;
      dlgDateTo := DateTo;


      //*******************
      if Execute then
      //******************
      begin
        {store updates in globals}
        DateFrom := dlgDateFrom;
        DateTo   := dlgDateTo;

        if not AllowBlank then
        begin
          gCodingDateFrom := DateFrom;
          gCodingDateTo   := DateTo;

          MyClient.clFields.clPeriod_Start_Date := gCodingDateFrom;
          Myclient.clFields.clPeriod_End_Date   := gCodingDateTo;
        end;
        Params.RunBtn := MyDlg.Pressed;

        case cmbSortBy.ItemIndex of
          1: Params.SortBy := csDatePresented;
        else
          Params.SortBy := csDateEffective;
        end;

        Params.Include        := cmbInclude.ItemIndex;
        Params.ShowOP         := rbShowOtherParty.checked;
        Params.ShowNotes      := chkShowNotes.Checked;
        Params.TwoColumn      := rbTwoCol.Checked;
        Params.ShowBalance    := chkShowBalance.Checked and chkShowBalance.Enabled;
        Params.WrapNarration  := chkWrap.Checked;

        params.AccountList.Clear;
        //add selected bank accounts to a tlist for used by report
        with MyDlg do
          for i := 0 to fmeAccountSelector1.AccountCheckBox.Count-1 do
            if fmeAccountSelector1.AccountCheckBox.Checked[i] then
            begin
              p := fmeAccountSelector1.AccountCheckBox.Items.Objects[i];
              params.AccountList.Add(p)
            end; 

        if Params.RunBtn = BTN_Save then begin
           Result := Params.BatchRunMode <> R_batch;
        end else
           Result := true;
      end;
    end;
  finally // wrap up
    MyDlg.Free;
  end;    // try/finally
end;
//------------------------------------------------------------------------------
procedure TdlgListEntriesAdvanced.cmbIncludeChange(Sender: TObject);
begin
  chkShowBalance.enabled := cmbInclude.ItemIndex = 0;
end;


{ TListEntriesParam }

procedure TListEntriesParam.LoadFromClient(Value: TClientObj);
begin
  inherited;
  with Value.clExtra do begin
    SortBy        := ceList_Entries_Sort_Order;
    Include       := ceList_Entries_Include;
    TwoColumn     := ceList_Entries_Two_Column;
    ShowBalance   := ceList_Entries_Show_Balance;
    ShowNotes     := ceList_Entries_Show_Notes;
    WrapNarration := ceList_Entries_Wrap_Narration;
    ShowOp        := ceList_Entries_Show_Other_Party;
  end;
end;

procedure TListEntriesParam.ReadFromNode(Value: IXMLNode);
begin
    if SameText( csNames[csDateEffective],GetBatchText('Sort',csNames[csDateEffective]))then
       SortBy := csDateEffective
    else  // Only Two options...
       SortBy := csDatePresented;

    if SameText( esNames[esAllEntries],GetBatchText('Include',esNames[esAllEntries]))then
       Include := esAllEntries
    else  // Only Two options...
       Include := esUncodedOnly;

    ShowOp        := GetBatchBool('Show_Other_Party',ShowOp);
    ShowNotes     := GetBatchBool('Show_Notes',ShowNotes);
    TwoColumn     := GetBatchBool('Show_Two_Columns',TwoColumn);
    ShowBalance   := GetBatchBool('Show_Balance',ShowBalance);
    WrapNarration := GetBatchBool('Wrap_Naration',WrapNarration);
    GetBatchAccounts;
end;

procedure TListEntriesParam.SaveToClient(Value: TClientObj);
begin
  with Value.clExtra do begin
    ceList_Entries_Sort_Order       := SortBy;
    ceList_Entries_Include          := Include;
    ceList_Entries_Two_Column       := TwoColumn;
    ceList_Entries_Show_Balance     := ShowBalance;
    ceList_Entries_Show_Notes       := ShowNotes;
    ceList_Entries_Wrap_Narration   := WrapNarration;
    ceList_Entries_Show_Other_Party := ShowOp;
  end;
end;

procedure TListEntriesParam.SaveToNode(Value: IXMLNode);
begin
   inherited;
   setBatchText('Sort',csNames[SortBy]);
   SetBatchText('Include',esNames[Include]);
   SetBatchBool('Show_Other_Party',ShowOp);
   SetBatchBool('Show_Notes',ShowNotes);
   SetBatchBool('Show_Two_Columns',TwoColumn);
   SetBatchBool('Show_Balance',ShowBalance);
   SetBatchBool('Wrap_Naration',WrapNarration);
   SaveBatchAccounts;
end;


end.
