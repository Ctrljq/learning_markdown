var
a, b, c, i: longint;
begin
writeln('Hello, National Olympiad in Informatics!');
readln(a, b);
writeln(a + b);
writeln(chr(a), 'inter ', chr(b), 'amp');
c := 0;
while (a <> 0) do begin
	inc(a, b);
	inc(c, 1);
end;
writeln(a, ' ', c);
c := c mod 10;
i := -1;
while (0 = 0) do begin
	if (abs(i) <= 0) then begin
		writeln(i);
		break;
	end;
	inc(i, 641)
end;
writeln('.');
writeln('.');
writeln('.');
writeln('.');
writeln('.');
end.