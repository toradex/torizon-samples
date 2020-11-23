# Container Image #

This Docker image provides an example of how to run [Amazon SageMaker Neo](https://docs.aws.amazon.com/sagemaker/latest/dg/neo.html) Object Detection models using [DLR runtime](https://github.com/neo-ai/neo-ai-dlr). In addition it also shows how to use Gstreamer to obtain a frame data from a camera, process it with OpenCV, draw on the image and output it to a video sink.

The **model** folder contains an example binary model pre-trained with pasta dataset and pre-compiled for Apalis iMX8. You can replace these files by other models that better fits your application, for example [AI at the Edge, Pasta Detection Demo with AWS model](https://github.com/toradex/aws-nxp-ai-at-the-edge/tree/master/container_inference/model) . If you want to rebuild these files using your own image dataset, see the instructions on the [Train a Neural Network for Object Detection algorithm (SSD) for iMX8 boards using SageMaker Neo](https://developer.toradex.com/knowledge-base/train-ssd-for-imx8-boards) article.

For complete information about this demo, visit the [Executing models tuned by SageMaker Neo in a Docker Container using DLR runtime, Gstreamer and OpenCV](https://developer.toradex.com/knowledge-base/how-to-run-dlr-runtime-to-test-object-detection-models-with-torizon) article.

# Building and Running #

To run this example, you need to start 2 containers: One for Wayland + Weston and another one for the inference service.

For complete information about how build an image and run a container based on this demo, see the [Executing models tuned by SageMaker Neo in a Docker Container using DLR runtime, Gstreamer and OpenCV](https://developer.toradex.com/knowledge-base/how-to-run-dlr-runtime-to-test-object-detection-models-with-torizon) article.
