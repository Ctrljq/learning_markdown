#include <stdio.h>

#define N 5011
int n, m;
char data[N][N];

int seed;
int next_rand(){
	static const int P = 1000000007, Q = 83978833, R = 8523467;
	return seed = ((long long)Q * seed % P * seed + R) % P;
}

void generate_input(){
	int i, j;
	scanf("%d%d", &n, &m);
	for(i = 0; i < n; i++)
		for(j = 0; j < m; j++)
			data[i][j] = ((next_rand() % 8) > 0 ? 1 : 0);
}

int check(int x1, int y1, int x2, int y2){
	int i, j, flag = 1;
	for(i = x1; i <= x2; i++)
		for(j = y1; j <= y2; j++)
			if(data[i][j] == 0)
				flag = 0;
	return flag;
}

long long count3(){
	int i, j, k, l;
	long long ans = 0;
	for(i = 0; i < n; i++)
		for(j = 0; j < m; j++)
			for(k = i; k < n; k++)
				for(l = j; l < m; l++)
					if(check(i, j, k, l))
						ans++;
	return ans;
}

int main(){
	int i;
	scanf("%d", &seed);
	for(i = 0; i < 10; i++){
		generate_input();
		printf("%lld\n", count3());
	}

	return 0;
}
