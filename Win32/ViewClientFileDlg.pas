Unit ViewClientFileDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//View the client details for clients in the admin system and
//reset some of the admin system values
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


!! No longer used in 5.3

Interface

Uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
      StdCtrls, SYDEFS;

Type
   TdlgViewClientFile = Class (TForm)
      btnClose       : TButton;
      Label1         : TLabel;
      Label2         : TLabel;
      Label3         : TLabel;
      Label4         : TLabel;
      Label5         : TLabel;
      stCode         : TStaticText;
      stName         : TStaticText;
      stDate         : TStaticText;
      stSaveCount    : TStaticText;
      stUserResp     : TStaticText;
      btnOK          : TButton;
      grpAdmin       : TGroupBox;
      chkCheckedOut  : TCheckBox;
      chkOpen        : TCheckBox;
    gbxScheduleReportStatus: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    stReportStart: TStaticText;
    stReportPeriod: TStaticText;
      Procedure btnCloseClick(Sender: TObject);
      Procedure chkCheckedOutClick(Sender: TObject);
      Procedure chkOpenClick(Sender: TObject);
      Procedure FormCreate(Sender: TObject);
      procedure SetUpHelp;
      Procedure FormShow(Sender: TObject);
      Procedure btnOKClick(Sender: TObject);
   Private
      { Private declarations }
      EditChk    : boolean;
      formLoaded : boolean;
      okPressed  : boolean;
   Public
      { Public declarations }
      Function Execute : boolean;
   End;

Function ViewEditClientFileDetails(CF: pClient_File_Rec) : boolean;

//******************************************************************************
Implementation

{$R *.DFM}

Uses
  bkDateUtils,
  bkconst,
  bkXPThemes,
  Admin32,
  Globals,
  EnterPwdDlg,
  YesNoDlg,
  LogUtil,
  ErrorMoreFrm,
  WarningMoreFrm;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TdlgViewClientFile.FormCreate(Sender: TObject);
Begin { TdlgViewClientFile.FormCreate }
  bkXPThemes.ThemeForm( Self);

  formLoaded := false;
  SetUpHelp;
End; { TdlgViewClientFile.FormCreate }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TdlgViewClientFile.FormShow(Sender: TObject);
Begin { TdlgViewClientFile.FormShow }
   formLoaded := true;
End; { TdlgViewClientFile.FormShow }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgViewClientFile.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   chkCheckedOut.Hint :=
      'UnCheck to Reset Checked Out or Off-site Status|'+
      'UnChecking this box will Reset the Checked Out or Off-site Status for this Client File';
   chkOpen.Hint       :=
      'UnCheck to Reset Open Status|'+
      'UnChecking this box will Reset the Open Status for this Client File';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TdlgViewClientFile.btnOKClick(Sender: TObject);
Begin { TdlgViewClientFile.btnOKClick }
   okPressed := true;
   Close;
End; { TdlgViewClientFile.btnOKClick }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TdlgViewClientFile.btnCloseClick(Sender: TObject);
Begin { TdlgViewClientFile.btnCloseClick }
   okPressed := false;
   Close;
End; { TdlgViewClientFile.btnCloseClick }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TdlgViewClientFile.chkCheckedOutClick(Sender: TObject);
Begin { TdlgViewClientFile.chkCheckedOutClick }
   If formLoaded Then Begin
      If EditChk Then Begin
         exit
      End; {already editing}
      If not (AskYesNo('Reset Client File Check Out Status', 'This will reset the Client File Check Out Status.  You should only do this '
         + 'if you have been advised to by a support person. ' + #13 + #13 + 'Please confirm you want to do this.',
         DLG_NO, 0) <> DLG_YES) Then Begin
         exit
      End;

      EditChk := true;
      chkCheckedOut.Checked := not chkCheckedOut.Checked; 
      EditChk := false; 
   End { formLoaded }; 
End; { TdlgViewClientFile.chkCheckedOutClick } 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure TdlgViewClientFile.chkOpenClick(Sender: TObject);
Begin { TdlgViewClientFile.chkOpenClick } 
   If formLoaded Then Begin
      If EditChk Then Begin 
         exit 
      End; {already editing} 
      If AskYesNo('Reset Client File Open Status', 'This will reset the Client File Open Status.  You should only do this ' 
         + 'if you have been advised to by a support person. ' + #13 + #13 + 'Please confirm you want to do this.',
         DLG_NO, 0) = DLG_YES Then Begin 
         If EnterPassword('Reset File Open Status', 'FILEOPEN', 0, true, false) 
            Then Begin 
            exit 
         End 
      End; 
      
      EditChk := true; 
      chkOpen.Checked := not chkOpen.Checked; 
      EditChk := false; 
   End { formLoaded };
