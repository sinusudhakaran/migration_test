unit WPToPDFDlg;
{:: Utility dialog to create PDF files easily.
    Simply create it, assign the property 'EditBox', maybe load an image into 'BackgroundImage'
    and Show it }

{-$DEFINE PDFDEBUGMODE} // Create wPDF Debug Metafiles

{$DEFINE PRINTERREFERENCE} // If defined we use the printer as reference

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ShellAPI, StdCtrls, ComCtrls, ExtCtrls, WPPDFR1, WPRTEDefs, WPCtrMemo, WPRTEPaint, WPPDFWP,
  jpeg;

type
  TWPCreatePDF = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SaveDialog1: TSaveDialog;
    TabSheet1: TTabSheet;
    Image1: TImage;
    FileName: TEdit;
    Button3: TButton;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    EnableCompression: TCheckBox;
    ImageCompression: TComboBox;
    TabSheet2: TTabSheet;
    radSecurity: TRadioGroup;
    grpPasswords: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    OwnerPassword: TEdit;
    UserPassword: TEdit;
    grpEnable: TGroupBox;
    chkPrint: TCheckBox;
    chkLowRes: TCheckBox;
    chkCopy: TCheckBox;
    chkEdit: TCheckBox;
    AutoLaunch: TCheckBox;
    EmbedFonts: TCheckBox;
    EncodeASCI85: TCheckBox;
    TabSheet3: TTabSheet;
    Button4: TButton;
    Image2: TImage;
    Bevel1: TBevel;
    RadioGroup2: TRadioGroup;
    SubsetsOnly: TCheckBox;
    Messages: TComboBox;
    BackgroundImage: TImage;
    procedure Label2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    BackgroundImageHandle : Integer;
    procedure DoError(Sender : TObject; num : Integer; str : String);
  public
    EditBox : TWPCustomRtfEdit;
    procedure AfterPage(Sender: TObject; Number, FromPos, Length: Integer);
    procedure BeforePage(Sender: TObject; Number, FromPos, Length: Integer);
  end;

var
  WPCreatePDF: TWPCreatePDF;

implementation

{$R *.dfm}

procedure TWPCreatePDF.Label2Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://www.wptools.de/', '', '', SW_SHOW);
end;

procedure TWPCreatePDF.Button3Click(Sender: TObject);
begin
   if SaveDialog1.Execute then FileName.Text := SaveDialog1.FileName;
end;

procedure TWPCreatePDF.BeforePage(Sender: TObject; Number, FromPos, Length: Integer);
var wPDF : TWPPDFExport;
begin
  wPDF := (Sender as TWPPDFExport);
  if BackgroundImage.Picture.Graphic<>nil then // BackgroundImage is a global TImage
  begin
      if BackgroundImageHandle<=0 then // BackgroundImageHandle is a global var
         BackgroundImageHandle := wPDF.DrawTGraphic(0,0,
            MulDiv( EditBox.Header.PageWidth, EditBox.Memo.CurrentXPixelsPerInch, 1440),
            MulDiv( EditBox.Header.PageHeight, EditBox.Memo.CurrentYPixelsPerInch, 1440),
            BackgroundImage.Picture.Graphic
            )
      else  wPDF.DrawBitmapClone(0,0,
            MulDiv( EditBox.Header.PageWidth, EditBox.Memo.CurrentXPixelsPerInch, 1440),
            MulDiv( EditBox.Header.PageHeight, EditBox.Memo.CurrentYPixelsPerInch, 1440),
            BackgroundImageHandle
            );
  end;
end;


procedure TWPCreatePDF.AfterPage(Sender: TObject; Number, FromPos, Length: Integer);
{$IFNDEF WPTOOLSAD}
begin

end;
{$ELSE} // Print our link on each page ...
var wPDF : TWPPDFExport;
    s,l : string;
    r : Integer;
    re : TRect;
begin
   wPDF := (Sender as TWPPDFExport);  
   s := 'Created by wPDF © WPCubed GmbH: www.wptools.de';
   l := 'http://www.wpcubed.com/products/wpdf/index.htm';
   r := wPDF.YPixelsPerInch;
   wPDF.Canvas.Font.Name := 'Courier New';
   wPDF.Canvas.Font.Color := clBlue;
   wPDF.Canvas.Brush.Style := bsClear;
   wPDF.Canvas.Font.Height := -MulDiv(60,r,600);
   wPDF.Canvas.TextOut(MulDiv(54,r,600),MulDiv(150,r,600),s);
   re.Left := MulDiv(50,r,600);
   re.Top := MulDiv(150,r,600);
   re.Right := MulDiv(58,r,600) + wPDF.Canvas.TextWidth(s);
   re.Bottom := MulDiv(215,r,600);
   WPWriteComment(wPDF.Canvas.Handle, 501, re,l );
   wPDF.Canvas.Pen.Width := 1;
   wPDF.Canvas.Pen.Color := clBlue;
   wPDF.Canvas.Rectangle(re.Left, re.Top, re.Right, re.Bottom);
