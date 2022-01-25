-- Lab of Julien Jacquot et Philibert de Sainte Foy --


We modified the following files : CPU_PC, CPU_CND and all the autotests


Let's describe the functions we coded and the tests we made :
Disclaimer : Each time, the functions work (with the tests we made, obvisouly)

-- First Part -- Functions LUI et ADDI --

It took time, but we succesfully coded ADDI.
ADDI is an important function because we need it to test all the other ones.

To test ADDI, we tried with negative and positive numbers and also with the value 7FF
which is the max one. As attented, if we try with 8FF, there is an error

-- 2nd Part -- Functions ADD (AND,OR,ANDI,XOR,XORI,SUB), SLL(SRL,SRA,SRAI,SLLI,SRLI) and AUIPCC --

We have choosen to make difficult tests, only for the functions ADD,SLL and AUIPC
because the others functions are basically derivated from them.

ADD : it's important to test with positive and negative values and with two negative values
Besides, we tried to additionate the biggest numbers we could (7FF) and it worked. The is logic
because the resut isn't saved on the same amount on bits.

SLL : Here, the most relevant things is to try to shift our number by more than 32 bits
That leads to : there is a period-32 looping, what a big news !

AUIPC :
It's working
-- Third Part -- PO BEQ(BNE,BLT,BGE,BLTU,BGEU), SLT(SLTI,SLTU,SLTIU)

This one was a big challenge !

BEQ, BGE, BNE : We tried with negative and positive values, all tests were succesfull
