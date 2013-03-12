unit ImportFromECodingDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, clObj32,
  OSFont;

type
  TdlgImportBNotes = class(TForm)
    pnlSave: TPanel;
    Label6: TLabel;
    btnToFolder: TSpeedButton;
    edtFrom: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    OpenDialog: TOpenDialog;
    Panel2: TPanel;
    chkShowExample: TCheckBox;
    chkFillNarration: TCheckBox;
    rbPayee: TRadioButton;
    rbNotes: TRadioButton;
    rbBoth: TRadioButton;
    Panel1: TPanel;
    lblIfNarration: TLabel;
    rbReplace: TRadioButton;
    rbNothing: TRadioButton;
    Bevel2: TBevel;
    pnlExample: TPanel;
    Shape1: TShape;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    lblNewNarration1: TLabel;
    lblEcodingNotes2: TLabel;
    lblEcodingNotes1: TLabel;
    lblEcodingPayee2: TLabel;
    lblNewNarration2: TLabel;
    Bevel1: TBevel;
    lblExisting2: TLabel;
    Bevel3: TBevel;
    Shape2: TShape;
    rbAppend: TRadioButton;

    procedure btnToFolderClick(Sender: TObject);
    procedure rbClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkShowExampleClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtFromChange(Sender: TObject);
  private
    { Private declarations }
    ForClient: TClientObj;
    FImportDestination: Byte;
    procedure SetImportDestination(Value: Byte);
  public
    { Public declarations }
    property ImportDestination: Byte read FImportDestination write SetImportDestination;
  end;

  function GetEcodingImportOptions( const aClient : TClientObj; var FromFilename : string; Destination: Byte ) : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  bkXPThemes,
  glConst,
  GlobalDirectories,
  WarningMoreFrm,
  BKCONST;

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportBNotes.btnToFolderClick(Sender: TObject);
var
   sDefaultDir : string;
   sDefaultFilename : string;
begin
   //prompt user for a filename

   //specify default filename
   sDefaultDir := ExtractFilePath( edtFrom.Text);
   sDefaultFilename := ExtractFilename( edtFrom.Text);

   OpenDialog.InitialDir := sDefaultDir;
   OpenDialog.Filename := sDefaultFilename;

   if OpenDialog.Execute then
      edtFrom.text := OpenDialog.Filename;

   //make sure all relative paths are relative to data dir after browse
   SysUtils.SetCurrentDir( GlobalDirectories.glDataDir);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportBNotes.rbClick(Sender: TObject);
//update the example
var
   s1 , s2 : string;
begin
   s1 := '';
   s2 := lblExisting2.caption;

   try
      rbNotes.enabled   := chkFillNarration.checked;
      rbPayee.enabled   := chkFillNarration.checked;
      rbBoth.enabled   := chkFillNarration.checked;
      lblIfNarration.enabled   := chkFillNarration.checked;
      rbReplace.enabled   := chkFillNarration.checked;
      rbNothing.enabled   := chkFillNarration.checked;
      rbAppend.enabled    := chkFillNarration.checked;

      if not chkFillNarration.checked then begin
         exit;
      end;

      if rbNotes.checked then begin
         s1 := lblEcodingNotes1.caption;
         s2 := lblEcodingNotes2.caption;
      end;

      if rbPayee.checked then begin
         s1 := '';
         s2 := lblEcodingPayee2.caption;
      end;

      if rbBoth.checked then begin
         s1 := '';
         s2 := lblEcodingPayee2.caption;

         if s1 = '' then
            s1 := lblEcodingNotes1.caption
         else
            s1 := s1 + ' : ' + lblEcodingNotes1.caption;

         if s2 = '' then
            s2 := lblEcodingNotes2.caption
         else
            s2 := s2 + ' : ' + lblEcodingNotes2.caption;
      end;

      if rbNothing.checked then begin
         if lblExisting2.caption <> '' then s2 := lblExisting2.caption;
      end;       

      if rbAppend.checked then
      begin
         if lblExisting2.caption <> '' then s2 := lblExisting2.caption + ' : ' + s2;
      end;

   finally
      lblNewNarration1.caption := S1;
      lblNewNarration2.caption := S2;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportBNotes.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);

   OpenDialog.Options := [ ofFileMustExist,
                           ofEnableSizing,
                           ofHideReadOnly];

   ImportDestination := ecDestFile; // Default
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportBNotes.chkShowExampleClick(Sender: TObject);
begin
   pnlExample.visible := chkShowExample.checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportBNotes.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   if ModalResult = mrOK then begin
     CanClose := false;

     if ( ExtractFileName( edtFrom.Text ) = '' ) then begin
        if ImportDestination = ecDestWebX then
          case ForClient.clFields.clWeb_Export_Format of
             wfWebX :  HelpfulWarningMsg('You must specify a file name to import the ' + glConst.WEBX_GENERIC_APP_NAME + ' file from.',0)
             else CanClose := True;
          end


        else
          HelpfulWarningMsg('You must specify a file name to import the ' + glConst.ECODING_APP_NAME + ' file from.',0);
        exit;
     end;

     CanClose := true;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetEcodingImportOptions( const aClient : TClientObj; var FromFilename : string; Destination: Byte) : boolean;
