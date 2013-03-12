unit dlgReportOptions;

interface

uses
  Virtualtreehandler,
  ReportTypes,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcnf, ExtCtrls, ComCtrls, Buttons,
  ImgList, ActnList, RzGroupBar, RzPanel, RzCmboBx, Mask, RzEdit,
  RzButton, ExtDlgs,
  OsFont, WPRTEDefs, WPCTRMemo, WPCTRRich, WPTbar, WPPanel, wpDefActions, Menus,
  WPRTEPaint, WPCTRLabel, WPRuler, StdActns, ExtActns, WPAction, RTFEditFme;





type
  TReportOptionDlg = class(TForm)
    pBtn: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    btnPreview: TButton;
    OpenPictureDlg: TOpenPictureDialog;
    pFooter: TPanel;
    lh2: TLabel;
    Bevel1: TBevel;
    cbRptClientCode: TCheckBox;
    cbRptPageNo: TCheckBox;
    cbRptPrinted: TCheckBox;
    cbRptTime: TCheckBox;
    cbRptUser: TCheckBox;
    PReport: TPanel;
    lStyle: TLabel;
    tcReportType: TTabControl;
    CBRounded: TCheckBox;
    cbAccountPage: TCheckBox;
    cbStyles: TComboBox;
    TopToolbar: TRzToolbar;
    BtnCopy: TRzToolButton;
    BtnPaste: TRzToolButton;
    PHeaderFooter: TPanel;
    btnStyle: TButton;
    TcSection: TTabControl;
    Editor: TfmeEditRTF;
    pHFTop: TPanel;
    Bevel2: TBevel;
    lh1: TLabel;
    ChkHFEnabled: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure tcReportTypeChange(Sender: TObject);
    procedure BtnPasteClick(Sender: TObject);
    procedure BtnCopyClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnStyleClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure TcSectionChange(Sender: TObject);
  private

    FReportType: TReportType;
    HFClipBoard: TReportTypeParams;
    RptHeaderFooters : array [TReportType] of TReportTypeParams;
    FInSetup: Boolean;
    FHFSection: Integer;
    FCountry: Byte;
    procedure GetHeaderFooter(var Value: TReportTypeParams);
    procedure SetHeaderFooter(const Value: TReportTypeParams);
    procedure SetReportType(const Value: TReportType);
    procedure SetHFSection(const Value: Integer);
    function GetHFSection: THFSection;
    property ReportType: TReportType read FReportType write SetReportType;
    function CurHeaderFooter: TReportTypeParams;
    //procedure LoadLogoFromFile(Filename: string; Logo: TImage; Lable: TLabel);
    //procedure SetLogoAlignment(Logo: TImage; Alignment: TAlignment; Shape: TShape);
    procedure SaveSection(Value: THFSection);
    procedure Loadsection(Value: THFSection);
    { Private declarations }
  public
    property HFSection: integer read FHFSection write SetHFSection;
    { Public declarations }
  end;

procedure ReportOptions;

implementation

{$R *.dfm}

uses
  CountryUtils,
  bkConst,
  MoneyUtils,
  GlobalMergeFields,
  Globals,
  clObj32,
  lockUtils,
  stDate,
  dlgReportStyles,
  bkdateutils,
  repcols,
  ReportStyleDlg,
  ImagesFrm,
  ErrorMoreFrm,
  InfoMoreFrm,
  ReportDefs,
  WarningMoreFrm,
  PrintMgrObj,
  ReportImages,
  NewReportObj,
  NewReportUtils,
  Genutils,
  YesNoDlg,
  omniXML,
  BkHelp,
  OmniXMLutils,
  WINUTILS, bkXPThemes;

procedure ReportOptions;
begin
   with TReportOptionDlg.Create(Application.MainForm) do try
      showModal;
   finally
      Free;
   end;
end;



{ TReportOptionDlg }



procedure TReportOptionDlg.BtnCopyClick(Sender: TObject);
begin
  if not Assigned(HFClipBoard) then begin
      HFClipBoard := TReportTypeParams.Create;
      btnPaste.Enabled := True;
   end;
   GetHeaderFooter(RptHeaderFooters[FReportType]);
   HFClipBoard.Assign(CurHeaderFooter);
