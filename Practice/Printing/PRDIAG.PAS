unit prdiag;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:  Print Job setup Dialog

  Written: 97/98
  Authors: Matthew

  Purpose: Allows user to set required setting for current print job.
     Unless dialog is in "setup only".  In this mode there is no current print job
     so only the printer settings are available.  The save settings button is also
     invisible.  Clicking OK will automatically save the report settings.

  Notes:
     expects a printer that has its devmode structure initialised
     resets the devmode when printer changes
     expects a TPRINTER object!!!!
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, OvcBase, OvcEF, OvcPB, OvcNF, OvcPF, Printers,
  Buttons, winspool, Progress,
  OSFont;


Const
  mrPrint   = 158; // a modal results for the Print/Preview button
  mrPreview = 159;

type
  TPrnDialog = class(TForm)
    btOK: TBitBtn;
    btCancel: TBitBtn;
    OvcController1: TOvcController;
    GBPrinter: TGroupBox;
    Label2: TLabel;
    lblStatus: TLabel;
    Label3: TLabel;
    lblType: TLabel;
    cmbPrinter: TComboBox;
    btnProp: TButton;
    chkUseDefault: TCheckBox;
    GBPrint: TGroupBox;
    Label5: TLabel;
    rbAllPages: TRadioButton;
    rbFrom: TRadioButton;
    opFrom: TOvcPictureField;
    opTo: TOvcPictureField;
    GBPaper: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    lblOrientation: TLabel;
    cmbSize: TComboBox;
    cmbSource: TComboBox;
    rbPortrait: TRadioButton;
    rbLandscape: TRadioButton;
    Label1: TLabel;
    lblWhere: TLabel;
    opCopies: TOvcPictureField;
    Label6: TLabel;
    Label4: TLabel;
    btnSetMargins: TButton;
    GBSave: TGroupBox;
    btnSave: TButton;
    btnReset: TButton;
    BtPreview: TBitBtn;
    btPrint: TBitBtn;

    procedure udCopiesClick(Sender: TObject; Button: TUDBtnType);
    procedure btCancelClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure cmbPrinterChange(Sender: TObject);
    procedure opFromEnter(Sender: TObject);
    procedure opToEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPropClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure cmbSizeChange(Sender: TObject);
    procedure cmbSourceChange(Sender: TObject);
    procedure opCopiesChange(Sender: TObject);
    procedure rbPortraitClick(Sender: TObject);
    procedure rbLandscapeClick(Sender: TObject);
    procedure btnSetMarginsClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtPreviewClick(Sender: TObject);
    procedure btPrintClick(Sender: TObject);
  private
    { Private declarations }
    UserMode    : boolean;

    okPressed   : boolean;
    FPrinter    : TPrinter;

    FPageFrom   : integer;
    FPageTo     : integer;
    FPageMax    : integer;
    FPageMin    : integer;
    FCopies     : integer;

    FPaperSize  : integer;
    FOrient     : integer;
    FBin        : integer;

    {extended properties for banklink5}
    FUseDefault : boolean;
    FFontName   : string;
    FFontSize   : integer;
    FFontStyle  : TFontStyles;
    FDisablePrinterChange : Boolean;

    {flags to show if set}
    Paper_Set   : boolean;
    Orient_Set  : boolean;
    Bin_Set     : boolean;
    Copies_Set  : boolean;

    {tstringlists for printer, bins, etc}
    FBinList    : TStringList;
    FPaperList  : TStringList;
    FPrinterList: TStringList;
    FSetupOnly: boolean;
    FPrePrintSetup: Boolean;

    procedure ChangePrinter(newIndex : integer);
    procedure LoadNames;
    procedure ReadDevMode;
    procedure WriteDevMode;

    procedure LoadDialogSettings;
    procedure SaveDialogSettings;

    procedure SetSetupOnly(const Value: boolean);
    procedure SetPrePrintSetup(const Value: Boolean);

  protected
    { Protected declarations }
    procedure SetPaperSize ( value :integer);
    procedure SetOrient (value : integer);
    procedure SetBin(value : integer);
    procedure SetCopies(value : integer);
    function UpdateStats : boolean;

  public
    { Public declarations }
    Margins       : TRect;      {extended for bk5}
    SaveClicked   : boolean;

    property PageMax  : integer read FPageMax write FPageMax;
    property PageMin  : integer read FPageMin write FPageMin;
    property PageFrom : integer read FPageFrom write FPageFrom;
    property PageTo   : integer read FPageTo write FPageTo;

    property DlgPrinter  : TPrinter read FPrinter write FPrinter;

    property Copies   : integer read FCopies write SetCopies;
    property PaperSize: integer read FPaperSize write SetPaperSize;
    property Orientation : integer read FOrient write SetOrient;
    property Bin      : integer read FBin write SetBin;

    {extended properties for banklink5}
    property UseDefPrinter : boolean read FUseDefault write FUseDefault;
    property DefFontName   : string read FFontName write FFontName;
    property DefFontSize   : integer read FFontSize write FFontSize;
    property DefFontStyle  : TFontStyles read FFontStyle write FFontStyle;

    property SetupOnly     : boolean read FSetupOnly write SetSetupOnly;

    property DisablePrinterChange : Boolean read FDisablePrinterChange write FDisablePrinterChange;

    Property PrePrintSetup : Boolean read FPrePrintSetup write SetPrePrintSetup;

    function Execute : TModalResult;
  end;

