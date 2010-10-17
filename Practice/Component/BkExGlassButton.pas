unit BkExGlassButton;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, stdCtrls, AdvGlassButton, GDIPicture, Windows,
  Graphics, Messages,Forms, Dialogs;

type
  TAdvGlassButtonEx = class(TAdvGlassButton)
    published
      property OnKeyDown;
      property OnKeyUp;
      property OnKeyPress;
      property OnEnter;
      property OnExit;
  end;

type
  tbkExGlassButton = class(TCustomPanel)
  private
    { Private declarations }
    FLabelControl : TLabel;
    FGlassButton : TAdvGlassButtonEx;
    FCaption: string;
    FButtonColor: TColor;
    FButtonSize: integer;
    FOnButtonKeyUp: TKeyEvent;
    FLabelCaption: string;
    FLabelVisible: boolean;
    FImageVisible: boolean;
    FButtonFontColor: TColor;
    FLabelFontColor: TColor;
    FButtonFontSize: integer;
    FLabelFontSize: integer;
    FTickImage : TImage;
    FButtonHorizMargin: integer;
    FButtonVertMargin: integer;
    FLabelHeight: integer;
    FResizing : boolean;
    FUpdating : boolean;
    FOnButtonKeyDown: TKeyEvent;
    FOnButtonKeyPress: TKeyPressEvent;

    procedure SetCaption(const Value: string);
    procedure SetButtonColor(const Value: TColor);
    procedure PositionComponents;
    procedure SetButtonSize(const Value: integer);
    procedure ArrowKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ArrowKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoButtonKeypress(Sender : TObject; var Key : Char);
    procedure SetOnButtonKeyUp(const Value: TKeyEvent);
    procedure ButtonEnter(Sender: TObject);
    procedure ButtonExit(Sender: TObject);
    procedure SetLabelCaption(const Value: string);
    procedure SetLabelVisible(const Value: boolean);
    procedure SetImageVisible(const Value: boolean);
    procedure SetButtonFontColor(const Value: TColor);
    procedure SetButtonFontSize(const Value: integer);
    procedure SetLabelFontColor(const Value: TColor);
    procedure SetLabelFontSize(const Value: integer);
    procedure SetButtonHorizMargin(const Value: integer);
    procedure SetButtonVertMargin(const Value: integer);
    procedure SetLabelHeight(const Value: integer);
    procedure SetOnButtonKeyDown(const Value: TKeyEvent);
    procedure SetOnButtonKeyPress(const Value: TKeyPressEvent);
    function GetOnClick: TNotifyEvent;
    procedure SetOnClick(const Value: TNotifyEvent);
  protected
    { Protected declarations }
    procedure WmSize(var Message: TMessage); message WM_SIZE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent ); override;
    destructor Destroy; override;

    procedure SetImagePicture( PictureToUse : TPicture);
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    { Published declarations }
    property ButtonCaption : string read FCaption write SetCaption;
    property ButtonColor : TColor read FButtonColor write SetButtonColor;
    property ButtonSize : integer read FButtonSize write SetButtonSize default 150;
    property ButtonFontColor :TColor read FButtonFontColor write SetButtonFontColor;
    property ButtonFontSize : integer read FButtonFontSize write SetButtonFontSize default 16;
    property ButtonVertMargin : integer read FButtonVertMargin write SetButtonVertMargin default 10;
    property ButtonHorizMargin : integer read FButtonHorizMargin write SetButtonHorizMargin default 10;

    property LabelCaption : string read FLabelCaption write SetLabelCaption;
    property LabelVisible : boolean read FLabelVisible write SetLabelVisible default False;
    property LabelFontColor : TColor read FLabelFontColor write SetLabelFontColor default clGray;
    property LabelFontSize : integer read FLabelFontSize write SetLabelFontSize default 10;
    property LabelHeight : integer read FLabelHeight write SetLabelHeight default 20;

    property ImageVisible : boolean read FImageVisible write SetImageVisible default False;

    property  Font;
    property  ParentFont;
    property  ParentShowHint;
    property  ParentColor;
    property  ParentBackground;
    property  TabOrder;
    property  TabStop default False;
    property  Tag;
    property  OnEnter;
    property  OnExit;
    property  Align;
    property  Anchors;

    property Action;
    property Constraints;
    property Enabled;
    property ParentBiDiMode;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick : TNotifyEvent read GetOnClick write SetOnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;

    property  OnButtonKeyUp : TKeyEvent read FOnButtonKeyUp write SetOnButtonKeyUp;
    property  OnButtonKeyDown : TKeyEvent read FOnButtonKeyDown write SetOnButtonKeyDown;
    property  OnButtonKeyPress : TKeyPressEvent read FOnButtonKeyPress write SetOnButtonKeyPress;
  end;

procedure Register;

implementation


{ tbkExGlassButton }

procedure tbkExGlassButton.ArrowKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //now need to move to next/previous control
  if Assigned( FOnButtonKeyUp) then
  begin
     FOnButtonKeyUp( Sender, Key, Shift);
  end;