var
  ImportBNotes : TdlgImportBNotes;
begin
   result := false;

   ImportBNotes := TdlgImportBNotes.Create(Application.Mainform);
   with ImportBNotes do begin
     try
       if Destination = ecDestWebX then
          case aClient.clFields.clWeb_Export_Format of
             wfWebX :  BKHelpSetUp(ImportBNotes, BKH_Importing_transactions_from_CCH_WebPractice_to_BankLink)
             else BKHelpSetUp(ImportBNotes, BKH_Importing_transactions_from_CCH_WebPractice_to_BankLink)
          end
       else
         BKHelpSetUp(ImportBNotes, BKH_Importing_a_BNotes_file_into_BankLink);

        ForClient := aClient;
        
        ImportDestination := Destination;

        edtFrom.Text := FromFilename;

        if (aClient.clFields.clECoding_Import_Options and noDontFill) = noDontFill then
           chkFillNarration.checked := false
        else begin
           chkFillNarration.checked := true;

           rbNotes.checked := (aClient.clFields.clECoding_Import_Options and noFillWithNotes) = noFillWithNotes;
           rbPayee.checked := (aClient.clFields.clECoding_Import_Options and noFillWithPayeeName) = noFillWithPayeeName;
           rbBoth.checked  := (aClient.clFields.clECoding_Import_Options and noFillWithBoth) = noFillWithBoth;

           rbNothing.checked := (aClient.clFields.clECoding_Import_Options and noDontOverwrite) = noDontOverwrite;
           rbAppend.checked  := (aClient.clFields.clECoding_Import_Options and noAppend) = noAppend;
        end;

        chkShowExample.checked := not ((aClient.clFields.clECoding_Import_Options and noHideExample) = noHideExample);

        //force the example to be updated
        rbClick( nil);

        if ShowModal = mrOK then begin
           FromFilename := edtFrom.Text;

           //set options
           aClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
           if not chkFillNarration.checked then
              aClient.clFields.clECoding_Import_Options := noDontFill
           else begin
              if rbNotes.checked then aClient.clFields.clECoding_Import_Options := noFillWithNotes;
              if rbBoth.checked  then aClient.clFields.clECoding_Import_Options := noFillWithBoth;
              if rbNothing.checked then aClient.clFields.clECoding_Import_Options := aClient.clFields.clECoding_Import_Options or noDontOverwrite;
              if rbAppend.checked then
                aClient.clFields.clECoding_Import_Options := aClient.clFields.clECoding_Import_Options or noAppend;
           end;
           if not chkShowExample.checked then aClient.clFields.clECoding_Import_Options := aClient.clFields.clECoding_Import_Options or noHideExample;

           result := true;
        end;
     finally
        Free;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgImportBNotes.edtFromChange(Sender: TObject);
begin
   edtFrom.Hint := edtFrom.text;
end;

// Set up UI as required
procedure TdlgImportBNotes.SetImportDestination(Value: Byte);
begin
  if Value = ecDestWebX then
  begin
     if ForClient.clFields.clWeb_Export_Format = 255 then
        ForClient.clFields.clWeb_Export_Format := wfdefault;

     Self.caption := 'Import ' + wfNames[ForClient.clFields.clWeb_Export_Format] + ' File';
     case ForClient.clFields.clWeb_Export_Format of
        wfWebX : begin
            label2.caption := glConst.WEBX_GENERIC_APP_NAME + ' Payee';
            label5.caption := glConst.WEBX_GENERIC_APP_NAME + ' Notes';
            OpenDialog.Filter := glConst.WEBX_GENERIC_APP_NAME + ' file (*.' +
                         glConst.WEBX_IMPORT_EXTN + ')|*.' +
                         glConst.WEBX_IMPORT_EXTN + '|' +
                          'All files (*.*)|*.*';
            OpenDialog.DefaultExt := glConst.WEBX_IMPORT_EXTN;
            OpenDialog.Title   := 'Import from ' + glConst.WEBX_GENERIC_APP_NAME + ' File';
        end;
        wfWebNotes : begin
            label2.caption := glConst.ECODING_APP_NAME + ' Payee';
            label5.caption := 'Notes';
            btnToFolder.Visible := false;
            label6.Caption := 'File';
            EdtFrom.Enabled := false;
        end;    
     end;

  end
  else
  begin
    Self.caption := 'Import from ' + glConst.ECODING_APP_NAME + ' file';
    label2.caption := glConst.ECODING_APP_NAME + ' Payee';
    label5.caption := 'Notes';
    OpenDialog.Filter := glConst.ECODING_APP_NAME + ' file (*.' +
                         glConst.ECODING_DEFAULT_EXTN + ')|*.' +
                         glConst.ECODING_DEFAULT_EXTN + '|' +
                         'All files (*.*)|*.*';
    OpenDialog.DefaultExt := glConst.ECODING_DEFAULT_EXTN;
    OpenDialog.Title   := 'Import ' + glConst.ECODING_APP_NAME + ' file';
  end;
  FImportDestination := Value;
end;

end.
