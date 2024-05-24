#!/bin/bash

# Function to display the menu
show_menu() {
    echo "---------------------------"
    echo "       Main Menu"
    echo "---------------------------"
    echo "1. Initialize instance (without installing) "
    echo "2. Initialize first time instance (install fooocus and requirements)"
    echo "3. Clone install fooocus"
    echo "4. Install lora"
    echo "5. Install model"
    echo "6. Run Fooocus"
    echo "7. Kill and run fooocus async"
    echo "0. Exit"
    echo "---------------------------"
    echo -n "Please enter your choice (0-6): "
}

# Function to display the date and time
initialize_instance() {
    apt-get update
    apt-get install nano
    apt-get install lsof
    kill_run_fooocus_api_async
}

initialize_instance_first_time() {
    apt-get update
    apt-get install nano
    apt-get install lsof
    clone_install_fooocus_api
    kill_run_fooocus_api_async
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
        
    python main.py --port $FOOOCUS_PORT --host 0.0.0.0 --base-url $FOOOCUS_URL
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
    nohup python main.py --port $FOOOCUS_PORT --host 0.0.0.0 --base-url $FOOOCUS_URL > output.log &
}

# Main loop to display the menu and get user input
while true; do
    show_menu
    read choice
    case $choice in
        1)
            initialize_instance
            ;;
        2)
            initialize_instance_first_time
            ;;
        3)
            clone_install_fooocus_api
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