import cv2

#video reader
#cap = cv2.VideoCapture('../videoRendering/TrafficTest.mp4')
cap = cv2.VideoCapture('./car1.avi')

#object classifiers
carCascade = cv2.CascadeClassifier('./cars.xml')
busCascade = cv2.CascadeClassifier('./buses.xml')

#frame count
c = 1
#total number of frames
length = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

while c < length:

    #frame of video
    ret, frame = cap.read()

    #if no frame break
    if (type(frame) == type(None)):
        break

    #clean up image
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    #get cars and buses
    cars = carCascade.detectMultiScale(gray, 1.1, 2)
    buses = busCascade.detectMultiScale(gray, 1.1, 2)

    #draw rectangles on vehicles
    for (x, y, w, h) in cars:
        cv2.rectangle(frame, (x,y), (x + w, y + h), (0,0,255),2)
        
    for (x, y, w, h) in buses:
        cv2.rectangle(frame, (x,y), (x + w, y + h), (0,255, 0),2)

    #display in a window, optionally save it in a folder to be converted to a video
    cv2.imshow('highway_vehicles_detected', frame)
    #success, image = cap.read()
    #cv2.imwrite("./renderedFrames/%03ddetechtion.jpg" % c, image)

    #increment frame count
    c += 1

    #if cv2 doesn't have anymore frames
    if cv2.waitKey(33) == 27:
        print('Detection halted')
        break

#cleanup video reader and open windows
cap.release()
cv2.destroyAllWindows()