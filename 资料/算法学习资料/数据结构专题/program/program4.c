#include <stdio.h>

#define N 5011
const int inf = 0x3F3F3F3F;
int n, m, type;
char data[N][N];

int seed;
int next_rand(){
	static const int P = 1000000007, Q = 83978833, R = 8523467;
	return seed = ((long long)Q * seed % P * seed + R) % P;
}

void generate_input(){
	int i, j;
	scanf("%d%d%d", &n, &m, &type);
	for(i = 0; i < n; i++)
		for(j = 0; j < m; j++)
			data[i][j] = ((next_rand() % 8) > 0 ? 1 : 0);
}

long long count1(){
	int i, j, k, l;
	long long ans = 0LL;
	for(i = 0; i < n; i++)
		for(j = 0; j < m; j++)
			if(data[i][j])
				for(k = 0; k < n; k++)
					for(l = 0; l < m; l++)
						if(data[k][l] && (k != i || l != j))
							ans++;
	return ans;
}

int abs_int(int x){
	return x < 0 ? -x : x;
}

long long count2(){
	long long ans = 0LL;
	int i, j, k, l, level, dist;
	for(i = 0; i < n; i++)
		for(j = 0; j < m; j++)
			if(data[i][j]){
				level = inf;
				for(k = 0; k < n; k++)
					for(l = 0; l < m; l++)
						if(!data[k][l]){
							dist = abs_int(k - i) + abs_int(l - j);
							if(level > dist)
								level = dist;
						}
				ans += level;
			}
	return ans;
}

int main(){
	int i;
	scanf("%d", &seed);
	for(i = 0; i < 10; i++){
		generate_input();
		printf("%lld\n", type == 1 ? count2() : count1());
	}
	return 0;
}
