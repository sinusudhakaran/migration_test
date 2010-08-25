unit WPPDFPRP;

interface

{$I wpdf_inc.inc} // use it with: {$IFDEF WPDF_SOURCE} ,WPPDFR1_src {$ELSE} ,WPPDFR1 {$ENDIF}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls
  {$IFDEF WPDF_SOURCE} ,WPPDFR1_src {$ELSE} ,WPPDFR1 {$ENDIF}
  {$IFNDEF INTWPSWITCH}, WPT2PDFDLL
  {$IFDEF PDFIMPORT}, WPDFRead{$ENDIF}{$ENDIF};

type
{$IFNDEF T2H}
  TWPPDFPropertyForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    CompressionGroup: TRadioGroup;
    EncodeGroup: TRadioGroup;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label4: TLabel;
    Edit1: TEdit;
    TabSheet3: TTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    PageMode: TComboBox;
    Label1: TLabel;
    Label11: TLabel;
    FontMode: TComboBox;
    ConvJPEG: TCheckBox;
    TabSheet4: TTabSheet;
    GroupBox1: TGroupBox;
    EncryptOpt4: TCheckBox;
    EncryptOpt3: TCheckBox;
    EncryptOpt2: TCheckBox;
    EncryptOpt1: TCheckBox;
    Label14: TLabel;
    UserPW: TEdit;
    OwnerPW: TEdit;
    Label13: TLabel;
    EncryptIt: TCheckBox;
    TabSheet2: TTabSheet;
    InputPDF: TEdit;
    Label2: TLabel;
    InputPDFMode: TRadioGroup;
    Button4: TButton;
    Button5: TButton;
    HighSecurity: TCheckBox;
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    WPPDFExport1 : TWPCustomPDFExport;
  end;
{$ENDIF}

  TWPPDFProperties = class(TComponent)
  private
     FWPPDFExport : TWPCustomPDFExport;
     FShowStartButton : Boolean;
  public
     function Execute : Boolean;
  published
     property PDFPrinter : TWPCustomPDFExport read FWPPDFExport write FWPPDFExport;
     property ShowStartButton : Boolean read FShowStartButton write FShowStartButton;
  end;

implementation

{$R *.DFM}

function TWPPDFProperties.Execute : Boolean;
var dia : TWPPDFPropertyForm;
begin
   dia := nil;
   if FWPPDFExport=nil then
         raise Exception.Create('PDFPrinter was not assigned')
   else
   try
      dia := TWPPDFPropertyForm.Create(nil);
      dia.WPPDFExport1 := FWPPDFExport;
      if FShowStartButton then
           dia.Button4.Caption := 'Start'
      else dia.Button4.Caption := 'OK';
      Result := dia.ShowModal=mrOK;
   finally
      dia.Free;
   end;
end;

