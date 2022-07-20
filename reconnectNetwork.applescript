-- set inferfanceName to "Interface"
-- Done in the lua code

tell application "System Preferences"
	launch
	set current pane to pane id "com.apple.preference.network"
	repeat until (exists (window "Network"))
		delay 1
	end repeat
end tell

tell application "System Events"
	--	set visible of application process "System Preferences" to false
	tell process "System Preferences"
		set networkFound to false

		repeat while networkFound is not true
			repeat with r in rows of table 1 of scroll area 1 of window 1
				if (value of static text of r as text) starts with interfaceName then
					select r
					delay 1 -- give time to the pane to change info
					set networkFound to true
				end if
			end repeat

			if (networkFound is not true) then
				display dialog "Could not find network interface:\"" & interfaceName & "\"
" & "What is the name of your dock network interface?" default answer interfaceName
				set interfaceName to text returned of the result
			end if
		end repeat
		tell group 1 of window 1

			-- for some reason we weren't connected, so connect and disconnect to reset the interface
			if exists (first button whose name is "Connect") then
				click (first button whose name is "Connect")
				repeat until (exists (first button whose name is "Disconnect"))
					delay 1
				end repeat
				delay 1 -- give a bit of extra time for the interface to update
			end if

			set target_button to a reference to (first button whose name is "Disconnect")
			set clicked_disconnect to 0
			if exists target_button then
				click target_button
				set clicked_disconnect to 1
			end if

			repeat until (exists (first button whose name is "Connect"))
				delay 1
			end repeat
			delay 1 -- give a bit of extra time for the interface to update
			click (first button whose name is "Connect")
			repeat until (exists (first button whose name is "Disconnect"))
				delay 1
			end repeat
			delay 1 -- give a bit of extra time for the interface to update
		end tell
	end tell
end tell

tell application "System Preferences"
	quit
end tell

