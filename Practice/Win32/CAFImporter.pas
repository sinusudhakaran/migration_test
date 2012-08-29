unit CAFImporter;

interface

type
  TCAFFileFormat = (cafPDF=0);

  TCAFImporter = class
  protected
    function PerformImport: Boolean; virtual; abstract;
  public
    constructor Create; virtual;
    
    procedure Import(ImportFile: String; FileFormat: TCAFFileFormat; OutputFolder: String);
    
    function Validate(ImportFile: String): Boolean; virtual; abstract;
  end;

  THSBCCAFImporter = class(TCAFImporter)
  protected
    function PerformImport: Boolean; override;
    function Validate(ImportFile: String): Boolean; override;
  end;
  
implementation

{ TCAFImporter }

constructor TCAFImporter.Create;
begin

end;

procedure TCAFImporter.Import(ImportFile: String; FileFormat: TCAFFileFormat; OutputFolder: String);
begin
  
end;


{ THSBCCAFImporter }

function THSBCCAFImporter.PerformImport: Boolean;
begin

end;

function THSBCCAFImporter.Validate(ImportFile: String): Boolean;
begin
  
end;

end.
