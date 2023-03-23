# Setting up a trigger

A trigger can be created with the following command:

```bash
curl --request POST --data '{
  "triggerName": "e0326da3de4b3d4ef4d193907afb82bf9afb938daccea445cbca747bb79c9139:NoOp:noOp",
  "party": "alice",
  "applicationId": "test-app-id"
}' -H 'Content-Type: application/json' localhost:4002/v1/triggers
```
