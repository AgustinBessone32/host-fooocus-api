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
    echo "7. Kill and run fooocus async"
    echo "8. Get ngrok public endpoint"
    echo "9. Config env var"
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

config_env_var() {
    apt-get update
    apt-get upgrade
    apt-get install nano

    echo "NGROK AUTH TOKEN:"
    read NGROK_AUTH_TOKEN_INPUT

    echo "FOOOCUS_API:"
    read FOOOCUS_PORT_INPUT

    sh -c 'echo "$NGROK_AUTH_TOKEN=$NGROK_AUTH_TOKEN_INPUT" >> /etc/environment'
    sh -c 'echo "$FOOOCUS_API=$FOOOCUS_PORT_INPUT" >> /etc/environment'
}

# Function to display the current directory
kill_run_ngrok() {
    pip install pyngrok
    NGROK_PIDS=$(pgrep ngrok)
    
    # Verificar si se encontraron procesos ngrok
    if [ -n "$NGROK_PIDS" ]; then
        echo "Terminando los procesos existentes de ngrok con PIDs: $NGROK_PIDS"
        
        # Iterar sobre cada PID y matar el proceso
        for PID in $NGROK_PIDS; do
            kill $PID
        done
        
        # Dar un segundo para que los procesos terminen
        sleep 1
        
        # Verificar si todos los procesos fueron terminados
        REMAINING_PIDS=$(pgrep ngrok)
        if [ -z "$REMAINING_PIDS" ]; then
            echo "Todos los procesos ngrok fueron terminados correctamente."
        else
            echo "No se pudieron terminar algunos procesos ngrok: $REMAINING_PIDS"
        fi
    else
        echo "No se encontraron procesos ngrok ejecutándose."
    fi
    ngrok config add-authtoken $NGROK_AUTH_TOKEN
    ngrok http $FOOOCUS_PORT > /dev/null &
    sleep 20
    curl -s http://localhost:4040/api/tunnels | grep -oP '"public_url":"\K[^"]+'
}

# Function to display disk usage
install_lora() {
    echo "Lora file name:"
    read filename
    echo "Lora file url:"
    read fileurl
    wget -O /workspace/Fooocus-API/repositories/Fooocus/models/loras/$filename $fileurl
    echo "$filename installed succesfully"
    echo "--------------------------------------------------------------------------------------------------------------"
    echo "LORAS AVAILABLES"
    ls /workspace/Fooocus-API/repositories/Fooocus/models/loras
}

install_model() {
    echo "Model file name:"
    read filename
    echo "Model file url:"
    read fileurl
    wget -O /workspace/Fooocus-API/repositories/Fooocus/models/checkpoints/$filename $fileurl
    echo "$filename installed succesfully"
    echo "--------------------------------------------------------------------------------------------------------------"
    echo "MODELS AVAILABLES"
    ls /workspace/Fooocus-API/repositories/Fooocus/models/checkpoints
}

run_fooocus_api_sync() {
    echo "Running fooocus api SYNC MODE:"
    cd /workspace/Fooocus-API/
    python main.py --port $FOOOCUS_PORT
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
    cd /workspace/Fooocus-API/
    nohup python main.py --port $FOOOCUS_PORT > output.log 2>&1 &
}

get_ngrok_public() {
    echo "NGROK PUBLIC PATH"
    curl -s http://localhost:4040/api/tunnels | grep -oP '"public_url":"\K[^"]+'
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
            run_fooocus_api_sync
            ;;
        7)
            kill_run_fooocus_api_async
            ;;       
        8)
            get_ngrok_public
            ;;            
        9)
            config_env_var
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