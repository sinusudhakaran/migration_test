unit selectTRFcheckinfrm;

//------------------------------------------------------------------------------
interface

uses
  Registryutils,
  Windows,
  FileWrapper,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
  TOpenWith = (OW_BNotes, OW_BK5_Path);
  // May include Path or DDE options later..
  TOpenOptions = set of TOpenWith;

type
  TSelectTRFcheckinform = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GBBNotes: TGroupBox;
    GroupBox1: TGroupBox;
    LBBK5Paths: TListBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    LBLTRFFile: TLabel;
    RBBnotes: TRadioButton;
    RBBK5: TRadioButton;
    procedure LBBK5PathsClick(Sender: TObject);
    procedure LBBK5PathsDblClick(Sender: TObject);
    procedure CBBK5Click(Sender: TObject);
    procedure CBBNotesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FOpenWith: TOpenwith;
    FClientCode: String;
    FTRFFile : TFilename;
    FOpenOptions: TOpenOptions;
    procedure SetOpenWith(const Value: TOpenwith);
    procedure SetTRFFile(const Value: TFilename);
    function GetBK5Paths: String;
    procedure SetBK5Paths(const Value: String);
    function GetBK5Path: String;
    procedure SetBK5Path(const Value: String);
    procedure SetClientCode(const Value: String);
    procedure SetOpenOptions(const Value: TOpenOptions);
    { Private declarations }
  public
    { Public declarations }
    property OpenWith : TOpenwith read FOpenWith write SetOpenWith;
    property OpenOptions : TOpenOptions read FOpenOptions write SetOpenOptions;
    property TRFFile : TFilename read FTRFFile write SetTRFFile;
    property ClientCode : String read FClientCode write SetClientCode;
    property BK5Paths : String read GetBK5Paths write SetBK5Paths;
    property BK5Path : String read GetBK5Path write  SetBK5Path;
    function Execute : TModalResult;
  end;

  //----------------------------------------------------------------------------
  Function SelectOpenWith(Var ABK5path : String;
                          Var OpenWith : TOpenWith;
                          OpenOptions : TOpenOptions;
                          Const ATRFFile, BK5Paths : String) : Boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}
uses
  BKHandConsts;

//------------------------------------------------------------------------------
function SelectOpenWith(Var ABK5path : String;
                        Var OpenWith : TOpenWith;
                        OpenOptions : TOpenOptions;
                        Const ATRFFile, BK5Paths : String) : Boolean;
var
  dlg : TSelectTRFcheckinform;
begin
  result := False;
  dlg := TSelectTRFcheckinform.Create( Application);
  try
    //fill it
    dlg.OpenOptions := OpenOptions;
    dlg.BK5Paths := BK5Paths;
    dlg.TRFFile  := ATRFFile;
    //dlg.OpenWith := OW_BNotes; done in OpenOptions

    if dlg.Execute = mrOK then begin
       OpenWith := dlg.OpenWith;
       case dlg.OpenWith of
       OW_BNotes  : begin
                   ABK5path := '';
                end;
       OW_BK5_Path  : begin
                    ABK5path := Dlg.BK5Path;
                end;
       end;
       Result := true;
    end;
  finally
    dlg.Release;
  end;
end;

{ TSelectTRFcheckinform }
//------------------------------------------------------------------------------
function TSelectTRFcheckinform.GetBK5Path: String;
begin
   result := '';
   if LBBK5Paths.ItemIndex < 0 Then begin
      if LBBK5Paths.Count > 0 then
         LBBK5Paths.ItemIndex := 0
      else
         Exit;
   end;
   Result := LBBK5Paths.Items[ LBBK5Paths.ItemIndex];
end;

//------------------------------------------------------------------------------
function TSelectTRFcheckinform.GetBK5Paths: String;
begin
   result := LBBK5Paths.Items.Text;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.SetBK5Path(const Value: String);
begin
   If Length(Value) > 0 then
   LBBK5Paths.ItemIndex := LBBK5Paths.Items.IndexOf(Value);
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.SetBK5Paths(const Value: String);
begin
   LBBK5Paths.Items.Text := Value;
   if LBBK5Paths.Items.Count > 0 Then
     LBBK5Paths.ItemIndex := 0;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.SetOpenWith(const Value: TOpenwith);
