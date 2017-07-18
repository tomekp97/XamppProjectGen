$host.ui.RawUI.WindowTitle = "WordPress Project Setup" 
write-host `n
write-host "Welcome to the WordPress Project Setup" 
write-host "This program will set up a basic WordPress installation with the ability to use SASS on your localhost (XAMPP)."
write-host `n
write-host "The program will:"
write-host "    1) Look for htdocs in your XAMPP folder wherever it may be."
write-host "    2) Detect the projects directory (author and god-king of this program recommends a /Work directory to be used in order to store all of your job projects). `n       If /Work is not detected, it will be created automatically OR you'll be able to create your own folder."
write-host "    3) Let you create your project/job folder."
write-host "    4) Download a basic WordPress installation into your project/job folder."
write-host "    5) Install SASS onto your machine if it's not installed already."
write-host "    6) Compile SCSS files into one file and set up 'sass -watch'."
# Program begins
write-host `n
read-host -prompt "Press Enter to continue"
write-host `n
# Creates downloading function
function download($url, $outputTo) {
    $webclient = New-Object System.Net.WebClient
    $webclient.DownloadFile($url,$outputTo)
}
# Creates unzipping functionality
function unzip($file, $destination) {
    $shell = new-object -com shell.application
    $zip = $shell.namespace($file)
    foreach($item in $zip.items()) {
        $shell.namespace($destination).copyhere($item)
    }
}
# Only get drives that actually has content
$drives = get-wmiobject win32_logicaldisk | where {$_.FreeSpace}
# Used to check if there's more than 1 drive containing /xampp 
$valid_drive = @()
$no_of_drives = 0
$bg_colour = "green"
$fg_colour = "black"
foreach ($drive in $drives) {
    $drive_name = $drive.DeviceID
    $xampp_path = "$drive_name\xampp"
    write-host "Checking drive $drive_name" -foregroundcolor "yellow"
    if (test-path $xampp_path) {
        $no_of_drives++
        if ($no_of_drives -gt 1) {
            $bg_colour = "darkred"
            $fg_colour = "white"
        }
        write-host "XAMPP folder found!" -backgroundcolor "$bg_colour" -foregroundcolor "$fg_colour"
        $valid_drive += "$drive_name"
        $use_this_path = $xampp_path
    }
    else {
        write-host "XAMPP folder not found." -backgroundcolor "gray" -foregroundcolor "black"
    }
    write-host `n
}
# Check if correct number of disks have /xampp
if ($valid_drive.Length -gt 1) {
    write-host `n
    write-host "More than 1 drive has the folder /xampp!"
    write-host "These are the drives where the folder /xampp exists:"
    write-host "================"
    $valid_drive
    write-host "================"
    write-host "Please delete /xampp from one of the listed drives and re-start the program."
    write-host `n
    read-host -prompt "Press Enter to quit"
}
elseif ($valid_drive.Length -lt 1) {
    write-host `n
    write-host "Couldn't find /xampp anywhere."
    write-host "Make sure you have XAMPP installed on your machine, then re-start the program."
    write-host `n
    read-host -prompt "Press Enter to quit"
}
else {
    # User specification variable comes into play when there are the /Work and /$work_dir_var direcotries present
    $user_specified = [Environment]::GetEnvironmentVariable("USER_SPECIFIED", "User")
    if (!$user_specified) {
        [Environment]::SetEnvironmentVariable("USER_SPECIFIED","FALSE","User")
        $user_specified = [Environment]::GetEnvironmentVariable("USER_SPECIFIED", "User")
    }
    # Check if WORK_DIR exists already, if not - set it.
    $work_dir_var = [Environment]::GetEnvironmentVariable("WORK_DIR", "User")
    if (!$work_dir_var) {
        [Environment]::SetEnvironmentVariable("WORK_DIR","Work","User")
        $work_dir_var = [Environment]::GetEnvironmentVariable("WORK_DIR", "User")
    }
    else {
        
    }
    write-host `n
    write-host "=========== Using the $valid_drive drive ==========="
    set-location -path "$use_this_path\htdocs"
    # Check if /Work exists or whether a project folder of the same name as the previously set Environment Variable exists in the current directory.
    if (($user_specified -eq "FALSE") -and (test-path "work") -and (($work_dir_var -ne "Work") -and (test-path "$work_dir_var"))) {
        write-host `n
        write-host "DISCREPANCY!" -backgroundcolor "red"
        write-host "============================="
        write-host "Folders detected:"
        write-host "/Work" -foregroundcolor "yellow" -nonewline
        write-host " (Default projects directory)" -foregroundcolor "green"
        write-host "/$work_dir_var" -foregroundcolor "yellow" -nonewline
        write-host " (User specified projects directory)" -foregroundcolor "green"
        write-host "============================="
        write-host `n
        do {
            # Choose folder
            $ultimate_choice = read-host -prompt "Which folder would you like to ultimately define as YOUR project directory?`n[1] - /Work`n[2] - /$work_dir_var"
            write-host `n
        }
        while ($ultimate_choice -eq [string]::empty)

        if ($ultimate_choice -eq 1) {
            [Environment]::SetEnvironmentVariable("USER_SPECIFIED","TRUE","User")
            [Environment]::SetEnvironmentVariable("WORK_DIR","Work","User")
            $work_dir_var = [Environment]::GetEnvironmentVariable("WORK_DIR", "User")
            write-host "You have ultimately defined " -nonewline
            write-host $work_dir_var -foregroundcolor "yellow" -nonewline
            write-host " as your projects directory."
            write-host `n
            set-location "work" | out-null
        }
        elseif ($ultimate_choice -eq 2) {
            [Environment]::SetEnvironmentVariable("USER_SPECIFIED","TRUE","User")
            write-host "You have ultimately defined " -nonewline
            write-host $work_dir_var -foregroundcolor "yellow" -nonewline
            write-host " as your projects directory."
            write-host `n
            set-location "$work_dir_var" | out-null
        }
        
    }
    elseif ((test-path "work") -and ($work_dir_var -eq "Work")) {
        set-location -path "work" | out-null
    }
    # This is the elseif that detectes if the permanent required folder (which would've been /Work by default) exists the Environment Variable value.
    elseif (($work_dir_var) -and (test-path "$work_dir_var")) {
        set-location -path "$work_dir_var" | out-null
    }
    else {
        $message  = ">> Couldn't find the /Work or any other projects folder in /xampp/htdocs."
        $question = ">> Do you want the program to generate the /Work directory?`n`n"
        $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes, generate the /Work directory.'))
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No, I want to create my own projects directory.'))
        $decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)
        if ($decision -eq 0) {
            new-item -itemtype directory Work | out-null
            write-host `n
            write-host '>> /Work directory created!'
            set-location -path "work" | out-null
            write-host `n
        } 
        else {
            do {
                write-host `n
                $folder_name = read-host -prompt "Enter the name of your projects directory"
                $question = read-host -prompt "Are you sure you want to name your projects directory: '$folder_name'? [Y/N]`n"
            } 
            while (($question -ne "y") -or (!$question))
            new-item -itemtype directory $folder_name | out-null
            write-host `n
            write-host ">> '$folder_name' directory created!"
            set-location -path "$folder_name" | out-null
            # Set WORK_DIR to $folder_name so it can be the default folder this program referes to instead of 
            [Environment]::SetEnvironmentVariable("WORK_DIR","$folder_name","User")
            $work_dir_var = [Environment]::GetEnvironmentVariable("WORK_DIR", "User")
            write-host `n
        }
    }
}

