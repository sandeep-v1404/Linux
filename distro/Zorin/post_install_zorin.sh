#!/bin/bash

#----- Fancy Messages -----#
#  Credits: snwh/solus-post-install

show_error() {
    echo -e "\033[1;31m$@\033[m" 1>&2
}

show_info() {
    echo -e "\033[1;32m$@\033[0m"
}

show_warning() {
    echo -e "\033[1;33m$@\033[0m"
}

show_question() {
    echo -e "\033[1;34m$@\033[0m"
}

show_success() {
    echo -e "\033[1;35m$@\033[0m"
}

show_header() {
    echo -e "\033[1;36m$@\033[0m"
}

show_listitem() {
    echo -e "\033[0;37m$@\033[0m"
}

after_install() {
    show_success "\n\n$* : Installed Successfully\n"
    echo -e "------------------------------------------\n\n"
}

banner() {
    printf "\n\n\n"
    msg="| $* |"
    edge=$(echo "$msg" | sed 's/./-/g')
    show_error "$edge"
    show_info "$msg"
    show_error "$edge"
}

pause() {
    read -s -n 1 -p "Press any key to continue . . ."
    clear
}

install_Neofetch() {
    banner "Installing Neofetch"
    sudo apt install neofetch -y
    after_install "neofetch"
}

install_Git() {
    banner "Installing Git"
    sudo apt install neofetch -y
    after_install "Git - Version Control System"
}

install_Xclip() {
    banner "Installing xclip"
    sudo apt install xclip -y
    after_install "xclip"
}

install_Xkill() {
    banner "Installing xkill"
    sudo apt install xkill -y
    after_install "xkill"
}

gitsetup() {
    banner "Setting up SSH for git and GitHub"

    read -e -p "Enter your GitHub Username                 : " GITHUB_USERNAME
    read -e -p "Enter the GitHub Email Address             : " GITHUB_EMAIL_ID
    read -e -p "Enter the default git editor (vim / nano)  : " GIT_CLI_EDITOR

    if [[ $GITHUB_EMAIL_ID != "" && $GITHUB_USERNAME != "" && $GIT_CLI_EDITOR != "" ]]; then
        printf "\n - Configuring GitHub username as: ${GITHUB_USERNAME}"
        git config --global user.name "${GITHUB_USERNAME}"

        printf "\n - Configuring GitHub email address as: ${GITHUB_EMAIL_ID}"
        git config --global user.email "${GITHUB_EMAIL_ID}"

        printf "\n - Configuring Default git editor as: ${GIT_CLI_EDITOR}"
        git config --global core.editor "${GIT_CLI_EDITOR}"

        printf "\n - Setting up the defaults for git pull"
        git config --global pull.rebase false

        printf "\n - The default branch name for new git repos will be: main"
        git config --global init.defaultBranch main

        printf "\n - Generating a new SSH key for ${GITHUB_EMAIL_ID}"
        printf "\n\nJust press Enter and add passphrase if you'd like to. \n\n"
        ssh-keygen -t ed25519 -C "${GITHUB_EMAIL_ID}"

        printf "\n\nAdding your SSH key to the ssh-agent..\n"

        printf "\n - Start the ssh-agent in the background..\n"
        eval "$(ssh-agent -s)"

        printf "\n\n - Adding your SSH private key to the ssh-agent\n\n"
        ssh-add ~/.ssh/id_ed25519

        printf "\n - Copying the SSH Key Content to the Clipboard..."

        printf "\n\nLog in into your GitHub account in the browser (if you have not)"
        printf "\nOpen this link https://github.com/settings/keys in the browser."
        printf "\nClik on New SSH key."
        xclip -selection clipboard <~/.ssh/id_ed25519.pub
        printf "\nGive a title for the SSH key."
        printf "\nPaste the clipboard content in the textarea box below the title."
        printf "\nClick on Add SSH key.\n\n"
        pause
    else
        printf "\nYou have not provided the details correctly for Git Setup."
        if ask_user "Want to try Again ?"; then
            gitsetup
        else
            printf "\nSkipping: Git and GitHub SSH setup..\n"
        fi
    fi
}

