import time
import serial
import math
import binascii
import re
from datetime import datetime
#import pandas as pd

FEXT = "pearl"

COMM_port = ""
SPEED = 50

RPT_echo = ""

FILE_NAME = None
DIRECTORY = "C:/"

OP_CODE_LIST = []
OPER_LIST = []

MACHINE_CODE_LOW = []
MACHINE_CODE_HIGH = []

ADDRESS_MACHINE_CODE_LOW = []
ADDRESS_MACHINE_CODE_HIGH = []

DIRECT_ADDRESS_LIST = [0]
DIRECT_DATA_LIST = [0]

WORD_DATA_LIST = [0]

SUBROUTINE_POINTER = {}

CONSTANTS = {}

MNEMONIC_CODE_REPORT_LIST = []

CONSOLE_OUTPUTS = []

CODE_DICTIONARIES = {'NOP': '00000000',
                     'LDA': '00000001',
                     'ADD': '00000010',
                     'SUB': '00000011',
                     'STA': '00000100',
                     'LDI': '00000101',
                     'JMP': '00000110',
                     'JMC': '00000111',
                     'JMZ': '00001000',
                     'MOVR0A': '00001001',
                     'MOVR0B': '00001010',
                     'MOVR0': '00001011',
                     'MOVA,R0A': '00001100',
                     'MOVA,R0B': '00001101',
                     'OUT': '00001110',
                     'HLT': '00001111',
                     'MOVA,R0': '00010000',
                     'MOVR0,A': '00010001',
                     'MOVR1A': '00010010',
                     'MOVR1B': '00010011',
                     'MOVR1': '00010100',
                     'MOVA,R1A': '00010101',
                     'MOVA,R1B': '00010110',
                     'MOVA,R1': '00010111',
                     'MOVR1,A': '00011000',
                     'MOVR2A': '00011001',
                     'MOVR2B': '00011010',
                     'MOVR2': '00011011',
                     'MOVA,R2A': '00011100',
                     'MOVA,R2B': '00011101',
                     'MOVA,R2': '00011110',
                     'MOVR2,A': '00011111',
                     'ADDR0A': '00100000',
                     'ADDR0B': '00100001',
                     'ADDR0': '00100010',
                     'SUBR0A': '00100011',
                     'SUBR0B': '00100100',
                     'SUBR0': '00100101',
                     'ADDR1A': '00100110',
                     'ADDR1B': '00100111',
                     'ADDR1': '00101000',
                     'SUBR1A': '00101001',
                     'SUBR1B': '00101010',
                     'SUBR1': '00101011',
                     'ADDR2A': '00101100',
                     'ADDR2B': '00101101',
                     'ADDR2': '00101110',
                     'SUBR2A': '00101111',
                     'SUBR2B': '00110000',
                     'SUBR2': '00110001',
                     'SETP0': '00110010',
                     'CLRP0': '00110011',
                     'MOVA,P0': '00110100',
                     'MOVP0,A': '00110101',
                     'MOVP0': '00110110',
                     'JBTF0': '00110111',
                     'JNBTF0': '00111000',
                     'SETT0E': '00111001',
                     'CLRT0': '00111010',
                     'SETTR0': '00111011',
                     'MOVTH0': '00111100',
                     'MOVTL0': '00111101',
                     'MOVCS0': '00111110',
                     'INCR0A': '00111111',
                     'INCR0B': '01000000',
                     'INCR0': '01000001',
                     'INCR1A': '01000010',
                     'INCR1B': '01000011',
                     'INCR1': '01000100',
                     'INCR2A': '01000101',
                     'INCR2B': '01000110',
                     'INCR2': '01000111',
                     'DECR0A': '01001000',
                     'DECR0B': '01001001',
                     'DECR0': '01001010',
                     'DECR1A': '01001011',
                     'DECR1B': '01001100',
                     'DECR1': '01001101',
                     'DECR2A': '01001110',
                     'DECR2B': '01001111',
                     'DECR2': '01010000',
                     'DJNZR0A,': '01010001',
                     'DJNZR0B,': '01010010',
                     'DJNZR0,': '01010011',
                     'DJNZR1A,': '01010100',
                     'DJNZR1B,': '01010101',
                     'DJNZR1,': '01010110',
                     'DJNZR2A,': '01010111',
                     'DJNZR2B,': '01011000',
                     'DJNZR2,': '01011001',
                     'CALL': '01011010',
                     'RET': '01011011',
                     'PUSHR0': '01011100',
                     'POPR0': '01011101',
                     'PUSHR1': '01011110',
                     'POPR1': '01011111',
                     'PUSHR2': '01100000',
                     'POPR2': '01100001',
                     'DDRP0': '01100010',
                     'JBP0': '01100011',
                     'JNBP0': '01100100',
                     'JBP1': '01100101',
                     'JNBP1': '01100110',
                     'MOVR3': '01110011',
                     'MOVA,R3': '01110100',
                     'MOVR3,A': '01110101',
                     'MOVDM': '01110110',
                     'MOVA,DM': '01110111',
                     'MOVDM,A': '01111000',
                     'MOVR4': '01110110',
                     'MOVA,R4': '01110111',
                     'MOVR4,A': '01111000',
                     'MULR0': '01111001',
                     'DIVR0': '01111010',
                     'MULR1': '01111011',
                     'DIVR1': '01111100',
                     'MULR2': '01111101',
                     'DIVR2': '01111110',
                     'PUSHDM': '01111111',
                     'POPDM': '10000000',
                     'PUSHR4': '01111111',
                     'POPR4': '10000000',
                     'PUSHR3': '10000001',
                     'POPR3': '10000010',
                     'ANLR0': '10000011',
                     'ANLR1': '10000100',
                     'ANLR2': '10000101',
                     'ANLR3': '10000110',
                     'ORLR0': '10000111',
                     'ORLR1': '10001000',
                     'ORLR2': '10001001',
                     'ORLR3': '10001010',
                     'CPLA': '10001011',
                     'MOVA@R0': '10001100',
                     'MOVA@R1': '10001101',
                     'MOVA@R2': '10001110',
                     'MOVA@R3': '10001111',
                     'MOV@R0A': '10010000',
                     'MOV@R1A': '10010001',
                     'MOV@R2A': '10010010',
                     'MOV@R3A': '10010011',
                     'INCR3': '10010100',
                     'DECR3': '10010101',
                     'DJNZR3,': '10010110',
                     'ADDR3': '10010111',
                     'SUBR3': '10011000',
                     'MOVP0.,C': '10011001',
                     'MOVC,P0.': '10011010',
                     'RDAP0': '10011011',
                     'MOVA,C': '10011100',
                     'MOVC,A': '10011101',
                     'MOVC': '10011110',
                     'RRC': '10011111',
                     'RLC': '10100000',
                     'PUSHA': '10100001',
                     'POPA': '10100010',
                     'ADDI': '10100011',
                     'SUBI': '10100100',
                     'DDRP1': '10110101',
                     'MOVP1': '10110110',
                     'MOVP1,A': '10110111',
                     'MOVA,P1': '10111000',
                     'SETP1': '10111001',
                     'CLRP1': '10111010',
                     'MOVP1.,C': '10111011',
                     'MOVC,P1.': '10111100',
                     'RDAP1': '10111101',
                     'CMPI': '10111110',
                     'CMP': '10111111',
                     'MOVTH0,A': '11000000',
                     'MOVTL0,A': '11000001',
                     'MOVCS0,A': '11000010',
                     'ADDCR0': '11000011',
                     'ADDCR1': '11000100',
                     'ADDCR2': '11000101',
                     'ADDCR3': '11000110',
                     'ADDIC': '11000111',
                     'ADDC': '11001000',
                     'MOVA,TC0L': '11001001',
                     'MOVA,TC0H': '11001010',
                     'SETTCR0E': '11001011',
                     'JT0V': '11001100',
                     'JNT0V': '11001101',
                     'SETTC0L': '11001110',
                     'MOVPC,A': '11001111',
                     'MOVA,PC': '11010000',
                     'MOVLR': '11010001',
                     'MOVLR,A': '11010010',
                     'MOVA,LR': '11010011',
                     'MOVPC,LR': '11010100',
                     'MOVLR,PC': '11010101',
                     'SUBBR0'  : '11010110',
                     'SUBBR1'  : '11010111',
                     'SUBBR2'  : '11011000',
                     'SUBBR3'  : '11011001',
                     'SUBIB'   : '11011010',
                     'SUBB'    : '11011011',
                     }


