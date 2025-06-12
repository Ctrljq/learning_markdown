const 
	maxn = 5011;
	inf = $3F3F3F3F;
var
	n, m, data_type: longint;
	data: array [0..maxn] of array [0..maxn] of boolean;
	seed: longint;

function next_rand():longint;
const
	P = 1000000007;
	Q = 83978833;
	R = 8523467;
begin
	seed := (int64(Q) * seed mod P * seed + R) mod P;
	exit(seed);
end;

procedure generate_input();
var
	i, j: longint;
begin
	read(n, m, data_type);
	for i := 0 to n - 1 do
		for j := 0 to m - 1 do
			data[i][j] := ((next_rand() mod 8) > 0)
end;

function count1():int64;
var
	i, j, k, l: longint;
	ans: int64;
begin
	ans := 0;
	for i := 0 to n - 1 do
		for j := 0 to m - 1 do
			if data[i][j] then
				for k := 0 to n - 1 do
					for l := 0 to m - 1 do
						if data[k][l] and ((k <> i) or (l <> j)) then
							inc(ans);
	exit(ans)
end;

function abs_int(x: longint):longint;
begin
	if x < 0 then
		exit(-x)
	else
		exit(x)
end;

function count2():int64;
var
	i, j, k, l, level, dist: longint;
	ans: int64;
begin
	ans := 0;
	for i := 0 to n - 1 do
		for j := 0 to m - 1 do
			if data[i][j] then begin
				level := inf;
				for k := 0 to n - 1 do
					for l := 0 to m - 1 do
						if not data[k][l] then begin
							dist := abs_int(k - i) + abs_int(l - j);
							if level > dist then
								level := dist;
						end;
				inc(ans, level);
			end;
	exit(ans)
end;

procedure main();
var
	i: longint;
begin
	read(seed);
	for i := 0 to 9 do begin
		generate_input;
		if data_type = 0 then
			writeln(count1())
		else
			writeln(count2());
	end
end;

begin
	main;
end.
