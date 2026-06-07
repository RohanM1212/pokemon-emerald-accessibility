import pyttsx3
import time
import os

QUEUE_FILE = r"C:\Users\rmukh\Desktop\pokemon-accessibility-dev\speech_queue.txt"

engine = pyttsx3.init()
engine.setProperty('rate', 150)
engine.setProperty('volume', 1.0)

print("Visual Impairment Speech Reader running.")
print("Waiting for game events...")

def read_and_speak():
    if not os.path.exists(QUEUE_FILE):
        return
        
    with open(QUEUE_FILE, 'r') as f:
        lines = f.readlines()
    
    if not lines:
        return
    
    with open(QUEUE_FILE, 'w') as f:
        f.write('')
    
    for line in lines:
        text = line.strip()
        if text:
            print(f"Speaking: {text}")
            engine.say(text)
            engine.runAndWait()

while True:
    try:
        read_and_speak()
        time.sleep(0.1)
    except KeyboardInterrupt:
        print("Stopped.")
        break
    except Exception as e:
        print(f"Error: {e}")
        time.sleep(1)