install_Sublime_Text() {
    banner "Installing Sublime Text"
    show_question "\nDownloading Sublime Text Build 4113\n"
    wget -O ~/Downloads/sublime.tar.xz 'https://download.sublimetext.com/sublime_text_build_4126_x64.tar.xz'

    show_question "\nCreating a directory to install Sublime Text.."
    if [ -d ~/.LEO ]; then
        show_warning "\nDirectory exists.\nSkipping the creation step..\n"
    else
        mkdir -p ~/.LEO
    fi

    show_info "\nExtracting the downloaded file...\n"
    tar -xf ~/Downloads/sublime.tar.xz -C ~/.LEO

    currentUser=$(whoami)

    show_info "\nCreating a Desktop Entry for Sublime Text.\n"
    {
        echo "[Desktop Entry]"
        echo "Version=1.0"
        echo "Type=Application"
        echo "Name=Sublime Text"
        echo "GenericName=Text Editor"
        echo "Comment=Sophisticated text editor for code, markup and prose"
        echo "Exec=/home/${currentUser}/.LEO/sublime_text/sublime_text %F"
        echo "Terminal=false"
        echo "MimeType=text/plain;"
        echo "Icon=/home/${currentUser}/.LEO/sublime_text/Icon/256x256/sublime-text.png"
        echo "Categories=TextEditor;Development;"
        echo "StartupNotify=true"
        echo "Actions=new-window;new-file;"

        echo "[Desktop Action new-window]"
        echo "Name=New Window"
        echo "Exec=/home/${currentUser}/.LEO/sublime_text/sublime_text --launch-or-new-window"
        echo "OnlyShowIn=Unity;"

        echo "[Desktop Action new-file]"
        echo "Name=New File"
        echo "Exec=/home/${currentUser}/.LEO/sublime_text/sublime_text --command new_file"
        echo "OnlyShowIn=Unity;"
    } | sudo tee /usr/share/applications/sublime-text.desktop

    show_info "Creating Sybmbolic Link for Sublime Text\n\n"
    sudo ln -s ~/.LEO/sublime_text/sublime_text /usr/bin/subl

    show_info "Cleaning out the remnant files.."
    rm ~/Downloads/sublime.tar.xz

    after_install "Sublime Text"
}

install_Vim() {
    banner "Installing Vim"
    sudo apt install neovim -y
    after_install "vim"
}

install_Microsoft_Core_Fonts() {
    banner "Installing Microsoft Core Fonts"
    show_info "Downloading the Setup File..."
    sudo apt install -y ttf-mscorefonts-installer
    after_install "mscorefonts"
}

install_Discord_Manually() {
    banner "Installing discord tar file"

    show_info "Downloading discord tar file"
    wget -O ~/Downloads/discord.tar.gz 'https://discord.com/api/download?platform=linux&format=tar.gz'

    show_question "\nCreating a directory to install Discord"
    if [ -d ~/.LEO ]; then
        show_warning "\nDirectory exists.\nSkipping the creation step..\n"
    else
        mkdir -p ~/.LEO
    fi

    show_info "Extracting discord tar file"
    tar -xzf ~/Downloads/discord.tar.gz -C ~/.LEO

    show_info "Adding symbolic link on /usr/bin/Discord"
    sudo ln -sf ~/.LEO/Discord/Discord /usr/bin/Discord

    show_info "Copying discord.desktop to /usr/share/applications"
    sudo cp -r ~/.LEO/Discord/discord.desktop /usr/share/applications

    show_info "Adding executable file for discord.desktop"
    SUBJECT='/usr/share/applications/discord.desktop'
    SEARCH_FOR='Exec='
    sudo sed -i "/^$SEARCH_FOR/c\Exec=/usr/bin/Discord" $SUBJECT

    currentUser=$(whoami)
    show_info "Adding icon for discord.desktop"
    SEARCH_FOR='Icon='
    sudo sed -i "/^$SEARCH_FOR/c\Icon=/home/${currentUser}/.LEO/Discord/discord.png" $SUBJECT

    show_info "Removing the remnant files..."
    rm ~/Downloads/discord.tar.gz
}

uninstall_Discord() {
    banner "Uninstalling Discord..."

    show_info "Deleting Discord Config files..."
    sudo rm -r ~/.config/discord

    show_info "Removing all Discord application files..."
    sudo rm -rf ~/.LEO/Discord

    show_info "Removing the symbolic for the Discord binary file..."
    sudo rm /usr/bin/Discord

    show_info "Removing the desktop shortcut from the system..."
    sudo rm /usr/share/applications/discord.desktop

    show_success "\n\n$*Discord : Uninstalled Successfully\n"
    echo -e "------------------------------------------\n\n"
}

install_Fira_Code_Font() {
    banner "Installing Fira Code Font"
    sudo apt install fonts-firacode -y
    after_install "Fira Code Font"
}

