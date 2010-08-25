{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10835: ad3LiveAutospell.pas 
{
{   Rev 1.6    1/27/2005 2:14:18 AM  mnovak
}
{
{   Rev 1.5    20/12/2004 3:24:12 pm  Glenn
}
{
{   Rev 1.4    9/8/2004 11:36:00 PM  mnovak
{ LiveSpell Control Destruction Fixes
}
{
{   Rev 1.3    2/21/2004 11:59:40 PM  mnovak
{ 3.4.1 Updates
}
{
{   Rev 1.2    1/5/2004 1:13:44 AM  mnovak
}
{
{   Rev 1.1    12/3/2003 1:03:28 AM  mnovak
{ Version Number Updates
}
{
{   Rev 1.0    8/25/2003 1:01:40 AM  mnovak
}
{
{   Rev 1.5    1/28/2003 8:23:58 PM  mnovak
{ Propogate LiveMenuOptions on to subclass components.
}
{
{   Rev 1.4    1/10/2003 11:02:00 PM  mnovak
{ Account for a missing nil pointer check when there is no active control.
}
{
{   Rev 1.3    12/17/2002 6:01:06 PM  mnovak
{ Added documentation Hints for Time2Help
}
{
{   Rev 1.2    7/30/2002 12:07:12 AM  mnovak
{ Prep for v3.3 release
}
{
{   Rev 1.1    7/29/2002 11:59:56 PM  mnovak
{ Added requested OnWordCheck event
}
{
{   Rev 1.0    6/23/2002 11:55:26 PM  mnovak
}
{
{   Rev 1.0    6/17/2002 1:34:18 AM  Supervisor
}
(*************************************************************

Addict 3.4,  (c) 1996-2005, Addictive Software
Contact: addictsw@addictivesoftware.com

Auto-subclassing LiveSpell component

History:
4/11/00     - Michael Novak     - Initial Write

**************************************************************)

unit ad3LiveAutospell;

{$I addict3.inc}

interface

uses
    classes, controls, extctrls, graphics,
    {$IFDEF Delphi5AndAbove} contnrs, {$ENDIF}
    ad3SpellBase,
    ad3LiveBase,
    ad3RichEditSubclass,
    ad3Util;

type
    //************************************************************
    // LiveSpell Auto-subclassing component
    //************************************************************

    TAddictAutoLiveSpell = class(TLiveAddictSpellBase)
    protected
        FTimer              :TTimer;
        FLastFocusControl   :TWinControl;

        FSubclassList       :TObjectList;
        FSubclassWindowList :TList;

        // Additional Public Properties

        FExpansionChars         :String;
        FIrregularLineHeights   :Boolean;
        FIrregularLeftMargin    :Boolean;
        FAggressiveContextMenu  :Boolean;
        FAutoSubclassFocus      :Boolean;
        FFocusedOnly            :Boolean;
        FDoubleBuffered         :Boolean;
        FLiveColor              :TColor;
        FLiveReadOnly           :Boolean;
        FSingleLiveControl      :TWinControl;

        FOnBeginEditing         :TNotifyEvent;
        FOnWordCheck            :TWordCheckEvent;

    protected

        // Notification Routines

        procedure Notification( AComponent:TComponent; Operation:TOperation ); override;

        procedure CheckSelected; override;
        procedure StartLiveSpell; override;
        procedure StopLiveSpell; override;
        procedure StartLiveCorrect; override;
        procedure StopLiveCorrect; override;

        procedure OnTimer(Sender: TObject);

        // Property Read/Write Functions

        procedure WriteExpansionChars( NewChars:String ); virtual;
        procedure WriteIrregularLineHeights( NewValue:Boolean ); virtual;
        procedure WriteIrregularLeftMargin( NewValue:Boolean ); virtual;
        procedure WriteAggressiveContextMenu( NewValue:Boolean ); virtual;
        procedure WriteAutoSubclassFocus( NewValue:Boolean ); virtual;
        procedure WriteAutospellOnlyFocused( NewValue:Boolean ); virtual;
        procedure WriteDoubleBuffered( Buffered:Boolean ); virtual;
        procedure WriteLiveSpellingColor( NewColor:TColor ); virtual;
        procedure WriteLiveReadOnly( NewReadOnly:Boolean ); virtual;
        procedure WriteSingeLiveControl( NewControl:TWinControl ); virtual;
        procedure WriteOnBeginEditing( NewEvent:TNotifyEvent ); virtual;
        procedure WriteOnWordCheck( NewEvent:TWordCheckEvent ); virtual;

        // Utility Function

        procedure CheckWinControls; virtual;        
        procedure UpdateControlState; virtual;
        procedure EnableLiveSpell( Enabled:Boolean ); override;
        procedure EnableLiveCorrect( Enabled:Boolean ); override;

    public
        {$IFNDEF T2H}
        constructor Create(AOwner:TComponent); override;
        destructor Destroy; override;
        {$ENDIF}

        procedure AddControl( Control:TWinControl ); virtual;
        procedure RemoveControl( Control:TWinControl ); virtual;
        function ControlAdded( Control:TWinControl ):Boolean; virtual;

        property ExpansionChars:String read FExpansionChars write WriteExpansionChars;
        property IrregularLineHeights:Boolean read FIrregularLineHeights write WriteIrregularLineHeights;
        property IrregularLeftMargin:Boolean read FIrregularLeftMargin write WriteIrregularLeftMargin;
        property AggressiveContextMenu:Boolean read FAggressiveContextMenu write WriteAggressiveContextMenu;

    published

        property DoubleBuffered:Boolean read FDoubleBuffered write WriteDoubleBuffered;
        property LiveSpellingColor:TColor read FLiveColor write WriteLiveSpellingColor;
        property LiveSpellingReadOnly:Boolean read FLiveReadOnly write WriteLiveReadOnly;
        property LiveControl:TWinControl read FSingleLiveControl write WriteSingeLiveControl;

        property LiveSpelling;
        property LiveCorrect;
        property LiveMenuOptions;
        property LiveSpellingOptions;

        property AutoSpellWhenFocused:Boolean read FAutoSubclassFocus write WriteAutoSubclassFocus;
        property AutoSpellOnlyFocusedControl:Boolean read FFocusedOnly write WriteAutospellOnlyFocused;

        //#<Events>
        property OnBeginEditing:TNotifyEvent read FOnBeginEditing write WriteOnBeginEditing;
        property OnWordCheck:TWordCheckEvent read FOnWordCheck write FOnWordCheck;
        //#</Events>
    end;



implementation

uses
    windows, Forms, sysutils,
    ad3Configuration;


//************************************************************
// AddictSpell 3rd party integration component
//************************************************************

constructor TAddictAutoLiveSpell.Create(AOwner:TComponent);
begin
    inherited Create(AOwner);

    FTimer          := TTimer.Create(Self);
    FTimer.Interval := 500;
    FTimer.OnTimer  := OnTimer;
    FTimer.Enabled  := True;

    FLastFocusControl   := nil;

    FSubclassList       := TObjectList.Create;
    FSubclassWindowList := TList.Create;

    FAutoSubclassFocus  := True;
    FFocusedOnly        := False;

    FDoubleBuffered     := True;
    FLiveColor          := clRed;
    FLiveReadOnly       := False;
    FSingleLiveControl  := nil;
    FExpansionChars     := ' .,;:' + #9;

    FOnBeginEditing     := nil;
    FOnWordCheck        := nil;

    CheckStandardVersion;
end;

//************************************************************

destructor TAddictAutoLiveSpell.Destroy;
begin
    FTimer.Free;

    FSubclassList.Free;
    FSubclassWindowList.Free;

    inherited Destroy;
end;



//************************************************************
// Protected Notifications
//************************************************************

procedure TAddictAutoLiveSpell.Notification( AComponent:TComponent; Operation:TOperation );
begin
    if (Operation = opRemove) and (AComponent is TWinControl) then
    begin
        if (AComponent = FSingleLiveControl) then
        begin
            LiveControl := nil;
        end;
        RemoveControl( (AComponent as TWinControl) );
    end;
	inherited Notification( AComponent, Operation );
end;

//************************************************************

procedure TAddictAutoLiveSpell.CheckSelected;
begin
end;

//************************************************************

procedure TAddictAutoLiveSpell.StartLiveSpell;
begin
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.StopLiveSpell;
begin
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.StartLiveCorrect;
begin
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.StopLiveCorrect;
begin
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.OnTimer( Sender: TObject );
var
    FocusControl        :TWinControl;
    ClassName           :Array[0..1023] of Char;
    Name                :String;
    SupportedControl    :Boolean;
begin
    CheckWinControls;

    if (Owner is TCustomForm) then
    begin
        FocusControl := (Owner as TCustomForm).ActiveControl;

        if (FLastFocusControl <> FocusControl) then
        begin
            FLastFocusControl := FocusControl;

            if  (FAutoSubclassFocus) and
                (FLastFocusControl <> nil) then
            begin
                // Do auto-detection of the control type we're checking (if possible)

                ClassName[0]        := #0;
                GetClassName( FLastFocusControl.Handle, ClassName, 1024 );
                Name                := ClassName;
                Name                := AnsiLowercase( Name );
                SupportedControl    := False;

                if  ((pos( 'richedit', Name ) > 0) and (pos( 'addict', Name ) = 0)) or
                    (pos( 'wwdbrichedit', Name ) > 0) or
                    (pos( 'dxedit', Name ) > 0) or
                    (pos( 'dxedit', Name ) > 0) or
                    (pos( 'dxmemo', Name ) > 0) or
                    (pos( 'dxdbedit', Name ) > 0) or
                    (pos( 'dxdbmemo', Name ) > 0) then
                begin
                    SupportedControl := True;
                end;

                if (SupportedControl) then
                begin
                    AddControl( FLastFocusControl );
                end;
            end;

            UpdateControlState;
        end;
    end;
end;


//************************************************************
// Property Read/Write Functions
//************************************************************

procedure TAddictAutoLiveSpell.WriteExpansionChars( NewChars:String );
begin
    FExpansionChars := NewChars;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteIrregularLineHeights( NewValue:Boolean );
begin
    FIrregularLineHeights   := NewValue;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteIrregularLeftMargin( NewValue:Boolean );
begin
    FIrregularLeftMargin    := NewValue;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSPell.WriteAggressiveContextMenu( NewValue:Boolean );
begin
    FAggressiveContextMenu  := NewValue;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteAutoSubclassFocus( NewValue:Boolean );
begin
    FAutoSubclassFocus  := NewValue;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteAutospellOnlyFocused( NewValue:Boolean );
begin
    FFocusedOnly        := NewValue;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteDoubleBuffered( Buffered:Boolean );
begin
    FDoubleBuffered := Buffered;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteLiveSpellingColor( NewColor:TColor );
begin
    FLiveColor := NewColor;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteLiveReadOnly( NewReadOnly:Boolean );
begin
    FLiveReadOnly := NewReadOnly;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteSingeLiveControl( NewControl:TWinControl );
begin
    if (NewControl <> FSingleLiveControl) then
    begin
        if (assigned(FSingleLiveControl)) then
        begin
            RemoveControl( FSingleLiveControl );
        end;
        FSingleLiveControl := NewControl;
        if (assigned(FSingleLiveControl)) then
        begin
            AutoSpellWhenFocused := False;
            AddControl( FSingleLiveControl );
        end;
    end;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteOnBeginEditing( NewEvent:TNotifyEvent );
begin
    FOnBeginEditing := NewEvent;
    UpdateControlState;
end;

//************************************************************

procedure TAddictAutoLiveSpell.WriteOnWordCheck( NewEvent:TWordCheckEvent );
begin
    FOnWordCheck := NewEvent;
    UpdateControlState;
end;


//************************************************************
// Utility Function
//************************************************************

procedure TAddictAutoLiveSpell.CheckWinControls;
var
    Index       :Integer;
    Subclass    :TAddictRichEditSubclass;
begin
    // Delphi has a bad habit of re-creating windows, so we
    // have this function called on a timer.  It watches to
    // ensure that if a Subclass object's WinControl falls to
    // 'nil' indicating its window handle got recreated, then
    // we go ahead and subclass the newly created window.

    for Index := 0 to FSubclassList.Count - 1 do
    begin
        Subclass    := TAddictRichEditSubclass(FSubclassList[Index]);
        if (Subclass.WinControl <> TWinControl(FSubclassWindowList[Index])) then
        begin
            Subclass.WinControl := TWinControl(FSubclassWindowList[Index]);
        end;
    end;
end;

//************************************************************

procedure TAddictAutoLiveSpell.UpdateControlState;
var
    Index       :Integer;
    HasFocus    :Boolean;
    Subclass    :TAddictRichEditSubclass;
begin
    for Index := 0 to FSubclassList.Count - 1 do
    begin
        Subclass    := TAddictRichEditSubclass(FSubclassList[Index]);
        HasFocus    := IsWindow(Subclass.WindowHandle) and (Subclass.WinControl = FLastFocusControl);

        Subclass.LiveSpelling           :=  FLiveEnabled and
                                            ((not FFocusedOnly) or HasFocus);
        Subclass.LiveCorrect            :=  FCorrectEnabled and
                                            ((not FFocusedOnly) or HasFocus);
        Subclass.DoubleBuffered         :=  FDoubleBuffered;
        Subclass.LiveSpellingColor      :=  FLiveColor;
        Subclass.LiveSpellingReadOnly   :=  FLiveReadOnly;
        Subclass.ExpansionChars         :=  FExpansionChars;
        Subclass.IrregularLineHeights   :=  FIrregularLineHeights;
        Subclass.IrregularLeftMargin    :=  FIrregularLeftMargin;
        Subclass.AggressiveContextMenu  :=  FAggressiveContextMenu;
        Subclass.LiveMenuOptions        :=  FLiveMenuOptions;

        Subclass.OnBeginEditing         :=  FOnBeginEditing;
        Subclass.OnWordCheck            :=  FOnWordCheck;
    end;
end;

//************************************************************

procedure TAddictAutoLiveSpell.EnableLiveSpell( Enabled:Boolean );
var
    Live    :Boolean;
begin
    if (FLiveOptions) then
    begin
        Live := soLiveSpelling in Configuration.SpellOptions;
    end
    else
    begin
        Live := FLiveSpell;
    end;

    if (FLiveEnabled <> Enabled) then
    begin
        if Enabled and Live then
        begin
            if (csDesigning in ComponentState) then
            begin
                exit;
            end;

            FLiveEnabled := True;

            StartLiveSpell;
        end;

        if not Enabled then
        begin
            FLiveEnabled := False;

            StopLiveSpell;
        end;
    end;
end;

//************************************************************

procedure TAddictAutoLiveSpell.EnableLiveCorrect( Enabled:Boolean );
var
    Correct :Boolean;
begin
    if (FLiveOptions) then
    begin
        Correct := soLiveCorrect in Configuration.SpellOptions;
    end
    else
    begin
        Correct := FLiveCorrect;
    end;

    if (FCorrectEnabled <> Enabled) then
    begin
        if Enabled and Correct then
        begin
            if (csDesigning in ComponentState) then
            begin
                exit;
            end;

            FCorrectEnabled := True;

            StartLiveCorrect;
        end;

        if not Enabled then
        begin
            FCorrectEnabled := False;

            StopLiveCorrect;
        end;
    end;
end;



//************************************************************
// Public API
//************************************************************

procedure TAddictAutoLiveSpell.AddControl( Control:TWinControl );
var
    Subclass    :TAddictRichEditSubclass;
begin
    if (not ControlAdded(Control)) and not(csDesigning in ComponentState) then
    begin
        Subclass                := TAddictRichEditSubclass.Create;
        Subclass.WinControl     := Control;
        Subclass.AddictSpell    := Self;
        FSubclassList.Add( Subclass );
        FSubclassWindowList.Add( Control );
        UpdateControlState;

        Control.FreeNotification( Self );
    end;
end;

//************************************************************

procedure TAddictAutoLiveSpell.RemoveControl( Control:TWinControl );
var
    Index: Integer;
begin
    if not(csDesigning in ComponentState) then
    begin
        for Index := 0 to FSubclassList.Count - 1 do
        begin
            if (TWinControl(FSubclassWindowList[Index]) = Control) then
            begin
                FSubclassList.Delete( Index );
                FSubclassWindowList.Delete( Index );
                Exit;
            end;
        end;
    end;
end;

//************************************************************

function TAddictAutoLiveSpell.ControlAdded( Control:TWinControl ):Boolean;
var
    Index: Integer;
begin
    for Index := 0 to FSubclassList.Count - 1 do
    begin
        if (TWinControl(FSubclassWindowList[Index]) = Control) then
        begin
            Result := True;
            Exit;
        end;
    end;
    Result := False;
end;


end.

