from flask import Flask, request, send_file
from healthcheck import HealthCheck
from PIL import Image
import os, cv2, joblib, logging, torch
import numpy as np

import detectron2
from detectron2.utils.visualizer import Visualizer


logging.basicConfig(format='%(message)s', level=logging.INFO)
app = Flask(__name__)

logging.info(f"=== LOGGING: torch = {torch.__version__}; cuda is avaliable:{torch.cuda.is_available()}")

MODEL_JOBLIB_FILE = './model/model.joblib'
predictor = joblib.load(MODEL_JOBLIB_FILE)
logging.info('=== LOGGING: All models loaded succcessfully')


def howami():
    return True, "I am alive. Thanks for checking.."

def detectron_check():
    return True, f'Detectron2 is available. Version == {str(detectron2.__version__)}' 

health = HealthCheck(app, "/hcheck")
health.add_check(howami)
health.add_check(detectron_check)


@app.route('/')
def hello():
    return 'Welcome to Books Prediction Application (Detectron2)'


def scorer(file_name):
    im = cv2.imread(file_name)
    outputs = predictor(im)   
    return outputs

def mask_to_rectangle(mask):
    contours, hierarchy = cv2.findContours(mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)
    if len(contours) == 0:
        return []
    
    contour1 = contours[0]
    for i in range(1, len(contours)):
        contour2 = np.array(contours[i])
        contour1 = np.concatenate((contour1, contour2), axis=0)
    contour1 = contour1.squeeze()
    contour1 = cv2.convexHull(contour1)
    
    rect = cv2.boxPoints(cv2.minAreaRect(contour1)).tolist()
    return rect

def predictions_to_rectangles(predictions):
    pred_masks = predictions['instances'].pred_masks.to("cpu").numpy()
    pred_masks = np.uint8(pred_masks)
    
    boxes = []
    for i in range(pred_masks.shape[0]):
        box = mask_to_rectangle(pred_masks[i])
        boxes.append(box) 
        
    return boxes


INPUT_PHOTO_FILE = 'input_photo.png'
OUTPUT_PHOTO_FILE = 'output_photo.png'
OUTPUT_COMPRESSED_FILE = 'output.pred_masks'

def plot_blocks_on_photo(boxes):
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    import pylab

    def build_polygon(points):
        xy = np.array(points)
        return patches.Polygon(xy, closed=True, linewidth=2, fill=True, alpha=0.5, color=np.random.rand(3, ))

    pylab.rcParams['figure.figsize'] = [50.0, 100.0]
    im = Image.open(INPUT_PHOTO_FILE)
    
    fig, ax = plt.subplots()
    ax.imshow(im)
    bx = fig.gca()

    for box in boxes:
        bx.add_patch(build_polygon(box))

    fig.savefig(OUTPUT_PHOTO_FILE)


def save_photo_from_request(request):   
    if 'photo' not in request.files:
        return 'File for predict is not founded', 400
    
    file = request.files['photo'] 
    logging.info(f'Received incoming file - {file.filename}')  
    
    img = Image.open(file)
    img.save(INPUT_PHOTO_FILE, format='PNG')

    



#api methods    

@app.route('/predict-masks', methods=['POST'])
def predict_masks():
    save_photo_from_request(request)

    #predict books segments
    predictions = scorer(INPUT_PHOTO_FILE)
    
    pred_masks = predictions['instances'].pred_masks.numpy()
    joblib.dump(pred_masks, OUTPUT_COMPRESSED_FILE,compress=True)        
    return send_file(OUTPUT_COMPRESSED_FILE)
    
    
@app.route('/predict-masks-on-photo', methods=['POST'])
def predict_mask_on_photo():
    save_photo_from_request(request)
    
    #predict books segments
    predictions = scorer(INPUT_PHOTO_FILE)
    
    im = cv2.imread(INPUT_PHOTO_FILE)
    v = Visualizer(im[:, :, ::-1], scale=1.)
    out = v.draw_instance_predictions(predictions['instances']).get_image()[:, :, ::-1]
    im = Image.fromarray(out)
    im.save(OUTPUT_PHOTO_FILE, format='PNG')
    return send_file(OUTPUT_PHOTO_FILE)

  
@app.route('/predict-rectangles', methods=['POST'])
def predict_rectangles():
    save_photo_from_request(request)
    
    #predict books segments
    predictions = scorer(INPUT_PHOTO_FILE)
    
    boxes = predictions_to_rectangles(predictions) 
    return {'boxes': boxes}


@app.route('/predict-rectangles-on-photo', methods=['POST'])
def predict_rectangles_on_photo():
    save_photo_from_request(request)
    
    #predict books segments
    predictions = scorer(INPUT_PHOTO_FILE)
    
    boxes = predictions_to_rectangles(predictions) 
    plot_blocks_on_photo(boxes)     
    return send_file(OUTPUT_PHOTO_FILE)
    
    

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
