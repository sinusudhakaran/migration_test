(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{$I OPDEFINE.INC}

unit OpPower;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpPptXP, OpOfcXP,                                      {!!.62}
  OpShared, ActiveX, db;

type
  {: Slide Transition Speed settings.}
  TOpPpTransitionSpeed = (pptsMixed,   // $FFFFFFFE;
                          pptsSlow,    // $00000001;
                          pptsMedium,  // $00000002;
                          pptsFast);   // $00000003;

  {: Slide Transition EffectEntry settings.}
  TOpPpEntryEffect  = (ppeeNone,                //00000000;
                       ppeeCut,                 //00000101;
                       ppeeCutThroughBlack,     //00000102;
                       ppeeRandom,              //00000201;
                       ppeeBlindsHorizontal,    //00000301;
                       ppeeBlindsVertical,      //00000302;
                       ppeeCheckerboardAcross,  //00000401;
                       ppeeCheckerboardDown,    //00000402;
                       ppeeCoverLeft,           //00000501;
                       ppeeCoverUp,             //00000502;
                       ppeeCoverRight,          //00000503;
                       ppeeCoverDown,           //00000504;
                       ppeeCoverLeftUp,         //00000505;
                       ppeeCoverRightUp,        //00000506;
                       ppeeCoverLeftDown,       //00000507;
                       ppeeCoverRightDown,      //00000508;
                       ppeeDissolve,            //00000601;
                       ppeeFade,                //00000701;
                       ppeeUncoverLeft,         //00000801;
                       ppeeUncoverUp,           //00000802;
                       ppeeUncoverRight,        //00000803;
                       ppeeUncoverDown,         //00000804;
                       ppeeUncoverLeftUp,       //00000805;
                       ppeeUncoverRightUp,      //00000806;
                       ppeeUncoverLeftDown,     //00000807;
                       ppeeUncoverRightDown,    //00000808;
                       ppeeRandomBarsHorizontal,//00000901;
                       ppeeRandomBarsVertical,  //00000902;
                       ppeeStripsUpLeft,        //00000A01;
                       ppeeStripsUpRight,       //00000A02;
                       ppeeStripsDownLeft,      //00000A03;
                       ppeeStripsDownRight,     //00000A04;
                       ppeeStripsLeftUp,        //00000A05;
                       ppeeStripsRightUp,       //00000A06;
                       ppeeStripsLeftDown,      //00000A07;
                       ppeeStripsRightDown,     //00000A08;
                       ppeeWipeLeft,            //00000B01;
                       ppeeWipeUp,              //00000B02;
                       ppeeWipeRight,           //00000B03;
                       ppeeWipeDown,            //00000B04;
                       ppeeBoxOut,              //00000C01;
                       ppeeBoxIn,               //00000C02;
                       ppeeSplitHorizontalOut,  //00000E01;
                       ppeeSplitHorizontalIn,   //00000E02;
                       ppeeSplitVerticalOut,    //00000E03;
                       ppeeSplitVerticalIn,     //00000E04;
                       ppeeAppear);             //00000F04;

  TOpPpDirection =  (ppdMixed,        // $FFFFFFFE;
                     ppdLeftToRight,  // $00000001;
                     ppdRightToLeft); // $00000002;

  {: Presentation SlideLayout settings.}
  TOpPpSlideLayout = (ppslTitle,                           // $00000001;
                      ppslText,                            // $00000002;
                      ppslTwoColumnText,                   // $00000003;
                      ppslTable,                           // $00000004;
                      ppslTextAndChart,                    // $00000005;
                      ppslChartAndText,                    // $00000006;
                      ppslOrgchart,                        // $00000007;
                      ppslChart,                           // $00000008;
                      ppslTextAndClipart,                  // $00000009;
                      ppslClipartAndText,                  // $0000000A;
                      ppslTitleOnly,                       // $0000000B;
                      ppslBlank,                           // $0000000C;
                      ppslTextAndObject,                   // $0000000D;
                      ppslObjectAndText,                   // $0000000E;
                      ppslLargeObject,                     // $0000000F;
                      ppslObject,                          // $00000010;
                      ppslTextAndMediaClip,                // $00000011;
                      ppslMediaClipAndText,                // $00000012;
                      ppslObjectOverText,                  // $00000013;
                      ppslTextOverObject,                  // $00000014;
                      ppslTextAndTwoObjects,               // $00000015;
                      ppslTwoObjectsAndText,               // $00000016;
                      ppslTwoObjectsOverText,              // $00000017;
                      ppslFourObjects,                     // $00000018;
                      ppslVerticalText,                    // $00000019;
                      ppslClipArtAndVerticalText,          // $0000001A;
                      ppslVerticalTitleAndText,            // $0000001B;
                      ppslVerticalTitleAndTextOverChart);  // $0000001C;

{ Forwards }
type
  TOpPowerPoint = class;
  TOpSlide = class;
  TOpSlides = class;
  TOpPresentations = class;
  TOpPresentation = class;


{ TOpSlideTransition }
  TOpSlideTransition = class(TPersistent)
  protected {private}
    FSlideComponent: TOpSlide;
    FAdvanceTime: Single;
    FAdvanceOnTime: Boolean;
    FAdvanceOnClick: Boolean;
    FEntryEffect: TOpPpEntryEffect;
    FTransSpeed: TOpPpTransitionSpeed;
    procedure SetAdvanceOnClick(const Value: Boolean);
    procedure SetAdvanceOnTime(const Value: Boolean);
    procedure SetAdvanceTime(const Value: Single);
    procedure SetEntryEffect(const Value: TOpPpEntryEffect);
    procedure SetTransSpeed(const Value: TOpPpTransitionSpeed);
    function GetOwner: TPersistent; override;
    function GetAdvanceOnClick: Boolean;
    function GetAdvanceOnTime: Boolean;
    function GetAdvanceTime: Single;
  public
    constructor Create(SlideComp: TOpSlide);
  published
    property AdvanceOnClick: Boolean
      read GetAdvanceOnClick write SetAdvanceOnClick;
    property AdvanceOnTime: Boolean
      read GetAdvanceOnTime write SetAdvanceOnTime;
    property AdvanceTime: Single
      read GetAdvanceTime write SetAdvanceTime;
    property EntryEffect: TOpPpEntryEffect
      read FEntryEffect write SetEntryEffect;
    property Speed: TOpPpTransitionSpeed
      read FTransSpeed write SetTransSpeed;
  end;

{ TOpSlide }
  TOpSlide = class(TOpNestedCollectionItem)
  protected {property variables}
    FLayout: TOpPpSlideLayout;
    FSlideName: WideString;
    FDisplayMasterShapes: Boolean;
    FFollowMasterBackground: Boolean;
    FSlideTransition: TOpSlideTransition;

  protected {methods}
    function GetAsSlide : Slide;
    function GetLayout: TOpPpSlideLayout;
    procedure SetLayout(const Value: TOpPpSlideLayout);
    function GetDisplayMasterShapes: Boolean;
    function GetFollowMasterBackground: Boolean;
    function GetName: WideString;
    procedure SetDisplayMasterShapes(const Value: Boolean);
    procedure SetFollowMasterBackground(const Value: Boolean);
    procedure SetName(const Value: WideString);
    function GetSubCollection(index: integer): TCollection; override;
    function GetSubCollectionCount: integer; override;

  public {methods}
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Connect; override;
    procedure Activate; override;

  public {properties}
    property AsSlide : Slide
      read GetAsSlide;

  published {properties}
    property Layout: TOpPpSlideLayout
      read GetLayout write SetLayout;
    property SlideName: WideString
      read GetName write SetName;
    property DisplayMasterShapes: Boolean
      read GetDisplayMasterShapes write SetDisplayMasterShapes;
    property FollowMasterBackground: Boolean
      read GetFollowMasterBackground write SetFollowMasterBackground;
    property TransitionEffect: TOpSlideTransition
      read FSlideTransition write FSlideTransition;
  end;


{ TOpSlides }
  TOpSlides = class(TOpNestedCollection)
  protected
    function GetItem(index: integer): TOpSlide;
    procedure SetItem(index: integer; const Value: TOpSlide);
    function GetItemName: string; override;
  public
    function Add: TOpSlide;
    property Items[index: integer]: TOpSlide
      read GetItem write SetItem ; default;
  end;


{ TOpPresentation }
  TOpPresentation = class(TOpNestedCollectionItem)
  protected {private}
    FSlides: TOpSlides;
    FPresFile: TFileName;
    FSaved: Boolean;
    FLayoutDirection: TOpPpDirection;
    FManualAdvance : Boolean;
    procedure SetPresFile(const Value: TFileName);
    procedure SetManualAdvance(const Value: Boolean);
    function GetManualAdvance : Boolean;
    function GetLayoutDirection: TOpPpDirection;
    function GetSaved: Boolean;
    procedure SetLayoutDirection(const Value: TOpPpDirection);
    procedure SetSaved(const Value: Boolean);
    function SaveCollection: boolean;
    function GetPropDirection: TOpPropDirection;
    function GetAsPresentation: _Presentation;
    function GetSubCollection(index: integer): TCollection; override;
    function GetSubCollectionCount: integer; override;
    function GetVerbCount: Integer; override;
    function GetVerb(index: integer): string; override;

  public {methods}
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Connect; override;
    procedure ExecuteVerb(index: Integer); override;
    procedure RunSlideShow;
    procedure Save;
    procedure SaveAs(const FileName: String);

  public {properties}
    property AsPresentation : _Presentation
      read GetAsPresentation;
    property PropDirection: TOpPropDirection
      read GetPropDirection;

  published {properties}
    property ManualAdvance : Boolean
      read GetManualAdvance write SetManualAdvance;
    property Slides: TOpSlides
      read FSlides write FSlides stored SaveCollection;
    property PresentationFile: TFileName
      read FPresFile write SetPresFile;
    property Saved: Boolean
      read GetSaved write SetSaved stored SaveCollection;
    property LayoutDirection: TOpPpDirection
      read GetLayoutDirection write SetLayoutDirection stored SaveCollection;
  end;


{ TOpPresentations }
  TOpPresentations = class(TOpNestedCollection)
  protected
    function GetItem(index: integer): TOpPresentation;
    procedure SetItem(index: integer; const Value: TOpPresentation);
    function GetItemName: string; override;
  public
    function Add: TOpPresentation;
    property Items[index: integer]: TOpPresentation
      read GetItem write SetItem ; default;
  end;


{ TOpPowerPoint }
  TOpPowerPoint = class(TOpPowerPointBase)
  protected {property variables}
    FVisible: Boolean;
    FCaption: string;
    FPresentations: TOpPresentations;
    FServer: _Application;
    FLeft: integer;
    FWidth: integer;
    FHeight: integer;
    FTop: integer;

  protected {methods}
    procedure FixupCollection(Item: TOpNestedCollectionItem);
    function GetCaption: string;
    procedure Setcaption(const Value: string);
    function GetHeight: integer;
    function GetLeft: integer;
    function GetTop: integer;
    function GetWidth: integer;
    procedure SetHeight(const Value: integer);
    procedure SetLeft(const Value: integer);
    procedure SetTop(const Value: integer);
    procedure SetWidth(const Value: integer);
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure FixupProps; override;
    procedure SetVisible(const Value: Boolean);
    function GetConnected: Boolean; override;
    function GetOfficeVersionStr: string; override;
    procedure ReleaseCollectionInterface(Item: TOpNestedCollectionItem);
    function PointsToPixels(Points: Single): Integer;
    function PixelsToPoints(Pixels: Integer): Single;
    function PixelsPerInch: Integer;
    function GetActivePresentation : TOpPresentation;

  public {methods}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  CreateItem(Item: TOpNestedCollectionItem): IDispatch; override;
    procedure GetAppInfo(Info: TStrings); override;
    procedure GetFileInfo(var Filter, DefExt: string); override;
    procedure HandleEvent(const IID: TIID; DispId: Integer;
      const Params: TVariantArgList); override;
    function  NewPresentation : TOpPresentation;
    function  OpenPresentation(const FileName : TFileName) : TOpPresentation;
    procedure Quit;

  public {properties}
    property ActivePresentation : TOpPresentation
      read GetActivePresentation;
    property Server: _Application
      read FServer;

  published {properties}
    property Caption: string
      read GetCaption write SetCaption;
    property Presentations: TOpPresentations
      read FPresentations write FPresentations;
    property ServerLeft: Integer
      read GetLeft write SetLeft;
    property ServerTop: Integer
      read GetTop write SetTop;
    property ServerWidth: Integer
      read GetWidth write SetWidth;
    property ServerHeight: Integer
      read GetHeight write SetHeight;
    property Visible: Boolean
      read FVisible write SetVisible;

  published {inherited properties}
    property Connected;
    property MachineName;
    property OnOpConnect;
    property OnOpDisconnect;
    property OnGetInstance;
    property PropDirection;
  end;

implementation

uses
  {$IFDEF TRIALRUN} OpTrial, {$ENDIF}
   Registry, ComObj, OpConst;

{ TOpPowerPointAppInfo }

procedure TOpPowerPoint.GetAppInfo(Info: TStrings);
var
  App: _Application;
begin
  if not Connected then
    OleCheck(CoCreate(CLASS_Application_, _Application, App))
  else
    App := FServer;
  if assigned(Info) then
  begin
    with Info do
    begin
      Clear;
      Add('Operating System=' + App.OperatingSystem);
      Add('Version=' + App.Version);
      Add('Build=' + App.Build);
      Add('Active Printer=' + App.ActivePrinter);
    end;
  end;
end;

{ TOpPowerPoint }

constructor TOpPowerPoint.Create(AOwner: TComponent);
begin
{$IFDEF TRIALRUN}
  _CC_;
  _VC_;
{$ENDIF}

  inherited Create(AOwner);

  FLeft := 0;
  FTop := 0;
  FWidth := 640;
  FHeight := 480;
  Visible:= True;
  FPresentations:= TOpPresentations.Create(self, self, TOpPresentation);
end;

destructor TOpPowerPoint.Destroy;
begin
  Connected := False;
  FPresentations.Free;
  inherited Destroy;
end;

procedure TOpPowerPoint.HandleEvent(const IID: TIID; DispId: Integer;
  const Params: TVariantArgList);
begin
  //  Not available for PowerPoint97 and is implemented on a Dual interface in Powerpaint2000 !
end;

procedure TOpPowerPoint.Setcaption(const Value: string);
begin
  FCaption := Value;
  if Connected then
    FServer.Caption := Value;
end;

procedure TOpPowerPoint.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  if Connected then
    FServer.Visible:= Integer(Value);
end;

function TOpPowerPoint.GetCaption: string;
begin
  if Connected then begin
    Result := FServer.Caption;
    FCaption:= Result;
  end else
    Result := FCaption;
end;

procedure TOpPowerPoint.Quit;
begin
  if Connected then
    FServer.Quit;
end;

function TOpPowerPoint.GetHeight: integer;
begin
  if Connected then
  begin
    Result := PointsToPixels(Fserver.Height);
    FHeight:= Result;
  end
  else
    Result := FHeight;
end;

function TOpPowerPoint.GetLeft: integer;
begin
  if Connected then
  begin
    Result := PointsToPixels(Fserver.Left);
    FLeft:= Result;
  end
  else
    Result := FLeft;
end;

function TOpPowerPoint.GetTop: integer;
begin
  if Connected then
  begin
    Result := PointsToPixels(Fserver.Top);
    FTop:= Result;
  end
  else
    Result := FTop;
end;

function TOpPowerPoint.GetWidth: integer;
begin
  if Connected then
  begin
    Result := PointsToPixels(Fserver.Width);
    FWidth:= Result;
  end
  else
    Result := FWidth;
end;

procedure TOpPowerPoint.SetHeight(const Value: integer);
begin
  FHeight:= Value;
  if (Connected) then
    FServer.Height := PixelsToPoints(FHeight);
end;

procedure TOpPowerPoint.SetLeft(const Value: integer);
begin
  FLeft:= Value;
  if (Connected) then
    FServer.Left := PixelsToPoints(FLeft);
end;

procedure TOpPowerPoint.SetTop(const Value: integer);
begin
  FTop:= Value;
  if (Connected) then
    FServer.Top := PixelsToPoints(FTop);
end;

procedure TOpPowerPoint.SetWidth(const Value: integer);
begin
  FWidth:= Value;
  if (Connected) then
    FServer.Width := PixelsToPoints(FWidth);
end;

function TOpPowerPoint.PixelsPerInch: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetDeviceCaps(DC,LOGPIXELSY);
  finally
    ReleaseDC(0,DC);
  end;
end;


function TOpPowerPoint.PixelsToPoints(Pixels: Integer): Single;
begin
  Result := (Pixels / PixelsPerInch) * 72;
end;

function TOpPowerPoint.PointsToPixels(Points: Single): Integer;
begin
  Result := Trunc((Points / 72) * PixelsPerInch);
end;

procedure TOpPowerPoint.DoConnect;
begin
  OleCheck(CoCreate(CLASS_Application_, _Application, FServer));
  FVisible:= True;
end;

procedure TOpPowerPoint.DoDisconnect;
begin
  if (csDesigning in ComponentState) then
  begin
    FPresentations.ForEachItem(ReleaseCollectionInterface);
    FServer.Quit;
    FServer:= nil;
  end;
end;

function TOpPowerPoint.GetOfficeVersionStr: string;
begin
  Result := FServer.Version;
end;

function TOpPowerPoint.GetActivePresentation : TOpPresentation;
var
  Pres : OpPptXP._Presentation;                             {!!.62}
  i : Integer;
begin
  Result := nil;
  Pres := Server.ActivePresentation;
  if (Presentations.Count > 0) then
    for i := 0 to Pred(Presentations.Count) do
      if (Pres = Presentations[i].AsPresentation) then
        begin
          Result := Presentations[i];
          Break;
        end;
end;

function TOpPowerPoint.NewPresentation : TOpPresentation;
begin
  if not Connected then
    Connected := True;
  Result := Presentations.Add;
end;

function TOpPowerPoint.OpenPresentation(const FileName : TFileName) : TOpPresentation;
begin
  if not Connected then
    Connected := True;
  Result := Presentations.Add;
  Result.PresentationFile := FileName;
end;


{ TOpSlideTransition }

constructor TOpSlideTransition.Create(SlideComp: TOpSlide);
begin
  FSlideComponent := SlideComp;
  FAdvanceOnClick := True;
  FAdvanceOnTime := False;
  FAdvanceTime := 10;
end;

function TOpSlideTransition.GetAdvanceOnClick: Boolean;
begin
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then begin
    Result := Boolean(FSlideComponent.AsSlide.SlideShowTransition.AdvanceOnClick);
    FAdvanceOnClick:= Result;
  end else
    Result := FAdvanceOnClick;
end;

function TOpSlideTransition.GetAdvanceOnTime: Boolean;
begin
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then begin
    Result := Boolean(FSlideComponent.AsSlide.SlideShowTransition.AdvanceOnTime);
    FAdvanceOnTime := Result;
  end else
    Result := FAdvanceOnTime;
end;

function TOpSlideTransition.GetAdvanceTime: Single;
begin
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then begin
    Result := FSlideComponent.AsSlide.SlideShowTransition.AdvanceTime;
    FAdvanceTime := Result;
  end else
    Result := FAdvanceTime;
end;

function TOpSlideTransition.GetOwner: TPersistent;
begin
  Result:= FSlideComponent;
end;

procedure TOpSlideTransition.SetAdvanceOnClick(const Value: Boolean);
begin
  FAdvanceOnClick := Value;
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then begin
    if FAdvanceOnClick then
      FSlideComponent.AsSlide.SlideShowTransition.AdvanceOnClick:= Integer(True)
    else
      FSlideComponent.AsSlide.SlideShowTransition.AdvanceOnClick:= Integer(False);
  end;
end;

procedure TOpSlideTransition.SetAdvanceOnTime(const Value: Boolean);
begin
  FAdvanceOnTime := Value;
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then begin
    if FAdvanceOnTime then
      FSlideComponent.AsSlide.SlideShowTransition.AdvanceOnTime:= Integer(True)
    else
      FSlideComponent.AsSlide.SlideShowTransition.AdvanceOnTime:= Integer(False);
  end;
end;

procedure TOpSlideTransition.SetAdvanceTime(const Value: Single);
begin
  FAdvanceTime := Value;
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then
    FSlideComponent.AsSlide.SlideShowTransition.AdvanceTime:= Value;
end;

procedure TOpSlideTransition.SetEntryEffect(const Value: TOpPpEntryEffect);
begin
  FEntryEffect := Value;
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then
    case Value of
      ppeeNone: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectNone);
      ppeeCut: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCut);
      ppeeCutThroughBlack: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCutThroughBlack);
      ppeeRandom: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectRandom);
      ppeeBlindsHorizontal: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectBlindsHorizontal);
      ppeeBlindsVertical: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectBlindsVertical);
      ppeeCheckerboardAcross: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCheckerboardAcross);
      ppeeCheckerboardDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCheckerboardDown);
      ppeeCoverLeft: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverLeft);
      ppeeCoverUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverUp);
      ppeeCoverRight: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverRight);
      ppeeCoverDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverDown);
      ppeeCoverLeftUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverLeftUp);
      ppeeCoverRightUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverRightUp);
      ppeeCoverLeftDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverLeftDown);
      ppeeCoverRightDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectCoverRightDown);
      ppeeDissolve: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectDissolve);
      ppeeFade: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectFade);
      ppeeUncoverLeft: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverLeft);
      ppeeUncoverUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverUp);
      ppeeUncoverRight: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverRight);
      ppeeUncoverDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverDown);
      ppeeUncoverLeftUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverLeftUp);
      ppeeUncoverRightUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverRightUp);
      ppeeUncoverLeftDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverLeftDown);
      ppeeUncoverRightDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectUncoverRightDown);
      ppeeRandomBarsHorizontal: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectRandomBarsHorizontal);
      ppeeRandomBarsVertical: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectRandomBarsVertical);
      ppeeStripsUpLeft: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsUpLeft);
      ppeeStripsUpRight: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsUpRight);
      ppeeStripsDownLeft: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsDownLeft);
      ppeeStripsDownRight: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsDownRight);
      ppeeStripsLeftUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsLeftUp);
      ppeeStripsRightUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsRightUp);
      ppeeStripsLeftDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsLeftDown);
      ppeeStripsRightDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectStripsRightDown);
      ppeeWipeLeft: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectWipeLeft);
      ppeeWipeUp: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectWipeUp);
      ppeeWipeRight: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectWipeRight);
      ppeeWipeDown: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectWipeDown);
      ppeeBoxOut: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectBoxOut);
      ppeeBoxIn: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectBoxIn);
      ppeeSplitHorizontalOut: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectSplitHorizontalOut);
      ppeeSplitHorizontalIn: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectSplitHorizontalIn);
      ppeeSplitVerticalOut: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectSplitVerticalOut);
      ppeeSplitVerticalIn: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectSplitVerticalIn);
      ppeeAppear: FSlideComponent.AsSlide.SlideShowTransition.EntryEffect:= integer(ppEffectAppear);
    end;
