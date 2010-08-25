unit KGlibImport;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$A8}{$Z4}
interface
uses Libc;
const
  libgobject='libgobject-2.0.so.0';
  libglib='libglib-2.0.so.0';

type
  gboolean= LongBool;
  gint32= Longint;
  guint32= LongWord;
  guint8 = byte;
  pguint8 = ^guint8;
  gint = integer;
  gchar=char;
  pgint = ^gint;
  ssize_t = size_t;
  gsf_off_t=int64;

  GError = record
    domain: guint32;
    code: integer;
    message: PChar;
  end;

  PGError=^GError;
  PPGError=^PGError;

  ////////////////////////////////////////////////////////////////////////

  procedure g_error_free(err: PGError);cdecl;external libglib;
  procedure g_object_unref(p: pointer);cdecl;external libgobject;

  function g_malloc(size: guint32): pointer;cdecl;external libglib;
  procedure g_free(mem: pointer);cdecl;external libglib;
implementation

end.