//******************************************************************************
implementation

{$R *.DFM}

uses

  bkXPThemes,
  PrntInfo,
  AdvReportFrm;





{-------------------------------------------------}
procedure TPrnDialog.SetPaperSize( value :integer);
begin
   Paper_Set  := true;
   FPaperSize := value;
end;    {  }

{-------------------------------------------------}
procedure TPrnDialog.SetOrient(value : integer);
begin
  Orient_Set := true;
  FOrient    := value;
end;    {  }

{-------------------------------------------------}
procedure TPrnDialog.SetBin(value : integer);
begin
  Bin_Set    := true;
  FBin       := value;
end;    {  }

procedure TPrnDialog.SetCopies(value: integer);
begin
  Copies_Set := true;
  FCopies    := Value;
end;

{-------------------------------------------------}

procedure TPrnDialog.udCopiesClick(Sender: TObject; Button: TUDBtnType);
begin

   case Button of        {  }
      btNext :
        if opCopies.AsInteger < 100 then
        begin
           opCopies.AsInteger := opCopies.AsInteger + 1;
           opCopiesChange(Sender);
        end;

      btPrev :
        if opCopies.AsInteger > 1 then
        begin
           opCopies.AsInteger := opCopies.AsInteger - 1;
           opCopiesChange(Sender);
        end;
   end;        { case }

end;

{-------------------------------------------------}
procedure TPrnDialog.btCancelClick(Sender: TObject);
begin
   if saveClicked then
      Modalresult := mrOk
   else
      Modalresult := mrCancel;
   //Close;
end;

{-------------------------------------------------}
procedure TPrnDialog.btOkClick(Sender: TObject);
begin
   if SetupOnly then        //save button will have disappeared because there
      SaveClicked := true;  //is not reason for it to be there ie no CURRENT job

   okPressed := true;
   ModalResult := mrOK;
   //Close;
end;

//   See http://support.microsoft.com/kb/q160129/
function TPrnDialog.UpdateStats : boolean;
var
  LStat,
  LDriver,
  LLocation : String;

begin
   lblStatus.caption := 'Checking..';
   result := CheckPrinterStatus(fPrinter,lstat,LDriver,LLocation);

   lblType.Caption   := LDriver;
   lblwhere.Caption  := LLocation;

   lblStatus.caption := LStat;
end;




procedure TPrnDialog.ReadDevMode;
var
  hDevMode: THANDLE;
  MydevMode: PDevMode;
  Device, Driver, Port: Array [0..255] of Char;
  Orient,
  lCopies,
  Paper,
  lBin,
  i : integer;
  PaperIndex, BinIndex : integer;
  DevModeOK : boolean;
begin
  UserMode := false;
  try
     FPrinter.GetPrinter(device, driver, port, hDevMode);