end;

procedure TOpSlideTransition.SetTransSpeed(const Value: TOpPpTransitionSpeed);
begin
  FTransSpeed := Value;
  if TOpPowerPoint(FSlideComponent.RootComponent).Connected then
    case Value of
    {$IFDEF DCC6ORLATER}
//{!!.62}      pptsMixed: FSlideComponent.AsSlide.SlideShowTransition.Speed:= int64(ppTransitionSpeedMixed);
      pptsSlow:  FSlideComponent.AsSlide.SlideShowTransition.Speed:= int64(ppTransitionSpeedSlow);
      pptsMedium:FSlideComponent.AsSlide.SlideShowTransition.Speed:= int64(ppTransitionSpeedMedium);
      pptsFast:  FSlideComponent.AsSlide.SlideShowTransition.Speed:= int64(ppTransitionSpeedFast);
    {$ELSE}
//{!!.62}      pptsMixed: FSlideComponent.AsSlide.SlideShowTransition.Speed := 1; //Integer(ppTransitionSpeedMixed);
      pptsSlow:  FSlideComponent.AsSlide.SlideShowTransition.Speed := Integer(ppTransitionSpeedSlow);
      pptsMedium:FSlideComponent.AsSlide.SlideShowTransition.Speed := Integer(ppTransitionSpeedMedium);
      pptsFast:  FSlideComponent.AsSlide.SlideShowTransition.Speed := Integer(ppTransitionSpeedFast);
    {$ENDIF}
    end;