end;



procedure TReportOptionDlg.btnOkClick(Sender: TObject);

  procedure SaveReportTypes;
  var Document: IXMLDocument;
      bn: IXMLNode;
      I: Integer;
  begin
      Document := CreateXMLDoc;
      try
         Document.Text := '';
         bn := EnsureNode(Document, 'ReportTypes');
         SetNodeText(bn,'Version','2');
         for I := ord(Low(TReportType)) to ord(High(TReportType)) do
            RPTHeaderFooters[TReportType(I)].SavetoNode(EnsureNode(bn,ReportTypenames[TReportType(I)]));

         Document.Save(ReportTypesFilename,ofIndent);
      finally
        Document := nil;
      end;
  end;


begin
   // Save...
   GetHeaderFooter(RptHeaderFooters[FReportType]);
   if FileLocking.ObtainLock(ltPracHeaderFooterImg, TimeToWaitForPracLogo) then
   begin
     try
       SaveReportTypes;

     finally
       FileLocking.ReleaseLock(ltPracHeaderFooterImg);
     end;
   end;
   ModalResult := mroK;
end;

procedure TReportOptionDlg.BtnPasteClick(Sender: TObject);
begin
  if Assigned(HFClipBoard) then begin
     CurHeaderFooter.assign(HFClipBoard); //Merge Paste..
     if FReportType =  rptFinancial then // Keep this one case 8291
         CurHeaderFooter.RoundValues := cbRounded.Checked;
     SetHeaderFooter(CurHeaderFooter); // Show the new one
  end;
end;

//******************************************************************************
// Global Printer
//******************************************************************************

var
  prNewPageDone: boolean;

procedure ReportNewPage(sender: TObject);
begin
   prNewPageDone := True;
end;

procedure ReportDetail(Sender:TObject);
   const
      MaxSectionCount = 10; // To file, may never get a NewPage.
      ItemCount = 15;
   var
      I,G: Integer;
      D: Integer;
   begin
      // ReportNewPage gets called first..
      // So need to Turn it off to make is usefull
      prNewPageDone := False;

      // Make sur the dates stay relevant...
      D := CurrentDate - 60;

      with TBKReport(Sender) do begin
         // we need a couple of these for the style..
         RenderTextLine ('Report Text line 1');
         RenderTextLine ('Report Text line 2');

         for G := 1 to MaxSectionCount do begin
            RenderTitleLine('Section Title' + intToStr(G));

            for I := 1 to (ItemCount + g) do begin
               // Just make up some stuff..
               PutString( '123456' );
               PutString( 'Description ' + intToStr(G) + '.' + intToStr(I) );

               PutString( bkDate2Str(D + G - I ));
               PutString( bkDate2Str(D + I ));

               PutCurrency( G * I );
               if odd(I) then
                  PutMoney( D + I)
               else
                  PutMoney(- D + I -G);
               RenderDetailLine;
            end;
            RenderDetailSubTotal('Sub Total'+ intToStr(G));

            if prNewPageDone then
               Break; // Have atleast a second page

         end;
         RenderDetailGrandTotal('Grand Total');
      end;
   end;


procedure TReportOptionDlg.btnPreviewClick(Sender: TObject);
var
   Job: TBKReport;
   cLeft: Double;
   KeepClient,
   TempClient: TClientObj;
