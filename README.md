# Aarch64 Assembly Code Optimization Project

Hello! This is my final project that I made for an ARM assembly course I took.

This project is about optimizing the **DAXPY** procedure (Double Precision (although I used 32 bit integers for the numbers) of A times X[i] plus Y[i].).

## Code Explanation

### daxpy.s

This first file is just doing normal DAXPY without any optimization. It is a simple loop that performs DAXPY element by element. 
First of all, we check if the “i” variable (w21) has reached the end of the array, by comparing it to the array’s length in bytes (stored in w22). 
The address for x[i] and y[i] is calculated by adding the base addresses by “i” (x21), which is the counter variable that is incremented by 4 each times, 
ensuring it will get the next value in the array, because each number is 32bits (4 bytes). Next, the values from the addresses from the arrays are loaded into w25 and w26. 
Now, we use the MADD instruction to perform DAXPY, and then finally increment x21 by 4 bytes. 

    loop_daxpy:
          cmp w21, w22
          bge end_daxpy
  
          /* get address of x[i] */
          add x23, x18, x21
  
          /* get address of y[i] */
          add x24, x19, x21
  
          /* get values of x[i] and y[i] */
          ldr w25, [x23]
          ldr w26, [x24]
  
          /* preform DAXPY (a*x[i] + y[i], saving result in y[i]) */
          MADD w27, w20, w25, w26
          str w27, [x24]
  
          /* increment i by 4 bytes */
          add x21, x21, #4
  
          b loop_daxpy

### unrolled_daxpy.s
Now, one optimization we can do to this code is by unrolling the loop. Instead of doing the MADD instruction only once per iteration, 
we can do it four times per iteration by “unrolling it” 4 times. 
We can do this by copying the code for x[i], and slightly modifying (adding 4 bytes)  it for x[i+1], x[i+2], and x[i+3]. 
By doing this, the MADD instruction is being completed 4 times per iteration, making the code more efficient. 
However, the input arrays X and Y need to be a size that is divisible by 4 so out of bounds memory is not accessed.

    loop_daxpy:
        cmp w21, w22
        bge end_daxpy

        /* x[i] & y[i] */
        add x23, x18, x21
        add x24, x19, x21

        ldr w25, [x23]
        ldr w26, [x24]

        MADD w27, w20, w25, w26
        str w27, [x24]

        /* x[i+1] & y[i+1] */
        add x23, x23, #4
        add x24, x24, #4

        ldr w25, [x23]
        ldr w26, [x24]

        MADD w27, w20, w25, w26
        str w27, [x24]

        /* x[i+2] & y[i+2] */
        add x23, x23, #4
        add x24, x24, #4

        ldr w25, [x23]
        ldr w26, [x24]

        MADD w27, w20, w25, w26
        str w27, [x24]

        /* x[i+3] & y[i+3] */
        add x23, x23, #4
        add x24, x24, #4

        ldr w25, [x23]
        ldr w26, [x24]

        MADD w27, w20, w25, w26
        str w27, [x24]

        /* increment i by 16 bytes */
        add x21, x21, #16

        b loop_daxpy

### simd_daxpy.s
Now that the loop is unrolled and is working on 4 datapoints per iteration, it can be further optimized by using SIMD instructions (Single Instruction, Multiple Data). 
The 4 elements from the X array are now stored in v1, 4 elements from the Y array are stored in v2, and 4 copies of the A multiplier are stored in v0, and the MLA instruction is used to perform DAXPY. 
The MLA instruction is used instead of MADD because MLA is more SIMD registers only, so I wasn’t able to use them in the previous examples.


    loop_daxpy:
        cmp w21, w22
        bge end_daxpy

        /* get address  of x[i] */
        add x23, x18, x21

        /* get address of y[i] */
        add x24, x19, x21

        /* get 4 elements from x[i], storing in v1 */
        ld1 {v1.4s}, [x23]

        /* get 4 elements from y[i], storing in v2 */
        ld1 {v2.4s}, [x24]

        /* preform DAXPY (a*x[i] + y[i], saving result in y[i]) */
        MLA v2.4s, v1.4s, v0.4s
        st1 {v2.4s}, [x24]

        /* increment i by 16 bytes */
        add x21, x21, #16

        b loop_daxpy
