unit RegistryUtils;
//------------------------------------------------------------------------------
{
   Title:        Registry Utils

   Description:  Provide access to registry functions needed by ecoding

   Remarks:      returns true if registry updated, catchs all exceptions

   Author:       Matthew Hopkins  31/08/2001

}
//------------------------------------------------------------------------------

interface

function AssociateFileType( Extn : string; FileDesc: string; AppPath : string) : boolean;

//******************************************************************************
implementation
uses
   Registry,
   Windows,
   SysUtils;

function AssociateFileType( Extn : string; FileDesc: string; AppPath : string) : boolean;
//registry the default file type so can open by double clicking etc
//extn should not have the '.' character

var
   Reg              : TRegistry;
   sValue           : string;
   AppInternalName  : string;
begin
   result := false;
   if not FileExists( AppPath) then exit;
   try
      Reg := TRegistry.Create;
      try
         Reg.RootKey := HKEY_CLASSES_ROOT;
         //determine if registry key exists already
         if Reg.KeyExists( '.' + Extn) then exit;

         //create the HKEY_CLASSES_ROOT\.EXT value
         AppInternalName := Extn + '_auto_file';
         Reg.OpenKey( '.' + Extn, true);
         Reg.WriteString( '', AppInternalName);
         Reg.CloseKey;

         //create association and default icon
         Reg.OpenKey( AppInternalName, true);
         sValue := Reg.ReadString('');
         if sValue = '' then
            Reg.WriteString('', FileDesc);
         Reg.CloseKey;

         Reg.OpenKey( AppInternalName + '\shell\open\command', true);
         sValue := Reg.ReadString( '');
         if sValue <> '' then begin
            exit;
         end;

         //associate file type
         Reg.WriteString( '', AppPath + ' "%1"');
         Reg.CloseKey;

         //set default icon
         Reg.OpenKey( AppInternalName + '\DefaultIcon', true);
         Reg.WriteString( '', AppPath + ',0');
         Reg.CloseKey;
      finally
         Reg.Free;
      end;
      result := true;
   except
      On E : exception do begin
         ; //do nothing
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