//     DevModeOK := false;
     Paper     := 0;
     lBin      := 0;
     Orient    := 0;
     lCopies   := 0;

     if hDevMode <> 0 then
     begin
       // Lock the memory
       try
         MyDevMode := GlobalLock(hDevMode);
         try
            Paper   := MyDevMode^.dmPaperSize;
            lBin := MyDevMode^.dmDefaultSource;
            lCopies := MyDevMode^.dmCopies;
            Orient  := MyDevMode^.dmOrientation;
            DevModeOK := true;
         finally
            GlobalUnlock(hDevMode);
         end;
       except
         DevModeOK := false;
       end;

       if DevModeOK then
       begin
          {Set default paper and bin}
          PaperIndex := 0;
          for i:= 0 to Pred(FPaperList.Count) do
             if TPaperInfo(FPaperList.Objects[i]).index = Paper then
             begin
               PaperIndex := i;
               break;
             end;
          cmbSize.ItemIndex := PaperIndex;

          BinIndex := 0;
          for i:= 0 to Pred(FBinList.Count) do
            if integer(FBinList.Objects[i]) = lBin then
            begin
              BinIndex := i;
              break;
            end;
          cmbSource.ItemIndex := BinIndex;

          {paper - if set then try to override default setting}
          if Paper_Set then
             if FPaperSize <> 0 then  {check to see if is a valid size}
               for i:= 0 to Pred(FPaperList.Count) do
                  if TPaperInfo(FPaperList.Objects[i]).index = FPaperSize then
                  begin
                    cmbSize.ItemIndex := i;
                    break;
                  end;

          {bin - if set then try to override default setting}
          if Bin_Set then
             if FBin <> 0 then
               for i:= 0 to Pred(FBinList.Count) do
                  if integer(FBinList.Objects[i]) = FBin then
                  begin
                    cmbSource.ItemIndex := i;
                    break;
                  end;

          {copies and orientation}
          if Copies_Set then Copies := FCopies;
          if lCopies > 0 then
              opCopies.AsInteger := lCopies;

          if Orient_Set then Orient := FOrient;
          if Orient = DMORIENT_PORTRAIT then
              rbPortrait.Checked := true
            else
              rbLandscape.Checked := true;
       end; {devmodeok}
     end;
   finally
     UserMode := true;
   end;
end;

procedure TPrnDialog.ChangePrinter(newIndex : integer);
var
   Device, Driver, Port: Array [0..255] of Char;
   hDevMode : THANDLE;
begin
   {reset defaults}
   with FPrinter do begin
     PrinterIndex := newIndex;
     GetPrinter(device, driver, port, hDevMode);
     SetPrinter(device, driver, port, 0);
   end;

   UpdateStats;
   LoadNames;
   ReadDevMode;
end;

procedure TPrnDialog.LoadNames;
var
   i : integer;
begin
  UserMode := false;
  try
     {load names}
     cmbSize.Items.clear;
     cmbSource.Items.Clear;

     GetPaperNames(FPrinter,FPaperList);
     if ( FPaperList.Count > 0) then begin
        for i := 0 to Pred(FPaperList.Count) do
           cmbSize.Items.AddObject(FPaperList.Strings[i], FPaperList.Objects[i]);
        {If NOT FPrePrintSetup
          then} cmbSize.enabled := true; // Can't change the papersize
     end
     else
        //Printer has not returned printer names so user cannot set
        cmbSize.enabled := false;

     GetBinNames(FPrinter,FBinList);
     if ( FBinList.Count > 0) then begin
        for i := 0 to Pred(FBinList.Count) do
           cmbSource.Items.Add(FBinList.Strings[i]);

        cmbSource.enabled := true;
     end
     else
        //Printer has not returned available bins so user cannot set
        cmbSource.enabled := false;
  finally
     UserMode := true;
  end;
end;

{-------------------------------------------------}
procedure TPrnDialog.cmbPrinterChange(Sender: TObject);
begin
  lblstatus.Caption := 'Querying Printer...';
  lblType.Caption   := '';
  lblWhere.Caption  := '';
  Refresh;
  ChangePrinter(cmbPrinter.ItemIndex);
end;

{-------------------------------------------------}
procedure TPrnDialog.opFromEnter(Sender: TObject);
begin
  rbFrom.Checked := true;
end;

{-------------------------------------------------}
procedure TPrnDialog.opToEnter(Sender: TObject);
begin
       rbFrom.Checked := true;
end;

{-------------------------------------------------}
procedure TPrnDialog.LoadDialogSettings;

