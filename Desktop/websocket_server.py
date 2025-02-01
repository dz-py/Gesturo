from pynput.mouse import Controller
import asyncio
import websockets
import ujson  
import uvloop  
import time

# uvloop for better async performance
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())  

class WebSocketServer:
    def __init__(self, host="0.0.0.0", port=5007):
        self.host = host
        self.port = port
        self.clients = set()

        self.delta_x_buffer = 0  # Accumulate X movements
        self.delta_y_buffer = 0  # Accumulate Y movements
        self.lock = asyncio.Lock()  # Prevent race conditions
        self.max_delta = 8  # Maximum amount to move at once
        self.sensitivity_factor = 0.8  # Adjusted sensitivity factor
        self.friction = 0.0006  # Friction to slow down cursor
        self.last_activity = time.time()  # Track last gesture time

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
            data = ujson.loads(message)  
            
            async with self.lock: 
                # Handle batched movements 
                if isinstance(data, list):  
                    for movement in data: 
                        self.delta_x_buffer += movement.get("deltaX", 0)
                        self.delta_y_buffer += movement.get("deltaY", 0)
                elif isinstance(data, dict): 
                    # Handle single movement messages
                    self.delta_x_buffer += data.get("deltaX", 0)
                    self.delta_y_buffer += data.get("deltaY", 0)

        except (ValueError, KeyError, TypeError) as e:
            print(f"Error processing message: {e}")

    async def move_cursor_periodically(self):
        """ Moves the cursor every few milliseconds using the accumulated buffer. """
        while True:
            if abs(self.delta_x_buffer) > 0 or abs(self.delta_y_buffer) > 0:
                small_move_threshold = 2  # Below this, we reduce sensitivity
                sensitivity = self.sensitivity_factor

                # Reduce sensitivity for very small movements
                if abs(self.delta_x_buffer) < small_move_threshold:
                    sensitivity = 0.8  # Lower sensitivity for small moves
                if abs(self.delta_y_buffer) < small_move_threshold:
                    sensitivity = 0.8

                delta_x = self.delta_x_buffer * sensitivity
                delta_y = self.delta_y_buffer * sensitivity

                self.mouse.move(delta_x, delta_y)  

                # Apply friction for smooth stopping
                self.delta_x_buffer *= self.friction
                self.delta_y_buffer *= self.friction

            await asyncio.sleep(0.001)


    async def start(self):
        server = await websockets.serve(self.handle_connection, self.host, self.port, ping_interval=None)
        print(f"WebSocket server started on ws://{self.host}:{self.port}")
        asyncio.create_task(self.move_cursor_periodically())
        await asyncio.Future() 
