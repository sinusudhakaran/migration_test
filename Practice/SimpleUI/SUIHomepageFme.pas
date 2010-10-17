unit SUIHomepageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, BkExGlassButton, ClObj32, SimpleUIHomepageFrm;

type
  TfmeSUIHomepage = class(TFrame)
    gpButtonHolder: TGridPanel;
    gbtnRetrieve: tbkExGlassButton;
    gbtnCode: tbkExGlassButton;
    gbtnRunReports: tbkExGlassButton;
    gbtnBackup: tbkExGlassButton;
    gbtnFinished: tbkExGlassButton;
    gbtnMore: tbkExGlassButton;
    imgTick: TImage;
    procedure gbtnRetrieveClick(Sender: TObject);
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gbtnMoreClick(Sender: TObject);
    procedure gbtnRunReportsClick(Sender: TObject);
    procedure gbtnCodeClick(Sender: TObject);
    procedure gbtnBackupClick(Sender: TObject);
    procedure gbtnFinishedClick(Sender: TObject);
  private
    { Private declarations }
    HomePage : TfrmSimpleUIHomePage;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent) ; override;
    procedure RefreshStatus;
    procedure InitFrame;
  end;

implementation
uses
  bkDateUtils,
  stDateSt,
  SUIFrameHelper, ClientHomepageFrm, bkConst;

{$R *.dfm}


constructor TfmeSUIHomepage.Create(AOwner: TComponent);
begin
  inherited;
  SUIFrameHelper.InitButtonsOnGridPanel(gpButtonHolder,
                                        CommonButtonKeyUp,
                                        nil,
                                        ImgTick.Picture,
                                        150,
                                        50,
                                        5,
                                        40,
                                        11);
  Homepage := TfrmSimpleUIHomePage(TPanel(AOwner).Parent);

  //resize buttons to include caption

end;

procedure TfmeSUIHomepage.CommonButtonKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if Key = VK_RIGHT then
   begin
     Key := 0;
     //force app to move to next items in tab order
     Self.SelectNext(TWinControl(Sender),true,true);
   end;

   if Key = VK_LEFT then
   begin
     Key := 0;
     //force app to move to next items in tab order
     Self.SelectNext(TWinControl(Sender),false,true);
   end;
end;

procedure TfmeSUIHomepage.gbtnBackupClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcOffsiteBackup);
end;

procedure TfmeSUIHomepage.gbtnCodeClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCodingCurrent);
end;

procedure TfmeSUIHomepage.gbtnFinishedClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcFinished);
end;

procedure TfmeSUIHomepage.gbtnMoreClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiMorepage);
end;

procedure TfmeSUIHomepage.gbtnRetrieveClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcRetrieveData);
end;


procedure TfmeSUIHomepage.gbtnRunReportsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiStdReportsPage);
end;

procedure TfmeSUIHomepage.InitFrame;
var
  RetrieveAvailable : boolean;
  c : TClientObj;
begin
   if Assigned( Homepage) then
     c := Homepage.ReadCurrentClient
   else
     c := nil;

  //if the retreive button should not be shown then need to reorder the grid
  if Assigned( c) then
  begin
      RetrieveAvailable := (not c.clFields.clFile_Read_Only) and
                           (c.clFields.clDownload_From = dlBankLinkConnect);
      //turn off the retrieve button and reflow the buttons in the control
      if not RetrieveAvailable then
      begin
         //remove all items and reload
         gBtnRetrieve.Parent := nil;
         gbtnCode.Parent := nil;
         gBtnRunReports.Parent := nil;
         gbtnBackup.Parent := nil;
         gbtnFinished.Parent := nil;
         gbtnMore.Parent := nil;

         gbtnCode.Parent := gpButtonHolder;
         gBtnRunReports.Parent := gpButtonHolder;
         gbtnBackup.Parent := gpButtonHolder;
         gbtnFinished.Parent := gpButtonHolder;
         gbtnMore.Parent := gpButtonHolder;
         gBtnRetrieve.Parent := gpButtonHolder;
         gbtnRetrieve.Visible := false;

         gbtnCode.ButtonCaption := '1. Code statements';
         gbtnRunReports.ButtonCaption := '2. Run reports...';
         gbtnBackup.ButtonCaption := '3. Backup';
         gbtnFinished.ButtonCaption := '4. Finished';
      end;
      //now update button captions etc
      RefreshStatus;
  end;
end;

procedure TfmeSUIHomepage.RefreshStatus;
var
  LastTD : integer;
  c : TClientObj;
  s : string;

  DownloadingDone,
  CodingDone,
  ReportsDone,
  BackupDone : boolean;
  BackupNeeded : boolean;
