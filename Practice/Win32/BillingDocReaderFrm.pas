unit BillingDocReaderFrm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, reportdefs,
  OsFont, ExtCtrls;

type
  TReportImage = class
    Filename : string;
    DiskID : string;  //000..A03 etc
    DiskNumber : integer;
    DownloadDate : integer;
    Version : byte;     //0 = old, 1 = htm
    SubVersion : byte;
    ImageType : byte;  //0 = unknown, 1 = statement, 2 = interim

    constructor Create;
  private
    FPeriodKnown : boolean;  //do we know which period the image refers to
    FHaveLookedForPeriod : boolean;
    FCaption : string;

    function GetCaption : string;
    procedure SetCaption( aCaption : string);
  public
    procedure LoadPeriodInformation;  //load the caption with meaningful information
    property Caption : string read GetCaption write SetCaption;
  end;

  TReportImageList = class( TList)
  public
    procedure LoadFromDir( aDir : string);
    function ReportImageAt(i : integer) : TReportImage;

    destructor Destroy; override;
  end;

type
  TfrmBillingDocReader = class(TForm)
    Label1: TLabel;
    cmbImages: TComboBox;
    cbIncludeInterimReports: TCheckBox;
    pnlControls: TPanel;
    btnPDF: TButton;
    btnCancel: TButton;
    ShapeBorder: TShape;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnPDFClick(Sender: TObject);
    procedure cmbImagesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cbIncludeInterimReportsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ReportImagesList : TReportImageList;
    procedure PrintTo(Dest: TReportDest);
    procedure LoadReports(IncludeInterim: Boolean = False);
  public
    { Public declarations }
    function GetStatementIndex(dt: Integer): Integer;
    function IsStatementAvailable(dt: Integer): Boolean;
    procedure ShowStatement(dt: Integer);
  end;

  procedure SelectReport;

implementation
uses
  rptInvoice, GlobalDirectories,
  ShellAPI, DownloadUtils, stDate, bkDateUtils,
  StreamIO, imagesFrm, bkHelp, bkXPThemes, Globals;

const
  itUnknown = 0;
  itStatement = 1;
  itInterim = 2;

  STATEMENT_TEXT = 'Statement/Tax Invoice for ';

{$R *.dfm}

