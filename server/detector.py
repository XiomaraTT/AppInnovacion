import asyncio
import json
import cv2
import websockets
import time
import numpy as np
from abc import ABC, abstractmethod

PORT = 8765

class TranslationService:
    """Handles class label translations from English COCO classes to Spanish."""
    def __init__(self):
        self.translations = {
            "person": "persona",
            "bicycle": "bicicleta",
            "car": "automóvil",
            "motorcycle": "motocicleta",
            "airplane": "avión",
            "bus": "autobús",
            "train": "tren",
            "truck": "camión",
            "boat": "barco",
            "traffic light": "semáforo",
            "fire hydrant": "hidrante",
            "stop sign": "señal de pare",
            "parking meter": "parquímetro",
            "bench": "banca",
            "bird": "pájaro",
            "cat": "gato",
            "dog": "perro",
            "horse": "caballo",
            "sheep": "oveja",
            "cow": "vaca",
            "elephant": "elefante",
            "bear": "oso",
            "zebra": "cebra",
            "giraffe": "jirafa",
            "backpack": "mochila",
            "umbrella": "paraguas",
            "handbag": "cartera",
            "tie": "corbata",
            "suitcase": "maleta",
            "frisbee": "frisbee",
            "skis": "esquís",
            "snowboard": "snowboard",
            "sports ball": "pelota",
            "kite": "cometa",
            "baseball bat": "bate de béisbol",
            "baseball glove": "guante de béisbol",
            "skateboard": "patineta",
            "surfboard": "tabla de surf",
            "tennis racket": "raqueta",
            "bottle": "botella",
            "wine glass": "copa",
            "cup": "taza",
            "fork": "tenedor",
            "knife": "cuchillo",
            "spoon": "cuchara",
            "bowl": "tazón",
            "banana": "plátano",
            "apple": "manzana",
            "sandwich": "sándwich",
            "orange": "naranja",
            "broccoli": "brócoli",
            "carrot": "zanahoria",
            "hot dog": "pancho",
            "pizza": "pizza",
            "donut": "dona",
            "cake": "pastel",
            "chair": "silla",
            "couch": "sillón",
            "potted plant": "planta",
            "bed": "cama",
            "dining table": "mesa",
            "toilet": "inodoro",
            "tv": "televisor",
            "laptop": "computadora",
            "mouse": "mouse",
            "remote": "control remoto",
            "keyboard": "teclado",
            "cell phone": "celular",
            "microwave": "microondas",
            "oven": "horno",
            "toaster": "tostadora",
            "sink": "lavadero",
            "refrigerator": "refrigerador",
            "book": "libro",
            "clock": "reloj",
            "vase": "florero",
            "scissors": "tijeras",
            "teddy bear": "oso de peluche",
            "hair drier": "secador de pelo",
            "toothbrush": "cepillo de dientes"
        }

    def translate(self, label: str) -> str:
        label_lower = label.lower()
        return self.translations.get(label_lower, label_lower)

class ObjectDetector(ABC):
    """Abstract Base Class for vision object detection models."""
    @abstractmethod
    def detect(self, frame) -> list:
        pass

class YoloDetector(ObjectDetector):
    """Implements YOLOv8 object detection."""
    def __init__(self, model_path="yolov8n.pt"):
        from ultralytics import YOLO
        self.model = YOLO(model_path)
        print("[INFO] YOLOv8 cargado con éxito. Se utilizará para detección de múltiples objetos.")

    def detect(self, frame) -> list:
        results = self.model(frame, verbose=False, conf=0.5)
        raw_detections = []
        for r in results:
            for box in r.boxes:
                cls_id = int(box.cls[0])
                label = self.model.names[cls_id]
                xyxy = box.xyxy[0].tolist()
                raw_detections.append({
                    "label": label,
                    "box": [int(v) for v in xyxy]
                })
        return raw_detections

