import numpy as np
import cv2
import re
from google.cloud import vision


# Instantiates a client
#TODO:AVEA - don't merge
#vision_client = vision.ImageAnnotatorClient()
vision_client = vision.ImageAnnotatorClient.from_service_account_json('venv\\keys\\biblosphere-210106-dcfe06610932.json')


def ocr_url(url):
    image = vision.Image()
    image.source.image_uri = url

    return vision_client.document_text_detection(image=image)


def ocr_image(img):

    content = cv2.imencode('.jpg', img)[1].tostring()
    image = vision.Image(content=content)

    # Performs label detection on the image file
    return vision_client.document_text_detection(image=image)


def imread_blob(blob):
    img = cv2.imdecode(np.asarray(bytearray(blob.download_as_string()), dtype=np.uint8), cv2.IMREAD_COLOR)
    return img

# ********************************************************************************************************
# Return bounding convex hull for the set of points`
def convex_for_points(points):
    boxes = np.array(points)
    #print(boxes)
    hull = cv2.convexHull(boxes.reshape(-1, 2))
    hull = hull.reshape(-1, 2)
    return hull


# Calculate angle of the line
def line_angle(A, B, full=False):
    side = A - B
    if side[0] == 0:
        if side[1] > 0:
            angle = np.pi / 2
        else:
            angle = -np.pi / 2

    else:
        angle = np.arctan(side[1] / side[0])

    if full:
        if side[0] < 0:
            if angle <= 0:
                angle += np.pi
            elif angle > 0:
                angle -= np.pi

    return angle


# Return bounding min area box for the set of points
def box_for_points(points):
    boxes = np.array(points)
    rect = cv2.minAreaRect(boxes.reshape(-1, 2))
    return np.int0(cv2.boxPoints(rect))


# Return a minimal box aligned with direction of the words
def box_for_words(word_list):
    # For each box get direction (alpha) and lenght
    points = np.zeros((0,2), dtype=np.uint8)
    for w in word_list:
        points = np.concatenate((points, w.box))
    return convex_for_points(points.reshape(-1,2))


# Calculate length and angle for a box
def box_angle(b, longside = False):
    b = box_for_points(b)

    # Incline of longer side
    if longside and np.sum((b[1]-b[0])**2) < np.sum((b[2]-b[1])**2):
        b = np.roll(b, 1, axis=0)

    #length = max(np.sqrt(np.sum((b[1]-b[0])**2)), np.sqrt(np.sum((b[2]-b[1])**2)))
    angle = line_angle(b[0], b[1])

    if not longside:
        if angle > np.pi/4:
            angle -= np.pi/2
        elif angle < -np.pi/4:
            angle += np.pi/2

    return angle


# Return euclidian distance
def d(p):
    return np.sqrt(np.sum(p ** 2))


def distance_to_line(points, A, B):
    if np.linalg.norm(B - A) == 0.0:
        return np.sqrt(np.sum((points-A) ** 2, axis=-1))
    else:
        return np.abs(np.cross(B - A, points - A) / np.linalg.norm(B - A))


# Return bounding min area box for the set of points
def center_for_points(points):
    center, size, _ = cv2.minAreaRect(points.reshape(-1, 2))
    return np.array(center), max(size), min(size)


# Rotate points around the center
def rotate_points(center, size, points, theta, trace=False):
    rx, ry = center
    w, h = size, size

    if trace:
        print('Contour before rotation: ', points)
        print('Rotation centre: ', rx, ry)

    # grab the rotation matrix
    M = cv2.getRotationMatrix2D((rx, ry), theta / np.pi * 180, 1)

    # grab the sine and cosine (i.e., the rotation components of the matrix)
    cos = np.abs(M[0, 0])
    sin = np.abs(M[0, 1])

    # compute the new bounding dimensions of the image
    nW = int((h * sin) + (w * cos))
    nH = int((h * cos) + (w * sin))

    # adjust the rotation matrix to take into account translation
    M[0, 2] += (nW / 2) - rx
    M[1, 2] += (nH / 2) - ry

    # rotate contour
    contour_rot = np.int0(cv2.transform(np.array([points]), M))[0]

    if trace:
        print('Contour after rotation: ', contour_rot)

    return contour_rot


# Rotate one point around the center
def rotate(center, point, angle):
    ox, oy = center
    px, py = point

    qx = ox + np.cos(angle) * (px - ox) - np.sin(angle) * (py - oy)
    qy = oy + np.sin(angle) * (px - ox) + np.cos(angle) * (py - oy)
    return np.array([qx, qy])



def diff_angle(a1, a2):
    eps = abs(a1 - a2)
    return min(eps, np.pi - eps)


# Return bounding min area box for the set of words
def minrect_area(points):
    #print(points)
    points = np.array(points).reshape((-1, 2))
    rect = cv2.minAreaRect(points)
    return rect[1][0] * rect[1][1]


# Check if projection of point P to line AB are inside the section AB
def in_section(p, A, B):
    dot = np.amin((np.dot(B - A, (B - p).T), np.dot(A - B, (A - p).T)), axis=0)
    return dot >= 0


def is_overlap(a, b):
    """

* Helper function to determine whether there is an intersection between the two polygons described
 * by the lists of vertices. Uses the Separating Axis Theorem
 *
 * @param a an ndarray of connected points [[x_1, y_1], [x_2, y_2],...] that form a closed polygon
 * @param b an ndarray of connected points [[x_1, y_1], [x_2, y_2],...] that form a closed polygon
 * @return true if there is any intersection between the 2 polygons, false otherwise
    """

    polygons = [a, b]
    minA, maxA, projected, i, i1, j, minB, maxB = None, None, None, None, None, None, None, None

    for i in range(len(polygons)):

        # for each polygon, look at each edge of the polygon, and determine if it separates
        # the two shapes
        polygon = polygons[i]
        for i1 in range(len(polygon)):

            # grab 2 vertices to create an edge
            i2 = (i1 + 1) % len(polygon)
            p1 = polygon[i1]
            p2 = polygon[i2]

            # find the line perpendicular to this edge
            normal = { 'x': p2[1] - p1[1], 'y': p1[0] - p2[0] }

            minA, maxA = None, None
            # for each vertex in the first shape, project it onto the line perpendicular to the edge
            # and keep track of the min and max of these values
            for j in range(len(a)):
                projected = normal['x'] * a[j][0] + normal['y'] * a[j][1]
                if (minA is None) or (projected < minA):
                    minA = projected

                if (maxA is None) or (projected > maxA):
                    maxA = projected

            # for each vertex in the second shape, project it onto the line perpendicular to the edge
            # and keep track of the min and max of these values
            minB, maxB = None, None
            for j in range(len(b)):
                projected = normal['x'] * b[j][0] + normal['y'] * b[j][1]
                if (minB is None) or (projected < minB):
                    minB = projected

                if (maxB is None) or (projected > maxB):
                    maxB = projected

            # if there is no overlap between the projects, the edge we are looking at separates the two
            # polygons, and we know there is no overlap
            if (maxA < minB) or (maxB < minA):
                return False

    return True


# ******************************************************************************************************


# Parse string (set) to lexems. Ignore short and frequent words by default (full = False)
def lexems(s, full = False):
    if type(s) is str:
        return re.sub('[;()\",/&!?:.\-*·|+$\'«@•]',' ',s.lower()).split()
    elif type(s) is set:
        return [w.lower() for w in s]


def lexem(s):
    return re.sub('[;()\",/&!?:.\-*·|+$\'«@•]', '', s.lower())