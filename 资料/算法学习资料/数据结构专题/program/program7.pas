const
	maxn = 16;
var
	s: array[0..maxn] of string;

function check(): boolean;
var
	i, j: longint;
	v: array [0..maxn] of boolean;
begin
	for i := 0 to maxn - 1 do begin
		fillchar(v, sizeof(v), 0);
		for j := 0 to maxn - 1 do
			v[ord(s[i][j + 1]) - ord('A')] := true;
		for j := 0 to maxn - 1 do
			if not v[j] then
				exit(false)
	end;
	for i := 0 to maxn - 1 do begin
		fillchar(v, sizeof(v), 0);
		for j := 0 to maxn - 1 do
			v[ord(s[j][i + 1]) - ord('A')] := true;
		for j := 0 to maxn - 1 do
			if not v[j] then
				exit(false)
	end;
	for i := 0 to maxn - 1 do begin
		fillchar(v, sizeof(v), 0);
		for j := 0 to maxn - 1 do
			v[ord(s[i div 4 * 4 + j div 4][i mod 4 * 4 + j mod 4 + 1]) - ord('A')] := true;
		for j := 0 to maxn - 1 do
			if not v[j] then
				exit(false)
	end;
	exit(true);
end;

function dfs(x, y: longint): boolean;
var
	i: char;
begin
	if (x = 16) and (y = 0) then
		exit(check);
	if s[x][y + 1] = '?' then begin
		for i := 'A' to 'P' do begin
			s[x][y + 1] := i;
			if dfs(x, y) then
				exit(true);
			s[x][y + 1] := '?';
		end;
		exit(false)
	end else
		exit(dfs(x + (y + 1) div 16, (y + 1) mod 16));
end;

procedure solve(points: longint);
var
	i, k: longint;
begin
	for i := 0 to maxn - 1 do
		readln(s[i]);
	if dfs(0, 0) then
		for k := 0 to points - 1 do begin
			for i := 0 to maxn - 1 do
				write(s[i]);
			writeln
		end
	else
		for k := 0 to points - 1 do
			writeln('NO SOLUTION.');
	readln;
end;

procedure main;
begin
	solve(1);
	solve(2);
	solve(3);
	solve(4);
end;

begin
	main;
end.