end;

procedure TOpPowerPoint.FixupProps;
begin
  Visible:= FVisible;
  case PropDirection of
    pdToServer:  Begin
                  ServerLeft:= FLeft;
                  ServerTop:= FTop;
                  ServerWidth:= FWidth;
                  ServerHeight:= FHeight;
                 end;
    pdFromServer: begin
                    FLeft:= ServerLeft;
                    FTop:= ServerTop;
                    FWidth:= ServerWidth;
                    FHeight:= ServerHeight;
                  end;
  end;
  FPresentations.ForEachItem(FixupCollection);
end;

function TOpPowerPoint.GetConnected: Boolean;
begin
  Result := Assigned(FServer);
end;

procedure TOpPowerPoint.FixupCollection(Item: TOpNestedCollectionItem);
begin
  item.Connect;
end;

procedure TOpPowerPoint.ReleaseCollectionInterface(
  Item: TOpNestedCollectionItem);
begin
  item.Intf:= nil;
end;

function TOpPowerPoint.CreateItem(Item: TOpNestedCollectionItem): IDispatch;
begin
  if Connected then
  begin
    if (Item is TOpPresentation) then
    begin
      if TOpPresentation(Item).PropDirection = pdFromServer then
        result:= nil
      else
        Result := Server.Presentations.Add(Integer(True));
    end;

    if (Item is TOpSlide) then
    begin
      if Item.Index < (Item.ParentItem.Intf as Presentation).Slides.Count then
        Result := (Item.ParentItem.Intf as Presentation).Slides.Item(Item.Index + 1)
      else
        Result := (Item.ParentItem.Intf as Presentation).Slides.Add(
          (Item.ParentItem.Intf as Presentation).Slides.Count + 1,
          Integer(ppLayoutTitle));
    end;
  end;
