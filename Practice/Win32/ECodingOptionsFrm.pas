unit ECodingOptionsFrm;
//------------------------------------------------------------------------------
{
   Title:       

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ECodingExportFme, Buttons, ImgList, ComCtrls,
  OsFont;

type
  TfrmECodingOptions = class(TForm)
    Bevel1: TBevel;
    btnOk: TButton;
    btnCancel: TButton;
    ecExportOptions: TfmeECodingExport;
    procedure FormCreate(Sender: TObject);
    procedure ecExportOptionscmbWebFormatsChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
    FExportDestination: Byte;
   // procedure SetExportDestination(Value: Byte);
  public
    { Public declarations }
    procedure BrandDialog;
   
  end;

  function SetECodingOptions( var EcOptions : TEcOptions; Country : Byte; Destination: Byte; AccountingSystemUsed: Byte): boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  Software,
  ShellAPI,
  glConst,
  bkConst,
  Globals,
  ErrorMoreFrm,
  InfoMoreFrm,
  WebXOffice,
  bkxpThemes,
  ComboUtils,
  CountryUtils,
  WarningMoreFrm,
  bkProduct, bkBranding;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmECodingOptions.FormCreate(Sender: TObject);

begin
   bkXPThemes.ThemeForm( Self);

   //set up frame
   ecExportOptions.SetupDialog;


end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SetECodingOptions( var EcOptions : TEcOptions; Country : byte; Destination: Byte; AccountingSystemUsed: Byte) : boolean;
var

  WebXFile: string;
  S: TStrings;
begin
  Result := false;

  // If there is no WebXOffice installed then tell the user
  if (Destination = ecDestWebX)
  and (EcOptions.WebFormat = wfWebX) then
  begin
    WebXFile := WebXOffice.GetWebXDataPath;
    if (WebXFile = '') then
    begin
      HelpfulInfoMsg(WEBX_APP_NAME + ' Secure Client Manager does not appear to be installed on the workstation.' + #13#13 +
              'You must install the software before you can use this function.', 0);
      exit;
    end;
    WebXFile := WebXOffice.GetWebXDataPath + glConst.WEBX_FOLDERINFO_FILE;
    if not FileExists(WebXFile) then
    begin
      HelpfulInfoMsg('The ' + WEBX_APP_NAME + ' file listing the Secure Areas cannot be found. ' + #13 +
          'File: ' + WebXFile + #13#13 +
          'You must install the software before you can use this function.', 0);
      exit;
    end;
    S := TStringList.Create;
    try
      WebXOffice.ReadSecureAreas(S);
      if S.Count = 0 then
      begin
        HelpfulInfoMsg('There are no ' + WEBX_APP_NAME + ' Secure Areas set up. ' + #13#13 +
          'You must install the software before you can use this function.', 0);
        exit;
      end;
    finally
      S.Free;
    end;
  end;

  with TfrmECodingOptions.Create(Application.Mainform) do
  begin
    try
      //load options
     // ecExportOptions.chkIncludeJobs.Visible := Destination <> ecDestWebX; //needs to be done before ShowSuperFields so checkboxes are arranged correctly

      with ecExportOptions do begin
         ShowSuperFields(Software.CanUseSuperFundFields(Country, AccountingSystemUsed));
         ExportDestination := Destination;
         with chkShowGST do Caption := Localise( Country, Caption );
         SetOptions(ecOptions);
         BrandDialog;
         //set the enabled and check state of the boxes on the form
          UpdateControlsOnForm;
      end;

      if ShowModal = mrOK then
      begin
         ecExportOptions.GetOptions(ecOptions);
        Result := true;
      end;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmECodingOptions.btnOkClick(Sender: TObject);
begin
  if (FExportDestination <> ecDestWebX) and (not (ecExportOptions.edtPassword.Text = ecExportOptions.edtConfirm.Text)) then
  begin
    HelpfulWarningMsg('The passwords you have entered do not match. Please re-enter them.', 0);
    ecExportOptions.edtPassword.SetFocus;
  end
  else
    ModalResult := mrOk;
end;


procedure TfrmECodingOptions.BrandDialog;

begin
 
   if ecExportOptions.ExportDestination =  ecDestWebX then
       Caption := TProduct.Rebrand(TProduct.Rebrand(wfNames[ecExportOptions.WebExportFormat])) + ' Options'
   else
       Caption := TProduct.Rebrand(bkBranding.NotesProductName) + ' Options';
end;

procedure TfrmECodingOptions.ecExportOptionscmbWebFormatsChange(
  Sender: TObject);
begin
  BrandDialog;
end;

end.