procedure TWPPDFPropertyForm.Button4Click(Sender: TObject);
begin
  if WPPDFExport1<>nil then
  begin
   WPPDFExport1.ConvertJPEGData := ConvJPEG.Checked;
   WPPDFExport1.Filename := Edit1.Text;
   WPPDFExport1.Info.Producer := Edit3.Text;
   WPPDFExport1.Info.Author   := Edit4.Text;
   WPPDFExport1.Info.Title    := Edit5.Text;
   WPPDFExport1.Info.Subject  := Edit6.Text;
   WPPDFExport1.Info.Keywords := Edit7.Text;
   WPPDFExport1.Info.Date := Date; // now

   case CompressionGroup.ItemIndex of
     0   : WPPDFExport1.CompressStreamMethod := wpCompressNone;
     1   : WPPDFExport1.CompressStreamMethod := wpCompressRunlength;
     2   : WPPDFExport1.CompressStreamMethod := wpCompressFlate;
     3   : WPPDFExport1.CompressStreamMethod := wpCompressFastFlate;
   end;

   if HighSecurity.Checked then
         WPPDFExport1.Security := wpp128bit
   else  WPPDFExport1.Security := wpp40bit;

   // was: WPPDFExport1.CompressStreamMethod := TWPCompressStreamMethod(CompressionGroup.ItemIndex);
   WPPDFExport1.EncodeStreamMethod := TWPEncodeStreamMethod(EncodeGroup.ItemIndex);
   WPPDFExport1.CreateThumbnails := CheckBox1.Checked;
   WPPDFExport1.CreateOutlines := CheckBox2.Checked;
   WPPDFExport1.PageMode := TWPPDFPageModes(PageMode.ItemIndex);
   WPPDFExport1.FontMode := TWPPDFFontMode(FontMode.ItemIndex);
   // Encryption
   if not EncryptIt.Checked then WPPDFExport1.Encryption := [] else
   begin
     WPPDFExport1.Encryption := [wpEncryptFile];
     if EncryptOpt1.Checked then
       WPPDFExport1.Encryption := WPPDFExport1.Encryption + [wpEnablePrinting];
     if EncryptOpt2.Checked then
       WPPDFExport1.Encryption := WPPDFExport1.Encryption + [wpEnableCopying];
     if EncryptOpt3.Checked then
       WPPDFExport1.Encryption := WPPDFExport1.Encryption + [wpEnableChanging];
     if EncryptOpt4.Checked then
       WPPDFExport1.Encryption  := WPPDFExport1.Encryption + [wpEnableForms];
     WPPDFExport1.UserPassword  := UserPW.Text;
     WPPDFExport1.OwnerPassword := OwnerPW.Text;
   end;
   // Use PDF Files
   WPPDFExport1.InputfileMode := TWPPDFInputfileMode(InputPDFMode.ItemIndex);
   WPPDFExport1.Inputfile := InputPDF.Text;
  end;
  ModalResult := mrOK;
end;

procedure TWPPDFPropertyForm.Button5Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TWPPDFPropertyForm.FormShow(Sender: TObject);
begin
  if WPPDFExport1<>nil then
  begin
     // Only available for WPTools ---------------------------------------------
     if CompareText(WPPDFExport1.ClassName,'TWPPDFExport')=0 then
     begin
        ConvJPEG.Visible := TRUE;
        CheckBox2.Visible := TRUE;
     end;
     // Other options ----------------------------------------------------------
     ConvJPEG.Checked := WPPDFExport1.ConvertJPEGData;
     Edit1.Text := WPPDFExport1.Filename;
     Edit3.Text := WPPDFExport1.Info.Producer;
     Edit4.Text := WPPDFExport1.Info.Author;
     Edit5.Text := WPPDFExport1.Info.Title;
     Edit6.Text := WPPDFExport1.Info.Subject;
     Edit7.Text := WPPDFExport1.Info.Keywords;

     case WPPDFExport1.CompressStreamMethod of
         wpCompressNone : CompressionGroup.ItemIndex := 0;
         wpCompressFlate: CompressionGroup.ItemIndex := 2;
         wpCompressRunlength : CompressionGroup.ItemIndex :=1;
         wpCompressFastFlate : CompressionGroup.ItemIndex :=3;
     end;

     EncodeGroup.ItemIndex := Integer(WPPDFExport1.EncodeStreamMethod);
     CheckBox1.Checked := WPPDFExport1.CreateThumbnails;
     CheckBox2.Checked := WPPDFExport1.CreateOutlines;
     PageMode.ItemIndex := Integer(WPPDFExport1.PageMode);
     FontMode.ItemIndex := Integer(WPPDFExport1.FontMode);

     HighSecurity.Checked := WPPDFExport1.Security = wpp128bit;

     EncryptIt.Checked := wpEncryptFile in WPPDFExport1.Encryption;
     EncryptOpt1.Checked  := wpEnablePrinting in WPPDFExport1.Encryption;
     EncryptOpt2.Checked  := wpEnableCopying in WPPDFExport1.Encryption;
     EncryptOpt3.Checked  := wpEnableChanging in WPPDFExport1.Encryption;
     EncryptOpt4.Checked  := wpEnableForms in WPPDFExport1.Encryption;
     UserPW.Text := WPPDFExport1.UserPassword;
     OwnerPW.Text := WPPDFExport1.OwnerPassword;
     InputPDFMode.ItemIndex := Integer(WPPDFExport1.InputfileMode);
     InputPDF.Text := WPPDFExport1.Inputfile;
  end;
end;


end.