end;

procedure TOpPowerPoint.GetFileInfo(var Filter, DefExt: string);
begin
  Filter := SPPFilter;
  DefExt := Sppt;
end;

procedure TOpPresentation.SetPresFile(const Value: TFileName);
var
  count: integer;
begin
  FPresFile := Value;
  if (CheckActive(False,ctProperty)) and (PropDirection = pdFromServer) and (Value <> '') then
  begin
    Slides.Clear;
    if assigned(Intf) then
    begin
      (AsPresentation).Close;
    end;
    Intf:= TOpPowerPoint(RootComponent).FServer.Presentations.OpenOld(Value,  {!!.62}
        Integer(False), Integer(False), Integer(True));
    if AsPresentation.Slides.Count > 0 then
    begin
      for Count:= 0 to AsPresentation.Slides.Count - 1 do
      begin
        Slides.Add;
      end;
    end;
  end;
end;


{ TOpSlide }
procedure TOpSlide.Activate;
begin
  if assigned(Intf) then
    AsSlide.Select;
end;

procedure TOpSlide.Connect;
begin
  inherited Connect;
  case (ParentItem as TOpPresentation).PropDirection of
    pdToServer:   begin
                    SlideName := FSlideName;
                    Layout:= FLayout;
                    DisplayMasterShapes:= FDisplayMasterShapes;
                    FollowMasterBackground:= FFollowMasterBackground;
                  end;
    pdFromServer: begin
                    FSlideName:= SlideName;
                    FLayout:= Layout;
                    FDisplayMasterShapes:= DisplayMasterShapes;
                    FFollowMasterBackground:= FollowMasterBackground;
                  end;
  end;
