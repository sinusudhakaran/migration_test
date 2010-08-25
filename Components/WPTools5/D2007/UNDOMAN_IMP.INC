// Include file: UNDOMAN_IMP.INC

constructor TWPUndoStack.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FOwnedObjects := TList.Create;
  FLockList := TList.Create;
  FUndoList := TList.Create;
  FRedoList := TList.Create;
  FUndoLinks := TList.Create;
  FUseLevel := FALSE;
  FLevel := 1;
  FMaxCount := -1;
end;

destructor TWPUndoStack.Destroy;
var
  i: Integer;
begin
  FOnChange := nil;
  Clear;
  for i := 0 to FUndoLinks.Count - 1 do
    TWPUndoManagerLink(FUndoLinks[i]).Free;
  FUndoLinks.Free;
  FOwnedObjects.Free;
  FUndoList.Free;
  FRedoList.Free;
  FLockList.Free;
  inherited Destroy;
end;

procedure TWPUndoStack.Loaded;
begin
  inherited Loaded;
  Changed;
end;

function TWPUndoStack.Locked(Source: TObject): Boolean;
begin
  Result := (FLockCount > 0) or (FLockList.IndexOf(Source) >= 0);
end;

function TWPUndoStack.AddUndoLink(Source: TObject): TWPUndoManagerLink;
var
  i: Integer;
begin
  for i := FUndoLinks.Count - 1 downto 0 do
    if TWPUndoManagerLink(FUndoLinks[i]) = Source then
    begin
      TWPUndoManagerLink(FUndoLinks[i]).Free;
      FUndoLinks.Delete(i);
    end;
  Result := TWPUndoManagerLink.Create;
  Result.FSource := Source;
  FUndoLinks.Add(Result);
end;

procedure TWPUndoStack.DeleteUndoLink(Source: TObject);
var
  i: Integer;
begin
  for i := FUndoLinks.Count - 1 downto 0 do
    if TWPUndoManagerLink(FUndoLinks[i]).Source = Source then
    begin
      TWPUndoManagerLink(FUndoLinks[i]).Free;
      FUndoLinks.Delete(i);
    end;
end;

procedure TWPUndoStack.LockSaving(Source: TObject; TakeSnapShot: Boolean);
begin
  if Source <> nil then
  begin
    if TakeSnapShot then SaveSnapShot(false, Source);
    FLockList.Add(Source);
  end
  else
  begin
    if TakeSnapShot then SaveSnapShot(false, Source);
    inc(FLockCount);
  end;
end;

procedure TWPUndoStack.UnlockSaving(Source: TObject);
var
  i: Integer;
begin
  if Source <> nil then
  begin
    i := FLockList.IndexOf(Source);
    if i >= 0 then FLockList.Delete(i);
  end
  else
  begin
    dec(FLockCount);
    if FLockCount < 0 then FLockCount := 0;
  end;
end;

function TWPUndoStack.Undo: Boolean; // TRUE if there is at least one operation left
var
  oldFWhileUndo, noCheckPoint: Boolean;
  TheUndoLevel, i:Integer;
 // oldcursor: TCursor;
