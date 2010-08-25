unit BasControls;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:         Bas Custom Controls

  Written:       Jan 2000
  Authors:       Matthew

  Purpose:       Custom Components for use in building the Australian Business
                 Activity Summary form.

  Notes:         These are custom visual controls which can be dropped onto
                 a form.

  TBasBoxField   Decends from TCustomControl
                 Is Part of the BankLink Package ( bk5pack.bpl )

                 Has the following published properties:
                      Caption           box caption
                      CaptionWidth      width of caption from control left
                      CaptionOffset     offset of caption from control left
                      BoxID             id code for box on the bas form
                      BoxIDWidth        width of ID field
                      ShowCurrency      is the currency symbol visible
                      ShowCaption       is the caption visible on the control
                      ShowBoxID         is the box id visible on the control

                 Font Size of control determines font size of ID and Currency
                 A constant is defined which specifies the Font Reduction Factor.
                 This factor is used to calculate the font size of the caption from
                 the font size of the control itself.

                 The caption is stored as a field and the split across x number
                 of labels.  The caption can contain the following special characters

                 <b>   bold this line
                 ~     new line

                 the labels will be right justified and vertically centered.

                 The label objects are stored in a dynamic array which holds the
                 pointer to the TLabel object.  The caption line labels are disposed
                 of and re allocated when the caption is changed.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  stdCtrls, OvcBase, OvcEF, OvcPB, OvcNF;

type
  TBasBoxField = class(TCustomControl)
  private
    { Private declarations }
    FlblBoxID       : TLabel;
    FlblCurrency    : TLabel;
    FNumericEdit    : TOvcNumericField;
    FStaticText     : TStaticText;
    FCaption        : string;
    FShowCurrency   : Boolean;
    FShowCaption    : Boolean;
    FShowID         : Boolean;
    FOffset         : integer;
    FCaptionWidth   : integer;
    FIDWidth        : integer;

    FCaptionLines     : array of TLabel;
    CaptionLinesCount : integer;
    FReadOnly: Boolean;
    FAsInteger: integer;
    procedure AllocateCaptionLines( Size : integer);
    procedure DisposeCaptionLines;

    procedure SetCaption(const Value: string);
    procedure SetBoxID(const Value: string);
    function  GetCaption: string;
    function  GetBoxID: string;
    procedure SetShowCaption(const Value: Boolean);
    procedure SetShowCurrency(const Value: Boolean);
    procedure SetShowID(const Value: Boolean);
    procedure SetCaptionWidth(const Value: integer);
    procedure SetOffset(const Value: integer);
    procedure SetIDWidth(const Value: integer);
    procedure PositionComponents;
    function GetController: TOvcController;
    procedure SetController(const Value: TOvcController);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetAsInteger(const Value: integer);
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetAsInteger: integer;
    function GetPictureMask: String;
    procedure SetPictureMask(Value : String);
    function GetEditBoxName: TComponentName;
    function GetLabelName: TComponentName;
    function GetBoxIDName: TComponentName;
    procedure SetEditBoxName(Value: TComponentName);
    procedure SetLabelName(Value: TComponentName);
    procedure SetBoxIDName(Value: TComponentName);
  protected
    procedure WmSize(var Message: TMessage); message WM_SIZE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  public
    constructor Create(AOwner : TComponent ); override;
    destructor Destroy; override;
    //publicly available but doesn't appear in object inspector
    property  NumericEdit : TOvcNumericField read FNumericEdit;
    property  StaticText  : TStaticText read FStaticText;
  published
    //public properties, appear in the object inspector
    property  Caption       : string read GetCaption write SetCaption;
    property  CaptionWidth  : integer read FCaptionWidth write SetCaptionWidth;
    property  CaptionOffset : integer read FOffset write SetOffset;
    property  BoxID         : string read GetBoxID write SetBoxID;
    property  BoxIDWidth    : integer read FIDWidth write SetIDWidth;

    property  ShowCurrency  : Boolean read FShowCurrency write SetShowCurrency default true;
    property  ShowCaption   : Boolean read FShowCaption write SetShowCaption default true;
    property  ShowBoxID     : Boolean read FShowID write SetShowID default true;

    property  PictureMask   : String  read GetPictureMask write SetPictureMask;

    property  ReadOnly      : Boolean read FReadOnly write SetReadOnly;
    property  AsInteger     : integer read GetAsInteger write SetAsInteger;
    property  OnChange : TNotifyEvent read GetOnChange write SetOnChange;

    //publish some properties from the numeric edit control
    property  Controller : TOvcController read GetController write SetController;

    //publish some custom control properties
    property  Font;
    property  ParentFont;
    property  ParentShowHint;
    property  TabOrder;
    property  TabStop;
    property  Tag;

    //publish properties to aid testing using Robot
    property  EditBoxName : TComponentName read GetEditBoxName write SetEditBoxName;
    property  LabelName : TComponentName read GetLabelName write SetLabelName;
    property  BoxIDName : TComponentName read GetBoxIDName write SetBoxIDName;
  end;

