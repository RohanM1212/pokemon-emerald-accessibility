import pyttsx3
import time
import os

QUEUE_FILE = "C:/Users/rmukh/Desktop/pokemon-accessibility-dev/speech_queue.txt"

print("Visual Impairment Speech Reader running.")
print("Waiting for game events...")

def speak_one(text):
    # one fresh engine per line — most reliable against pyttsx3's
    # tendency to only play the first utterance in a queue/session
    engine = pyttsx3.init()
    engine.setProperty('rate', 150)
    engine.setProperty('volume', 1.0)
    engine.say(text)
    engine.runAndWait()
    engine.stop()

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
            speak_one(text)   # fresh engine, one utterance, every line

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