install_Qbittorrent() {
    banner "Installing Qbittorrent"
    sudo apt install qbittorrent -y
    after_install "Qbittorrent"
}

update_Sublime_Text() {
    # Have to get the latest download link from the official website
    # https://www.sublimetext.com/download
    banner "Updating Sublime Text"

    show_info "Removing the existing Sublime Text Installation"
    rm -rf ~/.LEO/sublime_text/

    show_question "\nDownloading Sublime Text Build 4113\n"
    wget -O ~/Downloads/sublime.tar.xz 'https://download.sublimetext.com/sublime_text_build_4121_x64.tar.xz'

    show_info "\nExtracting the downloaded file...\n"
    tar -xf ~/Downloads/sublime.tar.xz -C ~/.LEO

    show_info "Cleaning out the remnant files.."
    rm ~/Downloads/sublime.tar.xz

    after_install "Sublime Text"
}

setup_Postman_API() {
    # References:
    # 1. https://morioh.com/p/e256fd7a2811
    # 2. https://www.tecmint.com/install-postman-on-linux-desktop/
    banner "Installing Postman API Desktop Client"

    show_question "\nDownloading the Latest version of Postman API\n"
    wget -O ~/Downloads/postman.tar.gz 'https://dl.pstmn.io/download/latest/linux64'

    show_question "\nCreating a directory to install Postman API.."
    if [ -d ~/.LEO ]; then
        show_warning "\nDirectory exists.\nSkipping the creation step..\n"
    else
        mkdir -p ~/.LEO
    fi

    show_info "\nExtracting the downloaded file...\n"
    tar -xzf ~/Downloads/postman.tar.gz -C ~/.LEO

    show_info "Creating Sybmbolic Link for Postman API\n\n"
    sudo ln -s ~/.LEO/Postman/Postman /usr/bin/postman

    currentUser=$(whoami)

    show_info "\nCreating a Desktop Entry for Postman\n"
    {
        echo "[Desktop Entry]"
        echo "Name=Postman"
        echo "GenericName=API Client"
        echo "X-GNOME-FullName=Postman API Client"
        echo "Comment=Make and view REST API calls and responses"
        echo "Keywords=api;"
        echo "Exec=/home/${currentUser}/.LEO/Postman/Postman"
        echo "Terminal=false"
        echo "Type=Application"
        echo "Icon=/home/${currentUser}/.LEO/Postman/app/resources/app/assets/icon.png"
        echo "Categories=Development;Utilities;"
    } | sudo tee /usr/share/applications/postman-client.desktop

    show_info "Removing the remnant files..."
    rm ~/Downloads/postman.tar.gz

    after_install "Postman API Client"
}

uninstall_Postman() {
    banner "Uninstalling Postman API Client..."

    show_info "Deleting Postman Config files..."
    sudo rm -r ~/.config/Postman

    show_info "Removing all application files..."
    sudo rm -rf ~/.LEO/Postman

    show_info "Removing the symbolic for the Postman Client binary file..."
    sudo rm /usr/bin/Postman

    show_info "Removing the desktop shortcut from the system..."
    sudo rm /usr/share/applications/postman-client.desktop

    show_success "\n\n$*Postman Client : Uninstalled Successfully\n"
    echo -e "------------------------------------------\n\n"
}

install_Heroku_CLI() {
    banner "Installing Heroku CLI"
    show_info "Getting the latest build using wget.."
    wget -O ~/Downloads/heroku.tar.gz 'https://cli-assets.heroku.com/heroku-linux-x64.tar.gz'

    show_question "\nCreating a directory to install heroku.."
    if [ -d ~/.LEO ]; then
        show_warning "\nDirectory exists.\nSkipping the creation step..\n"
    else
        mkdir -p ~/.LEO
    fi

    show_info "\nExtracting the downloaded file...\n"
    tar xf ~/Downloads/heroku.tar.gz -C ~/.LEO

    show_info "Creating symbolic link for heroku\n"
    sudo ln -s ~/.LEO/heroku/bin/heroku /usr/bin/heroku

    show_info "Cleaning out the remnant files.."
    rm ~/Downloads/heroku.tar.gz
}

