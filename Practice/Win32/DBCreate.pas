unit DBCreate;
//------------------------------------------------------------------------------
// Code to create the Initial System Database
// This code is called when BankLink is run with the parameter DBCreate
interface
//------------------------------------------------------------------------------
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcEF, OvcSF, SysObj32,
  OSFont;

type
  TfrmDBCreate = class(TForm)
    lblDirectory: TLabel;
    Label1: TLabel;
    gbxPracticeDetails: TGroupBox;
    cmbCountry: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    sflBankLinkCode: TOvcSimpleField;
    OvcController1: TOvcController;
    sflPracticeName: TOvcSimpleField;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
    procedure DoRebranding();
  public
    { Public declarations }
    class function Execute : Boolean;
  end;

function  CheckDBCreateParam : Boolean;
function  CheckDBCreateParamNoRun : Boolean;
procedure AddClientTypes(SystemDB: TSystemObj);

procedure NewAdminSystem( Country : Byte; Code, Name : String );

//******************************************************************************
implementation

{$R *.DFM}

uses
   bkXPThemes,
   STStrL,    //TurboPower
   SyUSIO,
   SYctIO,
   Admin32,
   SyDefs,
   BKDefs,
   BKConst,
   Globals,
   WarningMoreFrm,
   InfoMoreFrm,
   ErrorMoreFrm,
   WinUtils, bkBranding, bkProduct;

const
   DBCreateCLP = '/DBCREATE';             //Command Line Parameter
   DBCreateNoRunCLP = '/DBCREATE_NORUN';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDBCreate.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  bkXPThemes.ThemeForm( Self);

  // Populate Country Combo
  with cmbCountry do begin
    for i := whMin to whMax do begin
       Items.Add( whNames[ i ] );
    end;
    ItemIndex := 0;
  end;
  // Format Labels
  with lblDirectory do begin
    Caption := Format( Caption,[ JustPathnameL( Application.ExeName ) ] );
  end;
  SetUpHelp;

  DoRebranding();
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDBCreate.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   cmbCountry.Hint       :=
       'Select the country where you are installing the software|' +
       'Select the country where you are installing the software, this affects the data you can download';
   sflBankLinkCode.Hint  :=
       'Enter the '+SHORTAPPNAME+' Code assigned to your Practice|'+
       'Enter the '+SHORTAPPNAME+' Code assigned to your Practice';
   sflPracticeName.Hint  :=
       'Enter your Practice Name|' +
       'Enter your Practice Name';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDBCreate.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   //
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDBCreate.btnOkClick(Sender: TObject);
begin
   with sflBankLinkCode do begin
      if Text = '' then begin
         HelpfulWarningMsg('You must enter a ' + TProduct.BrandName + ' Code.', 0 );
         SetFocus;
         ModalResult := 0;
         Exit;
      end;
   end;
   with sflPracticeName do begin
      if Text = '' then begin
         HelpfulWarningMsg('You must enter a Practice Name.', 0 );
         SetFocus;
         ModalResult := 0;
         Exit;
      end;
   end;
   NewAdminSystem( cmbCountry.ItemIndex,
                   sflBankLinkCode.Text,
                   sflPracticeName.Text );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmDBCreate.DoRebranding;
begin
  Caption := 'Create Initial ' + BRAND_PRACTICE + ' Database';
  Label3.Caption := '&' + BRAND_SHORT_NAME + ' Code';
end;

class function TfrmDBCreate.Execute : Boolean;
var
   S : String;
begin
   Result := False;
   if AdminExists then begin
      S := 'There is already a %0:s database in this directory'#13#13+
           'Please contact %0:s Client Services for assistance.';
      S := Format( S, [ SHORTAPPNAME ] );
      HelpfulErrorMsg( S, 0 );
   end
   else begin
      with TfrmDBCreate.Create(Application.MainForm) do begin
         try
            ShowModal;
            If ( ModalResult = mrOk ) then
               Result := True;
         finally
            Free;
         end;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure NewAdminSystem( Country : Byte; Code, Name : String );

   procedure SetEntryTypes;
   var
      F              : TextFile;
      S              : String;
      P1,P2,P3       : String[80];
      i              : Integer;
      TypeFileName   : String;
   begin
      Case Country of
         whNewZealand   : TypeFileName := ExecDir + 'NZ.INF';
         whAustralia    : TypeFileName := ExecDir + 'OZ.INF';
         whUK           : TypeFileName := ExecDir + 'UK.INF'; 
      end;

      if BKFileExists( TypeFileName ) then begin
         AssignFile( F, TypeFileName );
         Reset( F );
         While not EOF( F ) do begin
            Readln( F, S );
            P1:=''; P2:=''; P3:='';

            i:=Pos( '³',S );
            If i>0 then begin
               P1:=Trim( Copy( S,1,i-1 ) );
               Delete( S,1,i );
            end
            else
               S:='';

            i:=Pos( '³',S );
            If i>0 then begin
               P2:=Trim( Copy( S,1,i-1 ) );
               Delete( S,1,i );
            end
            else
               S:='';

            P3:=Trim( S );
            i:=StrToIntDef( P1,-1);
            If ( i>=0 ) and ( i<=100 ) then begin
               with AdminSystem.fdFields do begin
                  fdShort_Name[i]      := P3;
                  fdLong_Name[i]       := P2;
               end;
            end;
         end;
         Close( F );
      end
      else
      begin
         //transaction types file not found
         HelpfulWarningMsg('Transaction Types descriptions file not found '+#13+#13+
                           TypeFileName+#13#13+
                           'No default descriptions will be loaded.',0);
      end;
   end;

