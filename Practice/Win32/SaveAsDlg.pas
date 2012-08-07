unit SaveAsDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  OSFont;

type
  TdlgSaveAs = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    eCode: TEdit;
    Label4: TLabel;
    eName: TEdit;
    lblCode: TLabel;
    Label2: TLabel;
    chkCheck: TCheckBox;

    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
    procedure SetUpHelp;
    function okToPost :boolean;
  public
    { Public declarations }
    function Execute : boolean;
  end;

function GetSaveAsDetails(var ACode : string; var AName : string) : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  bkXPThemes,
  syDefs,
  globals,
  WarningMoreFrm,
  WinUtils,
  BKConst;

{$R *.DFM}

{ TdlgSaveAs }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSaveAs.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SetupHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSaveAs.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eCode.Hint       :=
      'Enter a new code for the new Client File|'+
      'Enter a new code for the duplicate copy of this Client File';
   eName.Hint       :=
      'Enter the client name for the new Client File|'+
      'Enter the client name for the duplicate copy of this Client File';
   chkCheck.Hint       :=
      'Check this if you want to retrieve transactions into this Client File|'+
      'Check this if you want to retrieve transactions into this Client File, otherwise no transactions will be retrieved'
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSaveAs.FormShow(Sender: TObject);
begin
   ECode.SetFocus;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSaveAs.btnOKClick(Sender: TObject);
begin
  if okToPost then
  begin
    okPressed := true;
    close;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSaveAs.btnCancelClick(Sender: TObject);
begin
  Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsABadCode( S : String ): Boolean;
//check to see if client code entered is invalid
Begin
   S := UpperCase( S );

   result := ( S='CON' ) or ( S='AUX' ) or ( S='COM1' ) or ( S='COM2' ) or
             ( S='PRN' ) or ( S='LPT1' ) or ( S='LPT2' ) or ( S='LPT3' ) or ( S='NUL' ) or
             ( pos( '.', S )>0 ) or
             ( pos( ':', S )>0 ) or
             ( pos( '\', S )>0 ) or
             ( pos( '/', S )>0 ) or
             ( pos( '~', S )>0 ) or
             ( pos( '?', S )>0 ) or
             ( pos( '"', S) > 0) or
             ( pos( '<', S) > 0) or
             ( pos( '>', S) > 0) or
             ( pos( '|', S) > 0) or
             ( pos( '~', S) > 0) or
             ( pos( '*', S )>0);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgSaveAs.okToPost: boolean;
var
  cfRec : pClient_File_REc;
  NameExists : boolean;
  CodeType: string;
begin
  result := false;

  eCode.Text := Trim( eCode.Text);

  if eCode.Text = '' then
  begin
     HelpfulWarningMsg('You must enter a code for the new client file. Please try again',0);
     eCode.setfocus;
     exit;
  end;

  {check for duplicate name or file if no admin}
  NameExists := false;
  if Assigned(Adminsystem) then begin
     cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(eCode.Text);
     if cfRec <> nil then
     begin
       if cfRec.cfClient_Type = ctProspect then
         CodeType := 'Prospect'
       else
         CodeType := 'Client';
        NameExists := true;
     end;
  end
  else begin
     {no admin system.. check for file with this name}
     if BKFileExists(DATADIR + eCode.Text + FILEEXTN) then
     begin
       CodeType := 'Client';
       NameExists := true;
     end;
  end;

  if NameExists then begin
     HelpfulWarningMsg('A ' + CodeType + ' with this code already exists. Please try a different code.', 0 );
     eCode.setfocus;
     exit;
  end;

  if IsABadCode( eCode.text) then begin
     HelpfulWarningMsg('You have entered an illegal client code, or a code that contains illegal characters.  Please try again.',0);
     eCode.setfocus;
     exit;
  end;

  if eName.Text = '' then begin
     HelpfulWarningMsg('You must enter a client name. Please try again.', 0 );
     eName.setfocus;
     exit;
  end;

  result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgSaveAs.Execute: boolean;
begin
  okPressed := false;
  ShowModal;
  result := okPressed;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetSaveAsDetails(var ACode : string; var AName : string) : boolean;
var
  SaveAs : TDlgSaveAs;
begin
  Result := false;
  if not Assigned(MyClient) then exit;

  SaveAs := TDlgSaveAs.Create(Application.Mainform);
  with SaveAs do begin
    try
      BKHelpSetUp(SaveAs, BKH_Saving_a_client_file);
      eCode.text := ACode;
      eName.text := AName;
      lblCode.Caption := ACode+' : '+AName;
      chkCheck.Checked := false;  {assume dont want the copy to download also}
  
      if Execute then begin
         ACode := eCode.text;
         AName := eName.text;
         MyClient.clFields.clSuppress_Check_for_New_TXns := not chkCheck.Checked;
         Result := true;
      end;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
