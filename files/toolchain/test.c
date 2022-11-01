#include <stdio.h>

#ifndef TESTSTRING
#define TESTSTRING "didn't provide a test string"
#endif

int main(int argc, char *argv[]) {
    printf("Hello World!\n");
    printf("Provided: %s\n", TESTSTRING);
    printf("Have some emoji: 🏄‍♂️🏄‍♀️\n");
    return 0;
}