var
   SU : pUser_Rec;
begin
{$IFNDEF BK_UNITTESTINGON}
   If AdminExists then Halt;
{$ENDIF}
   AdminSystem := TSystemObj.Create;

   with AdminSystem do begin
      with fdFields do begin
         fdPractice_Name_for_Reports    := Name           ;
         fdPractice_EMail_Address       := ''             ;
         fdAccounting_System_Used       := 0              ;
         fdCountry                      := Country        ;
         fdBankLink_Code                := Code           ;
         fdMagic_Number                 := GetTickCount mod LongWord(MaxInt); //MilliSec since Windows Booted
         fdWeb_Export_Format            := 255;
         fdFile_Version                 := SYDEFS.SY_FILE_VERSION;
         fdExtract_Quantity_Decimal_Places := 4;
         fdCollect_Usage_Data           := True;
      end;
      SetEntryTypes;

      { Add the SUPERVIS and Operator Users }
      GetMem( SU, SYDefs.User_Rec_Size );
      FillChar( SU^, SYDefs.User_Rec_Size, 0 );
      With SU^ do begin
         usRecord_Type                      := tkBegin_User;
         usCode                             := 'SUPERVIS';
         usName                             := 'System Administrator';
         usPassword                         := 'INSECURE';
         usSystem_Access                    := TRUE;
         usMASTER_Access                    := TRUE;
         usEOR                              := tkEnd_User;
         Inc( fdFields.fdUser_LRN_Counter );
         usLRN := fdFields.fdUser_LRN_Counter;
      end;
      fdSystem_User_List.Insert( SU );

      GetMem( SU, SYDefs.User_Rec_Size );
      FillChar( SU^, SYDefs.User_Rec_Size, 0 );
      With SU^ do begin
         usRecord_Type                      := tkBegin_User;
         usCode                             := 'OPERATOR';
         usName                             := 'An Operator';
         usPassword                         := '';
         usSystem_Access                    := FALSE;
         usMASTER_Access                    := TRUE;
         usEOR                              := tkEnd_User;
         Inc( fdFields.fdUser_LRN_Counter );
         usLRN := fdFields.fdUser_LRN_Counter;
      end;
      fdSystem_User_List.Insert( SU );
      AddClientTypes(AdminSystem);
{$IFNDEF BK_UNITTESTINGON}
      Save;
{$ENDIF}      
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CheckDBCreateParam : Boolean;
// This function checks the start up parameters
// It returns true if BK5 is started with the /DBCreate param
var
   S : String;
begin
   Result := False;
   If ( ParamCount = 0 ) then
      Exit;
   If ( ParamCount = 1 ) then begin
      S := UpperCase( ParamStr( 1 ) );
      if not ( S = DBCreateCLP ) then begin
         Exit;
      end
      else begin
         Result := True;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CheckDBCreateParamNoRun : Boolean;
// This function checks the start up parameters
// It returns true if BK5 is started with the /DBCreate_NoRun param
var
   S : String;
begin
   Result := False;
   If ( ParamCount = 0 ) then
      Exit;
   If ( ParamCount = 1 ) then begin
      S := UpperCase( ParamStr( 1 ) );
      if not ( S = DBCreateNoRunCLP ) then begin
         Exit;
      end
      else begin
         Result := True;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// add system client types
procedure AddClientTypes(SystemDB: TSystemObj);
  procedure AddNewClientType(Name: string);
  var
    pc: pClient_Type_Rec;
  begin
    pc := New_Client_Type_Rec;
    Inc(SystemDB.fdFields.fdClient_Type_LRN_Counter);
    pc.ctLRN := SystemDB.fdFields.fdClient_Type_LRN_Counter;
    pc.ctName := Name;
    SystemDB.fdSystem_Client_Type_List.Insert(pc);
  end;
begin
  AddNewClientType('Coding Report');
  AddNewClientType('Notes');
  AddNewClientType('Books');
  AddNewClientType('Books via ' + bkBranding.ProductOnlineName);
  AddNewClientType('Books Secure');
  AddNewClientType('CodeIT');
  AddNewClientType('Annual');
  case Systemdb.fdFields.fdCountry  of
     whNewZealand   :
     begin
        AddNewClientType('GST');
        AddNewClientType('GST/Coding Report');
     end;
     whAustralia :
     begin
        AddNewClientType('GST');
        AddNewClientType('GST/Coding Report');
        AddNewClientType('Superfund');
     end;
     whUK :
     begin
        AddNewClientType('VAT');
        AddNewClientType('VAT/Coding Report');
     end;
  end;
end;

end.
