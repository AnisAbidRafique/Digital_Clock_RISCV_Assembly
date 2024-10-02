.globl main

.data
mask : .word -65536  #0xAllOnes0000


.text
main:
  li t0, 0x80001038     # base address of segment Enable
  li t1, 0x8000103C     # base address of segment value
  li s1, 0x80001200     # timer base address
  li s2, 0x021         # bit 0 = En, bit 5 = INTE
  li s3, 0x00001FFF     #reload value LO_Reg
  #li s3, 0x00000001     #reload value LO_Reg
  li s5, 0x00000001     #lsb mask
  li s6, 0              #Seconds Counter
  li a0, 0              #Minutes Counter
  li a5, 0              #Hours Counter
  li s7,9
  li s8,0x60

  li t2,0x00            # 7 Segment Enable
  sw t2, 0(t0)

  sw s3,8(s1)           #set reload value

  la t2,mask
  lw t2,0(t2)

  li t0,0x24        #Hours Reset value

Program:
  sw s2,12(s1)          # set control reg with en and interrupt

continue_count:
  lw   s4,12(s1)          #load the contents of the ctrl reg
  srli s4,s4,6            #Right Shift 6 bits lsb int bit
  and  s9,s4,s5            #masking lsb for interrupt
  beq  s9,x0,continue_count             #checking msb == 0

  slli a2,s6,24      #Extract 8 bits of seconds
  srli a2,a2,24

  beq a2,s8,Reset_Seconds         #Seconds_Reset
  

  slli s10,s6,28
  srli s10,s10,28
  beq s7,s10,Increment         #Checking lsb for 9
  sw   s6, 0(t1)        #second value on seven_segment
  addi s6,s6,1          #second = second + 1

  li   t4,0x80
  sw   t4,12(s1)


  j Program

Increment:
            sw   s6, 0(t1)        #second value on seven_segment

            addi s6,s6,7
            li   t4,0x80
            sw   t4,12(s1)
            j Program

Increment_mints:

            addi a0,a0,7          #mintues = 10
            slli a4,a0,8
            #mv   s6,a4
            or   s6,s6,a4
            beq a0,s8,Reset_Minutes         #Seconds_Reset
            sw   s6, 0(t1)        #second value on seven_segment

            li   t4,0x80
            sw   t4,12(s1)
            j Program

Increment_hours:

            addi a5,a5,7               #hours = 10
            slli a4,a5,16
            mv   s6,a4

            #beq a5,t0,Reset_Hours         #Seconds_Reset

            sw   s6, 0(t1)        #second value on seven_segment

            li   t4,0x80
            sw   t4,12(s1)
            j Program

Reset_Seconds:

            slli a3,a0,28
            srli a3,a3,28
            #addi s6,x0,0           #Seconds_Reset

            and s6,s6,t2           #Seconds_Reset

            beq s7,a3,Increment_mints         #Checking lsb for 9
            addi a0,a0,1          #mintues++

            slli a1,a0,8
            or   s6,a1,s6
            sw   s6, 0(t1)        #mintues value on seven_segment_59


            li   t4,0x80
            sw   t4,12(s1)
            j Program

Reset_Minutes:


            li a0,0x0000          #Reset minutes
            #li s6,0x0000
            and s6,s6,t2

            slli a6,a5,28
            srli a6,a6,28
            beq s7,a6,Increment_hours         #Checking lsb for 9

            addi a5,a5,1                      #Hours++

            beq a5,t0,Reset_Hours         #Seconds_Reset

            slli a7,a5,16
            mv   s6,a7
            
            sw   s6, 0(t1)        #mintues value on seven_segment_59 01:00:00

            

            li   t4,0x80
            sw   t4,12(s1)
            j Program

Reset_Hours:
            mv s6,x0
            li a5, 0              #Hours Counter reset
            sw   s6, 0(t1)        #Reset value on seven_segment 00:00:00
            li   t4,0x80
            sw   t4,12(s1)
            j Program
