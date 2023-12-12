# Device readings project

## Design
I had the following considerations for design. First, when creating the project, I used the following command

`rails new <- application_name -> --skip-active-record`

I did this because the description of the project mentioned that all data should be saved in memory, which means that no database can be used. Consequently, I won't use ActiveRecord nor require it.

Regarding the way of storing the information, I thought of various data structures. In the first place, I thought about a stack, given that we will need information about the latest timestamp in a very regular basis (one endpoint depends on it). However, the requirement also states that the timestamp might arrive in any order; this means that if there is already some timestamp stacked, we would need to unstack and then re-stack to re-construct properly the data structure. Because of that, I changed my initial idea for using a linked list. The list would be ordered at insertion by timestamp. This means that whenever a new node is inserted to this list, the following process will be performed

1. Start at the head of the linked list. Check if the new recording has a timestamp more recent than the analyzed node.
2. If the new recording is more recent than the analyzed node, we have to insert the node here. Create a node and then set the next node to the currently analyzed node. If the analyzed node is the head, replace the head of the node list
3. If the new recording is older than the analyzed node (i.e, the timestamp representation as integer is lower), then proceed to analyze the next node. If this is the final node of the list, create a new node and set it as the next node with the new recording information.

Like this, when we need to find the latest timestamp, this operation will have a O(1) complexity. Also, the insertion operation will have at most a O(n) complexity, which seems like a very good balance of insertion/reading complexity.

After some coding, I found out that it is more practical to implement a double linked list, as it would allow to check the previous element

## Setting up dev server

For running the application, you just have to navigate to the directory and run the `rails server` command.

## Calling the API
I created the following endpoints:

`POST /recordings`

The expected input looks like this:

```
{
	"id": "36d5658a-6908-479e-887e-a949ec199272",
	"readings": [
		{
			"timestamp": "2021-09-30T16:08:15+01:00",
			"count": 2
		},
		{
			"timestamp": "2022-09-29T16:09:15+01:00",
			"count": 8
		}
	]
}
```
The endpoint performs the following validations:

* Checks for existence of the parameters "id" and "readings"
* Checks that each reading contains a timestamp in a format that's parsable with the `Time.parse` function and a count parameter that must be an integer.

If any of the previous validation fails, it will output a 400 error. If all passed, it will try to add it to the HashMap that serves as a Data Store. This Hash has as key the ID of the device and its value is a double linked list that contains the information of the recordings.

The Data Store is implemented following a Singleton pattern, so that all the calls to the controller read and update the same object.

The endpoint returns a JSON with the following structure if the validations didn't pass:

```
{
  "message": "Malformed request"
}
```
and a status of 400 (Bad Request). If the insert was successful, it renders a contentless 200 HTTP response.

`GET /recordings/:device_id/latest`

If there is no recording for this device ID, the endpoint will return

```
{
  "message": "No recordings were found for that list"
}
```

with a status of 404. In the case there is some stored information, it will return a 200 response with a content like this

```
{
	"latest_timestamp": "2022-09-29T16:09:15.000+01:00"
}
```

`GET /recordings/:device_id/cumulative_count`

If there is no recording for this device ID, the endpoint will return

```
{
  "message": "No recordings were found for that list"
}
```

with a status of 404. In the case there is some stored information, it will return a 200 response with a content like this

```
{
	"latest_timestamp": 10
}
```
This operation will have a complexity of O(n)

## Project structure

Following the usual structure of a Rails project, the data store-related classes are in the models folder. These are

* DataStore
* DoubleLinkedList
* LinkedListNode

Regarding the controllers, following the REST API conventions, I created a controller called recordings_controller. Also, for keeping the controller slim, I encapsulated part of the logic regarding validation in a service.

## Possible improvements
Definitely the first improvement I would add given that I had more time, would be to add unit tests in multiple places:
* the DoubleLinkedList behaviors. Check that adding new elements works properly, and that they are automatically sorted when added.
* The validator service. Maybe think of other validation cases, or add error messages to the existing ones.

Maybe it would be worth to save the count data in the data store instead of calculating it each time that the endpoint is called. At insert, we take the previous total count and add to it the new value of the recording. Like this, the operational complexity of getting the cumulative_count would be reduced from O(n) to O(1), but id would add the need to check that the cumulative count is being updated properly.
