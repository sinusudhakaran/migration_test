{== Unit StreamIO
=====================================================}
{: Implements a text-file device driver that allows textfile-style I/O
   on streams.
@author Dr. Peter Below
@desc   Version 1.0 created 4 Januar 2001<BR>
        Current revision 1.0<BR>
        Last modified       4 Januar 2001

02.06.2005 Modified by Piotr Smolira:
           Corrected CRLF handling in Delphi 7<P>
}{======================================================================
}
unit StreamIO;

interface
uses classes;

{-- AssignStream
------------------------------------------------------}
{: Attach a stream to a Textfile to allow I/O via WriteLn/ReadLn
@Param F is the textfile to attach the stream to
@Param S is the stream
@Precondition  S <> nil
@Desc The passed streams position will be set to 0 by Reset and Rewrite
  and to the streams end by Append. The stream is not freed when the
  textfile is closed via CloseFile and it has to stay in existence as
  long as the textfile is open.
}{ Created 4.1.2001 by P. Below -----------------------------------------------------------------------
}
procedure AssignStream(var F: Textfile; S: TStream);

implementation

uses sysutils;

{-- GetDevStream
------------------------------------------------------}
{: Get the stream reference stored in the textrec userdata area
@Param F is the textfile record
@Returns the stream reference
@Postcondition result <> nil
}{ Created 4.1.2001 by P. Below -----------------------------------------------------------------------
}

function GetDevStream(var F: TTextRec): TStream;
begin { GetDevStream }
  Move(F.Userdata, Result, Sizeof(Result));
  Assert(Assigned(Result));
end; { GetDevStream }

{-- DevIn
-------------------------------------------------------------}
{: Called by Read, ReadLn etc. to fill the textfiles buffer from the
   device.
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below -----------------------------------------------------------------------
}

function DevIn(var F: TTextRec): Integer;
begin { DevIn }
  Result := 0;
  with F do
    begin
      BufEnd := GetDevStream(F).Read(BufPtr^, BufSize);
      BufPos := 0;
    end; { With }
end; { DevIn }

{-- DevFlushIn
--------------------------------------------------------}
{: A dummy method, flush on input does nothing.
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below -----------------------------------------------------------------------
}

function DevFlushIn(var F: TTextRec): Integer;
begin { DevFlushIn }
  Result := 0;
end; { DevFlushIn }

{-- DevOut
------------------------------------------------------------}
{: Write the textfile buffers content to the stream. Called by Write,
   WriteLn when the buffer becomes full. Also called by Flush.
@Param F is the textfile to operate on
@Returns 0 (no error)
@Raises EStreamError if the write failed for some reason.
}{ Created 4.1.2001 by P. Below -----------------------------------------------------------------------
}

function DevOut(var F: TTextRec): Integer;
begin { DevOut }
  Result := 0;
  with F do
    if BufPos > 0 then
      begin
        GetDevStream(F).WriteBuffer(BufPtr^, BufPos);
        BufPos := 0;
      end; { If }
end; { DevOut }

{-- DevClose
----------------------------------------------------------}
{: Called by Closefile. Does nothing here.
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below -----------------------------------------------------------------------
}

function DevClose(var F: TTextRec): Integer;
begin { DevClose }
  Result := 0;
end; { DevClose }

{-- DevOpen
-----------------------------------------------------------}
{: Called by Reset, Rewrite, or Append to prepare the textfile for I/O
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below -----------------------------------------------------------------------
}

function DevOpen(var F: TTextRec): Integer;
begin { DevOpen }
  Result := 0;
  with F do
    begin
      case Mode of
        fmInput:
          begin { Reset }
            InOutFunc := @DevIn;
            FlushFunc := @DevFlushIn;
            BufPos := 0;
            BufEnd := 0;
            GetDevStream(F).Position := 0;
          end; { Case fmInput }
        fmOutput:
          begin { Rewrite }
            InOutFunc := @DevOut;
            FlushFunc := @DevOut;
            BufPos := 0;
            BufEnd := 0;
            GetDevStream(F).Position := 0;
          end; { Case fmOutput }
        fmInOut:
          begin { Append }
            Mode := fmOutput;
            DevOpen(F);
            GetDevStream(F).Seek(0, soFromEnd);
          end; { Case fmInOut }
      end; { Case }
    end; { With }
end; { DevOpen }

procedure AssignStream(var F: Textfile; S: TStream);
begin { AssignStream }
  Assert(Assigned(S));
  with TTextRec(F) do
    begin
      Mode := fmClosed;
      BufSize := SizeOf(Buffer);
      BufPtr := @Buffer;
      OpenFunc := @DevOpen;
      CloseFunc := @DevClose;
      Name[0] := #0;
      { Store stream reference into Userdata area }
      Move(S, Userdata, Sizeof(S));
    end; { With }
  {$IFNDEF VER130}                // Compiler version in D5
  {$IF RTLVersion >= 15.00}       // RTL version in D7 (D5 does not understand this directive)
  SetLineBreakStyle(F,tlbsCRLF);  // Delphi version 7.0 (and probably later ones) must invoke this for lines to terminate with CRLF
  {$IFEND}
  {$ENDIF}
end; { AssignStream }

end { StreamIO }.
