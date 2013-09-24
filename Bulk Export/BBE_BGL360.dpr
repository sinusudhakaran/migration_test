library BBE_BGL360;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ExtractCommon in '..\Common\Lib\ExtractCommon.pas',
  frmBGLConfig in 'frmBGLConfig.pas' {BGLXMLConfig},
  ExtractBGL360 in 'ExtractBGL360.pas',
  ExtractHelpers in '..\Common\Lib\ExtractHelpers.pas';

{$R *.res}

exports
   GetExtractVersion name GetVersionName,
   GetExtractType name GetExtractTypeName,
   DoBulkExport name BulkExportName,
   procInitDllApplication name procInitDllApplicationName,
   CheckFeature name CheckFeatureName;


begin
end.
