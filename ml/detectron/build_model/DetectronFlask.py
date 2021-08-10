
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


@app.route('/predict', methods=['POST'])
def predict():
    output_data = request.form.get('output_data')
    
    if output_data not in ['predicted_masks', 'photo']:
        return 'Invalid "output_data" parameter. Valid values: "predicted_masks", "photo"', 400   
    logging.info(f'Received incoming message - output_data: {output_data}')
    
    if 'photo' not in request.files:
        return 'File for predict is not founded', 400
    file = request.files['photo'] 
    logging.info(f'Received incoming file - {file.filename}')    
        
    INPUT_PHOTO_FILE = './temp/input_photo.png'
    OUTPUT_PHOTO_FILE = './temp/output_photo.png'
    OUTPUT_COMPRESSED_FILE = './temp/output.pred_masks'
    
    img = Image.open(file)
    img.save(INPUT_PHOTO_FILE, format='PNG')
    
    
    #predict books segments
    predictions = scorer(INPUT_PHOTO_FILE)
    
   
    if output_data == 'predicted_masks':
        pred_masks = predictions['instances'].pred_masks.numpy()
        joblib.dump(pred_masks, OUTPUT_COMPRESSED_FILE,compress=True)        
        return send_file(OUTPUT_COMPRESSED_FILE)

    else:
        im = cv2.imread(INPUT_PHOTO_FILE)
        v = Visualizer(im[:, :, ::-1], scale=1.)
        out = v.draw_instance_predictions(predictions['instances']).get_image()[:, :, ::-1]
        im = Image.fromarray(out)
        im.save(OUTPUT_PHOTO_FILE, format='PNG')
        return send_file(OUTPUT_PHOTO_FILE)



if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
