unit PrinterSettingsFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:  Print Job setup Dialog

  Written: 97/98  Re Written for ecoding Aug 2001
  Authors: Matthew

  Notes:
     expects a printer that has its devmode structure initialised
     resets the devmode when printer changes
     expects a TPRINTER object!!!!
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Printers,
  Buttons, winspool,  RzButton, RzCommon, RzCmboBx;

type
  TfrmPrinterSettings = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    lblStatus: TLabel;
    Label3: TLabel;
    lblType: TLabel;
    Label9: TLabel;
    lblWhere: TLabel;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    GroupBox3: TGroupBox;
    rbPortrait: TRadioButton;
    rbLandscape: TRadioButton;
    cmbPrinter: TRzComboBox;
    cmbSize: TRzComboBox;
    cmbSource: TRzComboBox;
    RzFrameController1: TRzFrameController;
    rbtProperties: TRzButton;
    rbtOK: TRzButton;
    rbtCancel: TRzButton;

    procedure cmbPrinterChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPropClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbSizeChange(Sender: TObject);
    procedure cmbSourceChange(Sender: TObject);
    procedure rbPortraitClick(Sender: TObject);
    procedure rbLandscapeClick(Sender: TObject);
  private
    { Private declarations }
    UserMode    : boolean;
    FPrinter    : TPrinter;
    FPaperSize  : integer;
    FOrient     : integer;
    FBin        : integer;

    {flags to show if set}
    Paper_Set   : boolean;
    Orient_Set  : boolean;
    Bin_Set     : boolean;

    {tstringlists for printer, bins, etc}
    FBinList    : TStringList;
    FPaperList  : TStringList;
    FPrinterList: TStringList;

    procedure ChangePrinter(newIndex : integer);
    procedure LoadNames;
    procedure ReadDevMode;
    procedure WriteDevMode;
    procedure LoadDialogSettings;
    procedure SaveDialogSettings;

  protected
    { Protected declarations }
    procedure SetPaperSize ( value :integer);
    procedure SetOrient (value : integer);
    procedure SetBin(value : integer);
    procedure UpdateStats;

  public
    { Public declarations }
    property DlgPrinter  : TPrinter read FPrinter write FPrinter;

    property PaperSize: integer read FPaperSize write SetPaperSize;
    property Orientation : integer read FOrient write SetOrient;
    property Bin      : integer read FBin write SetBin;

    function Execute : boolean;
  end;

//******************************************************************************
implementation
{$R *.DFM}
uses
   PrntInfo, NotesHelp;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.SetPaperSize( value :integer);
begin
   Paper_Set  := true;
   FPaperSize := value;
end;    {  }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.SetOrient(value : integer);
begin
  Orient_Set := true;
  FOrient    := value;
end;    {  }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.SetBin(value : integer);
begin
  Bin_Set    := true;
  FBin       := value;
end;    {  }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.UpdateStats;
var
  hPrinter, hDevMode: THANDLE;
  Device, Driver, Port: Array [0..255] of Char;
  Info : pPrinterInfo2;
  BytesRec : integer;

begin
   FPrinter.GetPrinter(device, driver, port, hDevMode);
   OpenPrinter(device, hPrinter, nil);
   GetPrinter(hPrinter,2,nil,0,@bytesRec);  {get size for buffer}

   {read info}
   GetMem(info,bytesRec);
   try
     if Winspool.GetPrinter(hPrinter,2,info,bytesRec,@bytesRec) then
     begin
       lblStatus.caption := GetStatusMsg(info^.Status);
       lblType.caption   := info^.pDriverName;
       lblWhere.caption  := info^.pPortName;
     end
     else
     begin
       lblStatus.caption := 'Unknown';
       lblType.caption   := '';
       lblWhere.caption  := '';
     end;
   finally
     FreeMem(info,SizeOf(info));
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.ReadDevMode;
var
  hDevMode: THANDLE;
  MydevMode: PDevMode;
  Device, Driver, Port: Array [0..255] of Char;
  Orient,
  Paper,
  lBin,
  i : integer;
  PaperIndex, BinIndex : integer;
  DevModeOK : boolean;
