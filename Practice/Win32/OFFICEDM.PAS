unit Officedm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:    Office Components Data Module

   Written:  Apr 2000
   Authors:  Matthew

   Purpose:  Hold the Office Partner components for connecting to Excel and Word

   Notes:    The code that uses these components assumes that default documents and
             ranges will be available for each application.  This means that in
             Excel a workbook, worksheet and range should be created at DESIGN TIME
             so that it will be available at run time.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpShared, OpXL2K, OpExcel, OpXLXP;

type
  TDataModuleOffice = class(TDataModule)
    OpExcel1: TOpExcel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
//******************************************************************************
implementation

{$R *.DFM}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.                                     