begin
  // pick up any changes
  GetHeaderFooter(RptHeaderFooters[FReportType]);

  //set up a preview report

  Job := TBKReport.Create(FReportType); // Reads the file version
  TempClient := TClientObj.Create;

  KeepClient := MyClient;
  try
  Job.ReportTypeParams := (RptHeaderFooters[FReportType]);// Not saved yet...
  Job.ReportStyle.Name := CurHeaderFooter.HF_Style;
  Job.ReportStyle.load;

  CreateReportImageList;
  AddReportTypeToList(FReportType,RptHeaderFooters[FReportType]); // imagelist

     // looking at the report types...
    // if cbStyles.ItemIndex >= 0 then
     //    Job.ReportStyle.Assign(TStyleTreeItem(cbStyles.Items.Objects[cbStyles.ItemIndex]).style);

  case fReportType of
     rptFinancial : Job.ReportTitle := 'Cash Flow, P & L and Balance Sheet Reports Preview';
     rptCoding    : Job.ReportTitle := 'Coding Report Preview';
     rptLedger    : Job.ReportTitle := 'Ledger Report Preview';
     rptGst       : Job.ReportTitle := Localise(FCountry,'GST Report Preview');
     rptListings  : Job.ReportTitle := 'Listings Report Preview';
     else           Job.ReportTitle := 'General Report Preview';
  end;
  Job.LoadReportSettings(UserPrintSettings,Job.ReportTitle );


  TempClient.clFields.clCode := 'Cl_Code';
  TempClient.clFields.clName := 'Client Name';
  TempClient.clFields.clCountry := FCountry;

  MyClient := TempClient;

  AddCommonHeader(Job);

  AddJobHeader(Job,siTitle,Job.ReportTitle,true);
  AddJobHeader(Job,siSubTitle,'Preview for style: ' + Job.ReportStyle.Name  ,true);
  AddJobHeader(Job,siSubTitle,'',true);



  cLeft := GcLeft;
  AddColAuto(Job,cLeft,17 ,gcgap,'Account Number',jtLeft);
  AddColAuto(Job,cLeft,25,gcgap,'Account Name',jtLeft);
  AddColAuto(Job,cLeft,10,gcgap,'Entries From',jtLeft);
  AddColAuto(Job,cLeft,10,gcgap,'Entries To', jtLeft);
  AddFormatColAuto(Job,cLeft,10,gcgap,'No. Entries',jtRight,'#,##0','#,##0',true);
  AddFormatColAuto(Job,cLeft,17,gcgap,'Current Balance',jtRight,'#,##0.00" OD";#,##0.00" IF";#,##0.00 IF',
                    MoneyUtils.FmtBalanceStr(  whCurrencyCodes[FCountry] ),true);

  AddJobFooter(Job,siFootnote,'Preview footnote',true);

  AddCommonFooter(Job);
  Job.OnBKPrint := ReportDetail;
  Job.OnAfterNewPage := ReportNewPage;

  // Now print the report...
  Job.Generate(rdScreen);


  finally
    Job.Free;
    TempClient.Free;
    DestroyReportImageList;
    MyClient := KeepClient;
  end;
end;

procedure TReportOptionDlg.btnStyleClick(Sender: TObject);
begin
   if cbStyles.ItemIndex > 0 then
      CurHeaderFooter.HF_Style := cbStyles.Text // Save any changes.
   else
      CurHeaderFooter.HF_Style := '';

   if EditStyles(cbStyles.Text) = mrOk then begin
      // List may have changed..
      FillStyleList(cbStyles.Items);
      cbStyles.Items.Add(' ' + NoStyle);
      if CurHeaderFooter.HF_Style > '' then
         cbStyles.ItemIndex := cbStyles.Items.IndexOf(CurHeaderFooter.HF_Style)
      else
         cbStyles.ItemIndex := 0;
   end;
end;








function TReportOptionDlg.CurHeaderFooter: TReportTypeParams;
begin
   Result := RptHeaderFooters[FReportType];
end;




procedure TReportOptionDlg.FormCreate(Sender: TObject);

   procedure GetStyles;
   var I: integer;
   begin
      for I := ord(low(TReportType)) to ord(High(TReportType)) do
         RPTHeaderFooters[TReportType(I)] := TReportTypeParams.Read(TReportType(I));

   end;