//  UnlockValue : longbool;
begin
  UserMode := false;
  try
     FPrinter.GetPrinter(device, driver, port, hDevMode);
     Paper     := 0;
     lBin      := 0;
     Orient    := 0;

     if hDevMode <> 0 then
     begin
       // Lock the memory
       try
         MyDevMode := GlobalLock(hDevMode);
         try
            Paper   := MyDevMode^.dmPaperSize;
            lBin    := MyDevMode^.dmDefaultSource;
            Orient  := MyDevMode^.dmOrientation;
            DevModeOK := true;
         finally
            //UnlockValue :=
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.ChangePrinter(newIndex : integer);
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.LoadNames;
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
           cmbSize.Items.Add(FPaperList.Strings[i]);
        cmbSize.enabled := true;
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.cmbPrinterChange(Sender: TObject);
begin
  lblstatus.Caption := 'Querying Printer...';
  lblType.Caption   := '';
  lblWhere.Caption  := '';
  Refresh;
  ChangePrinter(cmbPrinter.ItemIndex);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.LoadDialogSettings;
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.FormCreate(Sender: TObject);
begin
    left := (screen.width - width) div 2;
    top  := (Screen.height - height) div 3;

    FBinList := TStringList.Create;
    FPaperList := TStringList.Create;
    FPrinterList := TStringList.Create;
    FPrinter := printer;

    Orient_Set := false;
    Paper_Set  := false;
    Bin_Set    := false;
    BKHelpSetUp(Self, BKH_Print_Setup_Options);    
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmPrinterSettings.Execute : boolean;
var
   i : integer;
begin
   result := false;
   Screen.Cursor := crHourGlass;
   try
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

      {display}
      Screen.Cursor := crDefault;

      if ( ShowModal = mrOK) then begin
         WriteDevMode;
         SaveDialogSettings;
         result := true;
      end;
   finally
      //set back to normal just in case anything failed
      Screen.Cursor := crDefault;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.btnPropClick(Sender: TObject);
//read the extended properties for the print device
var
  hPrinter, hDevMode: THANDLE;
  Device, Driver, Port: Array [0..255] of Char;
  MyDevMode: PDevMode;

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
         WasOrient:= MyDevMode^.dmOrientation;

         if not DocumentProperties(Self.Handle, hPrinter, device, MydevMode^, MydevMode^,
           DM_IN_BUFFER or DM_IN_PROMPT or DM_OUT_BUFFER) = IDOK then exit;

         Paper   := MyDevMode^.dmPaperSize;
         lBin    := MyDevMode^.dmDefaultSource;
         Orient  := MyDevMode^.dmOrientation;

         //see if values need updating
         if WasPaper <> Paper then PaperSize     := Paper;
         if WasBin <> lBin then Bin              := lBin;
         if WasOrient <> Orient then Orientation := Orient;
       finally
         GlobalUnlock(hDevMode);
       end;
     end;
   ClosePrinter(hPrinter);


   ReadDevMode;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.FormDestroy(Sender: TObject);
Var
  i   : Integer;
begin
   FBinList.Free;

   For i := 0 to Pred( FPaperList.Count ) do TPaperInfo( FPaperList.Objects[ i ] ).Free;
   FPaperList.Free;

   FPrinterList.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.WriteDevMode;
var
  hDevMode: THANDLE;
  MydevMode: PDevMode;
  Device, Driver, Port: Array [0..255] of Char;

  Orient,
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
       MyDevMode^.dmCopies        := 1;
       MyDevMode^.dmOrientation   := Orient;
    finally
       GlobalUnlock(hDevMode);
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.cmbSizeChange(Sender: TObject);
begin
   if UserMode then
     if cmbSize.Items.Count > 0 then
       PaperSize := TPaperInfo(FPaperList.Objects[cmbSize.Itemindex]).Index;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.cmbSourceChange(Sender: TObject);
begin
   if UserMode then
     if cmbSource.Items.count > 0 then
       Bin := integer(FBinList.Objects[cmbSource.ItemIndex]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.rbPortraitClick(Sender: TObject);
begin
   if UserMode then Orientation := DMORIENT_PORTRAIT;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.rbLandscapeClick(Sender: TObject);
begin
   if UserMode then Orientation := DMORIENT_LANDSCAPE;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPrinterSettings.SaveDialogSettings;
begin
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
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
