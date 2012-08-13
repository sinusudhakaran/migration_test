program bkUpg;

{%TogetherDiagram 'ModelSupport_bkUpg\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_bkUpg\upgClientCommon\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_bkUpg\bkUpg\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_bkUpg\upgStubfrm\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_bkUpg\upgConstants\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_bkUpg\default.txvpck'}

uses
  Forms,
  upgStubfrm in 'upgStubfrm.pas' {Form1},
  upgConstants in 'upgConstants.pas',
  upgClientCommon in 'upgClientCommon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