begin
  oldFWhileUndo := FWhileUndo;
  if FUndoList.Count > 0 then
  try
    if not FWhileUndo then
      DoBeforeApply(nil);
    if not FWhileUndo then
    begin
      inc(FLevel);
      FUseLevel := FALSE;
    end;
    FWhileUndo := TRUE;
    TheUndoLevel := TWPUndoObject(FUndoList.Last).FLevel;
    // 1. Count
    i := FUndoList.Count - 1;
    // c := 0;
    while (i >= 0) and (TWPUndoObject(FUndoList[i]).FLevel = TheUndoLevel) do
    begin
      if not oldFWhileUndo and (TWPUndoObject(FUndoList[i]).FOperation = undoCheckpoint) then
        noCheckPoint := FALSE
      else
        noCheckPoint := TRUE;
      if (TheUndoLevel = 0) and noCheckPoint then break;
      dec(i);
      // inc(c);
    end;
    // More than 20 steps at once - better show a hourglass
  {  if c > 20 then
    begin
      oldcursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
    end
    else
      oldcursor := crDefault;  }
    // Apply Undo
    TheUndoLevel := TWPUndoObject(FUndoList.Last).FLevel;
    while (FUndoList.Count > 0) and
      (TWPUndoObject(FUndoList.Last).FLevel = TheUndoLevel) do
    begin
      if not oldFWhileUndo and (TWPUndoObject(FUndoList.Last).FOperation = undoCheckpoint) then
        noCheckPoint := FALSE
      else
      begin
        if TWPUndoObject(FUndoList.Last).Source <> nil then
          DoBeforeApply(TWPUndoObject(FUndoList.Last).Source);
        TWPUndoObject(FUndoList.Last).Apply;
        noCheckPoint := TRUE;
      end;
      TWPUndoObject(FUndoList.Last).Free;
      if (TheUndoLevel = 0) and noCheckPoint then break;
    end;
    // Reset cursor
  //  if c > 20 then Screen.Cursor := oldcursor;
  finally
    FWhileUndo := oldFWhileUndo;
    if not FWhileUndo then DoAfterApply;
  end;
  Result := FUndoList.Count > 0;
  if not FWhileUndo then Changed;
end;

// Undoes all operation for 'Source' only

function TWPUndoStack.UndoSource(Source: TObject): Boolean;
var
  oldFWhileUndo: Boolean;
  i: Integer;
begin
  oldFWhileUndo := FWhileUndo;
  if FUndoList.Count > 0 then
  try
    if not FWhileUndo then
      DoBeforeApply(nil);
    if not FWhileUndo then
    begin
      inc(FLevel);
      FUseLevel := FALSE;
    end;
    FWhileUndo := TRUE;
    i := FUndoList.Count - 1;
    while i >= 0 do
    begin
      if TWPUndoObject(FUndoList[i]).FSource = Source then
      begin
        if TWPUndoObject(FUndoList[i]).Source <> nil then
          DoBeforeApply(TWPUndoObject(FUndoList[i]).Source);
        TWPUndoObject(FUndoList[i]).Apply;
        TWPUndoObject(FUndoList[i]).Free;
      end;
      dec(i);
    end;
  finally
    FWhileUndo := oldFWhileUndo;
    if not FWhileUndo then DoAfterApply;
  end;
  Result := FUndoList.Count > 0;
  if not FWhileUndo then Changed;
end;

// Undoes all operations until it finds a certain checkpoint. If this checkpoint
// does not exist it does not undo anything. The checkpoint is removed

function TWPUndoStack.UndoToCheckpoint(CheckpointNR: Integer): Boolean;
var
  found: Boolean;
  i, CheckpointID: Integer;
begin
  found := FALSE;
  CheckpointID := 0;
  for i := 0 to FUndoList.Count - 1 do
    if TWPUndoObject(FUndoList[i]).FOperation = undoCheckpoint then
    begin
      dec(CheckpointNR);
      if CheckpointNR = -1 then
      begin
        CheckpointID := TWPUndoObject(FUndoList[i]).FID;
        found := TRUE;
        break;
      end;
    end;

  if found then
  try
    inc(FLevel);
    FUseLevel := FALSE;
    FWhileUndo := TRUE;
    while found and (FUndoList.Count > 0) do
    begin
      if (TWPUndoObject(FUndoList.Last).FOperation = undoCheckpoint) and
        (TWPUndoObject(FUndoList.Last).FID = CheckpointID) then found := FALSE;
      Undo;
    end;
  finally
    FWhileUndo := FALSE;
  end;
  Result := FUndoList.Count > 0;
  Changed;
end;

procedure TWPUndoStack.GetCheckpoints(List: TStrings);
var
  i: Integer;
