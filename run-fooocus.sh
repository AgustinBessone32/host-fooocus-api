#!/bin/bash

# Function to display the menu
show_menu() {
    echo "---------------------------"
    echo "       Main Menu"
    echo "---------------------------"
    echo "1. Run ALL steps"
    echo "2. Clone fooocus and install requirements"
    echo "3. Kill and Run ngrok"
    echo "4. Install lora"
    echo "5. Install model"
    echo "6. Run Fooocus"
    echo "0. Exit"
    echo "---------------------------"
    echo -n "Please enter your choice (0-6): "
}

# Function to display the date and time
run_all_steps() {
    echo "The current date and time is: $(date)"
}

# Function to list files in the current directory
clone_install_fooocus_api() {
    cd /workspace
    echo echo "Cloning fooocus api in workspace"
    git clone https://github.com/mrhan1993/Fooocus-API.git
    cd Fooocus-API
    echo echo "Installing requirements"
    pip install -r requirements.txt
}

# Function to display the current directory
kill_run_ngrok() {
    pip install pyngrok
    NGROK_PID=$(pgrep ngrok)
    if [ -n "$NGROK_PID" ]; then
        echo "Terminando el proceso existente de ngrok con PID: $NGROK_PID"
        kill $NGROK_PID
        sleep 1  # Dar un segundo para que el proceso termine
    fi
    python ngrok.py
}

# Function to display disk usage
install_lora() {
    echo "Lora file name:"
    read filename
    echo "Lora file url:"
    read fileurl
    wget -O /workspace/Fooocus-API/repositories/Fooocus/models/loras/$filename $fileurl

    #wget -O /workspace/Fooocus-API/repositories/Fooocus/models/loras/add-detail-xl.safetensors https://civitai.com/api/download/models/135867
    echo "$filename installed succesfully"
}

install_model() {
    echo "Model file name:"
    read filename
    echo "Model file url:"
    read fileurl
    wget -O "/workspace/Fooocus-API/repositories/Fooocus/models/checkpoints/$filename" "$URL"
    echo "$filename installed succesfully"
}

run_fooocus_api_sync() {
    echo "Running fooocus api SYNC MODE:"
    python main.py
}

kill_run_fooocus_api_async() {
    echo "Running fooocus api SYNC MODE:"
    PID=$(lsof -t -i:$FOOOCUS_PORT)
    if [ -n "$PID" ]; then
        echo "Terminando el proceso con PID: $PID en el puerto: $FOOOCUS_PORT"
        kill -9 $PID
    else
        echo "No se encontró ningún proceso escuchando en el puerto $PORT."
    fi
    nohup python main.py > output.log 2>&1 &
}

# Main loop to display the menu and get user input
while true; do
    show_menu
    read choice
    case $choice in
        1)
            run_all_steps
            ;;
        2)
            clone_install_fooocus_api
            ;;
        3)
            kill_run_ngrok
            ;;
        4)
            install_lora
            ;;
        5)
            install_model
            ;;    
        6)
            run_fooocus_api
            ;;
        6)
            kill_run_fooocus_api_async
            ;;             
        0)
            echo "Exiting the program. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
    echo ""
done