# print CODE_DICTIONARIES ['LDA']

### Send Machine CODE to the Computer

def DeliverMachineCode():
    # for LINE_INDEX in range (CODE_LENGTH + len (DIRECT_ADDRESS_LIST) - 1 + len (WORD_DATA_LIST) - 1):
    catch_error = 0
    try:
        tx = serial.Serial(COMM_port, SPEED)
        print("Uploading ...")
        CONSOLE_OUTPUTS.append ("Uploading ...")
        with open('{}{}.HEX'.format(DIRECTORY, FILE_NAME)) as f:
            HEX_CODE = f.readlines()
            for NEW_LINE in HEX_CODE:
                hex_line = NEW_LINE.strip()
                if hex_line[0] == ':':
                    hex_array = hex_line[1:].split()
                    hex_to_int_array = []
                    for x in hex_array:
                        hex_to_int_array.append(int(x, 16))
                    # print hex_to_int_array
                    try:
                        format_hex_bytes = bytearray(hex_to_int_array)
                        tx.write(format_hex_bytes)
                    except ValueError:
                        print ("Operand value out of range 0 to 255")
                        CONSOLE_OUTPUTS.append ("Operand value out of range 0 to 255")
                        catch_error = 1

        time.sleep(0.3)
        tx.close()
        if catch_error == 0:
            print("Done Uploading.")
            CONSOLE_OUTPUTS.append ("Done Uploading.")
    except serial.SerialException:
        print("Comm Error!")
        CONSOLE_OUTPUTS.append ("Comm Error!")

    del OP_CODE_LIST[:]
    del OPER_LIST[:]

    del MACHINE_CODE_LOW[:]
    del MACHINE_CODE_HIGH[:]

    del ADDRESS_MACHINE_CODE_LOW[:]
    del ADDRESS_MACHINE_CODE_HIGH[:]

    del DIRECT_ADDRESS_LIST[:]
    DIRECT_ADDRESS_LIST.append(0)
    del DIRECT_DATA_LIST[:]
    DIRECT_DATA_LIST.append(0)

    del WORD_DATA_LIST[:]
    WORD_DATA_LIST.append(0)

    del MNEMONIC_CODE_REPORT_LIST[:]

    SUBROUTINE_POINTER.clear()
    CONSTANTS.clear()

    #Enter_file_name()


def FormHexFile(CODE_LENGTH):
    number_of_code_segments = int(math.ceil(float(CODE_LENGTH * 2) / 16.0))
    # print number_of_code_segments
    segment_byte_count = []
    for x in range(number_of_code_segments):
        if number_of_code_segments - x != 1:
            segment_byte_count.append(16)
        else:
            segment_byte_count.append((CODE_LENGTH * 2) - (16 * x))

    total_code_length = CODE_LENGTH + len(DIRECT_ADDRESS_LIST) - 1 + len(WORD_DATA_LIST) - 1
    # print "total code length {}" .format (total_code_length)
    # print "number of segments {}".format(number_of_code_segments)
    # print "segment byte count {}".format(segment_byte_count)

    hex_file = open('{}{}.HEX'.format(DIRECTORY ,FILE_NAME), 'w')
    report_file = open('{}{}.rpt'.format(DIRECTORY, FILE_NAME), 'a')
    report_file.write('\n\nHEX Code\n\n')
    # print FILE_NAME
    for segment_index in range(number_of_code_segments):
        hex_file.write(': {0:02x} {1:02x} 00'.format(segment_byte_count[segment_index], (8 * segment_index)))
        report_file.write(': {0:02x} {1:02x} 00'.format(segment_byte_count[segment_index], (8 * segment_index)))
        for byte_index in range(int(segment_byte_count[segment_index] / 2)):
            hex_file.write(' {0:02x} {1:02x}'.format(int(MACHINE_CODE_HIGH[(8 * segment_index) + byte_index], 2),
                                                     int(MACHINE_CODE_LOW[(8 * segment_index) + byte_index], 2)))
            report_file.write(' {0:02x} {1:02x}'.format(int(MACHINE_CODE_HIGH[(8 * segment_index) + byte_index], 2),
                                                        int(MACHINE_CODE_LOW[(8 * segment_index) + byte_index], 2)))
        hex_file.write('\n')
        report_file.write('\n')

    if DIRECT_ADDRESS_LIST[0] == 1 and DIRECT_DATA_LIST[0] == 1:
        for dir_add_data_index in range(len(DIRECT_ADDRESS_LIST) - 1):
            hex_file.write(': 02 {0:02x} 00 00 {1:02x}\n'.format(int(DIRECT_ADDRESS_LIST[dir_add_data_index + 1], 2),
                                                                 int(DIRECT_DATA_LIST[dir_add_data_index + 1], 2)))
            report_file.write(': 02 {0:02x} 00 00 {1:02x}\n'.format(int(DIRECT_ADDRESS_LIST[dir_add_data_index + 1], 2),
                                                                    int(DIRECT_DATA_LIST[dir_add_data_index + 1], 2)))

    if WORD_DATA_LIST[0] == 1:
        word_data_segment = int(math.ceil(float((len(WORD_DATA_LIST) - 1) * 2) / 16.0))
        # print word_data_segment
        word_segment_byte_count = []
        for x in range(word_data_segment):
            if word_data_segment - x != 1:
                word_segment_byte_count.append(16)
            else:
                word_segment_byte_count.append(((len(WORD_DATA_LIST) - 1) * 2) - (16 * x))
        # print word_segment_byte_count

        for word_segment_index in range(word_data_segment):
            hex_file.write(': {0:02x} {1:02x} 00'.format(word_segment_byte_count[word_segment_index],
                                                         (256 - (len(WORD_DATA_LIST) - 1)) + (8 * word_segment_index)))
            report_file.write(': {0:02x} {1:02x} 00'.format(word_segment_byte_count[word_segment_index],
                                                            (256 - (len(WORD_DATA_LIST) - 1)) + (8 * word_segment_index)))
            # print "word segment index {}" .format (word_segment_index)
            for byte_index in range(int(word_segment_byte_count[word_segment_index] / 2)):
                hex_file.write(' {0:02x} {1:02x}'.format(
                    int(WORD_DATA_LIST[len(WORD_DATA_LIST) - 1 - (8 * word_segment_index) - byte_index][:8], 2),
                    int(WORD_DATA_LIST[len(WORD_DATA_LIST) - 1 - (8 * word_segment_index) - byte_index][8:], 2)))
                report_file.write(' {0:02x} {1:02x}'.format(
                    int(WORD_DATA_LIST[len(WORD_DATA_LIST) - 1 - (8 * word_segment_index) - byte_index][:8], 2),
                    int(WORD_DATA_LIST[len(WORD_DATA_LIST) - 1 - (8 * word_segment_index) - byte_index][8:], 2)))
            hex_file.write('\n')
            report_file.write('\n')

    hex_file.write(': 00 00 01')
    report_file.write(': 00 00 01')
    report_file.write('\n--------------------------------------------------------------------------------\n')
    report_file.write('--------------------------------------------------------------------------------')

    hex_file.close()
    report_file.close()

    DeliverMachineCode()


