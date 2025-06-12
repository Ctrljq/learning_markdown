var
a, b, c, d, e, f, g, n, p, q, r, s, t, u, v, w, x, y, z: qword;
begin
	readln(n);
	p := 1234567891;
	q := 0;
	r := 0;
	s := 0;
	t := 0;
	u := 0;
	v := 0;
	w := 0;
	x := 0;
	y := 0;
	z := 0;
	a := 0;
	while (a < n) do begin
		a := a + 1;
		b := 0;
		while (b < n) do begin
			b := b + 1;
			c := 0;
			while (c < n) do begin
				c := c + 1;
				d := 0;
				while (d < n) do begin
					d := d + 1;
					e := 0;
					while (e < n) do begin
						e := e + 1;
						f := 0;
						while (f < n) do begin
							f := f + 1;
							g := 0;
							while (g < n) do begin
								g := g + 1;
								if (a < b) and (b < c) and (c < d) and (d < e) and (e < f) and (f < g) then begin
									q := q + 1;
									q := q mod p;
								end;

								if (a < b) and (c < g) and (c < d) and (e < f) and (a < d) then begin
									r := r + 1;
									r := r mod p;
								end;

								if (a < d) and (d < f) and (c < f) and (c < e) and (b < d) then begin
									s := s + 1;
									s := s mod p;
								end;

								if (d < e) and (b < d) and (a < f) and (d < e) and (b < g) then begin
									t := t + 1;
									t := t mod p;
								end;

								if (c < f) and (b < f) and (b < c) and (f < g) and (b < f) then begin
									u := u + 1;
									u := u mod p;
								end;

								if (b < d) and (b < c) and (d < f) and (c < e) and (b < e) then begin
									v := v + 1;
									v := v mod p;
								end;

								if (a < c) and (a < b) and (c < e) and (b < f) and (e < g) then begin
									w := w + 1;
									w := w mod p;
								end;

								if (b < d) and (b < f) and (a < g) and (c < g) and (a < e) then begin
									x := x + 1;
									x := x mod p;
								end;

								if (b < f) and (a < c) and (c < d) and (a < c) and (b < e) then begin
									y := y + 1;
									y := y mod p;
								end;

								if (d < e) and (e < f) and (a < d) and (c < g) and (b < d) then begin
									z := z + 1;
									z := z mod p;
								end;

							end;
						end;
					end;
				end;
			end;
		end;
	end;
	writeln(q);
	writeln(r);
	writeln(s);
	writeln(t);
	writeln(u);
	writeln(v);
	writeln(w);
	writeln(x);
	writeln(y);
	writeln(z);
end.