begin
  {setup page from/to}
  if FPageFrom = 0 then
    opFrom.AsInteger := FPageMin
  else begin
    opFrom.AsInteger := FPageFrom;
    rbFrom.Checked := true;
  end;

  if FPageTo = 0 then
    opTo.AsInteger   := FPageMax
  else begin
    rbAllPages.Caption := '&All ' + IntToStr(FPageMax) + ' pages'; // info would have been lost..
    opTo.AsInteger   := FPageTo;
    rbFrom.Checked := true;
  end;

  chkUseDefault.Checked := FUseDefault;


  if SetupOnly then
  begin
     Self.caption    := 'Setup Report';
  end;
end;    {  }

{-------------------------------------------------}
procedure TPrnDialog.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  left := (screen.width - width) div 2;
  top  := (Screen.height - height) div 3;

  FBinList := TStringList.Create;
  FPaperList := TStringList.Create;
  FPrinterList := TStringList.Create;
  FPrinter := printer;

  Orient_Set := false;
  Paper_Set  := false;
  Copies_Set := false;
  Bin_Set    := false;
end;

{-------------------------------------------------}
function TPrnDialog.Execute : TModalResult;
var
   i : integer;

   procedure EnableSetup ( Const Enable : Boolean);
   begin
      // Paper...
      {
      Label7.Enabled := Enable;
      cmbSize.Enabled := Enable;
       Source should be ok...
      Label8.Enabled := Enable;
      cmbSource.Enabled := Enable;
      }
      lblOrientation.Enabled := Enable;
      rbPortrait.Enabled := Enable;
      rbLandscape.Enabled := Enable;

      BtnSetMargins.Enabled := Enable;
      // Restore Save...
      btnreset.Enabled := Enable;
      btnSave.Enabled := Enable;

      // Use Default..
      chkUseDefault.Enabled := Enable;
   end;

   procedure EnableCopies(Const Enable : boolean);
   begin
      OPCopies.Enabled := Enable;
      Label6.Enabled := Enable;
   end;

   procedure Enablepages(Const Enable : boolean);
   begin
      rbAllPages.Enabled := Enable;
      rbFrom.Enabled := Enable;
      OPFrom.Enabled := Enable;
      OPTo.Enabled := Enable;
      label4.Enabled := Enable;
      label5.Enabled := Enable;
   end;

   procedure EnablePbuttons (Const Enable : Boolean);
   begin
      btPreview.Visible := Enable;
      btPrint.Visible := Enable;
      btok.Visible := NOT Enable;
   end;

begin
   okPressed     := false;
   Result := mrCancel;
   Screen.Cursor := crHourGlass;
   try  try
      {Load Printers}
      cmbPrinter.Items.Clear;
      for i := 0 to Pred(FPrinter.Printers.Count) do
        cmbPrinter.Items.Add(GetPrinterName(i));
      cmbPrinter.ItemIndex := FPrinter.PrinterIndex;

      {update dialog settings}
      LoadDialogSettings;

      {update status and settings}
      UpdateStats;
      LoadNames;
      ReadDevMode;
        {
      if FPrePrintSetup then begin
         Enablesetup (false); // Needs to be after Loadnames..
         EnablePages (false);
      end;
          }
      if FSetupOnly then begin
         Enablepages (false);
         EnableCopies(false);
         EnablePbuttons (false);
      end else begin
         EnablePbuttons(True);
      end;

      // If faxing setup then we don't let the user change the printer here
      if FDisablePrinterChange then
      begin
        cmbPrinter.Enabled := False;
        btnProp.Enabled := False;
        chkUseDefault.Enabled := False;
      end;

      {display}
      Screen.Cursor := crDefault;

      //*****************************
      Result := Self.ShowModal;
      //*****************************

      {save if okay}
      if okPressed then
      begin
         WriteDevMode;
         SaveDialogSettings;
      end;
   except

   end;
   finally
      //set back to normal just in case anything failed
      Screen.Cursor := crDefault;
   end;
end;

procedure TPrnDialog.btnPropClick(Sender: TObject);
//read the extended properties for the print device
var
  hPrinter, hDevMode: THANDLE;
  Device, Driver, Port: Array [0..255] of Char;
  MyDevMode: PDevMode;

  lCopies, WasCopies,
  Paper, WasPaper,
  lBin, WasBin,
  Orient, WasOrient    : integer;