End; { TdlgViewClientFile.chkOpenClick } 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function TdlgViewClientFile.Execute : boolean; 
Begin { TdlgViewClientFile.Execute }
   okPressed := false;
   
   ShowModal; 
   Result := okPressed; 
End; { TdlgViewClientFile.Execute } 
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ViewEditClientFileDetails(CF: pClient_File_Rec) : boolean;
const
   ThisMethodName = 'ViewEditClientFileDetails';
Var
   MyDlg      : TdlgViewClientFile;
   pu         : pUser_Rec;
   NewState   : Integer;
   ClientCode : string;
   WasState   : Integer;
   Status     : string;
Begin { ViewEditClientFileDetails } 
   Result := false; 
   MyDlg := TdlgViewClientFile.Create(Application); 
   Try 
      With MyDlg Do Begin 
         stCode.caption := CF.cfFile_Code; 
         stName.caption := CF.cfFile_Name; 
         stDate.caption := bkDate2Str(CF.cfDate_Last_Accessed); 
         stSaveCount.caption := IntToStr(CF.cfFile_Save_Count);
         stUserResp.caption := '';

         {load file status checkboxes}
         chkCheckedOut.Checked := ( CF.cfFile_Status in [ fsCheckedOut, fsOffsite ] );
         chkCheckedOut.Enabled := ( CF.cfFile_Status in [ fsCheckedOut, fsOffsite ] );

         chkOpen.Checked       := CF.cfFile_Status = fsOpen;
         chkOpen.Enabled       := CF.cfFile_Status = fsOpen;

         If Assigned(MyClient) Then Begin
            If MyClient.clFields.clCode = CF.cfFile_Code Then Begin
               chkOpen.Enabled := false
            End 
         End;

         {$IFNDEF SmartBooks}
         pu := AdminSystem.fdSystem_User_List.FindLRN(CF.cfUser_Responsible);
         If Assigned(pu) Then Begin
            stUserResp.caption := pu.usName
         End;
         {$ENDIF}
         
         stReportStart.caption := bkDate2Str(CF.cfReport_Start_Date); 
         
         If CF.cfReporting_Period in [roMin..roMax] Then Begin 
            stReportPeriod.caption := roNames[CF.cfReporting_Period] 
         End
         Else Begin
            stReportPeriod.caption := '' 
         End; 
      End { with MyDlg }; 
      
      If MyDlg.Execute Then Begin 
         With MyDlg Do Begin 
            {user pressed ok, first check if we really need to do anything} 
            NewState := fsNormal; 
            Result := true; {force a reload of the maintenance box} 
            If chkCheckedOut.Checked Then Begin 
               NewState := fsCheckedOut 
            End; 
            
            If chkOpen.Checked Then Begin 
               NewState := fsOpen 
            End; 
            
            If (NewState <> CF.cfFile_Status) Then Begin 
               {file status needs to be changed} 
               ClientCode := CF.cfFile_Code; 
               WasState := CF.cfFile_Status;
               
               If LoadAdminSystem(true, ThisMethodName ) Then Begin
                  CF := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode); 
                  If Assigned(CF) Then Begin 
                     If CF.cfFile_Status = WasState Then Begin 
                        CF.cfFile_Status := NewState;

                        //clear the current user 
                        if NewState = fsNormal then
                           cf.cfCurrent_User := 0;
                        SaveAdminSystem; 
                        
                        {log change}
                        Status := '<unknown>';
                        If NewState in [fsMin..fsMax] Then Begin 
                           Status := fsNames[NewState] 
                        End; 
                        If Status = '' Then Begin 
                           Status := 'Normal' 
                        End; 
                        
                        LogUtil.LogMsg(lmInfo, 'ViewClientFileDlg', 'User changed file status to ' 
                           + Status + ' for client ' + ClientCode); 
                     End { CF.cfFile_Status = WasState } 
                     Else Begin 
                        UnlockAdmin; 
                        HelpfulWarningMsg('The File Status for Client File ' + 
                           ClientCode + ' has changed.  Your change will not be saved.', 0); 
                     End { not (CF.cfFile_Status = WasState) }; 
                  End { Assigned(CF) } 
                  Else Begin 
                     UnlockAdmin; 
                     HelpfulErrorMsg('The File for Client Code ' + ClientCode + ' cannot be found by the Admin System.', 0); 
                  End { not (Assigned(CF)) }; 
               End { LoadAdminSystem(true) }
               Else Begin 
                  HelpfulErrorMsg('Unable to update Admin Client File Record.  Cannot Access Admin System.', 0) 
               End; 
            End { (NewState <> CF.cfFile_Status) }; 
         End { with MyDlg } 
      End; 
   Finally
      MyDlg.Free; 
   End { try }; 
End; { ViewEditClientFileDetails } 
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
End.
