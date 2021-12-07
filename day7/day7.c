#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

int main() {
    int count = 0;
    int capacity = 64;
    int *buf = malloc(capacity * sizeof(int));
    int L = INT_MAX;
    int R = 0;
    for (;;) {
        int a;
        int x = scanf("%d,", &a);
        if (x == 1) {
            if (count >= capacity) {
                capacity *= 2;
                buf = realloc(buf, capacity * sizeof(int));
            }

            buf[count] = a;
            count++;
            if (a < L) L = a;
            if (a > R) R = a;
        } else {
            break;
        }
    }

    int best_cost = INT_MAX;
    for (int pos = L; pos <= R; pos++) {
        int cost = 0;
        for (int i = 0; i < count; i++) {
            int d = buf[i] - pos;
            if (d < 0) d = -d;
            cost += d;
        }
        if (cost < best_cost) {
            best_cost = cost;
        }
    }

    printf("%Ld\n", best_cost);

    best_cost = INT_MAX;
    for (int pos = L; pos <= R; pos++) {
        int cost = 0;
        for (int i = 0; i < count; i++) {
            int d = buf[i] - pos;
            if (d < 0) d = -d;
            cost += d * (d + 1) / 2;
        }
        if (cost < best_cost) {
            best_cost = cost;
        }
    }

    printf("%Ld\n", best_cost);
}