end;

procedure tbkExGlassButton.ArrowKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //now need to move to next/previous control
  if Assigned( FOnButtonKeyDown) then
  begin
     FOnButtonKeyDown( Sender, Key, Shift);
  end;
end;


procedure tbkExGlassButton.BeginUpdate;
begin
  FUpdating := true;
end;

procedure tbkExGlassButton.ButtonEnter(Sender: TObject);
begin
  FGlassButton.OuterBorderColor := clHighlight;
end;

procedure tbkExGlassButton.ButtonExit(Sender: TObject);
begin
  FGlassButton.OuterBorderColor := clWhite;
end;

procedure tbkExGlassButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  FGlassButton.Enabled := Self.Enabled;
end;

procedure tbkExGlassButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
end;

constructor tbkExGlassButton.Create(AOwner: TComponent);
begin
   inherited Create( AOwner);
   //setup defaults
   Name           := ClassName;
   BevelOuter     := bvNone;
   Caption        := '';

   //create tick image
   FTickImage := TImage.Create(Self);
   FTickImage.Parent   := Self;
   FTickImage.AutoSize := true;
   FTickImage.Transparent := true;

   //Create button
   FGlassButton := TAdvGlassButtonEx.Create(Self);
   FGlassButton.parent        := Self;
   FGlassButton.TabStop       := true;
   FGlassButton.ShowFocusRect := true;
   FGlassButton.OnKeyUp       := ArrowKeyUp;
   FGlassButton.OnKeyDown     := ArrowKeyDown;
   FGlassButton.OnKeyPress    := DoButtonKeyPress; 
   FGlassButton.OnEnter       := ButtonEnter;
   FGlassButton.OnExit        := ButtonExit;
   FGlassButton.Caption       := name;

   //create sub label
   FLabelControl := TLabel.Create( Self);
   FLabelControl.parent      := Self;
   FLabelControl.caption     := 'Status';
   FLabelControl.Alignment   := taCenter;
   FLabelControl.AutoSize    := false;
   FLabelControl.WordWrap    := true;

   BeginUpdate;
     ButtonSize := 150;
     ButtonFontSize := 16;
     ButtonFontColor := clWhite;
     LabelFontSize := 8;
     LabelFontColor := clGray;
   EndUpdate;  //triggers a reposition
end;

destructor tbkExGlassButton.Destroy;
begin
  inherited Destroy;
end;

procedure tbkExGlassButton.DoButtonKeypress(Sender: TObject; var Key: Char);
begin
  //now need to move to next/previous control
  if Assigned( FOnButtonKeyPress) then
  begin
     FOnButtonKeyPress( Sender, Key);
  end;
end;

procedure tbkExGlassButton.EndUpdate;
begin
  FUpdating := false;
  PositionComponents;
end;

function tbkExGlassButton.GetOnClick: TNotifyEvent;
begin
  result := FGlassButton.OnClick;
end;

procedure tbkExGlassButton.PositionComponents;
const
  MinButtonSize = 75;
  MinFontSize = 8;
var
  RequiredWidth, RequiredHeight : integer;
  ParentWidth, ParentHeight : integer;
  vPadding, hPadding : integer;
  ButtonSizeToDraw : integer;    //used when positioning and space if too small
  FontSizeToUse    : integer;
  LabelFontSizeToUse : integer;
  vDiff, hDiff, xDiff : integer;