var kc: TCursor;
const TaxTab = 3;
begin
   kc := Screen.Cursor;
   Screen.Cursor := crHourGlass;
   try
      HFClipBoard := nil;
      bkXPThemes.ThemeForm(Self);
      Editor.FullPageMode := False;
      Editor.EditMode := True;
      Editor.LoadGlobalMergeMenues;
      Editor.AddMergeMenuItem('Page Num' ,Integer(Document_Page));

      if Assigned(Adminsystem) then //Practice
         FCountry := Adminsystem.fdFields.fdCountry
      else if assigned(MyClient) then //Books must have a client open to get here...
         FCountry := MyClient.clFields.clCountry;

      tcReportType.Tabs[TaxTab] := whTaxSystemNamesUC[fCountry];

      lh1.Font.name := Font.name;
      lh2.Font.name := Font.Name;

      if FileLocking.ObtainLock(ltPracHeaderFooterImg, TimeToWaitForPracLogo) then
      begin
        try
          GetStyles;
          FillStyleList(cbStyles.Items);
          cbStyles.Items.Add(' '+ NoStyle);
        finally
          FileLocking.ReleaseLock(ltPracHeaderFooterImg);
        end;
      end;
      BKHelpSetUp(Self, BKH_Report_and_Graph_Options);

      // Set the defaults So they don't Change when set the first time
      FHFSection := Integer(hf_HeaderAll);
      FReportType := rptFinancial; // Would default to that anyway.
      // Now load the details
      ReportType := rptFinancial;
   finally
      Screen.Cursor := kc;
   end;
end;

procedure TReportOptionDlg.FormDestroy(Sender: TObject);
var I: integer;
begin
   INI_CustomColors := AppImages.GlCustomColors.Colors.CommaText;
   
   if Assigned(HFClipBoard) then begin
      FreeAndNil(HFClipBoard);
   end;

   for I := ord(low(TReportType)) to ord(High(TReportType)) do
      RptHeaderFooters[TReportType(I)].Free;
end;

procedure TReportOptionDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
   case Key of
   #27 : begin
         Key := #0;
         ModalResult := mrCancel;
      end;
   end;
end;



procedure TReportOptionDlg.GetHeaderFooter(var Value: TReportTypeParams);
begin
   // Read the TReportTypeParams from the Dialog..
   Value.HF_Enabled := chkHFEnabled.Checked;

   Value.FooterItems := [];
   if cbRptClientCode.Checked then
      Value.FooterItems := Value.FooterItems + [fiClientCode];
   if cbRptPageNo.Checked then
      Value.FooterItems := Value.FooterItems + [fiPageNumbers];
   if cbRptPrinted.Checked then
      Value.FooterItems := Value.FooterItems + [fiPrinted];
   if cbRptTime.Checked then
      Value.FooterItems := Value.FooterItems + [fiTime];
   if cbRptUser.Checked then
      Value.FooterItems := Value.FooterItems + [fiUser];

   Value.RoundValues := cbRounded.Checked;
   Value.NewPageforAccounts := cbAccountPage.Checked;

   if cbStyles.ItemIndex > 0 then
      Value.HF_Style := cbStyles.Text // Save any changes.
   else
      Value.HF_Style := '';

   // While we are here..
    SaveSection(GetHFSection);
   //

   //Header Logo
   //Filename and Alignment already set
   {
   Value.H_LogoFileWidth := StrToInt(EHeaderLogoWidth.Text);
   Value.H_LogoFileHeight := StrToInt(EHeaderLogoHeight.Text);
   Value.H_LogoFileAspect := cbHeaderLogoRatio.Checked;


   Value.H_Title := EHeaderTitle.Text;
   Value.H_TitleFont.Assign(EHeaderTitle.Font);
   Value.H_TitleAlignment := EHeaderTitle.Alignment;
   if (EHeaderTitle.Color <> clWindow)
   and (EHeaderTitle.Color <> clWhite) then
      Value.H_TitleColor := EHeaderTitle.Color
   else
      Value.H_TitleColor := clNone;

   Value.H_Text := EHeaderText.Text;
   Value.H_TextFont.Assign(EHeaderText.Font);
   Value.H_TextAlignment := EHeaderText.Alignment;
   if (EHeaderText.Color <> clWindow)
   and (EHeaderText.Color <> clWhite) then
      Value.H_TextColor := EHeaderText.Color
   else
      Value.H_TextColor := clNone;

   Value.F_Text := EFooterText.Text;
   Value.F_TextFont.Assign(EFooterText.Font);
   Value.F_TextAlignment := EFooterText.Alignment;
   if (EFooterText.Color <> clWindow)
   and (EFooterText.Color <> clWhite) then
      Value.F_TextColor := EFooterText.Color
   else
      Value.F_TextColor := ClNone;

   //Filename and Alignment already set
   Value.F_LogoFileWidth := StrToInt(EFooterLogoWidth.Text);
   Value.F_LogoFileHeight := StrToInt(EFooterLogoHeight.Text);
   Value.F_LogoFileAspect := cbFooterLogoRatio.Checked;
    }
