import gi
gi.require_version('Gst', '1.0')
gi.require_version('GstApp', '1.0')
from gi.repository import GLib, Gst, GstApp
from time import time
from dlr import DLRModel
import numpy as np
import cv2
import threading

width_out = 1280
height_out = 960

nn_input_size= 128
class_names=['aeroplane', 'bicycle', 'bird', 'boat', 'bottle', 'bus', 'car',
            'cat', 'chair', 'cow', 'diningtable', 'dog', 'horse', 'motorbike',
             'person', 'pottedplant', 'sheep', 'sofa', 'train', 'tvmonitor']
colors=[(0xFF,0x83,0x00),(0xFF,0x66,0x00),(0xFF,0x00,0x00),(0x99,0xFF,0x00),
        (0x00,0xFF,0x00),(0x00,0x00,0xFF),(0x00,0x00,0x00)]

# Mean and Std deviation of the RGB colors (collected from Imagenet dataset)
mean=[123.68,116.779,103.939]
std=[58.393,57.12,57.375]

# Inference
def inference(img):
    #******** INSERT YOUR INFERENCE HERE ********
    #prepare image to input.Resize adding borders and normalize.
    nn_input=cv2.resize(img, (nn_input_size,int(nn_input_size/4*3)))
    nn_input=cv2.copyMakeBorder(nn_input,int(nn_input_size/8),int(nn_input_size/8),
                                0,0,cv2.BORDER_CONSTANT,value=(0,0,0))
    nn_input=nn_input.astype('float64')
    nn_input=nn_input.reshape((nn_input_size*nn_input_size ,3))
    nn_input=np.transpose(nn_input)
    nn_input[0,:] = nn_input[0,:]-mean[0]
    nn_input[0,:] = nn_input[0,:]/std[0]
    nn_input[1,:] = nn_input[1,:]-mean[1]
    nn_input[1,:] = nn_input[1,:]/std[1]
    nn_input[2,:] = nn_input[2,:]-mean[2]
    nn_input[2,:] = nn_input[2,:]/std[2]

    #Run the model
    tbefore = time()
    outputs = model.run({'data': nn_input})
    tafter = time()
    last_inference_time = tafter-tbefore
    objects=outputs[0][0]
    scores=outputs[1][0]
    bounding_boxes=outputs[2][0]

    #Draw bounding boxes
    i = 0
    while (scores[i]>0.5):

        y1=int((bounding_boxes[i][1]-nn_input_size/8)*width_out/nn_input_size)
        x1=int((bounding_boxes[i][0])*height_out/(nn_input_size*3/4))
        y2=int((bounding_boxes[i][3]-nn_input_size/8)*width_out/nn_input_size)
        x2=int((bounding_boxes[i][2])*height_out/(nn_input_size*3/4))

        object_id=int(objects[i])
        cv2.rectangle(img,(x2,y2),(x1,y1),colors[object_id%len(colors)],2)
        cv2.rectangle(img,(x1+70,y2+15),(x1,y2),colors[object_id%len(colors)],cv2.FILLED)
        cv2.putText(img,class_names[object_id],(x1,y2+10), cv2.FONT_HERSHEY_SIMPLEX, 0.4,(255,255,255),1,cv2.LINE_AA)
        i=i+1

    cv2.rectangle(img,(110,17),(0,0),(0,0,0),cv2.FILLED)
    cv2.putText(img,"inf. time: %.3fs"%last_inference_time,(3,12), cv2.FONT_HERSHEY_SIMPLEX, 0.4,(255,255,255),1,cv2.LINE_AA)

    #******** END OF YOUR INFERENCE CODE ********

# Pipeline 1 output
def on_new_frame(sink, data):
    global appsource
    global t_between_frames

    sample = sink.emit("pull-sample")
    captured_gst_buf = sample.get_buffer()
    caps = sample.get_caps()
    im_height_in = caps.get_structure(0).get_value('height')
    im_width_in = caps.get_structure(0).get_value('width')
    mem = captured_gst_buf.get_all_memory()
    success, arr = mem.map(Gst.MapFlags.READ)
    img = np.ndarray((im_height_in,im_width_in,3),buffer=arr.data,dtype=np.uint8)
    inference(img)
    appsource.emit("push-buffer", Gst.Buffer.new_wrapped(img.tobytes()))
    mem.unmap(arr)
    return Gst.FlowReturn.OK

def main():
    # SagemakerNeo init
    global model
    global appsource
    global pipeline1
    global pipeline2

    model = DLRModel('./model', 'cpu')

    # Gstreamer Init
    Gst.init(None)

    pipeline1_cmd="v4l2src device=/dev/video2 do-timestamp=True ! videoconvert ! \
        videoscale n-threads=4 method=nearest-neighbour ! \
        video/x-raw,format=RGB,width="+str(width_out)+",height="+str(height_out)+" ! \
        queue leaky=downstream max-size-buffers=1 ! appsink name=sink \
        drop=True max-buffers=1 emit-signals=True max-lateness=8000000000"

    pipeline2_cmd = "appsrc name=appsource1 is-live=True block=True ! \
        video/x-raw,format=RGB,width="+str(width_out)+",height="+ \
        str(height_out)+",framerate=20/1,interlace-mode=(string)progressive ! \
        videoconvert ! waylandsink" #v4l2sink max-lateness=8000000000 device=/dev/video14"

    pipeline1 = Gst.parse_launch(pipeline1_cmd)
    appsink = pipeline1.get_by_name('sink')
    appsink.connect("new-sample", on_new_frame, appsink)

    pipeline2 = Gst.parse_launch(pipeline2_cmd)
    appsource = pipeline2.get_by_name('appsource1')

    pipeline1.set_state(Gst.State.PLAYING)
    bus1 = pipeline1.get_bus()
    pipeline2.set_state(Gst.State.PLAYING)
    bus2 = pipeline2.get_bus()

    # Main Loop
    while True:
        message = bus1.timed_pop_filtered(10000, Gst.MessageType.ANY)
        if message:
            if message.type == Gst.MessageType.ERROR:
                err,debug = message.parse_error()
                print("ERROR bus 1:",err,debug)
                pipeline1.set_state(Gst.State.NULL)
                pipeline2.set_state(Gst.State.NULL)
                quit()

            if message.type == Gst.MessageType.WARNING:
                err,debug = message.parse_warning()
                print("WARNING bus 1:",err,debug)

            if message.type == Gst.MessageType.STATE_CHANGED:
                old_state, new_state, pending_state = message.parse_state_changed()
                print("INFO: state on bus 2 changed from ",old_state," To: ",new_state)
        message = bus2.timed_pop_filtered(10000, Gst.MessageType.ANY)
        if message:
            if message.type == Gst.MessageType.ERROR:
                err,debug = message.parse_error()
                print("ERROR bus 2:",err,debug)
                pipeline1.set_state(Gst.State.NULL)
                pipeline2.set_state(Gst.State.NULL)
                quit()

            if message.type == Gst.MessageType.WARNING:
                err,debug = message.parse_warning()
                print("WARNING bus 2:",err,debug)

            if message.type == Gst.MessageType.STATE_CHANGED:
                old_state, new_state, pending_state = message.parse_state_changed()
                print("INFO: state on bus 2 changed from ",old_state," To: ",new_state)

if (__name__ == "__main__"):
    thread1 = threading.Thread(target = main)
    thread1.start()