### Report File

def FormreportFile(CODE_LENGTH, DIR_ADD_LIST, DIR_DATA_LIST):
    # print RPT_echo
    if DIR_ADD_LIST[0] == 1 and DIR_DATA_LIST[0] == 1:
        for dir_add_data_index in range(len(DIR_ADD_LIST) - 1):
            ADDRESS_MACHINE_CODE_LOW.append(DIR_ADD_LIST[dir_add_data_index + 1][8:])
            ADDRESS_MACHINE_CODE_HIGH.append(DIR_ADD_LIST[dir_add_data_index + 1][:8])

            MACHINE_CODE_HIGH.append(DIR_DATA_LIST[dir_add_data_index + 1][:8])
            MACHINE_CODE_LOW.append(DIR_DATA_LIST[dir_add_data_index + 1][8:])

    if WORD_DATA_LIST[0] == 1:
        data_length = len(WORD_DATA_LIST) - 1
        for x in range(data_length):
            ADDRESS_MACHINE_CODE_LOW.append("{0:08b}".format(255 - x))
            ADDRESS_MACHINE_CODE_HIGH.append("00000000")

            MACHINE_CODE_LOW.append(WORD_DATA_LIST[x + 1][8:])
            MACHINE_CODE_HIGH.append(WORD_DATA_LIST[x + 1][:8])

    report_file = open('{}{}.rpt'.format(DIRECTORY, FILE_NAME), 'w')
    memory_used = CODE_LENGTH + len(DIRECT_ADDRESS_LIST) - 1 + len(WORD_DATA_LIST) - 1
    # print memory_used
    # print (float ((memory_used / 256.0) * 100.0))
    report_file.write('********************************************************************************\n')
    report_file.write('*** This is an auto generated report file showing the opcodes and memory map ***\n')
    file_name_rpt = '*** File name : {}'.format(FILE_NAME)
    report_file.write('{}'.format(file_name_rpt.ljust(77)) + '***\n')
    file_name_rpt = '*** Date of creation : {}'.format(datetime.now().strftime("%d-%m-%Y %H:%M:%S"))
    report_file.write('{}'.format(file_name_rpt.ljust(77)) + '***\n')
    report_file.write('\n\nMemory available : 256 bytes,  Memory used : {} bytes, {:.2f}%\n'.format(memory_used, memory_used / 256.0 * 100.0))
    report_file.write('--------------------------------------------------------------------------------\n')
    if DIRECT_ADDRESS_LIST[0] == 1 and (RPT_echo.find('r') != -1 or RPT_echo == ""):
        report_file.write('\nRaw address inputs\n\n')
        for x in range(len(DIRECT_ADDRESS_LIST) - 1):
            report_file.write('{}  {}        {}  {}\n'.format(DIRECT_ADDRESS_LIST[x + 1],
                                                              DIRECT_DATA_LIST[x + 1],
                                                              int(DIRECT_ADDRESS_LIST[x + 1], 2),
                                                              int(DIRECT_DATA_LIST[x + 1], 2)))
        report_file.write('--------------------------------------------------------------------------------\n\n')

    if WORD_DATA_LIST[0] == 1 and (RPT_echo.find('w') != -1 or RPT_echo == ""):
        report_file.write('\nWord String\n\n')
        # print WORD_DATA_LIST [1]
        for x in range(len(WORD_DATA_LIST) - 1):
            # print "{}".format(binascii.unhexlify('%x' % int(WORD_DATA_LIST[x + 1], 2)))
            report_file.write('{0:016b}  {1:}        {2:}  {3:}\n'.format(255 - x, WORD_DATA_LIST[x + 1], 255 - x, binascii.unhexlify('%x' % int(WORD_DATA_LIST[x + 1], 2)).decode('utf-8')))
        report_file.write('--------------------------------------------------------------------------------\n\n')

    if len(CONSTANTS) != 0 and (RPT_echo.find('c') != -1 or RPT_echo == ""):
        report_file.write('\nConstants\n\n')
        for key, value in CONSTANTS.items():
            report_file.write('{} = {}\n'.format(key, value))
        report_file.write('--------------------------------------------------------------------------------\n\n')

    report_file.write('Address     Opcode\n\n')
    line_number_counter = -1
    for x in range(len(MNEMONIC_CODE_REPORT_LIST)):
        line_number_counter += 1
        if MNEMONIC_CODE_REPORT_LIST[x][:len(MNEMONIC_CODE_REPORT_LIST[x]) - 1] in SUBROUTINE_POINTER:
            report_file.write('    {}\n'.format(MNEMONIC_CODE_REPORT_LIST[x]))
            line_number_counter -= 1
            continue
        else:
            report_file.write('{}   \t\t{}\n'.format(line_number_counter, MNEMONIC_CODE_REPORT_LIST[x]))
            if MNEMONIC_CODE_REPORT_LIST [x].lower ().find ('jb ') != -1 or MNEMONIC_CODE_REPORT_LIST [x].lower ().find ('jnb ') != -1:
                line_number_counter += 1

    report_file.write('--------------------------------------------------------------------------------\n\n')

    if RPT_echo.find('m') != -1 or RPT_echo == "":
        report_file.write('Memory Map\n\n')
        for x in range(len(MACHINE_CODE_HIGH)):
            try:
                report_file.write("{0:}\t{1:}{2:}   {3:}{4:}        {5:}\t{6:02x}  {7:02x}\n".format(x + 1,
                                                                                                     ADDRESS_MACHINE_CODE_HIGH[x],
                                                                                                     ADDRESS_MACHINE_CODE_LOW[x],
                                                                                                     MACHINE_CODE_HIGH[x],
                                                                                                     MACHINE_CODE_LOW[x],
                                                                                                     int(ADDRESS_MACHINE_CODE_LOW[x], 2),
                                                                                                     int(MACHINE_CODE_HIGH[x], 2),
                                                                                                     int(MACHINE_CODE_LOW[x], 2)))
            except (ValueError):
                try:
                    print("Instruction {0:02x}".format(int(MACHINE_CODE_HIGH[x], 2)))
                    CONSOLE_OUTPUTS.append ("Instruction {0:02x}".format(int(MACHINE_CODE_HIGH[x], 2)))
                except ValueError:
                    print(f"*** Undefined Instruction Error in address {x} ***")
                    CONSOLE_OUTPUTS.append (f"*** Undefined Instruction Error in address {x} ***")
                    report_file.close()
                try:
                    print("operand value {0:02x}".format(int(MACHINE_CODE_LOW[x], 2)))
                    CONSOLE_OUTPUTS.append ("operand value {0:02x}".format(int(MACHINE_CODE_LOW[x], 2)))
                except ValueError:
                    print(f"*** Type / Label Error in address {x} ***")
                    CONSOLE_OUTPUTS.append (f"*** Type / Label Error in address {x} ***")
                    print("Operand type undefined : possible types are 'x' for Hex 'b' for Binary '$' for Integer")
                    CONSOLE_OUTPUTS.append ("Operand type undefined : possible types are 'x' for Hex 'b' for Binary '$' for Integer")
                report_file.close()

                del OP_CODE_LIST[:]
                del OPER_LIST[:]

                del MACHINE_CODE_LOW[:]
                del MACHINE_CODE_HIGH[:]

                del ADDRESS_MACHINE_CODE_LOW[:]
                del ADDRESS_MACHINE_CODE_HIGH[:]

                del DIRECT_ADDRESS_LIST[:]
                DIRECT_ADDRESS_LIST.append(0)
                del DIRECT_DATA_LIST[:]
                DIRECT_DATA_LIST.append(0)

                del WORD_DATA_LIST[:]
                WORD_DATA_LIST.append(0)

                del MNEMONIC_CODE_REPORT_LIST[:]

                SUBROUTINE_POINTER.clear()
                CONSTANTS.clear()
                return -1
                #Enter_file_name()

    report_file.write('--------------------------------------------------------------------------------')

    report_file.close()

