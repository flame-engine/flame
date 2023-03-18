from psutil import process_iter
from signal import SIGTERM # or SIGKILL

for proc in process_iter():
    for conns in proc.connections(kind='inet'):
        if conns.laddr.port == 8000:
            proc.send_signal(SIGTERM) # or SIGKILL