uninstall_Heroku_CLI() {
    banner "Uninstalling Heroku CLI ..."

    show_info "Deleting Heroku CLI Config files..."
    rm -rf ~/.local/share/heroku/

    show_info "Deleting Heroku CLI cache files..."
    rm -rf ~/.cache/heroku/

    show_info "Removing all application files..."
    sudo rm -rf ~/.LEO/heroku

    show_info "Removing the symbolic for the Heroku CLI binary file..."
    sudo rm /usr/bin/heroku

    show_success "\n\n$* Heroku CLI : Uninstalled Successfully\n"
    echo -e "------------------------------------------\n\n"
}

configure_title_bar() {
    banner "Configure Title Bar"
    show_info "Showing Battery Percentage"
    gsettings set org.gnome.desktop.interface show-battery-percentage true

    show_success "Show Time in 12 hour format"
    gsettings set org.gnome.desktop.interface clock-format 12h

    show_success "Show Date in the top bar"
    gsettings set org.gnome.desktop.interface clock-show-date true

    show_success "Show the seconds in Clock"
    gsettings set org.gnome.desktop.interface clock-show-seconds true

    show_success "Show the Weekday in Clock"
    gsettings set org.gnome.desktop.interface clock-show-weekday true

    show_success "Adding Minimize and Maximize buttons on the left"
    gsettings set org.gnome.desktop.wm.preferences button-layout "close,maximize,minimize:"
}

install_Telegram_Manually() {
    banner "Installing Telegram Desktop"

    show_question "\nDownloading the Latest version of Telegram\n"
    wget -O ~/Downloads/tsetup.tar.xz 'https://telegram.org/dl/desktop/linux'

    show_question "\nCreating a directory to install Telegram.."
    if [ -d ~/.LEO ]; then
        show_warning "\nDirectory exists.\nSkipping the creation step..\n"
    else
        mkdir -p ~/.LEO
    fi

    show_info "\nExtracting the downloaded file...\n"
    tar -xJf ~/Downloads/tsetup.tar.xz -C ~/.LEO

    currentUser=$(whoami)

    show_info "Creating Symbolic Link for Telegram Desktop"
    sudo ln -s /home/${currentUser}/.LEO/Telegram/Telegram /usr/bin/telegram-desktop

    show_info "\nCreating a Desktop Entry for Telegram Desktop.\n"
    {
        echo "[Desktop Entry]"
        echo "Version=1.0"
        echo "Name=Telegram Desktop"
        echo "Comment=Official desktop version of Telegram messaging app"
        echo "TryExec=telegram-desktop"
        echo "Exec=telegram-desktop -- %u"
        echo "Icon=telegram"
        echo "Terminal=false"
        echo "StartupWMClass=TelegramDesktop"
        echo "Type=Application"
        echo "Categories=Chat;Network;InstantMessaging;Qt;"
        echo "MimeType=x-scheme-handler/tg;"
        echo "Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;"
        echo "Actions=Quit;"
        echo "X-GNOME-UsesNotifications=true"
        echo "X-GNOME-SingleWindow=true"
        echo ""
        echo "[Desktop Action Quit]"
        echo "Exec=telegram-desktop -quit"
        echo "Name=Quit Telegram"
        echo "Icon=application-exit"
    } | tee ~/.local/share/applications/telegramdesktop.desktop

    show_info "Cleaning out the remnant files.."
    rm ~/Downloads/tsetup.tar.xz

    after_install "Telegram Desktop"
}

uninstall_Telegram() {
    banner "Uninstalling Telegram..."

    show_info "Deleting Telegram Config Files..."
    rm -rf ~/.local/share/TelegramDesktop/

    show_info "Removing all Telegram application files..."
    rm -rf ~/.LEO/Telegram

    show_info "Removing the symbolic for the Telegram binary file..."
    sudo rm /usr/bin/telegram-desktop

    show_info "Removing the desktop shortcut from the system..."
    rm ~/.local/share/applications/telegramdesktop.desktop

    show_success "\n\n$*Telegram Desktop : Uninstalled Successfully\n"
    echo -e "------------------------------------------\n\n"
}

install_Pip() {
    banner "Installing PIP and VENV"
    sudo apt install -y python3-pip python3-venv
    after_install "Pip and virtual env"
}

install_YoutubeDL() {
    banner "Installing Youtube-DL"
    sudo apt install -y youtube-dl
    after_install "youtube-dl"
}

install_Spotify() {
    banner "Installing Spotify"

    show_header "Getting the GPG keys..."
    curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add - 

    show_info "Adding Spotify Repos to the sources list..."
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

    show_info "Update the package list"
    sudo apt update

    show_info "Installing the Spotify Client"
    sudo apt install spotify-client -y

    after_install "Spotify"
}