end;

constructor TOpSlide.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSlideTransition:= TOpSlideTransition.Create(self);
  //FSlideTransition.GetAdvanceOnClick;
  //FSlideTransition.GetAdvanceOnTime;
  //FSlideTransition.GetAdvanceTime;
end;

destructor TOpSlide.Destroy;
begin
  FSlideTransition.Free;
  if assigned(Intf) then begin
    AsSlide.Delete;
    Intf := nil;
  end;
  inherited Destroy;
end;

function TOpSlide.GetAsSlide: Slide;
begin
  CheckActive(True,ctProperty);
  Result := (Intf as Slide);
end;

function TOpSlide.GetDisplayMasterShapes: Boolean;
begin
  if (CheckActive(False,ctProperty)) then
  begin
    Result := Boolean(AsSlide.DisplayMasterShapes);
    FDisplayMasterShapes:= Result;
  end
  else
    Result := FDisplayMasterShapes;
end;

function TOpSlide.GetFollowMasterBackground: Boolean;
begin
  if (CheckActive(False,ctProperty)) then
  begin
    Result := Boolean(AsSlide.FollowMasterBackground);
    FFollowMasterBackground:= Result;
  end
  else
    Result := FFollowMasterBackground;
end;

function TOpSlide.GetLayout: TOpPpSlideLayout;
begin
  if (CheckActive(False,ctProperty)) then
  begin
    Result := TOpPpSlideLayout(AsSlide.Layout);
    FLayout:= Result;
  end
  else
    Result := FLayout;