end;
{$ENDIF}

procedure TWPCreatePDF.DoError(Sender : TObject; num : Integer; str : String);
begin
   Messages.Items.Add(IntToStr(num) +':' + str);
   Messages.ItemIndex := Messages.Items.Count-1;
end;

procedure TWPCreatePDF.Button1Click(Sender: TObject);
var pdf : TWPPDFExport; uh : Boolean;
begin
  BackgroundImageHandle := -1;
  Messages.Items.Clear;
  Messages.Items.Add('Messages');
  if EditBox=nil then raise Exception.Create('Property "EditBox" not assigned!')
  else
  begin
  pdf := TWPPDFExport.Create(nil);
  {$IFDEF PDFDEBUGMODE}
  pdf.DebugMode := TRUE;
  {$ENDIF}

  {$IFDEF PRINTERREFERENCE}
  pdf.CanvasReference := wprefPrinter;
  {$ENDIF}
                                    
  pdf.Source := EditBox;
  pdf.AutoLaunch := AutoLaunch.Checked;
  if EnableCompression.Checked then
        pdf.CompressStreamMethod := wpCompressFlate
  else  pdf.CompressStreamMethod := wpCompressNone;

  if Messages.Visible then
     pdf.OnError := DoError;

  case ImageCompression.ItemIndex of
   1 : pdf.JPEGQuality := wpJPEG_10;
   2 : pdf.JPEGQuality := wpJPEG_25;
   3 : pdf.JPEGQuality := wpJPEG_50;
   4 : pdf.JPEGQuality := wpJPEG_75;
   else pdf.JPEGQuality := wpNoJPEG;
  end;

  if EmbedFonts.Checked then
  begin
     if SubsetsOnly.Checked then
          pdf.FontMode := wpEmbedSubsetTrueType_UsedChar
     else pdf.FontMode := wpEmbedTrueTypeFonts;
  end else pdf.FontMode := wpEmbedSymbolTrueTypeFonts;

  pdf.ExcludedFonts.Clear;
  pdf.ExcludedFonts.Add('Arial');
  pdf.ExcludedFonts.Add('Courier New');
  pdf.ExcludedFonts.Add('Times New Roman');
  pdf.ExcludedFonts.Add('TimesNewRoman');

  if EncodeASCI85.Checked then
       pdf.EncodeStreamMethod := wpASCII85Encode
  else pdf.EncodeStreamMethod := wpEncodeNone;

  case radSecurity.ItemIndex of
    0 : pdf.Encryption := [];
    1 :
    begin
      pdf.Security := wpp40bit;
      pdf.Encryption := [wpEncryptFile];
    end;
    2 :
    begin
      pdf.Security := wpp128bit;
      pdf.Encryption := [wpEncryptFile];
    end;
  end;

  if wpEncryptFile in pdf.Encryption then
  begin
     pdf.OwnerPassword := OwnerPassword.Text;
     pdf.UserPassword := UserPassword.Text;

     if chkLowRes.Checked then
         pdf.Encryption := pdf.Encryption +
                  [wpEnablePrinting,wpLowQualityPrintOnly]
     else if chkPrint.Checked then
         pdf.Encryption := pdf.Encryption +
                  [wpEnablePrinting];


    if chkCopy.Checked then
        pdf.Encryption := pdf.Encryption +
                  [wpEnableCopying];

    if chkEdit.Checked then
        pdf.Encryption := pdf.Encryption +
                  [wpEnableChanging];
  end;


  uh := EditBox.InsertPointAttr.Hidden;
  if not uh then EditBox.InsertPointAttr.Hidden := TRUE;
  try
    pdf.FileName := FileName.Text;
    pdf.OnAfterPrintPage := AfterPage;
    pdf.OnBeforePrintPage := BeforePage;
    pdf.Print;
  finally
    pdf.Free;
    if not uh then EditBox.InsertPointAttr.Hidden := uh;
  end;
  end;
end;

procedure TWPCreatePDF.FormShow(Sender: TObject);
begin
  if EditBox<>nil then
     FileName.Text := ChangeFileExt(EditBox.LastFileName, '.PDF');
end;

procedure TWPCreatePDF.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
