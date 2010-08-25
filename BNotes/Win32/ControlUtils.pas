unit ControlUtils;

// -----------------------------------------------------------------------------
interface uses Classes, Controls, Graphics;
// -----------------------------------------------------------------------------

procedure SetControlColor( aControl : TControl; aColor : TColor );
procedure SetControlFontColor( aControl : TControl; aColor : TColor );
procedure SetControlFontSize( aControl : TControl; aSize : Integer );
function  GetControlColor( aControl : TControl ) : TColor;
function  GetControlFontColor( aControl : TControl ) : TColor;
procedure SetControlText( aControl : TControl; const aText : string );
function  GetControlText( aControl : TControl ) : string;
procedure SetControlReadOnly( aControl : TControl; state : Boolean );
function  IsControlReadOnly( aControl : TControl ) : Boolean;
procedure SetControlTabStop( aControl : TControl; TabStopState : Boolean );
function  IsControlATabStop( aControl : TControl ) : Boolean;
procedure SetControlFontName( aControl : TControl; const aFontName : string );
function  GetControlFontName( aControl : TControl ) : string;
Procedure ActivateHint( forComponent: TComponent );

// -----------------------------------------------------------------------------
implementation uses TypInfo;
// -----------------------------------------------------------------------------

procedure SetControlColor( aControl : TControl; aColor : TColor );
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Color' ) then
    SetOrdProp( aControl, 'Color', aColor );
end;

// -----------------------------------------------------------------------------

procedure SetControlFontColor( aControl : TControl; aColor : TColor );
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Font' ) then
    TFont( GetObjectProp( aControl, 'Font', TFont ) ).color := aColor;
end;

// -----------------------------------------------------------------------------

procedure SetControlFontSize( aControl : TControl; aSize : Integer );
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Font' ) then
    TFont( GetObjectProp( aControl, 'Font', TFont ) ).Size := aSize;
end;

// -----------------------------------------------------------------------------

function GetControlColor( aControl : TControl ) : TColor;
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Color' ) then
    Result := TColor( GetOrdProp( aControl, 'Color' ) )
  else
    Result := clWindow;
end;

// -----------------------------------------------------------------------------

function GetControlFontColor( aControl : TControl ) : TColor;
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Font' ) then
    Result := TFont( GetObjectProp( aControl, 'Font', TFont ) ).color
  else
    Result := clWindowText;
end;

// -----------------------------------------------------------------------------

procedure SetControlText( aControl : TControl; const aText : string );
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Text' ) then
    SetStrProp( aControl, 'Text', aText )
  else if IsPublishedProp( aControl, 'Caption' ) then
    SetStrProp( aControl, 'Caption', aText );
end;

// -----------------------------------------------------------------------------

function GetControlText( aControl : TControl ) : string;
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Text' ) then
    Result := GetStrProp( aControl, 'Text' )
  else if IsPublishedProp( aControl, 'Caption' ) then
    Result := GetStrProp( aControl, 'Caption' )
  else
    Result := '';
end;

// -----------------------------------------------------------------------------

procedure SetControlReadOnly( aControl : TControl; state : Boolean );
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'ReadOnly' ) then
    SetOrdProp( aControl, 'ReadOnly', Ord( state ) );
end;

// -----------------------------------------------------------------------------

function IsControlReadOnly( aControl : TControl ) : Boolean;
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'ReadOnly' ) then
    Result := GetOrdProp( aControl, 'ReadOnly' ) <> 0
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

procedure SetControlTabStop( aControl : TControl; TabStopState : Boolean );
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'TabStop' ) then
    SetOrdProp( aControl, 'TabStop', Ord( TabStopState ) );
end;

// -----------------------------------------------------------------------------

function  IsControlATabStop( aControl : TControl ) : Boolean;
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'TabStop' ) then
    Result := GetOrdProp( aControl, 'TabStop' ) <> 0
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

procedure SetControlFontName( aControl : TControl; const aFontName : string );
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Font' ) then
    TFont( GetObjectProp( aControl, 'Font', TFont ) ).Name := aFontName;
end;

// -----------------------------------------------------------------------------

function  GetControlFontName( aControl : TControl ) : string;
begin
  Assert( Assigned( aControl ) );
  if IsPublishedProp( aControl, 'Font' ) then
    Result := TFont( GetObjectProp( aControl, 'Font', TFont ) ).Name
  else
    Result := '';
end;

// -----------------------------------------------------------------------------

Procedure ActivateHint( forComponent: TComponent );
Begin { Make sure we are showing hints }
  If IsPublishedProp( forComponent, 'Hint' ) and
    ( GetStrProp( forComponent, 'Hint' ) <> '' ) and
    IsPublishedProp( forComponent, 'ShowHint' )
  Then
    SetOrdProp( forComponent, 'ShowHint', Ord(True));
end;


end.