end;

function TOpSlide.GetName: WideString;
begin
  if (CheckActive(False,ctProperty)) then
  begin
    Result := AsSlide.Name;
    FSlideName:= Result;
  end
  else
    Result := FSlideName;
end;

function TOpSlide.GetSubCollection(index: integer): TCollection;
begin
  result:= nil;
end;

function TOpSlide.GetSubCollectionCount: integer;
begin
  result:= 0;
end;

procedure TOpSlide.SetDisplayMasterShapes(const Value: Boolean);
begin
  FDisplayMasterShapes:= Value;
  if (CheckActive(False, ctProperty)) then
    AsSlide.DisplayMasterShapes := Integer(Value);
end;

procedure TOpSlide.SetFollowMasterBackground(const Value: Boolean);
begin
  FFollowMasterBackground := Value;
  if (CheckActive(False, ctProperty)) then
    AsSlide.FollowMasterBackground:= Integer(Value);
end;

procedure TOpSlide.SetLayout(const Value: TOpPpSlideLayout);
begin
  if (CheckActive(False,ctProperty)) then
  begin
    case Value of
      ppslTitle: AsSlide.Layout:= Integer(ppLayoutTitle);
      ppslText: AsSlide.Layout:=  Integer(ppLayoutText);
      ppslTwoColumnText: AsSlide.Layout:= Integer(ppLayoutTwoColumnText);
      ppslTable: AsSlide.Layout:= Integer(ppLayoutTable);
      ppslTextAndChart: AsSlide.Layout:= Integer(ppLayoutTextAndChart);
      ppslChartAndText: AsSlide.Layout:= Integer(ppLayoutChartAndText);
      ppslOrgchart: AsSlide.Layout:= Integer(ppLayoutOrgchart);
      ppslChart: AsSlide.Layout:= Integer(ppLayoutChart);
      ppslTextAndClipart: AsSlide.Layout:= Integer(ppLayoutTextAndClipart);
      ppslClipartAndText: AsSlide.Layout:= Integer(ppLayoutClipartAndText);
      ppslTitleOnly: AsSlide.Layout:= Integer(ppLayoutTitleOnly);
      ppslBlank: AsSlide.Layout:= Integer(ppLayoutBlank);
      ppslTextAndObject: AsSlide.Layout:= Integer(ppLayoutTextAndObject);
      ppslObjectAndText: AsSlide.Layout:= Integer(ppLayoutObjectAndText);
      ppslLargeObject: AsSlide.Layout:= Integer(ppLayoutLargeObject);
      ppslObject: AsSlide.Layout:= Integer(ppLayoutObject);
      ppslTextAndMediaClip: AsSlide.Layout:= Integer(ppLayoutTextAndMediaClip);
      ppslMediaClipAndText: AsSlide.Layout:= Integer(ppLayoutMediaClipAndText);
      ppslObjectOverText: AsSlide.Layout:= Integer(ppLayoutObjectOverText);
      ppslTextOverObject: AsSlide.Layout:= Integer(ppLayoutTextOverObject);
      ppslTextAndTwoObjects: AsSlide.Layout:= Integer(ppLayoutTextAndTwoObjects);
      ppslTwoObjectsAndText: AsSlide.Layout:= Integer(ppLayoutTwoObjectsAndText);
      ppslTwoObjectsOverText: AsSlide.Layout:= Integer(ppLayoutTwoObjectsOverText);
      ppslFourObjects: AsSlide.Layout:= Integer(ppLayoutFourObjects);
      ppslVerticalText: AsSlide.Layout:= Integer(ppLayoutVerticalText);
      ppslClipArtAndVerticalText: AsSlide.Layout:= Integer(ppLayoutClipArtAndVerticalText);
      ppslVerticalTitleAndText: AsSlide.Layout:= Integer(ppLayoutVerticalTitleAndText);
      ppslVerticalTitleAndTextOverChart: AsSlide.Layout:= Integer(ppLayoutVerticalTitleAndTextOverChart);
    end;
  end;
  FLayout:= Value;
