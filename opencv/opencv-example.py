import numpy as np
import cv2

# Load an color image in grayscale
img = cv2.imread('toradex_som.jpg',cv2.IMREAD_GRAYSCALE)
cv2.imshow('image',img)
cv2.waitKey(20000)
cv2.destroyAllWindows()
