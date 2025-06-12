var
s0, s1, s2, s3, s4, i, n: qword;
begin
	readln(n);
	i := 0;
	s0 := 0;
	s1 := 0;
	s2 := 0;
	s3 := 0;
	s4 := 0;
	while (i <= n) do begin
		s0 := s0 + 1;
		s1 := s1 + i;
		s2 := s2 + i * i;
		s3 := s3 + i * i * i;
		s4 := s4 + i * i * i * i;
		i := i + 1;
	end;
	writeln(s0);
	writeln(s0);
	writeln(s1);
	writeln(s1);
	writeln(s2);
	writeln(s2);
	writeln(s3);
	writeln(s3);
	writeln(s4);
	writeln(s4);
end.