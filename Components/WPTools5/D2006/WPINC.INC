//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPINC.INC - WPTools 5 Compiler Configuration
//******************************************************************************

{.$DEFINE WPREPORTER} //= WPReporter addon, part of "Bundle"!
   // http://www.wpcubed.com/products/wpreporter/index.htm

{.$DEFINE WPQUICK4} //=Support for Quickreport 4 - please ask for pricing

{$DEFINE WPSPELL} //= spellcheck addon.
   //  http://www.wpcubed.com/products/wpspell/

{.$DEFINE WPPREMIUM} //= addon for footnotes and text boxes
   // http://www.wpcubed.com/products/wptools/premium/

{.$DEFINE WPPDFEX} //= link in wPDF, our PDF addon

// Include the WPShared library right into the WPTools package
{$DEFINE INCLUDE_WPSHARED}

// Include our product WPForm right into WPTools
{.$DEFINE INCLUDE_WPFORM}

// Use ToolBar2000 extensions to draw themes -
// better defined this symbol in the project options
{-$DEFINE USETBX}

{$DEFINE RTLSUPPORT}//ON

// Activate this define to use Mike Lischkes open source graphic library
// GraphicEx to load PNG and GIF files. Don't forget to globally enabled the
// defines in GraphicConfiguration.inc, for GIF support also 'UseLZW'
// --> see unit WPObj_Image
{.$DEFINE GRAPHICEX}


// Activate this define to use Gustavo Dauds open source graphic library
// TPNGImage to load PNG and GIF files. If you use also GraphicEx you
// should deativate the PNG support in GraphicConfiguration.inc
// --> see unit WPObj_Image
{.$DEFINE PNGIMG}

// If defined pasted images will be saved as JPEG data (see procedure Compress in WPObj_Image)
{.$DEFINE COMPRESSBITMAPASJPEG}

// Don't link in DB units ------------------------------------------------------
{.$DEFINE NODB} // Default: OFF

// If defined the TWPTextObj.Source overrides the setting of TWPObject.StreamName
// this is used in WPIOWriteRTF, WPOBJ_Image, and WPIO_HTML
{$DEFINE WPIMG_USE_SOURCE_AS_LINK}

{$DEFINE ASSIGN_IMG_PATH} // The HTML Reader assigns the Source and StreamName
// properties. This way saving to RTF will NOT include the complete data.

// If the editor uses a beam cursor switch to crArrow if it is outside the page area
{$DEFINE AUTOSWITCH_BEAMCURSOR}

// If this property is defined the TParagraph and other objects create
// get/set properties which allow the access to properties which are now
// stored differently to WPTools V4 and before
{$DEFINE CREATE_COMPAT_PROPS} // Create par.indentleft etc

// Add Debug Information -------------------------------------------------------
{$IFNDEF NODEBUG}
   {$DEFINE WPDEBUG}
{$ENDIF}

// Compile WPTools 5DEMO Version
{--$DEFINE WPDEMO}

{$DEFINE USEPACKAGES}
{$DEFINE DELPHI4}
{$DEFINE DELPHI3ANDUP}
{$DEFINE DELPHI5ANDUP}
{$IFDEF BCB}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$IFNDEF VER130}
{$DEFINE DELPHI6ANDUP}
{$ENDIF}
{$DEFINE ALLOWCURSORINROWS}
{xxx$DEFINE PUBLISH_CODETEXT} // do not activate if you also use Delphi 5!!!

{.$DEFINE WPALLWARN} // Show platform warnings

{$IFDEF NODEBUG}
   {$IFDEF VER150}
   {$WARNINGS OFF}
   {$ENDIF}
{$ENDIF}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
{$DEFINE WPTOOLS5} // must be defined
{$DEFINE ALLOWUNDO} // ON
{$IFDEF WPDEMO}
{$R-}   // used for demo only
{$O+}   // used for demo only
{$DEFINE WPREPORTER}
{$DEFINE WPPREMIUM} // The demo is compiled as "Premium"
{$UNDEF WPDEBUG}
{$ELSE}
{$IFDEF WPDEBUG}
 {$R+}   // Rangecheck (suggestet setting: -)
 {$O-}   // Optimation (suggestet setting: +)
 {---$DEFINE READERDEBUG}
{$ELSE}
 {$O+}
 {$R+}
{$ENDIF}
{$ENDIF}

{$DEFINE WPTOOLS512B} // new generation RTF engine
{$B-} // Eval Bool: ShortCurt - required for WPTools!
