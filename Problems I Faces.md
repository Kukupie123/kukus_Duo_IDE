### Why was I not the data I sent being received by the other peer?
#### I had to set "negotiated = true". Each negotiated DataChannel must have a UID. If you fail to provide UID then you will only be able to create one negotiated DC.
### When I send data as a caller it is received properly by the Callee. But I want the Caller to get the data I sent as a caller too to keep consistency.
#### I setup a second Data Channel to send back the data received as a Callee. Not sure if it's scalable when there are multiple peers. 