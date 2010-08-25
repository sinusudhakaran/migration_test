Unit ShellUtils;

Interface

Uses
   Windows;

Function BrowseFolder(Var SelectedFolder: string; Const caption: string) : boolean;

{the callback function used by the browse for folder dialog
 box. notice the export directive.}
Function BrowseCallback(hWnd: hWnd; uMsg: UINT; lParam: lParam; lpData: lParam) : Integer;
   Stdcall; Export;

function  DeleteFileToRecycleBin(const FileName : string) : boolean;

Implementation

Uses
   Classes, SysUtils, ShlObj, ShellAPI, ActiveX, StFileOp, LogUtil, GlobalDirectories;

Const
   UnitName = 'ShellUtils';
   DebugMe  : Boolean = False;
            
{this callback function is called whenever an action takes
 place inside the browse for folder dialog box}
Function BrowseCallback(hWnd: hWnd; uMsg: UINT; lParam: lParam; lpData: lParam) : Integer;
Var
   PathName : Array [0..MAX_PATH] Of Char;
// holds the path name
Begin { BrowseCallback }
   Result := 0;
   {if the selection in the browse for folder
   dialog box has changed...}
   Case uMsg Of
   BFFM_INITIALIZED:
   Begin
      SendMessage(hWnd, BFFM_SETSELECTION, 1, lpData);
      Result := 0;
   End;
   BFFM_SELCHANGED:
   Begin
      {...retrieve the path name from the item identifier list}
      SHGetPathFromIDList(PItemIDList(lParam), @PathName);

      {display this path name in the status line of the dialog box}
      SendMessage(hWnd, BFFM_SETSTATUSTEXT, 0, longint(PChar(@PathName)));
      Result := 0;
   End;
   End { case uMsg };
   { case uMsg }

End; { BrowseCallback }


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Procedure FreePidl(pidl: PItemIDList);
Var
   allocator : IMalloc;
{ in ActiveX }
Begin { FreePidl }
   If Succeeded(SHGetMalloc(allocator)) Then
   Begin
      allocator.Free(pidl);
   End { Succeeded(SHGetMalloc(allocator)) };
End; { FreePidl }


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}

Function BrowseFolder(Var SelectedFolder: string; Const caption: string) : boolean;

Const
   ThisMethodName = 'BrowseFolder';
   
Type
   TCharArray = Array [0..MAX_PATH] Of Char;
   Var
   IDList      : ShlObj.PItemIDList; // an item identifier list
   BrowseInfo  : ShlObj.TBrowseInfo; // the browse info structure
   PathName    : TCharArray; // the path name
   DisplayName : TCharArray; // the file display name
   StartIn     : PChar;
   HomeDir     : string;
Begin 
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result  := false; 
   IDList  := Nil;
    
   HomeDir := GlobalDirectories.glDataDir;
   if not SetCurrentDir( HomeDir ) then
      LogUtil.LogMsg( lmDebug, UnitName, 'Error changing to '+HomeDir );

   if DebugMe then LogUtil.LogMsg( lmDebug, UnitName, 'Original Directory was '+HomeDir );
   
   If Copy(SelectedFolder, Length(SelectedFolder), 1) = '\' Then 
   Begin 
      SelectedFolder := Copy(SelectedFolder, 1, Length(SelectedFolder) - 1) 
   End { Copy(SelectedFolder, Length(SelectedFolder), 1) = '\' }; {strip off backslash} 

   GetMem(StartIn, MAX_PATH);
   Try
      StrpCopy(StartIn, SelectedFolder); 
      if DebugMe then LogUtil.LogMsg( lmDebug, UnitName, 'Starting Browser in '+SelectedFolder );
      
      {initialize the browse information structure} 
      BrowseInfo.hwndOwner := GetActiveWindow; 
      BrowseInfo.pidlRoot := Nil; 
      BrowseInfo.pszDisplayName := DisplayName; 
      BrowseInfo.lpszTitle := PChar(caption); 
      
      BrowseInfo.ulFlags := BIF_STATUSTEXT; // display a status line 
      BrowseInfo.lpfn := @BrowseCallback; 
      BrowseInfo.lParam := Integer(StartIn); 
      
      {show the browse for folder dialog box} 
      IDList := SHBrowseForFolder(BrowseInfo); 
      
      {retrieve the path from the item identifier list that was returned} 
      If IDList <> Nil Then 
      Begin 
         If SHGetPathFromIDList(IDList, @PathName) Then 
         Begin 
            Result := true; 
            SelectedFolder := PathName;
            if DebugMe then LogUtil.LogMsg( lmDebug, UnitName, 'User Selected '+SelectedFolder );
         End { SHGetPathFromIDList(IDList, @PathName) }; 
      End { IDList <> Nil }; 
   Finally 
      FreeMem(StartIn); 
      If IDList <> Nil Then 
      Begin 
         FreePidl(IDList) 
      End { IDList <> Nil }; 
      if not SetCurrentDir( HomeDir ) then
         LogUtil.LogMsg( lmDebug, UnitName, 'Error changing back to '+HomeDir );
   End { try }; 
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
End; { BrowseFolder } 


type
  TBankLinkFileOperation = class(TstFileOperation)
  private
     procedure OnFileOpError(Sender: TObject);
  public
     constructor Create(AOwner : TComponent); override;
  end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TBankLinkFileOperation.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   OnError := OnFileOpError;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TBankLinkFileOperation.OnFileOpError(Sender: TObject);
begin
   //
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function DeleteFileToRecycleBin(const FileName : string) : boolean;
//Deletes the file can puts a copy into the recycle bin if being deleted from
//a local drive.  Just deletes the file on a network drive.
//
//Uses the Windows shell file operations through systools
begin
   with TBankLinkFileOperation.Create(nil) do begin
      try
         Operation   := fOpDelete;
         Options     := [ foAllowUndo, foNoErrorUI, foNoConfirmation, foFilesOnly ];
         SourceFiles.Add(Filename);
         result := Execute;
      finally
         Free;
      end;
   end;
end;


Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
End.
