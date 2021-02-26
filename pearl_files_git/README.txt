###----------------------------------------------------------------------------------------
##                                                                         
## Hochschule Ravensburg-Weingarten, Weingarten (Baden-Württ), Germany      
##									    
## Author      : Rudran Chakraborty                                         
## Approved by : Prof. Dr. rer. nat. Markus Pfeil                           
##               		                                            
##                                                                          
##                                                                          
## Project Name: A Guide to Computer Architecture (Pearl)
##
## Detailed documentation & user guide with instruction set: pearl_documentation                         
##                                                                          
## Description: This purpose of this project is to understand the basics
## of a microcontroller. In this project, we also create a simple microcontroller
## architecture in an FPGA using VHDL. A custom Assembler for the microcontroller
## is also created using python with graphical user interface to assist the user
## for easier compiling and uploading of the assembly codes.
##                                                                          
## Target devices: CYC1000 and MAX1000, Xilinx Spartan 3E
## 
## Included files (VHDL): The project only includes the rtl folder with test-bench simultion
## of the top-level design. For Spartan 3E development board, the cyclone-pll module must be
## removed. The rtl folder must have the following files:
             1. pearl_top.vhd
	     2. programmer_inteface.vhd
	     3. isp.vhd
	     4. core_top.vhd
	     5. da_buffer.vhd
	     6. mar.vhd
	     7. iram.vhd
	     8. accumulator.vhd
	     9. b_reg.vhd
	     10. GP_Register0.vhd (GPR type1)
	     11. GP_Register3.vhd (GPR type2)
	     12. alu.vhd
	     13. Information_Register.vhd
	     14. program_header.vhd
	     15. user_o.vhd
	     16. user_io.vhd
	     17. multibus.vhd
	     18. Flag_Register.vhd
             19. timer_counter.vhd
	     20. constant_generator.vhd
	     21. stack_mem.vhd
	     22. control_fsm.vhd
	     23. accumulator_p.vhd
	     24. alu_p.vhd
	     25. control_fsm_p.vhd
	For MAX1000 and CYC1000 devices the pll files must be added as well:
             26. max1000_pll.vhd
	     27. max1000_pll.qip
	     28. max1000_pll.ppf
##                                                                                                                                         
##
## Note: Informations regarding project setup can be found in pearl_documentation
##
## Included files (Python): For the custom assembler and GUI, the following files must be present in
## pearl_assembler_gui folder:
##           1. pearl.py
##           2. asmpearl_0309.py
##	     3. system.ini
##           4. images (folder)
##
## Included SW (windows 10 64-bit): The "Executable" folder contains the following files:
##	     1. pearl.exe
##	     2. system.ini
##	     3. images (folder)
##
## The pearl.exe application is created from the pearl.py python script and can be run on windows 10 64-bit
## version computers. To compile and upload the assembly code (assuming that the board is already set in programming
## mode), first goto File -> Directory and chose the program directory. Next goto File -> Open file and select the
## program to compile. Finally click on the "tick" button to compile and upload the code. To upload an already built
## .hex file, click on the "arrow".
##
## Included example assembly files: The project file also includes example assembly programs that can be
## tested out in CYC/MAX1000 boards. For more information regarding the board connections can be found in
## pearl_documentation.
##
##
## UPDATE LOG:                                                              
## 1. (18.02.2021) Initial code release
##          
###----------------------------------------------------------------------------------