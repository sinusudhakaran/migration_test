unit FormUtils;

interface

uses
  Classes, Graphics, Controls, Forms, StdCtrls;

Procedure ApplyStandards( Const F : TForm );
Procedure SetEditState( C : TControl; Const EditOK : Boolean );

Var
  StdEditFontName : String;

Const
  StdEditFontSize  = 9;
  StdEditColor     = clBlack;
  StdBtnFontName = 'Arial';
  StdBtnFontSize = 10;
  StdDisabledColor = $00800000;

// ----------------------------------------------------------------------------
implementation uses ControlUtils;
// ----------------------------------------------------------------------------

Function GetEditFontName : String;

Const                { First Choice .............. > Last Choice }
  StdEditFontNames = '"Verdana","Tahoma","Fixedsys","MS Sans Serif","Arial"';
Var
  PreferredFonts : TStringList;
  i : Integer;
Begin
  PreferredFonts := TStringList.Create;
  Try
    PreferredFonts.CommaText := StdEditFontNames;
    For i := 0 to Pred( PreferredFonts.Count ) do
    Begin
      Result := PreferredFonts[ i ];
      If Screen.Fonts.IndexOf( Result ) <> -1 then exit;
    end;
  Finally
    PreferredFonts.Free;
  end;
end;

// ----------------------------------------------------------------------------

Procedure ApplyStandards( Const F : TForm );

  Procedure ApplyComponentStandards( Const aComponent : TComponent );

  Var
    i : Integer;
  Begin
    ActivateHint( aComponent );
    If ( aComponent is tButton ) then with ( aComponent as TButton ) do
    Begin
      Font.Name  := StdBtnFontName ;
      Font.Size  := StdBtnFontSize ;
      exit;
    end;

    If ( aComponent is TLabel ) then
    Begin
      With ( aComponent as TLabel ) do If ( aComponent.Tag = 0 ) then
      Begin
        Font.Name        := StdBtnFontName;
        //Font.Size        := StdBtnFontSize;
      end;
      exit;
    end;

    If ( aComponent is TCheckBox ) then
    Begin
      With ( aComponent as TCheckBox ) do
      Begin
        Font.Name        := StdBtnFontName;
        //Font.Size        := StdBtnFontSize;
      end;
      exit;
    end;

    If ( aComponent is TControl ) then
    Begin
      If IsControlATabStop( TControl( aComponent ) ) then
      Begin
        SetControlFontName( TControl( aComponent ), StdEditFontName );
        SetControlFontSize( TControl( aComponent ), StdEditFontSize );
      end;
    end;

    For i := 0 to Pred( aComponent.ComponentCount ) do
      ApplyComponentStandards( aComponent.Components[ i ] );
  end;

Begin { ApplyStandards }
  ApplyComponentStandards( TComponent( F ) );
end;

// ---------------------------------------------------------

Procedure SetEditState( C : TControl; Const EditOK : Boolean );

Begin
  If EditOK then
  Begin
    SetControlReadOnly( C, False );
    SetControlFontColor( C, StdEditColor );
    SetControlTabStop( C, True );
  end
  else
  Begin
    SetControlFontColor( C, StdDisabledColor );
    SetControlTabStop( C, False );
    SetControlReadOnly( C, True );
  end;
end;

// ---------------------------------------------------------

Initialization
  StdEditFontName := GetEditFontName;
end.
