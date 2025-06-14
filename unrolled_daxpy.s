.global main

.align 4
.section .rodata
x: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
a: .word 3
len: .word 64 /* 16*4 = 64 */
pattern: .asciz "%d "
newline: .asciz "\n"

.align 4
.section .data
y: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16

.align 8
.text
main:
        stp fp, lr, [sp, -16]!

        /* set adress of x & y to x18 x19, set value of a to x20, set counter to x21, set len to x22 */
        ldr x18, =x
        ldr x19, =y
        ldr x20, =a
        ldr x20, [x20]
        mov w21, #0 /* counter var, like i, increases by 8 each time */
        ldr x22, =len /* array length */
        ldr w22, [x22]

        loop_daxpy:
        cmp w21, w22
        bge end_daxpy

        /* get address  of x[i] */
        add x23, x18, x21

        /* get address of y[i] */
        add x24, x19, x21

        /* get values of x[i] and y[i] */
        ldr w25, [x23]
        ldr w26, [x24]

        /* preform DAXPY (a*x[i] + y[i], saving result in y[i] */
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

        end_daxpy:
        mov x21, #0 /* set i back to 0 */

        /* print out result (y)*/
        loop_print:
        cmp w21, w22
        bge end

        /* get pattern */
        ldr x0, =pattern

        /* get address then value of y[i] */
        add x1, x19, x21
        ldr w1, [x1]

        /* increment i by 4 */
        add x21, x21, #4

        bl printf
        b loop_print

        end:

        /* print out newline charachter */
        ldr x0, =newline
        bl printf

        /* end of program*/
        ldp fp, lr, [sp], 16

        mov w0, #0
        ret