class HaarFaceDetector(ObjectDetector):
    """Fallback Face Detector using OpenCV Haar Cascades."""
    def __init__(self):
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        self.face_cascade = cv2.CascadeClassifier(cascade_path)
        print("[WARN] Se usará el detector facial Haar Cascade como alternativa de detección.")

    def detect(self, frame) -> list:
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = self.face_cascade.detectMultiScale(gray, 1.3, 5)
        raw_detections = []
        for (x, y, face_w, face_h) in faces:
            raw_detections.append({
                "label": "person",
                "box": [x, y, x + face_w, y + face_h]
            })
        return raw_detections

class SpatialAnalyser:
    """Domain class to analyze bounding boxes for horizontal position and distance risk."""
    def __init__(self, translation_service: TranslationService):
        self.translator = translation_service

    def analyse(self, label: str, box: list, frame_width: int) -> dict:
        x1, y1, x2, y2 = box
        
        # Calculate horizontal center position
        x_center = ((x1 + x2) / 2.0) / frame_width
        if x_center < 0.35:
            pos = "Izquierda"
        elif x_center > 0.65:
            pos = "Derecha"
        else:
            pos = "Adelante"
            
        # Proximity risk via bounding box width ratio
        box_width_ratio = (x2 - x1) / frame_width
        
        risk = "Medio"
        translated_label = self.translator.translate(label).capitalize()
        desc = f"{translated_label} detectado a la {pos}."
        
        if label.lower() == "person":
            if box_width_ratio > 0.30:
                risk = "Alto"
                desc = "¡Cuidado! Persona adelante, muy cerca."
            elif box_width_ratio < 0.15:
                risk = "Bajo"
                desc = f"Persona a la {pos}."
        else:
            if box_width_ratio > 0.45:
                risk = "Alto"
                desc = f"¡Cuidado! {translated_label} adelante, muy cerca."
            elif box_width_ratio < 0.15:
                risk = "Bajo"
                desc = f"{translated_label} a la {pos}."
                
        return {
            "label": translated_label,
            "pos": pos,
            "risk": risk,
            "desc": desc,
            "box": box
        }

class EnvironmentConsolidator:
    """Consolidates single frame detections into a grammatically correct Spanish description."""
    def consolidate(self, analysed_objects: list) -> dict:
        if not analysed_objects:
            return None
            
        unique_items = {}
        highest_risk = "Bajo"
        
        for obj in analysed_objects:
            label = obj["label"]
            pos = obj["pos"]
            risk = obj["risk"]
            
            if risk == "Alto":
                highest_risk = "Alto"
            elif risk == "Medio" and highest_risk != "Alto":
                highest_risk = "Medio"
                
            key = (label, pos)
            if key not in unique_items:
                unique_items[key] = {
                    "label": label,
                    "pos": pos,
                    "risk": risk,
                    "desc": obj["desc"],
                    "box": obj["box"]
                }
                
        items_list = list(unique_items.values())
        items_list.sort(key=lambda x: 0 if x["risk"] == "Alto" else (1 if x["risk"] == "Medio" else 2))
        
        parts = []
        has_high_risk = False
        
        for item in items_list:
            label_text = item["label"]
            pos_text = item["pos"]
            risk_text = item["risk"]
            
            if risk_text == "Alto":
                has_high_risk = True
                parts.append(f"{label_text} muy cerca adelante")
            else:
                parts.append(f"{label_text} a la {pos_text}")
                
        if not parts:
            return None
            
        if len(parts) == 1:
            combined_desc = parts[0]
        elif len(parts) == 2:
            combined_desc = f"{parts[0]} y {parts[1]}"
        else:
            combined_desc = ", ".join(parts[:-1]) + f" y {parts[-1]}"
            
        if has_high_risk:
            combined_desc = "¡Cuidado! " + combined_desc
        else:
            combined_desc = combined_desc + "."
            
        combined_desc = combined_desc[0].upper() + combined_desc[1:]
        
        return {
            "type": "detection",
            "label": items_list[0]["label"],
            "position": items_list[0]["pos"],
            "risk": highest_risk,
            "description": combined_desc,
            "objects": [
                {
                    "label": item["label"],
                    "position": item["pos"],
                    "risk": item["risk"],
                    "box": item["box"]
                } for item in items_list
            ]
        }