begin
   if Value in OpenOptions Then begin
      fopenWith := Value;
      case fopenWith of
        OW_BNotes: begin
               RBBNotes.Checked := True;
               RBBK5.Checked := False;
            end;
        OW_BK5_Path: begin
               RBBNotes.Checked := False;
               RBBK5.Checked := True;
            end;
     end;
   end;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.SetTRFFile(const Value: TFilename);
Var LWrapper : TWrapper;
begin
   LBLTRFFile.Caption := ExtractFilename(Value);
   if GetWrapper( Value, LWrapper) then begin
      ClientCode := LWrapper.wCode;

      Caption :=
           'Process ' + BRAND_NOTES_NAME + ' file: ' +
           LBLTRFFile.Caption  +
           ' for: ' +  ClientCode;
   end else begin
      ClientCode := '';

      Caption :=
           'Process ' + BRAND_NOTES_NAME + ' file: ' +
           LBLTRFFile.Caption;

   end;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.CBBNotesClick(Sender: TObject);
begin
   if RBBNotes.Checked then
      OpenWith := OW_BNotes
   else
      Openwith := OW_BK5_Path;

end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.CBBK5Click(Sender: TObject);
begin
  if RBBK5.Checked Then
     OpenWith := OW_BK5_Path
  else
     OpenWith := OW_BNotes;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.SetClientCode(const Value: String);
begin
  FClientCode := Value;
end;

//------------------------------------------------------------------------------
function TSelectTRFcheckinform.Execute: TModalResult;
  //----------------------------------------------------------------------------
  function pathFailed (Apath : TFilename) : Boolean;
  begin
    Result := NOT FileExists(APath + Clientcode + '.bk5');
  end;
var
  Li : Integer;
begin
   result := mrok;
   // Check what we have so far...
   if (OW_BK5_Path In OpenOptions)
   and (length(ClientCode) > 0)
   and (LBBK5Paths.Count > 1 ) then begin
      // see if we can eliminate any.. Could keep a Changed flag...
      for LI := pred(LBBK5Paths.Items.Count) downto 0 do begin
         if PathFailed (LBBK5Paths.Items[Li]) then
           LBBK5Paths.Items.Delete(Li);
      end;
      // May need to recheck what options are left...
      if NOT (OW_BNotes in OpenOptions) then begin
         if LBBK5Paths.Items.Count = 0 then begin // Oh dear...
            result := mrCancel;
            Exit; // nowhere to go...
         end else if LBBK5Paths.Items.Count = 1 then begin
            // Only one option left..
            LBBK5Paths.ItemIndex := 1;
            OpenWith := OW_BK5_Path;
            Exit;
         end;
      end else begin
         // BNotes still an option
         if LBBK5Paths.Items.Count = 0 then begin
            OpenWith := OW_BNotes;
            Exit;
         end;
      end;
   end;

   Result := Showmodal;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.FormCreate(Sender: TObject);
begin
  RBBnotes.Caption := '&Open with ' + BRAND_NOTES_NAME;
  RBBK5.Caption := '&Import into ' + BRAND_NAME;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.SetOpenOptions(const Value: TOpenOptions);

  //----------------------------------------------------------------------------
  procedure EnableBNotes (Enable : Boolean);
  begin
     RBBNotes.Enabled := Enable;
  end;

  //----------------------------------------------------------------------------
  procedure EnableBK5 ( Enable : Boolean);
  begin // ?? Should never happen at this stage..
        // No pint running the dialog if BNotes is the only option..
     RBBK5.Enabled := Enable;
     LBBK5Paths.Enabled := Enable;
  end;

begin
  FOpenOptions := Value;
  EnableBNotes (OW_BNotes in FOpenOptions);
  EnableBK5    (OW_BK5_Path in FOpenOptions);
  if OW_BNotes in FOpenOptions then
     Openwith := OW_BNotes
  else
     Openwith := OW_BK5_Path
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.LBBK5PathsDblClick(Sender: TObject);
begin
  modalresult := mrOK;
end;

//------------------------------------------------------------------------------
procedure TSelectTRFcheckinform.LBBK5PathsClick(Sender: TObject);
begin
  OpenWith := OW_BK5_Path;
end;

end.