begin
   if Assigned( Homepage) then
     c := Homepage.ReadCurrentClient
   else
     c := nil;

   //DownloadingDone := false;
   //BackupDone := false;
   CodingDone := false;
   ReportsDone := false;

   if Assigned(C) then
   begin
     //retrieve button status
     //show tick if day up to last day of month or data in next month
     //caption : Downloaded transaction up to dd/mm/yy
     LastTD := Homepage.LastDownloadTransDate;
     if (LastTD < c.clExtra.ceSUI_Period_End) then
       s := 'Transactions downloaded up to ' + bkDate2Str( LastTD)
     else
       s := '';

     //downloading is done if we have a transaction on or later than the end of period
     DownloadingDone := ( LastTD >= c.clExtra.ceSUI_Period_End);

     gBtnRetrieve.LabelCaption := s;
     gBtnRetrieve.LabelVisible := (s <> '');
     gBtnRetrieve.ImageVisible :=  DownloadingDone;

     //update global var
     c.clExtra.ceSUI_Step_Done[ sui_Retrieve] := DownloadingDone;


     //coding form status
     //show tick if everything coded for period
     //caption: x accounts need coding
     s := '';
     if Homepage.TransInCurrentPeriodCount > 0 then
     begin
       gbtnCode.Enabled := true;
       if Homepage.NumStatementsToCode > 0 then
       begin
         gbtnCode.ImageVisible := false;
         if (Homepage.NumStatementsToCode = 1) then
           s := '1 statement needs coding'
         else
           s := IntToStr( Homepage.NumStatementsToCode) + ' statements need coding';
       end
       else
         CodingDone := true;
     end
     else
     begin
       //no transactions in this period
       gbtnCode.Enabled := false;
       s := '';

       //see if retrieve is done, this indications no transaction this month
       CodingDone := DownloadingDone;
     end;
     gbtnCode.ImageVisible := CodingDone;
     gbtnCode.LabelCaption := s;
     gbtnCode.LabelVisible := s <> '';

     //see if coding was done and now it isnt, this would indication more transactions downloaded
     //or a chart code deleted
     if (c.clExtra.ceSUI_Step_Done[ sui_Coded]) and (not CodingDone) then
     begin
       //force reports done to be cleared
       c.clExtra.ceSUI_Step_Done[ sui_ReportsRun] := false;
       c.clExtra.ceSUI_Step_Done[ sui_BackupDone] := false;
     end;

     c.clExtra.ceSUI_Step_Done[ sui_Coded] := CodingDone;

     //reports run
     //show tick if Status flag is set (needs to be set in reports)
     s := '';
     if CodingDone  then
     begin
        gbtnRunReports.Enabled := true;
        ReportsDone := c.clExtra.ceSUI_Step_Done[ sui_ReportsRun];
        if not ReportsDone then
          s := 'Reports need to be run';
     end
     else
     begin
       gbtnRunReports.Enabled := false;
       c.clExtra.ceSUI_Step_Done[ sui_ReportsRun] := false;
       s := '';
     end;
     gbtnRunReports.ImageVisible := ReportsDone;
     gbtnRunReports.LabelCaption := s;
     gbtnRunReports.LabelVisible := s <> '';

     //backup
     //show tick if backup done this session
     //caption: Last backup time
     BackupNeeded := c.clFields.clCRC_at_Last_Save <> c.clFields.clTemp_CRC_at_Last_Backup;
     if BackupNeeded then
       BackupDone := false
     else
       BackupDone := (c.clExtra.ceSUI_Step_Done[ sui_BackupDone]);

     {s := '';
     if Homepage.LastBackupDateTime <> 0 then
       s := 'Last Backed up at ' + TimeToStr(Homepage.LastBackupDateTime);
     if (CodingDone and ReportsDone) and (not BackupDone) then
       s := 'Backup needed';
       gbtnBackup.LabelCaption := s;
       gbtnBackup.LabelVisible := s <> '';
     }

     gbtnBackup.ImageVisible := BackupDone and ReportsDone and CodingDone;
     c.clExtra.ceSUI_Step_Done[ sui_BackupDone] := BackupDone;

     //finished
     //if status flags for other three are true??
   end
   else
   begin
     gBtnRetrieve.ImageVisible := false;
     gbtnCode.ImageVisible := false;
     gBtnRunReports.ImageVisible := false;
     gbtnBackup.ImageVisible := false;

     gBtnRetrieve.LabelVisible := false;
     gbtnCode.LabelVisible := false;
     gBtnRunReports.LabelVisible := false;
     gbtnBackup.LabelVisible := false;
   end;
end;

end.