# Making of individual projects
if ($work_dir_var) {
    do {
        $create_project = read-host -prompt "Now it's time to create a project.`nDo you want to do this now? [Y/N]"
        write-host `n
    }    
    while ($create_project -eq [string]::empty)

    if ($create_project -eq "n") {
        write-host "OK! Feel free to use this program to create a project at a later date, or do it yourself manually.`n"
        read-host -prompt "Press Enter to exit"
        write-host `n
        exit
    }
    elseif ($create_project -eq "y") {
        do {
            $project_name = read-host -prompt "Name of your project"
            $confirm_project_name = read-host -prompt "Are you sure you want to name your project '$project_name'? [Y/N]"
            write-host `n
        }
        while (($confirm_project_name -ne "y") -or (!$confirm_project_name))
        new-item -itemtype directory $project_name | out-null
        write-host `n
        write-host ">> Project '$project_name' created!"
        set-location -path "$project_name" | out-null
        write-host `n
		write-host ">> Checking if Ruby is installed..." -foregroundcolor "yellow"
		# Temporarily disable red errors if the command "ruby -v"doesn't exist.
		$ErrorActionPreference= 'silentlycontinue'
		$ruby = ruby -v
		# See if last operation returns TRUE
		if ($?) {
			$ErrorActionPreference= 'continue'
			write-host ">> Ruby is already installed on your machine!" -backgroundcolor "green" -foregroundcolor "black"
            # Install SASS via Ruby
            $sass = sass -v
            if ($?) {
                $ErrorActionPreference= 'continue'
                write-host ">> SASS already installed on your machine!" -backgroundcolor "green" -foregroundcolor "black"
            }
            else {
                write-host ">> Installing SASS..." -foregroundcolor "yellow"
                $sass = gem install sass
                write-host ">> SASS successfully installed!" -backgroundcolor "green" -foregroundcolor "black"
                $sass = sass -v
            }
		}
		else {
            $ErrorActionPreference= 'continue'
			write-host ">> Ruby not installed!" -backgroundcolor "darkred"
            write-host `n
			$message  = ""
			$question = "Do you want the program to download Ruby?`n`n"
			$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
			$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes, download it for me.'))
			$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No, I really want to download it myself, manually!'))
			$decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)
			write-host `n
			# Download or exit based on $decision
			if ($decision -eq 0) {
                new-item -itemtype directory -path $home/desktop/xpg-downloads-temp -force | out-null
				$OS = get-wmiobject win32_operatingsystem
				if ($OS.OSArchitecture -eq "64-bit") {
					# 64-bit
                    write-host ">> Downloading Ruby (64-bit)..." -foregroundcolor "yellow"
                    download -url "https://github.com/oneclick/rubyinstaller2/releases/download/2.4.1-2/rubyinstaller-2.4.1-2-x64.exe" -outputTo "$home\Desktop\xpg-downloads-temp\rubyinstaller.exe"
                    write-host ">> Download complete!" -foregroundcolor "green"
				}
				else {
					# 32-bit
                    write-host ">> Downloading Ruby (32-bit)..." -foregroundcolor "yellow"
                    download -url "https://github.com/oneclick/rubyinstaller2/releases/download/2.4.1-2/rubyinstaller-2.4.1-2-x86.exe" -outputTo "$home\Desktop\xpg-downloads-temp\rubyinstaller.exe"
                    write-host ">> Download complete!" -foregroundcolor "green"
				}
                # Check if user wants to auto run the downloaded Ruby installer
                do {
                    write-host `n
                    $run_ruby_install = read-host -prompt ">> Do you want to auto-run the Ruby installer? [Y/N]"
                }
                while (($run_ruby_install -eq [string]::empty))
                
                if ($run_ruby_install -eq "y") {
                    write-host ">> Running Ruby installation..." -foregroundcolor "yellow"
                    & "$home\Desktop\xpg-downloads-temp\rubyinstaller.exe"
                    $process = "rubyinstaller"
                    # Keep script running until Ruby installaion finishes
                    do {
                        $process_running = get-process | ? {$process -contains $_.Name} | select-object -expandproperty Name
                        if ($process_running)  {
                            start-sleep -s 1
                        }
                    } until (!$process_running)
                    remove-item "$home\desktop\xpg-downloads-temp" -recurse
                    write-host ">> Ruby installation finished" -foregroundcolor "yellow"
                    write-host ">> Checking if Ruby installed correctly..." -foregroundcolor "yellow"
                    # Update this PowerShell session's knowledge of newly acquired Ruby commands
                    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                    # Once again disable red errors coming up when "ruby -v" is not detected as aviable commad
                    $ErrorActionPreference= 'silentlycontinue'
                    $ruby = ruby -v
                    if ($?) {
                        write-host ">> Ruby successfully installed!" -backgroundcolor "green" -foregroundcolor "black"
                        # Install SASS via Ruby
                        $sass = sass -v
                        if ($?) {
                            $ErrorActionPreference= 'continue'
                            write-host ">> SASS already installed on your machine!" -backgroundcolor "green" -foregroundcolor "black"
                        }
                        else {
                            write-host ">> Installing SASS..." -foregroundcolor "yellow"
                            $sass = gem install sass
                            write-host ">> SASS successfully installed!" -backgroundcolor "green" -foregroundcolor "black"
                            $sass = sass -v
                        }
                    }
                    else {
                        # Enable errors again
                        $ErrorActionPreference= 'continue'
                        write-host ">> Ruby installation failed!" -backgroundcolor "darkred"
                    }
                }
                else {
                    write-host `n
                    write-host ">> OK, fine, install Ruby yourself. After that relaunch the script."
                    read-host -prompt "Press Enter to exit"
                }
			}
			else {
				write-host ">> Alright, do it yourself."
				write-host ">> Bye!" -foregroundcolor "darkred"
                read-host -prompt "Press Enter to exit"
			}
		}
    }
}