### Assembly to Machine Code

def FormMachineCode(OP_LIST, OPERAND_LIST, CODE_LENGTH, DIR_ADD_LIST, DIR_DATA_LIST):
    # print "This is in FormMachineCode function"
    # print OP_LIST
    for new_OP in range(CODE_LENGTH):
        # print (OP_LIST [new_OP])
        # print CODE_DICTIONARIES.get (str (OP_LIST [new_OP]) , 0)
        TEMP_MACHINE_CODE = "undef000"
        byte_address = "{0:016b}".format(new_OP)
        # print (byte_address)
        ADDRESS_MACHINE_CODE_LOW.append(byte_address[8:])
        ADDRESS_MACHINE_CODE_HIGH.append(byte_address[:8])
        if CODE_DICTIONARIES.get(OP_LIST[new_OP].upper(), 0) != 0:
            # print "Found {}" .format (OP_LIST [new_OP])
            TEMP_MACHINE_CODE = CODE_DICTIONARIES.get(OP_LIST[new_OP].upper())
            # MACHINE_CODE_LOW.append (CODE_DICTIONARIES.get (OP_LIST [new_OP]))
        # else:
        # print "{} Not Found" .format (OP_LIST [new_OP])

        if TEMP_MACHINE_CODE == "undef000":
            try:
                if (MACHINE_CODE_HIGH [-1] != "01100011" and MACHINE_CODE_HIGH [-1] != "01100100" and MACHINE_CODE_HIGH [-1] != "01100101" and MACHINE_CODE_HIGH [-1] != "01100110"):
                    print(f"*** Undefined Instruction Error ***")
                    CONSOLE_OUTPUTS.append ("*** Undefined Instruction Error ***")
                    print(f"{OP_LIST[new_OP]} : Instruction Not found : see instruction set guidelines")
                    CONSOLE_OUTPUTS.append(f"{OP_LIST[new_OP]} : Instruction Not found : see instruction set guidelines")
                    # Enter_file_name ()
                else:
                    TEMP_MACHINE_CODE = "00000000"
            except:
                print(f"*** Undefined Instruction Error ***")
                CONSOLE_OUTPUTS.append("*** Undefined Instruction Error ***")
                print(f"{OP_LIST[new_OP]} : Instruction Not found : see instruction set guidelines")
                CONSOLE_OUTPUTS.append(f"{OP_LIST[new_OP]} : Instruction Not found : see instruction set guidelines")

        if OPERAND_LIST[new_OP] != "NO OPER":
            if OPER_LIST[new_OP] in CONSTANTS:
                temp = (CONSTANTS[OPER_LIST[new_OP]])
                if temp[0].lower() == 'x':
                    temp = "{0:08b}".format(int(temp[1:], 16))
                elif temp[0].lower() == '$':
                    if temp[1].lower () != '-':
                        temp = "{0:08b}".format(int(temp[1:]))
                    else:
                        temp = "{0:08b}".format(256 - int(temp[2:]))
                elif temp[0].lower() == 'b':
                    temp = "{0:08b}".format(int(temp[1:], 2))
                elif temp[0].lower () == '"':
                    character = temp[temp.index('"') + 1: temp.index('"') + 2]  # store the character
                    temp = "{0:08b}".format (ord (character))
                # print temp
                TEMP_MACHINE_CODE = str(TEMP_MACHINE_CODE) + str(temp)
            elif OPER_LIST[new_OP] in SUBROUTINE_POINTER:
                TEMP_MACHINE_CODE = str(TEMP_MACHINE_CODE) + "{0:08b}".format(
                    int(SUBROUTINE_POINTER[OPER_LIST[new_OP]]))
            elif OPER_LIST[new_OP][0].lower() == 'x':
                TEMP_MACHINE_CODE = str(TEMP_MACHINE_CODE) + "{0:08b}".format(int(OPERAND_LIST[new_OP][1:], 16))
                # MACHINE_CODE_HIGH.append ("{0:08b}" .format (int (OPERAND_LIST [new_OP] [1:], 16)))
            elif OPER_LIST[new_OP][0].lower() == '$':
                if OPER_LIST[new_OP][1].lower() != '-':
                    TEMP_MACHINE_CODE = str(TEMP_MACHINE_CODE) + "{0:08b}".format(int(OPERAND_LIST[new_OP][1:]))
                    # MACHINE_CODE_HIGH.append ("{0:08b}" .format (int (OPERAND_LIST [new_OP] [1:])))
                else:
                    TEMP_MACHINE_CODE = str(TEMP_MACHINE_CODE) + "{0:08b}".format(256 - int(OPERAND_LIST[new_OP][2:]))
            elif OPER_LIST[new_OP][0].lower() == 'b':
                TEMP_MACHINE_CODE = str(TEMP_MACHINE_CODE) + "{0:08b}".format(int(OPERAND_LIST[new_OP][1:], 2))
                # MACHINE_CODE_HIGH.append ("{0:08b}" .format (int (OPERAND_LIST [new_OP] [1:], 2)))
        else:
            TEMP_MACHINE_CODE = str(TEMP_MACHINE_CODE) + "00000000"
            # MACHINE_CODE_HIGH.append ("00000000")

        # print "HIGH ADDRESS {} LOW_ADDRESS {}" .format (ADDRESS_MACHINE_CODE_HIGH [new_OP], ADDRESS_MACHINE_CODE_LOW [new_OP])

        MACHINE_CODE_LOW.append(TEMP_MACHINE_CODE[8:])
        MACHINE_CODE_HIGH.append(TEMP_MACHINE_CODE[:8])
    # print DIR_ADD_LIST
    # print DIR_DATA_LIST

    # print "Memory Map"

    # for x in range (len (MACHINE_CODE_HIGH)):
    #    print "{}{}   {}{}" .format (ADDRESS_MACHINE_CODE_HIGH [x], ADDRESS_MACHINE_CODE_LOW [x], MACHINE_CODE_HIGH [x], MACHINE_CODE_LOW [x])

    exit_status = FormreportFile(CODE_LENGTH, DIR_ADD_LIST, DIR_DATA_LIST)
    if exit_status == -1:
        return
    else:
        FormHexFile(CODE_LENGTH)

    # DeliverMachineCode (CODE_LENGTH)


