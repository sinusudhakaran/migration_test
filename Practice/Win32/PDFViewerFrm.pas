unit PDFViewerFrm;

interface

uses
  Windows, ReportDefs, SysUtils, Classes, Controls, Forms,
  imagesfrm, WPViewPDF1, StdCtrls, ComCtrls, ToolWin;

type
  TMultiDoc = (OneDoc,TwoDocs,MoreDocs);

  TOnPrintProc = procedure (const Destination: TReportDest) of object;
type
  TPDFViewFrm = class(TForm)
    StatusBar1: TStatusBar;
    tbarPreview: TToolBar;
    tbDoSetup: TToolButton;
    tbDoPrint: TToolButton;
    tbSep1: TToolButton;
    tbPage: TToolButton;
    tbWhole: TToolButton;
    cmbZoom: TComboBox;
    tbSep2: TToolButton;
    tbClose: TToolButton;
    tbarPage: TToolBar;
    tbFirst: TToolButton;
    tbPrev: TToolButton;
    tbNext: TToolButton;
    tbLast: TToolButton;
    PDFViewer: TWPViewPDF;
    tbEmail: TToolButton;
    tbSep3: TToolButton;
    procedure tbFirstClick(Sender: TObject);
    procedure tbPrevClick(Sender: TObject);
    procedure tbNextClick(Sender: TObject);
    procedure tbLastClick(Sender: TObject);
    procedure tbDoSetupClick(Sender: TObject);
    procedure tbDoPrintClick(Sender: TObject);
    procedure tbPageClick(Sender: TObject);
    procedure cmbZoomChange(Sender: TObject);
    procedure tbWholeClick(Sender: TObject);
    procedure tbCloseClick(Sender: TObject);
    procedure PDFViewerChangeViewPage(Sender: TObject; const PageNr: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbEmailClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cmbZoomKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmbZoomKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure PDFViewerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    FFileList: TStringList;
    cmbTyping  : boolean;
    FOnPrint: TOnPrintProc;
    FPDFMemoryStream: TMemoryStream;
    procedure SetFileList(const Value: TStringList);
    procedure Status(Value: string);
    function PageStatus(Page: Integer): string;
    procedure Zoom(Value: string); overload;
    procedure Zoom(Value: Integer); overload;
    procedure SetOnPrint(const Value: TOnPrintProc);
    procedure SetPDFMemoryStream(const Value: TMemoryStream);

    { Private declarations }
  protected
    procedure UpdateActions; override;
  public
    property FileList: TStringList read FFileList write SetFileList;
    property OnPrint: TOnPrintProc read FOnPrint write SetOnPrint;
    property PDFMemoryStream: TMemoryStream read FPDFMemoryStream write SetPDFMemoryStream;
    { Public declarations }
  end;


procedure ViewPDFFile(FileName: string);
procedure ViewPDFFileS(AList: TstringList);


implementation

uses
   //LogUtil,
   PDFViewCommands,
   Globals,
   MailFrm;

{$R *.dfm}

const
  PRWHOLEPAGE = 'Whole Page';
  PRWIDTH     = 'Page Width';
  PRPAGES     = '2 Pages';

procedure ViewPDFFile(FileName: string);
begin
   with TPDFViewFrm.Create(nil) do try
      FileList.Add(Filename);
      ShowModal;
   finally
      Free;
   end;
end;

procedure ViewPDFFileS(AList: Tstringlist);
begin
   with TPDFViewFrm.Create(nil) do try
      FileList := AList;
      ShowModal;
   finally
      Free;
   end;
end;



procedure TPDFViewFrm.cmbZoomChange(Sender: TObject);
begin
 if not cmbTyping then begin
      Zoom(cmbZoom.Text);
 end;
end;

procedure TPDFViewFrm.cmbZoomKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [ord('a').. ord('z'),
             ord('A').. ord('Z'),
             ord('0').. ord('9'),
             ord('%')] then
     cmbTyping := True;

end;

procedure TPDFViewFrm.cmbZoomKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   cmbTyping := false;
end;

procedure TPDFViewFrm.FormActivate(Sender: TObject);
var
  XPos, YPos: integer;
begin
  //9304 - Hack to get page control keys to work in the PDFViewer
  XPos := PDFViewer.Left + ((PDFViewer.BoundsRect.Right - PDFViewer.BoundsRect.Left) DIV 2);
  YPos := PDFViewer.Top + ((PDFViewer.BoundsRect.Bottom - PDFViewer.BoundsRect.Top) DIV 2);
  SetCursorPos(XPos, YPos);
  Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

procedure TPDFViewFrm.FormCreate(Sender: TObject);
begin
  cmbTyping := False;
  //WPPDFViewerStart('Jul', 'ED8TD8MEEDDERdR6T8', 50507);
  WPPDFViewerStart( 'BankLink', 'Gs9gdRbZaafhTEFuMG', 6945576 );
  FFileList:= TStringList.Create;
  PDFViewer.TabStop := true;
  //PDFViewer.Command(COMPDF_SetIgnoreRotation);
end;

procedure TPDFViewFrm.FormDestroy(Sender: TObject);
begin
  FFileList.Free;
end;

procedure TPDFViewFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case Key of
   VK_ESCAPE : begin
          Key := 0;
          ModalResult := mrCancel;
       end;

   VK_RETURN : begin
          Key := 0;
          if cmbZoom.Focused then
             Zoom(cmbZoom.text);
      end
   end;
end;

procedure TPDFViewFrm.FormShow(Sender: TObject);
var I, P: Integer;
    Rotate : Boolean;
begin
   if (FileList.Count = 0) and Assigned(PDFMemoryStream) then
     PDFViewer.LoadFromStream(PDFMemoryStream)
   else
     for I := 0 to FileList.Count - 1 do
       PDFViewer.AppendFromFile(FFileList[I]);

   PDFViewer.ViewOptions := [];
   PDFViewer.Command(COMPDF_ZoomFullWidth);

   PDFViewer.Command(COMPDF_PageSelectionInvert);
   Rotate := False;
   PDFViewer.Command(COMPDF_GotoFirst);
   for I := 0 to Pred(PDFViewer.PageCount) do begin
      P := PDFViewer.CommandEx(COMPDF_GetPageRotation,I );
      if {PDFViewer.CommandEX(COMPDF_GetPageRotation,I)} P = 0 then begin
          PDFViewer.CommandEx(COMPDF_PageSelectionDel,I);

      end else
         Rotate := True;
      PDFViewer.Command(COMPDF_GotoNext);
   end;
   if Rotate then
      PDFViewer.CommandEx(COMPDF_SetPageRotation,270 );

   PDFViewer.Command(COMPDF_PageSelectionClear);
   PDFViewer.Command(COMPDF_GotoFirst);
   cmbZoom.text := PRWIDTH;
end;

function TPDFViewFrm.PageStatus(Page: Integer): string;
begin
   Result := 'Page ' + IntToStr(Page) + ' of ' + InttoStr(PDFViewer.PageCount);
end;

procedure TPDFViewFrm.PDFViewerChangeViewPage(Sender: TObject; const PageNr: Integer);
var Zoom: Integer;
begin
  Status(PageStatus(PageNr));
  Zoom := PDFViewer.Command(COMPDF_Zoom);
  if Zoom <> 0 then
     cmbZoom.Text := IntToStr(Zoom) + '%';
end;

procedure TPDFViewFrm.PDFViewerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   FormKeyDown(Sender,Key,Shift);
end;

procedure TPDFViewFrm.SetFileList(const Value: TStringList);
begin
  FFileList.Assign (Value);
end;

procedure TPDFViewFrm.SetOnPrint(const Value: TOnPrintProc);
begin
  FOnPrint := Value;
end;

procedure TPDFViewFrm.SetPDFMemoryStream(const Value: TMemoryStream);
begin
  FPDFMemoryStream := Value;
end;

procedure TPDFViewFrm.Status(Value: string);
begin
  Statusbar1.SimpleText := Value;
end;

procedure TPDFViewFrm.tbCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TPDFViewFrm.tbDoPrintClick(Sender: TObject);
begin
   //PDFViewer.Command(COMPDF_Print);
   //Could use CurrUser flag
   //But default never set...
   PDFViewer.Command(COMPDF_PrintDialog);
   if Assigned(FOnPrint) then
       FOnPrint(rdPrinter);
end;

procedure TPDFViewFrm.tbDoSetupClick(Sender: TObject);
begin
  PDFViewer.Command(COMPDF_PrinterSetup);
end;

procedure TPDFViewFrm.tbEmailClick(Sender: TObject);
var EmailAddress: string;
begin
   if Assigned(MyClient) then
      EmailAddress := MyClient.clFields.clClient_EMail_Address
   else
      EmailAddress := '';

   if SendFilesTo('Reports',
               EmailAddress,
               'Reports',
               '',
               Filelist) then begin
      if Assigned(FOnPrint) then
          FOnPrint(rdEmail);
      // Have to reset these
      // Because we do not keep the files..
      Email_Saved := False;
      Email_To := '';
      Email_From := '';
      Email_Cc := '';
      Email_Body := '';
      Email_Attachments := '';
      Email_Subject := '';
      Email_Checkout_File := False;
   end;
end;

procedure TPDFViewFrm.tbFirstClick(Sender: TObject);
begin
   PDFViewer.Command(COMPDF_GotoFirst);
end;


procedure TPDFViewFrm.tbLastClick(Sender: TObject);
begin
   PDFViewer.Command(COMPDF_GotoLast);
end;


procedure TPDFViewFrm.tbNextClick(Sender: TObject);
begin
   PDFViewer.Command(COMPDF_GotoNext);
end;


procedure TPDFViewFrm.tbPageClick(Sender: TObject);
begin
   PDFViewer.Command(COMPDF_ZoomFullWidth);
end;

procedure TPDFViewFrm.tbPrevClick(Sender: TObject);
begin
   PDFViewer.Command(COMPDF_GotoPrev);
end;


procedure TPDFViewFrm.tbWholeClick(Sender: TObject);
begin
   PDFViewer.Command(COMPDF_ZoomFullPage);
end;



procedure TPDFViewFrm.UpdateActions;
begin
  inherited;
  tbEmail.Enabled := FileList.Count > 0;
end;

procedure TPDFViewFrm.Zoom(Value: Integer);
begin
   if(Value > 0 )
   and (Value < 2000) then begin
      PDFViewer.CommandEx(COMPDF_Zoom  ,Value);
      cmbZoom.SelectAll;
   end;
end;

procedure TPDFViewFrm.Zoom(Value: string);
var valErr,
    percent : integer;
begin
   if (Trim(Value) = '') then begin
      Value := '100';
   end;
   //check for text values
   if Sametext(Value, PRWIDTH) then begin
      PDFViewer.Command(COMPDF_ZoomFullWidth);
   end else
   if Sametext(Value, PRWHOLEPAGE) then begin
      PDFViewer.Command(COMPDF_ZoomFullPage);
   end else
   if Sametext(Value, PRPAGES) then begin
      PDFViewer.Command(COMPDF_ZoomTwoPages);
   end else begin

      //user has selected or typed a value
      if Value[length(Value)] = '%' then
         Value := Copy(Value,1,length(Value)-1);
      //check is numeric
      Val(Value,Percent,valErr);
      if ValErr = 0 then
        Zoom(percent);
   end;
end;

end.
