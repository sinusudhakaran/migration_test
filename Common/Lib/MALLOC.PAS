unit malloc;
{------------------------------------------}
{  A wrapper around object for delphi to   }
{ allow common use of code with pascal     }
{                                          }
{------------------------------------------}


interface

procedure SafeGetMem( var P ; size : integer ) ;
procedure SafeFreeMem( var P ; size : integer );

implementation
{------------------------------------------}
procedure SafeGetMem(var P; size : integer);
begin
  try
     GetMem(pointer(p),size);
  except
     {trap the error and do nothing, user code will handle nil pointer}
     pointer(p) := nil;
  end;
end;

procedure SafeFreeMem(var P ; size : integer);
begin
   FreeMem(pointer(p),size);
   pointer(p) := nil;
end;

end.
