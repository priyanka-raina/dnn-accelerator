#ifndef FIFO_H
#define FIFO_H

// Include mc_scverify.h for CCS_* macros
#include <mc_scverify.h>

template <typename DTYPE, int NUM_REGS>
class fifo
{
private:
    DTYPE regs[NUM_REGS];

public:
    fifo()
    { // required constructor
#pragma hls_unroll yes
        for (int i = 0; i < NUM_REGS; i++)
        {
            regs[i] = 0;
        }
    }

#pragma hls_design interface ccore
    void CCS_BLOCK(run)(DTYPE &input, DTYPE &output)
    {
    SHIFT:
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
};
#endif
