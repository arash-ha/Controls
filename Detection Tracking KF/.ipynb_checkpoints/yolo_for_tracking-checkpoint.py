# -*- coding: utf-8 -*-
"""yolo.ipynb"""

import os
from google.colab import drive
drive.mount('/content/drive', force_remount=False)
os.chdir("/content/drive/My Drive/Colab Notebooks/Tracking")


import cv2
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np

## Define the class YOLO and the init() function

class YOLO():
    def __init__(self):
       
        self.confThreshold = 0.5
        self.nmsThreshold = 0.4
        self.inpWidth = 320
        self.inpHeight = 320
        classesFile = "/content/drive/My Drive/Colab Notebooks/Tracking/Detection/YOLO/coco.names"
        self.classes = None
        with open(classesFile,'rt') as f:
            self.classes = f.read().rstrip('\n').split('\n')

        modelConfiguration = "/content/drive/My Drive/Colab Notebooks/Tracking/Main/Yolov3/yolov3.cfg"
        modelWeights = "/content/drive/My Drive/Colab Notebooks/Tracking/Main/Yolov3/yolov3.weights"
        self.net = cv2.dnn.readNetFromDarknet(modelConfiguration, modelWeights)
        self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_OPENCV)
        self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)

    def getOutputsNames(self):


        layersNames = self.net.getLayerNames()
        return [layersNames[i[0] - 1] for i in self.net.getUnconnectedOutLayers()]


    def drawPred(self, frame, classId, conf, left, top, right, bottom):

        # Draw a bounding box.
        cv2.rectangle(frame, (left, top), (right, bottom), (255, 0, 0), thickness=5)
        label = '%.2f' % conf
        # Get the label for the class name and its confidence
        if self.classes:
            assert(classId < len(self.classes))
            label = '%s:%s' % (self.classes[classId], label)
    
        #Display the label at the top of the bounding box
        labelSize, baseLine = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
        top = max(top, labelSize[1])
        cv2.putText(frame, label, (left, top), cv2.FONT_HERSHEY_SIMPLEX, 1, (255,255,255), thickness=3)
        return frame

    
    def postprocess(self,frame, outs):
        
        frameHeight = frame.shape[0]
        frameWidth = frame.shape[1]
        classIds = []
        confidences = []
        boxes = []
       
        for out in outs:
            for detection in out:
                scores = detection[5:]
                classId = np.argmax(scores)
                confidence = scores[classId]
                if confidence > self.confThreshold:
                    center_x = int(detection[0] * frameWidth)
                    center_y = int(detection[1] * frameHeight)
                    width = int(detection[2] * frameWidth)
                    height = int(detection[3] * frameHeight)
                    left = int(center_x - width / 2)
                    top = int(center_y - height / 2)
                    classIds.append(classId)
                    confidences.append(float(confidence))
                    boxes.append([left, top, width, height])
    
        
        indices = cv2.dnn.NMSBoxes(boxes, confidences, self.confThreshold, self.nmsThreshold)
        for i in indices:
            i = i[0]
            box = boxes[i]
            left = box[0]
            top = box[1]
            width = box[2]
            height = box[3]
            output_image = self.drawPred(frame,classIds[i], confidences[i], left, top, left + width, top + height)
        return frame, boxes

    
    def inference(self,image):
        """
        Main loop.
        Input: Image
        Output: Frame with the drawn bounding boxes
        """
        # Create a 4D blob from a frame.
        blob = cv2.dnn.blobFromImage(image, 1/255, (self.inpWidth, self.inpHeight), [0,0,0], 1, crop=False)
        # Sets the input to the network
        self.net.setInput(blob)
        # Runs the forward pass to get output of the output layers
        outs = self.net.forward(self.getOutputsNames())
        # Remove the bounding boxes with low confidence
        final_frame, boxes = self.postprocess(image, outs)
        return final_frame, boxes


