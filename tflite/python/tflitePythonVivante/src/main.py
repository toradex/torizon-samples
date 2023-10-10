#!python3
import numpy as np
from PIL import Image
from time import time
import glob

try:
    import tflite_runtime.interpreter as tf #Tensorflow_Lite
except:
    try:
        import tflite as tf #Tensorflow_Lite
    except:
        from tensorflow import lite as tf #Tensorflow

def main():

    # If the external vx tflite delegate is not available, like in local debugging, use the cpu 
    try:
        delegate = tf.load_delegate('/usr/lib/libvx_delegate.so')
        interpreter = tf.Interpreter(model_path="mobilenet_v1_1.0_224_quant.tflite", experimental_delegates=[delegate])
    except:
        interpreter = tf.Interpreter(model_path="mobilenet_v1_1.0_224_quant.tflite")
        
    interpreter.allocate_tensors()
    # Load object labels
    with open("labels_mobilenet_quant_v1_224.txt") as f:
        labels = f.readlines()

    # Get input and output tensors.
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    nn_input_size=input_details[0]['shape'][1]

    #load all images of the validation folder
    print("Loading test images")
    images = []
    filenames=[]
    for f in glob.iglob("cats_and_dogs_filtered/validation/dogs/*.jpg"):
        images.append(Image.open(f).convert('RGB'))
        filenames.append(f)
    for f in glob.iglob("cats_and_dogs_filtered/validation/cats/*.jpg"):
        images.append(Image.open(f).convert('RGB'))
        filenames.append(f)

    print("Starting inference")
    Total_Time=0
    inference_times=[]
    for i in range(len(images)):
        # Pad and resize the image to the correct input size
        img = images[i]
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
        Total_Time+=(t2-t1)

        # Find highest score into the result array and print the corresponding label
        output_data = interpreter.get_tensor(output_details[0]['index'])
        print(filenames[i],':',labels[np.where(output_data[0]==np.amax(output_data[0]))[0][0]],flush=True)
        print('Inference time:',t2-t1,'s')
        # Ignore the first inference - warm-up time
        if(i!=0):
            inference_times.append(t2-t1)

    inference_times=np.array(inference_times)
    n_images=len(inference_times)
    total_time=np.sum(inference_times)
    print("")
    print("Number of Images processed:",n_images)
    print("Mean Inference Time:",total_time/n_images)
    print("Mean image/s :",1/(total_time/n_images))
    print("Std deviation:",np.std(inference_times))
    print("")

if __name__ == "__main__":
    main()
