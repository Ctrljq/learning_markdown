#include <stdio.h>
#include <string.h>
char s[20][20];
int check() {
	int i, j;
	int v[16];
	for (i = 0; i <= 15; i++) {
		memset(v, 0, sizeof(v));
		for (j = 0; j <= 15; j++) {
			v[s[i][j] - 'A'] = 1;
		}
		for (j = 0; j <= 15; j++) {
			if (!v[j]) {
				return 0;
			}
		}
	}
	for (i = 0; i <= 15; i++) {
		memset(v, 0, sizeof(v));
		for (j = 0; j <= 15; j++) {
			v[s[j][i] - 'A'] = 1;
		}
		for (j = 0; j <= 15; j++) {
			if (!v[j]) {
				return 0;
			}
		}
	}
	for (i = 0; i <= 15; i++) {
		memset(v, 0, sizeof(v));
		for (j = 0; j <= 15; j++) {
			v[s[i / 4 * 4 + j / 4][i % 4 * 4 + j % 4] - 'A'] = 1;
		}
		for (j = 0; j <= 15; j++) {
			if (!v[j]) {
				return 0;
			}
		}
	}
	return 1;
}

int dfs(int x, int y) {
	char i;
	if (x == 16 && y == 0) {
		return check();
	}
	if (s[x][y] == '?') {
		for (i = 'A'; i <= 'P'; i++) {
			s[x][y] = i;
			if (dfs(x, y)) {
				return 1;
			}
			s[x][y] = '?';
		}
		return 0;
	} else {
		return dfs(x + (y + 1) / 16, (y + 1) % 16);
	}
}

void solve(int points) {
	int i, k;
	for (i = 0; i <= 15; i++) {
		scanf("%s", s[i]);
	}
	if (dfs(0, 0)) {
		for (k = 0; k <= points - 1; k++) {
			for (i = 0; i <= 15; i++) {
				printf("%s", s[i]);
			}
			printf("\n");
		}
	} else {
		for (k = 0; k <= points - 1; k++) {
			printf("NO SOLUTION.\n");
		}
	}
}
int main() {
	solve(1);
	solve(2);
	solve(3);
	solve(4);
	return 0;
}
