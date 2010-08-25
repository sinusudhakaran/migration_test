Unit bkmaskutils;

Interface

Uses
   StdCtrls;

Procedure CheckRemoveMaskChar(EditControl: TEdit; Var RemovingMask: boolean);

Procedure CheckForMaskChar(EditControl: TEdit; Var RemovingMask: boolean);

Implementation

Uses
   Forms, BK5Except, Globals, LogUtil;

const
   UnitName = 'MaskUtils';

Procedure CheckRemoveMaskChar(EditControl: TEdit; Var RemovingMask: boolean);
//check if we are trying to remove the mask char from a chart code
Const
   ThisMethodName = 'CheckRemoveMaskChar';
Var
   EditText : string;
   MaskChar : Char;
   Msg      : String;
Begin { BThisYear }
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end;

   EditText := EditControl.text;
   EditText := Copy(EditText, 1, Length(EditText) - 1);

   If MyClient.clChart.AddMaskCharToCode(EditText, MyClient.clFields.clAccount_Code_Mask,
      MaskChar) Then
   Begin
      RemovingMask := true;
      Try
         EditControl.text := EditText;
         EditControl.SelStart := Length(EditControl.text);
      Finally
         RemovingMask := false;
      End;
   End;
End;

Procedure CheckForMaskChar(EditControl: TEdit; Var RemovingMask: boolean);
Const
   ThisMethodName = 'CheckForMaskChar';
Var
   MaskChar : Char;
   EditText : string;
   Msg      : String;
Begin { BThisYear }
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end;
   
   EditText := EditControl.text; 
   If (not RemovingMask) and MyClient.clChart.AddMaskCharToCode(EditText, 
      MyClient.clFields.clAccount_Code_Mask, MaskChar) Then 
   Begin 
      EditControl.text := EditText + MaskChar; 
      EditControl.SelStart := Length(EditControl.text);
      Application.ProcessMessages; // #4095 - try to make sure this is done before other keystroke events happen
   End; 
End; 


End.    