begin
  if FCheckCount = 0 then
  begin
    if List.Count > 0 then List.Clear;
  end
  else
  begin
    List.BeginUpdate;
    try
      List.Clear;
      for i := 0 to FUndoList.Count - 1 do
        if TWPUndoObject(FUndoList[i]).FOperation = undoCheckpoint then
          List.Add(TWPUndoObject(FUndoList[i]).FText);
    finally
      List.EndUpdate;
    end;
  end;
end;

function TWPUndoStack.Redo: Boolean;
var
  TheUndoLevel, i: Integer;
 // oldcursor: TCursor;
begin
  if FRedoList.Count > 0 then
  try
    if not FWhileRedo then DoBeforeApply(nil);
    FWhileRedo := TRUE;
    inc(FLevel);
    FUseLevel := FALSE;
    TheUndoLevel := TWPUndoObject(FRedoList.Last).FLevel;
    // 1. Count
    i := FRedoList.Count - 1;
    // c := 0;
    while (i >= 0) and (TWPUndoObject(FRedoList[i]).FLevel = TheUndoLevel) do
    begin
      if TheUndoLevel = 0 then break;
      dec(i);
     // inc(c);
    end;
    // More than 20 steps at once - better show a hourglass
   { if c > 20 then
    begin
      oldcursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
    end
    else
      oldcursor := crDefault; }
    // Apply Undo
    while (FRedoList.Count > 0) and (TWPUndoObject(FRedoList.Last).FLevel = TheUndoLevel) do
    begin
      if TWPUndoObject(FRedoList.Last).Source <> nil then
        DoBeforeApply(TWPUndoObject(FRedoList.Last).Source);
      TWPUndoObject(FRedoList.Last).Apply;
      TWPUndoObject(FRedoList.Last).Free;
      if TheUndoLevel = 0 then break;
    end;
    // Reset Cursor
   // if c > 20 then Screen.Cursor := oldcursor;
  finally
    FWhileRedo := FALSE;
    if not FWhileRedo then DoAfterApply;
  end;
  Result := FRedoList.Count > 0;
  Changed;
end;

procedure TWPUndoStack.Clear;
var
  i: Integer;
begin
  try
  for i := 0 to FUndoList.Count - 1 do
  begin
    TWPUndoObject(FUndoList[i]).FOwner := nil;
    TWPUndoObject(FUndoList[i]).Free;
  end;
  for i := 0 to FRedoList.Count - 1 do
  begin
    TWPUndoObject(FRedoList[i]).FOwner := nil;
    TWPUndoObject(FRedoList[i]).Free;
  end;
  except
  end;
  FUndoList.Clear;
  FRedoList.Clear;
  try
  for i := 0 to FOwnedObjects.Count - 1 do
    TObject(FOwnedObjects[i]).Free;
  except
  end;
  FOwnedObjects.Clear;
  FLockList.Clear;
  FLockCount := 0;
  FUseLevel := FALSE;
  FCheckIDs := 0;
  FLevel := 1;
  Changed;
end;

// Remove all objects which are in the 'stack' but not used by and undo object
procedure TWPUndoStack.CleanStackObjects;
var
  i, j: Integer;
  obj: TObject;
begin
  for i := 0 to FOwnedObjects.Count - 1 do
  begin
    obj := FOwnedObjects[i];
    if obj <> nil then
      for j := 0 to FUndoList.Count - 1 do
        if TWPUndoObject(FUndoList[j]).FStackObject = obj then
        begin
          obj := nil;
          break;
        end;

    if obj <> nil then
      for j := 0 to FRedoList.Count - 1 do
        if TWPUndoObject(FRedoList[j]).FStackObject = obj then
        begin
          obj := nil;
          break;
        end;

    if obj <> nil then
    begin
      obj.Free;
      FOwnedObjects[i] := nil;
    end;
  end;
  FOwnedObjects.Pack;
end;

procedure TWPUndoStack.ClearSource(Source: TObject);
var
  i: Integer;
