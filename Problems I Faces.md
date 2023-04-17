### Why was I not the data I sent being received by the other peer?
#### I had to set "negotiated = true". Each negotiated DataChannel must have a UID. If you fail to provide UID then you will only be able to create one negotiated DC.
### When I send data as a caller it is received properly by the Callee. But I want the Caller to get the data I sent as a caller too to keep consistency.
#### I setup a second Data Channel (LoopBack) to send back the data received as a Callee. Not sure if it's scalable when there are multiple peers. 
### Reminder : One Handler will overwrite another. If you have a DC.onMessage in 1.dart and another in 2.dart, only one of them will run. So in order to have multiple Handlers what you might want to do is have a dispatcher that is going to take in all data from the data channel and then dispatch them to where ever it is needed.

#### Here's how I think I can go about it :

```
Map<DataChannelType, Functions[]>  
```
We can store list of functions that need to be dispatched for the specific DataChannelType. <br>
When we receive a data we will then execute all the functions in the map. <br>
To remove the functions we can have the functions in a class and have a UID to them to get rid of specific functions. <br>
We can also check functions list and get rid of functions that are null.
