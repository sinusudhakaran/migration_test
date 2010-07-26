unit Templates;

(*
   A template file is a text file which contains all the GST & BAS setup and
   chart information for a client. We use some standard template files to create
   default GST tables when we import a client's chart.
*)
{$I COMPILER}
//{$I DEBUGME}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Type
   tpl_CreateChartType = ( tpl_CreateChartFromTemplate, tpl_DontCreateChart );
  

Procedure SaveAsTemplate;

Procedure LoadFromTemplate;

Function  LoadTemplate( Const TemplateFilename : String;
                        Const CreateChartIfFound : tpl_CreateChartType ): Boolean; 

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses
   Globals,
   glConst,
   bkDateUtils,
   StDate,
   BASUtils,
   SysUtils,
   InfoMoreFrm,
   StStrS,
   Dialogs,
   BKDefs,
   BKConst,
   BKchIO,
   GenUtils,
   GSTUtil32,
   WinUtils,
   YesNoDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure SaveAsTemplate;

CONST
   NY : Array[ Boolean ] of String[1] = ( 'N', 'Y' );

Var
   F     : TextFile;
   Buf   : Array[ 1..8192 ] of Byte;
   TemplateFileName : String;

   SD    : TSaveDialog;
   AllOK : Boolean;
   i     : Integer;
Begin
   If not Assigned( MyClient ) then exit;

   if not DirectoryExists( GLOBALS.TemplateDir ) then CreateDir( GLOBALS.TemplateDir );

   //allow the user to select a different template name
   SD := TSaveDialog.Create( NIL );
   Try
      SD.InitialDir := GLOBALS.TemplateDir;
      SD.FileName   := MyClient.clFields.clCode + '.TPL';
      SD.Filter     := 'Template files (*.tpl)|*.TPL';
      SD.DefaultExt := 'TPL';
      SD.Options    := [ ofNoChangeDir, ofHideReadOnly ];
      If SD.Execute then
         TemplateFileName := SD.FileName
      else
         exit;
      while BKFileExists(TemplateFileName) do
      begin
        if AskYesNo('Overwrite File','The file '+ExtractFileName(TemplateFileName)+' already exists. Overwrite?',dlg_yes,0) = DLG_YES then
          Break;
        if not SD.Execute then exit;
        TemplateFileName := SD.FileName        
      end;
   Finally
      SD.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( Globals.DataDir);
   end;
   With MyClient.clFields do
   Begin
      AssignFile( F, TemplateFileName );
      SetTextBuf( F, Buf );
      Rewrite( F );
      Try
         Writeln( F, '[Template]' );
         Writeln( F, 'Code=', clCode );
         Writeln( F, 'Name=', clName );
         Writeln( F, 'Version=2' );
         Writeln( F, '[Tax Starts]' );
         For i := 1 to 5 do Writeln( F, i, '|', bkDate2Str( clGST_Applies_From[ i ] ) );
         Writeln( F );

         Writeln( F, '[Tax Table]' );
         For i := 1 to MAX_GST_CLASS do
         Begin
            If clGST_Class_Codes[ i ] <> '' then
            Begin
               Writeln( F,
                  i, '|',
                  clGST_Class_Codes[ i ], '|',
                  clGST_Class_Names[ i ], '|',
                  clGST_Rates[ i, 1 ]:0:0, '|',
                  clGST_Rates[ i, 2 ]:0:0, '|',
                  clGST_Rates[ i, 3 ]:0:0, '|',
                  clGST_Rates[ i, 4 ]:0:0, '|',
                  clGST_Rates[ i, 5 ]:0:0, '|',
                  clGST_Account_Codes[ i ], '|',
                  clGST_Business_Percent[ i]:0:0
                  );
            end;
         end;
         Writeln( F );

         Writeln( F, '[Chart]' );
         With MyClient.clChart do For i := 0 to Pred( ItemCount ) do With Account_At( i )^ do
         Begin
            Writeln( F,
               chAccount_Code, '|',
               chAccount_Description, '|',
               chGST_Class, '|',
               NY[ chPosting_Allowed ], '|',
               chAccount_Type, '|',
               NY[ chEnter_Quantity ]
               );
         end;
         Writeln( F );

         Writeln( F, '[BAS Rules]' );
         For i := MIN_SLOT to MAX_SLOT do
         Begin
            If clBAS_Field_Number[ i ] > 0 then
            Begin
               Writeln( F, clBAS_Field_Number[ i ], '|',
                           clBAS_Field_Source[ i ], '|',
                           clBAS_Field_Account_Code[ i ], '|',
                           clBAS_Field_Balance_Type[ i ], '|',
                           clBAS_Field_Percent[i]:0:0
                       );
            end;
         end;
         Writeln( F );
         AllOK := True;
      Finally
         CloseFile( F );
      end;
   end;
   If AllOK then HelpfulInfoMsg( 'Template saved to '+ TemplateFileName, 0 );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function  LoadTemplate( Const TemplateFilename : String;
                        Const CreateChartIfFound : tpl_CreateChartType ): Boolean;

   Function Field( Const L : ShortString; N : Integer ): ShortString;
   Var
      LLen   : Byte Absolute L;
      i, No   : Byte;
   Begin
      Result := '';
      If LLen = 0 then exit;

      No  := 1;
      For i := 1 to LLen do
      Begin
         Case L[i] of
            '|' : Begin
                     If No = N then exit;
                     Inc( No );
                     Result := '';
                  end;
            else Result := Result + L[i];
         end;
      end;   
      If ( No = N ) then exit;
      Result := '';
   end;
   
