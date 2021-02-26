import tkinter as tk
from tkinter.filedialog import *
import asmpearl_0309 as asm
from functools import partial
import serial
#import threading
#import time

app_width = 800
app_height = 600

class pearl_controller (tk.Tk):
    def __init__(self):
        tk.Tk.__init__(self)
        self.frame = pearl_loading_screen (self)

    def change_frame (self, new_frame, current_frame):
        current_frame.destroy ()
        self.frame = new_frame(self)
        self.frame.pack()

class pearl_loading_screen (tk.Frame):
    def __init__(self, master):
        tk.Frame.__init__(self)
        self.loading_screen_bg = tk.PhotoImage(file=r"images\loading_screen.png")
        bg_width = self.loading_screen_bg.width()
        bg_height = self.loading_screen_bg.height ()
        self.pearl_loading_frame = tk.Frame(master, height = 531, width = 530, bd = 0, bg = "red")
        self.pearl_loading_frame.pack()
        self.pearl_loading_frame.place (x = 0, y = 0, anchor = tk.NW)
        self.pearl_loading_frame.propagate(0)
        master.geometry(f"{bg_width}x{bg_height}+{int((master.winfo_screenwidth() - bg_width) / 2)}"
                                                f"+{int((master.winfo_screenheight() - bg_height) / 2) - 30}")

        master.overrideredirect(True)
        master.resizable(False, False)

        self.loading_screen_lable = tk.Label (self.pearl_loading_frame, image = self.loading_screen_bg)
        self.loading_screen_lable.pack ()
        self.loading_screen_lable.place (x = 0, y =0, anchor = tk.NW)
        self.after_id = None

        self.loading ()

    def loading (self):
        self.after_id = self.after (2000, self.pearl_interface_terminal)

    def pearl_interface_terminal (self):
        if self.after_id is not None:
            self.after_cancel (self.after_id)

        self.master.change_frame (new_frame = pearl_interface, current_frame = self.pearl_loading_frame)