# Continue to WordPress install
$ErrorActionPreference = "silentlycontinue"
if (($ruby) -and ($sass)) {
    $ErrorActionPreference = "continue"
    write-host `n
    $message  = ">> It's time to set up WordPress for your project."
    $question = ">> Do you want the program to download WordPress for you?`n`n"
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes, download it please!.'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No, it would mean a lot to me if I could download the files manually.'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)
    write-host `n
    if ($decision -eq 0) {
        $cd = get-location | select -expandproperty Path
        write-host ">> Downloading WordPress..."-foregroundcolor "yellow"
        download -url "https://en-gb.wordpress.org/wordpress-4.8-en_GB.zip" -outputTo "$cd\wordpress.zip"
        write-host ">> WordPress download complete!" -foregroundcolor "green"
        write-host ">> Unzipping WordPress..." -foregroundcolor "yellow"
        # Unzip WordPress
        unzip -file "$cd\wordpress.zip" -destination "$cd ."
        move-item "$cd\wordpress\*" "$cd"
        write-host ">> Unzipping completed!" -foregroundcolor "green"
        remove-item "$cd\wordpress";remove-item "$cd\wordpress.zip"
    } 
    else {
        write-host n
        write-host "Fine download it yourself...but make sure to restart the script afterwards,`nunless you want to do the rest of the stuff yourself too!"
        read-host -prompt "Press Enter to exit"
    }
}
else {
    $ErrorActionPreference = "continue"
}

# SASS compilation
if (test-path "wp-admin") {
    $theme = "twentyseventeen"
    set-location "wp-content/themes"
    do {
        write-host `n
        $rename_theme = read-host -prompt "Would you like to rename the WordPress 'twentyseventeen' theme folder? [Y/N]"
    }
    while (($rename_theme -eq [string]::empty) -or (($rename_theme -ne "y") -and ($rename_theme -ne "n")))
    if ($rename_theme -eq "y") {
        do {
            write-host `n
            $newname_theme = read-host -prompt "Enter the new theme name"
            $decision = read-host -prompt "Are you sure you want to rename the theme to '$newname_theme'? [Y/N]"
        }
        while (($decision -eq [string]::empty) -or (($decision -ne "y") -and ($decision -eq "n")))
        if ($decision -eq "y") {
            $theme = $newname_theme
            rename-item "twentyseventeen" "$newname_theme"
            write-host `n
            write-host ">> Folder 'twentyseventeen' renamed to '$newname_theme'" -foregroundcolor "green"
            write-host `n
        }
    }
    set-location "$theme" | out-null
}