begin
  for i := 0 to FUndoList.Count - 1 do
    if TWPUndoObject(FUndoList[i]).FSource = Source then
    begin
      TWPUndoObject(FUndoList[i]).FOwner := nil;
      TWPUndoObject(FUndoList[i]).Free;
      FUndoList[i] := nil;
    end;
  FUndoList.Pack;
  for i := 0 to FRedoList.Count - 1 do
    if TWPUndoObject(FRedoList[i]).FSource = Source then
    begin
      TWPUndoObject(FRedoList[i]).FOwner := nil;
      TWPUndoObject(FRedoList[i]).Free;
      FRedoList[i] := nil;
    end;
  FRedoList.Pack;

  CleanStackObjects;

  repeat
    i := FLockList.IndexOf(Source);
    if i >= 0 then FLockList.Delete(i);
  until i < 0;

  FUseLevel := FALSE;
  Changed;
end;

// Save an object on the Undo Stack but check first if it can be combined

function TWPUndoStack.Save(RedoStack: Boolean; NewUndoObject: TWPUndoObject): Boolean;
var
  temp: TWPUndoObject;
begin
  temp := Saved(RedoStack);
  if (temp = nil) or not temp.CanCombine(NewUndoObject) then
    Result := InternSave(RedoStack, NewUndoObject)
  else
  begin
    NewUndoObject.Free;                                      
    Result := FALSE;
  end;
end;

procedure TWPUndoStack.SaveObjectDirectly(RedoStack: Boolean; NewUndoObject: TWPUndoObject);
begin
  if NewUndoObject <> nil then
  begin
    NewUndoObject.FOwner := Self;
    NewUndoObject.FIsRedo := RedoStack;
    if RedoStack then // REDO Stack
      FRedoList.Add(NewUndoObject)
    else // UNDO STACK
      FUndoList.Add(NewUndoObject);
  end;
end;

// Save an object on the Undo Stack

function TWPUndoStack.InternSave(RedoStack: Boolean; NewUndoObject: TWPUndoObject): Boolean;
begin
  if NewUndoObject <> nil then
  begin
    if NewUndoObject.FOperation = undoCheckpoint then inc(FCheckCount);
    NewUndoObject.FOwner := Self;
    if FWhileUndo or FWhileRedo or
      (FUseLevel and not RedoStack) then
      NewUndoObject.FLevel := FLevel;
    NewUndoObject.FIsRedo := RedoStack;
    if RedoStack then // REDO Stack
      FRedoList.Add(NewUndoObject)
    else // UNDO STACK
    begin
      if FMaxCount > 0 then SetMaxCount(FMaxCount);
      if not FWhileRedo then
        while FRedoList.Count > 0 do
          TWPUndoObject(FRedoList.First).Free;
      FUndoList.Add(NewUndoObject);
      FUndoBreak := FALSE;
    end;
    if (NewUndoObject.FStackObject <> nil) and
      (FOwnedObjects.IndexOf(NewUndoObject.FStackObject) < 0) then
      FOwnedObjects.Add(NewUndoObject.FStackObject);
    Changed;
    Result := TRUE;
  end
  else
    Result := FALSE;
end;

procedure TWPUndoStack.DoApplyUndoAction(var CurrentObject: TWPUndoObject);
begin
  if CurrentObject <> nil then
  begin
    if Assigned(FOnApplyUndoAction) then
      FOnApplyUndoAction(Self, CurrentObject.FSource, CurrentObject);
  end;
end;

procedure TWPUndoStack.DoBeforeApply(Source: TObject);
var
  i: Integer;
begin
  if Source = nil then
  begin
    for i := 0 to FUndoLinks.Count - 1 do
      TWPUndoManagerLink(FUndoLinks[i]).FApplied := FALSE
  end
  else
    for i := 0 to FUndoLinks.Count - 1 do
      if TWPUndoManagerLink(FUndoLinks[i]).FSource = Source then
      begin
        if assigned(FBeforeApply) then
          FBeforeApply(Self, TWPUndoManagerLink(FUndoLinks[i]).FSource);
        if assigned(TWPUndoManagerLink(FUndoLinks[i]).FBeforeApply) then
          TWPUndoManagerLink(FUndoLinks[i]).FBeforeApply(Self,
            TWPUndoManagerLink(FUndoLinks[i]).FSource);
        TWPUndoManagerLink(FUndoLinks[i]).FApplied := TRUE;
      end;
