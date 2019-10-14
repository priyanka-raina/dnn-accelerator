#ifndef FIFO_H
#define FIFO_H

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>

// #define CCS_BLOCK(x) x

template<typename T, int NUM_REGS>
class Fifo{
public:
    Fifo()
    { // required constructor
// #pragma hls_unroll yes
//         for (int i = 0; i < NUM_REGS; i++)
//         {
//             regs[i].clear();
//         }
    }

#pragma hls_design interface ccore
    void CCS_BLOCK(run)(T &input, T &output)
    {
    LABEL(SHIFT)
        for (int i = NUM_REGS - 1; i >= 0; i--)
        {
            if (i == 0)
            {
                regs[i] = input;
            }
            else
            {
                regs[i] = regs[i - 1];
            }

            output = regs[NUM_REGS - 1];
        }
    }

private:
    T regs[NUM_REGS];
};
#endif