procedure Register;

//******************************************************************************
implementation
const
   Gap                 = 5;
   FontReductionFactor = 0.7;
   LineSeperatorChar   = '~';  //tilda
   BoldTag             = '<b>';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Register;
begin
  RegisterComponents('BankLink', [TBasBoxField]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TBasBoxField.Create(AOwner: TComponent);
begin
   inherited Create( AOwner);
   //setup defaults
   width          := 300;
   Height         := 50;
   Name           := ClassName;
   FOffset        := 30;
   FCaptionWidth  := 150;
   FIDWidth       := 30;
   FShowCurrency  := true;
   FShowID        := true;
   FShowCaption   := true;
   FReadOnly      := false;
   //Create ID TLabel
   FlblBoxID                := TLabel.Create( Self);
   FlblBoxID.parent         := Self;
   FlblBoxID.caption        := 'XX';
   FlblBoxID.Alignment      := taCenter;
   FlblBoxID.Font.Assign( Self.Font);
   FlblBoxID.Font.Style     := FlblBoxID.Font.Style + [fsBold];
   //Create TLabel for currency symbol
   FlblCurrency             := TLabel.Create( Self);
   FlblCurrency.parent      := Self;
   FlblCurrency.caption     := '$';
   FlblCurrency.Alignment   := taLeftJustify;
   FlblCurrency.Font.Style  := FlblCurrency.Font.Style + [fsBold];
   //Create static text box
   FStaticText              := TStaticText.Create( Self);
   FStaticText.Parent       := Self;
   FStaticText.BorderStyle  := sbsSunken;
   FStaticText.Visible      := false;
   FStaticText.Alignment    := taRightJustify;
   FStaticText.Transparent  := False;
   //Create edit box
   FNumericEdit             := TOvcNumericField.Create( Self);
   FNumericEdit.PictureMask := 'iiiiiiii';
   FNumericEdit.Parent      := Self;
   //Set caption, this will cause a position of all components
   Caption        := ClassName;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TBasBoxField.Destroy;
begin
   //make sure Tlabels are array are freed
   DisposeCaptionLines;
   inherited Destroy;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.AllocateCaptionLines(Size: integer);
//clears existing array, then sets the size of the array and creates each of
//the TLabel components
var
   i : integer;
begin
   //Clear any existing label array
   DisposeCaptionLines;
   //Allocation space for pointers
   SetLength(FCaptionLines,Size);
   CaptionLinesCount := Size;
   //Create a TLabel object for each array position
   for i := 0 to Pred(Size) do begin
      FCaptionLines[i] := TLabel.Create( Self);
      FCaptionLines[i].Parent      := Self;
      FCaptionLines[i].Alignment   := taRightJustify;
      //dont show automatic underline
      FCaptionLines[i].ShowAccelChar := false;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.CMFontChanged(var Message: TMessage);
//responds to the windows message for font being changed.  Is needed because
//ParentFont will not be set to TRUE for each of the components contained in this
//control
var
   I : integer;
begin
  inherited;
  //now alter fields to use same font.  they will not be automatically updated
  //because the ID and currency labels have style bold, this means that ParentFont
  //property is false
  FlblCurrency.Font.Assign( Self.Font);
  FlblCurrency.Font.Style := FlblCurrency.Font.Style + [fsBold];
  FlblBoxID.Font.Assign( Self.Font);
  FlblBoxID.Font.Style := FlblBoxID.Font.Style + [fsBold];
  //change font for caption lines.  This should always be a fraction of the height
  //of the normal font
  for i := 0 to Pred( CaptionLinesCount) do begin
     FCaptionLines[i].Font.Name := Self.Font.Name;
     FCaptionLines[i].Font.Size := Round( Self.Font.Size * FontReductionFactor);
  end;
  //Re align everything
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.DisposeCaptionLines;
//used to free each of the labels and the free the memory held by the array
var
   i : integer;
begin
    //Hide the labels so that no AV's occur if try to repaint
    for i := 0 to Pred( CaptionLinesCount) do
       FCaptionLines[i].Hide;
    //Free the lables
    for i := 0 to Pred( CaptionLinesCount) do
       FCaptionLines[i].Free;
    //Resize the Array
    SetLength(FCaptionLines,0);
    CaptionLinesCount := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasBoxField.GetCaption: string;
begin
   result := FCaption;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasBoxField.GetBoxID: string;
begin
   result := FlblBoxID.Caption;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.PositionComponents;
{positions the components within the size bounds of the control

 Must be called after changes to
    size of control
    offset
    caption width
    font size change

  FCaptionLines - individual Tlabel objects for each new line in the caption

  FlblBoxID
      centred vert, centered, autosize on, can be hidden

  FlblCurrency
      centered vert, right justified, autosize on,  can be hidden

  FNumericEdit
      centered vert, right justified

  Layout Rules

  --------------------------------------------
  |        |Caption   |  1A  |     $|[      ]|
  --------------------------------------------
  |<- Wm ->|

  |<-   Wd          ->|< Wi >|< Wc >|<  We  >|

  Wd = width of description   user defined thru property
  Wm = width of offset        user defined thru property
  Wi = width of ID            user defined thru property
  Wc = width of Currency      calculated from label size
  We = width of Edit Box      calculated remainder available

  There will be a small gap better each component. this is defined as a constant
}

var
  CurrLeft     : integer;
  TotalHeight  : integer;
  CurrTop      : integer;
  i            : integer;

  NumLines     : integer;

begin
  CurrLeft := 0;
  if FShowCaption then begin
     //position horiz and then calc total height required
     NumLines := Pred( CaptionLinesCount);
     TotalHeight := 0;
     for i := 0 to NumLines do begin
        FCaptionLines[i].Left := FOffset;
        FCaptionLines[i].Width := ( FCaptionWidth - FOffset);
        TotalHeight := TotalHeight + FCaptionLines[i].height;
     end;
     //Now position so that the block of caption lines is vertically centered
     CurrTop := ( Self.Height - TotalHeight) div 2;
     for i := 0 to NumLines do begin
        FCaptionLines[i].Top := CurrTop;
        CurrTop := CurrTop + FCaptionLines[i].Height;
     end;
     CurrLeft := (FCaptionWidth + Gap);
  end;

  if FShowID then begin
     //width of ID field set by user or default
     FlblBoxID.Left := CurrLeft;
     FlblBoxID.Width := ( FIDWidth);
     //Move currleft to position of next control
     CurrLeft := ( CurrLeft + FlblBoxID.Width + Gap);
     //Center vertically
     FlblBoxID.top := (Self.Height - FlblBoxID.Height) div 2;
  end;

  if FShowCurrency then begin
     //text width of Currency can be set automatically
     FlblCurrency.Left := CurrLeft;
     CurrLeft := ( CurrLeft + FlblCurrency.Width + Gap);
     //Center vertically
     FlblCurrency.top := (Self.Height - FlblCurrency.Height) div 2;
  end;

  if not ReadOnly then begin
     //Edit Box should take up all remaining space
     FNumericEdit.Left  := CurrLeft;
     FNumericEdit.Width := self.width - currleft;
     //Center vertically
     FNumericEdit.top    := (Self.Height - FNumericEdit.Height) div 2;

     if ( csDesigning in Self.ComponentState) then
        FStaticText.Width   := 0;
  end
  else begin
     //Static Text box should be same horiz size as numeric edit, height will be
     //set by autosize
     FStaticText.Left    := CurrLeft;
     FStaticText.Width   := (Self.width - currleft);
     FStaticText.Top     := (Self.Height - FStaticText.Height) div 2;

     if ( csDesigning in Self.ComponentState) then
        FNumericEdit.Width := 0;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetCaption(const Value: string);
//called when the Caption property is changed
var
   i           : integer;
   s           : string;
   CurrCaption : string;
   Lines       : TStringList;
begin
  FCaption         := Value;
  if caption <> '' then begin
     //split into strings
     Lines := TStringList.Create;
     try
        //fill captions
        s := Value;
        //seperate into individual lines
        while Pos( LineSeperatorChar, s ) > 0 do begin
           CurrCaption := Copy( s, 0, Pos( LineSeperatorChar, s) -1);
           if CurrCaption <> '' then
              Lines.Add( CurrCaption);
           s := Copy(s, Pos( LineSeperatorChar, s)+1, Length(s));
        end;
        //Add remaining line once no seperators found
        if s <> '' then Lines.Add( s);
        //Allocate space for array and create labels
        AllocateCaptionLines( Lines.Count);
        //Set caption values, look for bold tag
        for i := 0 to Pred(Lines.Count) do begin
           CurrCaption := Lines[i];
           if Pos( BoldTag, CurrCaption) > 0 then begin
              FCaptionLines[i].Font.Style := Font.Style + [fsBold];
              CurrCaption  := Copy( CurrCaption, Length( BoldTag)+1, length( CurrCaption));
           end;
           FCaptionLines[i].Caption   := CurrCaption;
           FCaptionLines[i].Font.Size := Round( Font.Size * FontReductionFactor);
        end;
     finally
        Lines.Free;
     end;
  end;
  //reposition lbldescription vertically as number of lines may have changed
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetCaptionWidth(const Value: integer);
begin
  FCaptionWidth := value;
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetBoxID(const Value: string);
begin
  FlblBoxID.caption := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetIDWidth(const Value: integer);
begin
  FIDWidth := Value;
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetOffset(const Value: integer);
begin
  FOffset := Value;
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetShowCaption(const Value: Boolean);
var
   i : integer;
begin
  FShowCaption := Value;
  //make caption lines invisible
  for i := 0 to Pred( CaptionLinesCount) do begin
     FCaptionLines[i].Visible := value;
     //can't set invisible in design mode so set width to 0, will be reset in position if visible
     FCaptionLines[i].Width   := 0;
  end;
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetShowCurrency(const Value: Boolean);
begin
  FShowCurrency := Value;
  FlblCurrency.Visible := value;
  //can't set invisible in design mode so set width to 0, will be reset in position if visible
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetShowID(const Value: Boolean);
begin
  FShowID := Value;
  FlblBoxID.visible := value;
  //can't set invisible in design mode so set width to 0, will be reset in position if visible
  FlblBoxID.width   := 0;
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.WmSize(var Message: TMessage);
begin
  inherited;
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasBoxField.GetController: TOvcController;
begin
   result := FNumericEdit.Controller;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetController(const Value: TOvcController);
begin
   FNumericEdit.Controller := value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  //Hide the edit box and show the Label over the top
  FNumericEdit.Visible := not value;
  FStaticText.Visible  := value;
  FStaticText.Color    := clBtnFace;

  if ( csDesigning in Self.ComponentState) then begin
     if not FNumericEdit.Visible then
        FNumericEdit.Width := 0;

     if not FStaticText.Visible then
        FStaticText.Width := 0;
  end;
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetAsInteger(const Value: integer);
begin
  FAsInteger := Value;
  //Test to see if the controller has been assigned yet.  If not just update
  //the label
  if Assigned( FNumericEdit.Controller) then begin
     FNumericEdit.AsInteger  := value;
     FStaticText.Caption     := FNumericEdit.DisplayString;
  end
  else
     FStaticText.Caption     := IntToStr(Value);
  //Reposition as alignment may have changed
  PositionComponents;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasBoxField.GetOnChange: TNotifyEvent;
begin
   result := FNumericEdit.OnChange;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetOnChange(const Value: TNotifyEvent);
begin
   FNumericEdit.OnChange := value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasBoxField.GetAsInteger: integer;
begin
   if (not ReadOnly) and (Assigned( FNumericEdit.Controller)) then begin
      FAsInteger := FNumericEdit.AsInteger;
   end;
   result := FAsInteger;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasBoxField.GetPictureMask: String;
begin
  Result := FNumericEdit.PictureMask;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBasBoxField.SetPictureMask(Value: String);
begin
   FNumericEdit.PictureMask := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBasBoxField.GetEditBoxName: TComponentName;
begin
  Result := FNumericEdit.Name;
end;

function TBasBoxField.GetLabelName: TComponentName;
begin
  Result := FStaticText.Name;
end;

function TBasBoxField.GetBoxIDName: TComponentName;
begin
  Result := FlblBoxID.Name;
end;

procedure TBasBoxField.SetEditBoxName(Value: TComponentName);
begin
  FNumericEdit.Name := Value;
end;

procedure TBasBoxField.SetLabelName(Value: TComponentName);
begin
  FStaticText.Name := Value;
end;

procedure TBasBoxField.SetBoxIDName(Value: TComponentName);
begin
  FlblBoxID.Name := Value;
end;

end.