class VisionServer:
    """Manages WebSocket connections and frames streaming from mobile clients."""
    def __init__(self, detector: ObjectDetector, analyser: SpatialAnalyser, consolidator: EnvironmentConsolidator):
        self.detector = detector
        self.analyser = analyser
        self.consolidator = consolidator
        self.connected_clients = set()
        
        self.last_announced_desc = ""
        self.last_announced_time = 0.0

    async def register(self, websocket):
        print(f"[INFO] Cliente conectado desde: {websocket.remote_address}")
        self.connected_clients.add(websocket)

    async def unregister(self, websocket):
        print(f"[INFO] Cliente desconectado: {websocket.remote_address}")
        self.connected_clients.remove(websocket)
        try:
            cv2.destroyWindow("Riqsi Vision Server - Transmision Celular")
        except Exception:
            pass

    async def process_frame(self, jpeg_bytes, websocket):
        try:
            nparr = np.frombuffer(jpeg_bytes, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if frame is None:
                return

            h, w, _ = frame.shape
            
            raw_detections = self.detector.detect(frame)
            analysed_objects = [
                self.analyser.analyse(raw["label"], raw["box"], w)
                for raw in raw_detections
            ]

            # Render rectangles on visual debug window
            for obj in analysed_objects:
                box = obj["box"]
                color = (0, 255, 0)
                if obj["risk"] == "Alto":
                    color = (0, 0, 255)
                elif obj["risk"] == "Medio":
                    color = (0, 165, 255)
                cv2.rectangle(frame, (box[0], box[1]), (box[2], box[3]), color, 3)
                cv2.putText(frame, f"{obj['label']} - {obj['pos']} ({obj['risk']})", 
                            (box[0], box[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

            cv2.imshow("Riqsi Vision Server - Transmision Celular", frame)
            cv2.waitKey(1)

            # Consolidate detections and apply rate limits
            consolidated = self.consolidator.consolidate(analysed_objects)
            if consolidated:
                current_time = time.time()
                combined_desc = consolidated["description"]
                
                should_send = False
                if combined_desc != self.last_announced_desc:
                    should_send = True
                else:
                    elapsed = current_time - self.last_announced_time
                    if consolidated["risk"] == "Alto" and elapsed > 5.5:
                        should_send = True
                    elif consolidated["risk"] in ("Medio", "Bajo") and elapsed > 11.0:
                        should_send = True

                if should_send:
                    self.last_announced_desc = combined_desc
                    self.last_announced_time = current_time
                    print(f"[VISION-CELULAR] Enviando entorno: {combined_desc} (Riesgo: {consolidated['risk']})")
                    await websocket.send(json.dumps(consolidated))
            else:
                if time.time() - self.last_announced_time > 4.5:
                    self.last_announced_desc = ""

        except Exception as e:
            print(f"[ERROR] Error al procesar imagen del celular: {e}")

    async def handler(self, websocket):
        await self.register(websocket)
        try:
            async for message in websocket:
                if isinstance(message, bytes):
                    await self.process_frame(message, websocket)
        except websockets.exceptions.ConnectionClosedOK:
            pass
        except Exception as e:
            print(f"[ERROR] Error en comunicación: {e}")
        finally:
            await self.unregister(websocket)

async def main():
    # Instantiate clean detector dynamically based on dependencies availability
    yolo_available = False
    try:
        from ultralytics import YOLO
        yolo_available = True
    except ImportError:
        pass

    if yolo_available:
        detector = YoloDetector()
    else:
        detector = HaarFaceDetector()

    translator = TranslationService()
    analyser = SpatialAnalyser(translator)
    consolidator = EnvironmentConsolidator()
    server = VisionServer(detector, analyser, consolidator)

    print("\n" + "="*50)
    print("      RIQSI - SERVIDOR DE VISIÓN LIMPIO")
    print("="*50)
    print(f" Servidor WebSocket: ws://localhost:{PORT}")
    print("="*50 + "\n")

    async with websockets.serve(server.handler, "0.0.0.0", PORT):
        print(f"[INFO] Servidor WebSocket corriendo en puerto {PORT}")
        while True:
            await asyncio.sleep(3600)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n[INFO] Servidor terminado por el usuario.")