end;

procedure TWPUndoStack.DoAfterApply;
var
  i: Integer;
begin
  for i := 0 to FUndoLinks.Count - 1 do
    if TWPUndoManagerLink(FUndoLinks[i]).FApplied then
    begin
      if assigned(TWPUndoManagerLink(FUndoLinks[i]).FAfterApply) then
        TWPUndoManagerLink(FUndoLinks[i]).FAfterApply(Self,
          TWPUndoManagerLink(FUndoLinks[i]).FSource);
      if assigned(FAfterApply) then
        FAfterApply(Self, TWPUndoManagerLink(FUndoLinks[i]).FSource);
      TWPUndoManagerLink(FUndoLinks[i]).FApplied := FALSE;
    end;
end;

function TWPUndoStack.Saved(RedoStack: Boolean): TWPUndoObject;
begin
  Result := nil;
  if not FUndoBreak then
  begin
    if RedoStack and (FRedoList.Count > 0) then
      Result := TWPUndoObject(FRedoList.Last)
    else if FUndoList.Count > 0 then
      Result := TWPUndoObject(FUndoList.Last);
  end;
end;

// This are 2 standard actions to add undo support for simple edit fields
// The comparison "CanCombine" is not use to avoid the overhead of creating
// a new object

procedure TWPUndoStack.SaveTextInput(RedoStack: Boolean; Source, Element: TObject; Pos: Integer; Key: Char; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FOperation <> undoCharInput) or
      (UndoObject.FPos + Length(UndoObject.FText) <> Pos) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoCharInput;
      UndoObject.FPos := Pos;
      UndoObject.FText := Key;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end
    else
      UndoObject.FText := UndoObject.FText + Key;
  end;
end;

procedure TWPUndoStack.SaveTextDelete(RedoStack: Boolean; Source, Element: TObject; Pos, Count: Integer; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FOperation <> undoCharDelete) or
      (UndoObject.FPos + UndoObject.FLen <> Pos) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoCharDelete;
      UndoObject.FPos := Pos;
      UndoObject.FLen := Count;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end
    else
      inc(UndoObject.FLen, Count);
  end;
end;

// Easy to use function. Pos+Len is used to combine undo states
// If Len=0 then always a new item is created

