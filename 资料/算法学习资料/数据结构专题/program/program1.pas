procedure _();
var 
a, b, c, d, i: qword;
begin
readln(a, b, c);
i := 0;
d := 0;
while (i < b) do begin
	d := d + a;
	d := d mod c;
	i := i + 1;
end;
writeln(d);
end;

begin
	_();
	_();
	_();
	_();
	_();
	
	_();
	_();
	_();
	_();
	_();
end.