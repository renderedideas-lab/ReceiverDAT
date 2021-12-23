program ReceiverDat;

{$APPTYPE Console}

uses System.SysUtils, System.Classes, System.IOUtils;

function read_null_string(var fs: tfilestream; var target: string; sz: integer):Boolean;
var
  i: integer;
  c: char;
begin
  i:=0;
  fs.Read(c,1);
  while (c<>#0) and (fs.Position<fs.size) do
  begin

    if (i = sz-1) then
	  begin
      WriteLn(Output,'ERROR : read_null_string: Exceeded buffer');
      Result:=false;
      exit;
    end;
    target[i+1]:=c;
    fs.Read(c,1);
    inc(i);
  end;
  setlength(target,i);
  Result:=true;
end;


procedure readreceiverdat;
var
  station,title: string;
  year: uint16;
  month,day,utc_hour,minute: uint8;
  fs: tfilestream;
begin

  setlength(station,512);
  setlength(title,512);

  if not FileExists(ParamStr(1)) then
  begin
    WriteLn(Output, Format('ERROR : Cannot open file "%s"',[ParamStr(1)]));
    Exit;
  end;
  fs:=tfilestream.Create(ParamStr(1),fmopenread);
  writeln(Output, Format('Opening file "%s"',[ParamStr(1)]));

  { Read Station }
  if fs.Seek(13,0) = -1 then
  begin 
    WriteLn(Output,'ERROR : Cannot seek to station');
    fs.Free;
    Exit;
  end;
  if not read_null_string(fs,station,length(station)) then
  begin 
    fs.Free;
    Exit;
  end;
  writeln(Output, 'Reading STATION');
  
  { Read movie title }
  if fs.Seek($95,0) = -1 then
  begin
    WriteLn(Output,'ERROR : Cannot seek to title');
    fs.Free;
    Exit;
  end;
  if not read_null_string(fs, title, length(title)) then
  begin 
    fs.Free;
    Exit;
  end;
  writeln(Output,'Reading TITLE');

  { Read date }
  if fs.Seek($D8,0) = -1 then
  begin
    WriteLn(Output,'ERROR : Cannot seek to year');
    fs.Free;
    Exit;
  end;
  if fs.Read(year,2) <> 2 then
  begin
    WriteLn(Output,'ERROR : Cannot read year');
    fs.Free;
    Exit;
  end;
  writeln(Output,'Reading YEAR');
  if fs.Read(month,1) <> 1 then
  begin
    WriteLn(Output,'ERROR : Cannot read month');
    fs.Free;
    Exit;
  end;
  writeln(Output,'Reading MONTH');
  if fs.Read(day,1) <> 1 then
  begin
    WriteLn(Output,'ERROR : Cannot read day');
    fs.Free;
    Exit;
  end;
  writeln(Output,'Reading DAY');

  { Read time (UTC) }
  if fs.Seek($D4,0) = -1 then
  begin 
    WriteLn(Output,'ERROR : Cannot seek to hour');
    fs.Free;
    Exit;
  end;
  if fs.Read(utc_hour,1) <> 1 then
  begin 
    WriteLn(Output,'ERROR : Cannot read hour');
    fs.Free;
    Exit;
  end;
  writeln(Output,'Reading HOUR');
  if fs.Read(minute,1) <> 1 then
  begin
    WriteLn(Output,'ERROR : Cannot read minute');
    fs.Free;
    Exit;
  end;
  writeln(Output,'Reading MINUTE');
  
  { Dump all information }

  WriteLn(Output, '');
  WriteLn(Output, '!!! SUCCESS !!!');
  WriteLn(Output, '');
  WriteLn(Output,Format('station :     %s',[station]));
  WriteLn(Output,Format('title   :     %s',[title]));
  WriteLn(Output,Format('date    :     %.2d.%.2d.%.4d',[day, month, year]));
  WriteLn(Output,Format('time    :     %.2d:%.2d (UTC)',[utc_hour, minute]));
  fs.Free;
end;

begin
  try
    if ParamCount <> 2 then
    begin
      WriteLn(Output,Format('USAGE : %s <meta.dat> <command> ("read", to read from file, "write", to write to file)',[ParamStr(0)]));
	  Exit;
    end;

	  if ParamStr(2)='read' then
	  begin
	    ReadReceiverDat;
	  end else
    if ParamStr(2)='write' then
    begin
      //WriteReceiverDat ---> (Coming soon !!!)
    end else
    begin
      WriteLn(Output,Format('ERROR : Unknown command "%s"',[Paramstr(2)]));
    end;

    Writeln;
    Writeln;
    Write('Press [ENTER] to continue...');
    Readln;
	
  except
    on e:Exception do
	begin
      WriteLn(Output, e.Message);
	end;
end;

end.
