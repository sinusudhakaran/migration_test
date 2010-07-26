unit files2;

(*
  This is how the FILES.PAS program should be rewritten so that the Admin and
  Local functions can be separated cleanly, and with a clean set of functions
  that only operate on MyClient.

  See Also AFiles.PAS, LFiles.PAS
  
*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure OpenMyClient( Code : ShortString );
procedure SaveMyClient;
procedure CloseMyClient;
procedure SaveMyClientAs;
procedure AbandonMyClient;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
uses
   Globals, AFiles, LFiles, LogUtil;

Const
   UnitName = 'FILES2';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure OpenMyClient( Code : ShortString );
const
   ThisMethodName = 'OpenMyClient';
Begin   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   if Assigned( Globals.AdminSystem ) then
      AFiles.OpenMyClient( Code )
   else
      LFiles.OpenMyClient( Code );
      
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
procedure SaveMyClient;
const
   ThisMethodName = 'SaveMyClient';
Begin   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   if Assigned( Globals.AdminSystem ) then
      AFiles.SaveMyClient
   else
      LFiles.SaveMyClient;
      
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
procedure CloseMyClient;
const
   ThisMethodName = 'CloseMyClient';
Begin   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   if Assigned( Globals.AdminSystem ) then
      AFiles.CloseMyClient
   else
      LFiles.CloseMyClient;
      
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
procedure SaveMyClientAs;
const
   ThisMethodName = 'SaveMyClientAs';
Begin   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   if Assigned( Globals.AdminSystem ) then
      AFiles.SaveMyClientAs
   else
      LFiles.SaveMyClientAs;
      
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
procedure AbandonMyClient;
const
   ThisMethodName = 'AbandonMyClient';
Begin   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   if Assigned( Globals.AdminSystem ) then
      AFiles.AbandonMyClient
   else
      LFiles.AbandonMyClient;
      
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
 
