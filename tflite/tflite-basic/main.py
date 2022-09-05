import numpy as np
from PIL import Image
from time import time
import glob
import tflite_runtime.interpreter as tf #Tensorflow_Lite

def main():
    # Load the TFLite model and allocate tensors.
    interpreter = tf.Interpreter(model_path="mobilenet_v1_1.0_224_quant.tflite")
    interpreter.allocate_tensors()

    # Load object labels
    with open('labels_mobilenet_quant_v1_224.txt') as f:
        labels = f.readlines()

    # Get input and output tensors.
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    nn_input_size=input_details[0]['shape'][1]

    # Load all images of the validation folder
    print("Loading test images")
    filename="image.jpg"
    img=Image.open(filename).convert('RGB')

    # Resize image to the input size of the model
    width, height = img.size
    if width>height:
        img_resized=Image.new("RGB",(width,width))
    if width<height:
        img_resized=Image.new("RGB",(height,height))
    img_resized.paste(img)
    img_resized = img_resized.resize((nn_input_size,nn_input_size))
    np_img = np.array(img_resized)
    input_data=[np_img]

    # Set the input tensor
    interpreter.set_tensor(input_details[0]['index'], input_data)

    # Execute the inference
    t1=time()
    interpreter.invoke()
    t2=time()

    # Find highest score into the result array and print the corresponding label
    output_data = interpreter.get_tensor(output_details[0]['index'])
    print(filename,':',labels[np.where(output_data[0]==np.amax(output_data[0]))[0][0]],flush=True)
    print('Inference time:',t2-t1,'s')

if __name__ == "__main__":
    main()
