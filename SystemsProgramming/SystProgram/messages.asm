; Various messages output by the second stage

second_stage_msg	db 'Second stage of boot loader running', 0
	
a20_msg_one			db 'A20 line already enabled', 0
a20_msg_two			db 'A20 line enabled by BIOS', 0
mssg_1				db 'Content of sector', 0
continuemssg		db 'Press any key to continue', 0
inputmessage		db 'Enter the Sector number to Read: ', 0
a20_msg_three		db 'A20 line enabled using keyboard controller', 0
a20_msg_four		db 'A20 line enabled using Fast A20 gate', 0
no_a20_msg			db 'Unable to enable A20 line', 0	
wait_for_key_msg    db 'Press a key to continue', 0
msgFailure 	  	    db 'Unable to find KERNEL.SYS. ', 0


a20_message_list	dw no_a20_msg
					dw a20_msg_one
					dw a20_msg_two
					dw a20_msg_three
					dw a20_msg_four