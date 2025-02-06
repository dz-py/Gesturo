import json
from pynput.mouse import Controller

class CursorController:
    
    def __init__(self):
        self.mouse = Controller()

    def move_cursor(self, delta_x, delta_y):
        self.mouse.move(delta_x, delta_y)

    def handle_message(self, message):
        try:
            data = json.loads(message)  
            if isinstance(data, list):  
                for movement in data:
                    delta_x = movement.get("deltaX", 0)
                    delta_y = movement.get("deltaY", 0)
                    self.move_cursor(delta_x, delta_y)
            elif isinstance(data, dict): 
                delta_x = data.get("deltaX", 0)
                delta_y = data.get("deltaY", 0)
                self.move_cursor(delta_x, delta_y)
            else:
                print(f"Unexpected data format: {data}")

        except Exception as e:
            print(f"Error processing message: {e}")