procedure TWPUndoStack.SaveString(RedoStack: Boolean; Source, Element: TObject;
  const Value: string; ID, Pos, Len: Integer; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (len = 0) or
      (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FID <> ID) or
      (UndoObject.FOperation <> undoReplaceString) or
      (UndoObject.FPos + UndoObject.FLen <> Pos) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoReplaceString;
      UndoObject.FID := ID;
      UndoObject.FPos := Pos;
      UndoObject.FSource := Source;
      UndoObject.FElement := Element;
      UndoObject.FLen := Len;
      UndoObject.Modified := Modified;
      UndoObject.FText := Value;
      InternSave(RedoStack, UndoObject);
    end
    else
    begin
      inc(UndoObject.FLen, Len);
    end;
  end;
end;

function TWPUndoStack.SaveStream(RedoStack: Boolean; Source, Element: TObject; const Stream: TStream;
  ID: Integer; Modified: Boolean): TMemoryStream;
var
  UndoObject: TWPUndoObject;
begin
  Result := nil;
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (ID = 0) or
      (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FID <> ID) or
      (UndoObject.FOperation <> undoReplaceStream) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoReplaceStream;
      UndoObject.FID := ID;
      Result := UndoObject.Data;
      if Stream <> nil then
      begin
        Stream.Position := 0;
        Result.CopyFrom(Stream, Stream.Size);
      end;
      UndoObject.FSource := Source;
      UndoObject.FElement := Element;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end;
  end;
end;

procedure TWPUndoStack.SaveInt(RedoStack: Boolean; Source, Element: TObject;
  const Value: Integer; ID: Integer; Modified: Boolean);
var
  UndoObject: TWPUndoObject;
begin
  if not Locked(Source) then
  begin
    UndoObject := Saved(RedoStack);
    if (ID = 0) or
      (UndoObject = nil) or
      (UndoObject.FSource <> Source) or
      (UndoObject.FElement <> Element) or
      (UndoObject.FID <> ID) or
      (UndoObject.FOperation <> undoReplaceInteger) then
    begin
      UndoObject := TWPUndoObject.Create;
      UndoObject.FOperation := undoReplaceInteger;
      UndoObject.FID := ID;
      UndoObject.FValue := Value;
      UndoObject.FSource := Source;
      UndoObject.FElement := Element;
      UndoObject.Modified := Modified;
      InternSave(RedoStack, UndoObject);
    end;
  end;
end;

// never combined !

procedure TWPUndoStack.SaveSnapShot(RedoStack: Boolean; Source: TObject);
var
  newobj: TWPUndoObject;
  i: Integer;
begin
  if not Locked(Source) then
  begin
    for i := 0 to FUndoLinks.Count - 1 do
    begin
      if (TWPUndoManagerLink(FUndoLinks[i]).FSource = Source) and
        Assigned(TWPUndoManagerLink(FUndoLinks[i]).FOnTakeSnapshot) then
      begin
        newobj := TWPUndoObject.Create;
        try
          newobj.FSource := Source;
          TWPUndoManagerLink(FUndoLinks[i]).FOnTakeSnapshot(Self, Source, newobj);
          if newobj <> nil then
          begin
            //NO FUndoBreak := TRUE;
            Save(RedoStack, newobj);
          end;
        except
          newobj.Free;
        end;
      end;
    end;
    if Assigned(FOnTakeSnapshot) then
    begin
      newobj := TWPUndoObject.Create;
      try
        newobj.FSource := Source;
        FOnTakeSnapshot(Self, Source, newobj);
        if newobj <> nil then
        begin
          //NO FUndoBreak := TRUE;
          Save(RedoStack, newobj);
        end;
      except
        newobj.Free;
      end;
    end;
  end;
end;

function TWPUndoStack.SaveCheckpoint(const Title: string): Integer;
var
  UndoObject: TWPUndoObject;
begin
  inc(FCheckIDs);
  UndoObject := TWPUndoObject.Create;
  UndoObject.FOperation := undoCheckpoint;
  UndoObject.FID := FCheckIDs;
  UndoObject.FText := Title;
  Result := FCheckCount; // 0 based !
  InternSave(false, UndoObject);
end;

// Avoids the combination of a new and the last undo operations

procedure TWPUndoStack.NewUndoBreak;
begin
  // No combining of the same undo actions
  FUndoBreak := TRUE;
end;

procedure TWPUndoStack.NewUndoBreakTopLevel;
begin
  if FLevelsDepth <= 0 then FUndoBreak := TRUE;
end;

procedure TWPUndoStack.StartUndoLevel;
begin
  // now 'grouping' of undo actions
  inc(FLevelsDepth);
  if FLevelsDepth = 1 then
  begin
    inc(FLevel);
    Changed;
  end;
  FUseLevel := TRUE;
end;

function TWPUndoStack.EndUndoLevel: Boolean;
begin
  if FLevelsDepth > 0 then
    dec(FLevelsDepth);
  if FLevelsDepth = 0 then
  begin
    FUseLevel := FALSE;
    Changed;
  end;
  Result := FLevelsDepth > 0;
end;

// Get the last undo operation. Skips 'Checkpoint' markers

function TWPUndoStack.RecentAction: TWPUndoObject;
begin
  if FUndoList.Count > 0 then
    Result := TWPUndoObject(FUndoList.Last)
  else
    Result := nil;
end;

function TWPUndoStack.RecentRedoAction: TWPUndoObject;
begin
  if FRedoList.Count > 0 then
    Result := TWPUndoObject(FRedoList.Last)
  else
    Result := nil;
end;

function TWPUndoStack.GetCanUndo: Boolean;
var
  i: Integer;
begin
  Result := FALSE;
  for i := 0 to FUndoList.Count - 1 do
    if TWPUndoObject(FUndoList[i]).FOperation <> undoCheckpoint then
    begin
      Result := TRUE; break;
    end;
end;

function TWPUndoStack.LastUndoObj: TWPUndoObject;
var
  i: Integer;
begin
  Result := nil;
  for i := FUndoList.Count - 1 downto 0 do
    if (TWPUndoObject(FUndoList[i]).FOperation <> undoCheckpoint) and
       (TWPUndoObject(FUndoList[i]).FOperation <> undoCustomSkip)
    then
    begin
      Result := TWPUndoObject(FUndoList[i]); break;
    end;
end;

function TWPUndoStack.GetCanRedo: Boolean;
begin
  Result := FRedoList.Count > 0;
end;

procedure TWPUndoStack.EnumStackObjects(
  Source: TObject; UndoObjects, RedoObjects: Boolean; EnumCallback: TWPEnumStackObjects);
var
  i: Integer;
begin
  if UndoObjects then
    for i := 0 to FUndoList.Count - 1 do
      if TWPUndoObject(FUndoList[i]).FSource = Source then
        EnumCallback(Self, TWPUndoObject(FUndoList[i]));
  if RedoObjects then
    for i := 0 to FRedoList.Count - 1 do
      if TWPUndoObject(FRedoList[i]).FSource = Source then
        EnumCallback(Self, TWPUndoObject(FRedoList[i]));
end;

function TWPUndoStack.GetInGroup: Boolean;
begin
  Result := FLevelsDepth > 0;
end;
// Reduces the size of the undo buffer

procedure TWPUndoStack.SetMaxCount(x: Integer);
var
  lastlevel, currlevel: Integer; ischeck: Boolean;
begin
  FMaxCount := x;
  if (FUndoList.Count > 0) and (FMaxCount > 0) then
  begin
    x := FMaxCount - Count;
    lastlevel := 0;
    while (x <= 0) and (FUndoList.Count > 0) do
    begin
      currlevel := TWPUndoObject(FUndoList.First).FLevel;
      ischeck := TWPUndoObject(FUndoList.First).FOperation = undoCheckpoint;
      TWPUndoObject(FUndoList.First).Free;
      if not ischeck and ((currlevel = 0) or (lastlevel <> currlevel)) then inc(x);
      lastlevel := currlevel;
    end;
  end;
end;

procedure TWPUndoStack.Changed;
begin
  if assigned(FOnChange) then FOnChange(Self);
end;

procedure TWPUndoStack.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent <> nil) then
  begin
    DeleteUndoLink(AComponent);
  end;
