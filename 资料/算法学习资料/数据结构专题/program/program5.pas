const
	maxn = 5011;	
var
	n, m: longint;
	data: array [0..maxn] of array [0..maxn] of boolean;
	seed: longint;
	
function next_rand():longint;
const
	P = 1000000007;
	Q = 83978833;
	R = 8523467;
begin
	seed := (int64(Q) * seed mod P * seed + R) mod P;
	exit(seed)
end;

procedure generate_input();
var
	i, j: longint;
begin
	read(n, m);
	for i := 0 to n - 1 do
		for j := 0 to m - 1 do
			data[i][j] := ((next_rand() mod 8) > 0)
end;

function check(x1, y1, x2, y2: longint):boolean;
var
	i, j: longint;
	flag: boolean;
begin
	flag := true;
	for i := x1 to x2 do
		for j := y1 to y2 do
			if not data[i][j] then
				flag := false;
	exit(flag)
end;

function count3():int64;
var
	i, j, k, l: longint;
	ans: int64;
begin
	ans := 0;
	for i := 0 to n - 1 do
		for j := 0 to m - 1 do
			for k := i to n - 1 do
				for l := j to m - 1 do
					if check(i, j, k, l) then
						inc(ans);
	exit(ans)
end;

procedure main();
var
	i: longint;
begin
	read(seed);
	for i := 0 to 9 do begin
		generate_input;
		writeln(count3);
	end
end;

begin
	main;
end.
