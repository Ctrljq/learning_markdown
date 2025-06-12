var
a, b, c, t, k, n: qword;
i :longint;

function rd(): qword;
begin
	t := (t * t * a + b) mod c;
	rd := t;
end;

begin
	for i := 0 to 9 do begin
		readln(n, a, b, c);
		t := 0;
		k := 1;
		while (k <= n) do begin
			k := k + 1;
			rd();
		end;
		writeln(t);
	end;
end.