class pearl_interface (tk.Frame):
    def __init__(self, master):
        tk.Frame.__init__(self)
        self.pearl_frame = tk.Frame (master, bd = 3, relief ="ridge", height = app_height, width = app_width, bg ="white")
        self.pearl_frame.pack ()
        self.pearl_frame.propagate (0)
        master.geometry (f"{app_width}x{app_height}+{int ((master.winfo_screenwidth ()  - app_width) / 2)}+{int ((master.winfo_screenheight () - app_height) / 2)}")

        self.menubar = tk.Menu (self.pearl_frame)
        master.config (menu = self.menubar)
        master.resizable (False, False)
        master.title('Pearl Terminal 1.0.1')
        master.overrideredirect(False)
        master.iconbitmap (r'images\icon2.ico')

        self.compile_upload_btn_image = tk.PhotoImage (file = r"images\compile_upload.png")
        self.hex_upload_btn_image = tk.PhotoImage (file = r"images\hex_upload.png")
        self.terminal_btn_image = tk.PhotoImage (file = r"images\term_btn.png")

        self.pearl_terminal_window = None
        self.rx = None

        self.after_id = None

        with open ("system.ini", 'r') as f:
            new = f.readlines()
            self.directory_path = new[0] [new[0].index ('=') + 1 :].strip()
            self.file = new [1] [new [1].index ('=') + 1 :].strip()
            self.comm_port = new [2] [new [2].index ('=') + 1 :].strip()
            self.speed = new [3] [new [3].index ('=') + 1 :].strip()
            self.report_echo = new [4] [new [4].index ('=') + 1 :].strip ()

            f.close ()

        print (self.report_echo)

        self.report_word_var = tk.BooleanVar ()
        if self.report_echo.find ('w') != -1:
            self.report_word_var.set (True)
        else:
            self.report_word_var.set (False)

        self.report_constant_var = tk.BooleanVar ()
        if self.report_echo.find ('c') != -1:
            self.report_constant_var.set (True)
        else:
            self.report_constant_var.set (False)

        self.report_raw_var = tk.BooleanVar ()
        if self.report_echo.find ('r') != -1:
            self.report_raw_var.set (True)
        else:
            self.report_raw_var.set (False)

        self.dialog = None

        self.add_elements ()

    def pearl_terminal (self):
        font_colour = "#05c3de"
        if self.pearl_terminal_window is not None:
            self.pearl_terminal_window.destroy ()
            try:
                self.rx.close()
            except AttributeError:
                print ("comm error!")

        self.pearl_terminal_window = tk.Toplevel (bg = "#3c3f41")
        self.pearl_terminal_window.geometry(f"{700}x{400}+{int((self.pearl_terminal_window.winfo_screenwidth() - 700) / 2)}"
                                                f"+{int((self.pearl_terminal_window.winfo_screenheight() - 400) / 2) - 30}")
        self.pearl_terminal_window.geometry ("700x400")
        self.pearl_terminal_window.protocol ('WM_DELETE_WINDOW', self.disable_close)
        self.pearl_terminal_window.resizable (False, False)
        self.pearl_terminal_window.title (f"{self.comm_port} at {self.speed}  Terminal window")
        self.pearl_terminal_window.iconbitmap(r'images\icon2.ico')
        self.pearl_terminal_window.focus ()
        self.terminal_text = tk.Text(self.pearl_terminal_window, wrap=tk.WORD, width=87, height=23, bd=1)
        self.terminal_text.pack()
        self.terminal_text.place(x= 2, y= 30, anchor=tk.NW)

        self.terminal_close_btn = tk.Button (self.pearl_terminal_window, text = "close", command = self.terminal_close, bd = 1, bg = "#3c3f41", fg = "white", activebackground = "#3c3f41")
        self.terminal_close_btn.pack ()
        self.terminal_close_btn.place (x = 680, y = 2, anchor = tk.NE)

        self.rx = serial.Serial(port=self.comm_port, baudrate=int(self.speed), timeout=0.05)
        self.receive_data ()

    def disable_close (self):
        pass

    def terminal_close (self):
        if self.after_id is not None:
            self.after_cancel(self.after_id)

        if self.pearl_terminal_window is not None:
            self.pearl_terminal_window.destroy ()
            try:
                self.rx.close()
            except AttributeError:
                print ("comm error!")

    def receive_data (self):
        while True:
            x = self.rx.readlines()
            if len (x) == 0:
                break
            try:
                x = x[0]
                self.terminal_text.insert(tk.END, f'{x.decode("utf-8")}')
            except:
                continue


        if self.after_id is not None:
            self.after_cancel(self.after_id)

        self.after_id = self.after(10, self.receive_data)

    def add_elements (self):
        strip_colour = "#17a1a5"
        strip_colour2 = "#05c3de"
        strip_colour3 = "#6638b6"
        self.horizontal_strip = tk.Label (self.pearl_frame, bg = strip_colour3, width = 112, height = 4)
        self.horizontal_strip.pack ()
        self.horizontal_strip.place (x = 0, y = 0)

        self.upload_button = tk.Button (self.pearl_frame, image = self.hex_upload_btn_image, height = 38, width = 40, command = self.upload_hex, bd = 0, bg = strip_colour3, activebackground = strip_colour3)
        self.upload_button.pack ()
        self.upload_button.place (x = 15, y = 10, anchor = tk.NW)

        self.compile_button = tk.Button (self.pearl_frame, image = self.compile_upload_btn_image, height = 39, width = 46, command = self.compile_upload, bd = 0, bg = strip_colour3, activebackground = strip_colour3)
        self.compile_button.pack ()
        self.compile_button.place (x = 75, y = 10, anchor = tk.NW)

        self.terminal_btn = tk.Button(self.pearl_frame, image = self.terminal_btn_image, command = self.pearl_terminal, height = 42, width = 53, bd = 0, bg = strip_colour3, activebackground = strip_colour3)
        self.terminal_btn.pack ()
        self.terminal_btn.place (x = 770, y = 10, anchor = tk.NE)

        self.console_setup = tk.Text (self.pearl_frame, wrap = tk.WORD, width = 50, height = 30, bd = 5)
        self.console_setup.pack ()
        self.console_setup.place (x = 0, y = 80, anchor = tk.NW)

        self.program_information = tk.Text (self.pearl_frame, width = 47, height = 6, wrap = tk.CHAR)
        self.program_information.pack ()
        self.program_information.place (x = 411, y = 80, anchor = tk.NW)
        self.update_program_information()

        self.assemblycodes = tk.Text (self.pearl_frame, wrap = tk.WORD, width = 47, height = 24, bd = 3)
        self.assemblycodes.pack ()
        self.assemblycodes.place (x = 411, y = 180, anchor = tk.NW)
        self.assemblycodes.insert (tk.END, "   *** Syntax for commonly used Inst. ***\n\n")
        self.assemblycodes.insert (tk.END, "type = $ for integer b for binary x for hex\n\n")

        self.assemblycodes.insert (tk.END, "\t\tMove commands :\n\n")
        self.assemblycodes.insert (tk.END, "MOV A, R_ ;  \t\t\t_ = 0 to 4\n")
        self.assemblycodes.insert (tk.END, "MOV R_, A ;  \t\t\t_ = 0 to 4\n")
        self.assemblycodes.insert (tk.END, "MOV R_ {type}{num} ;   \te.g MOV R1 x0a\n")
        self.assemblycodes.insert (tk.END, "MOV TH0 {type}{num} ;  \te.g MOV TH0 $20\n")
        self.assemblycodes.insert (tk.END, "MOV CS0 {type}{num} ;  \te.g MOV CS0 $20\n")
        self.assemblycodes.insert (tk.END, "MOV C, P_.x ;  \t\t\t_ = 0, 1; x = 0 to 7\n\n")
        self.assemblycodes.insert (tk.END, "MOV P_.x, C ;  \t\t\t_ = 0, 1; x = 0 to 7\n\n")
        self.assemblycodes.insert (tk.END, "Look into data sheet for more instrunctions\n\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n\n")

        self.assemblycodes.insert (tk.END, "\t\tJump commands :\n\n")
        self.assemblycodes.insert (tk.END, "JMP {address} ; uncondtional jump\n")
        self.assemblycodes.insert (tk.END, "JBTF0 {address}; jump when timer0 flag is set\n")
        self.assemblycodes.insert (tk.END, "JNBTF0 {address}; jump when timer0 flag is NOT\n\t\t  set\n")
        self.assemblycodes.insert (tk.END, "JT0V {address}; jump when timer0 overflow flag\n\t\t  is set\n")
        self.assemblycodes.insert(tk.END, "JNT0V {address}; jump when timer0 overflow flag\n\t\t is NOT set\n")
        self.assemblycodes.insert (tk.END, "JB P_.x {address}; \t\t _ = 0, 1; x = 0 to 7\n")
        self.assemblycodes.insert(tk.END, "JNB P_.x {address}; \t\t_ = 0, 1; x = 0 to 7\n")
        self.assemblycodes.insert (tk.END, "DJNZ R_, {address};decrement and jump when R_\n\t\t   is NOT zero\n\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n\n")

        self.assemblycodes.insert (tk.END, "\t\tINC / DEC commands :\n\n")
        self.assemblycodes.insert(tk.END, "INC R_ {num} ; \t\t_ = 0 to 3\n")
        self.assemblycodes.insert(tk.END, "DEC R_ {num} ; \t\t_ = 0 to 3\n\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n\n")

        self.assemblycodes.insert(tk.END, "\t\tSET / CLR commands :\n\n")
        self.assemblycodes.insert(tk.END, "SET P_.x {num} ; \t\t_ = 0, 1; x = 0 to 7\n")
        self.assemblycodes.insert(tk.END, "CLR P_.x {num} ; \t\t_ = 0, 1; x = 0 to 7\n")
        self.assemblycodes.insert(tk.END, "SET T0E ; \t sets the prescale and OCR register\n")
        self.assemblycodes.insert(tk.END, "SET TR0 ; \t starts Timer0\n")
        self.assemblycodes.insert(tk.END, "SET TCR0E ;\tstarts Counter0\n")
        self.assemblycodes.insert(tk.END, "SET TC0L ; \tloads Counter0 trim value\n")
        self.assemblycodes.insert(tk.END, "CLR T0 ;   \tresets Timer0 / Counter0\n\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n\n")

        self.assemblycodes.insert(tk.END, "\t\tCompare commands :\n\n")
        self.assemblycodes.insert(tk.END, "CMP {num} ; compare value stored in memory\n\t    address num with A register; Flags\n\t    are updated w/o changing A register\n")
        self.assemblycodes.insert(tk.END, "CMPI {num} ; compare with immediate value\n\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n")
        self.assemblycodes.insert(tk.END, "-----------------------------------------------\n\n")

        self.assemblycodes.config (state = "disabled")

        fileMenu = tk.Menu (self.menubar, tearoff = False)
        self.menubar.add_cascade (label = "File", menu = fileMenu)
        fileMenu.add_command (label = "Open file", command = self.open_file)
        fileMenu.add_command (label = "Directory", command = self.directory)
        fileMenu.add_separator ()
        fileMenu.add_command (label = "Exit", command = self.exit_pearl)

        toolMenu = tk.Menu(self.menubar, tearoff=False)
        reportFile = tk.Menu(self.menubar, tearoff=False)
        self.menubar.add_cascade(label="Tools", menu=toolMenu)
        toolMenu.add_command(label="Port", command=self.add_port)
        toolMenu.add_command(label = "Baud rate", command = self.change_baudrate)
        toolMenu.add_command(label="Clear console", command=self.clear_console)

        toolMenu.add_cascade(label="Add in report", menu=reportFile)
        reportFile.add_checkbutton(label="Raw address", variable=self.report_raw_var)
        reportFile.add_checkbutton(label="Word type", variable=self.report_word_var)
        reportFile.add_checkbutton(label="Constants", variable=self.report_constant_var)

    def exit_pearl (self):
        self.quit ()

    def open_file (self):
        old_filename = self.file
        self.file = askopenfilename(initialdir = self.directory_path,
                                    filetypes = (("pearl File", "*.pearl"), ("All Files", "*.*")),
                                    title = "Choose file.")

        if self.file != "":
            self.file = self.file [self.file.rindex ('/') + 1 : self.file.rindex ('.')]
        else:
            self.file = old_filename

        self.update_system_config (update_type = "current file", old_name = old_filename, new_name = self.file)
        self.update_program_information ()

    def update_system_config (self, update_type, old_name, new_name):
        with open ("system.ini") as f:
            data = f.readlines ()
            with open("system.ini", 'w') as edit:
                for line in data:
                    change = line
                    if line [: line.index ('=')].strip () == update_type:
                        change = line.replace (old_name, new_name)
                        print (change)
                    edit.write (change)
                edit.close ()
            f.close ()

    def update_program_information (self):
        self.program_information.config(state="normal")
        self.program_information.delete('1.0', tk.END)
        self.program_information.insert(tk.END, f"Current file : {self.file}\nDirectory : {self.directory_path}"
                                             f"\nPort : {self.comm_port}\nBaud : {self.speed}")

        self.program_information.config(state="disable")

    def directory (self):
        old_directoryname = self.directory_path
        self.directory_path = askdirectory(initialdir = self.directory_path,
                                           title = "Choose current directory.")

        if self.directory_path == "":
            self.directory_path = old_directoryname

        self.update_system_config(update_type = "directory path", old_name = old_directoryname, new_name = self.directory_path)
        self.update_program_information()

    def change_baudrate (self):
        if self.dialog is not None:
            try:
                self.dialog.destroy ()
            except:
                pass
        width = 250
        height = 100
        self.dialog = tk.Toplevel ()
        self.dialog.geometry("%dx%d+%d+%d" % (width, height, (self.dialog.winfo_screenwidth() - width) / 2, (self.dialog.winfo_screenheight() - height) / 2 + 20))
        self.dialog.config (bd = 0)
        self.dialoglabel = tk.Label (self.dialog, text = "Enter Baud Rate", bd = 0)
        self.dialoglabel.pack ()
        self.dialoglabel.place (x = width / 2, y = 10, anchor = tk.CENTER)
        self.dialog.resizable (False, False)
        #self.dialog.attributes('-type', 'dock')
        old_rate = self.speed
        baudrate_entry = tk.Entry (self.dialog, width = 20, bd = 2)
        baudrate_entry.pack ()
        baudrate_entry.place (x = width / 2, y = height / 2, anchor = tk.CENTER)
        baudrate_entry.focus ()

        self.confirm_btn = tk.Button (self.dialog, text = ">", command = partial (self.port_config, type = "baud_rate", old_val = old_rate, new_val = baudrate_entry), width = 3, height = 1, bd = 1)
        self.confirm_btn.pack ()
        self.confirm_btn.place (x = width / 2 + 84, y = height / 2, anchor = tk.CENTER)

    def add_port (self):
        if self.dialog is not None:
            try:
                self.dialog.destroy ()
            except:
                pass
        width = 250
        height = 100
        self.dialog = tk.Toplevel ()
        self.dialog.geometry("%dx%d+%d+%d" % (width, height, (self.dialog.winfo_screenwidth() - width) / 2, (self.dialog.winfo_screenheight() - height) / 2 + 20))
        self.dialog.config (bd = 0)
        self.dialoglabel = tk.Label (self.dialog, text = "Enter Port Name", bd = 0)
        self.dialoglabel.pack ()
        self.dialoglabel.place (x = width / 2, y = 10, anchor = tk.CENTER)
        self.dialog.resizable (False, False)
        #self.dialog.attributes('-type', 'dock')
        old_commport = self.comm_port
        com_port = tk.Entry (self.dialog, width = 20, bd = 2)
        com_port.pack ()
        com_port.place (x = width / 2, y = height / 2, anchor = tk.CENTER)
        com_port.focus ()

        self.confirm_btn = tk.Button (self.dialog, text = ">", command = partial (self.port_config, type = "port", old_val = old_commport, new_val = com_port), width = 3, height = 1, bd = 1)
        self.confirm_btn.pack ()
        self.confirm_btn.place (x = width / 2 + 84, y = height / 2, anchor = tk.CENTER)

    def port_config (self, type, old_val, new_val):
        if type == "port":
            if new_val.get() == "":
                self.comm_port = old_val
            else:
                self.comm_port = new_val.get()
            self.update_system_config (update_type = "comm port", old_name = old_val, new_name = self.comm_port)
        elif type == "baud_rate":
            if new_val.get() == "":
                self.speed = old_val
            else:
                self.speed = new_val.get()
            self.update_system_config(update_type="baud rate", old_name=old_val, new_name=self.speed)
        self.update_program_information ()
        self.dialog.destroy ()

    def upload_hex (self):
        self.update_report_file_format()
        self.console_setup.config(state="normal")
        asm.Enter_file_name(name=self.file, directory=self.directory_path, mode=2, report_echo="",
                            commport=self.comm_port, speed=int(self.speed))
        for console_line in asm.CONSOLE_OUTPUTS:
            self.console_setup.insert (tk.END, f"{console_line}\n")
        self.console_setup.config(state="disabled")
        del asm.CONSOLE_OUTPUTS [:]

    def compile_upload (self):
        self.update_report_file_format()
        self.console_setup.config(state="normal")
        self.console_setup.insert(tk.END, "compiling...\n")
        asm.Enter_file_name (name = self.file, directory = self.directory_path, mode = 1, report_echo = self.report_echo,
                             commport = self.comm_port, speed = int (self.speed))
        for console_line in asm.CONSOLE_OUTPUTS:
            self.console_setup.insert (tk.END, f"{console_line}\n")
        self.console_setup.config(state="disabled")
        del asm.CONSOLE_OUTPUTS [:]

    def clear_console (self):
        self.console_setup.config (state = "normal")
        self.console_setup.delete('1.0', tk.END)
        self.console_setup.config (state = "disable")

    def update_report_file_format (self):
        report_echo_type = "m"
        if self.report_raw_var.get() == True:
            report_echo_type += 'r'
        if self.report_word_var.get() == True:
            report_echo_type += 'w'
        if self.report_constant_var.get() == True:
            report_echo_type += 'c'

        if (self.report_raw_var.get() == False and self.report_word_var.get() == False
                and self.report_constant_var.get() == False):
            report_echo_type = "m"

        print (report_echo_type)
        self.update_system_config (update_type = "report echo", old_name = self.report_echo, new_name = report_echo_type)
        self.report_echo = report_echo_type


if __name__ == "__main__":
    app = pearl_controller ()
    app.mainloop ()