Var
   F                : TextFile;
   Buf              : Array[ 1..8192 ] of Byte;
   L                : ShortString;
   CreateChart      : Boolean;
   i, Slot          : Integer;
   A                : pAccount_Rec;
   V                : LongInt;
   aCode            : BK5CodeStr;
   aDesc            : String[80];
   aGST_Class       : Integer;
   aType            : Integer;
   aQty             : Boolean;
   aPostOK          : Boolean;
   MultiplyBy       : Integer;
Begin
   Result := False;
   If not Assigned( MyClient ) then exit;

   If ( TemplateFileName = '' ) then exit;
   If not BKFileExists( TemplateFileName ) then exit;

   With MyClient, clFields do
   Begin
      FillChar( clGST_Class_Codes          , Sizeof( clGST_Class_Codes          ), 0 );
      FillChar( clGST_Applies_From         , Sizeof( clGST_Applies_From         ), 0 );
      FillChar( clGST_Class_Names          , Sizeof( clGST_Class_Names          ), 0 );
      FillChar( clGST_Class_Types          , Sizeof( clGST_Class_Types          ), 0 );
      FillChar( clGST_Account_Codes        , Sizeof( clGST_Account_Codes        ), 0 );
      FillChar( clGST_Rates                , Sizeof( clGST_Rates                ), 0 );
      FillChar( clGST_Business_Percent     , Sizeof( clGST_Business_Percent     ), 0 );
   
      FillChar( clBAS_Field_Number         , Sizeof( clBAS_Field_Number         ), 0 );
      FillChar( clBAS_Field_Source         , Sizeof( clBAS_Field_Source         ), 0 );
      FillChar( clBAS_Field_Account_Code   , Sizeof( clBAS_Field_Account_Code   ), 0 );
      FillChar( clBAS_Field_Balance_Type   , Sizeof( clBAS_Field_Balance_Type   ), 0 );
      FillChar( clBAS_Field_Percent        , Sizeof( clBAS_Field_Percent        ), 0 );

      CreateChart := ( clChart.ItemCount = 0 ) and ( CreateChartIfFound = tpl_CreateChartFromTemplate );

      Assign( F, TemplateFileName );
      Try
         SetTextBuf( F, Buf );
         Reset( F );
         // Change to support 4.d.p. - upgrade old templates
         MultiplyBy := 100;
         While not EOF( F ) do
         Begin
            Readln( F, L );

            // -----------------------------------------------------------------

            // Change to support 4.d.p. - do not upgrade new templates!
            if L = '[Template]' then
            begin
               Repeat
                  Readln( F, L );
                  If L <> '' then
                  Begin
                    if Lowercase(L) = 'version=2' then
                      MultiplyBy := 1;
                  end;
               Until ( L = '' ) or (L='[Tax Starts]');
            end;

            If L = '[Tax Starts]' then
            Begin
               Repeat
                  Readln( F, L );
                  If L <> '' then
                  Begin
                     i := GenUtils.Str2Long( Field( L, 1 ) );
                     If i in [ 1..5 ] then
                     Begin
                        clGST_Applies_From[ i ] :=  bkStr2Date( Field( L, 2 ) );
                     end;
                  end;
               Until ( L = '' );
            end;

            // -----------------------------------------------------------------

            If L = '[Tax Table]' then
            Begin
               Repeat
                  Readln( F, L );
                  If L <> '' then
                  Begin
                     i := Str2Long( Field( L, 1 ) );
                     If i in [ 1..MAX_GST_CLASS ] then
                     Begin
                        clGST_Class_Codes[ i ] := Field( L, 2 );
                        clGST_Class_Names[ i ] := Field( L, 3 );
                        V := Str2Long( Field( L, 4 ) ); clGST_Rates[ i, 1 ] := V * MultiplyBy;
                        V := Str2Long( Field( L, 5 ) ); clGST_Rates[ i, 2 ] := V * MultiplyBy;
                        V := Str2Long( Field( L, 6 ) ); clGST_Rates[ i, 3 ] := V * MultiplyBy;
                        V := Str2Long( Field( L, 7 ) ); clGST_Rates[ i, 4 ] := V * MultiplyBy;
                        V := Str2Long( Field( L, 8 ) ); clGST_Rates[ i, 5 ] := V * MultiplyBy;
                        clGST_Account_Codes[ i ] := Field( L, 9 );
                        V := Str2Long( Field( L, 10 )); clGST_Business_Percent[ i ] := V;
                     end;
                  end;
               Until ( L = '' );
            end;

            // -----------------------------------------------------------------
            
            If L = '[Chart]' then
            Begin
               Repeat
                  Readln( F, L );
                  If L <> '' then
                  Begin
                     aCode := Field( L, 1 );
                     aDesc := Field( L, 2 );
                     aGST_Class := Str2Long( Field( L, 3 ) );
                     aPostOK := ( Field( L, 4 ) = 'Y' );
                     aType := Str2Long( Field( L, 5 ) );
                     aQty := ( Field( L, 6 ) = 'Y' );

                     If CreateChart then
                     Begin
                        With MyClient.clChart do
                        Begin
                           If FindCode( aCode ) = nil then
                           begin
                              A := New_Account_Rec;
                              With A^ do
                              Begin
                                 chAccount_Code        := aCode;
                                 chAccount_Description := aDesc;
                                 If aGST_Class in [ 0..MAX_GST_CLASS ] then chGST_Class := aGST_Class;
                                 chAccount_Type        := aType;
                                 chPosting_Allowed     := aPostOK;
                                 chEnter_Quantity      := aQty;
                              end;
                              MyClient.clChart.Insert( A );
                           end;
                        end;
                     end
                     else
                     Begin
                        With MyClient.clChart do
                        Begin
                           A := FindCode( aCode );
                           If Assigned( A ) then With A^ do
                           Begin
                              If aGST_Class in [ 0..MAX_GST_CLASS ] then chGST_Class := aGST_Class;
                           end;
                        end;
                     end;
                  end;
               Until ( L = '' );
            end;

            // -----------------------------------------------------------------

            If L = '[BAS Rules]' then
            Begin
               Slot := 0;
               Repeat
                  Readln( F, L );
                  If L <> '' then
                  Begin
                     i := Str2Long( Field( L, 1 ) );
                     If i in [ bfMin..bfMax ] then
                     Begin
                        Inc( Slot );
                        If ( Slot in [ MIN_SLOT..MAX_SLOT ] ) then
                        Begin
                           clBAS_Field_Number[ Slot ]       := i;
                           clBAS_Field_Source[ Slot ]       := Str2Byte( Field( L, 2 ) );
                           clBAS_Field_Account_Code[ Slot ] := Field( L, 3 );
                           clBAS_Field_Balance_Type[ Slot ] := Str2Byte( Field( L, 4 ) );
                           If Str2LongS( Field( L, 5 ), V ) then clBAS_Field_Percent[ Slot ] := V * MultiplyBy;
                        end;
                     end;
                  end;
               Until ( L = '' );
            end;
         end;
         Result := True;
      Finally
         CloseFile( F );
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure LoadFromTemplate;
Var
   OD               : TOpenDialog;
   TemplateFileName : String;
Begin
   If not Assigned( MyClient ) then exit;

   TemplateFileName := '';

   OD := TOpenDialog.Create( NIL );
   Try
      OD.InitialDir := GLOBALS.TemplateDir;
      OD.Filter     := 'All Template files (*.tpl; *.tpm)|*.TPL;*.TPM|Template files (*.tpl)|*.TPL|Master Template files (*.tpm)|*.TPM';
      OD.Filename   := '';
      OD.Options    := [ ofNoChangeDir, ofHideReadOnly ];
      If OD.Execute then TemplateFileName := OD.FileName;
   Finally
      OD.Free;
      //make sure all relative paths are relative to data dir after browse
      SysUtils.SetCurrentDir( Globals.DataDir);
   end;

   If TemplateFileName = '' then exit;

   If LoadTemplate( TemplateFilename, tpl_CreateChartFromTemplate ) then begin
      HelpfulInfoMsg( 'Template loaded from '+TemplateFileName, 0 );
      //now reload the gst defaults for the client
      GSTUTIL32.ApplyDefaultGST( false);
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