end;

function TReportOptionDlg.GetHFSection: THFSection;
begin //hf_HeaderFirst, hf_HeaderAll, hf_FooterAll, hf_FooterLast
   case TcSection.TabIndex of
   0 : Result := hf_HeaderAll;
   1 : Result := hf_FooterAll;
   2 : Result := hf_HeaderFirst;
   else Result := hf_FooterLast;
   end;
end;

(*
procedure TReportOptionDlg.LoadLogoFromFile(Filename: string; Logo: TImage;
  Lable: TLabel);
var
  WidthAspect, HeightAspect : Double;
begin
  //set default width and height
  Logo.Top := 3;
  Logo.Left := 2;
  Logo.Width := 197;
  Logo.Height := 81;
  Lable.Caption := '';
  if (Filename = '') then
     Logo.Picture := nil
  else if (not BKFileExists(Filename)) then begin
     Logo.Picture := nil;
     Lable.Caption := Filename + #13#10 + 'cannot be found.';
  end else begin
     Logo.Picture.LoadFromFile(Filename);
     WidthAspect := (Logo.Width / Logo.Picture.Width);
     HeightAspect := (Logo.Height / Logo.Picture.Height);
     if (WidthAspect < HeightAspect) then begin
        Logo.Width := Trunc(Logo.Picture.Width * WidthAspect);
        Logo.Height := Trunc(Logo.Picture.Height * WidthAspect);
     end else begin
        Logo.Width := Trunc(Logo.Picture.Width * HeightAspect);
        Logo.Height := Trunc(Logo.Picture.Height * HeightAspect);
     end;
  end;
end;
*)

procedure TReportOptionDlg.Loadsection(Value: THFSection);
begin
   Editor.AsString := RptHeaderFooters[ FReportType].HF_Sections[Value];
end;


procedure TReportOptionDlg.SaveSection(Value: THFSection);
begin
   RptHeaderFooters[FReportType].HF_Sections[Value] := Editor.AsString;
end;


procedure TReportOptionDlg.SetHeaderFooter(const Value: TReportTypeParams);
begin //Write the Value to the UI
   Finsetup := True;
   try
      SetHFSection(Integer(GetHFSection));

      cbRptClientCode.Checked := fiClientCode in Value.FooterItems;
      cbRptPageNo.Checked := fiPageNumbers in Value.FooterItems;
      cbRptPrinted.Checked := fiPrinted in Value.FooterItems;
      cbRptTime.Checked := fiTime in Value.FooterItems;
      cbRptUser.Checked := fiUser in Value.FooterItems;
      cbRounded.Checked := Value.RoundValues;
      cbAccountPage.Checked := Value.NewPageforAccounts;

   chkHFEnabled.Checked := Value.HF_Enabled;
   if Value.HF_Style > '' then
      cbStyles.ItemIndex :=  cbStyles.Items.IndexOf(Value.HF_Style)
   else
      cbStyles.ItemIndex := 0;

   {
   //Header Logo
   LoadLogoFromFile(Value.H_LogoFile, ImageHeader, lHeaderLogo);
   SetLogoAlignment(ImageHeader,Value.H_LogoFileAlignment,ShapeHeader);
   EHeaderLogoWidth.Text := IntToStr(Value.H_LogoFileWidth);
   EHeaderLogoHeight.Text := IntToStr(Value.H_LogoFileHeight);
   cbHeaderLogoRatio.Checked := Value.H_LogoFileAspect;

   //Header Title
   EHeaderTitle.Text := Value.H_Title;
   EHeaderTitle.Font.Assign(Value.H_TitleFont);
   //EHeaderTitle.Font.Size := 9;
   EHeaderTitle.Alignment := Value.H_TitleAlignment;
   if Value.H_TitleColor <> clNone then
      EHeaderTitle.Color := Value.H_TitleColor
   else
      EHeaderTitle.Color := clWindow;


   //Header Text
   EHeaderText.Text := Value.H_Text;
   EHeaderText.Font := Value.H_TextFont;
   //EHeaderText.Font.Size := 9;
   EHeaderText.Alignment := Value.H_TextAlignment;
   if Value.H_TextColor <> clNone then
      EHeaderText.Color := Value.H_TextColor
   else
      EHeaderText.Color := clWindow;

   //Footer Text
   EFooterText.Text := Value.F_Text;
   EFooterText.Font.Assign(Value.F_TextFont);
   //EFooterText.Font.Size := 9;
   EFooterText.Alignment := Value.F_TextAlignment;
   if Value.F_TextColor <> clNone then
      EFooterText.Color := Value.F_TextColor
   else
      EFooterText.Color := clWindow;

   //Footer Logo
   LoadLogoFromFile(Value.F_LogoFile, ImageFooter, lblFooterLogo);
   SetLogoAlignment(ImageFooter, Value.F_LogoFileAlignment, ShapeFooter);
   EFooterLogoWidth.Text := IntToStr(Value.F_LogoFileWidth);
   EFooterLogoHeight.Text := IntToStr(Value.F_LogoFileHeight);
   cbFooterLogoRatio.Checked := Value.F_LogoFileAspect;


   }
   finally
      FinSetup := False;
   end;
