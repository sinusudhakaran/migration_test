{$D-}
{##############################################################################}
{# NexusDB: nxDefine.inc 2.00                                                 #}
{# NexusDB Memory Manager: nxDefine.inc 2.03                                  #}
{# Copyright (c) Nexus Database Systems Pty. Ltd. 2003                        #}
{# All rights reserved.                                                       #}
{##############################################################################}
{# NexusDB: Compiler options/directives include file                          #}
{##############################################################################}

{NOTE: nxDefine.inc is included in all NexusDB units; hence you can
       specify global compiler options here. nxDefine.inc is included
       *before* each unit's own required compiler options, so options
       specified here could be overridden by hardcoded options in the
       unit source file.}

{====Determination of compiler (do NOT change)====}
{$IFDEF VER100}
  Not supported!
  {$DEFINE Delphi3}
  {$DEFINE IsDelphi}
  {$DEFINE CannotOverrideDispatch}
{$ENDIF}
{$IFDEF VER110}
  Not supported!
  {$DEFINE CBuilder3}
{$ENDIF}
{$IFDEF VER120}
  Not supported!
  {$DEFINE Delphi4}
  {$DEFINE IsDelphi}
  {$DEFINE DCC4OrLater}
  {$DEFINE HasStrictCardinal}
  {$DEFINE ResizePersistFields}
{$ENDIF}
{$IFDEF VER125}
  Not supported!
  {$DEFINE CBuilder4}
  {$DEFINE DCC4OrLater}
  {$DEFINE HasStrictCardinal}
  {$DEFINE ResizePersistFields}
{$ENDIF}
{$IFDEF VER130}
  {$DEFINE DCC4OrLater}
  {$DEFINE DCC5OrLater}
  {$DEFINE ProvidesDatasource}
  {$IFNDEF BCB}
    {$DEFINE Delphi5}
    {$DEFINE IsDelphi}
    {$DEFINE HasStrictCardinal}
    {$DEFINE ResizePersistFields}
  {$ELSE}
    {$DEFINE CBuilder5}
    {$DEFINE HasStrictCardinal}
    {$DEFINE ResizePersistFields}
  {$ENDIF}
{$ENDIF}
{$IFDEF VER140}
  {$DEFINE DCC4OrLater}
  {$DEFINE DCC5OrLater}
  {$DEFINE DCC6OrLater}
  {$DEFINE ProvidesDatasource}
  {$IFNDEF BCB}
    {$DEFINE Delphi6}
    {$DEFINE IsDelphi}
    {$DEFINE HasStrictCardinal}
    {$DEFINE ResizePersistFields}
  {$ELSE}
    {$DEFINE CBuilder6}
    {$DEFINE HasStrictCardinal}
    {$DEFINE ResizePersistFields}
  {$ENDIF}
{$ENDIF}
{$IFDEF VER170}
  {$DEFINE DCC4OrLater}
  {$DEFINE DCC5OrLater}
  {$DEFINE DCC6OrLater}
  {$DEFINE DCC7OrLater}
  {$DEFINE ProvidesDatasource}
  {$IFNDEF BCB}
    {$DEFINE Delphi7}
    {$DEFINE IsDelphi}
    {$DEFINE HasStrictCardinal}
    {$DEFINE ResizePersistFields}
  {$ELSE}
    Not yet supported!
  {$ENDIF}
{$ENDIF}
{$IFDEF VER180}
  {$DEFINE DCC4OrLater}
  {$DEFINE DCC5OrLater}
  {$DEFINE DCC6OrLater}
  {$DEFINE DCC7OrLater}
  {$DEFINE ProvidesDatasource}
  {$IFNDEF BCB}
    {$DEFINE Delphi7}
    {$DEFINE IsDelphi}
    {$DEFINE HasStrictCardinal}
    {$DEFINE ResizePersistFields}
  {$ELSE}
    Not yet supported!
  {$ENDIF}
{$ENDIF}

{$IFNDEF DCC5OrLater}
  Compiler not yet supported!
{$ENDIF}

{====Global fixed compiler options (do NOT change)====}
{$U-} // Pentium-safe FDIV OFF
{$I+} // I/O checking ON
{$A+} // align on quad word boundaries ON
{$B-} // Complete boolean eval OFF
{$X+} // Extended syntax ON
{$T-} // Typed @ operator OFF
{$P+} // Open parameters ON
{$H+} // Huge strings ON
{$J-} // Assignable typed constants OFF
{$Z-} // minimum enum size = 1 byte
{$IFOPT D+}
  {.$O-} // Optimization OFF
  {.$W+} // Stack frames ON
  {.$R+} // Range checking ON
  {.$Q+} // Overflow checking ON

  {.$L+} // Local symbols ON
  {.$Y+} // Reference info ON
  {.$C+} // Assertions ON
{$ELSE}
  {$O+} // Optimization ON
  {$W-} // Stack frames OFF
  {$R-} // Range checking OFF
  {$Q-} // Overflow checking OFF

  {$L-} // Local symbols OFF
  {$Y-} // Reference info OFF
  {$C-} // Assertions OFF
{$ENDIF}

{---Delphi 6---}
  {$IFDEF Delphi6}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN SYMBOL_DEPRECATED OFF}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN UNIT_DEPRECATED OFF}
  {$ENDIF}
{---Delphi 7---}
  {$IFDEF Delphi7}
  {$WARN SYMBOL_PLATFORM OFF}
  {$WARN SYMBOL_DEPRECATED OFF}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
  {$WARN UNIT_DEPRECATED OFF}
  {$ENDIF}
{---C++Builder 5---}
  {$IFDEF CBuilder5}
  {$OBJEXPORTALL ON}
  {$ENDIF}
{---C++Builder 6---}
  {$IFDEF CBuilder6}
  {$OBJEXPORTALL ON}
  {$ENDIF}

{====General defines=================================================}

{Activate the following define to remove most locking code from the
 server engine. When this define is enabled the following limitations apply:
 - only usable with an embedded server engine
 - only a single session can connect to the server engine
 - all databases are opened in exclusive mode
 - all tables are opened in exclusive mode
 - everything that creates a TnxThread will result in a DBIERR_NOTSUPPORTED
   exception. This includes: transports, restructure, pack,
   reindex, async record count
 - only a single thread may call the server engine.}
{.$DEFINE NoLocking}

{Activate the following define to enable safer text comparisons.
AnsiCompareText has problems comparing text for some locals that cause
this define to be necessary. For instance, in the Norwegian locale,
BAALAM <> BaAlam when using AnsiCompareText, instead AnsiCompareText
should report that the values are equal.
Enabling this define will cause AnsiLowerText to be performed on
both input strings before AnsiCompareText is called.}
{.$DEFINE SafeAnsiCompare}

{Deactivate the UseMMXInstructions define if you expect your
customers to have very old hardware without MMX support,
e.g. Pentium 133 and older. For Delphi 5 it is deactivated
as it doesnt support the assembly instructions.}
{$IFDEF DCC6OrLater}
  {$DEFINE UseMMXInstructions}
{$ENDIF}


{====CLIENT specific defines=========================================}

{Activate the following define to look to the Registry for Client
 configuration information.}
{$DEFINE UseRegistryConfig}

{Activate the following define to look to the ini file for Client
 configuration information}
{.$DEFINE UseINIConfig}

{====SERVER specific defines=========================================}
{Activate the following define to compile a secured server}
{$DEFINE SecureServer}
  {$IFDEF SecureServer}
    {Turn on the following define to make TempStorage secure}
    {.$DEFINE SecureTempStorage}
  {$ENDIF}

{ Turn this on to prevent creation of new and access to existing file blobs.}
{.$DEFINE BLOBENGINE_NOFILEBLOBS}

{Activate the following defines to enable debugging code}
{.$DEFINE NX_DEBUG}
  {$IFDEF NX_DEBUG}
    {.$DEFINE NX_DEBUG_WALKINDEX}
    {$DEFINE NX_DEBUG_THREAD}
      {$IFDEF NX_DEBUG_THREAD}
        {$DEFINE NX_DEBUG_THREAD_THREADNAMES}
      {$ENDIF}
    {$DEFINE NX_DEBUG_MEMORYMANAGER}
      {$IFDEF NX_DEBUG_MEMORYMANAGER}
        {.$DEFINE NX_DEBUG_MEMORYMANAGER_CLEARONFREE}
        {.$DEFINE NX_DEBUG_MEMORYMANAGER_SEPERATEBLOCKS}
        {.$DEFINE NX_DEBUG_MEMORYMANAGER_BYPASS}
      {$ENDIF}
    {.$DEFINE NX_DEBUG_STREAMS}
      {$IFDEF NX_DEBUG_STREAMS}
        {.$DEFINE NX_DEBUG_STREAMS_BYPASS}
      {$ENDIF}
    {,$DEFINE NX_DEBUG_BUFFERMANAGER}
      {$IFDEF NX_DEBUG_BUFFERMANAGER}
        {,$DEFINE NX_DEBUG_BUFFERMANAGER_PROTECT_READONLY}
      {$ENDIF}
    {.$DEFINE NX_DEBUG_CS}
      {$IFDEF NX_DEBUG_CS}
        {.$DEFINE NX_DEBUG_CS_BLOCKHEAPENGINE}
      {$ENDIF}
  {$ENDIF}

{Activate the following define to enable exception logging.

Note: You must manually set the project to create a map file for this
      option to be useful}

{.$DEFINE NX_EXCEPTION_LOG}

{.$DEFINE NX_TRIAL}

{.$DEFINE NX_EMBEDDEDSERVER_ONLY}

{.$DEFINE NX_LITE}

{$DEFINE NX_MEMMAN_ONLY}

{.$DEFINE NX_MEMMANTRIAL}

{-------- !! DO NOT CHANGE DEFINES BELOW THIS LINE !! --------}

{$DEFINE NEXUS}
{$DEFINE NEXUS2}
