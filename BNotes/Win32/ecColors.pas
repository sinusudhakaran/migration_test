unit ecColors;
//------------------------------------------------------------------------------
{
   Title:       Colors

   Description: Holds global color values

   Remarks:

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface

uses
  Graphics, Forms, Windows;

const
  clBankLinkBlue    = $009F6300;
  clBankLinkGreen   = $00B3A100;

  //256 colour palette
  BKCOLOR_BLUE = $00800000;
  BKCOLOR_TEAL = $00808000;

  //hi colour palette
  BKHICOLOR_BLUE = $00995A00;
  BKHICOLOR_TEAL = $009F9B00;

var
  clAltLine         : TColor;
  clLightPanel      : TColor;
  clSelectedRow     : TColor;
  clExtraLight      : TColor;
  clBorderColor     : TColor;
  clSuperFields     : TColor;

procedure SetDefaultColors(Is256Color : Boolean);

//******************************************************************************

implementation

uses
  INISettings;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SetDefaultColors(Is256Color : Boolean);
begin
  if (INI_Theme = 'Desert') then
  begin
    if Is256Color then
    begin
      clLightPanel        := clSilver;
      clAltLine           := $0080FFFF; //yellow
      clSelectedRow       := clAqua;
      clExtraLight        := clWhite;
      clBorderColor       := BKCOLOR_BLUE;
      clSuperFields       := BKCOLOR_BLUE;
    end else
    begin
      clLightPanel        := $00E6E6E6;
      clAltLine           := $00E0FFFF; //yellow
      clSelectedRow       := clSkyBlue;
      clExtraLight        := $00F2F2F2;
      clBorderColor       := BKHICOLOR_BLUE;
      clSuperFields       := BKHICOLOR_BLUE;
    end;
  end else if (INI_Theme = 'Sky') then
  begin
    if Is256Color then
    begin
      clLightPanel        := clSilver;
      clAltLine           := clAqua; //blue
      clSelectedRow       := $0080FFFF; //yellow
      clExtraLight        := clWhite;
      clBorderColor       := BKCOLOR_BLUE;
      clSuperFields       := BKCOLOR_BLUE;
    end else
    begin
      clLightPanel        := $00E6E6E6;
      clAltLine           := $00F5EDDE;
      clSelectedRow       := $00CCFFFF; //yellow
      clExtraLight        := $00F2F2F2;
      clBorderColor       := BKHICOLOR_BLUE;
      clSuperFields       := BKHICOLOR_BLUE;
    end;
  end else
  begin
    //default
    if Is256Color then
    begin
      clLightPanel        := clSilver;
      clAltLine           := clBtnFace;
      clSelectedRow       := clAqua;
      clExtraLight        := clWhite;
      clBorderColor       := BKCOLOR_BLUE;
      clSuperFields       := BKCOLOR_BLUE;
    end else
    begin
      clLightPanel        := $00E6E6E6;
      clAltLine           := $00F5EDDE;
      clSelectedRow       := $00409FFF; //orange
      clExtraLight        := $00F2F2F2;
      clBorderColor       := BKHICOLOR_BLUE;
      clSuperFields       := BKHICOLOR_BLUE;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
