' Firmware for Miniature Vector Magnetometer
' Version 20220105
' Compiler: BASCOM-AVR 2.0.8.3
' Malte Ahlers, m.ahlers@uol.de
'
$regfile = "m168def.dat"
$crystal = 8000000
$framesize = 64
$swstack = 64
$hwstack = 64
$baud = 38400
$lib "i2c_twi.lbx"
$lib "mcsbyteint.lbx"
'
'
config portb.2 = output
led alias Portb.2
'
Config Serialout = Buffered , Size = 32
'
Config Scl = Portc.5
Config Sda = Portc.4
Config Twi = 400000
'
' QMC5883L i2c adresses
Const W_adr = &B0001_1010
Const R_adr = &B0001_1011
'
' QMC5883L used registers
const magx_lb = &H00
const status1 = &H06
const ctrl1 = &H09
const rst_prd = &H0B
'
'
Dim Bx as integer
Dim Bx_hb As Byte at bx + 1 overlay
Dim Bx_lb As Byte at bx overlay
Dim By As Integer
Dim By_hb As Byte At By + 1 Overlay
Dim By_lb As Byte At By Overlay
Dim Bz As Integer
Dim Bz_hb As Byte At Bz + 1 Overlay
Dim Bz_lb As Byte At Bz Overlay
'
Dim status as byte
'
Dim uartin(16) as byte
Dim uartin_str as string * 16
Dim uartbuf(16) as byte at uartin_str overlay
Dim uart_opcode_str as string * 2
Dim msg_idx as byte
Dim uartin_idx as byte
uartin_idx = 1
Dim msglen as byte
Dim new_msg as bit
'
Dim data_out as bit
'
Dim xout as string * 6
Dim yout as string * 6
Dim zout as string * 6
'
Dim fw_string as string * 11
Dim sn_string as string * 6
fw_string = "MVM20220105"
sn_string = "000001"
'
'
reset led
waitms 500
set led
waitms 500
reset led
waitms 500
set led
waitms 500
reset led
'
data_out = 0
'
I2CINIT
'
I2cstart
   I2cwbyte W_adr
   if err = 1 then
      set led
   else
      reset led
   endif
   I2cwbyte rst_prd
   I2cwbyte &H01
I2cstop
'
I2cstart
   I2cwbyte W_adr
   I2cwbyte ctrl1
   I2cwbyte &B1100_1101 ' 64 oversampling; +/-2 G; 200 Hz; continuous
I2cstop
'
waitms 5
'
On Urxc Rec_isr
'
enable URXC
enable interrupts
'
Do
   if new_msg = 1 then
      'parse
      uart_opcode_str = left(uartin_str , 2)
      select case  uart_opcode_str
         case "ON":
            data_out = 1
         case "OF":
            data_out = 0
         case "ID":
            print fw_string
         case "SN":
            print sn_string
      end select
      new_msg = 0
   endif
   '
   if data_out = 1 then
      I2cstart
         I2cwbyte W_adr
         I2cwbyte status1
      I2cstart
         I2cwbyte R_adr
         I2crbyte status , nack
      I2Cstop
      '
      if err = 0 then
         if status.0 = 1 then
            ' new data ready -> read data
            set led
            '
            I2cstart
               I2cwbyte W_adr
               I2cwbyte magx_lb ' register adress auto increment
            I2cstart
               I2cwbyte R_adr
               I2crbyte bx_lb , ack
               I2crbyte bx_hb , ack
               I2crbyte by_lb , ack
               I2crbyte by_hb , ack
               I2crbyte bz_lb , ack
               I2crbyte bz_hb , nack
            I2Cstop
            '
            xout = str(bx)
            print xout ; " " ;
            yout = str(by)
            print yout ; " " ;
            zout = str(bz)
            print zout
            '
            reset led
            '
         endif
      else
         reset led
         print "err0"
      endif
   endif
   '
loop
'
end
'
Rec_isr:
   uartin(uartin_idx) = inkey()
   if uartin(uartin_idx) = 10 then
      ' CR
      if uartin_idx > 3 then
         if uartin(uartin_idx - 1) = 13 then
            ' LF
            new_msg = 1
            msglen = uartin_idx-2
            for msg_idx = 1 to msglen
               uartbuf(msg_idx) = uartin(msg_idx)
            next
            uartin_idx = 1
         else
            ' error
            uartin_idx = 1
         endif
      else
         ' error
         uartin_idx = 1
      endif
   else
      if uartin_idx < 16 then
         incr uartin_idx
      else
         uartin_idx = 1
      endif
   endif
return