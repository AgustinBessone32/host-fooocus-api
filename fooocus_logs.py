from flask import Flask, Response
import os
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import threading

app = Flask(__name__)
log_file_path = 'path_to_your_log_file.log'
log_data = ""

class LogHandler(FileSystemEventHandler):
    def __init__(self):
        super().__init__()
        self.lock = threading.Lock()

    def on_modified(self, event):
        if event.src_path == log_file_path:
            with self.lock:
                global log_data
                with open(log_file_path, 'r') as file:
                    log_data = file.read()

def start_watching():
    event_handler = LogHandler()
    observer = Observer()
    observer.schedule(event_handler, path=os.path.dirname(log_file_path), recursive=False)
    observer.start()
    observer.join()

@app.route('/logs')
def stream_logs():
    def generate():
        last_position = 0
        while True:
            global log_data
            with log_handler.lock:
                current_position = len(log_data)
                if current_position != last_position:
                    yield log_data[last_position:]
                    last_position = current_position
    return Response(generate(), mimetype='text/plain')

if __name__ == '__main__':
    log_handler = LogHandler()
    watch_thread = threading.Thread(target=start_watching)
    watch_thread.daemon = True
    watch_thread.start()
    app.run(port=5000, debug=True)