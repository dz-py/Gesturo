from pynput.mouse import Controller, Button
import asyncio
import websockets
import ujson
import uvloop
import time

asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

class WebSocketServer:
    def __init__(self, host="0.0.0.0", port=5007):
        self.host = host
        self.port = port
        self.clients = set()
        
        self.delta_x_buffer = 0         # Accumulate X movements
        self.delta_y_buffer = 0         # Accumulate Y movements
        self.scroll_x_buffer = 0        # Accumulate X scrolling
        self.scroll_y_buffer = 0        # Accumulate Y scrolling
        self.lock = asyncio.Lock()      # Prevent race conditions
        self.max_delta = 20             # Maximum amount to move at once
        self.sensitivity_factor = 3.5   # Adjusted sensitivity factor
        self.scroll_sensitivity = 0.8   # Adjusted scrolling sensitivity factor 
        self.friction = 0.005           # Momentum effect (lower = more friction)
        
        self.mouse = Controller()

    async def handle_connection(self, websocket):
        self.clients.add(websocket)
        print("iOS device connected!")
        
        try:
            async for message in websocket:
                await self.process_message(message)
        except websockets.exceptions.ConnectionClosed:
            print("Client disconnected.")
        finally:
            self.clients.remove(websocket)

    async def process_message(self, message):
        try:
            receive_time = time.time() * 1000  
            data = ujson.loads(message)
            
            # if isinstance(data, list):
            #     for movement in data:
            #         if 'sendTime' in movement:
            #             latency = receive_time - movement['sendTime']
            #             print(f"Message latency: {latency:.2f}ms")
            #         await self.handle_gesture(movement)
            # elif isinstance(data, dict):
            #     if 'sendTime' in data:
            #         latency = receive_time - data['sendTime']
            #         print(f"Message latency: {latency:.2f}ms")
            #     await self.handle_gesture(data)
                        
        except (ValueError, KeyError, TypeError) as e:
            print(f"Error processing message: {e}")

    async def handle_gesture(self, gesture_data):
        gesture_type = gesture_data.get("type", "move")
        
        if gesture_type == "move":
            self.delta_x_buffer += gesture_data.get("deltaX", 0)
            self.delta_y_buffer += gesture_data.get("deltaY", 0)
        
        elif gesture_type == "scroll":
            self.scroll_x_buffer += gesture_data.get("deltaX", 0)
            self.scroll_y_buffer += gesture_data.get("deltaY", 0)
        
        elif gesture_type == "leftClick":
            self.mouse.click(Button.left)
        
        elif gesture_type == "rightClick":
            self.mouse.click(Button.right)

        elif gesture_type == "doubleClick":
            self.mouse.click(Button.left, 2)

    async def move_cursor_periodically(self):
        while True:
            # Handle cursor movement
            if abs(self.delta_x_buffer) > 0 or abs(self.delta_y_buffer) > 0:
                small_move_threshold = 7
                sensitivity = self.sensitivity_factor

                if abs(self.delta_x_buffer) < small_move_threshold:
                    sensitivity = 0.5
                if abs(self.delta_y_buffer) < small_move_threshold:
                    sensitivity = 0.5

                total_delta = (abs(self.delta_x_buffer) + abs(self.delta_y_buffer))
                sensitivity = self.sensitivity_factor

                # Normalize diagonal movement
                if total_delta > 0:
                    delta_x = self.delta_x_buffer * sensitivity * (abs(self.delta_x_buffer) / total_delta)
                    delta_y = self.delta_y_buffer * sensitivity * (abs(self.delta_y_buffer) / total_delta)

                    self.mouse.move(delta_x, delta_y)


                self.delta_x_buffer *= self.friction
                self.delta_y_buffer *= self.friction

            # Handle scrolling
            if abs(self.scroll_x_buffer) > 0 or abs(self.scroll_y_buffer) > 0:
                scroll_x = int(self.scroll_x_buffer * self.scroll_sensitivity)
                scroll_y = int(self.scroll_y_buffer * self.scroll_sensitivity)
                
                if abs(scroll_y) > 0:
                    self.mouse.scroll(0, scroll_y)  # Negative for natural scrolling
                if abs(scroll_x) > 0:
                    self.mouse.scroll(scroll_x, 0)
                
                self.scroll_x_buffer *= self.friction
                self.scroll_y_buffer *= self.friction

            await asyncio.sleep(0.001)

    async def start(self):
        server = await websockets.serve(self.handle_connection, self.host, self.port, ping_interval=None)
        print(f"WebSocket server started on ws://{self.host}:{self.port}")
        asyncio.create_task(self.move_cursor_periodically())
        await asyncio.Future()