end;

// Counts the elements on the und stack. Elements with the same level are
// counted as one element! Checkpoints are not counted !

function TWPUndoStack.Count: Integer;
var
  temp: TWPUndoObject;
  lastlevel, i: Integer;
begin
  Result := 0;
  lastlevel := 0;
  for i := 0 to FUndoList.Count - 1 do
  begin
    temp := TWPUndoObject(FUndoList[i]);
    if (temp.FOperation <> undoCheckpoint) and
      (temp.FLevel = 0) or (temp.FLevel <> lastlevel) then inc(Result);
    lastlevel := temp.FLevel;
  end;
end;

// Creates a new object and places it on the undo stack

constructor TWPUndoObject.Create;
begin
  inherited Create;
end;

// Destroys the object and removes it from the undo or redo stack
// The stack must always be freed from the tail !

destructor TWPUndoObject.Destroy;
var
  i: Integer;
begin
  if FData <> nil then FData.Free;
  if FOwnedObject <> nil then FOwnedObject.Free;
  FText := '';
  if FOwner <> nil then
  begin
    if FOperation = undoCheckpoint then dec(FOwner.FCheckCount);
    // Remove from Owner
    if FIsRedo then
    begin
      i := FOwner.FRedoList.IndexOf(Self);
      if i >= 0 then
        FOwner.FRedoList.Delete(i)
      else
        raise Exception.Create('Error - Redostack');
    end
    else
    begin
      i := FOwner.FUndoList.IndexOf(Self);
      if i >= 0 then
        FOwner.FUndoList.Delete(i)
      else
        raise Exception.Create('Error - Undostack');
    end;
  end;
  SetStackObject(nil);
  inherited Destroy;