begin
    if not (FResizing or FUpdating) then
    begin
      FResizing := true;

      ParentWidth := Self.Width;
      ParentHeight := Self.Height;

      //turn off alignment
      FGlassButton.Anchors := [];
      FLabelControl.Anchors := [];
      FLabelControl.Align := alNone;
      FTickImage.Anchors := [];

      ButtonSizeToDraw := FButtonSize;
      FontSizeToUse    := FButtonFontSize;
      LabelFontSizeToUse := FLabelFontSize;

      //figure out if button size will fit within container
      //button and label should be vertically centered
      //button and label should be horizontally centered
      RequiredWidth := ButtonSizeToDraw + (2 * FButtonHorizMargin);
      RequiredHeight := ButtonSizeToDraw + (2 * FButtonVertMargin) + FLabelControl.Height;

      if (ParentWidth < RequiredWidth) or (ParentHeight < RequiredHeight) then
      begin
        //parent is not big enough, resize button and/or label
        vDiff := RequiredHeight - ParentHeight;
        hDiff := RequiredWidth - ParentWidth;

        //pick the direction with the biggest different
        if vDiff > hDiff then
          xDiff := vDiff
        else
          xDiff := hDiff;

        ButtonSizeToDraw := FButtonSize - (xDiff + 2);// - (FLabelControl.Height div 2);
        if ButtonSizeToDraw < MinButtonSize then
          ButtonSizeToDraw := MinButtonSize;

        FontSizeToUse := Round( FButtonFontSize * (ButtonSizeToDraw / FButtonSize));
        if FontSizeToUse < MinFontSize then
          FontSizeToUse := MinFontSize;

        LabelFontSizeToUse := Round( LabelFontSizeToUse * (ButtonSizeToDraw / FButtonSize));
        if LabelFontSizeToUse < MinFontSize then
          LabelFontSizeToUse := MinFontSize;

        RequiredWidth := ButtonSizeToDraw + (2 * FButtonHorizMargin);
        RequiredHeight := ButtonSizeToDraw + (2 * FButtonVertMargin) + FLabelControl.Height;
      end;

      //sizing sorted out now, do final positioning
      vPadding := (ParentHeight - RequiredHeight) div 2;
      hPadding := (ParentWidth - RequiredWidth) div 2;

      //set the component sized based of the button size
      FGlassButton.Top := FButtonVertMargin + vPadding;
      FGlassButton.Left := FButtonHorizMargin + hPadding;
      FGlassButton.Width := ButtonSizeToDraw;
      FGlassButton.Height := ButtonSizeToDraw;
      FGlassButton.Font.Size := FontSizeToUse;
      //image
      FTickImage.Left := FGlassButton.Left + ButtonSizeToDraw - ( FTickImage.Width + 10);
      FTickImage.Top  := FGlassButton.Top + ButtonSizeToDraw - ( FTickImage.Height + 10);
      //label
      FLabelControl.Top := FGlassButton.Top + ButtonSizeToDraw + FButtonVertMargin;
      FLabelControl.Left := hPadding;
      FLabelControl.Width := RequiredWidth;
      FLabelControl.Font.Size := LabelFontSizeToUse;

      FResizing := false;
      Self.Invalidate;
    end;
end;

procedure tbkExGlassButton.SetButtonColor(const Value: TColor);
begin
  FButtonColor := Value;
  FGlassButton.BackColor := Value;
end;

procedure tbkExGlassButton.SetButtonFontColor(const Value: TColor);
begin
  FButtonFontColor := Value;
  FGlassButton.Font.Color := Value;
end;

procedure tbkExGlassButton.SetButtonFontSize(const Value: integer);
begin
  FButtonFontSize := Value;
  FGlassButton.Font.Size := Value;
end;

procedure tbkExGlassButton.SetButtonHorizMargin(const Value: integer);
begin
  FButtonHorizMargin := Value;
  PositionComponents;
end;

procedure tbkExGlassButton.SetButtonSize(const Value: integer);
begin
  FButtonSize := Value;
  PositionComponents;
end;

procedure tbkExGlassButton.SetButtonVertMargin(const Value: integer);
begin
  FButtonVertMargin := Value;
  PositionComponents;
end;

procedure tbkExGlassButton.SetCaption(const Value: string);
begin
  FCaption := Value;
  FGlassButton.Caption := FCaption;
end;

procedure tbkExGlassButton.SetImagePicture(PictureToUse: TPicture);
begin
  if Assigned( PictureToUse) then
  begin
     FTickImage.Picture := PictureToUse;
     PositionComponents;
  end;
end;

procedure tbkExGlassButton.SetImageVisible(const Value: boolean);
begin
  FImageVisible := Value;
  FTickImage.Visible := Value;
  FGlassButton.Invalidate;  //is underneath button so need to redraw
end;

procedure tbkExGlassButton.SetLabelCaption(const Value: string);
begin
  FLabelCaption := Value;
  FLabelControl.caption := FLabelCaption;
end;

procedure tbkExGlassButton.SetLabelFontColor(const Value: TColor);
begin
  FLabelFontColor := Value;
  FLabelControl.Font.Color := Value;
end;

procedure tbkExGlassButton.SetLabelFontSize(const Value: integer);
begin
  FLabelFontSize := Value;
  FLabelControl.Font.Size := value;
  PositionComponents;
end;

procedure tbkExGlassButton.SetLabelHeight(const Value: integer);
begin
  FLabelHeight := Value;
  FLabelControl.Height := Value;
  PositionComponents;
end;

procedure tbkExGlassButton.SetLabelVisible(const Value: boolean);
begin
  FLabelVisible := Value;
  FLabelControl.Visible := FLabelVisible;
end;

procedure tbkExGlassButton.SetOnButtonKeyDown(const Value: TKeyEvent);
begin
  FOnButtonKeyDown := Value;
end;

procedure tbkExGlassButton.SetOnButtonKeyPress(const Value: TKeyPressEvent);
begin
  FOnButtonKeyPress := Value;
end;

procedure tbkExGlassButton.SetOnButtonKeyUp(const Value: TKeyEvent);
begin
  FOnButtonKeyUp := Value;
end;

procedure tbkExGlassButton.SetOnClick(const Value: TNotifyEvent);
begin
  FGlassButton.OnClick := Value;
end;

procedure tbkExGlassButton.WmSize(var Message: TMessage);
begin
  inherited;
  PositionComponents;
end;

procedure Register;
begin
  RegisterComponents('BankLink', [tbkExGlassButton]);
end;

end.