### Open Program code file

def ReadFile(FILE_NAME):
    try:
        with open(FILE_NAME) as f:
            READ_CODE = f.readlines()
            CODE_LENGTH = 0
            for NEW_LINE in READ_CODE:
                # CURRENT_LINE = READ_CODE [LINE_INDEX].strip ()
                MNEMONIC_CODE = NEW_LINE.strip()
                # print MNEMONIC_CODE.replace (" ", "")
                if MNEMONIC_CODE != '' and MNEMONIC_CODE[0] != ';':
                    # print "first character is {}" .format (MNEMONIC_CODE [0])
                    # print MNEMONIC_CODE
                    if (MNEMONIC_CODE[0] != '['):
                        CODE_LENGTH += 1

                        try:
                            if MNEMONIC_CODE.find(';') != -1 and MNEMONIC_CODE.find('.word') == -1:
                                MNEMONIC_CODE = MNEMONIC_CODE[:MNEMONIC_CODE.index(';')].strip()
                                # print "{}" .format (MNEMONIC_CODE)
                                # print MNEMONIC_CODE.index (' ')
                            if MNEMONIC_CODE.find('=') >= 0 and MNEMONIC_CODE.find('.word') == -1:
                                CONSTANTS[MNEMONIC_CODE[:MNEMONIC_CODE.index('=')].strip()] = MNEMONIC_CODE [MNEMONIC_CODE.index('=') + 1:].strip ()
                                # print "CHECK"
                                # print CONSTANTS
                                CODE_LENGTH -= 1
                                continue

                            #### REPORT FILE LIST
                            if MNEMONIC_CODE.find('.word') == -1:
                                MNEMONIC_CODE_REPORT_LIST.append(MNEMONIC_CODE)
                            ###

                            if MNEMONIC_CODE.find(':') != -1 and MNEMONIC_CODE.find('.word') == -1:
                                SUBROUTINE_POINTER[
                                    MNEMONIC_CODE[:MNEMONIC_CODE.index(':')].replace(" ", "")] = CODE_LENGTH - 1
                                if MNEMONIC_CODE[MNEMONIC_CODE.index(':') + 1:].strip() is not "":
                                    MNEMONIC_CODE = MNEMONIC_CODE[MNEMONIC_CODE.index(':') + 1:].strip()
                                    # print SUBROUTINE_POINTER
                                else:
                                    CODE_LENGTH -= 1
                                    # print "written in next line"
                                    continue
                                    # print "this is skipped"

                            if MNEMONIC_CODE.find('.word') >= 0:
                                DATA = MNEMONIC_CODE[MNEMONIC_CODE.index('"') + 1: MNEMONIC_CODE.rindex('"')]
                                if MNEMONIC_CODE.find('@') >= 0:
                                    if MNEMONIC_CODE[
                                       MNEMONIC_CODE.index('@') + 1: MNEMONIC_CODE.index(',')].strip() != '':
                                        CONSTANTS[MNEMONIC_CODE[MNEMONIC_CODE.index('@') + 1: MNEMONIC_CODE.index(
                                            ',')].strip()] = "b{0:08b}".format(255 - (len(WORD_DATA_LIST) - 1))

                                    if MNEMONIC_CODE[
                                       MNEMONIC_CODE.index(',') + 1: MNEMONIC_CODE.index('"')].strip() != '':
                                        CONSTANTS[MNEMONIC_CODE[MNEMONIC_CODE.index(',') + 1: MNEMONIC_CODE.index(
                                            '"')].strip()] = "b{0:08b}".format(len(DATA))

                                WORD_DATA_LIST[0] = 1
                                for x in DATA:
                                    char = "{0:016b}".format(ord(x))
                                    WORD_DATA_LIST.append(char)
                                CODE_LENGTH -= 1
                                continue

                            if MNEMONIC_CODE.find('(') != -1:
                                operand_list_plus = []
                                operand_list_minus = []
                                operand_list_and = []
                                operand_list_or = []

                                operation_type = ""
                                result = 0

                                constant_operation_argument = MNEMONIC_CODE[MNEMONIC_CODE.index('(') + 1: MNEMONIC_CODE.index(')')].replace(" ", "")

                                operators_list = re.split("[\&\|\+\-\~]", constant_operation_argument)
                                for index in range(len(operators_list)):
                                    for x in CONSTANTS:
                                        # if MNEMONIC_CODE.find(x) != -1:
                                        if operators_list[index] == x:
                                            #constant_operation_argument = constant_operation_argument.replace(x, CONSTANTS[x])
                                            constant_operation_argument = re.sub (r'\b{}\b'.format(x), CONSTANTS [x], constant_operation_argument)

                                #print (constant_operation_argument)
                                if ((constant_operation_argument.find ('-') != -1 or constant_operation_argument.find ('+') != -1)
                                    and (constant_operation_argument [0] != '+' and constant_operation_argument [0] != '-')):
                                    constant_operation_argument = '+' + constant_operation_argument
                                    if (constant_operation_argument.find ('&') != -1 or constant_operation_argument.find ('|') != -1
                                        or constant_operation_argument.find ('~') != -1):
                                        return -1, f"*** mixed operation of constant types Error in address {CODE_LENGTH - 1} ***"

                                if constant_operation_argument.find ('&') != -1:
                                    constant_operation_argument = '&' + constant_operation_argument
                                    if (constant_operation_argument.find ('+') != -1 or constant_operation_argument.find ('-') != -1 or constant_operation_argument.find ('|') != -1
                                        or constant_operation_argument.find ('~') != -1):
                                        return -1, f"*** mixed operation of constant types Error in address {CODE_LENGTH - 1} ***"

                                if constant_operation_argument.find ('|') != -1:
                                    constant_operation_argument = '|' + constant_operation_argument
                                    if (constant_operation_argument.find('+') != -1 or constant_operation_argument.find('-') != -1 or constant_operation_argument.find('&') != -1
                                        or constant_operation_argument.find('~') != -1):
                                        return -1, f"*** mixed operation of constant types Error in address {CODE_LENGTH - 1} ***"

                                if constant_operation_argument [0] != '~':
                                    for x in range(len(constant_operation_argument)):
                                        if constant_operation_argument[x] == '+':
                                            operation_type = "arithmetic"
                                            string_till_now = constant_operation_argument[x + 1:]
                                            next_operator_minus = string_till_now.find('-')
                                            next_operator_plus = string_till_now.find('+')

                                            if next_operator_minus == -1:
                                                next_operator_minus = 100

                                            if next_operator_plus == -1:
                                                next_operator_plus = 100

                                            if next_operator_minus < next_operator_plus:
                                                operand = string_till_now[:next_operator_minus]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                                operand_list_plus.append(int('+' + operand))
                                            elif next_operator_plus < next_operator_minus:
                                                operand = string_till_now[:next_operator_plus]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                                operand_list_plus.append(int('+' + operand))
                                            else:
                                                operand = string_till_now[:]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                                operand_list_plus.append(int('+' + operand))

                                            operand_list_minus.append(0)

                                        elif constant_operation_argument[x] == '-':
                                            operation_type = "arithmetic"
                                            string_till_now = constant_operation_argument[x + 1:]
                                            next_operator_minus = string_till_now.find('-')
                                            next_operator_plus = string_till_now.find('+')

                                            if next_operator_minus == -1:
                                                next_operator_minus = 100

                                            if next_operator_plus == -1:
                                                next_operator_plus = 100

                                            if next_operator_minus < next_operator_plus:
                                                operand = string_till_now[:next_operator_minus]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                                operand_list_minus.append(int('-' + operand))
                                            elif next_operator_plus < next_operator_minus:
                                                operand = string_till_now[:next_operator_plus]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                                operand_list_minus.append(int('-' + operand))
                                            else:
                                                operand = string_till_now[:]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                                operand_list_minus.append(int('-' + operand))

                                            operand_list_plus.append(0)

                                        elif constant_operation_argument[x] == '&':
                                            operation_type = "logical_and"
                                            string_till_now = constant_operation_argument[x + 1:]
                                            try:
                                                operand = string_till_now[: string_till_now.index('&')]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))
                                            except:
                                                operand = string_till_now[:]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                            operand_list_and.append(int(operand))

                                        elif constant_operation_argument[x] == '|':
                                            operation_type = "logical_or"
                                            string_till_now = constant_operation_argument[x + 1:]
                                            try:
                                                operand = string_till_now[: string_till_now.index('|')]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))
                                            except:
                                                operand = string_till_now[:]
                                                if operand[0].lower() == 'x':
                                                    operand = "{}".format(int(operand[1:], 16))
                                                elif operand[0].lower() == '$':
                                                    operand = "{}".format(int(operand[1:]))
                                                elif operand[0].lower() == 'b':
                                                    operand = "{}".format(int(operand[1:], 2))

                                            operand_list_or.append(int(operand))

                                    if operation_type == 'arithmetic':
                                        for x in range (len (operand_list_plus)):
                                            result = result + operand_list_plus [x] + operand_list_minus [x]
                                        if result < 0:
                                            result = 256 - abs(result)

                                        print (result)

                                    elif operation_type == 'logical_and':
                                        result = operand_list_and[0]
                                        for x in range(len(operand_list_and) - 1):
                                            result = result & operand_list_and[x + 1]
                                    elif operation_type == 'logical_or':
                                        result = operand_list_or [0]
                                        for x in range (len (operand_list_or) - 1):
                                            result = result | operand_list_or [x + 1]

                                    MNEMONIC_CODE = MNEMONIC_CODE.replace(MNEMONIC_CODE[MNEMONIC_CODE.index('('):], "b{0:08b}".format(result))
                                    # print MNEMONIC_CODE
                                elif constant_operation_argument [0] == '~':
                                    operator = constant_operation_argument[
                                               (constant_operation_argument.index('~')) + 1:]
                                    # print operator2

                                    if operator in CONSTANTS:
                                        operator = CONSTANTS[operator]

                                    if operator[0].lower() == 'x':
                                        operator = "{}".format(int(operator[1:], 16))
                                    elif operator[0].lower() == '$':
                                        operator = "{}".format(int(operator[1:]))
                                    elif operator[0].lower() == 'b':
                                        operator = "{}".format(int(operator[1:], 2))

                                    # print operator
                                    result = 256 + ~ int(operator)
                                    # print result

                                    MNEMONIC_CODE = MNEMONIC_CODE.replace(MNEMONIC_CODE[MNEMONIC_CODE.index('('):],
                                                                          "b{0:08b}".format(result))
                                    # print MNEMONIC_CODE

                            if MNEMONIC_CODE.find('"') != -1:
                                character = MNEMONIC_CODE[MNEMONIC_CODE.index('"') + 1: MNEMONIC_CODE.index(
                                    '"') + 2]  # store the character
                                MNEMONIC_CODE = MNEMONIC_CODE.replace(MNEMONIC_CODE[MNEMONIC_CODE.index('"'):],
                                                                      "b{0:08b}".format(ord(character)))

                            OP_CODE = MNEMONIC_CODE[:MNEMONIC_CODE.index(' ')]
                            # print OP_CODE
                            if (OP_CODE.lower() == 'mov' or OP_CODE.lower() == 'add' or OP_CODE.lower() == 'sub' or OP_CODE.lower() == 'push' or OP_CODE.lower() == 'pop'
                                or OP_CODE.lower() == 'mul' or OP_CODE.lower() == 'div' or OP_CODE.lower() == 'rda' or OP_CODE.lower() == 'addi' or OP_CODE.lower() == 'subi'
                                or OP_CODE.lower() == 'jb' or OP_CODE.lower() == 'jnb' or OP_CODE.lower() == 'addc' or OP_CODE.lower() == 'addic' or OP_CODE.lower() == 'subb'
                                or OP_CODE.lower() == 'subib'):
                                # if MNEMONIC_CODE [MNEMONIC_CODE.rindex (' ') + 1:] in CONSTANTS:
                                #    MNEMONIC_CODE = MNEMONIC_CODE.replace (MNEMONIC_CODE [MNEMONIC_CODE.rindex (' ') + 1:], CONSTANTS [MNEMONIC_CODE [MNEMONIC_CODE.rindex (' ') + 1:]])
                                mnemonic_word_array = re.split("\s|[,]", MNEMONIC_CODE)
                                for word_index in range(len(mnemonic_word_array)):
                                    for x in CONSTANTS:
                                        # if MNEMONIC_CODE.find(x) != -1:
                                        if mnemonic_word_array[word_index] == x:
                                            MNEMONIC_CODE = MNEMONIC_CODE.replace(x, CONSTANTS[x])

                                if (MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1].lower() != 'x'
                                        and MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1].lower() != '$'
                                        and MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1].lower() != 'b' and (
                                                MNEMONIC_CODE.lower().find('jb') == -1 and MNEMONIC_CODE.lower().find(
                                            'jnb') == -1)):
                                    OP_CODE = MNEMONIC_CODE.replace(" ", "")
                                    # print OP_CODE
                                    MNEMONIC_CODE = OP_CODE
                                    # print ("when not {}" .format (MNEMONIC_CODE))
                                else:
                                    OP_CODE = MNEMONIC_CODE[:MNEMONIC_CODE.rindex(' ')].replace(" ", "")
                                    # print ("when direct {}" .format (OP_CODE))

                                ### MOV C PX.Y / MOV PX.Y C
                                if (MNEMONIC_CODE.lower().find('p0.') != -1 and (
                                        MNEMONIC_CODE.lower().find('jb') == -1 and MNEMONIC_CODE.lower().find(
                                        'jnb') == -1)):
                                    A = 0b00000000
                                    bit_op = A | (1 << int(MNEMONIC_CODE[MNEMONIC_CODE.index('.') + 1]))
                                    OP_CODE = MNEMONIC_CODE.replace (MNEMONIC_CODE[MNEMONIC_CODE.index('0.'): MNEMONIC_CODE.index('0.') + 3], "0.").replace(" ", "")
                                    MNEMONIC_CODE = str(OP_CODE) + " b{0:08b}".format(bit_op)
                                elif (MNEMONIC_CODE.lower().find('p0.') != -1 and (MNEMONIC_CODE.lower().find('jb') != -1 or MNEMONIC_CODE.lower().find('jnb') != -1)):
                                    A = 0b00000000
                                    bit_op = A | (1 << int(MNEMONIC_CODE[MNEMONIC_CODE.index('.') + 1]))
                                    address = MNEMONIC_CODE[MNEMONIC_CODE.rindex(' '):]
                                    OP_CODE = MNEMONIC_CODE[: MNEMONIC_CODE.rindex(' ')].strip()
                                    OP_CODE = OP_CODE.replace(OP_CODE[OP_CODE.index('0.'): OP_CODE.index('0.') + 3], "0").replace(" ", "")
                                    OP_CODE_LIST.append(OP_CODE)
                                    OPER_LIST.append("b{0:08b}".format(bit_op))
                                    CODE_LENGTH += 1
                                    OP_CODE = "00000000 "
                                    MNEMONIC_CODE = OP_CODE + address

                                if (MNEMONIC_CODE.lower().find('p1.') != -1 and (MNEMONIC_CODE.lower().find('jb') == -1 and MNEMONIC_CODE.lower().find('jnb') == -1)):
                                    A = 0b00000000
                                    bit_op = A | (1 << int(MNEMONIC_CODE[MNEMONIC_CODE.index('.') + 1]))
                                    OP_CODE = MNEMONIC_CODE.replace(
                                        MNEMONIC_CODE[MNEMONIC_CODE.index('1.'): MNEMONIC_CODE.index('1.') + 3],
                                        "1.").replace(" ", "")
                                    MNEMONIC_CODE = str(OP_CODE) + " b{0:08b}".format(bit_op)
                                elif (MNEMONIC_CODE.lower().find('p1.') != -1 and (
                                        MNEMONIC_CODE.lower().find('jb') != -1 or MNEMONIC_CODE.lower().find(
                                        'jnb') != -1)):
                                    A = 0b00000000
                                    bit_op = A | (1 << int(MNEMONIC_CODE[MNEMONIC_CODE.index('.') + 1]))
                                    address = MNEMONIC_CODE[MNEMONIC_CODE.rindex(' '):]
                                    OP_CODE = MNEMONIC_CODE[: MNEMONIC_CODE.rindex(' ')].strip()
                                    OP_CODE = OP_CODE.replace(OP_CODE[OP_CODE.index('1.'): OP_CODE.index('1.') + 3],
                                                              "1").replace(" ", "")
                                    OP_CODE_LIST.append(OP_CODE)
                                    OPER_LIST.append("b{0:08b}".format(bit_op))
                                    CODE_LENGTH += 1
                                    OP_CODE = "00000000 "
                                    MNEMONIC_CODE = OP_CODE + address

                            if MNEMONIC_CODE.find('"') != -1:
                                character = MNEMONIC_CODE[MNEMONIC_CODE.index('"') + 1: MNEMONIC_CODE.index(
                                    '"') + 2]  # store the character
                                OP_CODE = MNEMONIC_CODE [:MNEMONIC_CODE.index ('"')]
                                MNEMONIC_CODE = OP_CODE + " " +  "b{0:08b}".format(ord(character))
                                # MNEMONIC_CODE = MNEMONIC_CODE.replace(MNEMONIC_CODE[MNEMONIC_CODE.index('"'):],
                                #                                       "b{0:08b}".format(ord(character)))

                            if OP_CODE.lower() == 'inc' or OP_CODE.lower() == 'dec' or OP_CODE.lower() == 'djnz':
                                OP_CODE = MNEMONIC_CODE[:MNEMONIC_CODE.rindex(' ')].replace(" ", "")

                            if OP_CODE.lower() == 'anl' or OP_CODE.lower() == 'orl' or OP_CODE.lower() == 'cpl':
                                OP_CODE = MNEMONIC_CODE.replace(" ", "")
                                if OP_CODE.lower() == 'cpla':
                                    MNEMONIC_CODE = str(OP_CODE) + " b{0:08b}".format(255)
                                else:
                                    MNEMONIC_CODE = OP_CODE

                            if OP_CODE.lower() == 'set' or OP_CODE.lower() == 'clr':
                                if (MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:].lower() != 't0e'
                                        and MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:].lower() != 't0'
                                        and MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:].lower() != 'tr0'
                                        and MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:].lower() != 'tcr0e'
                                        and MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:].lower() != 'tc0l'):
                                    if MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:] in CONSTANTS:
                                        MNEMONIC_CODE = MNEMONIC_CODE.replace(
                                            MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:],
                                            CONSTANTS[MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:]])

                                    OP_CODE = MNEMONIC_CODE[:MNEMONIC_CODE.index('.')].replace(" ", "")
                                    A = 0b00000000
                                    bit_op = A | (1 << int(MNEMONIC_CODE[MNEMONIC_CODE.index('.') + 1:]))
                                    # print "bit_op {0:08b}" .format (bit_op)
                                    MNEMONIC_CODE = str(MNEMONIC_CODE[:MNEMONIC_CODE.index('.')]) + " b{0:08b}".format(
                                        bit_op)
                                else:
                                    OP_CODE = MNEMONIC_CODE.replace(" ", "")
                                    # print OP_CODE
                                    MNEMONIC_CODE = MNEMONIC_CODE.replace(" ", "")
                        except:
                            OP_CODE = MNEMONIC_CODE
                        try:
                            OPER = MNEMONIC_CODE[MNEMONIC_CODE.rindex(' ') + 1:]
                        except:
                            OPER = 'NO OPER'
                        OP_CODE_LIST.append(OP_CODE)
                        OPER_LIST.append(OPER)
                    else:
                        try:
                            DIRECT_ADDRESS = MNEMONIC_CODE[1:MNEMONIC_CODE.rindex(':')].replace(" ", "")  # raw address location
                            # print "Direct address location {}" .format (DIRECT_ADDRESS)
                            # print DIRECT_ADDRESS [0]
                            # print DIRECT_ADDRESS [1:]
                            # Hex DATA
                            if DIRECT_ADDRESS[0].lower() == 'x':
                                # bin(int("abc123efff", 16))[2:]
                                BIN_ADDRESS = "{0:016b}".format(int(DIRECT_ADDRESS[1:], 16))
                                # print BIN_ADDRESS
                            # Int DATA
                            elif DIRECT_ADDRESS[0].lower() == '$':
                                BIN_ADDRESS = "{0:016b}".format(int(DIRECT_ADDRESS[1:]))
                                # print BIN_ADDRESS
                            # Binary DATA
                            elif DIRECT_ADDRESS[0].lower() == 'b':
                                BIN_ADDRESS = "{0:016b}".format(int(DIRECT_ADDRESS[1:], 2))
                                # print BIN_ADDRESS
                            DIRECT_ADDRESS_LIST[0] = 1
                            DIRECT_ADDRESS_LIST.append(BIN_ADDRESS)

                            DIRECT_DATA = MNEMONIC_CODE[
                                          MNEMONIC_CODE.rindex(':') + 1:MNEMONIC_CODE.rindex(']')].replace(" ",
                                                                                                           "")  # raw data in the raw address location
                            # print "Direct Data loaded {}" .format (DIRECT_DATA)
                            # Hex DATA
                            if DIRECT_DATA[0].lower() == 'x':
                                # bin(int("abc123efff", 16))[2:]
                                BIN_DATA = "{0:016b}".format(int(DIRECT_DATA[1:], 16))
                                # print BIN_DATA
                            # Int DATA
                            elif DIRECT_DATA[0].lower() == '$':
                                if DIRECT_DATA[1].lower () != '-':
                                    BIN_DATA = "{0:016b}".format(int(DIRECT_DATA[1:]))
                                    # print BIN_DATA
                                else:
                                    BIN_DATA = "{0:016b}".format(256 - int(DIRECT_DATA[2:]))
                            # Binary DATA
                            elif DIRECT_DATA[0].lower() == 'b':
                                BIN_DATA = "{0:016b}".format(int(DIRECT_DATA[1:], 2))
                                # print BIN_DATA
                            DIRECT_DATA_LIST[0] = 1
                            DIRECT_DATA_LIST.append(BIN_DATA)
                        except (ValueError, IndexError, UnboundLocalError):
                            print(f"*** Direct Address Error ***")
                            CONSOLE_OUTPUTS.append ("*** Direct Address Error ***")
                            print("Expected format : [address : data]")
                            CONSOLE_OUTPUTS.append ("Expected format : [address : data]")

                            del OP_CODE_LIST[:]
                            del OPER_LIST[:]

                            del MACHINE_CODE_LOW[:]
                            del MACHINE_CODE_HIGH[:]

                            del ADDRESS_MACHINE_CODE_LOW[:]
                            del ADDRESS_MACHINE_CODE_HIGH[:]

                            del DIRECT_ADDRESS_LIST[:]
                            DIRECT_ADDRESS_LIST.append(0)
                            del DIRECT_DATA_LIST[:]
                            DIRECT_DATA_LIST.append(0)

                            del WORD_DATA_LIST[:]
                            WORD_DATA_LIST.append(0)

                            del MNEMONIC_CODE_REPORT_LIST[:]

                            SUBROUTINE_POINTER.clear()
                            CONSTANTS.clear()

                            #Enter_file_name()

            f.close()

        FormMachineCode(OP_CODE_LIST, OPER_LIST, CODE_LENGTH, DIRECT_ADDRESS_LIST, DIRECT_DATA_LIST)
        return 0, ""
    except FileNotFoundError:
        print("File not found")
        CONSOLE_OUTPUTS.append ("File not found")
        #Enter_file_name()


def Enter_file_name(name, directory, mode, report_echo, commport, speed):
    global FILE_NAME
    global RPT_echo
    global DIRECTORY
    global COMM_port
    global SPEED

    COMM_port = commport
    SPEED = speed
    RPT_echo = report_echo
    FILE_NAME = name
    DIRECTORY = f"{directory}/"
    DIRECTORY_NAME_EXT = "{}{}.{}".format(DIRECTORY, FILE_NAME, FEXT)
    print (f"name is {FILE_NAME}.{FEXT}")
    if int(mode) == 1:
        exit_status, message = ReadFile(DIRECTORY_NAME_EXT)
        if exit_status == -1:
            CONSOLE_OUTPUTS.append (message)
    elif int(mode) == 2:
        DeliverMachineCode()