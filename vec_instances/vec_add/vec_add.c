#include <stdint.h>
// #include <stdio.h>

#define ARRAY_SIZE 16

void vector_add(uint32_t* result, const uint32_t* array1, const uint32_t* array2, int size) {
    for (int i = 0; i < size; i++) {
        *result += array1[i] + array2[i];
    }
}


int main() {
        uint32_t array1[ARRAY_SIZE] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
        uint32_t array2[ARRAY_SIZE] = {2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 2.0, 4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0};
        uint32_t result = 0;
        vector_add(&result,array1,array2,ARRAY_SIZE);
        // printf("%d",result);
        return result;
}