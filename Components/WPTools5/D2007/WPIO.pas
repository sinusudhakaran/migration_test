unit WPIo;

{:: The only goal of this unit is to include all
  available Reader and writer units which have to be included individually otherwise.
  This unit also includes the image objects defined in unit WPObjImage. The WPTools unit
  WPCtrMemo includes this unit, too.
  <br>
  To exclude support for HTML define "WPNOHTMLSUPPORT" in the projects options and do a BuildAll.
  HTML will be then loaded in ANSI format.
  <br>
  To exclude support for RTF define "WPNORTFSUPPORT" in the projects options and do a BuildAll.
  RTF will be also loaded in ANSI format.
  <br>
  To exclude support for the WPTOOLS text format define "WPNOWPTOOLSSUPPORT" in the projects
  options and do a BuildAll. WPTOOLS will be then loaded in HTML or ANSI format. Note that
  the clipboard operations work best with WPTOOLS format.
}

{$I WPINC.INC}

interface

uses  WPIoANSI
      {$IFNDEF WPNORTFSUPPORT} ,WPIOReadRTF, WPIOWriteRTF
         {$IFDEF WPPREMIUM} ,WPIORTFPremium {$ENDIF}
       {$ENDIF}
      {$IFNDEF WPNOHTMLSUPPORT} ,WPIOHTML {$ENDIF}
      {$IFNDEF WPNOUNICODESUPPORT} ,WPIOUNICODE {$ENDIF}
      {$IFNDEF WPNOWPTOOLSSUPPORT} ,WPIOWPTools {$ENDIF}
      {$IFDEF WPPREMIUM},WPObj_TextBox {$ENDIF}
      ,WPObj_Image;

{$IFNDEF VER130}
//{$MESSAGE Warn '*** (Info) Reader and writer classes have been included using unit "WPIO"'}
{$ENDIF}

implementation

end.