end;

function TWPUndoObject.GetDescription: string;
begin
  Result := WPUndoDescriptions[FOperation];
end;

function TWPUndoObject.GetData: TMemoryStream;
begin
  if FData = nil then FData := TMemoryStream.Create;
  Result := FData;
end;

// Set and/or free the stack object

procedure TWPUndoObject.SetStackObject(x: TObject);
var
  oldstackobj: TObject;
  i, j: Integer;
begin
  if (FOwner <> nil) and (FStackObject <> x) then
  try
    oldstackobj := FStackObject;
    FStackObject := x;
    // Free the stack object - but only if it is not referenced somewhere else in the stack !
    if oldstackobj <> nil then
    begin
      // Do we list this object in the list of stack objects
      i := FOwner.FOwnedObjects.IndexOf(oldstackobj);
      // Yes, then we can check if we may free it
      if i >= 0 then
      begin
        // Free it and remove it from the FOwnedObjects if it is not used anywhere else
        for j := 0 to FOwner.FUndoList.Count - 1 do
          if TWPUndoObject(FOwner.FUndoList[j]).FStackObject = oldstackobj then exit;
        for j := 0 to FOwner.FRedoList.Count - 1 do
          if TWPUndoObject(FOwner.FRedoList[j]).FStackObject = oldstackobj then exit;
        // If we come here we may delete that
        oldstackobj.Free;
        FOwner.FOwnedObjects.Delete(i);
      end;
    end;
  finally
    if (FStackObject <> nil) and (FOwner <> nil) and (FOwner.FOwnedObjects.IndexOf(x) < 0) then
      FOwner.FOwnedObjects.Add(FStackObject);
  end;
end;

procedure TWPUndoObject.SetOwnedObject(x: TObject);
begin
  if FOwnedObject <> x then
  begin
    if FOwnedObject <> nil then FOwnedObject.Free;
    FOwnedObject := x;
  end;
end;

// Apply the undo object

procedure TWPUndoObject.Apply;
var
  o: TWPUndoObject;
begin
  if FOperation = undoCheckpoint then exit;
  o := Self;
  if assigned(FOnApply) then FOnApply(FOwner, Self, o);
  if (o <> nil) and (FOwner <> nil) then
  begin
    if assigned(FOwner.FOnUndoStringAction) and
      (FOperation = undoReplaceString) then
      FOwner.FOnUndoStringAction(FOwner, FSource, o, FID, FText)
    else if assigned(FOwner.FOnUndoIntegerAction) and
      (FOperation = undoReplaceInteger) then
      FOwner.FOnUndoIntegerAction(FOwner, FSource, o, FID, FValue)
    else if assigned(FOwner.FOnUndoStreamAction) and
      (FOperation = undoReplaceStream) and (FData <> nil) then
    begin
      FData.Position := 0;
      FOwner.FOnUndoStreamAction(FOwner, FSource, o, FID, FData);
    end;
    FOwner.DoApplyUndoAction(o);
  end;
end;

// This implementation only checks the minimum requirements

function TWPUndoObject.CanCombine(NewUndoObject: TWPUndoObject): Boolean;
begin
  if (NewUndoObject = nil) or (FOwner = nil) or
    (FOwner.FUndoBreak) then
    Result := FALSE
  else
    Result := (NewUndoObject.FOperation = FOperation) and // Same Operation (custom!)
    (NewUndoObject.FElement = FElement) and // Same Element
    (NewUndoObject.FSource = FSource) and // Same Source
    (NewUndoObject.FID = FID) and // same ID
    (NewUndoObject.ClassName = Self.ClassName); // and in the same class only
end;
