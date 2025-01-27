import json
import pyautogui

class CursorController:
    def __init__(self):
        pass

    def move_cursor(self, delta_x, delta_y):
        pyautogui.move(delta_x, delta_y)

    def handle_message(self, message):
        try:
            data = json.loads(message)
            delta_x = data.get("deltaX", 0)
            delta_y = data.get("deltaY", 0)
            self.move_cursor(delta_x, delta_y)
        except Exception as e:
            print(f"Error processing message: {e}")