end;

procedure TOpSlide.SetName(const Value: WideString);
begin
  if (CheckActive(False,ctProperty)) then
    AsSlide.Name:= Value;
  FSlideName:= Value;
end;

{ TOpSlides }

function TOpSlides.Add: TOpSlide;
begin
  Result := TOpSlide(inherited Add);
end;

function TOpSlides.GetItem(index: integer): TOpSlide;
begin
  Result := TOpSlide(inherited GetItem(index));
end;

function TOpSlides.GetItemName: string;
begin
  result := 'Slide';
end;

procedure TOpSlides.SetItem(index: integer; const Value: TOpSlide);
begin
  inherited SetItem(index,Value);
end;

{ TOpPresentation }

constructor TOpPresentation.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FSlides := TOpSlides.Create((Collection as TOpNestedCollection).RootComponent,self,TOpSlide);
  FManualAdvance := False;
end;

destructor TOpPresentation.Destroy;
begin
  FSlides.Free;
  if TOpPowerPoint(RootComponent).Connected then
    (Intf as _Presentation).Close;
  inherited Destroy;
end;

function TOpPresentation.GetSubCollection(index: integer): TCollection;
begin
  result := FSlides;
end;

function TOpPresentation.GetSubCollectionCount: integer;
begin
  result:= 1;
