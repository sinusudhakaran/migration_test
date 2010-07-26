unit ImportExtraDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ Purpose:
  ---------

  This unit will provide the functionality to Import multiple update files into
  the current client.  An update file contains transactions for a particular
  bank account that have not be processed into the client file for some reason.

  Examples:

    pending transactions may have been missed out in earlier versions of
    the upgrade from bk4 to bk5.

    a practise may a split and want historical transactions that are in our
    production system

  Process:
  -----------------------

  The process for Importing an update file is as follows

  1) An update file or files will be created from the production system and sent
     to the banklink client

  2) The user will go to Other Functions | House Keeping | Import Update File
     to start the process.  They will be presented with an empty selection box
     and need to select a path to Import files from.

  3) Each of the files found in the directory will be checked to see if they
     are valid.  An update file will be rejected if

             (i)   the file header cannot be read
             (ii)  the file is for the wrong country

  4) Valid files will be placed into a single select list box from the user can
     select a file to Import.

  5) Selected file will be checked to ensure that the date range of the update
     transactions does not match any existing transactions for the bank account.
     A warning will be given for files that are have invalid dates or cannot be
     read, and the file will be skipped.

  6) The transactions will be read out of the file and inserted into a
     temporary transaction list before inserting into the bank account.  This
     will allow any errors in that file to be handled before changes occur
     to the bank account.  A file will be skipped if it an error occurs.

  7)  The user will return to the selection dialog to import any further files.
      if no other valid files exist the box will terminate.

  Design considerations:
  ----------------------

  Error Handling

  EInOut error will be cause while reading the file header and during the
  first stage of the import when transactions are read into a temp list

  Any exception that occurs during the actual Importing of the transactions
  will be treated as a critical error.

  Notes:
  ------

  Uses routines for ImportExtra.pas for building the list and importing
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, OvcBase, ComCtrls, StdCtrls, ExtCtrls,
  OSFont;

type
  TdlgImportUpdate = class(TForm)
    Bevel1: TBevel;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    ePath: TEdit;
    lvFiles: TListView;
    OvcController1: TOvcController;
    btnFolder: TSpeedButton;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure ePathEnter(Sender: TObject);
    procedure ePathExit(Sender: TObject);
  private
    { Private declarations }
    TempPath  : string;

    procedure SetupHelp;
    procedure RefreshList;
  public
    { Public declarations }
  end;

  procedure DoImportUpdateFiles;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes,
  LogUtil,
  Globals,
  ShellUtils,
  Warningmorefrm,
  ErrorMoreFrm,
  InfoMoreFrm,
  GenUtils,
  bkConst,
  bkDateUtils,
  MoneyDef,
  ImagesFrm,
  baObj32,
  lvUtils,
  bkdefs,
  UpdateMF,
  StdHints,
  ImportExtra;   //Important Unit

const
  UnitName = 'IMPORTEXTRADLG';
var
  DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  TempPath := '';
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFolder.Glyph);
  SetListViewColWidth(lvFiles,4);  //adjust column status
  SetupHelp;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.SetupHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   btnFolder.Hint   :=
                 STDHINTS.DIRBUTTONHINT;
   ePath.Hint       :=
                'Enter a directory path to import Update File(s) from|'+
                'Enter a directory path to import Update File(s) from';
   lvFiles.Hint    :=
                'Select Update File to import|'+
                'Select an Update File to import';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.btnFolderClick(Sender: TObject);
var
  test  : string;
begin
  test := ePath.Text;
  if BrowseFolder(test, 'Select a folder to import Update File(s) from') then
  begin
    ePath.Text := test;
    TempPath   := test;

    RefreshList;  //reload from new directory
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.btnOKClick(Sender: TObject);
var
  FilePath : string;
  FileName : string;
  IndexToDelete : integer;
  Status        : integer;
  aMsg          : string;
