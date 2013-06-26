unit FHExceptions;

interface uses SysUtils;

Type
  FHException = Class( Exception );
  { ------------------------------------------------ }
  FHArrayBoundsException        = Class( FHException );
  FHNilPointerException         = Class( FHException );
  FHCorruptMemoryException      = Class( FHException );
  FHUnknownTokenException       = Class( FHException );
  FHInsufficientMemoryException = Class( FHException );
  { ------------------------------------------------ }
  FHOpCodeException             = Class( FHException );
  FHStringLengthException       = Class( FHException );

  { ------------------------------------------------ }

  FHCorruptFileException        = Class( FHException );
  FHDataValidationException     = Class( FHException );

implementation

end.
 