end;

procedure TReportOptionDlg.SetHFSection(const Value: integer);
begin
  if (FHFSection <> Value) then begin
     //Different
     if (FHFSection >=0) then // Save the old one
         SaveSection(THFSection(FHFSection));

     FHFSection := Value;
  end;
  // Load it
  LoadSection(THFSection(FHFSection));
end;

(*
procedure TReportOptionDlg.SetLogoAlignment(Logo: TImage; Alignment: TAlignment;
  Shape: TShape);
begin
  case Alignment of
    taLeftJustify  : Logo.Left := 2;
    taCenter       : Logo.Left := ((shape.Width - Logo.Width) div 2) - 2;
    taRightJustify : Logo.Left := (shape.Width - Logo.Width) - 2;
  end;
end;
*)
procedure TReportOptionDlg.SetReportType(const Value: TReportType);

   procedure Accbutton(Text: string);
   begin
      CBRounded.Visible := False;
      cbAccountPage.Visible := True;
      cbAccountPage.Caption := '&Start a new page for each bank account' + Text;
   end;
begin
   if FReportType <> Value then // Save old one
      GetHeaderFooter(RptHeaderFooters[FReportType]);
   FReportType := Value;

   //Update the UI
   case FReportType of
     rptFinancial: begin
            cbAccountPage.Visible := False;
            CBRounded.Visible := True;
         end;
     rptCoding: Accbutton('');
     rptLedger,
     rptGraph: begin
            cbAccountPage.Visible := False;
            CBRounded.Visible := False;
         end;
     rptGst: Accbutton(' in: Audit Trail and Overrides reports');
     rptListings: Accbutton(' in: List Entries report');
     rptOther: Accbutton(' in: Bank Reconciliation report');
   end;

   // Update the Help Context ID
   case FReportType of
      rptFinancial: BKHelpSetUp(Self, BKH_Report_and_Graph_Options_Financial);
      rptCoding:    BKHelpSetUp(Self, BKH_Report_and_Graph_Options_Coding);
      rptLedger:    BKHelpSetUp(Self, BKH_Report_and_Graph_Options_Ledger);
      rptGst:       BKHelpSetUp(Self, BKH_Report_and_Graph_Options_GST);
      rptListings:  BKHelpSetUp(Self, BKH_Report_and_Graph_Options_Listings);
      rptOther:     BKHelpSetUp(Self, BKH_Report_and_Graph_Options_Other);
      rptGraph:     BKHelpSetUp(Self, BKH_Report_and_Graph_Options_Graphs);
   end;

   SetHeaderFooter(RptHeaderFooters[FReportType]);
end;



procedure TReportOptionDlg.TcSectionChange(Sender: TObject);
begin    
   HFSection := Integer(GetHFSection);
end;

procedure TReportOptionDlg.tcReportTypeChange(Sender: TObject);
begin
   ReportType :=
     TReportType(tcReportType.Tabindex);
end;




end.