begin
  ePathExit( Self ); //Ensure that OnExit Method for Dir path Box fired - Enter defaults OkButton

  if lvFiles.SelCount = 0 then
  begin
      RefreshList;
      exit;
  end;

  //check that directory is valid}

  FilePath := AddSlash( Uppercase( ePath.Text ) );  { Browse doesn't add the slash for you }
  FilePath := ExtractFilePath( FilePath );

  if not (FilePath = 'A:\') then begin
    if not DirectoryExists( FilePath ) then  begin
      HelpfulWarningMsg('The Directory '+FilePath+' does not exist.  Please enter a valid directory path.',0);
      ePath.Setfocus;
      exit;
    end;
  end;

  //if a file has been selected and the directory is valid then try to
  //Import the update
  Filename := AddSlash( FilePath ) + lvFiles.Selected.Caption;
  Status   := Integer(lvFiles.Selected.SubItems.Objects[0]);

  if Status = usOKtoImport then
  begin
    if ImportUpdateFile(FileName) then
    begin
       //once imported remove the file from the list being displayed
       lvFiles.Selected.SubItems.Objects[0] := TObject(usInvalidDates);
       IndexToDelete := lvfiles.Items.IndexOf(lvFiles.Selected);
       lvFiles.Items.Delete(IndexToDelete);
    end;
  end
  else
  begin
    case Status of
       usInvalidDates : begin
         aMsg := 'This Update File contains entries with dates which overlap existing transactions in the Bank Account.  '+
                 'Importing this File may result in duplicated transactions.';
       end;

       usUnknownAccount : begin
         aMsg := 'The current Client File does not contain this Bank Account.  You cannot import transactions '+
                 'for an unknown Bank Account.';
       end;

       usErrorInFile : begin
         aMsg := 'Unable to import update file.  There is a problem with the file.';
       end;
    else
      aMsg := 'Unable to import update file. Unknown Error';
    end;

    HelpfulErrorMsg( aMsg, 0);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.ePathEnter(Sender: TObject);
// Save Existing Path
begin
   TempPath := ePath.Text;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.ePathExit(Sender: TObject);
//if the path has changed the clear any selection
begin
   if not ( TempPath = ePath.Text ) then begin
     TempPath := ePath.Text;
     lvFiles.Selected := nil;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgImportUpdate.RefreshList;
const
   ThisMethodName  = 'TDlgImportUpdate.RefreshList';
   UPDATE_WILDCARD = '*.UP2';
var
  DirPath : string;
  SearchRec : TSearchRec;
  Found     : integer;
  NewItem   : TListItem;

  D1,D2     : integer;
  Account   : string;
  Status    : byte;
begin
  lvFiles.Items.BeginUpdate;
  MsgBar('Loading Update File list',true);
  try
     lvFiles.Items.Clear;

     //read items from path directory - check path has trailing backslash \
     DirPath := AddSlash(ePath.Text);
     if not DirectoryExists(DirPath) then exit;

     //Load the file list using the information contained in each wrapper
     Found := FindFirst(DirPath+UPDATE_WILDCARD, faAnyFile, SearchRec);
     try
        while Found = 0 do begin
          if ShowUpdateFileInListBox(DirPath+SearchRec.Name, Account, D1,D2, Status) then begin
            //create a new entry in the list
            NewItem := lvFiles.Items.Add;
            with NewItem do begin
              Caption    := SearchRec.Name;
              SubItems.AddObject(Account,TObject(Status));
              SubItems.Add(bkDate2Str(D1));
              SubItems.Add(bkDate2Str(D2));
              SubItems.Add(usNames[Status]);

              if ( Status = usOkToImport ) then
                 ImageIndex := MISC_FILE_BMP
              else
                 ImageIndex := MISC_BADFILE_BMP;
            end;
          end;
          Found := FindNext(SearchRec);
        end;
     finally
        FindClose(SearchRec);
     end;

     if lvFiles.Items.Count = 0 then
       HelpfulInfoMsg('No Update Files were found in this directory.',0);

  finally
    lvFiles.Items.EndUpdate;
    MsgBar('',false);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoImportUpdateFiles;
const
   ThisMethodName = 'ImportUpdateFile';
begin
   if not Assigned(MyClient) then exit;

   //create and show the selection dialog
   with TdlgImportUpdate.Create(Application.MainForm) do begin
     try
        ShowModal;
     finally
        Free;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