procedure TfrmBillingDocReader.FormCreate(Sender: TObject);
begin
  //load list of report images from disk
  bkXPThemes.ThemeForm( Self);
  BKHelpSetup(Self, BKH_Statements_and_Download_Documents);
  ReportImagesList := TReportImageList.Create;
  ReportImagesList.LoadFromDir( GlobalDirectories.glDataDir + 'work\');
  cbIncludeInterimReports.Checked := UserINI_Show_Interim_Reports;
  LoadReports(UserINI_Show_Interim_Reports);
end;

procedure TfrmBillingDocReader.FormDestroy(Sender: TObject);
begin
  FreeAndNil(ReportImagesList);
end;

{ TReportImageList }

destructor TReportImageList.Destroy;
var
  i : integer;
begin
  //empty objects
  for i := 0 to Count - 1 do
    ReportImageAt(i).Free;

  inherited;
end;
function CompareDiskNumber(Item1, Item2: Pointer): Integer;
var
  int1, int2 : integer;
begin
  int1 := TReportImage( Item1).DiskNumber;
  int2 := TReportImage( Item2).DiskNumber;

  if int1 < int2 then result := 1 else
  if int1 > int2 then result := -1 else
    result := 0;
end;

procedure TReportImageList.LoadFromDir(aDir: string);
const
  MaxImagesToParse = 24;
var

  aImage          : TReportImage;
  i : integer;
  NumImagesToParse : integer;

  procedure Lookfor(FileSearchMask: string; IdPos,IdLength: Integer);
  var Found: Integer;
      SearchRec: TSearchRec;
      NewImage: TReportImage;
  begin
     Found := FindFirst( aDir + FileSearchMask, faAnyFile, SearchRec);
     try
        while Found = 0 do begin

           NewImage := TReportImage.Create;
           NewImage.Filename := aDir + SearchRec.Name;
           if IdLength = 0 then
              NewImage.DiskID  := Copy( SearchRec.Name, IdPos, Pos('.',SearchRec.Name) - IdPos)
           else
              NewImage.DiskID := Copy( SearchRec.Name, IdPos, IdLength);
           NewImage.DiskNumber := DownloadUtils.SuffixToSequenceNo( NewImage.DiskID);
           NewImage.Version := 0;
           NewImage.DownloadDate := stDate.DateTimeToStDate( FileDateToDateTime(SearchRec.Time));
           with NewImage do
              Caption := 'Disk Image ' + DiskID + '    ' + bkDate2Str( DownloadDate);

           Self.Add( NewImage);
           Found := FindNext(SearchRec);
        end;
     finally
        FindClose(SearchRec);
     end;
  end;

begin
  //search directory
  //look for v1 format  REPORT.nnn
  LookFor('reports.????',9,4); // catches .??? as well ...

  //LookFor('report_???.htm',8,3);
  LookFor('report_????.htm',8,0); // Catched ???. as well


  //sort so last download is at top
  Self.Sort( @CompareDiskNumber);

  //parse disk images to extract a useful description to show the user
  if Count < MaxImagesToParse then
    NumImagesToParse := Count
  else
    NumImagesToParse := MaxImagesToParse;

  for i := 0 to NumImagesToParse - 1 do
  begin
    aImage := Items[i];
    aImage.LoadPeriodInformation;
  end;
end;

function TReportImageList.ReportImageAt(i: integer): TReportImage;
begin
  result := TReportImage( Items[i]);
end;

procedure TfrmBillingDocReader.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBillingDocReader.btnPDFClick(Sender: TObject);
begin
  PrintTo( rdFile);
end;

procedure TfrmBillingDocReader.PrintTo( Dest : TReportDest);
var
  Image : TReportImage;
  pdfFilename : string;
begin
  if cmbImages.ItemIndex > - 1 then
  begin
    Image := TReportImage( cmbImages.Items.Objects[cmbImages.ItemIndex]);
    if Dest = rdFile then
      pdfFilename := Image.Filename+'.pdf'
    else
      pdfFilename := '';

    if (RptInvoice.DoInvoiceReport( rdScreen, Image.Caption, Image.Filename, pdfFilename)) and ( Dest = rdFile) then
    begin
       ShellExecute(0, 'open', PChar(pdfFileName), nil, nil, SW_SHOWMAXIMIZED);
    end;
  end;
end;

procedure SelectReport;
var
 fm : TfrmBillingDocReader;
begin
 fm := TfrmBillingDocReader.Create(Application.MainForm);
 try
   
   fm.ShowModal;
 finally
   fm.Release;
 end;
end;

{ TReportImage }

constructor TReportImage.Create;
begin
  inherited;

  FPeriodKnown := false;
  FHaveLookedForPeriod := false;
end;

function TReportImage.GetCaption: string;
begin
  //see if we have loaded the period information yet
  if not FHaveLookedForPeriod then
    LoadPeriodInformation;

  result := FCaption;
end;

procedure TReportImage.LoadPeriodInformation;
var
  fn : string;
  fs : TFileStream;
  inFile : TextFile;
  infoFound : boolean;
  s : string;
  p : integer;
  lineNo : integer;
  StatementId : string;
  AcctChargesId : string;


  function ReadLine: string;
  var i: Integer;
  begin
     Readln( inFile, Result);
     for I := 1 to Length(Result) do
       case Result[i] of
       #$A0 : Result[i] := #$20; // None braking space to 'Normal' space See Case 10726
       // can easaly add any more...
       end;
  end;

begin
  //already have period info
  if FPeriodKnown or FHaveLookedForPeriod then
    exit;

  //if we have looked already then dont look again
  FHaveLookedForPeriod := true;

  InfoFound := false;
  LineNo := 0;

  fn := Self.Filename;
  fs := TFileStream.Create( Self.Filename, fmOpenRead);
  try
    StreamIO.AssignStream( inFile, fs);
    Reset( inFile);
    try
      //read first line, to determine format

      s := readLine;
      if pos( '<html>', s) = 1 then
      begin
        StatementId := 'STATEMENT<br>';
        AcctChargesId := 'TRANSACTIONS<br>';//'CHARGES<br>';
        Self.Version := 1
      end
      else
      begin
        StatementId := '<big>STATEMENT';
        AcctChargesId := '<big>CLIENT';
        Self.Version := 0;
      end;

      while not (EOF( inFile) or infoFound or (LineNo > 75)) do
      begin
        //read lines looking for date info
        s := readLine;
        LineNo := LineNo + 1;

        //if we find a statement line then this is a monthly statement/invoice
        if pos( StatementID, s ) > 0 then
        begin
           //read the next line this should be <lmp>30 June xxx
           s := readLine;

           if Self.Version = 0 then
           begin
             if pos( '<lmp>', s) = 1 then
             begin
               s := Copy( s, 6, length( s));
               FCaption := STATEMENT_TEXT + s;
               infoFound := true;

               Imagetype := itStatement;
             end;
           end
           else
           begin
             //next line should be
             //30 June 2005<br>
             p := pos( '<br>', s);
             if p > 0 then
             begin
               s := Copy( s, 1, p -1);
               p := pos( '>', s);
               if p > 0 then
                 s := Copy( s, p + 1, length(s));
               FCaption := 'Statement/Tax Invoice for ' + s;
               infoFound := true;

               ImageType := itStatement;
             end;
           end;
         end;

         //if we find a client account charge page first this is an interim
         //report
         if pos( AcctChargesId, s) > 0 then
         begin
           //read the next line this should be <lmp>30 June xxx
           s := readLine;

           if Self.Version = 0 then
           begin
             if pos( '<lmp>', s) = 1 then
             begin
               s := Copy( s, 6, length( s));
               Self.Caption := 'Interim reports for ' + s;
               infoFound := true;

               ImageType := itInterim;
             end;
           end
           else
           begin
             //next line should be
             //</big>30 June 2005<br>
             p := pos( '<br>', s);
             if p > 0 then
             begin
               s := Copy( s, 1, p -1);
               p := pos( '>', s);
               if p > 0 then
                 s := Copy( s, p + 1, length(s));

               Self.Caption := 'Interim reports for ' + s;
               infoFound := true;

               ImageType := itInterim;
             end;
           end;
         end;
      end;

      FPeriodKnown := InfoFound;
    finally
      CloseFile( inFile);
    end;
  finally
    fs.Free
  end;
end;

procedure TReportImage.SetCaption(aCaption: string);
begin
  FCaption := aCaption;
end;

procedure TfrmBillingDocReader.cbIncludeInterimReportsClick(Sender: TObject);
begin
  UserINI_Show_Interim_Reports := cbIncludeInterimReports.Checked;
  Loadreports(UserINI_Show_Interim_Reports);
end;

procedure TfrmBillingDocReader.cmbImagesDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
//custom draw the item so that we can load the real caption if necessary
//displaying the caption will force the period information to be loaded if it
//has not already been done
var
  ri : TReportImage;
begin
  ri := TReportImage( cmbImages.Items.Objects[ index]);

  cmbImages.canvas.fillrect(rect);  //This ensures the correct highlite color is used
  //This line draws the actual bitmap
  if ri.ImageType = itStatement then
    AppImages.Misc.Draw( cmbImages.Canvas, rect.left, rect.top + 2, 10);
  //This line writes the text after the bitmap
  cmbImages.canvas.textout( rect.left + AppImages.Misc.Width +  2 ,rect.top + 2, ri.Caption);
end;

function TfrmBillingDocReader.GetStatementIndex(dt: Integer): Integer;
var
  ri: TReportImage;
  i: Integer;
  S: string;
begin
  Result := -1;
  S := STATEMENT_TEXT + Date2Str(dt, 'dd') + ' ' + Trim(Date2str(dt, 'nnnnnnnnn')) + ' ' +  Date2Str(dt, 'yyyy');
  for i := 0 to Pred(cmbImages.Items.Count) do begin
     ri := TReportImage( cmbImages.Items.Objects[i]);

     if AnsiSameText(ri.Caption, S) then begin
        Result := i;
        Break;
     end;
  end;
end;

function TfrmBillingDocReader.IsStatementAvailable(dt: Integer): Boolean;
begin
  Result := GetStatementIndex(dt) > -1;
end;

procedure TfrmBillingDocReader.LoadReports(IncludeInterim: Boolean);
var
  i: integer;
  ri : TReportImage;
  Current: string;
begin
  //Save current
  Current := '';
  if (cmbImages.ItemIndex <> - 1)  then
    Current := cmbImages.Items[cmbImages.ItemIndex];
  //populate combo
  cmbImages.Clear;
  for i := 0 to ReportImagesList.Count - 1 do begin
    ri := ReportImagesList.ReportImageAt(i);
    if (Pos('INTERIM', UpperCase(ri.Caption)) > 0) then begin
      //Interim Reports
      if IncludeInterim then
        cmbImages.AddItem( ri.DiskID, ri);
    end else
      cmbImages.AddItem( ri.DiskID, ri);
  end;
  //Select a report
  if Current <> '' then
    cmbImages.ItemIndex := cmbImages.Items.IndexOf(Current);
  if (cmbImages.ItemIndex = - 1) and (cmbImages.Items.Count > 0) then
    cmbImages.ItemIndex := 0;
end;

procedure TfrmBillingDocReader.ShowStatement(dt: Integer);
var
  i: Integer;
begin
  i := GetStatementIndex(dt);
  if i > -1 then
  begin
    cmbImages.ItemIndex := i;
    btnPDFClick(Self);
  end;
end;

end.
