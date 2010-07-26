//Flexcel Centralized Configuration file
//Read this file and change it to fit your needs.


//This is an intentional error, so you are directed here
//the first time you install FlexCel. Read this file,
//configure it as neccesary, and delete the "x" above

{$DEFINE TMSASG}


//Define your language by deleting the "*" in the language you want to use.
//If you don't define one, english will be used
{*$DEFINE SPANISH}
{*$DEFINE FRENCH}
{*$DEFINE ITALIAN}
{*$DEFINE ROMANIAN}
{*$DEFINE PORTUGUESEBR}
{*$DEFINE CHINESE}
{*$DEFINE RUSSIAN}
{*$DEFINE GERMAN}

//Define your Delphi version on Excel Server Components.
//Note that this is not the version of excel you have, is the version of DELPHI components (see install.doc)
//Leave just one of this 3 defines uncommented

//Note2: This is only for Delphi. If you are using C++Builder, it doesn't matter
//        as you will be using always Excel2000 type libraries

{*$DEFINE EXCEL97}
{$DEFINE EXCEL2000}
{*$DEFINE EXCELXP}


// CLX and/or VCL. 
// By default, CLX is defined on LINUX and VCL on Windows. If you want, you can
// change this to use CLX on Windows.

{$IFDEF WIN32}
  {$DEFINE FLX_VCL}
{$ELSE}
  {$DEFINE FLX_CLX}
{$ENDIF}

{$DEFINE FLEXCELADVSTRINGGRID}