end;

procedure TOpPresentation.ExecuteVerb(index: Integer);
begin
  case Index of
    0:  RunSlideShow;
    1:  Save;
  end;
end;

function TOpPresentation.GetAsPresentation: _Presentation;
begin
  CheckActive(True,ctProperty);
  Result := (Intf as _Presentation);
end;

function TOpPresentation.GetVerb(index: integer): string;
begin
  case index of
    0: Result := 'Run SlideShow';
    1: Result := 'Save';
  end;
end;

function TOpPresentation.GetVerbCount: Integer;
begin
  Result:= 2;
end;

function TOpPresentation.GetManualAdvance : Boolean;
begin
  if CheckActive(False, ctProperty) then begin
    Result := AsPresentation.SlideShowSettings.AdvanceMode = ppSlideShowManualAdvance;
    FManualAdvance:= Result;
  end else
    Result := FManualAdvance;
end;

procedure TOpPresentation.SetManualAdvance(const Value: Boolean);
begin
  FManualAdvance := Value;
  if (CheckActive(False, ctProperty)) then begin
    if FManualAdvance then
      AsPresentation.SlideShowSettings.AdvanceMode := ppSlideShowManualAdvance
    else
      AsPresentation.SlideShowSettings.AdvanceMode := ppSlideShowUseSlideTimings;
  end;
end;

function TOpPresentation.GetLayoutDirection: TOpPpDirection;
begin
  if (CheckActive(False,ctProperty)) then begin
    Result := TOpPpDirection(AsPresentation.LayoutDirection);
    FLayoutDirection:= Result;
  end else
    Result := FLayoutDirection;
end;

function TOpPresentation.GetSaved: Boolean;
begin
  if (CheckActive(False,ctProperty)) then begin
    Result := Boolean(AsPresentation.Saved);
    FSaved:= Result;
  end else
    Result := FSaved;
end;

procedure TOpPresentation.SetLayoutDirection(const Value: TOpPpDirection);
begin
  FLayoutDirection := Value;
  if (CheckActive(False,ctProperty)) then
    case Value of
    {$IFDEF DCC6ORLATER}
      ppdMixed: AsPresentation.LayoutDirection:= Int64(ppDirectionMixed);
      ppdLeftToRight: AsPresentation.LayoutDirection:= Int64(ppDirectionLeftToRight);
      ppdRightToLeft: AsPresentation.LayoutDirection:= Int64(ppDirectionRightToLeft);
    {$ELSE}
      ppdMixed: AsPresentation.LayoutDirection:= Integer(ppDirectionMixed);
      ppdLeftToRight: AsPresentation.LayoutDirection:= Integer(ppDirectionLeftToRight);
      ppdRightToLeft: AsPresentation.LayoutDirection:= Integer(ppDirectionRightToLeft);
    {$ENDIF}
    end;
end;

procedure TOpPresentation.SetSaved(const Value: Boolean);
begin
  FSaved := Value;
  if (CheckActive(False, ctProperty)) then
    AsPresentation.Saved := Integer(Value);
end;

function TOpPresentation.GetPropDirection: TOpPropDirection;
begin
  if (FPresFile = '') then
    Result := pdToServer
  else
    Result := pdFromServer;
end;

function TOpPresentation.SaveCollection: boolean;
begin
  Result := PropDirection = pdToServer;
end;

procedure TOpPresentation.Connect;
begin
  inherited Connect;
  if PropDirection = pdFromServer then begin
    PresentationFile := FPresFile;
    Saved := GetSaved;
    LayoutDirection := GetLayoutDirection;
    ManualAdvance := GetManualAdvance;
  end else begin
    FPresFile:= PresentationFile;
    FSaved:= Saved;
    FLayoutDirection := LayoutDirection;
    FManualAdvance := ManualAdvance;
  end;
end;

procedure TOpPresentation.Save;
begin
  if (CheckActive(True, ctMethod)) then
    AsPresentation.Save;
end;

procedure TOpPresentation.SaveAs(const FileName: String);
begin
  if (CheckActive(True, ctMethod)) then
    AsPresentation.SaveAs(FileName, Integer(ppSaveAsPresentation), Integer(True));
end;

procedure TOpPresentation.RunSlideShow;
begin
  if CheckActive(True, ctMethod) then
    AsPresentation.SlideShowSettings.Run;
end;

{ TOpPresentations }

function TOpPresentations.Add: TOpPresentation;
begin
  Result := TOpPresentation(inherited Add);
end;

function TOpPresentations.GetItem(index: integer): TOpPresentation;
begin
  Result := TOpPresentation(inherited GetItem(index));
end;

function TOpPresentations.GetItemName: string;
begin
  result := 'Presentation';
end;

procedure TOpPresentations.SetItem(index: integer; const Value: TOpPresentation);
begin
  inherited SetItem(index,Value);
end;

end.