begin
   WriteDevMode;
   FPrinter.GetPrinter(device, driver, port, hDevMode);
   OpenPrinter(device, hPrinter, nil);
   if hDevMode <> 0 then
     begin
       MyDevMode := GlobalLock(hDevMode);
       try
         WasPaper := MyDevMode^.dmPaperSize;
         WasBin   := MyDevMode^.dmDefaultSource;
         WasCopies:= MyDevMode^.dmCopies;
         WasOrient:= MyDevMode^.dmOrientation;
         if not DocumentProperties(Self.Handle, hPrinter, device, MydevMode^, MydevMode^,
           DM_IN_BUFFER or DM_IN_PROMPT or DM_OUT_BUFFER) = IDOK then exit;

         Paper   := MyDevMode^.dmPaperSize;
         lBin    := MyDevMode^.dmDefaultSource;
         lCopies := MyDevMode^.dmCopies;
         Orient  := MyDevMode^.dmOrientation;

         //see if values need updating
         if WasPaper <> Paper then PaperSize     := Paper;
         if WasBin <> lBin then Bin              := lBin;
         if WasCopies <> lCopies then Copies     := lCopies;
         if WasOrient <> Orient then Orientation := Orient;
       finally
         GlobalUnlock(hDevMode);
       end;
     end;
   ClosePrinter(hPrinter);


   ReadDevMode;
end;

procedure TPrnDialog.FormDestroy(Sender: TObject);
Var
  i   : Integer;
begin
   FBinList.Free;

   For i := 0 to Pred( FPaperList.Count ) do TPaperInfo( FPaperList.Objects[ i ] ).Free;
   FPaperList.Free;

   FPrinterList.Free;
end;

procedure TPrnDialog.WriteDevMode;
var
  hDevMode: THANDLE;
  MydevMode: PDevMode;
  Device, Driver, Port: Array [0..255] of Char;

  Orient,
  lCopies,
  Paper,
  lBin,
  PaperIndex, BinIndex : integer;
begin
  FPrinter.GetPrinter(device, driver, port, hDevMode);

  Paper  := 0;
  lBin   := 0;

  if hDevMode <> 0 then
  begin
    if cmbSize.Items.Count > 0 then
    begin
      PaperIndex := cmbSize.ItemIndex;
      Paper      := TPaperInfo(FPaperList.Objects[PaperIndex]).index;
    end;

    if cmbSource.Items.Count > 0 then
    begin
      BinIndex   := cmbSource.ItemIndex;
      lBin        := integer(FBinList.Objects[BinIndex]);
    end;

    lCopies     := opCopies.AsInteger;

    if rbPortrait.Checked then
      Orient := DMORIENT_PORTRAIT
    else
      Orient := DMORIENT_LANDSCAPE;

    // Lock the memory
    MyDevMode := GlobalLock(hDevMode);
    try
       MyDevMode^.dmFields := MyDevMode^.dmFields or
                            dm_paperSize or
                            dm_copies or
                            dm_defaultsource or
                            dm_Orientation or
                            dm_Color or
                            DM_PRINTQUALITY;

       MyDevMode^.dmPaperSize     := Paper;
       MyDevMode^.dmDefaultSource := lBin;
       MyDevMode^.dmCopies        := lCopies;
       MyDevMode^.dmOrientation   := Orient;
    finally
       GlobalUnlock(hDevMode);
    end;
  end;
end;


procedure TPrnDialog.btnResetClick(Sender: TObject);
begin
   Orient_Set := false;
   Paper_Set  := false;
   Copies_Set := false;
   Bin_Set    := false;

   //reset margins
   Margins.Top    := 0;
   Margins.Left   := 0;
   Margins.Bottom := 0;
   Margins.Right  := 0;

   FFontName := 'Arial';
   FFontSize := 8;
   FFontStyle := [];

   //set to use default printer if not faxing
   if not DisablePrinterChange then
   begin
     chkUseDefault.checked := true;
     ChangePrinter(-1);
     //reposition the combo to display default printer
     cmbPrinter.ItemIndex := FPrinter.PrinterIndex;
   end
   else
    ChangePrinter(cmbPrinter.ItemIndex);
end;

procedure TPrnDialog.cmbSizeChange(Sender: TObject);
begin
   if UserMode then
     if cmbSize.Items.Count > 0 then
       PaperSize := TPaperInfo(FPaperList.Objects[cmbSize.Itemindex]).Index;
end;

procedure TPrnDialog.cmbSourceChange(Sender: TObject);
begin
   if UserMode then
     if cmbSource.Items.count > 0 then
       Bin := integer(FBinList.Objects[cmbSource.ItemIndex]);
end;

procedure TPrnDialog.opCopiesChange(Sender: TObject);
begin
   if UserMode then Copies := opCopies.AsInteger;
end;

procedure TPrnDialog.rbPortraitClick(Sender: TObject);
begin
   if UserMode then Orientation := DMORIENT_PORTRAIT;
end;

procedure TPrnDialog.rbLandscapeClick(Sender: TObject);
begin
   if UserMode then Orientation := DMORIENT_LANDSCAPE;
end;

procedure TPrnDialog.SaveDialogSettings;
begin
   FPageFrom := opFrom.AsInteger;
   FPageTo   := opTo.AsInteger;
   FCopies   := opCopies.AsInteger;
   if ( cmbSource.Items.Count > 0) then
      FBin      := integer(FBinList.Objects[cmbSource.ItemIndex]);
   //else use current value.  this will be the value that was passed in to this dialog
   //since it will not have been changed

   if ( cmbSize.Items.Count > 0) then
      FPaperSize:= TPaperInfo(FPaperList.Objects[cmbSize.ItemIndex]).index;
   //else use current value

   if rbPortrait.Checked then
      FOrient := DMORIENT_PORTRAIT
    else
      FOrient := DMORIENT_LANDSCAPE;

   FUseDefault := chkUseDefault.Checked;
end;

procedure TPrnDialog.btnSetMarginsClick(Sender: TObject);
var
   MyDlg : TfrmAdvReport;
begin
   MyDlg := TfrmAdvReport.Create(self);
   try
     MyDlg.nfTop.AsFloat    := Margins.Top / 10;
     MyDlg.nfLeft.AsFloat   := Margins.Left / 10;
     MyDlg.nfBottom.AsFloat := Margins.Bottom / 10;
     MyDlg.nfRight.AsFloat  := Margins.Right /10;

     if MyDlg.Execute then
     begin
        Margins.Top    := Round(MyDlg.nfTop.AsFloat * 10);
        Margins.Left   := Round(MyDlg.nfLeft.AsFloat * 10);
        Margins.Bottom := Round(MyDlg.nfBottom.AsFloat * 10);
        Margins.Right  := Round(MyDlg.nfRight.AsFloat * 10);
     end;
   finally
     MyDlg.Free;
   end;
end;

procedure TPrnDialog.btnSaveClick(Sender: TObject);
begin
   SaveClicked := true;
   okPressed := true; //a bit ambiguous, but needed to save...
end;


procedure TPrnDialog.FormShow(Sender: TObject);
begin
   Progress.ClearStatus;
end;

procedure TPrnDialog.SetSetupOnly(const Value: boolean);

begin
    FSetupOnly := Value;
end;

procedure TPrnDialog.SetPrePrintSetup(const Value: Boolean);
begin
  FPrePrintSetup := Value;
end;

procedure TPrnDialog.BtPreviewClick(Sender: TObject);
begin
   okPressed := True;
   Modalresult := mrPreview;
end;


procedure TPrnDialog.btPrintClick(Sender: TObject);
  function CheckPageRange : boolean;
  begin
     result := pageMax < 1; //No Info..
     if  result then
        exit;
     // so result = false..
     if( opFrom.AsInteger > 0)
     and (opFrom.AsInteger > PageMax)
      then begin
        MessageDlg('Nothing to print'#13'''From'' page too high', mtInformation
                     , [mbOk],0);
        OpFrom.SetFocus;
        Exit;
     end;

     if opFrom.AsInteger > opTo.AsInteger then begin
         MessageDlg('Nothing to print'#13'''From'' higher than ''To''' , mtInformation
                     , [mbOk],0);
         OpFrom.SetFocus;
         Exit;
     end;
     // still here...
     Result := True;
  end;

begin
   if not CheckPageRange then Exit;
   if not UpdateStats then begin
     if  MessageDlg('Printer Not ready'#13'Print job may fail', mtWarning
                     , [mbOk , mbcancel], 0) <> mrok
         then exit;
   end;
   // Check the page Range..
   okPressed := True;
   ModalResult := mrPrint;
end;

end.
